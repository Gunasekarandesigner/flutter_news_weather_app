import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_news_weather_app/provider/weatherprovider.dart';

import 'package:flutter_news_weather_app/ui_screen/homescreen.dart';
import 'package:flutter_news_weather_app/ui_screen/fivedaysforecastdetailscreen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider( 
      providers: [
        ChangeNotifierProvider(create: (context) => WeatherProvider()),
       // ChangeNotifierProvider(create: (context) => NewsProvider()), 
      ],
      child: MaterialApp(
        title: 'Flutter Weather',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            iconTheme: IconThemeData(color: Colors.blue),
            elevation: 0,
          ),
          scaffoldBackgroundColor: Colors.white,
          primaryColor: Colors.amber,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          colorScheme:
              ColorScheme.fromSwatch().copyWith(secondary: Colors.white),
        ),
        
        home: const HomeScreen(),
        onGenerateRoute: (settings) {
          final arguments = settings.arguments;
          if (settings.name == FiveDaysForecastDetail.routeName) {
            return PageRouteBuilder(
              settings: settings,
              pageBuilder: (_, __, ___) => FiveDaysForecastDetail(
                initialIndex: arguments == null ? 0 : arguments as int,
              ),
              transitionsBuilder: (ctx, a, b, c) => CupertinoPageTransition(
                primaryRouteAnimation: a,
                secondaryRouteAnimation: b,
                linearTransition: false,
                child: c,
              ),
            );
          }
         
          return MaterialPageRoute(builder: (_) => const HomeScreen());
        },
      ),
    );
  }
}
