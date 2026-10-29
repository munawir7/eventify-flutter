
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../domain/entities/event.dart';
import '../controllers/seat_selection_controller.dart';
import '../../bookings/screens/checkout_screen.dart';

class SeatSelectionScreen extends StatefulWidget {
  const SeatSelectionScreen({
    super.key,
    required this.event,
  });

  final Event event;

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  late final SeatSelectionController controller;
  late final String controllerTag;

  static const Color primaryColor = Color(0xFF0D47A1);
  static const Color backgroundColor = Color(0xFFF5F7FA);

  @override
  void initState() {
    super.initState();

    controllerTag = 'seat_selection_${widget.event.id}';

    controller = Get.put(
      SeatSelectionController(
        eventId: widget.event.id!,
      ),
      tag: controllerTag,
    );
  }

  @override
  void dispose() {
    if (Get.isRegistered<SeatSelectionController>(
      tag: controllerTag,
    )) {
      Get.delete<SeatSelectionController>(
        tag: controllerTag,
      );
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Select Seats',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: backgroundColor,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          Obx(
            () => TextButton(
              onPressed: controller.selectedCount == 0
                  ? null
                  : controller.clearSelection,
              child: const Text(
                'Clear',
                style: TextStyle(
                  color: primaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: primaryColor,
            ),
          );
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 50,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    controller.errorMessage.value,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: controller.loadSeats,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (controller.seats.isEmpty) {
          return const Center(
            child: Text(
              'No seats available for this event.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
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
                    _buildEventInformation(),
                    const SizedBox(height: 24),
                    _buildScreenIndicator(),
                    const SizedBox(height: 24),
                    _buildLegend(),
                    const SizedBox(height: 28),
                    _buildSeatCategory('Regular'),
                    const SizedBox(height: 24),
                    _buildSeatCategory('Premium'),
                    const SizedBox(height: 24),
                    _buildSeatCategory('VIP'),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            _buildBottomSummary(),
          ],
        );
      }),
    );
  }

  Widget _buildEventInformation() {
    final event = widget.event;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 18,
                color: primaryColor,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  event.venue,
                  style: const TextStyle(
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                _formatDate(event.eventDate),
                style: const TextStyle(
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;

    return '$day/$month/$year';
  }

  Widget _buildScreenIndicator() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 8,
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'SCREEN THIS WAY',
          style: TextStyle(
            fontSize: 12,
            letterSpacing: 2,
            color: Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildLegend() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 12,
      children: [
        _buildLegendItem(
          color: Colors.white,
          borderColor: Colors.grey,
          label: 'Available',
        ),
        _buildLegendItem(
          color: primaryColor,
          borderColor: primaryColor,
          label: 'Selected',
        ),
        _buildLegendItem(
          color: Colors.grey.shade400,
          borderColor: Colors.grey.shade400,
          label: 'Unavailable',
        ),
      ],
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required Color borderColor,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: borderColor,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildSeatCategory(String category) {
    final categorySeats = controller.seats
        .where(
          (seat) =>
              seat.category.toLowerCase() == category.toLowerCase(),
        )
        .toList();

    if (categorySeats.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              category,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '₹${categorySeats.first.price.toStringAsFixed(0)} / seat',
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 10,
          children: categorySeats.map((seat) {
            final isSelected =
                controller.selectedSeatIds.contains(seat.id);

            final isAvailable =
                seat.status.toLowerCase() == 'available';

            return InkWell(
              onTap: () => controller.toggleSeat(seat),
              borderRadius: BorderRadius.circular(8),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 48,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? primaryColor
                      : isAvailable
                          ? Colors.white
                          : Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? primaryColor
                        : isAvailable
                            ? Colors.grey.shade400
                            : Colors.grey.shade400,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Text(
                  seat.seatNumber,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isSelected || !isAvailable
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBottomSummary() {
    return Obx(
      () => Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${controller.selectedCount} seat(s) selected',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${controller.totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: controller.selectedCount == 0
                      ? null
                      : _continueToCheckout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _continueToCheckout() {
    if (controller.selectedSeats.isEmpty) {
      return;
    }

    Get.to(
      () => CheckoutScreen(
        event: widget.event,
        selectedSeats: controller.selectedSeats,
      ),
    );
  }
}
