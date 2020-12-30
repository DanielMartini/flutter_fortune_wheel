part of 'bar.dart';

/// A fortune bar visualizes a (random) selection process as a horizontal bar
/// divided into uniformly sized boxes, which correspond to the number of
/// [items]. When spinning, items are moved horizontally for [duration].
///
/// See also:
///  * [FortuneWheel], which provides an alternative visualization
///  * [FortuneWidget()], which automatically chooses a fitting widget
///  * [Fortune.randomItem], which helps selecting random items from a list
///  * [Fortune.randomDuration], which helps choosing a random duration
class FortuneBar extends HookWidget implements FortuneWidget {
  static const List<FortuneIndicator> kDefaultIndicators =
      const <FortuneIndicator>[
    FortuneIndicator(
      alignment: Alignment.topCenter,
      child: RectangleIndicator(),
    ),
  ];

  static const StyleStrategy kDefaultStyleStrategy =
      const UniformStyleStrategy(borderWidth: 4);

  /// Requires this widget to have exactly this height.
  final double height;

  /// {@macro flutter_fortune_wheel.FortuneWidget.items}
  final List<FortuneItem> items;

  /// {@macro flutter_fortune_wheel.FortuneWidget.selected}
  final int selected;

  /// {@macro flutter_fortune_wheel.FortuneWidget.rotationCount}
  final int rotationCount;

  /// {@macro flutter_fortune_wheel.FortuneWidget.duration}
  final Duration duration;

  /// {@macro flutter_fortune_wheel.FortuneWidget.indicators}
  final List<FortuneIndicator> indicators;

  /// {@macro flutter_fortune_wheel.FortuneWidget.animationType}
  final Curve curve;

  /// {@macro flutter_fortune_wheel.FortuneWidget.onAnimationStart}
  final VoidCallback onAnimationStart;

  /// {@macro flutter_fortune_wheel.FortuneWidget.onAnimationEnd}
  final VoidCallback onAnimationEnd;

  /// {@macro flutter_fortune_wheel.FortuneWidget.styleStrategy}
  final StyleStrategy styleStrategy;

  /// If this value is true, this widget expands to the screen width and ignores
  /// width constraints imposed by parent widgets.
  ///
  /// This is disabled by default.
  final bool fullWidth;

  /// {@macro flutter_fortune_wheel.FortuneWidget.animateFirst}
  final bool animateFirst;

  Offset _itemOffset({
    int itemIndex,
    double animationProgress,
    double offset = 0,
    double itemWidth,
  }) {
    itemIndex = (itemIndex - selected) % items.length;
    final rotationWidth = itemWidth * items.length;

    final norm = 1 / rotationCount;
    final rotation = (animationProgress / norm).floor();
    final rotationProgress = animationProgress / norm - rotation;
    final animationValue = rotationProgress * rotationWidth;

    double x = itemWidth * itemIndex - animationValue - offset;
    if (itemWidth * (itemIndex + 1) < animationValue) {
      x += rotationWidth;
    }
    return Offset(x, 0);
  }

  /// {@template flutter_fortune_wheel.FortuneBar}
  /// Creates a new [FortuneBar] with the given [items], which is centered
  /// on the [selected] value.
  ///
  /// {@macro flutter_fortune_wheel.FortuneWidget.ctorArgs}.
  ///
  /// See also:
  ///  * [FortuneWheel], which provides an alternative visualization.
  /// {@endtemplate}
  const FortuneBar({
    Key key,
    this.height = 56.0,
    this.duration = FortuneWidget.kDefaultDuration,
    this.onAnimationStart,
    this.onAnimationEnd,
    this.curve = FortuneCurve.spin,
    @required this.selected,
    this.rotationCount = FortuneWidget.kDefaultRotationCount,
    this.items,
    this.indicators = kDefaultIndicators,
    this.fullWidth = false,
    this.styleStrategy = kDefaultStyleStrategy,
    this.animateFirst = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final animationCtrl = useAnimationController(duration: duration);
    final animation = CurvedAnimation(parent: animationCtrl, curve: curve);

    // TODO: refactor: implement shared fortune animation hook
    Future<void> animate() async {
      if (animationCtrl.isAnimating) {
        return;
      }

      if (onAnimationStart != null) {
        await Future.microtask(onAnimationStart);
      }

      await animationCtrl.forward(from: 0);

      if (onAnimationEnd != null) {
        await Future.microtask(onAnimationEnd);
      }
    }

    useEffect(() {
      if (animateFirst) animate();
      return null;
    }, []);

    useValueChanged(selected, (_, __) async {
      await animate();
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        final theme = Theme.of(context);
        final visibleItemCount = Math.min(3, items.length);
        final screenSize = MediaQuery.of(context).size;
        final width = fullWidth ? screenSize.width : constraints.maxWidth;
        final offsetX = fullWidth && visibleItemCount > 1
            ? (screenSize.width - constraints.maxWidth) / 2
            : 0.0;
        final itemWidth = width / visibleItemCount;

        return ClipRect(
          clipper: _RectClipper(Rect.fromLTWH(-offsetX, 0, width, height)),
          child: SizedBox(
            width: width,
            height: height,
            child: AnimatedBuilder(
              animation: animation,
              builder: (context, _) {
                return Stack(
                  children: [
                    for (var i = 0; i < items.length; i++)
                      Transform.translate(
                        offset: _itemOffset(
                          animationProgress: animation.value,
                          // put selected item in center
                          itemIndex: (i + 1) % items.length,
                          offset: offsetX,
                          itemWidth: itemWidth,
                        ),
                        child: _FortuneBarItem(
                          child: items[i].child,
                          style: items[i].style ??
                              styleStrategy.getItemStyle(
                                  theme, i, items.length),
                          width: itemWidth,
                          height: height,
                        ),
                      ),
                    for (var it in indicators)
                      Align(
                        alignment: it.alignment,
                        child: SizedBox(
                          width: itemWidth,
                          height: height,
                          child: it.child,
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _RectClipper extends CustomClipper<Rect> {
  final Rect rect;

  _RectClipper(this.rect);

  @override
  Rect getClip(Size size) => rect;

  @override
  bool shouldReclip(covariant _RectClipper oldClipper) =>
      rect != oldClipper.rect;
}
