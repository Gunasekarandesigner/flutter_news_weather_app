import 'package:flutter/material.dart';
import 'package:flutter_news_weather_app/provider/weatherprovider.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsWidget extends StatelessWidget {
 // Callback to send data
  

  const NewsWidget({super.key,});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Latest News',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16.0),
      
        Consumer<WeatherProvider>(
          builder: (context, weatherProvider, child) {
            if (weatherProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (weatherProvider.isRequestError) {
              return const Center(child: Text('Failed to load news data.'));
            } else if (weatherProvider.articleList.isEmpty) {
              return  Column(
                children: [
                  SvgPicture.asset("assets/images/empty-box.svg",width: 400,),
                  const Center(child: Text('No news articles available.',)),
                ],
              );
            }else{
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: weatherProvider.articleList.length,
              itemBuilder: (context, index) {
                final article = weatherProvider.articleList[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Card(
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12.0)),
                          child: article.imageUrl != null
                              ? Image.network(
                                  article.imageUrl!,
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _placeholderImage();
                                  },
                                )
                              : _placeholderImage(),
                        ),
                        ListTile(
                          contentPadding: const EdgeInsets.all(16.0),
                          title: Text(
                            article.title ?? 'No Title',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8.0),
                              Text(
                                article.description ?? 'No Description',
                                style: const TextStyle(fontSize: 14),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8.0),
                             Text(
          article.pubDate != null 
            ? DateFormat('yyyy-MM-dd').format(article.pubDate!) 
            : 'No Date',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
                            ],
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios,
                              size: 16, color: Colors.grey),
                          onTap: () {
                            _launchURL(article.link);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
            }
          },
        ),
      ],
    );
  }

  // Placeholder widget for missing images
  Widget _placeholderImage() {
    return Image.asset(
      'assets/images/download.jpg',
      height: 200,
      width: double.infinity,
      fit: BoxFit.cover,
    );
  }

  void _launchURL(String? url) async {
    if (url != null && await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      debugPrint('Could not launch $url');
    }
  }
}
