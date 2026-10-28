import 'package:get/get.dart';

import '../../../data/repositories/booking_repository.dart';
import '../../bookings/models/booking_model.dart';

class TicketController extends GetxController {
  final BookingRepository _repository = BookingRepository();

  final Rx<BookingModel?> booking = Rx<BookingModel?>(null);
  final RxString message = ''.obs;
  final RxString resultType = ''.obs;
  final RxBool isLoading = false.obs;

  // Search for a booking using its reference.
  Future<void> validateTicket(String reference) async {
    final String cleanedReference = reference.trim();

    if (cleanedReference.isEmpty) {
      booking.value = null;
      resultType.value = 'invalid';
      message.value = 'Please enter a booking reference.';
      return;
    }

    isLoading.value = true;
    booking.value = null;
    message.value = '';
    resultType.value = '';

    try {
      final BookingModel? result =
          await _repository.getBookingByReference(cleanedReference);

      if (result == null) {
        resultType.value = 'invalid';
        message.value = 'No booking found for this reference.';
      } else if (result.status.toLowerCase() != 'confirmed') {
        booking.value = result;
        resultType.value = 'cancelled';
        message.value = 'This booking is cancelled or no longer valid.';
      } else if (result.isCheckedIn) {
        booking.value = result;
        resultType.value = 'used';
        message.value = 'This ticket has already been used.';
      } else {
        booking.value = result;
        resultType.value = 'valid';
        message.value = 'Ticket is valid. You can check in.';
      }
    } catch (error) {
      resultType.value = 'error';
      message.value = 'Unable to validate the ticket. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  // Check in a valid ticket and save the change in SQLite.
  Future<void> checkInTicket() async {
    final BookingModel? currentBooking = booking.value;

    if (currentBooking == null || resultType.value != 'valid') {
      return;
    }

    isLoading.value = true;

    try {
      final bool success = await _repository.checkInBooking(
        currentBooking.bookingReference,
      );

      if (success) {
        // Reload the booking to confirm the saved database status.
        await validateTicket(currentBooking.bookingReference);

        if (resultType.value == 'used') {
          message.value = 'Check-in successful! This ticket is now used.';
        }
      } else {
        // Another attempt may already have checked in this ticket.
        await validateTicket(currentBooking.bookingReference);
      }
    } catch (error) {
      resultType.value = 'error';
      message.value = 'Check-in failed. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  // Clear the previous validation result.
  void clearValidation() {
    booking.value = null;
    message.value = '';
    resultType.value = '';
  }
}