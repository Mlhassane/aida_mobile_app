class AvatarHelper {
  // Liste des avatars disponibles
  static const List<String> availableAvatars = [
    'assets/avatar_01.png',
    'assets/avatar_02.png',
    'assets/avatar_03.png',
    'assets/avatar_04.png',
    'assets/avatar_05.png',
    'assets/avatar_06.png',
    'assets/avatar_07.png',
    'assets/avatar_08.png',
    'assets/avatar_09.png',
    'assets/avatar_10.png',
  ];

  // Obtenir un avatar par défaut aléatoire
  static String getRandomAvatar() {
    final random = DateTime.now().millisecond % availableAvatars.length;
    return availableAvatars[random];
  }

  // Vérifier si c'est un avatar asset ou une image personnalisée
  static bool isAssetAvatar(String? avatarPath) {
    if (avatarPath == null) return false;
    return availableAvatars.contains(avatarPath);
  }
}
