import 'package:flutter/material.dart';

final boxStyle = ElevatedButton.styleFrom(backgroundColor: Colors.transparent,
    foregroundColor: Colors.black, elevation: 0);

class SlidingWindow extends StatefulWidget {
  final Widget toast;

  const SlidingWindow({Key? key, required this.toast}) : super(key: key);

  @override
  State<SlidingWindow> createState() => _SlidingWindowState();
}

class _SlidingWindowState extends State<SlidingWindow> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<Offset>(begin: const Offset(0, 1.0), end: const Offset(0, 0.5)),
      duration: const Duration(milliseconds: 500),
      curve: Curves.ease,
      builder: (context, offset, child) {
        return FractionalTranslation(
          translation: offset,
          child: SizedBox(
            width: double.infinity,
            child: Center(
              child: child,
            ),
          ),
        );
      },
      child: widget.toast,
    );
  }
}