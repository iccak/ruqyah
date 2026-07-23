import 'package:flutter/material.dart';

import '../widgets/app_bottom_nav.dart';
import 'audio_library_screen.dart';
import 'home_screen.dart';
import 'settings_screen.dart';

/// الحاوية الرئيسية للتطبيق: تعرض شريط تنقل سفلي بثلاث تبويبات
/// (الرئيسية، السور، الإعدادات) وتحافظ على حالة كل شاشة عند التنقل
/// بينها باستخدام IndexedStack.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  final List<Widget> _tabs = const [
    HomeScreen(),
    AudioLibraryScreen(embedded: true),
    SettingsScreen(),
  ];

  // مرتبة لتطابق ظهورها بصريًا من اليسار لليمين على الشاشة
  // (الإعدادات، السور، الرئيسية)، كما في التصميم المرجعي.
  final List<NavItem> _navItems = const [
    NavItem(icon: Icons.settings_outlined, label: 'الإعدادات'),
    NavItem(icon: Icons.menu_book_outlined, label: 'السور'),
    NavItem(icon: Icons.home_outlined, label: 'الرئيسية'),
  ];

  @override
  Widget build(BuildContext context) {
    // _tabs مرتبة: 0=الرئيسية، 1=السور، 2=الإعدادات
    // _navItems مرتبة بصريًا بالعكس: 0=الإعدادات، 1=السور، 2=الرئيسية
    final reversedIndex = _tabs.length - 1 - _index;

    return Scaffold(
      body: SafeArea(
        top: false,
        child: IndexedStack(
          index: _index,
          children: _tabs,
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: reversedIndex,
        items: _navItems,
        onTap: (tappedReversedIndex) {
          setState(() => _index = _tabs.length - 1 - tappedReversedIndex);
        },
      ),
    );
  }
}
