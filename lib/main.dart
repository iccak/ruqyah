import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'screens/home_screen.dart';
import 'services/audio_service_provider.dart';
import 'services/storage_service.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة التخزين المحلي (Hive) قبل تشغيل الواجهة
  await StorageService.instance.init();

  // تهيئة خدمة الصوت في الخلفية (Background Service) مرة واحدة فقط
  await initAudioService();

  runApp(const RuqyahApp());
}

/// التطبيق الرئيسي: يفرض اتجاه RTL ولغة عربية بالكامل، ويستخدم
/// ثيمًا عالي التباين وخطوطًا كبيرة مناسبة لكبار السن.
class RuqyahApp extends StatelessWidget {
  const RuqyahApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'الرقية الشرعية',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,

      // فرض العربية كلغة وحيدة للتطبيق (لا حاجة لدعم لغات أخرى)
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: const [
        // مندوبات الماديريال الأساسية تكفي لدعم الاتجاه RTL والتقويم العربي
        // بدون الحاجة لحزمة flutter_localizations إضافية إن لم تُستخدم
        // نصوص نظام مترجمة (كل النصوص هنا عربية ثابتة مكتوبة يدويًا).
      ],

      builder: (context, child) {
        // ضمان اتجاه RTL في كل الشاشة بغض النظر عن اللغة الافتراضية للجهاز
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const HomeScreen(),
    );
  }
}
