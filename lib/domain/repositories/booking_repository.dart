import '../entities/booking.dart';
import '../entities/booking_request.dart';

abstract class BookingRepository {
Future<String> createBooking(BookingRequest request);

Future<Booking?> getBookingById(int id);

Future<Booking?> getBookingByReference(String reference);

Future<List<Booking>> getAllBookings();

Future<List<Booking>> getBookingsByEventId(int eventId);

Future<bool> checkInBooking(String reference);

Future<bool> cancelBooking(String reference);
}
