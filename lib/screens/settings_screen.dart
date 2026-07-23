import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/app_header.dart';

/// شاشة الإعدادات: معلومات بسيطة عن التطبيق. يمكن التوسّع فيها لاحقًا
/// (مثل تغيير حجم الخط أو إدارة النسخ الاحتياطي).
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const AppHeader(
          title: 'الإعدادات',
          subtitle: 'معلومات عن التطبيق',
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _InfoTile(
                icon: Icons.info_outline,
                title: 'عن التطبيق',
                subtitle: 'رقيتي — تطبيق لإنشاء وتشغيل قوائم رقية مخصصة بالكامل دون اتصال بالإنترنت.',
              ),
              const SizedBox(height: 12),
              _InfoTile(
                icon: Icons.wifi_off_outlined,
                title: 'يعمل بدون إنترنت',
                subtitle: 'جميع السور والرقيات محفوظة على جهازك فقط.',
              ),
              const SizedBox(height: 12),
              _InfoTile(
                icon: Icons.numbers,
                title: 'الإصدار',
                subtitle: '1.0.0',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoTile({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEDEAE0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.softGreen,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppTheme.primaryGreen),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18)),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 15, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
