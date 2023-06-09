import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:vac_iot/src/pages/chart_page.dart';
import 'package:vac_iot/src/pages/home_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/detalhes': (context) => ChartPage(),
      },
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(title: 'Controle Vacinas'),
    );
  }
}
