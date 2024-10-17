import 'package:flutter/material.dart';
import 'package:flutter_news_weather_app/provider/weatherprovider.dart';
import 'package:flutter_news_weather_app/ui_screen/locationerror.dart';
import 'package:flutter_news_weather_app/ui_screen/newssettingsscreen.dart';
import 'package:flutter_news_weather_app/ui_screen/requesterror.dart';
import 'package:flutter_news_weather_app/widgets/customshimmer.dart';
import 'package:flutter_news_weather_app/widgets/fivedayforecast.dart';
import 'package:flutter_news_weather_app/widgets/mainweatherinfo.dart';
import 'package:flutter_news_weather_app/widgets/weatherinfoheader.dart';
import 'package:geolocator/geolocator.dart';
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../widgets/newswidget.dart';

enum SelectedCategoryEnum { category }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FloatingSearchBarController fsc = FloatingSearchBarController();
  bool showNews = true;
  String initialValue = "";

  List<String> categories = [];
  List<String> allCategories = [];

  @override
  void initState() {
    super.initState();
    requestWeather();
  }

  Future<void> requestWeather() async {
    await Provider.of<WeatherProvider>(context, listen: false)
        .getWeatherData(context);
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      elevation: 0,
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
      title: const Center(
        child: Text(
          'Aetram News & Weather Reports',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22.0,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const PhosphorIcon(
            PhosphorIconsBold.gear,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NewsSettingsScreen(
                  data: (p0, p1) {
                    initialValue = p0!;
                    categories = p1;
                  },
                  initialCategories: categories,
                  initialLanguage: initialValue,
                ),
              ),
            );
          },
        ),
      ],
      leading: IconButton(
        icon: const PhosphorIcon(
          PhosphorIconsBold.user,
          color: Colors.white,
        ),
        onPressed: () {},
      ),
      centerTitle: true,
    ),
    body: Consumer<WeatherProvider>(
      builder: (context, weatherProv, _) {
        if (!weatherProv.isLoading && !weatherProv.isLocationServiceEnabled) {
          return const LocationServiceErrorDisplay();
        }
        if (!weatherProv.isLoading &&
            weatherProv.locationPermission != LocationPermission.always &&
            weatherProv.locationPermission != LocationPermission.whileInUse) {
          return const LocationPermissionErrorDisplay();
        }
        if (weatherProv.isRequestError) return const RequestErrorDisplay();
        if (weatherProv.isSearchError) return SearchErrorDisplay(fsc: fsc);

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(12.0).copyWith(
                  top: kToolbarHeight +
                      MediaQuery.viewPaddingOf(context).top +
                      1.0,
                ),
                child: Column(
                  children: [
                    const WeatherInfoHeader(),
                    const SizedBox(height: 16.0),
                    const MainWeatherInfo(),
                    const SizedBox(height: 16.0),
                    Divider(color: Colors.grey.shade500),
                    const SizedBox(height: 16.0),
                    weatherProv.isLoading
                        ? CustomShimmer(
                            height: 48.0,
                            width: double.infinity,
                            borderRadius: BorderRadius.circular(8.0),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    showNews = true;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12.0, horizontal: 24.0),
                                  decoration: BoxDecoration(
                                    gradient: showNews
                                        ? LinearGradient(
                                            colors: [
                                              Colors.black,
                                              Colors.amber.shade400,
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          )
                                        : null,
                                    color: showNews
                                        ? null
                                        : Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Text(
                                    "Latest News",
                                    style: TextStyle(
                                      color: showNews
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    showNews = false;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12.0, horizontal: 24.0),
                                  decoration: BoxDecoration(
                                    gradient: !showNews
                                        ? LinearGradient(
                                            colors: [
                                              Colors.black,
                                              Colors.amber.shade400,
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          )
                                        : null,
                                    color: !showNews
                                        ? null
                                        : Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Text(
                                    "5-Day Forecast",
                                    style: TextStyle(
                                      color: !showNews
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                    const SizedBox(height: 16.0),
                    Divider(color: Colors.grey.shade500),
                    const SizedBox(height: 16.0),
                    weatherProv.isLoading
                        ? CustomShimmer(
                            height: 60.0,
                            width: double.infinity,
                            borderRadius: BorderRadius.circular(8.0),
                          )
                        : Wrap(
                            spacing: 8.0,
                            runSpacing: 4.0,
                            children: [
                           initialValue.isNotEmpty?   FilterChip(
                                label: Text('Language: $initialValue'),
                                selected: true,
                                onSelected: (isSelected) {},
                                selectedColor: Colors.grey.shade600,
                                backgroundColor: Colors.grey.shade200,
                                labelStyle: const TextStyle(
                                  color: Colors.white,
                                ),
                              ):const SizedBox(),
                              ...categories.map((category) {
                                return FilterChip(
                                  label: Text(category),
                                  selected: true,
                                  onSelected: (isSelected) {},
                                  selectedColor: Colors.grey.shade600,
                                  backgroundColor: Colors.grey.shade200,
                                  labelStyle: const TextStyle(
                                    color: Colors.white,
                                  ),
                                );
                              }),
                            ],
                          ),
                    const SizedBox(height: 18.0),
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          showNews
                              ? weatherProv.isLoading
                                  ? CustomShimmer(
                                      height: 250.0,
                                      width: double.infinity,
                                      borderRadius:
                                          BorderRadius.circular(12.0),
                                    )
                                  : const NewsWidget()
                              : const FiveDayForecast(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black,
                    Colors.amber.shade400,
                  ],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
              ),
              height: 60.0,
              child: const Center(
                child: Text(
                  '',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}
}
