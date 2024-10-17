

class News {
  final String status;
  final int totalResults;
  //final List<Article> results;
  final String? nextPage;

  News({
    required this.status,
    required this.totalResults,
    //required this.results,
     this.nextPage,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      status: json['status']??"",
      totalResults: json['totalResults']??0,
      //results: List<Article>.from(json['results'].map((article) => Article.fromJson(article))),
      nextPage: json['nextPage']??"",
    );
  }
}

class Article {
  final String? articleId;
  final String? title;
  final String? link;
  final List<String>? keywords;
  final List<dynamic>? creator;
  final String? videoUrl;
  final String? description;
  final String? content;
  final DateTime? pubDate;
  final String? pubDateTZ;
  final String? imageUrl;
  final String? sourceId;
  final int? sourcePriority;
  final String? sourceName;
  final String? sourceUrl;
  final String? sourceIcon;
  final String? language;
  final List<String>? country;
  final List<String>? category;
  final bool? duplicate;

  Article({
     this.articleId,
     this.title,
     this.link,
    this.keywords,
    this.creator,
    this.videoUrl,
    this.description,
    this.content,
     this.pubDate,
     this.pubDateTZ,
    this.imageUrl,
     this.sourceId,
     this.sourcePriority,
     this.sourceName,
     this.sourceUrl,
     this.sourceIcon,
     this.language,
     this.country,
     this.category,
     this.duplicate,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      articleId: json['article_id']??"",
      title: json['title']??"",
      link: json['link']??"",
      keywords: json['keywords'] != null ? List<String>.from(json['keywords']) : null,
      creator: json['creator']!= null ? List<dynamic>.from(json['creator']) : null,
      videoUrl: json['video_url']??"",
      description: json['description']??"",
      content: json['content']??"",
     pubDate: json['pubDate'] != null
          ? DateTime.parse(json['pubDate'])
          : null,
      pubDateTZ: json['pubDateTZ']??"",
      imageUrl: json['image_url']??"",
      sourceId: json['source_id']??"",
      sourcePriority: json['source_priority']??0,
      sourceName: json['source_name']??"",
      sourceUrl: json['source_url']??"",
      sourceIcon: json['source_icon']??"",
      language: json['language']??"",
      country: json['country'] != null ? List<String>.from(json['country']) : null,
      category:json['category'] != null ? List<String>.from(json['category']) : null,
      duplicate: json['duplicate'],
    );
  }
}



