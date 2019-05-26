import 'package:pull_to_reveal/pull_to_reveal.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final bool revealWhenEmpty;

  MyApp({this.revealWhenEmpty = true});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pull to Reveal Demo',
      home: MyHomePage(title: 'Pull to Reveal Demo', revealWhenEmpty: revealWhenEmpty),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  final bool revealWhenEmpty;

  MyHomePage({Key key, this.revealWhenEmpty = true, this.title}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  int _filter;
  List<bool> items = [];
  TextEditingController searchController;

  void initState() {
    searchController = TextEditingController();
    searchController.addListener(_onSearch);
    super.initState();
  }

  void _onSearch() {
    setState(() {
      // `tryParse` returns `null` if the text is not int-friendly
      _filter = int.tryParse(searchController.text);
    });
  }

  void addToList() {
    setState(() {
      _counter++;
      items.add(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: PullToRevealTopItemList(
          revealWhenEmpty: widget.revealWhenEmpty,
          itemsCount: _counter,
          itemBuilder: (BuildContext context, int index) {
            if (_filter != null && _filter < index) {
              return Container();
            }
            return Card(
              margin: EdgeInsets.all(10),
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Text('$index', key: Key('$index'), style: TextStyle(fontSize: 20)),
                ),
              ),
            );
          },
          topItemBuilder: (BuildContext context, Function opener, Function closer) {
            return Row(
              key: Key('scrollable-row'),
              children: <Widget>[
                SizedBox(width: 10),
                Flexible(
                  child: TextFormField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search',
                      suffixIcon: Icon(Icons.search, color: Theme.of(context).backgroundColor),
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
      floatingActionButton: FloatingActionButton(
        onPressed: addToList,
        tooltip: 'Add to List',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
