
import 'package:eventify/features/events/controllers/event_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';
import '../../../core/constants/app_constants.dart';
import '../widgets/event_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final EventsController controller = Get.put(EventsController());

    return Scaffold(
      appBar: AppBar(
  title: const Text(
    AppConstants.appName,
    style: TextStyle(fontWeight: FontWeight.bold),
  ),
  actions: [
    // Open ticket validation.
    IconButton(
      tooltip: 'Validate Ticket',
      onPressed: () {
        Get.toNamed(AppRoutes.ticketValidation);
      },
      icon: const Icon(Icons.qr_code_scanner),
    ),

    // Refresh events.
    IconButton(
      tooltip: 'Refresh events',
      onPressed: controller.loadEvents,
      icon: const Icon(Icons.refresh),
    ),
    IconButton(
  tooltip: 'Booking History',
  onPressed: () {
    Get.toNamed(AppRoutes.bookingHistory);
  },
  icon: const Icon(Icons.history),
),
  ],
),
      body: SafeArea(
        child: Column(
          children: [
            // Search field.
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                onChanged: controller.searchEvents,
                decoration: InputDecoration(
                  hintText: 'Search events, categories, venues...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  filled: true,
                ),
              ),
            ),

            // Category filters.
           // Category filters.
SizedBox(
  height: 52,
  child: ListView.separated(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    scrollDirection: Axis.horizontal,
    itemCount: controller.categories.length,
    separatorBuilder: (_, __) => const SizedBox(width: 8),
    itemBuilder: (context, index) {
      final category = controller.categories[index];

      return Obx(() {
        final selected =
            controller.selectedCategory.value == category;

        return ChoiceChip(
          label: Text(category),
          selected: selected,
          onSelected: (_) {
            controller.filterByCategory(category);
          },
        );
      });
    },
  ),
),

            // Sorting controls.
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  const Icon(Icons.sort),
                  const SizedBox(width: 8),
                  const Text('Sort by:'),
                  const SizedBox(width: 12),
                  Obx(
                    () => DropdownButton<String>(
                      value: controller.sortBy.value,
                      items: const [
                        DropdownMenuItem(
                          value: 'Date',
                          child: Text('Date'),
                        ),
                        DropdownMenuItem(
                          value: 'Price',
                          child: Text('Price'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          controller.changeSorting(value);
                        }
                      },
                    ),
                  ),
                  const Spacer(),
                  Obx(
                    () => IconButton(
                      tooltip: controller.ascending.value
                          ? 'Ascending order'
                          : 'Descending order',
                      onPressed: controller.toggleSortOrder,
                      icon: Icon(
                        controller.ascending.value
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Event list.
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (controller.errorMessage.value.isNotEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(controller.errorMessage.value),
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed: controller.loadEvents,
                            child: const Text('Try Again'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (controller.filteredEvents.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.event_busy_outlined,
                            size: 64,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'No events found',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Try another search or category.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.loadEvents,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: controller.filteredEvents.length,
                    itemBuilder: (context, index) {
                      final event =
                          controller.filteredEvents[index];

                      return EventCard(
  event: event,
  onTap: () {
    Get.toNamed(
      AppRoutes.eventDetails,
      arguments: event,
    );
  },
);
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
