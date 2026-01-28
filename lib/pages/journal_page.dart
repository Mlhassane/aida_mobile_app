import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import '../core/theme_colors.dart';

import 'package:hive_flutter/hive_flutter.dart';
import '../services/journal_service.dart';
import '../services/hive_service.dart';
import '../models/journal_model.dart';
import 'journal_write_page.dart';

class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.getBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            IconlyLight.arrow_left_2,
            color: ThemeColors.getTextColor(context),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Journal',
          style: TextStyle(
            color: ThemeColors.getTextColor(context),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: HiveService.journalBox.listenable(),
        builder: (context, box, _) {
          final entries = JournalService.getAllEntries();

          if (entries.isEmpty) {
            return _buildEmptyState();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mes entrées',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: ThemeColors.getTextColor(context),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 16),
                ...entries.map((entry) => _buildJournalEntry(entry)),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const JournalWritePage()),
          );
        },
        backgroundColor: ThemeColors.getPrimaryColor(context),
        icon: const Icon(IconlyBold.edit, color: Colors.white),
        label: const Text(
          'Nouvelle entrée',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: ThemeColors.getPrimaryColor(context).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              IconlyBold.edit,
              size: 64,
              color: ThemeColors.getPrimaryColor(context),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Aucune entrée',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: ThemeColors.getTextColor(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Commence à écrire dans ton journal\npour suivre ton bien-être',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: ThemeColors.getSecondaryTextColor(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJournalEntry(JournalModel entry) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JournalWritePage(entry: entry),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: ThemeColors.getCardColor(context),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: ThemeColors.getBorderColor(context),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: ThemeColors.getShadowColor(context),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(entry.mood ?? '😐', style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.title ?? 'Sans titre',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: ThemeColors.getTextColor(context),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        DateFormat('dd MMMM yyyy', 'fr_FR').format(entry.date),
                        style: TextStyle(
                          fontSize: 12,
                          color: ThemeColors.getSecondaryTextColor(context),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  IconlyLight.arrow_right_2,
                  color: ThemeColors.getPrimaryColor(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              entry.content,
              style: TextStyle(
                fontSize: 14,
                color: ThemeColors.getTextColor(context).withOpacity(0.8),
                height: 1.5,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (entry.tags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: entry.tags
                    .map(
                      (tag) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: ThemeColors.getPrimaryColor(
                            context,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            fontSize: 10,
                            color: ThemeColors.getPrimaryColor(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
