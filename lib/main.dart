import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AnyNote',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Anyone can take note'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String name = "";
  String password = "";
  String note = "";
  String oldNotes = "";

  TextEditingController nameTextController = TextEditingController();
  TextEditingController passwordTextController = TextEditingController();
  TextEditingController noteTextController = TextEditingController();

  FirebaseFirestore db = FirebaseFirestore.instance;

  void addToDB() async {
    int count = 0;
    await db.collection("users").get().then((event) {
      for (var doc in event.docs) {
        if ("$name++$password".compareTo(doc.id) == 0) {
          //In case the user has already saved notes
          if (doc.data().containsKey('count')) {
            count = doc.data()["count"];
          }
        }
      }
    });

    count++;

    final userNote = <String, dynamic>{"note$count": note, "count": count};

    db
        .collection("users")
        .doc("$name++$password")
        .set(userNote, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>> get() async {
    Map<String, dynamic> a = {};

    await db.collection("users").get().then((event) {
      for (var doc in event.docs) {
        if ("$name++$password".compareTo(doc.id) == 0) {
          var v = doc.data();

          oldNotes = "";
          int count = 0;
          int i = 1;

          if (v.containsKey("count")) {
            count = v["count"];
            while (i <= count) {
              oldNotes += "Note $i:" + v["note$i"] + "\n";
              i++;
            }
          }

          return doc.data();
        }
      }
    });
    return a;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Row(
                    children: <Widget>[
                      const Expanded(
                        flex: 2,
                        child: Text("Name:"),
                      ),
                      Expanded(
                        flex: 7,
                        child: TextField(
                          controller: nameTextController,
                          maxLines: null,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      const Expanded(
                        flex: 2,
                        child: Text("Password:"),
                      ),
                      Expanded(
                        flex: 7,
                        child: TextField(
                          controller: passwordTextController,
                          obscureText: true,
                          obscuringCharacter: '*',
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      const Expanded(
                        flex: 2,
                        child: Text("Note:"),
                      ),
                      Expanded(
                        flex: 7,
                        child: TextField(
                          controller: noteTextController,
                          maxLines: null,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                          flex: 1,
                          child: TextButton(
                              onPressed: () {
                                setState(() {
                                  name = nameTextController.text;
                                  password = passwordTextController.text;
                                  note = noteTextController.text;
                                });
                                addToDB();
                              },
                              child: const Text("Save Note"))),
                      Expanded(
                          flex: 1,
                          child: TextButton(
                              onPressed: () {
                                get();
                                setState(() {});
                              },
                              child: const Text("Show Notes"))),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: Text(oldNotes),
            ),
            // Text(oldNotes),
          ],
        ),
      ),
    );
  }
}
