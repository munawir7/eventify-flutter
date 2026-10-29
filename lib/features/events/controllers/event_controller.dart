import 'dart:developer' as developer;

import 'package:get/get.dart';

import '../../../data/repositories/event_repository.dart' as data_event;
import '../../../domain/entities/event.dart';
import '../../../domain/repositories/event_repository.dart' as domain_event;
import '../../../domain/usecases/events/get_all_events_usecases.dart';

class EventsController extends GetxController {
  EventsController({
    GetAllEventsUseCase? getAllEventsUseCase,
  }) : _getAllEventsUseCase =
           getAllEventsUseCase ?? _resolveGetAllEventsUseCase();

  static GetAllEventsUseCase _resolveGetAllEventsUseCase() {
    if (Get.isRegistered<GetAllEventsUseCase>()) {
      return Get.find<GetAllEventsUseCase>();
    }
    final repo = Get.isRegistered<domain_event.EventRepository>()
        ? Get.find<domain_event.EventRepository>()
        : Get.put<domain_event.EventRepository>(data_event.EventRepository());
    return Get.put<GetAllEventsUseCase>(GetAllEventsUseCase(repo));
  }

  final GetAllEventsUseCase _getAllEventsUseCase;

  // All events retrieved through the domain use case.
  final RxList<Event> allEvents = <Event>[].obs;

  // Events currently displayed on the screen.
  final RxList<Event> filteredEvents = <Event>[].obs;

  // Loading and error states.
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Search, category, and sorting selections.
  final RxString searchQuery = ''.obs;
  final RxString selectedCategory = 'All'.obs;
  final RxString sortBy = 'Date'.obs;
  final RxBool ascending = true.obs;

  bool _isDisposed = false;

  final List<String> categories = [
    'All',
    'Music',
    'Movies',
    'Sports',
    'Workshop',
    'Conference',
  ];

  @override
  void onInit() {
    super.onInit();
    loadEvents();
  }

  void _logError(
    String operation,
    Object error,
    StackTrace stackTrace,
  ) {
    developer.log(
      'Failed to $operation.',
      error: error,
      stackTrace: stackTrace,
      name: 'Eventify.EventsController',
    );
  }

  // Retrieve events through the domain use case.
  Future<void> loadEvents() async {
    if (_isDisposed || isLoading.value) {
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final events = await _getAllEventsUseCase();

      if (_isDisposed) {
        return;
      }

      allEvents.assignAll(events);
      _applyFilters();
    } catch (e, stackTrace) {
      _logError('load events', e, stackTrace);

      if (!_isDisposed) {
        errorMessage.value =
            'Unable to load events. Please try again.';
      }
    } finally {
      if (!_isDisposed) {
        isLoading.value = false;
      }
    }
  }

  // Update the search text.
  void searchEvents(String query) {
    if (_isDisposed) return;

    searchQuery.value = query;
    _applyFiltersSafely();
  }

  // Update the selected category.
  void filterByCategory(String category) {
    if (_isDisposed) return;

    if (!categories.contains(category)) {
      errorMessage.value = 'Please select a valid category.';
      return;
    }

    selectedCategory.value = category;
    _applyFiltersSafely();
  }

  // Change sorting options.
  void changeSorting(String option) {
    if (_isDisposed) return;

    if (option != 'Date' && option != 'Price') {
      errorMessage.value = 'Please select a valid sorting option.';
      return;
    }

    sortBy.value = option;
    _applyFiltersSafely();
  }

  // Toggle ascending and descending order.
  void toggleSortOrder() {
    if (_isDisposed) return;

    ascending.value = !ascending.value;
    _applyFiltersSafely();
  }

  // Handle unexpected errors while filtering.
  void _applyFiltersSafely() {
    try {
      _applyFilters();
      errorMessage.value = '';
    } catch (e, stackTrace) {
      _logError('filter or sort events', e, stackTrace);
      errorMessage.value =
          'Unable to filter events. Please try again.';
    }
  }

  // Apply search, category filtering, and sorting.
  void _applyFilters() {
    List<Event> result = List<Event>.from(allEvents);

    // Search by title, category, or venue.
    final query = searchQuery.value.trim().toLowerCase();

    if (query.isNotEmpty) {
      result = result.where((event) {
        return event.title.toLowerCase().contains(query) ||
            event.category.toLowerCase().contains(query) ||
            event.venue.toLowerCase().contains(query);
      }).toList();
    }

    // Filter by category.
    if (selectedCategory.value != 'All') {
      result = result.where((event) {
        return event.category == selectedCategory.value;
      }).toList();
    }

    // Sort the filtered events.
    if (sortBy.value == 'Price') {
      result.sort(
        (a, b) => ascending.value
            ? a.price.compareTo(b.price)
            : b.price.compareTo(a.price),
      );
    } else {
      result.sort(
        (a, b) => ascending.value
            ? a.eventDate.compareTo(b.eventDate)
            : b.eventDate.compareTo(a.eventDate),
      );
    }

    filteredEvents.assignAll(result);
  }

  @override
  void onClose() {
    _isDisposed = true;
    super.onClose();
  }
}