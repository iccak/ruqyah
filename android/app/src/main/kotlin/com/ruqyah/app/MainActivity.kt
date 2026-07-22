package com.ruqyah.app

import io.flutter.embedding.android.FlutterFragmentActivity

// نستخدم FlutterFragmentActivity (بدل FlutterActivity) لأن حزمة
// audio_service تتطلبها لعرض عناصر تحكم الوسائط على شاشة القفل
// وشريط الإشعارات بشكل صحيح.
class MainActivity : FlutterFragmentActivity()
