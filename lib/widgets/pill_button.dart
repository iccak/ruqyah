import 'package:flutter/material.dart';

/// زر كبسولي بلون خلفية ونص مخصصين، يُستخدم للأزرار الثانوية مثل
/// "تعديل" (أخضر فاتح) أو "حذف" (وردي فاتح) أو "إلغاء".
class PillButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color background;
  final Color foreground;
  final VoidCallback? onPressed;
  final double height;

  const PillButton({
    super.key,
    required this.label,
    required this.background,
    required this.foreground,
    this.icon,
    this.onPressed,
    this.height = 52,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Material(
        color: background,
        shape: const StadiumBorder(),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (icon != null) ...[
                  const SizedBox(width: 8),
                  Icon(icon, color: foreground, size: 20),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// زر دائري صغير (تشغيل/حذف) يُستخدم داخل بطاقات مكتبة السور.
class CircleIconButton extends StatelessWidget {
  final IconData icon;
  final Color background;
  final Color foreground;
  final VoidCallback? onPressed;
  final double size;

  const CircleIconButton({
    super.key,
    required this.icon,
    required this.background,
    required this.foreground,
    this.onPressed,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: background,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Icon(icon, color: foreground, size: size * 0.5),
        ),
      ),
    );
  }
}
