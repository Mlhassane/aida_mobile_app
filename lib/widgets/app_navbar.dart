import 'package:flutter/material.dart';
import 'dart:ui' show ImageFilter;
import 'package:iconly/iconly.dart';
import '../core/theme_colors.dart';

class AppNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onItemSelected;

  const AppNavBar({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 85,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black.withOpacity(0.8)
                  : Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavBarItem(
                  icon: IconlyLight.home,
                  activeIcon: IconlyBold.home,
                  label: "Accueil",
                  isSelected: currentIndex == 0,
                  onTap: () => onItemSelected(0),
                ),
                _NavBarItem(
                  icon: IconlyLight.folder,
                  activeIcon: IconlyBold.folder,
                  label: "Modules",
                  isSelected: currentIndex == 1,
                  onTap: () => onItemSelected(1),
                ),
                _buildCentralButton(context),
                _NavBarItem(
                  icon: IconlyLight.chart,
                  activeIcon: IconlyBold.chart,
                  label: "Stats",
                  isSelected: currentIndex == 3,
                  onTap: () => onItemSelected(3),
                ),
                _NavBarItem(
                  icon: IconlyLight.profile,
                  activeIcon: IconlyBold.profile,
                  label: "Profil",
                  isSelected: currentIndex == 4,
                  onTap: () => onItemSelected(4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCentralButton(BuildContext context) {
    final isSelected = currentIndex == 2;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => onItemSelected(2),
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          color: isSelected
              ? ThemeColors.getPrimaryColor(context)
              : (isDark ? Colors.grey[900] : Colors.white),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color:
                  (isSelected
                          ? ThemeColors.getPrimaryColor(context)
                          : Colors.black)
                      .withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.05),
            width: 1,
          ),
        ),
        child: Icon(
          isSelected ? IconlyBold.chat : IconlyLight.chat,
          color: isSelected
              ? Colors.white
              : (isDark ? Colors.white : Colors.black),
          size: 28,
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDark ? Colors.white : Colors.black;
    final inactiveColor = isDark ? Colors.grey[600] : Colors.grey[400];

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(8),
            child: Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? activeColor : inactiveColor,
              size: 24,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? activeColor : inactiveColor,
            ),
          ),
        ],
      ),
    );
  }
}
