import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/main_shell.dart';
import 'services/storage_service.dart';
import 'theme.dart';

Future<void> main() async {
  // نلتقط أي خطأ يحدث أثناء الإقلاع أو أثناء بناء الواجهة ونعرضه
  // على الشاشة بدل ترك شاشة بيضاء فارغة بلا أي تفسير.
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
    };

    try {
      // تهيئة التخزين المحلي (Hive) فقط عند الإقلاع.
      // ملاحظة: لا نُهيّئ خدمة الصوت في الخلفية هنا؛ يتم تأجيل ذلك
      // إلى حين فتح شاشة التشغيل فعليًا لتفادي بدء خدمة أندرويد
      // الأمامية (Foreground Service) قبل أن يطلب المستخدم التشغيل،
      // وهو سبب شائع لتعطل التطبيقات عند الإقلاع.
      await StorageService.instance.init();
      runApp(const RuqyahApp());
    } catch (error, stackTrace) {
      runApp(_StartupErrorApp(error: error, stackTrace: stackTrace));
    }
  }, (error, stackTrace) {
    // أي خطأ غير متوقع خارج شجرة الواجهة يُعرض أيضًا بدل شاشة بيضاء صامتة
    runApp(_StartupErrorApp(error: error, stackTrace: stackTrace));
  });
}

/// شاشة بديلة تُعرض فقط إذا فشل إقلاع التطبيق، لعرض تفاصيل الخطأ
/// الحقيقي بدل شاشة بيضاء فارغة يتعذر تشخيصها.
class _StartupErrorApp extends StatelessWidget {
  final Object error;
  final StackTrace stackTrace;
  const _StartupErrorApp({required this.error, required this.stackTrace});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.red.shade700,
            title: const Text('حدث خطأ عند تشغيل التطبيق'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'يرجى إرسال نص هذا الخطأ للمطوّر:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                SelectableText(
                  error.toString(),
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 20),
                SelectableText(
                  stackTrace.toString(),
                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// التطبيق الرئيسي: يفرض اتجاه RTL ولغة عربية بالكامل، ويستخدم
/// ثيمًا عالي التباين وخطوطًا كبيرة مناسبة لكبار السن.
class RuqyahApp extends StatelessWidget {
  const RuqyahApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'رقيتي',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,

      // فرض العربية كلغة وحيدة للتطبيق (لا حاجة لدعم لغات أخرى)
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: const [
        // مطلوبة كي تعمل عناصر الواجهة القياسية (كمربعات الحوار
        // showDialog) بشكل صحيح مع اللغة العربية بدل التعطل بخطأ
        // "Null check operator used on a null value".
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      builder: (context, child) {
        // ضمان اتجاه RTL في كل الشاشة بغض النظر عن اللغة الافتراضية للجهاز
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const MainShell(),
    );
  }
}
