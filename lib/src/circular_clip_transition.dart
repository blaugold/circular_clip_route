import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'circular_clip_route.dart';

/// A widget which reveals its [child] by expanding a circular clip from
/// the center of [expandingRect] until the child is fully revealed.
///
/// [expandingRect] is a rectangle in the coordinate space of this widget, which
/// contains the clip circle when [animation.value] is `0`.
///
/// When [animation.value] is `1`, the clip circle contains both
/// [expandingRect] and the rectangle which is the bounding box of [child].
///
/// See also:
///
/// * [CircularClipRoute], which uses this widget.
class CircularClipTransition extends StatefulWidget {
  /// The default value for [opacity].
  static final kDefaultOpacityAnimatable = TweenSequence([
    TweenSequenceItem(
      tween: Tween(
        begin: .0,
        end: 1.0,
      ),
      weight: 10,
    ),
    TweenSequenceItem(
      weight: 90,
      tween: ConstantTween(1.0),
    ),
  ]);

  /// The default value for [border].
  static const kDefaultBorder = Border.fromBorderSide(BorderSide(
    color: Color(0xFFFFFFFF),
    width: 2,
  ));

  /// The default value for [shadow].
  static const kDefaultShadow = [
    BoxShadow(
      color: Color(0x61000000),
      blurRadius: 100,
    )
  ];

  /// Creates  widget which reveals its [child] by expanding a circular clip
  /// from the center of [expandingRect] until the child is fully revealed.
  CircularClipTransition({
    Key key,
    @required this.animation,
    @required this.expandingRect,
    @required this.child,
    Animatable<double> opacity,
    this.border = kDefaultBorder,
    this.shadow = kDefaultShadow,
  })  : assert(animation != null),
        assert(expandingRect != null),
        assert(child != null),
        this.opacity = opacity ?? kDefaultOpacityAnimatable,
        super(key: key);

  /// The animation which controls the progress (0 to 1) of the transition.
  final Animation<double> animation;

  /// The rectangle which describes the center and dimension of the clip
  /// circle at [animation.value] `0`.
  ///
  /// The expanding clip circle will always be centered at this rectangle's
  /// center.
  final Rect expandingRect;

  /// {@template CircularClipTransition.opacity}
  /// The [Animatable] which is used to fade the transition in and out.
  ///
  /// When this option is not provided or is `null` it defaults to
  /// [kDefaultOpacityAnimatable]. To use a fixed opacity pass something line
  /// `ConstantTween(1.0)`.
  /// {@endtemplate}
  final Animatable<double> opacity;

  /// {@template CircularClipTransition.border}
  /// The border which is drawn around the clip circle. The default is
  /// [kDefaultBorder]. To disable the border, set [border] to `null`.
  /// {@endtemplate}
  final BoxBorder border;

  /// {@template CircularClipTransition.shadow}
  /// The shadow which is drawn beneath the clip circle. The default is
  /// [kDefaultShadow]. To disable the shadow, set [shadow] to `null`.
  /// {@endtemplate}
  final List<BoxShadow> shadow;

  /// The widget which is clipped by the clip circle.
  final Widget child;

  @override
  _CircularClipTransitionState createState() => _CircularClipTransitionState();
}

class _CircularClipTransitionState extends State<CircularClipTransition> {
  /// The widget returned from [build] is cached to prevent unnecessary
  /// rebuilds of the tree managed by the transition. The child is only
  /// rebuild when the configuration in [widget] actually changes (see
  /// [didUpdateWidget]).
  Widget _child;

  @override
  void didUpdateWidget(CircularClipTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animation != oldWidget.animation ||
        widget.expandingRect != oldWidget.expandingRect ||
        widget.opacity != oldWidget.opacity ||
        widget.border != oldWidget.border ||
        widget.shadow != oldWidget.shadow ||
        widget.child != oldWidget.child) {
      _child = null;
    }
  }

  @override
  Widget build(BuildContext context) => _child ??= _buildChild();

  Widget _buildChild() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final clipRectAnimation = RectTween(
          begin: widget.expandingRect,
          end: _getExpandedClipRect(Rect.fromPoints(
            Offset.zero,
            Offset(constraints.maxWidth, constraints.maxHeight),
          )),
        ).animate(widget.animation);

        final stackChildren = <Widget>[];

        if (widget.shadow != null) {
          stackChildren.add(_buildDecoration(
            clipRectAnimation,
            BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: widget.shadow,
            ),
          ));
        }

        stackChildren.add(_buildChildClipper(clipRectAnimation));

        if (widget.border != null) {
          stackChildren.add(_buildDecoration(
            clipRectAnimation,
            BoxDecoration(
              shape: BoxShape.circle,
              border: widget.border,
            ),
            ignorePointer: true,
          ));
        }

        Widget child = Stack(children: stackChildren);

        if (widget.opacity != null) {
          child = FadeTransition(
            opacity: widget.opacity.animate(widget.animation),
            child: child,
          );
        }

        return child;
      },
    );
  }

  Rect _getExpandedClipRect(Rect contentRect) {
    final circleRadius = [
      contentRect.topLeft,
      contentRect.topRight,
      contentRect.bottomLeft,
      contentRect.bottomRight,
    ]
        .map((corner) => (corner - widget.expandingRect.center).distance)
        .reduce(math.max);

    var rectSize = Size.square(circleRadius * 2);

    if (widget.border != null) {
      rectSize = widget.border.dimensions.inflateSize(rectSize);
    }

    return Rect.fromCenter(
      center: widget.expandingRect.center,
      height: rectSize.height,
      width: rectSize.width,
    );
  }

  ClipOval _buildChildClipper(Animation<Rect> clipRectAnimation) {
    return ClipOval(
      clipper: _RectAnimationClipper(animation: clipRectAnimation),
      child: widget.child,
    );
  }

  Widget _buildDecoration(
    Animation<Rect> clipRectAnimation,
    Decoration decoration, {
    bool ignorePointer = false,
  }) {
    Widget child = DecoratedBox(decoration: decoration);
    child = ignorePointer ? IgnorePointer(child: child) : child;
    return _AbsolutePositionedTransition(
      rect: clipRectAnimation,
      child: child,
    );
  }
}

/// Animates the position of a [child] in a [Stack] with  absolutely
/// positioned through a [rect].
class _AbsolutePositionedTransition extends AnimatedWidget {
  const _AbsolutePositionedTransition({
    Key key,
    @required Animation<Rect> rect,
    @required this.child,
  })  : assert(rect != null),
        super(key: key, listenable: rect);

  Animation<Rect> get rect => listenable as Animation<Rect>;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Positioned.fromRect(
      rect: rect.value,
      child: child,
    );
  }
}

/// A simple [CustomClipper] which adapts an [Animation<Rect>] to animate the
/// clip rect.
class _RectAnimationClipper extends CustomClipper<Rect> {
  _RectAnimationClipper({
    @required this.animation,
  })  : assert(animation != null),
        super(reclip: animation);

  final Animation<Rect> animation;

  @override
  Rect getClip(Size size) => animation.value;

  @override
  bool shouldReclip(_RectAnimationClipper oldClipper) =>
      animation != oldClipper.animation;
}
