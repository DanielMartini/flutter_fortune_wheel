part of 'wheel.dart';

/// A fortune wheel visualizes a (random) selection process as a spinning wheel
/// divided into uniformly sized slices, which correspond to the number of
/// [items].
///
/// ![](https://raw.githubusercontent.com/kevlatus/flutter_fortune_wheel/main/images/img-wheel-256.png?sanitize=true)
///
/// See also:
///  * [FortuneBar], which provides an alternative visualization
///  * [FortuneWidget()], which automatically chooses a fitting widget
///  * [Fortune.randomItem], which helps selecting random items from a list
///  * [Fortune.randomDuration], which helps choosing a random duration
class FortuneWheel extends HookWidget implements FortuneWidget {
  /// The default value for [indicators] on a [FortuneWheel].
  /// Currently uses a single [TriangleIndicator] on [Alignment.topCenter].
  static const List<FortuneIndicator> kDefaultIndicators =
      const <FortuneIndicator>[
    const FortuneIndicator(
      alignment: Alignment.topCenter,
      child: const TriangleIndicator(),
    ),
  ];

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
  final FortuneAnimation animationType;

  /// {@macro flutter_fortune_wheel.FortuneWidget.onAnimationStart}
  final VoidCallback onAnimationStart;

  /// {@macro flutter_fortune_wheel.FortuneWidget.onAnimationEnd}
  final VoidCallback onAnimationEnd;

  double _getAngle(double progress) {
    return 2 * Math.pi * rotationCount * progress;
  }

  /// {@template flutter_fortune_wheel.FortuneWheel}
  /// Creates a new [FortuneWheel] with the given [items], which is centered
  /// on the [selected] value.
  ///
  /// {@macro flutter_fortune_wheel.FortuneWidget.ctorArgs}.
  ///
  /// See also:
  ///  * [FortuneBar], which provides an alternative visualization.
  /// {@endtemplate}
  const FortuneWheel({
    Key key,
    @required this.items,
    this.rotationCount = FortuneWidget.kDefaultRotationCount,
    this.selected = 0,
    this.duration = FortuneWidget.kDefaultDuration,
    this.animationType = FortuneAnimation.Spin,
    this.indicators = kDefaultIndicators,
    this.onAnimationStart,
    this.onAnimationEnd,
  })  : assert(items != null && items.length > 1),
        assert(selected >= 0 && selected < items.length),
        assert(animationType != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final animationCtrl = useAnimationController(duration: duration);
    final animation = CurvedAnimation(
      parent: animationCtrl,
      curve: Cubic(0, 1.0, 0, 1.0),
    );
    final AnimationFunc animFunc = getAnimationFunc(animationType);

    Future<void> animate() async {
      if (animationCtrl.isAnimating) {
        return;
      }

      if (onAnimationStart != null) {
        await Future.delayed(Duration.zero, onAnimationStart);
      }

      await animFunc(animationCtrl);

      if (onAnimationEnd != null) {
        await Future.delayed(Duration.zero, onAnimationEnd);
      }
    }

    useEffect(() {
      animate();
      return null;
    }, []);

    useValueChanged(selected, (_, __) {
      animate();
    });

    final wheel = AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return Transform.rotate(
          angle: -2 * Math.pi * (selected / items.length),
          child: Transform.rotate(
            angle: _getAngle(animation.value),
            child: SizedBox.expand(
              child: _SlicedCircle(
                items: items,
              ),
            ),
          ),
        );
      },
    );

    return Stack(
      children: [
        wheel,
        for (var it in indicators) _WheelIndicator(indicator: it),
      ],
    );
  }
}
