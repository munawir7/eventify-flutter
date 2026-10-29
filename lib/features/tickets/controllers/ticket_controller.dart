
import 'dart:developer' as developer;

import 'package:get/get.dart';

import '../../../data/repositories/booking_repository_impl.dart';
import '../../../domain/entities/booking.dart';
import '../../../domain/repositories/booking_repository.dart';
import '../../../domain/usecases/bookings/check_in_booking_usecases.dart';
import '../../../domain/usecases/bookings/get_bookings_by_reference_usecases.dart';

class TicketController extends GetxController {
  TicketController({
    GetBookingByReferenceUseCase? getBookingByReferenceUseCase,
    CheckInBookingUseCase? checkInBookingUseCase,
  })  : _getBookingByReferenceUseCase =
            getBookingByReferenceUseCase ??
                _resolveGetBookingByReferenceUseCase(),
        _checkInBookingUseCase =
            checkInBookingUseCase ?? _resolveCheckInBookingUseCase();

  static BookingRepository _resolveBookingRepo() {
    return Get.isRegistered<BookingRepository>()
        ? Get.find<BookingRepository>()
        : Get.put<BookingRepository>(BookingRepositoryImpl());
  }

  static GetBookingByReferenceUseCase _resolveGetBookingByReferenceUseCase() {
    if (Get.isRegistered<GetBookingByReferenceUseCase>()) {
      return Get.find<GetBookingByReferenceUseCase>();
    }
    return Get.put(GetBookingByReferenceUseCase(_resolveBookingRepo()));
  }

  static CheckInBookingUseCase _resolveCheckInBookingUseCase() {
    if (Get.isRegistered<CheckInBookingUseCase>()) {
      return Get.find<CheckInBookingUseCase>();
    }
    return Get.put(CheckInBookingUseCase(_resolveBookingRepo()));
  }

  final GetBookingByReferenceUseCase _getBookingByReferenceUseCase;
  final CheckInBookingUseCase _checkInBookingUseCase;

  final Rx<Booking?> booking = Rx<Booking?>(null);
  final RxString message = ''.obs;
  final RxString resultType = ''.obs;
  final RxBool isLoading = false.obs;

  bool _isDisposed = false;

  /// Log errors with details for debugging.
  void _logError(
    String operation,
    Object error,
    StackTrace stackTrace,
  ) {
    developer.log(
      'TicketController: $operation failed.',
      name: 'TicketController',
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Search for a booking using its reference.
  Future<void> validateTicket(String reference) async {
    if (_isDisposed || isLoading.value) {
      return;
    }

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
      final Booking? result =
          await _getBookingByReferenceUseCase.call(cleanedReference);

      if (_isDisposed) return;

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
    } catch (error, stackTrace) {
      _logError('validateTicket', error, stackTrace);

      if (_isDisposed) return;

      resultType.value = 'error';
      message.value = 'Unable to validate the ticket. Please try again.';
    } finally {
      if (!_isDisposed) {
        isLoading.value = false;
      }
    }
  }

  /// Check in a valid ticket and save the change.
  Future<void> checkInTicket() async {
    if (_isDisposed || isLoading.value) {
      return;
    }

    final Booking? currentBooking = booking.value;

    if (currentBooking == null || resultType.value != 'valid') {
      return;
    }

    isLoading.value = true;

    try {
      final bool success = await _checkInBookingUseCase.call(
        currentBooking.bookingReference,
      );

      if (_isDisposed) return;

      if (success) {
        // Reload the booking to confirm its updated status.
        isLoading.value = false;

        await validateTicket(currentBooking.bookingReference);

        if (_isDisposed) return;

        if (resultType.value == 'used') {
          message.value = 'Check-in successful! This ticket is now used.';
        }
      } else {
        // Reload to check whether another attempt checked in this ticket.
        isLoading.value = false;

        await validateTicket(currentBooking.bookingReference);
      }
    } catch (error, stackTrace) {
      _logError('checkInTicket', error, stackTrace);

      if (_isDisposed) return;

      resultType.value = 'error';
      message.value = 'Check-in failed. Please try again.';
    } finally {
      if (!_isDisposed) {
        isLoading.value = false;
      }
    }
  }

  /// Clear the previous validation result.
  void clearValidation() {
    if (_isDisposed) return;

    booking.value = null;
    message.value = '';
    resultType.value = '';
  }

  @override
  void onClose() {
    _isDisposed = true;
    super.onClose();
  }
}

