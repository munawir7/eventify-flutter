
import 'package:eventify/data/repositories/seat_repositery.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_constants.dart';
import '../models/seat_model.dart';

class SeatSelectionController extends GetxController {
  SeatSelectionController({
    required this.eventId,
  });

  final int eventId;

  final SeatRepository _seatRepository = SeatRepository();

  // All seats belonging to the selected event.
  final RxList<SeatModel> seats = <SeatModel>[].obs;

  // IDs of seats selected by the user.
  final RxList<int> selectedSeatIds = <int>[].obs;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Calculate the total price of the selected seats.
  double get totalPrice {
    double total = 0;

    for (final seat in seats) {
      if (selectedSeatIds.contains(seat.id)) {
        total += seat.price;
      }
    }

    return total;
  }

  // Get the complete details of the selected seats.
  List<SeatModel> get selectedSeats {
    return seats
        .where((seat) => selectedSeatIds.contains(seat.id))
        .toList();
  }

  // Number of seats currently selected.
  int get selectedCount => selectedSeatIds.length;

  @override
  void onInit() {
    super.onInit();
    loadSeats();
  }

  // Load seats for this event from the local database.
  Future<void> loadSeats() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final loadedSeats =
          await _seatRepository.getSeatsByEventId(eventId);

      seats.assignAll(loadedSeats);
    } catch (e) {
      errorMessage.value = 'Unable to load seats. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  // Select or deselect a seat.
  void toggleSeat(SeatModel seat) {
    final seatId = seat.id;

    if (seatId == null) {
      return;
    }

    // If the seat is already selected, deselect it.
    if (selectedSeatIds.contains(seatId)) {
      selectedSeatIds.remove(seatId);
      return;
    }

    // Only available seats can be selected.
    if (seat.status != 'available') {
      Get.snackbar(
        'Seat unavailable',
        'Please choose another seat.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Enforce the maximum number of tickets per booking.
    if (selectedSeatIds.length >= AppConstants.maxTicketsPerBooking) {
      Get.snackbar(
        'Booking limit reached',
        'You can select a maximum of '
            '${AppConstants.maxTicketsPerBooking} seats.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    selectedSeatIds.add(seatId);
  }

  // Clear all selected seats.
  void clearSelection() {
    selectedSeatIds.clear();
  }
}
