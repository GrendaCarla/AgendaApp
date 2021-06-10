import 'package:appAgenda/home.dart';

import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

// ---------------- map para personalizar a primarySwatch --------------

Map<int, Color> tonsCorPersonalizada = {
  50: Color.fromRGBO(95, 141, 241, .1),
  100: Color.fromRGBO(95, 141, 241, .2),
  200: Color.fromRGBO(95, 141, 241, .3),
  300: Color.fromRGBO(95, 141, 241, .4),
  400: Color.fromRGBO(95, 141, 241, .5),
  500: Color.fromRGBO(95, 141, 241, 1),
  600: Color.fromRGBO(95, 141, 241, .7),
  700: Color.fromRGBO(95, 141, 241, .8),
  800: Color.fromRGBO(95, 141, 241, .9),
  900: Color.fromRGBO(95, 141, 241, 1),
};

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    MaterialColor corPrimariaPersonalizada =
        MaterialColor(0xFF5F8DF1, tonsCorPersonalizada);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Agenda',
      theme: ThemeData(
        primarySwatch: corPrimariaPersonalizada,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: HomeApp.tag,
      routes: {
        HomeApp.tag: (context) => HomeApp(),
      },
    );
  }
}
