import 'package:spotify_with_flutter/domain/entities/songs/songs.dart';

class PlaylistEntity {
  final String id;
  final String title;
  final String description;
  final String coverUrl;
  final List<SongEntity> tracks;
  final String category; // 'N1', 'N2', 'Revisão'

  PlaylistEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.coverUrl,
    required this.tracks,
    required this.category,
  });
}
