
import 'package:get/get.dart';

import '../../../data/repositories/event_repository.dart';
import '../models/event_model.dart';

class EventsController extends GetxController {
  final EventRepository _repository = EventRepository();

  // All events retrieved from SQLite.
  final RxList<EventModel> allEvents = <EventModel>[].obs;

  // Events currently displayed on the screen.
  final RxList<EventModel> filteredEvents = <EventModel>[].obs;

  // Loading and error states.
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Search, category, and sorting selections.
  final RxString searchQuery = ''.obs;
  final RxString selectedCategory = 'All'.obs;
  final RxString sortBy = 'Date'.obs;
  final RxBool ascending = true.obs;

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

  // Retrieve events from SQLite.
  Future<void> loadEvents() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final events = await _repository.getAllEvents();

      allEvents.assignAll(events);
      _applyFilters();
    } catch (e) {
      errorMessage.value = 'Unable to load events. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  // Update the search text.
  void searchEvents(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  // Update the selected category.
  void filterByCategory(String category) {
    selectedCategory.value = category;
    _applyFilters();
  }

  // Change sorting options.
  void changeSorting(String option) {
    sortBy.value = option;
    _applyFilters();
  }

  // Toggle ascending and descending order.
  void toggleSortOrder() {
    ascending.value = !ascending.value;
    _applyFilters();
  }

  // Apply search, category filtering, and sorting.
  void _applyFilters() {
    List<EventModel> result = List<EventModel>.from(allEvents);

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
}
