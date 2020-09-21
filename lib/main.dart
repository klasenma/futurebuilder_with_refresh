import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:futurebuilder_with_refresh/model/user.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Example(),
    );
  }
}

class Example extends StatefulWidget {
  @override
  _ExampleState createState() => _ExampleState();
}

class _ExampleState extends State<Example> {
  var _refreshKey = GlobalKey<RefreshIndicatorState>();
  Future<List<User>> users;

  @override
  void initState() {
    super.initState();
    // Right Url for the initial request
    users = _fetchExampleUser('https://jsonplaceholder.typicode.com/users');
  }

  Future sleep() {
    return new Future.delayed(const Duration(seconds: 2), () => "2");
  }

  Future<List<User>> _fetchExampleUser(String url) async {
    await sleep();
    final response = await http.get(url);

    if (response.statusCode == 200) {
      var responseJson = jsonDecode(response.body);
      return responseJson.map<User>((el) => User.fromJson(el)).toList();
    } else {
      throw new Exception('an error occurred...');
    }
  }

  // Use a wrong url to simulate an exception on refresh
  Future _refresh() async {
    setState(() {});
    return users = _fetchExampleUser(
        'https://jsonplaceholder.typicode.com/somewrongurl'); // ==> Unhandled Exception: Exception: an error occurred...
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('RefreshIndicator and FutureBuilder'),
      ),
      body: FutureBuilder(
        future: users,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<User> _users = snapshot.data;

            return RefreshIndicator(
              key: _refreshKey,
              onRefresh: () => _refresh(),
              child: Container(
                height: MediaQuery.of(context).size.height,
                child: ListView(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  children: _users.map((el) {
                    return Card(
                      elevation: 4,
                      child: ListTile(
                        title: Text(el.name),
                        onTap: () {},
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.black,
                            )
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            );
          } else if (snapshot.hasError) {
            print(snapshot.error.toString());
            return RefreshIndicator(
              key: _refreshKey,
              onRefresh: () => _refresh(),
              child: Container(
                height: MediaQuery.of(context).size.height,
                child: ListView(
                  children: [
                    Card(
                      elevation: 4,
                      child: ListTile(
                        title: Text(snapshot.error.toString()),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
