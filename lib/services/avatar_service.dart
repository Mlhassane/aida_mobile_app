import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../core/logger.dart';

class AvatarService {
  static const List<String> availableAvatars = [
    'avatar_01.png',
    'avatar_02.png',
    'avatar_03.png',
    'avatar_04.png',
    'avatar_05.png',
    'avatar_06.png',
    'avatar_07.png',
    'avatar_08.png',
    'avatar_09.png',
    'avatar_10.png',
  ];

  // Obtenir le chemin de l'avatar asset
  static String getAvatarAssetPath(String avatarName) {
    return 'assets/$avatarName';
  }

  // Obtenir tous les chemins d'avatars
  static List<String> getAllAvatarPaths() {
    return availableAvatars
        .map((avatar) => getAvatarAssetPath(avatar))
        .toList();
  }

  // Sélectionner une image depuis la galerie
  static Future<String?> pickImageFromGallery({Color? primaryColor}) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image == null) return null;

      // Recadrer l'image
      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: image.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Recadrer l\'image',
            toolbarColor: primaryColor ?? const Color(0xFF4CAF50),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
            hideBottomControls: false,
          ),
          IOSUiSettings(
            title: 'Recadrer l\'image',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
          ),
        ],
      );

      if (croppedFile == null) return null;

      // Copier l'image dans le dossier de l'application
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String avatarDir = path.join(appDir.path, 'avatars');
      await Directory(avatarDir).create(recursive: true);

      final String fileName =
          'profile_${DateTime.now().millisecondsSinceEpoch}.png';
      final String savedPath = path.join(avatarDir, fileName);

      final File savedFile = await File(croppedFile.path).copy(savedPath);
      return savedFile.path;
    } catch (e, st) {
      logger.severe('Erreur lors de la sélection de l\'image: $e', e, st);
      return null;
    }
  }

  // Prendre une photo avec la caméra
  static Future<String?> takePhotoWithCamera({Color? primaryColor}) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image == null) return null;

      // Recadrer l'image
      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: image.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Recadrer l\'image',
            toolbarColor: primaryColor ?? const Color(0xFF4CAF50),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
            hideBottomControls: false,
          ),
          IOSUiSettings(
            title: 'Recadrer l\'image',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
          ),
        ],
      );

      if (croppedFile == null) return null;

      // Copier l'image dans le dossier de l'application
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String avatarDir = path.join(appDir.path, 'avatars');
      await Directory(avatarDir).create(recursive: true);

      final String fileName =
          'profile_${DateTime.now().millisecondsSinceEpoch}.png';
      final String savedPath = path.join(avatarDir, fileName);

      final File savedFile = await File(croppedFile.path).copy(savedPath);
      return savedFile.path;
    } catch (e, st) {
      logger.severe('Erreur lors de la prise de photo: $e', e, st);
      return null;
    }
  }

  // Vérifier si un fichier existe
  static Future<bool> fileExists(String filePath) async {
    try {
      final file = File(filePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  // Supprimer une image
  static Future<bool> deleteImage(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e, st) {
      logger.severe('Erreur lors de la suppression de l\'image: $e', e, st);
      return false;
    }
  }
}
