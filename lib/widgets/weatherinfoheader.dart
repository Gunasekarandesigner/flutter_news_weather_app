import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_news_weather_app/provider/weatherprovider.dart';
import 'package:flutter_news_weather_app/theme_data/textstyle.dart';
import 'package:flutter_news_weather_app/widgets/customshimmer.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class WeatherInfoHeader extends StatelessWidget {
  static const double boxWidth = 52.0;
  static const double boxHeight = 40.0;

  const WeatherInfoHeader({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, weatherProv, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            weatherProv.isLoading
                ? Expanded(
                    child: CustomShimmer(
                      height: 48.0,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  )
                : Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FittedBox(
                          child: RichText(
                            textAlign: TextAlign.start,
                            text: TextSpan(
                              text: '${weatherProv.weather?.city ?? ""}, ',
                              style: semiboldText,
                              children: [
                                TextSpan(
                                  text: Country.tryParse(
                                          weatherProv.weather?.countryCode ??
                                              "")
                                      ?.name,
                                  style: regularText.copyWith(fontSize: 18.0),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        FittedBox(
                          child: Text(
                            DateFormat('EEEE MMM dd, y  hh:mm a')
                                .format(DateTime.now()),
                            style: regularText.copyWith(
                                color: Colors.grey.shade700),
                          ),
                        )
                      ],
                    ),
                  ),
            const SizedBox(width: 8.0),
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Container(
                padding: const EdgeInsets.all(4.0),
                color: Colors.grey.shade200,
                child: Stack(
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 150),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: weatherProv.isCelsius
                                ? const Offset(1.0, 0.0)
                                : const Offset(-1.0, 0.0),
                            end: const Offset(0.0, 0.0),
                          ).animate(animation),
                          child: child,
                        );
                      },
                      child: weatherProv.isCelsius
                          ? GestureDetector(
                              key: const ValueKey<int>(0),
                              child: Row(
                                children: [
                                  Container(
                                    height: boxHeight,
                                    width: boxWidth,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8.0),
                                      color: weatherProv.isLoading
                                          ? Colors.grey
                                          : Colors.grey.shade600,
                                    ),
                                  ),
                                  Container(
                                    height: boxHeight,
                                    width: boxWidth,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8.0),
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () => weatherProv.isLoading
                                  ? null
                                  : weatherProv.switchTempUnit(),
                            )
                          : GestureDetector(
                              key: const ValueKey<int>(1),
                              child: Row(
                                children: [
                                  Container(
                                    height: boxHeight,
                                    width: boxWidth,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8.0),
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                  Container(
                                    height: boxHeight,
                                    width: boxWidth,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8.0),
                                      color: weatherProv.isLoading
                                          ? Colors.grey
                                          : Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () => weatherProv.switchTempUnit(),
                            ),
                    ),
                    IgnorePointer(
                      child: Row(
                        children: [
                          Container(
                            height: boxHeight,
                            width: boxWidth,
                            alignment: Alignment.center,
                            child: Text(
                              '°C',
                              style: semiboldText.copyWith(
                                fontSize: 16,
                                color: weatherProv.isCelsius
                                    ? Colors.white
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ),
                          Container(
                            height: boxHeight,
                            width: boxWidth,
                            alignment: Alignment.center,
                            child: Text(
                              '°F',
                              style: semiboldText.copyWith(
                                fontSize: 16,
                                color: weatherProv.isCelsius
                                    ? Colors.grey.shade600
                                    : Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        );
      },
    );
  }
}
