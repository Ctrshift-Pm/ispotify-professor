import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart' hide PlayerState;
import 'package:spotify_with_flutter/common/helpers/is_dark_mode.dart';
import 'package:spotify_with_flutter/common/widgets/appbar/app_bar.dart';
import 'package:spotify_with_flutter/common/widgets/favorite_button/favorite_button.dart';
import 'package:spotify_with_flutter/common/widgets/media_mode_pill.dart';
import 'package:spotify_with_flutter/core/configs/theme/app_color.dart';
import 'package:spotify_with_flutter/core/services/app_services.dart';
import 'package:spotify_with_flutter/domain/entities/songs/songs.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class SongPlayerPage extends StatefulWidget {
  final SongEntity songEntity;

  const SongPlayerPage({
    super.key,
    required this.songEntity,
  });

  @override
  State<SongPlayerPage> createState() => _SongPlayerPageState();
}

class _SongPlayerPageState extends State<SongPlayerPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _notesController = TextEditingController();
  final AudioPlayer _audioPlayer = AudioPlayer();

  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration?>? _durationSubscription;
  StreamSubscription<YoutubeVideoState>? _youtubeVideoStateSubscription;
  StreamSubscription<YoutubePlayerValue>? _youtubeValueSubscription;

  YoutubePlayerController? _youtubeController;

  bool _isVideoMode = false;
  bool _isLoadingMedia = true;
  bool _isLoadingNotes = true;
  Duration _songPosition = Duration.zero;
  Duration _songDuration = Duration.zero;
  PlayerState _youtubePlayerState = PlayerState.unknown;

  bool get _hasOfficialYoutubeVideo =>
      _extractYoutubeVideoId(widget.songEntity.videoUrl) != null;

  bool get _usesYoutubeAsSource => _youtubeController != null;

  bool get _isPlaying {
    if (_usesYoutubeAsSource) {
      return _youtubePlayerState == PlayerState.playing;
    }
    return _audioPlayer.playing;
  }

  @override
  void initState() {
    super.initState();
    _loadMedia();
    _loadNotes();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _youtubeVideoStateSubscription?.cancel();
    _youtubeValueSubscription?.cancel();
    _youtubeController?.close();
    _audioPlayer.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadMedia() async {
    final youtubeVideoId = _extractYoutubeVideoId(widget.songEntity.videoUrl);
    if (youtubeVideoId != null) {
      _loadYoutubePlayer(youtubeVideoId);
      return;
    }
    await _loadAudioPreview();
  }

  void _loadYoutubePlayer(String videoId) {
    final controller = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      autoPlay: false,
      params: const YoutubePlayerParams(
        showControls: false,
        showFullscreenButton: true,
        enableCaption: true,
        interfaceLanguage: 'pt',
        strictRelatedVideos: true,
        privacyEnhancedMode: true,
      ),
    );

    _youtubeController = controller;
    _youtubeValueSubscription = controller.stream.listen((value) {
      if (!mounted) {
        return;
      }

      setState(() {
        _youtubePlayerState = value.playerState;
        final duration = controller.metadata.duration;
        if (duration > Duration.zero) {
          _songDuration = duration;
        }
        _isLoadingMedia = value.playerState == PlayerState.unknown &&
            controller.metadata.duration == Duration.zero;
      });
    });

    _youtubeVideoStateSubscription = controller.videoStateStream.listen((state) {
      if (!mounted) {
        return;
      }

      setState(() {
        _songPosition = state.position;
        final duration = controller.metadata.duration;
        if (duration > Duration.zero) {
          _songDuration = duration;
          _isLoadingMedia = false;
        }
      });
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoadingMedia = false;
      });
    });
  }

  Future<void> _loadAudioPreview() async {
    _positionSubscription = _audioPlayer.positionStream.listen((position) {
      if (mounted) {
        setState(() => _songPosition = position);
      }
    });

    _durationSubscription = _audioPlayer.durationStream.listen((duration) {
      if (mounted && duration != null) {
        setState(() => _songDuration = duration);
      }
    });

    try {
      await _audioPlayer.setUrl(widget.songEntity.audioUrl);
    } finally {
      if (mounted) {
        setState(() => _isLoadingMedia = false);
      }
    }
  }

  Future<void> _loadNotes() async {
    final notes = await songService.getPrivateNotes(widget.songEntity.songId);
    if (!mounted) {
      return;
    }

    setState(() {
      _notesController.text = notes;
      _isLoadingNotes = false;
    });
  }

  Future<void> _saveNotes() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await songService.savePrivateNotes(
      widget.songEntity.songId,
      _notesController.text.trim(),
    );

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notas salvas com sucesso!'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _togglePlayback() async {
    if (_usesYoutubeAsSource) {
      if (_youtubePlayerState == PlayerState.playing) {
        await _youtubeController!.pauseVideo();
      } else {
        await _youtubeController!.playVideo();
      }
      return;
    }

    if (_audioPlayer.playing) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _seekMedia(double value) async {
    if (_usesYoutubeAsSource) {
      await _youtubeController!.seekTo(
        seconds: value,
        allowSeekAhead: true,
      );
      return;
    }

    await _audioPlayer.seek(Duration(seconds: value.toInt()));
  }

  Future<void> _openOfficialVideoExternally() async {
    final videoUrl = widget.songEntity.videoUrl;
    if (videoUrl == null || videoUrl.isEmpty) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nenhum link oficial do YouTube foi cadastrado para esta faixa.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    await launchUrl(
      Uri.parse(videoUrl),
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BasicAppBar(
        title: const Text(
          'Tocando Agora',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        action: IconButton(
          onPressed: () {},
          icon: Icon(
            Icons.more_vert_rounded,
            color: context.isDarkMode
                ? const Color(0xff959595)
                : const Color(0xff555555),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Column(
            children: [
              _mediaDisplay(context),
              const SizedBox(height: 12),
              if (_hasOfficialYoutubeVideo) _modeSelector(),
              if (_hasOfficialYoutubeVideo) const SizedBox(height: 12),
              _songDetail(),
              const SizedBox(height: 20),
              _songPlayer(),
              const SizedBox(height: 30),
              _studyNotesForm(context),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mediaDisplay(BuildContext context) {
    final mediaHeight = MediaQuery.of(context).size.height / 2.3;

    if (_usesYoutubeAsSource) {
      return Container(
        height: mediaHeight,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Stack(
            fit: StackFit.expand,
            children: [
              YoutubePlayer(
                controller: _youtubeController!,
                aspectRatio: 16 / 9,
              ),
              if (!_isVideoMode)
                Container(
                  color: Colors.black.withValues(alpha: 0.82),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Opacity(
                        opacity: 0.35,
                        child: Image.network(
                          widget.songEntity.imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 160,
                            width: 160,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              image: DecorationImage(
                                image: NetworkImage(widget.songEntity.imageUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            'Áudio do YouTube oficial',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'O som continua enquanto você alterna para vídeo.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              Positioned(
                right: 12,
                top: 12,
                child: FilledButton.tonalIcon(
                  onPressed: _openOfficialVideoExternally,
                  icon: const Icon(Icons.open_in_new_rounded, size: 16),
                  label: const Text('YouTube'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.black.withValues(alpha: 0.5),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: mediaHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        image: DecorationImage(
          fit: BoxFit.cover,
          image: NetworkImage(widget.songEntity.imageUrl),
        ),
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Text(
            'Prévia oficial em áudio',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _modeSelector() {
    return Center(
      child: MediaModePill(
        isVideoSelected: _isVideoMode,
        onChanged: (isVideoSelected) {
          setState(() {
            _isVideoMode = isVideoSelected;
          });
        },
      ),
    );
  }

  Widget _songDetail() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.songEntity.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 5),
              Text(
                widget.songEntity.artist,
                style: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        FavoriteButton(
          sizeIcons: 30,
          songEntity: widget.songEntity,
        ),
      ],
    );
  }

  Widget _songPlayer() {
    if (_isLoadingMedia) {
      return const CircularProgressIndicator();
    }

    final maxDuration =
        _songDuration.inSeconds <= 0 ? 1.0 : _songDuration.inSeconds.toDouble();
    final currentPosition =
        _songPosition.inSeconds.clamp(0, maxDuration.toInt()).toDouble();

    return Column(
      children: [
        Slider(
          value: currentPosition,
          min: 0.0,
          max: maxDuration,
          activeColor: AppColors.primary,
          inactiveColor: Colors.grey.withValues(alpha: 0.3),
          onChanged: _seekMedia,
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatDuration(_songPosition),
              style: const TextStyle(color: Colors.grey),
            ),
            Text(
              _formatDuration(_songDuration),
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 15),
        GestureDetector(
          onTap: _togglePlayback,
          child: Container(
            height: 60,
            width: 60,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
            ),
            child: Icon(
              _isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: 35,
            ),
          ),
        ),
      ],
    );
  }

  Widget _studyNotesForm(BuildContext context) {
    if (_isLoadingNotes) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.isDarkMode
            ? AppColors.darkGrey.withValues(alpha: 0.5)
            : AppColors.greyWhite.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: context.isDarkMode
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.notes_rounded, color: AppColors.primary, size: 22),
                SizedBox(width: 8),
                Text(
                  'Anotacoes & Letras',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              maxLines: 4,
              minLines: 2,
              style: TextStyle(
                color: context.isDarkMode ? Colors.white : Colors.black,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'Digite suas notas, letras ou pensamentos da musica...',
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                filled: true,
                fillColor: context.isDarkMode
                    ? Colors.black.withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(15),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor, insira alguma nota.';
                }
                if (value.trim().length < 3) {
                  return 'Sua nota precisa de no minimo 3 caracteres.';
                }
                return null;
              },
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: _saveNotes,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  icon: const Icon(Icons.save_rounded, size: 18),
                  label: const Text(
                    'Salvar Notas',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String? _extractYoutubeVideoId(String? url) {
    if (url == null || url.isEmpty) {
      return null;
    }

    final uri = Uri.tryParse(url);
    if (uri == null) {
      return null;
    }

    if (uri.host.contains('youtu.be')) {
      return uri.pathSegments.isEmpty ? null : uri.pathSegments.first;
    }

    if (uri.host.contains('youtube.com')) {
      return uri.queryParameters['v'];
    }

    return null;
  }
}
