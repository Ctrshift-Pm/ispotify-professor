import 'package:spotify_with_flutter/data/models/songs/songs.dart';
import 'package:spotify_with_flutter/domain/entities/playlist/playlist.dart';

class PlaylistModel {
  String? id;
  String? title;
  String? description;
  String? coverUrl;
  List<SongModel>? tracks;
  String? category;

  PlaylistModel({
    this.id,
    this.title,
    this.description,
    this.coverUrl,
    this.tracks,
    this.category,
  });

  PlaylistModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    coverUrl = json['coverUrl'];
    category = json['category'];
    if (json['tracks'] != null) {
      tracks = <SongModel>[];
      json['tracks'].forEach((v) {
        tracks!.add(SongModel.fromJson(v));
      });
    }
  }
}

extension PlaylistModelX on PlaylistModel {
  PlaylistEntity toEntity() {
    return PlaylistEntity(
      id: id ?? '',
      title: title ?? '',
      description: description ?? '',
      coverUrl: coverUrl ?? '',
      category: category ?? '',
      tracks: tracks?.map((e) => e.toEntity()).toList() ?? [],
    );
  }
}
