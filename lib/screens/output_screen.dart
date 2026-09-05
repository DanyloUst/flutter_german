import 'package:flutter/material.dart';
import 'package:flutter_german/api_service.dart';
import 'package:flutter_german/models/word_response.dart';

class OutputScreen extends StatefulWidget {
  final WordResponse response;
  const OutputScreen({super.key, required this.response});
  @override
  State<StatefulWidget> createState() => OutputScreenState();
}

class OutputScreenState extends State<OutputScreen> {
  List<String>? definitions;
  String? selectedTranslation;
  @override
  Widget build(BuildContext context) {
    if (definitions == null) {
      selectedTranslation = widget.response.translations.first;
    }
    return Scaffold(
      appBar: AppBar(title: Text('Output')),
      body: Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 10, vertical: 5),
        child: Column(
          children: [
            Row(children: [Text('The word: '), Text(widget.response.word)]),
            widget.response.nounData != null
                ? Row(
                    children: [
                      Text('Arricle: '),
                      Text(widget.response.nounData!.article),
                    ],
                  )
                : SizedBox.shrink(),
            widget.response.nounData != null
                ? Row(
                    children: [
                      Text('Plural: '),
                      Text(widget.response.nounData!.plural.join(', ')),
                    ],
                  )
                : SizedBox.shrink(),
            widget.response.verbData != null
                ? Row(
                    children: [
                      Text('Infinitive: '),
                      Text(widget.response.verbData!.infinitive),
                    ],
                  )
                : SizedBox.shrink(),
            widget.response.verbData != null
                ? Row(
                    children: [
                      Text('Prateritum: '),
                      Text(widget.response.verbData!.prateritum),
                    ],
                  )
                : SizedBox.shrink(),
            widget.response.verbData != null
                ? Row(
                    children: [
                      Text('Perfect: '),
                      Text(widget.response.verbData!.perfect),
                    ],
                  )
                : SizedBox.shrink(),
            widget.response.adjectiveData != null
                ? Row(
                    children: [
                      Text('Comparative: '),
                      Text(widget.response.adjectiveData!.comparative),
                    ],
                  )
                : SizedBox.shrink(),
            widget.response.adjectiveData != null
                ? Row(
                    children: [
                      Text('Superlative: '),
                      Text(widget.response.adjectiveData!.superlative),
                    ],
                  )
                : SizedBox.shrink(),
            Row(
              children: [
                Text('Translation:'),
                DropdownMenu(
                  dropdownMenuEntries: widget.response.translations.map((
                    translation,
                  ) {
                    return DropdownMenuEntry(
                      value: translation,
                      label: translation,
                    );
                  }).toList(),
                  initialSelection: widget.response.translations.first,
                  onSelected: (value) {
                    setState(() {
                      selectedTranslation = value;
                    });
                  },
                ),
                IconButton(onPressed: () {}, icon: Icon(Icons.copy)),
              ],
            ),
            Row(
              children: [
                Text('Definition:'),
                definitions != null
                    ? DropdownMenu(
                        dropdownMenuEntries: definitions!.map((definition) {
                          return DropdownMenuEntry(
                            value: definition,
                            label: definition,
                          );
                        }).toList(),
                        initialSelection: definitions!.first,
                        onSelected: (value) {},
                      )
                    : ElevatedButton(
                        onPressed: () async {
                          try {
                            print('i happen');
                            final definitionsList =
                                await ApiService.getDefinition(
                                  selectedTranslation!,
                                  widget.response.type,
                                );
                            setState(() {
                              definitions = definitionsList;
                            });
                          } catch (e) {
                            print("something went wrong: $e");
                          }
                        },
                        child: Text('Get definition'),
                      ),
                IconButton(onPressed: () {}, icon: Icon(Icons.copy)),
              ],
            ),
            Row(
              children: [
                Text('German example:'),
                Text(widget.response.germanSentence),
              ],
            ),
            Row(
              children: [
                Text('German example translation:'),
                Text(widget.response.englishSentence),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
