import 'package:flutter/material.dart';
import 'package:flutter_german/api_service.dart';
import 'package:flutter_german/app_colors.dart';
import 'package:flutter_german/models/word_response.dart';

class OutputScreen extends StatefulWidget {
  const OutputScreen({super.key});

  @override
  State<StatefulWidget> createState() => OutputScreenState();
}

class OutputScreenState extends State<OutputScreen> {
  List<String> translations = ['House', 'Home'];
  List<String> definitions = ['House', 'Home'];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Result")),
      body: Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 15, vertical: 15),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MainCard(
                word: 'Haus',
                nounData: NounData(
                  article: 'der',
                  plural: ['Hauser', 'Hauser'],
                ),
              ),
              DropdownCard(
                title: 'Translations',
                entries: translations,
                isCopyAll: true,
              ),
              DropdownCard(
                title: 'Definitions',
                entries: definitions,
                isCopyAll: false,
              ),
              TextCard(
                title: 'Your sentence (German)',
                content: 'Ich gehe nach Hause.',
              ),
              TextCard(
                title: 'Your sentence (Translation)',
                content: 'Im going home.',
              ),
              TextCard(
                title: 'Your sentence (With a blank)',
                content: 'Ich gehe nach _____.',
              ),
              TextCard(
                title: 'Another sentence (German)',
                content: 'Das Haus ist gross.',
              ),
              TextCard(
                title: 'Another sentence (Translation)',
                content: 'The house is big.',
              ),
              SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}

class TextCard extends StatelessWidget {
  final String title;
  final String content;
  const TextCard({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsetsDirectional.only(
          start: 15,
          end: 10,
          bottom: 10,
          top: 7,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: AppColors.secondaryText)),
            SizedBox(height: 5),
            Card(
              color: AppColors.secondaryCard,
              child: Padding(
                padding: EdgeInsetsGeometry.directional(
                  top: 7,
                  bottom: 7,
                  start: 12,
                  end: 12,
                ),
                child: Row(
                  children: [
                    Expanded(child: Text(content)),
                    Icon(Icons.copy, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DropdownCard extends StatelessWidget {
  final String title;
  final List<String> entries;
  final bool isCopyAll;
  const DropdownCard({
    super.key,
    required this.title,
    required this.entries,
    required this.isCopyAll,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsetsDirectional.only(
          start: 20,
          end: 10,
          bottom: 10,
          top: 5,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: AppColors.secondaryText)),
            SizedBox(height: 5),
            Row(
              children: [
                Expanded(
                  child: DropdownMenu<String>(
                    width: double.infinity,
                    dropdownMenuEntries: entries
                        .map(
                          (entry) => DropdownMenuEntry<String>(
                            value: entry,
                            label: entry,
                          ),
                        )
                        .toList(),
                    initialSelection: entries[0],
                    inputDecorationTheme: InputDecorationTheme(
                      filled: true,
                      fillColor: AppColors.secondaryCard,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 2,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.primaryCard,
                          width: 0.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.primaryCard,
                          width: 0.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.primaryCard,
                          width: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.copy, size: 18),
              ],
            ),

            isCopyAll ? const SizedBox(height: 5) : SizedBox.shrink(),

            isCopyAll
                ? SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Copy All'),
                          SizedBox(width: 5),
                          Icon(Icons.copy_all),
                        ],
                      ),
                    ),
                  )
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}

class MainCard extends StatelessWidget {
  final String word;
  final NounData? nounData;
  final AdjectiveData? adjectiveData;
  final VerbData? verbData;
  const MainCard({
    super.key,
    required this.word,
    this.nounData,
    this.adjectiveData,
    this.verbData,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsetsGeometry.directional(start: 20, end: 10, bottom: 10),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    word,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(onPressed: () {}, icon: Icon(Icons.copy)),
              ],
            ),
            NounSpecificData(nounData: nounData!),
          ],
        ),
      ),
    );
  }
}

class NounSpecificData extends StatelessWidget {
  final NounData nounData;
  const NounSpecificData({super.key, required this.nounData});

  @override
  Widget build(BuildContext context) {
    final String plural = nounData.plural.join('/');
    return Card(
      color: AppColors.secondaryCard,
      child: Padding(
        padding: EdgeInsetsGeometry.directional(start: 15, end: 7, top: 7, bottom: 7),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  'Article: ',
                  style: TextStyle(
                    fontSize: 17,
                    color: AppColors.secondaryText,
                  ),
                ),
                Expanded(
                  child: Text(
                    nounData.article,
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                  ),
                ),
                Icon(Icons.copy, size: 18),
                SizedBox(width: 5),
              ],
            ),
            SizedBox(height: 5),
            Row(
              children: [
                Text(
                  'Plural: ',
                  style: TextStyle(
                    fontSize: 17,
                    color: AppColors.secondaryText,
                  ),
                ),
                Expanded(
                  child: Text(
                    plural,
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                  ),
                ),
                Icon(Icons.copy, size: 18),
                SizedBox(width: 5),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
