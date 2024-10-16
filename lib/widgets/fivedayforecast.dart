import 'package:flutter/material.dart';
import 'package:flutter_news_weather_app/helper/extensions.dart';

import 'package:flutter_news_weather_app/theme_data/textstyle.dart';


import 'package:flutter_news_weather_app/provider/weather_provider.dart';

import 'package:flutter_news_weather_app/widgets/customshimmer.dart';
import 'package:intl/intl.dart';

import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../helper/utils.dart';
import '../theme_data/colors.dart';
import '../ui_screen/fivedaysforecastdetailscreen.dart';


class FiveDayForecast extends StatelessWidget {
  const FiveDayForecast({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              const PhosphorIcon(PhosphorIconsRegular.calendar),
              const SizedBox(width: 4.0),
              const Text(
                '5-Day Forecast',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Consumer<WeatherProvider>(
                builder: (context, weatherProv, _) {
                  
                  return TextButton(
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      textStyle: mediumText.copyWith(fontSize: 14.0),
                      foregroundColor: primaryBlue,
                    ),
                    onPressed: weatherProv.isLoading
                        ? (){
                           CustomShimmer(
                    height: 150.0,
                    borderRadius: BorderRadius.circular(12.0),
                  );
                        }
                        : () {
                            Navigator.of(context)
                                .pushNamed(FiveDaysForecastDetail.routeName);
                          },
                    child: const Text('more details ▶'),
                  );
                },
              )
            ],
          ),
        ),
        const SizedBox(height: 8.0),
        SizedBox(
          child: Consumer<WeatherProvider>(
            builder: (context, weatherProv, _) {
              if (weatherProv.isLoading) {
                return ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: 5,
                  itemBuilder: (context, index) => CustomShimmer(
                    height: 82.0,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                );
              }
              return ListView.builder(
  shrinkWrap: true,
  padding: EdgeInsets.zero,
  physics: const NeverScrollableScrollPhysics(),
  itemCount: weatherProv.dailyWeather.length > 5 ? 5 : weatherProv.dailyWeather.length,
  itemBuilder: (context, index) {
    var weather = weatherProv.dailyWeather[index];
    
    // Calculate the day for each forecast entry
    String displayDay = index == 0 
        ? 'Today' 
        : DateFormat('EEEE').format(weather.date.add( Duration(days: index)));

    return Material(
      borderRadius: BorderRadius.circular(12.0),
      color: index.isEven ? backgroundWhite : Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(12.0),
        onTap: () {
          Navigator.of(context).pushNamed(
            FiveDaysForecastDetail.routeName,
            arguments: index,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: MediaQuery.sizeOf(context).width / 4,
                child: FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: Text(
                    displayDay,  // Use the calculated displayDay here
                    style: semiboldText,
                    maxLines: 1,
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 36.0,
                    width: 36.0,
                    child: Image.asset(
                      getWeatherImage(weather.weatherCategory),
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    weather.weatherCategory,
                    style: lightText,
                  ),
                ],
              ),
              SizedBox(
                width: MediaQuery.sizeOf(context).width / 5,
                child: FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: Text(
                    weatherProv.isCelsius
                        ? '${weather.temp.toStringAsFixed(0)}°/${weather.tempMin.toStringAsFixed(0)}°'
                        : '${weather.temp.toFahrenheit().toStringAsFixed(0)}°/${weather.tempMin.toFahrenheit().toStringAsFixed(0)}°',
                    style: semiboldText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  },
);

},
          ),
        ),
      ],
    );
  }
}
