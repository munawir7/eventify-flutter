
import 'package:eventify/features/events/screens/event_detail_screen.dart';
import 'package:eventify/features/tickets/screens/ticket_validation_screen.dart';
import 'package:get/get.dart';

import '../features/bookings/screens/booking_history_screen.dart';
import '../features/events/models/event_model.dart';
import '../features/events/screens/home_screen.dart';
import '../features/events/screens/seat_selection_screen.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static final List<GetPage<dynamic>> pages = [
    GetPage<dynamic>(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.eventDetails,
      page: () {
        final event = Get.arguments as EventModel;

        return EventDetailsScreen(event: event);
      },
    ),
    GetPage<dynamic>(
      name: AppRoutes.seatSelection,
      page: () {
        final event = Get.arguments as EventModel;

        return SeatSelectionScreen(event: event);
      },
    ),
    GetPage<dynamic>(
      name: AppRoutes.ticketValidation,
      page: () => const TicketValidationScreen(),
    ),
    GetPage<dynamic>(
  name: AppRoutes.bookingHistory,
  page: () => const BookingHistoryScreen(),
),
  ];
}
