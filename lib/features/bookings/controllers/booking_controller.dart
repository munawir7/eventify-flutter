
import 'dart:developer' as developer;

import 'package:eventify/domain/entities/booking_request.dart';
import 'package:eventify/domain/entities/event.dart';
import 'package:eventify/domain/entities/seat.dart';
import 'package:eventify/domain/usecases/bookings/create_booking_usecases.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../../data/repositories/booking_repository_impl.dart';
import '../../../domain/repositories/booking_repository.dart';
import '../screens/booking_confirmation_screen.dart';

class BookingController extends GetxController {
  BookingController({
    required this.event,
    required this.selectedSeats,
    CreateBookingUseCase? createBookingUseCase,
  }) : createBookingUseCase =
            createBookingUseCase ?? _resolveCreateBookingUseCase();

  static CreateBookingUseCase _resolveCreateBookingUseCase() {
    if (Get.isRegistered<CreateBookingUseCase>()) {
      return Get.find<CreateBookingUseCase>();
    }

    final bookingRepo = Get.isRegistered<BookingRepository>()
        ? Get.find<BookingRepository>()
        : Get.put<BookingRepository>(BookingRepositoryImpl());

    return Get.put<CreateBookingUseCase>(CreateBookingUseCase(bookingRepo));
  }

  // Dependencies
  final Event event;
  final List<Seat> selectedSeats;
  final CreateBookingUseCase createBookingUseCase;

  // Form controllers
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController phoneController =
      TextEditingController();

  // Reactive state
  final RxBool isBooking = false.obs;
  final RxDouble discountAmount = 0.0.obs;
  final RxDouble finalAmount = 0.0.obs;

  bool _isDisposed = false;

  // Price calculations
  double get totalAmount {
    return selectedSeats.fold<double>(
      0.0,
      (total, seat) => total + seat.price,
    );
  }

  @override
  void onInit() {
    super.onInit();
    _calculateAmounts();
  }

  void _calculateAmounts() {
    final double total = totalAmount;

    if (total >= 2000) {
      discountAmount.value = total * 0.10;
    } else {
      discountAmount.value = 0.0;
    }

    finalAmount.value = total - discountAmount.value;
  }

  // Form validation
  bool validateAttendeeDetails() {
    if (_isDisposed) {
      return false;
    }

    return formKey.currentState?.validate() ?? false;
  }

  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your full name.';
    }

    if (value.trim().length < 2) {
      return 'Name must contain at least 2 characters.';
    }

    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email address.';
    }

    final emailRegex = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address.';
    }

    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your phone number.';
    }

    final digits = value.replaceAll(RegExp(r'\D'), '');

    if (digits.length < 10 || digits.length > 15) {
      return 'Enter a valid phone number.';
    }

    return null;
  }

  // Error handling
  void _showError(String message) {
    if (_isDisposed) {
      return;
    }

    Get.snackbar(
      'Booking Failed',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade100,
      colorText: Colors.red.shade900,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    );
  }

  void _logError(
    String message,
    Object error,
    StackTrace stackTrace,
  ) {
    developer.log(
      message,
      name: 'BookingController',
      error: error,
      stackTrace: stackTrace,
    );
  }

  // Confirm booking
  Future<String?> confirmBooking() async {
    if (_isDisposed || isBooking.value) {
      return null;
    }

    if (!validateAttendeeDetails()) {
      return null;
    }

    if (selectedSeats.isEmpty) {
      _showError('Please select at least one seat.');
      return null;
    }

    if (selectedSeats.length >
        AppConstants.maxTicketsPerBooking) {
      _showError(
        'You can book a maximum of '
        '${AppConstants.maxTicketsPerBooking} tickets at a time.',
      );
      return null;
    }

    final int? eventId = event.id;

    if (eventId == null || eventId <= 0) {
      _showError('The selected event is invalid.');
      return null;
    }

    final List<int?> seatIdValues =
        selectedSeats.map((seat) => seat.id).toList();

    if (seatIdValues.any(
      (seatId) => seatId == null || seatId <= 0,
    )) {
      _showError('One or more selected seats are invalid.');
      return null;
    }

    final List<int> seatIds = seatIdValues.cast<int>().toList();

    if (seatIds.toSet().length != seatIds.length) {
      _showError(
        'Duplicate seats were selected. Please select your seats again.',
      );
      return null;
    }

    isBooking.value = true;

    try {
      final BookingRequest request = BookingRequest(
        eventId: eventId,
        seatIds: seatIds,
        attendeeName: nameController.text.trim(),
        attendeeEmail: emailController.text.trim(),
        attendeePhone: phoneController.text.trim(),
      );

      final String bookingReference =
          await createBookingUseCase(request);

      if (_isDisposed) {
        return null;
      }

      return bookingReference;
    } on AppException catch (error, stackTrace) {
      _logError(
        'Booking failed because of an application error.',
        error,
        stackTrace,
      );

      _showError(error.message);
      return null;
    } on DatabaseException catch (error, stackTrace) {
      _logError(
        'Booking failed because of a database error.',
        error,
        stackTrace,
      );

      _showError(
        'A database error occurred while booking your seats. '
        'Please try again.',
      );

      return null;
    } on FormatException catch (error, stackTrace) {
      _logError(
        'Booking failed because of invalid data.',
        error,
        stackTrace,
      );

      _showError(
        'Some booking information is invalid. '
        'Please check your details and try again.',
      );

      return null;
    } on PlatformException catch (error, stackTrace) {
      _logError(
        'Booking failed because of a platform error.',
        error,
        stackTrace,
      );

      _showError(
        'A device error occurred while processing your booking.',
      );

      return null;
    } catch (error, stackTrace) {
      _logError(
        'An unexpected error occurred during booking.',
        error,
        stackTrace,
      );

      _showError(
        'Unable to complete your booking. Please try again.',
      );

      return null;
    } finally {
      if (!_isDisposed) {
        isBooking.value = false;
      }
    }
  }

  Future<void> confirmBookingAndNavigate() async {
    FocusManager.instance.primaryFocus?.unfocus();

    final bookingReference = await confirmBooking();

    if (_isDisposed || bookingReference == null) {
      return;
    }

    Get.off(
      () => BookingConfirmationScreen(
        event: event,
        selectedSeats: selectedSeats,
        bookingReference: bookingReference,
        attendeeName: nameController.text.trim(),
        attendeeEmail: emailController.text.trim(),
        attendeePhone: phoneController.text.trim(),
        totalAmount: totalAmount,
        discountAmount: discountAmount.value,
        finalAmount: finalAmount.value,
      ),
    );
  }

  @override
  void onClose() {
    _isDisposed = true;

    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();

    super.onClose();
  }
}
