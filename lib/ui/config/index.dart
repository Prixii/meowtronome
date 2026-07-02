import 'package:flutter/material.dart';
import 'package:meowtronome/global.dart';

class ConfigPage extends StatefulWidget {
  const ConfigPage({
    super.key,
    required this.show,
    required this.isWide,
    required this.onClose,
  });

  final bool show;
  final bool isWide;
  final void Function() onClose;

  static const targetScale = 0.9;

  @override
  State<ConfigPage> createState() => ConfigPageState();
}

class ConfigPageState extends State<ConfigPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _positionAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _positionAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0, end: ConfigPage.targetScale),
        weight: 1,
      ),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(covariant ConfigPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.show && widget.show) {
      _controller.forward(from: 0);
    } else if (oldWidget.show && !widget.show) {
      _controller.reverse(from: ConfigPage.targetScale);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    final preferredWidth = mediaQuery.size.width * (widget.isWide ? 0.5 : 0.9);

    return AnimatedBuilder(
      child: null,
      animation: _controller,
      builder: (context, child) {
        final height = _positionAnimation.value * mediaQuery.size.height;

        return Visibility(
          visible: (_positionAnimation.value > 0),
          child: Stack(
            children: [
              GestureDetector(
                onTap: widget.onClose,
                child: Container(
                  color: Colors.black54.withAlpha(
                    (_positionAnimation.value * 255).toInt(),
                  ),
                  width: mediaQuery.size.width,
                  height: mediaQuery.size.height,
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: preferredWidth,
                  height: height,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: ConfigBody(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ConfigBody extends StatelessWidget {
  const ConfigBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Text('ConfigPage', style: titleTextStyle),
    );
  }
}
