import 'package:falling_sand/falling_sand.dart';
import 'package:falling_sand/grid_sketch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_processing/flutter_processing.dart';

const Color darkBlue = Color.fromARGB(255, 18, 32, 47);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: darkBlue,
        body: Processing(
          sketch: FallingSandSketch(MediaQuery.sizeOf(context)),
        ),
        // body: FallingSand(),
      ),
    );
  }
}
