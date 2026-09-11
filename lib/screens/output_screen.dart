import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_german/api_service.dart';
import 'package:flutter_german/app_colors.dart';
import 'package:flutter_german/models/word_response.dart';

class OutputScreen extends StatefulWidget {
  final ScrapedData scrapedData;
  const OutputScreen({super.key, required this.scrapedData});

  @override
  State<StatefulWidget> createState() => OutputScreenState();
}

class OutputScreenState extends State<OutputScreen> {
  List<String> definitions = [];
  late String selectedValue;
  bool isLoading = false;

  @override
  void initState() {
    selectedValue = widget.scrapedData.wordResponse.translations.first;
    getDefinitions(selectedValue);
    super.initState();
  }

  Future<void> getDefinitions(String word) async {
    setState(() {
      isLoading = true;
    });
    final definitionsList = await ApiService.getDefinition(
      word,
      widget.scrapedData.wordResponse.type,
    );
    setState(() {
      definitions = definitionsList;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> translations = widget.scrapedData.wordResponse.translations;
    NounData? nounData = widget.scrapedData.wordResponse.nounData;
    VerbData? verbData = widget.scrapedData.wordResponse.verbData;
    AdjectiveData? adjectiveData =
        widget.scrapedData.wordResponse.adjectiveData;
    final response = widget.scrapedData.wordResponse;
    return Scaffold(
      appBar: AppBar(title: Text("Result")),
      body: Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 15, vertical: 15),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MainCard(
                word: response.word,
                nounData: nounData,
                verbData: verbData,
                adjectiveData: adjectiveData,
              ),
              DropdownCard(
                title: 'Translations',
                entries: translations,
                isCopyAll: true,
                onChanged: (word) {
                  setState(() {
                    isLoading = true;
                  });
                  getDefinitions(word);
                },
                isLoading: false,
              ),
              DropdownCard(
                title: 'Definitions',
                entries: definitions,
                isCopyAll: false,
                isLoading: isLoading,
              ),
              widget.scrapedData.originalSentence != null
                  ? TextCard(
                      title: 'Your sentence (German)',
                      content: widget.scrapedData.originalSentence!,
                    )
                  : SizedBox.shrink(),
              widget.scrapedData.originalSentence != null
                  ? TextCard(
                      title: 'Your sentence (Translation)',
                      content: widget.scrapedData.translatedSentence!,
                    )
                  : SizedBox.shrink(),
              widget.scrapedData.originalSentence != null
                  ? TextCard(
                      title: 'Your sentence (With a blank)',
                      content: widget.scrapedData.originalSentence!.replaceAll(
                        response.word,
                        '_' * response.word.length,
                      ),
                    )
                  : SizedBox.shrink(),
              TextCard(
                title: 'Another sentence (German)',
                content: response.germanSentence,
              ),
              TextCard(
                title: 'Another sentence (Translation)',
                content: response.englishSentence,
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
                    InkWell(
                      onTap: () async {
                        copyToClip(context, content);
                      },
                      child: Icon(Icons.copy, size: 18),
                    ),
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
  final ValueChanged<String>? onChanged;
  final bool isCopyAll;
  final bool isLoading;
  const DropdownCard({
    super.key,
    required this.title,
    required this.entries,
    required this.isCopyAll,
    this.onChanged,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    String selectedValue = entries.isNotEmpty ? entries[0] : '';
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
                isLoading
                    ? CircularProgressIndicator()
                    : Expanded(
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          items: entries
                              .map(
                                (entry) => DropdownMenuItem<String>(
                                  value: entry,
                                  child: Text(
                                    entry,
                                    softWrap: true,
                                    maxLines: null,
                                  ),
                                ),
                              )
                              .toList(),
                          initialValue: selectedValue,
                          onChanged: (value) {
                            selectedValue = value!;
                            if (isCopyAll) {
                              onChanged!(selectedValue);
                            }
                          },
                          decoration: InputDecoration(
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
                InkWell(
                  onTap: () async {
                    copyToClip(context, selectedValue);
                  },
                  child: Icon(Icons.copy, size: 18),
                ),
              ],
            ),

            isCopyAll ? const SizedBox(height: 5) : SizedBox.shrink(),

            isCopyAll
                ? SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        copyToClip(context, entries.join(', '));
                      },
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
                IconButton(
                  onPressed: () async {
                    copyToClip(context, word);
                  },
                  icon: Icon(Icons.copy),
                ),
              ],
            ),
            nounData != null
                ? NounSpecificData(nounData: nounData!)
                : SizedBox.shrink(),
            verbData != null
                ? VerbSpecificData(verbData: verbData!)
                : SizedBox.shrink(),
            adjectiveData != null
                ? AdjectiveSpecificData(adjectiveData: adjectiveData!)
                : SizedBox.shrink(),
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
        padding: EdgeInsetsGeometry.directional(
          start: 15,
          end: 7,
          top: 7,
          bottom: 7,
        ),
        child: Column(
          children: [
            TextRow(title: 'Article: ', content: nounData.article),
            SizedBox(height: 5),
            TextRow(title: 'Plural: ', content: plural),
          ],
        ),
      ),
    );
  }
}

class VerbSpecificData extends StatelessWidget {
  final VerbData verbData;
  const VerbSpecificData({super.key, required this.verbData});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.secondaryCard,
      child: Padding(
        padding: EdgeInsetsGeometry.directional(
          start: 15,
          end: 7,
          top: 7,
          bottom: 7,
        ),
        child: Column(
          children: [
            TextRow(title: 'Infinitive: ', content: verbData.infinitive),
            SizedBox(height: 5),
            TextRow(title: 'Prateritum: ', content: verbData.prateritum),
            SizedBox(height: 5),
            TextRow(title: 'Perfect: ', content: verbData.perfect),
          ],
        ),
      ),
    );
  }
}

class AdjectiveSpecificData extends StatelessWidget {
  final AdjectiveData adjectiveData;
  const AdjectiveSpecificData({super.key, required this.adjectiveData});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.secondaryCard,
      child: Padding(
        padding: EdgeInsetsGeometry.directional(
          start: 15,
          end: 7,
          top: 7,
          bottom: 7,
        ),
        child: Column(
          children: [
            TextRow(title: 'Comparative: ', content: adjectiveData.comparative),
            SizedBox(height: 5),
            TextRow(title: 'Superlative: ', content: adjectiveData.superlative),
          ],
        ),
      ),
    );
  }
}

class TextRow extends StatelessWidget {
  final String title;
  final String content;
  const TextRow({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 17, color: AppColors.secondaryText),
        ),
        Expanded(
          child: Text(
            content,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
        ),
        InkWell(
          onTap: () async {
            copyToClip(context, content);
          },
          child: Icon(Icons.copy, size: 18),
        ),
        SizedBox(width: 5),
      ],
    );
  }
}

void copyToClip(BuildContext context, String content) async {
  Clipboard.setData(ClipboardData(text: content));
  if (!context.mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      duration: Duration(milliseconds: 750),
      content: Text('Copied to clipboard!'),
    ),
  );
}
