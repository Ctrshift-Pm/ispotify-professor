import 'package:flutter/material.dart';
import 'package:spotify_with_flutter/core/configs/theme/app_color.dart';
import 'package:spotify_with_flutter/core/services/app_services.dart';
import 'package:spotify_with_flutter/domain/entities/songs/songs.dart';

class FavoriteButton extends StatefulWidget {
  final SongEntity songEntity;
  final double sizeIcons;
  final VoidCallback? onChanged;

  const FavoriteButton({
    super.key,
    required this.songEntity,
    this.sizeIcons = 25,
    this.onChanged,
  });

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  bool _isSubmitting = false;

  Future<void> _toggleFavorite() async {
    if (_isSubmitting) {
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final isFavorite = await songService.addOrRemoveFavoriteSong(
        widget.songEntity.songId,
      );
      setState(() {
        widget.songEntity.isFavorite = isFavorite;
      });
      widget.onChanged?.call();
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _toggleFavorite,
      icon: Icon(
        widget.songEntity.isFavorite
            ? Icons.favorite
            : Icons.favorite_outline_outlined,
        size: widget.sizeIcons,
        color: AppColors.darkGrey,
      ),
    );
  }
}
