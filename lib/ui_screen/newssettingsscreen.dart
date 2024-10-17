import 'package:flutter/material.dart';
import 'package:flutter_news_weather_app/provider/weatherprovider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

class NewsSettingsScreen extends StatefulWidget {
  final Function(String?, List<String>) data;
  final String? initialLanguage;
  final List<String> initialCategories;

  const NewsSettingsScreen({
    super.key,
    required this.data,
    this.initialLanguage,
    required this.initialCategories,
  });

  @override
  NewsSettingsScreenState createState() => NewsSettingsScreenState();
}

class NewsSettingsScreenState extends State<NewsSettingsScreen> {
  String? selectedLanguage;
  List<String> selectedCategories = [];

  final List<String> languages = [
    'English',
    'Tamil',
    'Malayalam',
  ];

  final List<String> categories = [
    'Business',
    'Entertainment',
    'Health',
    'Science',
    'Sports',
    'Technology',
    'Lifestyle',
    'Crime',
    'Domestic',
    'Tourism',
    'Politics',
    'Education',
    'World',
    'Others'
  ];

  @override
  void initState() {
    super.initState();

    selectedLanguage = widget.initialLanguage;
    selectedCategories = List<String>.from(widget.initialCategories);
  }

  void _fetchNews() {
    if (selectedLanguage != null && selectedCategories.isNotEmpty) {
      widget.data(selectedLanguage, selectedCategories);

      String shortName = selectedLanguage!.substring(0, 2).toLowerCase();

      Provider.of<WeatherProvider>(context, listen: false)
          .fetchNewsBasedOnWeather(shortName, selectedCategories);

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select a language and categories')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const PhosphorIcon(
            PhosphorIconsBold.arrowCircleLeft,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black,
                Colors.amber.shade400,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20.0),
              bottomRight: Radius.circular(20.0),
            ),
          ),
        ),
        title: const Text(
          'News Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22.0,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: _buildSettings(),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black,
                    Colors.amber.shade400,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(0),
              ),
              child: FilledButton(
                style: ButtonStyle(
                  backgroundColor:
                      const WidgetStatePropertyAll(Colors.transparent),
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                  ),
                ),
                onPressed: _fetchNews,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    'Fetch News',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Language',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        ...languages.map((language) {
          final bool isSelected = selectedLanguage == language;
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [
                        Colors.black,
                        Colors.amber.shade400,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isSelected ? null : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: RadioListTile<String>(
              title: Text(
                language,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                ),
              ),
              value: language,
              groupValue: selectedLanguage,
              onChanged: (value) {
                setState(() {
                  selectedLanguage = value;
                });
              },
              activeColor: Colors.transparent,
            ),
          );
        }),
        const SizedBox(height: 16),
        const Text(
          'Select Categories (up to 5)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        ...categories.map((category) {
          final bool isSelected = selectedCategories.contains(category);

          return isSelected
              ? Container(
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black,
                        Colors.amber.shade400,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: CheckboxListTile(
                    title: Text(
                      category,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    value: isSelected,
                    onChanged: (bool? selected) {
                      setState(() {
                        selectedCategories.remove(category);
                      });
                    },
                    activeColor: Colors.transparent,
                    checkColor: Colors.white,
                  ),
                )
              : Container(
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: ListTile(
                    title: Text(
                      category,
                      style: const TextStyle(color: Colors.black),
                    ),
                    onTap: () {
                      setState(() {
                        if (selectedCategories.length < 5) {
                          selectedCategories.add(category);
                        }
                      });
                    },
                  ),
                );
        }),
      ],
    );
  }
}
