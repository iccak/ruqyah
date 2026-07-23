import 'package:flutter/material.dart';

import '../theme.dart';
import 'star_pattern_background.dart';

/// رأس الشاشة الموحّد: عنوان كبير بخط عريض، عبارة فرعية، وخلفية خضراء
/// نعناعية بنمط زخرفي خفيف. يمكن إضافة زر دائري في الأعلى (مثل زر
/// رجوع) عبر [trailing].
class AppHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? trailing;

  const AppHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return StarPatternBackground(
      patternColor: AppTheme.heroPattern,
      child: Container(
        width: double.infinity,
        color: AppTheme.heroBackground,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 26),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.primaryGreenDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
