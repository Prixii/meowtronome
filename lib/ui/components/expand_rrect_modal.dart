import 'package:flutter/material.dart';
import 'package:meowtronome/ui/components/animated_expand_rrect.dart';

Future<T?> showExpandRRectModal<T>({
  required BuildContext context,
  required GlobalKey anchorKey,
  required WidgetBuilder builder,
  BorderRadius endBorderRadius = const BorderRadius.all(Radius.circular(16)),
  Duration duration = const Duration(milliseconds: 500),
  double widthFraction = 0.85,
  double heightFraction = 0.5,
}) {
  final anchorContext = anchorKey.currentContext;
  if (anchorContext == null) {
    return Future.value(null);
  }

  final box = anchorContext.findRenderObject()! as RenderBox;
  final anchorRect = box.localToGlobal(Offset.zero) & box.size;
  final beginRect = Rect.fromCenter(
    center: anchorRect.center,
    width: 0,
    height: 0,
  );

  final screenSize = MediaQuery.sizeOf(context);
  final endSize = Size(
    screenSize.width * widthFraction,
    screenSize.height * heightFraction,
  );
  final endRect = Rect.fromCenter(
    center: Offset(screenSize.width / 2, screenSize.height / 2),
    width: endSize.width,
    height: endSize.height,
  );

  return Navigator.of(context).push<T>(
    PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.transparent,
      pageBuilder: (context, animation, secondaryAnimation) {
        return _ExpandRRectModalPage(
          beginRect: beginRect,
          endRect: endRect,
          endBorderRadius: endBorderRadius,
          duration: duration,
          builder: builder,
        );
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return child;
      },
    ),
  );
}

class _ExpandRRectModalPage extends StatefulWidget {
  const _ExpandRRectModalPage({
    required this.beginRect,
    required this.endRect,
    required this.endBorderRadius,
    required this.duration,
    required this.builder,
  });

  final Rect beginRect;
  final Rect endRect;
  final BorderRadius endBorderRadius;
  final Duration duration;
  final WidgetBuilder builder;

  @override
  State<_ExpandRRectModalPage> createState() => _ExpandRRectModalPageState();
}

class _ExpandRRectModalPageState extends State<_ExpandRRectModalPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    await _controller.reverse();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        fit: StackFit.expand,
        children: [
          FadeTransition(
            opacity: _controller,
            child: GestureDetector(
              onTap: _dismiss,
              behavior: HitTestBehavior.opaque,
              child: const ColoredBox(color: Colors.black54),
            ),
          ),
          AnimatedExpandRRect(
            controller: _controller,
            beginRect: widget.beginRect,
            endRect: widget.endRect,
            endBorderRadius: widget.endBorderRadius,
            duration: widget.duration,
            scaleChild: true,
            child: Material(
              color: Colors.white,
              borderRadius: widget.endBorderRadius,
              clipBehavior: Clip.antiAlias,
              child: widget.builder(context),
            ),
          ),
        ],
      ),
    );
  }
}
