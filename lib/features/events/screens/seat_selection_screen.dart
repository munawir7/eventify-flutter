
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../bookings/screens/checkout_screen.dart';
import '../controllers/seat_selection_controller.dart';
import '../models/event_model.dart';
import '../models/seat_model.dart';

class SeatSelectionScreen extends StatelessWidget {
  const SeatSelectionScreen({
    super.key,
    required this.event,
  });

  final EventModel event;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      SeatSelectionController(eventId: event.id!),
      tag: 'event_${event.id}',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Your Seats'),
        actions: [
          IconButton(
            onPressed: controller.clearSelection,
            icon: const Icon(Icons.refresh),
            tooltip: 'Clear selection',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(controller.errorMessage.value),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: controller.loadSeats,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (controller.seats.isEmpty) {
          return const Center(
            child: Text('No seats available for this event.'),
          );
        }

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      event.venue,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),

                    // Screen indicator.
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          'S C R E E N',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 4,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Seat status legend.
                    const Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 16,
                      runSpacing: 12,
                      children: [
                        _SeatLegend(
                          color: Colors.green,
                          label: 'Available',
                        ),
                        _SeatLegend(
                          color: Colors.deepPurple,
                          label: 'Selected',
                        ),
                        _SeatLegend(
                          color: Colors.red,
                          label: 'Booked',
                        ),
                        _SeatLegend(
                          color: Colors.grey,
                          label: 'Blocked',
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // Display Regular, Premium, and VIP seats.
                    for (final category in [
                      'Regular',
                      'Premium',
                      'VIP',
                    ]) ...[
                      _buildSeatCategory(
                        context,
                        controller,
                        category,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ],
                ),
              ),
            ),

            // Bottom booking summary.
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() {
                      return Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${controller.selectedCount} seat(s) selected',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            '₹${controller.totalPrice.toStringAsFixed(2)}',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      );
                    }),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: Obx(() {
                        return ElevatedButton(
                      
onPressed: controller.selectedCount == 0
    ? null
    : () {
        Get.to(
          () => CheckoutScreen(
            event: event,
            selectedSeats: List<SeatModel>.from(
              controller.selectedSeats,
            ),
          ),
        );
      },

                          child: const Text('Continue to Checkout'),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSeatCategory(
    BuildContext context,
    SeatSelectionController controller,
    String category,
  ) {
    final categorySeats = controller.seats
        .where((seat) => seat.category == category)
        .toList();

    if (categorySeats.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$category Seats',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          '₹${categorySeats.first.price.toStringAsFixed(2)} per seat',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 16),

        // Display seats in rows of five.
        Wrap(
          spacing: 10,
          runSpacing: 12,
          children: categorySeats.map((seat) {
            return Obx(() {
              final isSelected =
                  controller.selectedSeatIds.contains(seat.id);

              return _SeatTile(
                seat: seat,
                isSelected: isSelected,
                onTap: () => controller.toggleSeat(seat),
              );
            });
          }).toList(),
        ),
      ],
    );
  }
}

class _SeatTile extends StatelessWidget {
  const _SeatTile({
    required this.seat,
    required this.isSelected,
    required this.onTap,
  });

  final SeatModel seat;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color seatColor;

    if (isSelected) {
      seatColor = Colors.deepPurple;
    } else if (seat.status == 'booked') {
      seatColor = Colors.red;
    } else if (seat.status == 'blocked') {
      seatColor = Colors.grey;
    } else {
      seatColor = Colors.green;
    }

    final bool isUnavailable =
        seat.status == 'booked' || seat.status == 'blocked';

    return InkWell(
      onTap: isUnavailable ? null : onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 48,
        height: 44,
        decoration: BoxDecoration(
          color: seatColor.withValues(alpha: 0.15),
          border: Border.all(
            color: seatColor,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            seat.seatNumber,
            style: TextStyle(
              color: seatColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class _SeatLegend extends StatelessWidget {
  const _SeatLegend({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
