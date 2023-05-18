import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/rendering.dart';
import 'dart:async';

import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> containers = [];
  late DatabaseReference starCountRef;
  StreamSubscription<DatabaseEvent>? subscription;
  dynamic selectedContainer;
  String temperature = "?";
  String lastTime = "";

  @override
  void initState() {
    initFirebase();
    super.initState();
  }

  initFirebase() async {
    starCountRef = FirebaseDatabase.instance.ref();
    starCountRef.once().then((DatabaseEvent event) {
      final dynamic data = event.snapshot.value;
      List<dynamic> containers = data.keys.toList();

      Set<String> set1 = Set.from(this.containers);
      Set<String> set2 = Set.from(containers);

      if (set1.difference(set2).isNotEmpty ||
          set2.difference(set1).isNotEmpty) {
        setState(() {
          this.containers = containers;
        });
      }
    });
  }

  listen() {
    print('listen $selectedContainer');
    subscription?.cancel();
    starCountRef = FirebaseDatabase.instance.ref(selectedContainer);
    subscription = starCountRef.onValue.listen((DatabaseEvent event) {
      final dynamic data = event.snapshot.value;
      String date = DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.fromMillisecondsSinceEpoch(int.parse(data['timestamp'])  * 1000).toLocal());
      setState(() {
        temperature = data['temperature'];
        lastTime = date;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffeeeeee),
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.3,
              width: MediaQuery.of(context).size.width * 0.8,
              child: Card(
                color: Colors.transparent,
                elevation: 0,
                margin: const EdgeInsets.all(0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(width: 1, color: Colors.grey[300]!),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        temperature == "?"
                            ? "Selecione um Container"
                            : "$temperature°",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: temperature == "?" ? 24 : 32,
                          fontFamily: "Roboto",
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (temperature != "?")
                        Text(
                          "Medido em: $lastTime",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            fontFamily: "Roboto",
                          ),
                        ),
                      const SizedBox(height: 16),
                      if (temperature != "?")
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/detalhes',
                              arguments: selectedContainer,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                          ),
                          child: const Text("Ver detalhes"),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.builder(
                itemCount: containers.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  dynamic containerId = containers[index];
                  return Column(
                    children: [
                      ListTile(
                        title: Text(
                          "Container ID: $containerId",
                          style: TextStyle(
                            fontFamily: "Roboto",
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: containerId == selectedContainer
                                ? Colors.green
                                : Colors.black,
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            color: containerId == selectedContainer
                                ? Colors.green
                                : Colors.black,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        onTap: () {
                          setState(() {
                            selectedContainer = containerId;
                            listen();
                          });
                        },
                        tileColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.grey[400],
                          size: 20,
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
