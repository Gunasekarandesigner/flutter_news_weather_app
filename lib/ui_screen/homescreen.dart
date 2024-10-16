import 'package:flutter/material.dart';
import 'package:flutter_news_weather_app/models/geocode.dart';
import 'package:flutter_news_weather_app/provider/weather_provider.dart';
import 'package:flutter_news_weather_app/theme_data/textstyle.dart';

import 'package:flutter_news_weather_app/ui_screen/locationError.dart';
import 'package:flutter_news_weather_app/widgets/customshimmer.dart';
import 'package:flutter_news_weather_app/widgets/fivedayforecast.dart';
import 'package:flutter_news_weather_app/widgets/newswidget.dart';
import 'package:geolocator/geolocator.dart';
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../theme_data/colors.dart';
import '../widgets/WeatherInfoHeader.dart';

import '../widgets/mainWeatherInfo.dart';

import 'requestError.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FloatingSearchBarController fsc = FloatingSearchBarController();
  bool showNews = true;

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
              PhosphorIconsBold.bell,
              color: Colors.white,
            ),
            onPressed: () {},
          ),
        ],
        leading: IconButton(
          icon: const PhosphorIcon(
            PhosphorIconsBold.user,
            color: Colors.white,
          ),
          onPressed: () {
            // Action when user icon is tapped
          },
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

          return Stack(
            children: [
              ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(12.0).copyWith(
                  top: kToolbarHeight +
                      MediaQuery.viewPaddingOf(context).top +
                      2.0,
                ),
                children: [
                  const WeatherInfoHeader(),
                  const SizedBox(height: 16.0),
                  const MainWeatherInfo(),
                  const SizedBox(height: 16.0),
                  Row(
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
                            color:
                                showNews ? primaryBlue : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Text(
                            "Latest News",
                            style: TextStyle(
                              color: showNews ? Colors.white : Colors.black,
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
                            color:
                                !showNews ? primaryBlue : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Text(
                            "5-Day Forecast",
                            style: TextStyle(
                              color: !showNews ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
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
                                    borderRadius: BorderRadius.circular(12.0),
                                  )
                                : NewsWidget(
                                    newsArticles: weatherProv.articleList)
                            : const FiveDayForecast(),
                      ],
                    ),
                  )
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class CustomSearchBar extends StatefulWidget {
  final FloatingSearchBarController fsc;
  const CustomSearchBar({
    super.key,
    required this.fsc,
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  List<GeoCodeData> _citiesSuggestion = []; // Changed to hold GeoCodeData

  @override
  Widget build(BuildContext context) {
    return FloatingSearchBar(
      controller: widget.fsc,
      hint: 'Search...',
      clearQueryOnClose: false,
      scrollPadding: const EdgeInsets.only(top: 16.0, bottom: 56.0),
      transitionDuration: const Duration(milliseconds: 400),
      borderRadius: BorderRadius.circular(16.0),
      transitionCurve: Curves.easeInOut,
      accentColor: primaryBlue,
      hintStyle: regularText,
      queryStyle: regularText,
      physics: const BouncingScrollPhysics(),
      elevation: 2.0,
      debounceDelay: const Duration(milliseconds: 500),
      onQueryChanged: (query) async {
        if (query.isNotEmpty) {
          List<GeoCodeData> suggestions =
              await Provider.of<WeatherProvider>(context, listen: false)
                  .getLocationSuggestions(query);
          setState(() {
            _citiesSuggestion =
                suggestions; // Update state with new suggestions
          });
        } else {
          setState(() {
            _citiesSuggestion = []; // Clear suggestions if the query is empty
          });
        }
      },
      onSubmitted: (query) async {
        widget.fsc.close();
        await Provider.of<WeatherProvider>(context, listen: false)
            .searchWeather(query);
      },
      transition: CircularFloatingSearchBarTransition(),
      actions: [
        const FloatingSearchBarAction(
          showIfOpened: false,
          child: PhosphorIcon(
            PhosphorIconsBold.magnifyingGlass,
            color: primaryBlue,
          ),
        ),
        FloatingSearchBarAction.icon(
          showIfClosed: false,
          showIfOpened: true,
          icon: const PhosphorIcon(
            PhosphorIconsBold.x,
            color: primaryBlue,
          ),
          onTap: () {
            if (widget.fsc.query.isEmpty) {
              widget.fsc.close();
            } else {
              widget.fsc.clear();
            }
          },
        ),
      ],
      builder: (context, transition) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Material(
            color: Colors.white,
            elevation: 4.0,
            child: ListView.separated(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: _citiesSuggestion.length,
              itemBuilder: (context, index) {
                GeoCodeData data = _citiesSuggestion[index]; // Use GeoCodeData
                return InkWell(
                  onTap: () async {
                    widget.fsc.query =
                        data.name; // Set the query to the selected city's name
                    widget.fsc.close();
                    await Provider.of<WeatherProvider>(context, listen: false)
                        .searchWeather(data
                            .name); // Search weather based on the selected city
                  },
                  child: Container(
                    padding: const EdgeInsets.all(22.0),
                    child: Row(
                      children: [
                        const PhosphorIcon(PhosphorIconsFill.mapPin),
                        const SizedBox(width: 22.0),
                        Text(data.name,
                            style:
                                mediumText), // Use data.name to display the city name
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) => const Divider(
                thickness: 1.0,
                height: 0.0,
              ),
            ),
          ),
        );
      },
    );
  }
}
