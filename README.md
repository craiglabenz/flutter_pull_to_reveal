# pull_to_reveal

A simple Flutter widget that wraps a `ListView` and selectively renders a hidden top element based on user scroll behavior.

## Getting Started

To use the `PullToRevealTopItemList` widget in your Flutter project, wrap any of
your `ListView`s with this extra widget. You can either use the
`PullToRevealTopItemList.builder()` pattern to control the entire inner list, or
use the familiar `itemCount` and `itemBuilder(context, index)` pattern.

```dart
import 'package:pull_to_reveal/pull_to_reveal.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: PullToRevealTopItemList(
          // Set this to `true` to avoid losing a TextInput in your revealable
          // during scroll up, and in doing so, also causing Flutter to dismiss
          // any visible keyboards.
          freezeOnScrollUpIfKeyboardIsVisible: true,
          itemCount: _counter,
          itemBuilder: (BuildContext context, int index) {
            return ListItemElement(index: index);
          },
          revealableHeight: 50,
          revealableBuilder: (BuildContext context, RevealableToggler opener, RevealableToggler closer, BoxConstraints constraints) {
            return Row(
              children: <Widget>[
                SizedBox(width: 10),
                Flexible(
                  child: TextFormField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search',
                      suffixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.cancel),
                  onPressed: () {
                    // Handles closing the `Revealable`
                    closer();
                    // Removes any filtering effects
                    searchController.text = '';
                    setState(() {
                      _filter = null;
                    });
                  },
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
```

<img src="https://raw.githubusercontent.com/craiglabenz/flutter_pull_to_reveal/master/doc/assets/example.gif" alt="Example" height="600" />
