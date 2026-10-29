class Booking {
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

const Booking({
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
}
