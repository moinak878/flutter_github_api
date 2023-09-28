import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter UrbanMatch Project',
      theme: ThemeData(
        primarySwatch:
            Colors.blueGrey, // Use primarySwatch for consistent color
        fontFamily: 'Roboto', // Use a custom font
      ),
      home: const MyHomePage(title: 'Flutter Github API (UrbanMatch)'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> repositoryData = [];
  Map<String, String> repoCommits = {};

  Future<List<String>> getAllRepos() async {
    var response = await http.get(Uri.https(
        'api.github.com', 'users/freeCodeCamp/repos', {'q': '{https}'}));
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body) as List<dynamic>;
      for (int i = 0; i < jsonResponse.length; i++) {
        repositoryData.add(jsonResponse[i]['name']);
      }
      return repositoryData;
    } else {
      throw Exception('Error fetching repo data');
    }
  }

  Future<String?> getLastCommit(String repoName) async {
    if (repoCommits.containsKey(repoName)) {
      return repoCommits[repoName];
    }

    var response = await http.get(
      Uri.https('api.github.com', 'repos/freeCodeCamp/$repoName/commits'),
    );

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body) as List<dynamic>;
      if (jsonResponse.isNotEmpty) {
        repoCommits[repoName] = jsonResponse[0]['commit']['message'];
        return jsonResponse[0]['commit']['message'];
      } else {
        repoCommits[repoName] = 'No commits found';
        return 'No commits found';
      }
    } else {
      return 'Error fetching commit';
    }
  }

  @override
  void initState() {
    super.initState();
    repositoryData.clear();
    getAllRepos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: AppBar(
        title: Center(child: Text(widget.title)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'FreeCodeCamp Repositories',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<String>>(
                future: getAllRepos(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CupertinoActivityIndicator(
                      color: Colors.white,
                      radius: 24.0,
                    ));
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData) {
                    return const Text('No repositories available.');
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (BuildContext context, int index) {
                        final repoName =
                            snapshot.data?[index] ?? 'Repository Name Missing';
                        return Container(
                          margin: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.0),
                            color: const Color.fromARGB(
                                255, 255, 255, 255), // Use a bright color
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 1.0,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ListTile(
                              title: Column(children: [
                            Text(
                              repoName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            FutureBuilder<String?>(
                              future: getLastCommit(repoName),
                              builder: (context, commitSnapshot) {
                                if (commitSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                } else if (commitSnapshot.hasError) {
                                  return Text(
                                    'Error: ${commitSnapshot.error}',
                                    style: const TextStyle(
                                      color: Colors.red,
                                    ),
                                  );
                                } else if (!commitSnapshot.hasData) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey, // Border color
                                        width: 1.0, // Border width
                                      ),
                                      borderRadius: BorderRadius.circular(
                                          4.0), // Border radius
                                    ),
                                    padding: const EdgeInsets.all(
                                        4.0), // Padding inside the container
                                    child: const Text(
                                      'No commit history found',
                                      style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  );
                                } else {
                                  return Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors
                                            .green.shade900, // Border color
                                        width: 1.0, // Border width
                                      ),
                                      borderRadius: BorderRadius.circular(
                                          4.0), // Border radius
                                    ),
                                    padding: const EdgeInsets.all(
                                        4.0), // Padding inside the container
                                    child: Text(
                                      commitSnapshot.data!,
                                      style: TextStyle(
                                        color: Colors.green.shade900,
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ])),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
