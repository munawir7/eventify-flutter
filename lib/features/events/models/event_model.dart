
import '../../../domain/entities/event.dart';

class EventModel extends Event {
  const EventModel({
    super.id,
    required super.title,
    required super.category,
    required super.description,
    required super.venue,
    required super.eventDate,
    required super.price,
    required super.posterUrl,
    required super.totalSeats,
    super.isFeatured = false,
  });

  factory EventModel.fromEntity(Event event) {
    if (event is EventModel) return event;
    return EventModel(
      id: event.id,
      title: event.title,
      category: event.category,
      description: event.description,
      venue: event.venue,
      eventDate: event.eventDate,
      price: event.price,
      posterUrl: event.posterUrl,
      totalSeats: event.totalSeats,
      isFeatured: event.isFeatured,
    );
  }

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
