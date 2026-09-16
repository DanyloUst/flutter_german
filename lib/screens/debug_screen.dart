import 'package:flutter/material.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<StatefulWidget> createState() => DebugScreenState();
}

class DebugScreenState extends State<DebugScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('DEBUG')),
      body: Center(child: Text('DEBUG HERE')),
    );
  }
}
