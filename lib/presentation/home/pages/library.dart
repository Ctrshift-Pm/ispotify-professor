import 'package:flutter/material.dart';
import 'package:spotify_with_flutter/common/helpers/is_dark_mode.dart';
import 'package:spotify_with_flutter/core/configs/theme/app_color.dart';
import 'package:spotify_with_flutter/core/services/app_services.dart';
import 'package:spotify_with_flutter/domain/entities/playlist/playlist.dart';
import 'package:spotify_with_flutter/presentation/home/pages/playlist_details.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.library_music_rounded, color: AppColors.primary, size: 28),
                      SizedBox(width: 10),
                      Text(
                        "Sua Biblioteca",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.add_rounded, color: Colors.grey, size: 28),
                  )
                ],
              ),
              const SizedBox(height: 15),
              TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: context.isDarkMode ? AppColors.white : AppColors.dark,
                indicatorColor: AppColors.primary,
                tabAlignment: TabAlignment.start,
                tabs: const [
                  Tab(text: "Todas"),
                  Tab(text: "Álbum"),
                  Tab(text: "Singles"),
                  Tab(text: "Clipes"),
                ],
              ),
              const SizedBox(height: 15),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: const [
                    _LibraryPlaylistTab(category: "ALL"),
                    _LibraryPlaylistTab(category: "ALBUM"),
                    _LibraryPlaylistTab(category: "SINGLES"),
                    _LibraryPlaylistTab(category: "CLIPES"),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _LibraryPlaylistTab extends StatelessWidget {
  final String category;

  const _LibraryPlaylistTab({required this.category});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PlaylistEntity>>(
      future: songService.getPlaylistsByCategory(category),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return _playlistsList(snapshot.data!);
      },
    );
  }

  Widget _playlistsList(List<PlaylistEntity> playlists) {
    if (playlists.isEmpty) {
      return const Center(
        child: Text(
          "Nenhuma playlist encontrada.",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.separated(
      itemCount: playlists.length,
      separatorBuilder: (context, index) => const SizedBox(height: 18),
      itemBuilder: (context, index) {
        final playlist = playlists[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlaylistDetailsPage(playlist: playlist),
              ),
            );
          },
          child: Row(
            children: [
              Container(
                height: 70,
                width: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(playlist.coverUrl),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      playlist.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      playlist.description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Álbum • ${playlist.tracks.length} faixas • ${playlist.category}",
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.chevron_right_rounded, color: Colors.grey),
            ],
          ),
        );
      },
    );
  }
}
