import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_german/api_service.dart';
import 'package:flutter_german/app_colors.dart';
import 'package:flutter_german/models/word_response.dart';
import 'package:flutter_german/scraper.dart';
import 'package:file_saver/file_saver.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

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
  late WordResponse selectedWord;

  @override
  void initState() {
    selectedWord = widget.scrapedData.wordResponses[0];
    selectedValue = selectedWord.translations.first;
    getDefinitions(selectedValue);
    super.initState();
  }

  Future<void> getDefinitions(String word) async {
    setState(() {
      isLoading = true;
    });
    final definitionsList = await ApiService.scrapeDefinition(
      word,
      selectedWord.type,
    );
    setState(() {
      definitions = definitionsList;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> translations = selectedWord.translations;
    NounData? nounData = selectedWord.nounData;
    VerbData? verbData = selectedWord.verbData;
    AdjectiveData? adjectiveData = selectedWord.adjectiveData;
    final response = selectedWord;

    final originalSentence = widget.scrapedData.originalSentence;
    final translatedSentence = widget.scrapedData.translatedSentence;
    String originalBlank = originalSentence;

    if (originalSentence.isNotEmpty) {
      for (final word in originalSentence.split(' ')) {
        if (word.contains(response.word)) {
          originalBlank = originalSentence.replaceAll(word, '_' * word.length);
        }
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text("Result")),
      body: Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 15, vertical: 15),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: widget.scrapedData.wordResponses.map((response) {
                  bool isSelected = response == selectedWord;
                  return Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          selectedWord = response;
                        });
                      },
                      child: Card(
                        color: AppColors.primaryCard,
                        child: Padding(
                          padding: EdgeInsetsGeometry.directional(
                            top: 7,
                            start: 5,
                            end: 5,
                            bottom: 7,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSelected
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_off,
                              ),
                              SizedBox(width: 5),
                              Text(response.type),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
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
              originalSentence.isNotEmpty
                  ? TextCard(
                      title: 'Your sentence (German)',
                      content: originalSentence,
                    )
                  : SizedBox.shrink(),
              translatedSentence != null
                  ? TextCard(
                      title: 'Your sentence (Translation)',
                      content: translatedSentence,
                    )
                  : SizedBox.shrink(),
              originalBlank.isNotEmpty
                  ? TextCard(
                      title: 'Your sentence (With a blank)',
                      content: originalBlank,
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
              PronunciationCard(
                pronunciationBytes: widget.scrapedData.pronunciationBytes,
                word: response.word,
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
                    Expanded(child: Text(content, maxLines: 10)),
                    InkWell(
                      onTap: () async {
                        copyToClip(context, content);
                      },
                      child: Icon(Icons.copy, size: 26, opticalSize: 26),
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

class DropdownCard extends StatefulWidget {
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
  State<DropdownCard> createState() => _DropdownCardState();
}

class _DropdownCardState extends State<DropdownCard> {
  late String selectedValue;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.entries.isNotEmpty ? widget.entries[0] : '';
  }

  @override
  void didUpdateWidget(covariant DropdownCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.entries != oldWidget.entries) {
      setState(() {
        selectedValue = widget.entries.isNotEmpty ? widget.entries[0] : '';
      });
    }
  }

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
            Text(
              widget.title,
              style: TextStyle(color: AppColors.secondaryText),
            ),
            SizedBox(height: 5),
            Row(
              children: [
                widget.isLoading
                    ? Center(child: CircularProgressIndicator())
                    : widget.entries.isEmpty
                    ? Expanded(
                        child: Text(
                          'Nothing found',
                          style: TextStyle(color: AppColors.secondaryText),
                        ),
                      )
                    : Expanded(
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          itemHeight:
                              null, // allow variable-height items for the dividers
                          items: widget.entries.map((entry) {
                            final isLast = entry == widget.entries.last;
                            return DropdownMenuItem<String>(
                              value: entry,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    child: Text(
                                      entry,
                                      softWrap: true,
                                      maxLines: null,
                                    ),
                                  ),
                                  if (!isLast)
                                    Divider(
                                      height: 1,
                                      thickness: 0.5,
                                      color: AppColors.primaryText,
                                    ),
                                ],
                              ),
                            );
                          }).toList(),
                          selectedItemBuilder: (context) {
                            return widget.entries.map((entry) {
                              return SizedBox(
                                width: double.infinity,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(entry, softWrap: true),
                                ),
                              );
                            }).toList();
                          },
                          initialValue: selectedValue,
                          onChanged: (value) {
                            if (value == null || value == selectedValue) {
                              return; // no real change -> skip lookup entirely
                            }

                            setState(() {
                              selectedValue = value;
                            });

                            if (widget.isCopyAll) {
                              widget.onChanged!(selectedValue);
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
                    if (widget.entries.isNotEmpty)
                      copyToClip(context, selectedValue);
                  },
                  child: Icon(Icons.copy, size: 26, opticalSize: 26),
                ),
              ],
            ),

            widget.isCopyAll ? const SizedBox(height: 5) : SizedBox.shrink(),

            widget.isCopyAll
                ? SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        copyToClip(context, widget.entries.join(', '));
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
            SizedBox(height: 7),
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
            SizedBox(height: 7),
            TextRow(title: 'Prateritum: ', content: verbData.prateritum),
            SizedBox(height: 7),
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
            SizedBox(height: 7),
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
          child: Icon(Icons.copy, size: 24, opticalSize: 24),
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

class PronunciationCard extends StatefulWidget {
  final Uint8List? pronunciationBytes;
  final String word;
  const PronunciationCard({
    super.key,
    required this.pronunciationBytes,
    required this.word,
  });

  @override
  State<PronunciationCard> createState() => _PronunciationCardState();
}

class _PronunciationCardState extends State<PronunciationCard> {
  late final AudioPlayer _player;
  bool _isPlaying = false;
  bool _isSaving = false;
  String? _tempFilePath;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _writeTempFile();
  }

  Future<void> _writeTempFile() async {
    if (widget.pronunciationBytes == null) return;

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/pronunciation_temp.ogg');
    await file.writeAsBytes(widget.pronunciationBytes!);
    _tempFilePath = file.path;
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _play() async {
    if (_tempFilePath == null) return;

    setState(() => _isPlaying = true);
    try {
      await _player.setFilePath(_tempFilePath!);
      await _player.play();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not play pronunciation')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPlaying = false);
    }
  }

  Future<void> _stop() async {
    try {
      await _player.stop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not stop playback')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPlaying = false);
    }
  }

  Future<void> _save() async {
    if (widget.pronunciationBytes == null) return;

    setState(() => _isSaving = true);
    try {
      final outputFile = await FilePicker.saveFile(
        bytes: widget.pronunciationBytes!,
        dialogTitle: 'Save pronunciation',
        fileName: 'pronunciation_${widget.word}.ogg',
      );

      if (outputFile != null) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Saved')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save pronunciation')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAvailable = widget.pronunciationBytes != null;

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
            Text(
              'Pronunciation',
              style: TextStyle(color: AppColors.secondaryText),
            ),
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
                    Expanded(
                      child: isAvailable
                          ? Icon(
                              Icons.graphic_eq,
                              size: 32,
                              color: AppColors.secondaryText,
                            )
                          : Text(
                              'Pronunciation not found',
                              style: TextStyle(color: AppColors.secondaryText),
                            ),
                    ),
                    IconButton(
                      icon: _isPlaying
                          ? const Icon(Icons.stop_rounded, size: 26)
                          : const Icon(Icons.play_arrow, size: 26),
                      onPressed: isAvailable
                          ? (_isPlaying ? _stop : _play)
                          : null,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 5),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isAvailable && !_isSaving ? _save : null,
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Download'),
                          SizedBox(width: 5),
                          Icon(Icons.download),
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
