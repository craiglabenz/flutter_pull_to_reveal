import 'dart:math';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

/// Combination of [BouncingScrollPhysics] and [AlwaysScrollableScrollPhysics]
/// which creates the iOS-style bouncing scroll even on when the page is not
/// completely full on Android devices.
class AlwaysBouncableScrollPhysics extends BouncingScrollPhysics {
  const AlwaysBouncableScrollPhysics({ScrollPhysics parent})
      : super(parent: parent);

  @override
  AlwaysBouncableScrollPhysics applyTo(ScrollPhysics ancestor) {
    return AlwaysBouncableScrollPhysics(parent: buildParent(ancestor));
  }

  /// This part must be added to `BouncingScrollPhysics` to make the effect work
  /// on Android devices when the page is not completely full.
  @override
  bool shouldAcceptUserOffset(ScrollMetrics position) => true;
}

/// Dictates behavior of incompletely rendered "revealable" widgets after
/// a user stops scrolling.
enum RevealableCompleter {
  /// Indicates an incompletely rendered widget should be
  /// animated to its final state.
  animate,

  /// Indicates an incompletely rendered widget should snap
  /// to its final state.
  snap,
}

/// Captures whether a specific [ScrollUpdateNotification] is the result of
/// user action or the system resetting overscrolling from user action.
enum ScrollSource {
  userAction,
  automatedRebound,
}

/// Hook to force a Revealable open or closed.
///
/// Accepts an optional boolean parameter which overrides the default value passed
/// for [RevealableCompleter]. When not passed, default behavior is used.
typedef RevealableToggler = void Function({RevealableCompleter completer});

/// Builder function for a "revealable" widget based on user scrolling.
typedef RevealableBuilder = Widget Function(
    BuildContext, RevealableToggler, RevealableToggler, BoxConstraints);

Widget emptyTopBuilder(BuildContext context, RevealableToggler opener,
    RevealableToggler closer, BoxConstraints constraints) {
  return Container();
}

class PullToRevealTopItemList extends StatefulWidget {
  /// Optional decoration for a Container that wraps the entire revealed widget.
  ///
  /// This Container is not scaled with the animation, making this
  /// [BoxDecoration] suitable for background styling.
  final BoxDecoration backgroundRevealableDecoration;

  /// Pass-thru to the eventual ListView for size-of-content optimizations.
  final int itemCount;

  /// The revealable's render state if the list is empty.
  ///
  /// Note: This is incompatible with the `builder()` constructor, because
  /// that pattern is not tied to the concept of an itemCount.
  final bool revealWhenEmpty;

  /// The revealable's initial render state.
  final bool startRevealed;

  /// The size of our Revealable when it is fully expanded.
  final double revealableHeight;

  /// The percentage we expect to have to reveal the internal widget
  /// for the animation to continue opening instead of closing.
  final double opacityThresholdToReveal;

  /// Milliseconds to complete a full closed-to-open (or inverse) animation.
  final int animationRuntime;

  /// Pass-thru to the eventual ListView.builder function.
  final IndexedWidgetBuilder itemBuilder;

  /// Pass-thru for a single builder that constructs the entire list. Use this
  /// for access to specific ListView build parameters.
  final Widget Function(BuildContext, ScrollController) builder;

  /// The function that builds your revealable top element.
  final RevealableBuilder revealableBuilder;

  /// Method for taking a partially rendered revealable to 0 or 100% opacity.
  final RevealableCompleter revealableCompleter;

  /// Optional builder that places content between the Revealable and the List.
  final WidgetBuilder dividerBuilder;

  /// Optional indicator for whether the list should dismiss a visible keyboard.
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;

  /// Optional override to freeze revealable on scroll up if the keyboard is
  /// visible.
  ///
  /// If the revealable contains a text input with focus, scrolling up will
  /// eventually remove that widget, causing Flutter to dismiss the keyboard.
  /// Set this value to `true` to disable the above effect.
  final bool freezeOnScrollUpIfKeyboardIsVisible;

  PullToRevealTopItemList._({
    @required this.revealableBuilder,
    @required this.revealableHeight,
    @required this.itemBuilder,
    @required this.builder,
    @required this.backgroundRevealableDecoration,
    this.animationRuntime = 300,
    this.dividerBuilder,
    this.itemCount,
    this.keyboardDismissBehavior,
    this.opacityThresholdToReveal = 0.5,
    this.revealableCompleter = RevealableCompleter.animate,
    this.revealWhenEmpty = true,
    this.startRevealed = false,
    this.freezeOnScrollUpIfKeyboardIsVisible = false,
    Key key,
  })  : assert(itemCount != null),
        super(key: key);

  /// Builder constructor to expose complete control over the inner [ListView].
  ///
  /// The builder function accepts two parameters: 1) the current [BuildContext],
  /// and 2) the [ScrollController] that drives the revealable builder. If you
  /// use this constructor, you must apply the [ScrollController] to your
  /// [ListView], like so:
  ///
  /// ```dart
  /// builder: (context, scrollController) => ListView.builder(
  ///   controller: scrollController,
  ///   itemCount: yourItemCount,
  ///   itemBuilder: yourItemBuilder,
  ///
  ///   // It is recommended to apply this for intended behavior in both iOS
  ///   // and Android
  ///   physics: AlwaysBouncableScrollPhysics(),
  /// )
  /// ```
  factory PullToRevealTopItemList.builder({
    @required RevealableBuilder revealableBuilder,
    @required double revealableHeight,
    @required Widget Function(BuildContext, ScrollController) builder,
    BoxDecoration backgroundRevealableDecoration,
    int animationRuntime = 300,
    WidgetBuilder dividerBuilder,
    bool freezeOnScrollUpIfKeyboardIsVisible = false,
    ScrollViewKeyboardDismissBehavior keyboardDismissBehavior,
    double opacityThresholdToReveal = 0.5,
    RevealableCompleter revealableCompleter = RevealableCompleter.animate,
    bool revealWhenEmpty = true,
    bool startRevealed = false,
    Key key,
  }) =>
      PullToRevealTopItemList._(
        revealableBuilder: revealableBuilder,
        revealableHeight: revealableHeight,
        itemBuilder: null,
        builder: builder,
        animationRuntime: animationRuntime,
        backgroundRevealableDecoration: backgroundRevealableDecoration,
        dividerBuilder: dividerBuilder,
        freezeOnScrollUpIfKeyboardIsVisible:
            freezeOnScrollUpIfKeyboardIsVisible,
        itemCount: null,
        keyboardDismissBehavior: keyboardDismissBehavior,
        opacityThresholdToReveal: opacityThresholdToReveal,
        revealableCompleter: revealableCompleter,
        revealWhenEmpty: revealWhenEmpty,
        startRevealed: startRevealed,
      );

  factory PullToRevealTopItemList({
    @required RevealableBuilder revealableBuilder,
    @required double revealableHeight,
    @required IndexedWidgetBuilder itemBuilder,
    int animationRuntime = 300,
    BoxDecoration backgroundRevealableDecoration,
    WidgetBuilder dividerBuilder,
    bool freezeOnScrollUpIfKeyboardIsVisible = false,
    int itemCount,
    ScrollViewKeyboardDismissBehavior keyboardDismissBehavior,
    double opacityThresholdToReveal = 0.5,
    RevealableCompleter revealableCompleter = RevealableCompleter.animate,
    bool revealWhenEmpty = true,
    bool startRevealed = false,
    Key key,
  }) =>
      PullToRevealTopItemList._(
        revealableBuilder: revealableBuilder,
        revealableHeight: revealableHeight,
        itemBuilder: itemBuilder,
        builder: null,
        animationRuntime: animationRuntime,
        backgroundRevealableDecoration: backgroundRevealableDecoration,
        dividerBuilder: dividerBuilder,
        freezeOnScrollUpIfKeyboardIsVisible:
            freezeOnScrollUpIfKeyboardIsVisible,
        itemCount: itemCount,
        keyboardDismissBehavior: keyboardDismissBehavior,
        opacityThresholdToReveal: opacityThresholdToReveal,
        revealableCompleter: revealableCompleter,
        revealWhenEmpty: revealWhenEmpty,
        startRevealed: startRevealed,
      );

  State createState() => _PullToRevealTopItemListState();
}

/// Current state of the revealable.
enum RevealableState { closed, closing, userScrolling, opening, open }

/// ListItem wrapper whose first item is hidden, but revealed when the user
/// scrolls.
class _PullToRevealTopItemListState extends State<PullToRevealTopItemList>
    with TickerProviderStateMixin {
  RevealableState _revealableState;
  ScrollDirection _scrollDirection = ScrollDirection.idle;
  bool _isKeyboardVisible = false;

  AnimationController _closeController;
  Animation<double> _closeAnimation;
  AnimationController _openController;
  Animation<double> _openAnimation;
  RevealableCompleter _revealableCompleter;

  ScrollController _scrollController;
  double _lastEndScrollPosition;

  double _revealableOpacity;
  double _revealableHeight;
  double _opacityThresholdToReveal;
  int _animationRuntime;

  DragUpdateDetails _lastDragDetails;

  @override
  void initState() {
    _scrollController = ScrollController();
    _revealableHeight = widget.revealableHeight;
    _opacityThresholdToReveal = widget.opacityThresholdToReveal;
    _revealableOpacity = widget.startRevealed ? 1 : 0;
    _revealableState =
        widget.startRevealed ? RevealableState.open : RevealableState.closed;
    _animationRuntime = widget.animationRuntime;
    _revealableCompleter = widget.revealableCompleter;
    _lastEndScrollPosition = 0;
    KeyboardVisibilityController()
      ..onChange.listen((isVisible) {
        _isKeyboardVisible = isVisible;
      });
    super.initState();
  }

  /// Helper for whether the animation to minimize the revealable on scroll-up
  /// should be frozen to preserve keyboard visibility.
  bool get isFrozen =>
      _isKeyboardVisible && widget.freezeOnScrollUpIfKeyboardIsVisible;
  bool get isClosed => _revealableState == RevealableState.closed;
  bool get isClosing => _revealableState == RevealableState.closing;
  bool get isUserScrolling => _revealableState == RevealableState.userScrolling;
  bool get isOpening => _revealableState == RevealableState.opening;
  bool get isOpen => _revealableState == RevealableState.open;

  void setToClosed() => _revealableState = RevealableState.closed;

  void setToClosing() => _revealableState = RevealableState.closing;

  void setToUserScrolling() => _revealableState = RevealableState.userScrolling;

  void setToOpening() => _revealableState = RevealableState.opening;

  void setToOpen() => _revealableState = RevealableState.open;

  @override
  void dispose() {
    _scrollController.dispose();
    _closeController?.dispose();
    _openController?.dispose();
    super.dispose();
  }

  /// Handles updates while a user is actively scrolling content down.
  void _continuePullingContentDown(double pix) {
    if (isOpen) {
      // Important guard to prevent re-revealing a fully displayed revealable
      // when the user starts pulling content down
      return;
    }
    setState(() {
      if (pix >= _revealableHeight) {
        // Scrolled enough to completely add revealable
        _revealableOpacity = 1;
        setToOpen();
      } else {
        // Still scrolling enough to completely add revealable
        setToUserScrolling();
        double _tmpRevealableOpacity =
            (pix / _revealableHeight).clamp(0.0, 1.0);
        _revealableOpacity = max(_tmpRevealableOpacity, _revealableOpacity);
      }
    });
  }

  /// Handles updates while a user is actively pushing content up.
  void _continuePushingContentUp(double scrolledPixels) {
    if (isClosed || isFrozen) {
      // Important guard to prevent revealing a hidden revealable
      // when the user starts pulling content down
      return;
    }
    setState(() {
      if (scrolledPixels >= _revealableHeight) {
        // Scrolled enough to completely remove revealable
        _revealableOpacity = 0;
        setToClosed();
      } else {
        // Still removing the revealable
        setToUserScrolling();
        _revealableOpacity =
            ((_revealableHeight - scrolledPixels) / _revealableHeight)
                .clamp(0.0, 1.0);
      }
    });
  }

  /// Escorts a partially rendered "revealable" to it's appropriate final state.
  ///
  /// This method can be dangerous to call without first checking against last
  /// scroll directions and any ongoing transitions. All checks should happen before
  /// calling this method, since it remains oblivious to such considerations.
  void _concludeReveal() {
    if (_revealableOpacity >= _opacityThresholdToReveal) {
      if (isOpening || isClosing) {
        return;
      }
      _opener();
    } else {
      if (isClosing || isClosed) {
        return;
      }
      _closer();
    }
  }

  /// Handles final considerations after a user stops scrolling content down.
  void _endedPullDown() {
    if (isOpen || isOpening) {
      return;
    }
    _concludeReveal();
  }

  /// Handles final considerations after a user stops scrolling content up.
  void _endedPushUp() {
    if (isClosed || isClosing || isFrozen) {
      return;
    }
    _concludeReveal();
  }

  /// Responsible for setting state every scroll update.
  ///
  /// Handles all user-based scroll events, including ongoing scrolling and
  /// abandoned scrolling that may need a partially rendered revealable to be
  /// ushered to one of the two complete stays (fully hidden or fully revealed).
  void _onUpdateScroll(ScrollUpdateNotification notification) {
    double scrolledPixels =
        notification.metrics.pixels - _lastEndScrollPosition;
    _scrollDirection =
        scrolledPixels > 0 ? ScrollDirection.forward : ScrollDirection.reverse;
    ScrollSource scrollSource = notification.dragDetails != null
        ? ScrollSource.userAction
        : ScrollSource.automatedRebound;
    if (scrollSource == ScrollSource.userAction &&
        _scrollDirection == ScrollDirection.forward &&
        (isOpen || isOpening)) {
      setToUserScrolling();
    }
    if (scrollSource == ScrollSource.userAction &&
        _scrollDirection == ScrollDirection.reverse &&
        (isClosed || isClosing)) {
      setToUserScrolling();
    }
    if (!isUserScrolling) {
      return;
    }
    bool _isDragRelease =
        _lastDragDetails != null && notification.dragDetails == null;
    _lastDragDetails = notification.dragDetails;
    // Pushing content up (ScrollDirection.forward)
    if (scrolledPixels > 0) {
      _isDragRelease
          ? _endedPushUp()
          : _continuePushingContentUp(scrolledPixels);

      // Pulling content down (ScrollDirection.reverse)
    } else if (scrolledPixels < 0) {
      _isDragRelease
          ? _endedPullDown()
          : _continuePullingContentDown(scrolledPixels.abs());
    }
  }

  /// Handles the conclusion of a scroll, which may be user-created or an
  /// automated reset.
  ///
  /// When a user's scroll overflows in either direction, the system will reset
  /// back to the appropriate boundary. As that animation completes, this function is
  /// resolved. This function is also called when a user-activated scroll ends
  /// without overflowing and thus without causing an automated reset.
  void _onEndScroll(ScrollEndNotification notification) async {
    _lastEndScrollPosition = notification.metrics.pixels;
    // Set value to zero if below zero
    _lastEndScrollPosition =
        _lastEndScrollPosition > 0 ? _lastEndScrollPosition : 0;

    // Pushing content up and not already closing
    if (_scrollDirection == ScrollDirection.forward &&
        !isClosed &&
        !isClosing &&
        !isFrozen) {
      _closer();
    } else if (_scrollDirection == ScrollDirection.reverse &&
        !isOpen &&
        !isOpening) {
      _concludeReveal();
    }
  }

  /// Normalizes animation speed for animations of various distance.
  ///
  /// When a user stops scrolling, they may have the maximum distance yet
  /// to travel (if they barely crossed the threshold), or they may have 0.001%
  /// of the distance to travel. This is used in the open and closed animation
  /// controllers to keep all animation speeds consistent.
  int get runtime => (_animationRuntime * _revealableOpacity).round();

  void _animateOpen() {
    setToOpening();
    double _startingOpacity = _revealableOpacity;
    _openController = AnimationController(
        duration: Duration(milliseconds: runtime), vsync: this);
    _openAnimation = Tween<double>(begin: 0, end: 1).animate(_openController)
      ..addListener(() {
        setState(() {
          _revealableOpacity =
              (_openAnimation.value + _startingOpacity).clamp(0.0, 1.0);
        });
      })
      ..addStatusListener((state) {
        if (state == AnimationStatus.completed) {
          setToOpen();
          _revealableOpacity = 1;
        }
      });
    _openController.forward();
  }

  void _animateClosed() {
    setToClosing();
    double _startingOpacity = _revealableOpacity;
    _closeController = AnimationController(
        duration: Duration(milliseconds: runtime), vsync: this);
    _closeAnimation =
        Tween<double>(begin: 1.0, end: 0).animate(_closeController)
          ..addListener(() {
            setState(() {
              _revealableOpacity = _closeAnimation.value * _startingOpacity;
            });
          })
          ..addStatusListener((state) {
            if (state == AnimationStatus.completed) {
              setToClosed();
              _revealableOpacity = 0;
            }
          });
    _closeController.forward();
  }

  /// Leads to complete rendering of the "revealable" via the given
  /// [RevealableCompleter].
  void _opener({RevealableCompleter completer}) {
    completer = completer ?? _revealableCompleter;
    _abortCloseAnimation();
    if (completer == RevealableCompleter.animate) {
      _animateOpen();
    } else {
      _snapOpen();
    }
  }

  /// Leads to complete hiding of the "revealable" via the given
  /// [RevealableCompleter].
  void _closer({RevealableCompleter completer}) {
    completer = completer ?? _revealableCompleter;
    _abortOpenAnimation();
    if (completer == RevealableCompleter.animate) {
      _animateClosed();
    } else {
      _snapClosed();
    }
  }

  void _abortCloseAnimation() => _closeController?.stop();
  void _abortOpenAnimation() => _openController?.stop();

  void _snapOpen() {
    setToOpen();
    setState(() {
      _revealableOpacity = 1;
    });
  }

  void _snapClosed() {
    setToClosed();
    setState(() {
      _revealableOpacity = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isEmptyAndForceOnEmpty =
        widget.itemCount == 0 && widget.revealWhenEmpty;
    double opacity =
        (isEmptyAndForceOnEmpty || isOpen) ? 1.0 : _revealableOpacity;
    return Column(
      children: <Widget>[
        _Revealable(
          backgroundBoxDecoration: widget.backgroundRevealableDecoration,
          opacity: opacity,
          maxHeight: _revealableHeight,
          builder: opacity > 0.0 ? widget.revealableBuilder : emptyTopBuilder,
          opener: _opener,
          closer: _closer,
        ),
        widget.dividerBuilder != null
            ? widget.dividerBuilder(context)
            : Container(),
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: (scrollNotification) {
              if (scrollNotification is ScrollUpdateNotification) {
                _onUpdateScroll(scrollNotification);
              } else if (scrollNotification is ScrollEndNotification) {
                _onEndScroll(scrollNotification);
              }
              // This return value continues event propagation
              return null;
            },
            child: widget.builder == null
                ? ListView.builder(
                    controller: _scrollController,
                    // iOS-style physics for everyone, since Android by default
                    // doesn't allow scrolling higher than the highest content
                    physics: AlwaysBouncableScrollPhysics(),
                    keyboardDismissBehavior: widget.keyboardDismissBehavior,
                    itemCount: widget.itemCount,
                    itemBuilder: widget.itemBuilder,
                  )
                : widget.builder(context, _scrollController),
          ),
        ),
      ],
    );
  }
}

/// Helper widget which passes size constraints to the
/// [RevealableBuilder].
class _Revealable extends StatelessWidget {
  /// Optional decoration for a Container that wraps the entire revealed widget.
  final BoxDecoration backgroundBoxDecoration;

  /// Builder for your list's top item, which is conditionally rendered
  /// depending on user scroll behavior.
  final RevealableBuilder builder;

  /// Callback to force the revealed widget to disappear.
  final RevealableToggler closer;

  /// Maximum height of the revealed widget once fully rendered.
  final double maxHeight;

  /// Current transparency of the revealed widget.
  final double opacity;

  /// Callback to force the revealed widget to appear.
  final RevealableToggler opener;
  _Revealable({
    @required this.builder,
    @required this.closer,
    @required this.maxHeight,
    @required this.opacity,
    @required this.opener,
    this.backgroundBoxDecoration,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext _context, BoxConstraints constraints) {
        double _maxHeight = constraints.maxHeight.clamp(0, maxHeight);
        BoxConstraints scaledConstraints = BoxConstraints(
          maxWidth: constraints.maxWidth,
          maxHeight: _maxHeight * opacity,
          minHeight: 0,
          minWidth: 0,
        );
        return Container(
          decoration: backgroundBoxDecoration,
          child: Opacity(
            opacity: opacity,
            child: Transform.scale(
              scale: opacity,
              child: Container(
                constraints: scaledConstraints,
                child: builder(_context, opener, closer, scaledConstraints),
              ),
            ),
          ),
        );
      },
    );
  }
}
