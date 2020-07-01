import 'package:flutter/widgets.dart';

import 'circular_clip_transition.dart';

/// A [PageRoute] which transitions by expanding a circular clip from
/// the center of [expandFrom] until the page is fully revealed.
class CircularClipRoute<T> extends PageRoute<T> {
  CircularClipRoute({
    @required this.expandFrom,
    @required this.builder,
    this.curve = Curves.easeInOutCubic,
    this.reverseCurve = Curves.easeInOutCubic,
    this.opacity,
    this.border = CircularClipTransition.kDefaultBorder,
    this.shadow = CircularClipTransition.kDefaultShadow,
    this.maintainState = false,
    this.transitionDuration = const Duration(milliseconds: 500),
  })  : assert(expandFrom != null),
        assert(builder != null),
        assert(curve != null),
        assert(reverseCurve != null),
        assert(maintainState != null),
        assert(transitionDuration != null);

  /// The [BuildContext] of the widget, which is used to determine the center
  /// of the expanding clip circle and its initial dimensions.
  ///
  /// The [RenderObject] which eventually renders the widget, must be a
  /// [RenderBox].
  ///
  /// See also:
  ///
  /// * [CircularClipTransition.expandingRect], which is what [expandFrom] is
  /// used to calculate.
  final BuildContext expandFrom;

  /// Builds the primary contents of the route.
  final WidgetBuilder builder;

  /// The curve used when this route is pushed.
  final Curve curve;

  /// The curve used when this route is popped.
  final Curve reverseCurve;

  /// {@macro CircularClipTransition.opacity}
  final Animatable<double> opacity;

  /// {@macro CircularClipTransition.border}
  final BoxBorder border;

  /// {@macro CircularClipTransition.shadow}
  final List<BoxShadow> shadow;

  @override
  final bool maintainState;

  @override
  final Duration transitionDuration;

  // The expandFrom context is used when popping this route, to update the
  // _expandingRect. This is necessary to handle changes to the layout of
  // the routes below this one (e.g. window is resized), therefore they must be
  // kept around.
  @override
  bool get opaque => false;

  @override
  Color get barrierColor => null;

  @override
  String get barrierLabel => null;

  Rect _expandingRect;

  void _updateExpandingRect() {
    setState(() {
      assert(expandFrom.findRenderObject() is RenderBox);
      final expandFromRenderBox = expandFrom.findRenderObject() as RenderBox;
      final expandFromTransform = expandFromRenderBox.getTransformTo(null);
      final navigatorTransform =
          navigator.context.findRenderObject().getTransformTo(null);
      final transform = expandFromTransform
        ..multiply(Matrix4.tryInvert(navigatorTransform));
      _expandingRect = MatrixUtils.transformRect(
        transform,
        Offset.zero & expandFromRenderBox.size,
      );
    });
  }

  @override
  TickerFuture didPush() {
    _updateExpandingRect();
    return super.didPush();
  }

  @override
  bool didPop(T result) {
    _updateExpandingRect();
    return super.didPop(result);
  }

  @override
  Animation<double> createAnimation() {
    return CurvedAnimation(
      parent: super.createAnimation(),
      curve: curve,
      reverseCurve: reverseCurve,
    );
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) =>
      builder(context);

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return CircularClipTransition(
      animation: animation,
      expandingRect: _expandingRect,
      opacity: opacity,
      border: border,
      shadow: shadow,
      child: child,
    );
  }
}
