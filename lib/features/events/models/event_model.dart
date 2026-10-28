
class EventModel {
  final int? id;
  final String title;
  final String category;
  final String description;
  final String venue;
  final DateTime eventDate;
  final double price;
  final String posterUrl;
  final int totalSeats;
  final bool isFeatured;

  const EventModel({
    this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.venue,
    required this.eventDate,
    required this.price,
    required this.posterUrl,
    required this.totalSeats,
    this.isFeatured = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'description': description,
      'venue': venue,
      'event_date': eventDate.toIso8601String(),
      'price': price,
      'poster_url': posterUrl,
      'total_seats': totalSeats,
      'is_featured': isFeatured ? 1 : 0,
    };
  }

  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      category: map['category'] as String,
      description: map['description'] as String,
      venue: map['venue'] as String,
      eventDate: DateTime.parse(map['event_date'] as String),
      price: (map['price'] as num).toDouble(),
      posterUrl: map['poster_url'] as String,
      totalSeats: map['total_seats'] as int,
      isFeatured: (map['is_featured'] as int) == 1,
    );
  }
}
