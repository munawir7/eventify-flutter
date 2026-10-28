
class BookingModel {
  final int? id;
  final String bookingReference;
  final int eventId;
  final String attendeeName;
  final String attendeeEmail;
  final String attendeePhone;
  final double totalAmount;
  final double discountAmount;
  final double finalAmount;
  final DateTime bookingDate;
  final String status;
  final bool isCheckedIn;

  const BookingModel({
    this.id,
    required this.bookingReference,
    required this.eventId,
    required this.attendeeName,
    required this.attendeeEmail,
    required this.attendeePhone,
    required this.totalAmount,
    required this.discountAmount,
    required this.finalAmount,
    required this.bookingDate,
    this.status = 'confirmed',
    this.isCheckedIn = false,
  });

  // Convert the booking object into a map for SQLite.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'booking_reference': bookingReference,
      'event_id': eventId,
      'attendee_name': attendeeName,
      'attendee_email': attendeeEmail,
      'attendee_phone': attendeePhone,
      'total_amount': totalAmount,
      'discount_amount': discountAmount,
      'final_amount': finalAmount,
      'booking_date': bookingDate.toIso8601String(),
      'status': status,
      'checked_in': isCheckedIn ? 1 : 0,
    };
  }

  // Convert a SQLite map into a BookingModel object.
  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      id: map['id'] as int?,
      bookingReference: map['booking_reference'] as String,
      eventId: map['event_id'] as int,
      attendeeName: map['attendee_name'] as String,
      attendeeEmail: map['attendee_email'] as String,
      attendeePhone: map['attendee_phone'] as String,
      totalAmount: (map['total_amount'] as num).toDouble(),
      discountAmount: (map['discount_amount'] as num).toDouble(),
      finalAmount: (map['final_amount'] as num).toDouble(),
      bookingDate: DateTime.parse(map['booking_date'] as String),
      status: map['status'] as String,
      isCheckedIn: (map['checked_in'] as int) == 1,
    );
  }
}
