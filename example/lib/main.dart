import 'dart:math';

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
  String _filter;
  List<String> items = [];
  TextEditingController searchController;

  void initState() {
    searchController = TextEditingController();
    searchController.addListener(_onSearch);
    super.initState();
  }

  void _onSearch() {
    setState(() {
      _filter = searchController.text;
    });
  }

  void addToList() {
    setState(() {
      _counter++;
      items.add(names[Random.secure().nextInt(names.length - 1)]);
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
          itemCount: _counter,
          revealableHeight: 50,
          itemBuilder: (BuildContext context, int index) {
            if (_filter != null && !items[index].contains(_filter)) {
              return Container();
            }
            return Card(
              margin: EdgeInsets.all(10),
              child: Center(
                child: Container(
                  height: 150,
                  padding: EdgeInsets.all(10),
                  child: Center(
                    child: Text('${items[index]}', key: Key('$index'), style: TextStyle(fontSize: 20)),
                  ),
                ),
              ),
            );
          },
          dividerBuilder: (BuildContext context) {
            return Container(
              alignment: Alignment.topLeft,
              padding: EdgeInsets.all(10),
              child: Text('Items', style: Theme.of(context).textTheme.headline),
            );
          },
          revealableBuilder: (BuildContext context, RevealableToggler opener, RevealableToggler closer, BoxConstraints constraints) {
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
                    closer(completer: RevealableCompleter.snap);
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

const List<String> names = [
  "Michael",
  "James",
  "John",
  "Robert",
  "David",
  "William",
  "Mary",
  "Christopher",
  "Joseph",
  "Richard",
  "Daniel",
  "Thomas",
  "Matthew",
  "Jennifer",
  "Charles",
  "Anthony",
  "Patricia",
  "Linda",
  "Mark",
  "Elizabeth",
  "Joshua",
  "Steven",
  "Andrew",
  "Kevin",
  "Brian",
  "Barbara",
  "Jessica",
  "Jason",
  "Susan",
  "Timothy",
  "Paul",
  "Kenneth",
  "Lisa",
  "Ryan",
  "Sarah",
  "Karen",
  "Jeffrey",
  "Donald",
  "Ashley",
  "Eric",
  "Jacob",
  "Nicholas",
  "Jonathan",
  "Ronald",
  "Michelle",
  "Kimberly",
  "Nancy",
  "Justin",
  "Sandra",
  "Amanda",
  "Brandon",
  "Stephanie",
  "Emily",
  "Melissa",
  "Gary",
  "Edward",
  "Stephen",
  "Scott",
  "George",
  "Donna",
  "Jose",
  "Rebecca",
  "Deborah",
  "Laura",
  "Cynthia",
  "Carol",
  "Amy",
  "Margaret",
  "Gregory",
  "Sharon",
  "Larry",
  "Angela",
  "Maria",
  "Alexander",
  "Benjamin",
  "Nicole",
  "Kathleen",
  "Patrick",
  "Samantha",
  "Tyler",
  "Samuel",
  "Betty",
  "Brenda",
  "Pamela",
  "Aaron",
  "Kelly",
  "Heather",
  "Rachel",
  "Adam",
  "Christine",
  "Zachary",
  "Debra",
  "Katherine",
  "Dennis",
  "Nathan",
  "Christina",
  "Julie",
  "Jordan",
  "Kyle",
  "Anna",
];
