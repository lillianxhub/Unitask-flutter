import 'package:flutter/material.dart';

class AppFloatingActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget? child;
  final List<Color>? gradientColors;
  final double bottomPadding;

  const AppFloatingActionButton({
    super.key,
    required this.onPressed,
    this.child,
    this.gradientColors,
    this.bottomPadding = 0,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final colors = gradientColors ?? [cs.secondary, cs.tertiary];

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Container(
        width: 65,
        height: 65,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: colors.first.withValues(alpha: 0.5),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: onPressed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: child ?? const Icon(Icons.add, color: Colors.white, size: 30),
        ),
      ),
    );
  }
}
