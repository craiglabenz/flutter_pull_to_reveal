# pull_to_reveal

A simple Flutter widget that wraps a `ListView` and selectively renders a hidden top element based on user scroll behavior.

## Getting Started

To use the `PullToRevealListView` widget in your Flutter project, you need only wrap it in a `LayoutBuilder` and then a `Stack`. These are excellent for adding a little life to a `Scaffold` background, or for programming a Pong client.

```dart
import 'package:corner_bouncer/corner_bouncer.dart';
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
          itemsCount: _counter,
          itemBuilder: (BuildContext context, int index) {
            return ListItemElement(index: index);
          },
          topItemBuilder: (BuildContext context, Function opener, Function closer) {
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
