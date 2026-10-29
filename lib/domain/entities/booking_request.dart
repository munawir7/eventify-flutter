class BookingRequest {
final int eventId;
final List<int> seatIds;
final String attendeeName;
final String attendeeEmail;
final String attendeePhone;

const BookingRequest({
required this.eventId,
required this.seatIds,
required this.attendeeName,
required this.attendeeEmail,
required this.attendeePhone,
});
}
