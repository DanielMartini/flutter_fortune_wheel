part of 'wheel.dart';

class _SlicedCircle extends StatelessWidget {
  final List<FortuneItem> items;
  final StyleStrategy? styleStrategy;

  const _SlicedCircle({
    Key? key,
    required this.items,
    this.styleStrategy,
  })  : assert(items.length > 1),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final anglePerChild = 2 * _math.pi / items.length;

    return LayoutBuilder(builder: (context, constraints) {
      final smallerSide = getSmallerSide(constraints);
      var offsetX = constraints.maxWidth / 2;
      if (Directionality.of(context) == TextDirection.rtl) {
        offsetX = offsetX * -1 + smallerSide / 2;
      }

      return Transform.translate(
        offset: Offset(offsetX, constraints.maxHeight / 2),
        child: Stack(
          children: items.asMap().keys.map((index) {
            final theme = Theme.of(context);
            final style = items[index].style ??
                styleStrategy!.getItemStyle(theme, index, items.length);

            final childAngle = anglePerChild * index;
            // first slice starts at 90 degrees, if 0 degrees is at the top.
            // The angle offset puts the center of the first slice at the top.
            final angleOffset = -(_math.pi / 2 + anglePerChild / 2);

            return Transform.rotate(
              alignment: Alignment.topLeft,
              angle: childAngle + angleOffset,
              child: _CircleSliceLayout(
                child: DefaultTextStyle(
                  textAlign: style.textAlign,
                  style: style.textStyle,
                  child: items[index].child,
                ),
                slice: _CircleSlice(
                  radius: smallerSide / 2,
                  angle: 2 * _math.pi / items.length,
                  fillColor: style.color,
                  strokeColor: style.borderColor,
                  strokeWidth: style.borderWidth,
                ),
              ),
            );
          }).toList(),
        ),
      );
    });
  }
}
