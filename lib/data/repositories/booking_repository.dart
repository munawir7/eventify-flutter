
import 'dart:developer' as developer;

import 'package:sqflite/sqflite.dart';

import '../database/app_database.dart';
import '../../features/bookings/models/booking_model.dart';

class BookingRepository {
  final AppDatabase _appDatabase = AppDatabase.instance;

  /// Logs repository errors for debugging.
  void _logError(
    String operation,
    Object error,
    StackTrace stackTrace,
  ) {
    developer.log(
      'BookingRepository: $operation failed.',
      name: 'BookingRepository',
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Save a new booking and return its database ID.
  Future<int> createBooking(BookingModel booking) async {
    try {
      final Database db = await _appDatabase.database;

      return await db.insert(
        'bookings',
        booking.toMap()..remove('id'),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    } on DatabaseException catch (error, stackTrace) {
      _logError('createBooking - database error', error, stackTrace);
      rethrow;
    } catch (error, stackTrace) {
      _logError('createBooking', error, stackTrace);
      rethrow;
    }
  }

  /// Retrieve a booking by its database ID.
  Future<BookingModel?> getBookingById(int id) async {
    try {
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
    } on DatabaseException catch (error, stackTrace) {
      _logError('getBookingById - database error', error, stackTrace);
      rethrow;
    } catch (error, stackTrace) {
      _logError('getBookingById', error, stackTrace);
      rethrow;
    }
  }

  /// Retrieve a booking by its unique reference.
  Future<BookingModel?> getBookingByReference(
    String reference,
  ) async {
    try {
      final String trimmedReference = reference.trim();

      if (trimmedReference.isEmpty) {
        return null;
      }

      final Database db = await _appDatabase.database;

      final List<Map<String, dynamic>> maps = await db.query(
        'bookings',
        where: 'booking_reference = ?',
        whereArgs: [trimmedReference],
        limit: 1,
      );

      if (maps.isEmpty) {
        return null;
      }

      return BookingModel.fromMap(maps.first);
    } on DatabaseException catch (error, stackTrace) {
      _logError(
        'getBookingByReference - database error',
        error,
        stackTrace,
      );
      rethrow;
    } catch (error, stackTrace) {
      _logError('getBookingByReference', error, stackTrace);
      rethrow;
    }
  }

  /// Retrieve all bookings, newest first.
  Future<List<BookingModel>> getAllBookings() async {
    try {
      final Database db = await _appDatabase.database;

      final List<Map<String, dynamic>> maps = await db.query(
        'bookings',
        orderBy: 'booking_date DESC',
      );

      return maps.map(BookingModel.fromMap).toList();
    } on DatabaseException catch (error, stackTrace) {
      _logError('getAllBookings - database error', error, stackTrace);
      rethrow;
    } catch (error, stackTrace) {
      _logError('getAllBookings', error, stackTrace);
      rethrow;
    }
  }

  /// Retrieve bookings belonging to a particular event.
  Future<List<BookingModel>> getBookingsByEventId(
    int eventId,
  ) async {
    try {
      final Database db = await _appDatabase.database;

      final List<Map<String, dynamic>> maps = await db.query(
        'bookings',
        where: 'event_id = ?',
        whereArgs: [eventId],
        orderBy: 'booking_date DESC',
      );

      return maps.map(BookingModel.fromMap).toList();
    } on DatabaseException catch (error, stackTrace) {
      _logError(
        'getBookingsByEventId - database error',
        error,
        stackTrace,
      );
      rethrow;
    } catch (error, stackTrace) {
      _logError('getBookingsByEventId', error, stackTrace);
      rethrow;
    }
  }

  /// Mark a confirmed booking as checked in.
  ///
  /// Returns true if the ticket was successfully checked in.
  /// Returns false if it is invalid, cancelled, or already used.
  Future<bool> checkInBooking(String reference) async {
    try {
      final String trimmedReference = reference.trim();

      if (trimmedReference.isEmpty) {
        return false;
      }

      final Database db = await _appDatabase.database;

      final int updatedRows = await db.update(
        'bookings',
        {'checked_in': 1},
        where: '''
          booking_reference = ?
          AND status = ?
          AND checked_in = 0
        ''',
        whereArgs: [
          trimmedReference,
          'confirmed',
        ],
      );

      return updatedRows == 1;
    } on DatabaseException catch (error, stackTrace) {
      _logError(
        'checkInBooking - database error',
        error,
        stackTrace,
      );
      rethrow;
    } catch (error, stackTrace) {
      _logError('checkInBooking', error, stackTrace);
      rethrow;
    }
  }

  /// Cancel a confirmed booking and release its reserved seats.
  ///
  /// Cancellation is allowed only before the event's two-hour deadline.
  ///
  /// Returns false when the booking is invalid, already checked in,
  /// already cancelled, or past the cancellation deadline.
  Future<bool> cancelBooking(String reference) async {
    try {
      final String trimmedReference = reference.trim();

      if (trimmedReference.isEmpty) {
        return false;
      }

      final Database db = await _appDatabase.database;

      return await db.transaction<bool>((txn) async {
        // Find the confirmed booking that has not been checked in.
        final List<Map<String, Object?>> bookings = await txn.query(
          'bookings',
          columns: ['id', 'event_id'],
          where: '''
            booking_reference = ?
            AND status = ?
            AND checked_in = 0
          ''',
          whereArgs: [
            trimmedReference,
            'confirmed',
          ],
          limit: 1,
        );

        // Stop if the booking cannot be cancelled.
        if (bookings.isEmpty) {
          return false;
        }

        final Object? bookingIdValue = bookings.first['id'];
        final Object? eventIdValue = bookings.first['event_id'];

        if (bookingIdValue is! int || eventIdValue is! int) {
          throw const FormatException(
            'The booking contains invalid ID values.',
          );
        }

        final int bookingId = bookingIdValue;
        final int eventId = eventIdValue;

        // Find the event date and time.
        final List<Map<String, Object?>> events = await txn.query(
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

        final Object? eventDateValue = events.first['event_date'];

        if (eventDateValue is! String) {
          throw const FormatException(
            'The event date is missing or invalid.',
          );
        }

        // Parse the date safely so malformed data cannot cancel a booking.
        final DateTime? eventDate = DateTime.tryParse(eventDateValue);

        if (eventDate == null) {
          throw const FormatException(
            'The event date has an invalid format.',
          );
        }

        final DateTime now = DateTime.now();

        // Cancellation deadline: two hours before the event.
        final DateTime cancellationDeadline =
            eventDate.subtract(const Duration(hours: 2));

        // Reject cancellation at or after the deadline.
        if (!now.isBefore(cancellationDeadline)) {
          return false;
        }

        // Find seats reserved by this booking.
        final List<Map<String, Object?>> bookingSeats =
            await txn.query(
          'booking_seats',
          columns: ['seat_id'],
          where: 'booking_id = ?',
          whereArgs: [bookingId],
        );

        // Release only the seats belonging to this booking.
        for (final Map<String, Object?> bookingSeat in bookingSeats) {
          final Object? seatIdValue = bookingSeat['seat_id'];

          if (seatIdValue is! int) {
            throw const FormatException(
              'A reserved seat has an invalid ID.',
            );
          }

          await txn.update(
            'seats',
            {'status': 'available'},
            where: 'id = ? AND status = ?',
            whereArgs: [
              seatIdValue,
              'booked',
            ],
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

        // Throwing here rolls back the transaction if the update failed.
        if (updatedRows != 1) {
          if (updatedRows != 1) {
  throw StateError(
    'The booking could not be cancelled.',
  );
}
        }

        return true;
      });
    } on DatabaseException catch (error, stackTrace) {
      _logError(
        'cancelBooking - database error',
        error,
        stackTrace,
      );
      rethrow;
    } on FormatException catch (error, stackTrace) {
      _logError(
        'cancelBooking - invalid data',
        error,
        stackTrace,
      );
      rethrow;
    } catch (error, stackTrace) {
      _logError('cancelBooking', error, stackTrace);
      rethrow;
    }
  }
}

