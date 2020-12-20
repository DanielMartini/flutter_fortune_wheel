/// {@template flutter_fortune_wheel.FortuneWidget.items}
/// A list of [FortuneItem]s to be shown within this [FortuneWidget].
/// {@endtemplate}
///
/// {@template flutter_fortune_wheel.FortuneWidget.selected}
/// The currently selected index within [items].
/// Used by [FortuneWidget]s to align [indicators] on the selected item.
/// {@endtemplate}
///
/// {@template flutter_fortune_wheel.FortuneWidget.rotationCount}
/// The number of times a [FortuneWidget] rotates around all
/// [items] before it settles on the [selected] value.
/// {@endtemplate}
///
/// {@template flutter_fortune_wheel.FortuneWidget.duration}
/// The animation duration used for [FortuneAnimation.Roll]
/// within [FortuneWidget] instances.
/// {@endtemplate}
///
/// {@template flutter_fortune_wheel.FortuneWidget.animationType}
/// The type of animation to be used when [selected] changes.
///
/// See also:
///  * [FortuneAnimation]
/// {@endtemplate}
///
/// {@template flutter_fortune_wheel.FortuneWidget.onAnimationStart}
/// Called when this widget starts an animation.
/// Useful for disabling other widgets during the animation.
/// {@endtemplate}
///
/// {@template flutter_fortune_wheel.FortuneWidget.onAnimationEnd}
/// Called when this widget's animation ends.
/// Useful for enabling other widgets after the animation ends.
/// {@endtemplate}
///
/// {@template flutter_fortune_wheel.FortuneWidget.ctor_args}
/// The type of animation to be used when [selected] changes is determined
/// by [animationType]. If it is set to [FortuneAnimation.Roll],
/// [rotationCount] determines the number of rotations around all items before
/// settling on the selected value during the animation [duration].
/// The callbacks [onAnimationStart] and [onAnimationEnd] are called whenever
/// this widget starts and ends an animation respectively. This applies to all
/// values of [animationType].
///
/// The list of [indicators] is rendered on top of the underlying
/// [FortuneWidget]. These can be used to visualize the position of the
/// [selected] item.
/// {@endtemplate}
///

import 'package:flutter/widgets.dart';
import 'package:quiver/core.dart';

import 'animations.dart';
import 'indicators/indicators.dart';
import 'bar/bar.dart';
import 'wheel/wheel.dart';

/// A [FortuneItem] represents a value, which is chosen during a selection
/// process and displayed within a [FortuneWidget].
///
/// See also:
///  * [FortuneWidget]
@immutable
class FortuneItem {
  /// The color used for filling the background of this item.
  final Color color;

  /// The color used for painting the border of this item.
  final Color borderColor;

  /// The border width of this item.
  final double borderWidth;

  /// A widget to be rendered within this item.
  final Widget child;

  const FortuneItem({
    this.color,
    this.borderColor,
    this.borderWidth,
    @required this.child,
  }) : assert(child != null);

  @override
  int get hashCode => hash4(color, borderColor, borderWidth, child);

  @override
  bool operator ==(Object other) {
    return other is FortuneItem &&
        color == other.color &&
        borderColor == other.borderColor &&
        borderWidth == other.borderWidth &&
        child == other.child;
  }
}

/// A [FortuneWidget] visualizes (random) selection processes by iterating over
/// a list of items before settling on a selected item.
///
/// See also:
///  * [FortuneWheel]
///  * [FortuneBar]
///  * [FortuneItem]
abstract class FortuneWidget implements Widget {
  /// The default value for [duration] (currently **5 seconds**).
  static const Duration kDefaultDuration = const Duration(seconds: 5);

  /// The default value for [rotationCount] (currently **100**).
  static const int kDefaultRotationCount = 100;

  /// {@macro flutter_fortune_wheel.FortuneWidget.items}
  List<FortuneItem> get items;

  /// {@macro flutter_fortune_wheel.FortuneWidget.selected}
  int get selected;

  /// {@macro flutter_fortune_wheel.FortuneWidget.rotationCount}
  int get rotationCount;

  /// {@macro flutter_fortune_wheel.FortuneWidget.duration}
  Duration get duration;

  /// {@macro flutter_fortune_wheel.FortuneWidget.animationType}
  FortuneAnimation get animationType;

  /// {@macro flutter_fortune_wheel.FortuneWidget.onAnimationStart}
  VoidCallback get onAnimationStart;

  /// {@macro flutter_fortune_wheel.FortuneWidget.onAnimationEnd}
  VoidCallback get onAnimationEnd;

  /// Creates a new [FortuneWheel] with the given [items] and centered on the
  /// [selected] value.
  ///
  /// {@macro flutter_fortune_wheel.FortuneWidget.ctor_args}.
  ///
  /// See also:
  ///  * [FortuneWheel]
  const factory FortuneWidget.wheel({
    Key key,
    @required int selected,
    @required List<FortuneItem> items,
    int rotationCount,
    Duration duration,
    FortuneAnimation animationType,
    List<FortuneIndicator> indicators,
    VoidCallback onAnimationStart,
    VoidCallback onAnimationEnd,
  }) = FortuneWheel;

  /// Creates a new [FortuneBar] with the given [items] and centered on the
  /// [selected] value.
  ///
  /// {@macro flutter_fortune_wheel.FortuneWidget.ctor_args}.
  ///
  /// See also:
  ///  * [FortuneWidget()]
  ///  * [FortuneWidget.wheel]
  const factory FortuneWidget.bar({
    Key key,
    @required List<FortuneItem> items,
    @required int selected,
    int rotationCount,
    Duration duration,
    FortuneAnimation animationType,
    List<FortuneIndicator> indicators,
    VoidCallback onAnimationStart,
    VoidCallback onAnimationEnd,
    double height,
  }) = FortuneBar;

  /// Creates a new [FortuneWheel] if the number of [items] is even or a
  /// [FortuneBar] if it is odd.
  ///
  /// {@macro flutter_fortune_wheel.FortuneWidget.ctor_args}.
  ///
  /// See also:
  ///  * [FortuneWidget.bar()]
  ///  * [FortuneWidget.wheel()]
  factory FortuneWidget({
    Key key,
    @required List<FortuneItem> items,
    @required int selected,
    int rotationCount = kDefaultRotationCount,
    Duration duration = kDefaultDuration,
    FortuneAnimation animationType = FortuneAnimation.Roll,
    List<FortuneIndicator> indicators,
    VoidCallback onAnimationStart,
    VoidCallback onAnimationEnd,
  }) {
    if (items.length % 2 == 0) {
      return FortuneWidget.wheel(
        key: key,
        items: items,
        selected: selected,
        rotationCount: rotationCount,
        duration: duration,
        animationType: animationType,
        indicators: indicators ?? FortuneWheel.kDefaultIndicators,
        onAnimationStart: onAnimationStart,
        onAnimationEnd: onAnimationEnd,
      );
    } else {
      return FortuneWidget.bar(
        key: key,
        items: items,
        selected: selected,
        rotationCount: rotationCount,
        duration: duration,
        animationType: animationType,
        indicators: indicators ?? FortuneBar.kDefaultIndicators,
        onAnimationStart: onAnimationStart,
        onAnimationEnd: onAnimationEnd,
      );
    }
  }
}
