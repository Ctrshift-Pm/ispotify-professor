import 'package:flutter/material.dart';
import 'package:spotify_with_flutter/common/helpers/duration_formatter.dart';
import 'package:spotify_with_flutter/common/helpers/is_dark_mode.dart';
import 'package:spotify_with_flutter/common/widgets/appbar/app_bar.dart';
import 'package:spotify_with_flutter/common/widgets/favorite_button/favorite_button.dart';
import 'package:spotify_with_flutter/core/configs/theme/app_color.dart';
import 'package:spotify_with_flutter/core/services/app_services.dart';
import 'package:spotify_with_flutter/domain/entities/auth/user.dart';
import 'package:spotify_with_flutter/domain/entities/songs/songs.dart';
import 'package:spotify_with_flutter/presentation/song_player.dart/pages/song_player.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<UserEntity> _userFuture;
  late Future<List<SongEntity>> _favoriteSongsFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = authService.getUser();
    _favoriteSongsFuture = songService.getUserFavoriteSong();
  }

  void _reloadFavoriteSongs() {
    setState(() {
      _favoriteSongsFuture = songService.getUserFavoriteSong();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BasicAppBar(
        backgroundColor: AppColors.metalDark,
        title: Text('Perfil'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _profileInfo(context),
          const SizedBox(height: 30),
          Expanded(child: _favoriteSongs()),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Text(
              'LINKIN PARK, Meteora 20 e respectivas obras audiovisuais: todos os direitos reservados aos seus detentores.',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.withValues(alpha: 0.9),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileInfo(BuildContext context) {
    return FutureBuilder<UserEntity>(
      future: _userFuture,
      builder: (context, snapshot) {
        return Container(
          height: MediaQuery.of(context).size.height / 3.5,
          decoration: BoxDecoration(
            color: context.isDarkMode ? AppColors.metalDark : AppColors.white,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(50),
              bottomRight: Radius.circular(50),
            ),
          ),
          child: Center(
            child: switch (snapshot.connectionState) {
              ConnectionState.done when snapshot.hasData => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: NetworkImage(snapshot.data!.imageURL!),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(snapshot.data!.email ?? ''),
                    const SizedBox(height: 15),
                    Text(
                      snapshot.data!.fullName ?? '',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                  ],
                ),
              ConnectionState.done => const Text('Tente novamente'),
              _ => const CircularProgressIndicator(),
            },
          ),
        );
      },
    );
  }

  Widget _favoriteSongs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('MÚSICAS FAVORITAS'),
          const SizedBox(height: 20),
          Expanded(
            child: FutureBuilder<List<SongEntity>>(
              future: _favoriteSongsFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final favoriteSongs = snapshot.data!;
                if (favoriteSongs.isEmpty) {
                  return const Center(child: Text('Nenhuma música favoritada.'));
                }

                return ListView.separated(
                  itemCount: favoriteSongs.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 20),
                  itemBuilder: (context, index) {
                    final song = favoriteSongs[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SongPlayerPage(songEntity: song),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                height: 60,
                                width: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: NetworkImage(
                                      song.imageUrl,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    song.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    song.artist,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(formatSongDuration(song.duration)),
                              const SizedBox(width: 20),
                              FavoriteButton(
                                key: ValueKey(song.songId),
                                songEntity: song,
                                onChanged: _reloadFavoriteSongs,
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
