import 'package:eventify/domain/usecases/bookings/cancel_booking_usecases.dart';
import 'package:eventify/domain/usecases/bookings/check_in_booking_usecases.dart';
import 'package:eventify/domain/usecases/bookings/create_booking_usecases.dart';
import 'package:eventify/domain/usecases/bookings/get_all_bookings_usecases.dart';
import 'package:eventify/domain/usecases/bookings/get_bookings_by_reference_usecases.dart';
import 'package:get/get.dart';

import '../../data/repositories/booking_repository_impl.dart';
import '../../data/repositories/event_repository.dart' as data_event;
import '../../data/repositories/seat_repositery.dart' as data_seat;
import '../../domain/repositories/booking_repository.dart';
import '../../domain/repositories/event_repository.dart' as domain_event;
import '../../domain/repositories/seat_repository.dart' as domain_seat;
import '../../domain/usecases/events/get_all_events_usecases.dart';
import '../../domain/usecases/seats/get_seats_by_event_id_usecases.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    // ----------------------------------------------------
    // Event dependencies
    // ----------------------------------------------------
    Get.lazyPut<domain_event.EventRepository>(
      () => data_event.EventRepository(),
      fenix: true,
    );

    Get.lazyPut<GetAllEventsUseCase>(
      () => GetAllEventsUseCase(
        Get.find<domain_event.EventRepository>(),
      ),
      fenix: true,
    );

    // ----------------------------------------------------
    // Seat dependencies
    // ----------------------------------------------------
    Get.lazyPut<data_seat.SeatRepository>(
      () => data_seat.SeatRepository(),
      fenix: true,
    );

    Get.lazyPut<domain_seat.SeatRepository>(
      () => Get.find<data_seat.SeatRepository>(),
      fenix: true,
    );

    Get.lazyPut<GetSeatsByEventIdUseCase>(
      () => GetSeatsByEventIdUseCase(
        Get.find<data_seat.SeatRepository>(),
      ),
      fenix: true,
    );

    // ----------------------------------------------------
    // Booking dependencies
    // ----------------------------------------------------
    Get.lazyPut<BookingRepository>(
      () => BookingRepositoryImpl(),
      fenix: true,
    );

    Get.lazyPut<CreateBookingUseCase>(
      () => CreateBookingUseCase(
        Get.find<BookingRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<GetAllBookingsUseCase>(
      () => GetAllBookingsUseCase(
        Get.find<BookingRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<GetBookingByReferenceUseCase>(
      () => GetBookingByReferenceUseCase(
        Get.find<BookingRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<CancelBookingUseCase>(
      () => CancelBookingUseCase(
        Get.find<BookingRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<CheckInBookingUseCase>(
      () => CheckInBookingUseCase(
        Get.find<BookingRepository>(),
      ),
      fenix: true,
    );
  }
}