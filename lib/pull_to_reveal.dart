import 'package:flutter/material.dart';

/// Combination of [BouncingScrollPhysics] and [AlwaysScrollableScrollPhysics] which creates
/// the iOS-style bouncing scroll even on when the page is not completely full on Android devices.
class AlwaysBouncableScrollPhysics extends BouncingScrollPhysics {
  const AlwaysBouncableScrollPhysics({ScrollPhysics parent}) : super(parent: parent);

  @override
  AlwaysBouncableScrollPhysics applyTo(ScrollPhysics ancestor) {
    return AlwaysBouncableScrollPhysics(parent: buildParent(ancestor));
  }

  /// This part must be added to `BouncingScrollPhysics` to make the effect work on Android devices
  /// when the page is not completely full
  @override
  bool shouldAcceptUserOffset(ScrollMetrics position) => true;
}

typedef RevealableToggler = void Function();
typedef RevealableBuilder = Widget Function(BuildContext, RevealableToggler, RevealableToggler);

Widget emptyTopBuilder(BuildContext context, RevealableToggler opener, RevealableToggler closer) {
  return Container();
}

class PullToRevealTopItemList extends StatefulWidget {
  // Pass-thru to the eventual ListView for size-of-content optimizations
  final int itemsCount;
  // Determines whether the special revealable item should render if the list
  // is empty
  final bool revealWhenEmpty;
  // Pass-thru to the eventual ListView.builder function
  final IndexedWidgetBuilder itemBuilder;
  // The function that builds your revealable top element
  final RevealableBuilder topItemBuilder;

  PullToRevealTopItemList({
    Key key,
    this.itemsCount,
    this.revealWhenEmpty = true,
    @required this.topItemBuilder,
    @required this.itemBuilder,
  }) : super(key: key);

  State createState() => PullToRevealTopItemListState();
}

class PullToRevealTopItemListState extends State<PullToRevealTopItemList> with TickerProviderStateMixin {
  bool isSearching = false;
  bool isRemoving = false;
  bool _canAddSearch = true;
  bool _canRemoveSearch = true;

  AnimationController _closeController;
  Animation<double> _closeAnimation;

  ScrollController _scrollController;
  double lastEndScrollPosition = 0;

  double searchOpacity = 0;
  double scrollToReveal = 50;

  @override
  void initState() {
    _scrollController = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    if (_closeController != null) {
      _closeController.dispose();
    }
    super.dispose();
  }

  void _onUpdateScroll(ScrollUpdateNotification notification) {
    double pix = notification.metrics.pixels - lastEndScrollPosition;
    // Pushing content up
    if (pix > 0) {
      setState(() {
        isRemoving = true;
        if (pix >= scrollToReveal) {
          isSearching = false;
          if (_canRemoveSearch) {
            searchOpacity = 0;
            // Removes searchItem, so let's not let it come back until the next scroll
            _canAddSearch = false;
          }
        } else {
          if (isSearching) {
            searchOpacity = ((scrollToReveal - pix) / scrollToReveal).clamp(0.0, 1.0);
          }
        }
      });

      // Pulling content down
    } else if (pix < 0) {
      isRemoving = false;
      setState(() {
        if (pix.abs() >= scrollToReveal) {
          // Adds searchItem, so let's not let it go away until the next scroll
          if (_canAddSearch) {
            _canRemoveSearch = false;
            isSearching = true;
          }
        } else {
          searchOpacity = (pix.abs() / scrollToReveal).clamp(0.0, 1.0);
        }
      });
    }
  }

  void _onEndScroll(ScrollEndNotification notification) async {
    lastEndScrollPosition = notification.metrics.pixels;
    // Set value to zero if below zero
    lastEndScrollPosition = lastEndScrollPosition > 0 ? lastEndScrollPosition : 0;

    bool userIsDragging = (notification.dragDetails?.primaryVelocity ?? 0.0) > 0.0;
    if (_canRemoveSearch && !userIsDragging) {
      int runTime = 150 * searchOpacity.round();
      double _startingOpacity = searchOpacity;
      _closeController = AnimationController(duration: Duration(milliseconds: runTime), vsync: this);
      _closeAnimation = Tween<double>(begin: 1.0, end: 0).animate(_closeController)
        ..addListener(() {
          setState(() {
            searchOpacity = _closeAnimation.value * _startingOpacity;
          });
        })
        ..addStatusListener((state) {
          if (state == AnimationStatus.completed) {
            isSearching = false;
          }
        });
      _closeController.forward();
    }
    _canAddSearch = true;
    _canRemoveSearch = true;
  }

  void _opener() {
    _abortCloseAnimation();
    setState(() {
      isSearching = true;
      isRemoving = false;
    });
  }

  void _closer() {
    _abortCloseAnimation();
    setState(() {
      isSearching = false;
      isRemoving = false;
      searchOpacity = 0;
    });
  }

  void _abortCloseAnimation() {
    // TODO: Needs better way to know if `_closeController` is still viable
    // and in need of being disposed
    if (_closeController.toString() != null) {
      _closeController.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEmptyAndForceOnEmpty = widget.itemsCount == 0 && widget.revealWhenEmpty;
    double opacity = (isEmptyAndForceOnEmpty || (isSearching && !isRemoving)) ? 1.0 : searchOpacity;
    return Column(
      children: <Widget>[
        Revealable(
          opacity: opacity,
          maxHeight: scrollToReveal,
          builder: opacity > 0.0 ? widget.topItemBuilder : emptyTopBuilder,
          opener: _opener,
          closer: _closer,
        ),
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: (scrollNotification) {
              if (scrollNotification is ScrollUpdateNotification) {
                _onUpdateScroll(scrollNotification);
              } else if (scrollNotification is ScrollEndNotification) {
                _onEndScroll(scrollNotification);
              }
            },
            child: ListView.builder(
              controller: _scrollController,
              // iOS-style physics for everyone, since Android by default
              // doesn't allow scrolling higher than the highest content
              physics: AlwaysBouncableScrollPhysics(),
              itemCount: widget.itemsCount,
              itemBuilder: widget.itemBuilder,
            ),
          ),
        ),
      ],
    );
  }
}

/// Helper widget which passes size constraints to the `topItemBuilder` defined above
class Revealable extends StatelessWidget {
  final double opacity;
  final double maxHeight;
  final RevealableBuilder builder;
  final RevealableToggler opener;
  final RevealableToggler closer;
  Revealable({
    @required this.opacity,
    @required this.maxHeight,
    @required this.builder,
    @required this.opener,
    @required this.closer,
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
        return Opacity(
          opacity: opacity,
          child: Transform.scale(
            scale: opacity,
            child: Container(
              height: scaledConstraints.maxHeight,
              width: scaledConstraints.maxWidth,
              child: builder(_context, opener, closer),
            ),
          ),
        );
      },
    );
  }
}
