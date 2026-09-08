import 'package:flutter/material.dart';
import 'package:flutter_german/api_service.dart';
import 'package:flutter_german/models/word_response.dart';

class OutputScreen extends StatefulWidget {
  const OutputScreen({super.key});

  @override
  State<StatefulWidget> createState() => OutputScreenState();
}

class OutputScreenState extends State<OutputScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Result")),
      body: Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 15, vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Expanded(
                child: Padding(
                  padding: EdgeInsetsGeometry.symmetric(horizontal: 10),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text('Word', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          ),
                          IconButton(onPressed: () {}, icon: Icon(Icons.copy)),
                        ],
                      ),
                      Row(
                        children: [
                          Text('Article: ', style: TextStyle(fontSize: 17)),
                          Expanded(
                            child: Text('Der', style: TextStyle(fontSize: 17)),
                          ),
                          IconButton(onPressed: () {}, icon: Icon(Icons.copy)),
                        ],
                      ),
                      Row(
                        children: [
                          Text('Plural: ', style: TextStyle(fontSize: 17)),
                          Expanded(
                            child: Text('Words/Wordss', style: TextStyle(fontSize: 17)),
                          ),
                          IconButton(onPressed: () {}, icon: Icon(Icons.copy)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
