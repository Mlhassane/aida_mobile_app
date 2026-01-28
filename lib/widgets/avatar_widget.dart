import 'dart:io';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import '../services/avatar_service.dart';
import '../core/theme_colors.dart';

/// Widget réutilisable pour afficher un avatar (asset ou image personnelle)
class AvatarWidget extends StatelessWidget {
  final String? avatarAsset;
  final String? profileImagePath;
  final double size;
  final bool showShadow;

  const AvatarWidget({
    super.key,
    this.avatarAsset,
    this.profileImagePath,
    this.size = 50,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget avatarWidget;

    if (profileImagePath != null) {
      // Afficher la photo personnelle
      avatarWidget = ClipOval(
        child: Image.file(
          File(profileImagePath!),
          width: size,
          height: size,
          cacheWidth: size.toInt(),
          cacheHeight: size.toInt(),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildDefaultAvatar(context, size);
          },
        ),
      );
    } else if (avatarAsset != null) {
      // Afficher l'avatar asset
      avatarWidget = ClipOval(
        child: Image.asset(
          AvatarService.getAvatarAssetPath(avatarAsset!),
          width: size,
          height: size,
          cacheWidth: size.toInt(),
          cacheHeight: size.toInt(),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildDefaultAvatar(context, size);
          },
        ),
      );
    } else {
      // Avatar par défaut
      avatarWidget = _buildDefaultAvatar(context, size);
    }

    if (!showShadow) {
      return avatarWidget;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: ThemeColors.getPrimaryColor(context).withOpacity(0.3),
            blurRadius: size * 0.16,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: avatarWidget,
    );
  }

  Widget _buildDefaultAvatar(BuildContext context, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ThemeColors.getPrimaryColor(context),
            ThemeColors.getPrimaryColor(context).withOpacity(0.7),
          ],
        ),
        shape: BoxShape.circle,
      ),
      child: Icon(IconlyBold.profile, color: Colors.white, size: size * 0.56),
    );
  }
}
