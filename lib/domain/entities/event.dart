class Event {
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

  const Event({
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
}