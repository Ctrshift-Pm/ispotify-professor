import 'package:flutter/material.dart';
import 'package:spotify_with_flutter/common/helpers/duration_formatter.dart';
import 'package:spotify_with_flutter/common/helpers/is_dark_mode.dart';
import 'package:spotify_with_flutter/common/widgets/favorite_button/favorite_button.dart';
import 'package:spotify_with_flutter/core/configs/theme/app_color.dart';
import 'package:spotify_with_flutter/core/services/app_services.dart';
import 'package:spotify_with_flutter/domain/entities/songs/songs.dart';
import 'package:spotify_with_flutter/presentation/song_player.dart/pages/song_player.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  List<SongEntity> _allSongs = [];
  List<SongEntity> _filteredSongs = [];
  bool _isLoading = true;

  final List<Map<String, dynamic>> _quickCategories = [
    {"title": "Meteora 20", "color": Colors.blueGrey},
    {"title": "Linkin Park", "color": Colors.deepOrangeAccent},
    {"title": "Numb", "color": Colors.blueAccent},
    {"title": "Faint", "color": Colors.green},
    {"title": "Breaking the Habit", "color": Colors.redAccent},
    {"title": "Somewhere I Belong", "color": Colors.purpleAccent},
  ];

  @override
  void initState() {
    super.initState();
    _loadAllSongs();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAllSongs() async {
    try {
      final songs = await songService.getPlayList();
      setState(() {
        _allSongs = songs;
        _filteredSongs = songs;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();
    if (query.isEmpty) {
      setState(() {
        _filteredSongs = _allSongs;
      });
      return;
    }

    setState(() {
      _filteredSongs = _allSongs.where((song) {
        final titleMatch = song.title.toLowerCase().contains(query);
        final artistMatch = song.artist.toLowerCase().contains(query);
        final releaseMatch = song.releaseDate.contains(query);
        return titleMatch || artistMatch || releaseMatch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Buscar",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                ),
              ),
              const SizedBox(height: 15),
              _searchForm(context),
              const SizedBox(height: 20),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _searchController.text.trim().isEmpty
                        ? _categoriesGrid(context)
                        : _searchResultsList(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _searchForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: TextFormField(
        controller: _searchController,
        style: TextStyle(
          color: context.isDarkMode ? Colors.white : Colors.black,
        ),
        decoration: InputDecoration(
          hintText: "O que você quer ouvir hoje?",
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                  },
                  icon: const Icon(Icons.clear_rounded, color: Colors.grey),
                )
              : null,
          filled: true,
          fillColor: context.isDarkMode
              ? AppColors.darkGrey.withValues(alpha: 0.6)
              : AppColors.greyWhite,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _categoriesGrid(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Explorar o álbum",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 15),
        Expanded(
          child: GridView.builder(
            itemCount: _quickCategories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.6,
            ),
            itemBuilder: (context, index) {
              final cat = _quickCategories[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _searchController.text = cat["title"];
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: cat["color"],
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: (cat["color"] as Color).withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Stack(
                    children: [
                      Text(
                        cat["title"],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Positioned(
                        right: -10,
                        bottom: -10,
                        child: Transform.rotate(
                          angle: 0.4,
                          child: const Icon(
                            Icons.music_note_rounded,
                            size: 60,
                            color: Colors.white24,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        )
      ],
    );
  }

  Widget _searchResultsList(BuildContext context) {
    if (_filteredSongs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.sentiment_dissatisfied_rounded, size: 60, color: Colors.grey),
            const SizedBox(height: 15),
            const Text(
              "Nenhuma música encontrada.",
              style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              "Tente buscar por faixa, artista ou data.",
              style: TextStyle(color: Colors.grey.withValues(alpha: 0.8), fontSize: 13),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemBuilder: (context, index) {
        final song = _filteredSongs[index];
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
              Expanded(
                child: Row(
                  children: [
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(
                            song.imageUrl,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            song.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "${song.artist} • ${song.releaseDate}",
                            style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Row(
                children: [
                  Text(
                    formatSongDuration(song.duration),
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(width: 15),
                  FavoriteButton(songEntity: song),
                ],
              ),
            ],
          ),
        );
      },
      separatorBuilder: (context, index) => const SizedBox(height: 20),
      itemCount: _filteredSongs.length,
    );
  }
}
