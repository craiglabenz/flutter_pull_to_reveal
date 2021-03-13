## [0.0.3-nullsafety.0] - 2021-03-13

- Initial commit of null-safety migration.
- Added `freezeOnScrollUpIfKeyboardIsVisible` parameter to prevent revealable
  from minimizing on scroll up, which is useful if that contains a form field.

## [0.0.2] - 2020-12-02

- Added builder pattern for complete control.

## [0.0.1-beta] - 2019-05-26

- Creates `PullToRevealListView` widget that contains a hidden top widget users can pull to reveal. Forces iOS-style scroll physics across platforms to achieve this effect.

## [0.0.1-beta-2] - 2019-05-28

- Added `dividerBuilder` to place content between list and revealable

## [0.0.1-beta-3] - 2019-05-29

- Fixed issue where scroll behavior was different depending on whether or not ListView's content overflowed the visible area. Behavior is now different between those two scenarios, but both are acceptable. (When Revealed, and partially scrolling up: overflowing situations will finish closing the Revealable, whereas non-overflowing situations will revert back to a full reveal.) Before, non-overflowing situations reverted back to a full reveal, then blinked away. Very unsatisfying.

## [0.0.1-beta-4] - 2019-06-01

- Attribute consistency improvements (renamed `topItemBuilder` to `revealableBuilder`)
- Improved close animation logic

## [0.0.1-beta-5] - 2019-06-04

- Added `startedRevealed` option for better user search discoverability

## [0.0.1] - 2019-09-26

- Fixed inconsistent scrolling/snapping behavior
- Added [RevealableCompleter] flag for animation control
- Significantly refactored internal logic
- Standardized example to filter on substrings instead of integers

## [0.0.2] - 2020-12-02

- Added `BoxDecoration` parameter for background of Revealable
- Added new `.builder()` constructor to fully expose the composition of the underlying `ListView`
- Directly exposed `ScrollViewKeyboardDismissBehavior` parameter from `ListView`
- Additional comments and code formatting
