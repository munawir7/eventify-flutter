import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../domain/entities/booking.dart';
import '../../domain/entities/booking_request.dart';
import '../../domain/repositories/booking_repository.dart';
import '../../features/bookings/models/booking_model.dart';
import '../database/app_database.dart';

class BookingRepositoryImpl implements BookingRepository {
final AppDatabase _appDatabase;

BookingRepositoryImpl({
AppDatabase? appDatabase,
}) : _appDatabase = appDatabase ?? AppDatabase.instance;



Booking _toEntity(BookingModel model) {
return Booking(
id: model.id,
bookingReference: model.bookingReference,
eventId: model.eventId,
attendeeName: model.attendeeName,
attendeeEmail: model.attendeeEmail,
attendeePhone: model.attendeePhone,
totalAmount: model.totalAmount,
discountAmount: model.discountAmount,
finalAmount: model.finalAmount,
bookingDate: model.bookingDate,
status: model.status,
isCheckedIn: model.isCheckedIn,
);
}

@override
Future<String> createBooking(BookingRequest request) async {
final seatIds = request.seatIds;


if (request.eventId <= 0) {
  throw const AppException('The event does not have a valid ID.');
}

if (seatIds.isEmpty) {
  throw const AppException(
    'Please select at least one seat.',
  );
}

if (seatIds.length > AppConstants.maxTicketsPerBooking) {
  throw AppException(
    'You can book a maximum of '
    '${AppConstants.maxTicketsPerBooking} seats.',
  );
}

if (seatIds.any((id) => id <= 0)) {
  throw const AppException(
    'A selected seat does not have a valid ID.',
  );
}

if (seatIds.toSet().length != seatIds.length) {
  throw const AppException(
    'Duplicate seats were detected. Please select your seats again.',
  );
}

if (request.attendeeName.trim().isEmpty ||
    request.attendeeEmail.trim().isEmpty ||
    request.attendeePhone.trim().isEmpty) {
  throw const AppException(
    'Please provide all attendee details.',
  );
}

final db = await _appDatabase.database;

return db.transaction<String>((txn) async {
  // 1. Verify that the event exists.
  final eventRows = await txn.query(
    'events',
    columns: ['event_date'],
    where: 'id = ?',
    whereArgs: [request.eventId],
    limit: 1,
  );

  if (eventRows.isEmpty) {
    throw const AppException(
      'This event no longer exists.',
    );
  }

  // 2. Validate the event date.
  final rawEventDate = eventRows.first['event_date'];

  if (rawEventDate is! String) {
    throw const AppException(
      'The event date is missing or invalid.',
    );
  }

  final eventDate = DateTime.tryParse(rawEventDate);

  if (eventDate == null) {
    throw const AppException(
      'The event date is invalid.',
    );
  }

  if (!eventDate.isAfter(DateTime.now())) {
    throw const AppException(
      'This event has already started.',
    );
  }

  // 3. Verify the selected seats and read their current prices.
  double currentTotal = 0;

  for (final seatId in seatIds) {
    final seatRows = await txn.query(
      'seats',
      columns: ['event_id', 'seat_number', 'price', 'status'],
      where: 'id = ?',
      whereArgs: [seatId],
      limit: 1,
    );

    if (seatRows.isEmpty ||
        seatRows.first['event_id'] != request.eventId ||
        seatRows.first['status'] != 'available') {
      final seatNumber = seatRows.isEmpty
          ? seatId.toString()
          : seatRows.first['seat_number']?.toString() ?? seatId.toString();

      throw AppException(
        'Seat $seatNumber is no longer available.',
      );
    }

    final rawPrice = seatRows.first['price'];

    if (rawPrice is! num ||
        !rawPrice.isFinite ||
        rawPrice < 0) {
      throw AppException(
        'The price for seat '
        '${seatRows.first['seat_number']} is invalid.',
      );
    }

    currentTotal += rawPrice.toDouble();
  }

  // 4. Calculate the discount using current database prices.
  final currentDiscount = currentTotal >= 2000
      ? currentTotal * 0.10
      : 0.0;

  final currentFinalAmount = currentTotal - currentDiscount;

  // 5. Generate a unique booking reference.
  final reference =
      'EVT-${const Uuid().v4().replaceAll('-', '').substring(0, 8).toUpperCase()}';

  // 6. Insert the booking.
  final bookingId = await txn.insert(
    'bookings',
    {
      'booking_reference': reference,
      'event_id': request.eventId,
      'attendee_name': request.attendeeName.trim(),
      'attendee_email': request.attendeeEmail.trim(),
      'attendee_phone': request.attendeePhone.trim(),
      'total_amount': currentTotal,
      'discount_amount': currentDiscount,
      'final_amount': currentFinalAmount,
      'booking_date': DateTime.now().toIso8601String(),
      'status': 'confirmed',
      'checked_in': 0,
    },
    conflictAlgorithm: ConflictAlgorithm.abort,
  );

  // 7. Reserve each seat and associate it with the booking.
  for (final seatId in seatIds) {
    final updatedRows = await txn.update(
      'seats',
      {'status': 'booked'},
      where: 'id = ? AND event_id = ? AND status = ?',
      whereArgs: [seatId, request.eventId, 'available'],
    );

    if (updatedRows != 1) {
      throw const AppException(
        'A selected seat could not be reserved. Please try again.',
      );
    }

    await txn.insert(
      'booking_seats',
      {
        'booking_id': bookingId,
        'seat_id': seatId,
      },
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  // Return only after the transaction succeeds.
  return reference;
});


}

@override
Future<Booking?> getBookingById(int id) async {
final db = await _appDatabase.database;


final maps = await db.query(
  'bookings',
  where: 'id = ?',
  whereArgs: [id],
  limit: 1,
);

if (maps.isEmpty) {
  return null;
}

return _toEntity(BookingModel.fromMap(maps.first));


}

@override
Future<Booking?> getBookingByReference(String reference) async {
final trimmedReference = reference.trim();


if (trimmedReference.isEmpty) {
  return null;
}

final db = await _appDatabase.database;

final maps = await db.query(
  'bookings',
  where: 'booking_reference = ?',
  whereArgs: [trimmedReference],
  limit: 1,
);

if (maps.isEmpty) {
  return null;
}

return _toEntity(BookingModel.fromMap(maps.first));


}

@override
Future<List<Booking>> getAllBookings() async {
final db = await _appDatabase.database;


final maps = await db.query(
  'bookings',
  orderBy: 'booking_date DESC',
);

return maps
    .map((map) => _toEntity(BookingModel.fromMap(map)))
    .toList();


}

@override
Future<List<Booking>> getBookingsByEventId(int eventId) async {
final db = await _appDatabase.database;


final maps = await db.query(
  'bookings',
  where: 'event_id = ?',
  whereArgs: [eventId],
  orderBy: 'booking_date DESC',
);

return maps
    .map((map) => _toEntity(BookingModel.fromMap(map)))
    .toList();


}

@override
Future<bool> checkInBooking(String reference) async {
final trimmedReference = reference.trim();


if (trimmedReference.isEmpty) {
  return false;
}

final db = await _appDatabase.database;

final updatedRows = await db.update(
  'bookings',
  {'checked_in': 1},
  where: '''
    booking_reference = ?
    AND status = ?
    AND checked_in = 0
  ''',
  whereArgs: [trimmedReference, 'confirmed'],
);

return updatedRows == 1;


}

@override
Future<bool> cancelBooking(String reference) async {
final trimmedReference = reference.trim();


if (trimmedReference.isEmpty) {
  return false;
}

final db = await _appDatabase.database;

return db.transaction<bool>((txn) async {
  final bookings = await txn.query(
    'bookings',
    columns: ['id', 'event_id'],
    where: '''
      booking_reference = ?
      AND status = ?
      AND checked_in = 0
    ''',
    whereArgs: [trimmedReference, 'confirmed'],
    limit: 1,
  );

  if (bookings.isEmpty) {
    return false;
  }

  final bookingId = bookings.first['id'];
  final eventId = bookings.first['event_id'];

  if (bookingId is! int || eventId is! int) {
    throw const FormatException(
      'The booking contains invalid ID values.',
    );
  }

  final events = await txn.query(
    'events',
    columns: ['event_date'],
    where: 'id = ?',
    whereArgs: [eventId],
    limit: 1,
  );

  if (events.isEmpty) {
    return false;
  }

  final eventDateValue = events.first['event_date'];

  if (eventDateValue is! String) {
    throw const FormatException(
      'The event date is missing or invalid.',
    );
  }

  final eventDate = DateTime.tryParse(eventDateValue);

  if (eventDate == null) {
    throw const FormatException(
      'The event date has an invalid format.',
    );
  }

  final cancellationDeadline =
      eventDate.subtract(const Duration(hours: 2));

  if (!DateTime.now().isBefore(cancellationDeadline)) {
    return false;
  }

  final bookingSeats = await txn.query(
    'booking_seats',
    columns: ['seat_id'],
    where: 'booking_id = ?',
    whereArgs: [bookingId],
  );

  for (final bookingSeat in bookingSeats) {
    final seatId = bookingSeat['seat_id'];

    if (seatId is! int) {
      throw const FormatException(
        'A reserved seat has an invalid ID.',
      );
    }

    await txn.update(
      'seats',
      {'status': 'available'},
      where: 'id = ? AND status = ?',
      whereArgs: [seatId, 'booked'],
    );
  }

  final updatedRows = await txn.update(
    'bookings',
    {'status': 'cancelled'},
    where: '''
      id = ?
      AND status = ?
      AND checked_in = 0
    ''',
    whereArgs: [bookingId, 'confirmed'],
  );

  if (updatedRows != 1) {
    throw StateError(
      'The booking could not be cancelled.',
    );
  }

  return true;
});


}
}
