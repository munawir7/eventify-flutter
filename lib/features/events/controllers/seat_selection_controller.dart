
import 'package:get/get.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/repositories/seat_repositery.dart';
import '../../../domain/entities/seat.dart';
import '../../../domain/usecases/seats/get_seats_by_event_id_usecases.dart';

class SeatSelectionController extends GetxController {
  SeatSelectionController({
    required this.eventId,
    GetSeatsByEventIdUseCase? getSeatsByEventIdUseCase,
  }) : _getSeatsByEventIdUseCase =
           getSeatsByEventIdUseCase ?? _resolveGetSeatsUseCase();

  static GetSeatsByEventIdUseCase _resolveGetSeatsUseCase() {
    if (Get.isRegistered<GetSeatsByEventIdUseCase>()) {
      return Get.find<GetSeatsByEventIdUseCase>();
    }
    final repo = Get.isRegistered<SeatRepository>()
        ? Get.find<SeatRepository>()
        : Get.put<SeatRepository>(SeatRepository());
    return Get.put<GetSeatsByEventIdUseCase>(GetSeatsByEventIdUseCase(repo));
  }

  final int eventId;

  final GetSeatsByEventIdUseCase _getSeatsByEventIdUseCase;

  // All seats for the selected event.
  final RxList<Seat> seats = <Seat>[].obs;

  // IDs of the seats selected by the user.
  final RxList<int> selectedSeatIds = <int>[].obs;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Calculate the total price of the selected seats.
  double get totalPrice {
    double total = 0;

    for (final seat in selectedSeats) {
      total += seat.price;
    }

    return total;
  }

  // Return the selected seats.
  List<Seat> get selectedSeats {
    return seats
        .where((seat) => selectedSeatIds.contains(seat.id))
        .toList();
  }

  // Number of selected seats.
  int get selectedCount => selectedSeatIds.length;

  @override
  void onInit() {
    super.onInit();
    loadSeats();
  }

  // Load seats using the domain use case.
  
Future<void> loadSeats() async {
  isLoading.value = true;
  errorMessage.value = '';

  try {
    final List<Seat> loadedSeats =
        await _getSeatsByEventIdUseCase(eventId);

    seats.assignAll(loadedSeats);
  } catch (e) {
    errorMessage.value = 'Unable to load seats. Please try again.';
  } finally {
    isLoading.value = false;
  }
}


  // Select or deselect a seat.
  void toggleSeat(Seat seat) {
    if (seat.id == null) {
      return;
    }

    if (seat.status != 'available') {
      Get.snackbar(
        'Seat Unavailable',
        'This seat is not available for booking.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (selectedSeatIds.contains(seat.id)) {
      selectedSeatIds.remove(seat.id);
      return;
    }

    if (selectedSeatIds.length >= AppConstants.maxTicketsPerBooking) {
      Get.snackbar(
        'Limit Reached',
        'You can select a maximum of '
        '${AppConstants.maxTicketsPerBooking} seats.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    selectedSeatIds.add(seat.id!);
  }

  // Clear all selected seats.
  void clearSelection() {
    selectedSeatIds.clear();
  }
}
