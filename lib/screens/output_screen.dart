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
              child: Padding(
                padding: EdgeInsetsGeometry.directional(
                  start: 20,
                  end: 10,
                  bottom: 10,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Hause',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(onPressed: () {}, icon: Icon(Icons.copy)),
                      ],
                    ),
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
                            'Der',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
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
                            'Hauser/Hauser',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Icon(Icons.copy, size: 18),
                        SizedBox(width: 5),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Card(
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
                      'Translations',
                      style: TextStyle(color: AppColors.secondaryText),
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownMenu<String>(
                            width: double.infinity,
                            dropdownMenuEntries: translations
                                .map(
                                  (translation) => DropdownMenuEntry<String>(
                                    value: translation,
                                    label: translation,
                                  ),
                                )
                                .toList(),
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

                    const SizedBox(height: 5),

                    SizedBox(
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
                    ),
                  ],
                ),
              ),
            ),
            Card(
              //TODO: make this and translation cards be a separate widget that requires a title and a list to fill out the entries, bool if copy all is needed
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
                      'Definitions',
                      style: TextStyle(color: AppColors.secondaryText),
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownMenu<String>(
                            width: double.infinity,
                            dropdownMenuEntries: translations
                                .map(
                                  (translation) => DropdownMenuEntry<String>(
                                    value: translation,
                                    label: translation,
                                  ),
                                )
                                .toList(),
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
                  ],
                ),
              ),
            ),
            Card(
              //TODO: make all the following cards be a separate widget that requires a title and content
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
                      'Your sentence (German)',
                      style: TextStyle(color: AppColors.secondaryText),
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        Expanded(child: Text('Ich gehe nach Hause.')),
                        Icon(Icons.copy, size: 18),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            TextCard(title: 'Your sentence (Translation)', content: 'Im going home.'),
            Card(
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
                      'Your sentence (with blank)',
                      style: TextStyle(color: AppColors.secondaryText),
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        Expanded(child: Text('Ich gehe nach ____')),
                        Icon(Icons.copy, size: 18),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Card(
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
                      'Another sentence (German)',
                      style: TextStyle(color: AppColors.secondaryText),
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        Expanded(child: Text('Das Haus ist gross.')),
                        Icon(Icons.copy, size: 18),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Card(
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
                      'Another sentence (Translation)',
                      style: TextStyle(color: AppColors.secondaryText),
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        Expanded(child: Text('The house is big')),
                        Icon(Icons.copy, size: 18),
                      ],
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
