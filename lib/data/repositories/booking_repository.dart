
import 'package:sqflite/sqflite.dart';

import '../database/app_database.dart';
import '../../features/bookings/models/booking_model.dart';

class BookingRepository {
  final AppDatabase _appDatabase = AppDatabase.instance;

  // Save a new booking and return its database ID.
  Future<int> createBooking(BookingModel booking) async {
    final Database db = await _appDatabase.database;

    return db.insert(
      'bookings',
      booking.toMap()..remove('id'),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  // Retrieve a booking by its database ID.
  Future<BookingModel?> getBookingById(int id) async {
    final Database db = await _appDatabase.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'bookings',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return BookingModel.fromMap(maps.first);
  }

  // Retrieve a booking by its unique reference.
  Future<BookingModel?> getBookingByReference(
    String reference,
  ) async {
    final Database db = await _appDatabase.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'bookings',
      where: 'booking_reference = ?',
      whereArgs: [reference],
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return BookingModel.fromMap(maps.first);
  }

  // Retrieve all bookings, newest first.
  Future<List<BookingModel>> getAllBookings() async {
    final Database db = await _appDatabase.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'bookings',
      orderBy: 'booking_date DESC',
    );

    return maps.map(BookingModel.fromMap).toList();
  }

  // Retrieve bookings belonging to a particular event.
  Future<List<BookingModel>> getBookingsByEventId(
    int eventId,
  ) async {
    final Database db = await _appDatabase.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'bookings',
      where: 'event_id = ?',
      whereArgs: [eventId],
      orderBy: 'booking_date DESC',
    );

    return maps.map(BookingModel.fromMap).toList();
  }
    // Mark a confirmed booking as checked in.
  // Returns true if the ticket was successfully checked in.
  // Returns false if it is invalid, cancelled, or already used.
  Future<bool> checkInBooking(String reference) async {
    final Database db = await _appDatabase.database;

    final int updatedRows = await db.update(
      'bookings',
      {
        'checked_in': 1,
      },
      where: '''
        booking_reference = ?
        AND status = ?
        AND checked_in = 0
      ''',
      whereArgs: [
        reference.trim(),
        'confirmed',
      ],
    );

    return updatedRows == 1;
  }

// Cancel a confirmed booking and release its reserved seats.
// Cancellation is allowed only until 2 hours before the event.
Future<bool> cancelBooking(String reference) async {
  final Database db = await _appDatabase.database;

  return db.transaction<bool>((txn) async {
    // Find the confirmed booking that has not been checked in.
    final bookings = await txn.query(
      'bookings',
      columns: ['id', 'event_id'],
      where: '''
        booking_reference = ?
        AND status = ?
        AND checked_in = 0
      ''',
      whereArgs: [
        reference.trim(),
        'confirmed',
      ],
      limit: 1,
    );

    // Stop if the booking cannot be cancelled.
    if (bookings.isEmpty) {
      return false;
    }

    final int bookingId = bookings.first['id'] as int;
    final int eventId = bookings.first['event_id'] as int;

    // Find the event date and time.
    final events = await txn.query(
      'events',
      columns: ['event_date'],
      where: 'id = ?',
      whereArgs: [eventId],
      limit: 1,
    );

    // Stop if the event cannot be found.
    if (events.isEmpty) {
      return false;
    }

    final String eventDateString =
        events.first['event_date'] as String;

    final DateTime eventDate = DateTime.parse(eventDateString);
    final DateTime now = DateTime.now();

    // Cancellation deadline: 2 hours before the event.
    final DateTime cancellationDeadline =
        eventDate.subtract(const Duration(hours: 2));

    // Reject cancellation at or after the deadline.
    if (!now.isBefore(cancellationDeadline)) {
      return false;
    }

    // Find seats reserved by this booking.
    final bookingSeats = await txn.query(
      'booking_seats',
      columns: ['seat_id'],
      where: 'booking_id = ?',
      whereArgs: [bookingId],
    );

    // Release only the seats belonging to this booking.
    for (final bookingSeat in bookingSeats) {
      final int seatId = bookingSeat['seat_id'] as int;

      await txn.update(
        'seats',
        {'status': 'available'},
        where: 'id = ? AND status = ?',
        whereArgs: [seatId, 'booked'],
      );
    }

    // Mark the booking as cancelled.
    final int updatedRows = await txn.update(
      'bookings',
      {'status': 'cancelled'},
      where: '''
        id = ?
        AND status = ?
        AND checked_in = 0
      ''',
      whereArgs: [
        bookingId,
        'confirmed',
      ],
    );

    return updatedRows == 1;
  });
}

}
