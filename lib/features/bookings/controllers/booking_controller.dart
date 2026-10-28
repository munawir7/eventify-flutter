
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/database/app_database.dart';
import '../../events/models/event_model.dart';
import '../../events/models/seat_model.dart';

class BookingController extends GetxController {
  BookingController({
    required this.event,
    required this.selectedSeats,
  });

  final EventModel event;
  final List<SeatModel> selectedSeats;

  final AppDatabase _appDatabase = AppDatabase.instance;

  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  final RxBool isBooking = false.obs;
  final RxDouble discountAmount = 0.0.obs;
  final RxDouble finalAmount = 0.0.obs;

  double get totalAmount {
    return selectedSeats.fold<double>(
      0,
      (total, seat) => total + seat.price,
    );
  }

  @override
  void onInit() {
    super.onInit();
    calculateAmount();
  }

  void calculateAmount() {
    final discount = totalAmount >= 2000 ? totalAmount * 0.10 : 0.0;

    discountAmount.value = discount;
    finalAmount.value = totalAmount - discount;
  }

  bool validateAttendeeDetails() {
    if (formKey.currentState == null) {
      return false;
    }

    return formKey.currentState!.validate();
  }

  // Creates the booking and returns its unique reference.
  Future<String?> confirmBooking() async {
    if (isBooking.value) {
      return null;
    }

    if (!validateAttendeeDetails()) {
      return null;
    }

    if (selectedSeats.isEmpty) {
      Get.snackbar(
        'No seats selected',
        'Please select at least one seat.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }

    if (selectedSeats.length > AppConstants.maxTicketsPerBooking) {
      Get.snackbar(
        'Booking limit reached',
        'You can book a maximum of '
            '${AppConstants.maxTicketsPerBooking} seats.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }

    if (event.id == null) {
      Get.snackbar(
        'Booking failed',
        'The event does not have a valid ID.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }

    isBooking.value = true;

    try {
      final Database db = await _appDatabase.database;

      final bookingReference = await db.transaction<String>((txn) async {
        // Check that the event still exists and has not started.
        final eventRows = await txn.query(
          'events',
          columns: ['event_date'],
          where: 'id = ?',
          whereArgs: [event.id],
          limit: 1,
        );

        if (eventRows.isEmpty) {
          throw Exception('This event no longer exists.');
        }

        final eventDate = DateTime.parse(
          eventRows.first['event_date'] as String,
        );

        if (!eventDate.isAfter(DateTime.now())) {
          throw Exception('This event has already started.');
        }

        // Check that every selected seat is still available.
        for (final seat in selectedSeats) {
          if (seat.id == null) {
            throw Exception('A selected seat has an invalid ID.');
          }

          final seatRows = await txn.query(
            'seats',
            columns: ['event_id', 'status'],
            where: 'id = ?',
            whereArgs: [seat.id],
            limit: 1,
          );

          if (seatRows.isEmpty ||
              seatRows.first['event_id'] != event.id ||
              seatRows.first['status'] != 'available') {
            throw Exception(
              'Seat ${seat.seatNumber} is no longer available.',
            );
          }
        }

        // Generate a unique booking reference.
        final reference =
            'EVT-${const Uuid().v4().replaceAll('-', '').substring(0, 8).toUpperCase()}';

        // Read the latest prices from the database.
        double currentTotal = 0;

        for (final seat in selectedSeats) {
          final seatRows = await txn.query(
            'seats',
            columns: ['price'],
            where: 'id = ? AND event_id = ? AND status = ?',
            whereArgs: [seat.id, event.id, 'available'],
            limit: 1,
          );

          if (seatRows.isEmpty) {
            throw Exception(
              'Seat ${seat.seatNumber} is no longer available.',
            );
          }

          currentTotal +=
              (seatRows.first['price'] as num).toDouble();
        }

        final currentDiscount =
            currentTotal >= 2000 ? currentTotal * 0.10 : 0.0;

        final currentFinalAmount = currentTotal - currentDiscount;

        // Save the booking.
        final bookingId = await txn.insert(
          'bookings',
          {
            'booking_reference': reference,
            'event_id': event.id,
            'attendee_name': nameController.text.trim(),
            'attendee_email': emailController.text.trim(),
            'attendee_phone': phoneController.text.trim(),
            'total_amount': currentTotal,
            'discount_amount': currentDiscount,
            'final_amount': currentFinalAmount,
            'booking_date': DateTime.now().toIso8601String(),
            'status': 'confirmed',
            'checked_in': 0,
          },
          conflictAlgorithm: ConflictAlgorithm.abort,
        );

        // Mark the seats as booked and link them to the booking.
        for (final seat in selectedSeats) {
          final updatedRows = await txn.update(
            'seats',
            {'status': 'booked'},
            where: 'id = ? AND event_id = ? AND status = ?',
            whereArgs: [seat.id, event.id, 'available'],
          );

          if (updatedRows != 1) {
            throw Exception(
              'Seat ${seat.seatNumber} could not be reserved.',
            );
          }

          await txn.insert(
            'booking_seats',
            {
              'booking_id': bookingId,
              'seat_id': seat.id,
            },
            conflictAlgorithm: ConflictAlgorithm.abort,
          );
        }

        // Return the reference, not the internal database ID.
        return reference;
      });

      return bookingReference;
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');

      Get.snackbar(
        'Booking failed',
        message,
        snackPosition: SnackPosition.BOTTOM,
      );

      return null;
    } finally {
      isBooking.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();

    super.onClose();
  }
}
