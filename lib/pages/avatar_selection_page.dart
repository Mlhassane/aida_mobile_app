import 'dart:io';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import '../models/user_model.dart';
import '../services/avatar_service.dart';
import '../services/user_service.dart';
import '../core/theme_colors.dart';

class AvatarSelectionPage extends StatefulWidget {
  const AvatarSelectionPage({super.key});

  @override
  State<AvatarSelectionPage> createState() => _AvatarSelectionPageState();
}

class _AvatarSelectionPageState extends State<AvatarSelectionPage> {
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() {
    setState(() {
      _user = UserService.getUser();
    });
  }

  Future<void> _selectAvatarAsset(String avatarName) async {
    if (_user == null) return;

    final updated = _user!.copyWith(
      avatarAsset: avatarName,
      profileImagePath:
          null, // Supprimer la photo personnelle si on choisit un avatar
    );
    await UserService.updateUser(updated);
    _loadUser();

    if (mounted) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Avatar sélectionné avec succès'),
          backgroundColor: ThemeColors.getPrimaryColor(context),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _pickImageFromGallery() async {
    final imagePath = await AvatarService.pickImageFromGallery(
      primaryColor: ThemeColors.getPrimaryColor(context),
    );
    if (imagePath != null && _user != null) {
      // Supprimer l'ancienne photo si elle existe
      if (_user!.profileImagePath != null) {
        await AvatarService.deleteImage(_user!.profileImagePath!);
      }

      final updated = _user!.copyWith(
        profileImagePath: imagePath,
        avatarAsset: null, // Supprimer l'avatar asset si on choisit une photo
      );
      await UserService.updateUser(updated);
      _loadUser();

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Photo sélectionnée avec succès'),
            backgroundColor: ThemeColors.getPrimaryColor(context),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _takePhotoWithCamera() async {
    final imagePath = await AvatarService.takePhotoWithCamera(
      primaryColor: ThemeColors.getPrimaryColor(context),
    );
    if (imagePath != null && _user != null) {
      // Supprimer l'ancienne photo si elle existe
      if (_user!.profileImagePath != null) {
        await AvatarService.deleteImage(_user!.profileImagePath!);
      }

      final updated = _user!.copyWith(
        profileImagePath: imagePath,
        avatarAsset: null, // Supprimer l'avatar asset si on choisit une photo
      );
      await UserService.updateUser(updated);
      _loadUser();

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Photo prise avec succès'),
            backgroundColor: ThemeColors.getPrimaryColor(context),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _showImageSourceDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Choisir une source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                IconlyBold.image,
                color: ThemeColors.getPrimaryColor(context),
              ),
              title: const Text('Galerie'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
            ),
            ListTile(
              leading: Icon(
                IconlyBold.camera,
                color: ThemeColors.getPrimaryColor(context),
              ),
              title: const Text('Appareil photo'),
              onTap: () {
                Navigator.pop(context);
                _takePhotoWithCamera();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarWidget(String? avatarAsset, String? profileImagePath) {
    if (profileImagePath != null) {
      // Afficher la photo personnelle
      return ClipOval(
        child: Image.file(
          File(profileImagePath),
          width: 80,
          height: 80,
          cacheWidth: 160,
          cacheHeight: 160,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ThemeColors.getPrimaryColor(context),
                    ThemeColors.getPrimaryColor(context).withOpacity(0.7),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                IconlyBold.profile,
                color: Colors.white,
                size: 40,
              ),
            );
          },
        ),
      );
    } else if (avatarAsset != null) {
      // Afficher l'avatar asset
      return ClipOval(
        child: Image.asset(
          AvatarService.getAvatarAssetPath(avatarAsset),
          width: 80,
          height: 80,
          cacheWidth: 160,
          cacheHeight: 160,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ThemeColors.getPrimaryColor(context),
                    ThemeColors.getPrimaryColor(context).withOpacity(0.7),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                IconlyBold.profile,
                color: Colors.white,
                size: 40,
              ),
            );
          },
        ),
      );
    } else {
      // Avatar par défaut
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              ThemeColors.getPrimaryColor(context),
              ThemeColors.getPrimaryColor(context).withOpacity(0.7),
            ],
          ),
          shape: BoxShape.circle,
        ),
        child: const Icon(IconlyBold.profile, color: Colors.white, size: 40),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.getBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: ThemeColors.getBackgroundColor(context),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(IconlyLight.arrow_left_2),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Choisir un avatar',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar actuel
            Center(
              child: Column(
                children: [
                  _buildAvatarWidget(
                    _user?.avatarAsset,
                    _user?.profileImagePath,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Avatar actuel',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: ThemeColors.getTextColor(context),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Option pour ajouter une photo personnelle
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ThemeColors.getCardColor(context),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: ThemeColors.getBorderColor(context)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        IconlyBold.camera,
                        color: ThemeColors.getPrimaryColor(context),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Photo personnelle',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: ThemeColors.getTextColor(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _showImageSourceDialog,
                          icon: const Icon(IconlyBold.image),
                          label: const Text('Choisir une photo'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ThemeColors.getPrimaryColor(
                              context,
                            ),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Avatars disponibles
            Text(
              'Avatars disponibles',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: ThemeColors.getTextColor(context),
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemCount: AvatarService.availableAvatars.length,
              itemBuilder: (context, index) {
                final avatarName = AvatarService.availableAvatars[index];
                final isSelected = _user?.avatarAsset == avatarName;

                return GestureDetector(
                  onTap: () => _selectAvatarAsset(avatarName),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? ThemeColors.getPrimaryColor(context)
                            : ThemeColors.getBorderColor(context),
                        width: isSelected ? 3 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: ThemeColors.getPrimaryColor(
                                  context,
                                ).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(13),
                      child: Image.asset(
                        AvatarService.getAvatarAssetPath(avatarName),
                        fit: BoxFit.cover,
                        cacheWidth: 100,
                        cacheHeight: 100,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: ThemeColors.getCardColor(context),
                            child: Icon(
                              IconlyBold.profile,
                              color: ThemeColors.getSecondaryTextColor(context),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
