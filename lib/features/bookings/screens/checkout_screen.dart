import 'package:eventify/domain/entities/event.dart';
import 'package:eventify/domain/entities/seat.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/booking_controller.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({
    super.key,
    required this.event,
    required this.selectedSeats,
  });

  final Event event;
  final List<Seat> selectedSeats;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late final BookingController controller;
  late final String _controllerTag;

  @override
  void initState() {
    super.initState();

    _controllerTag = 'checkout_${widget.event.id}';

    controller = Get.put(
      BookingController(
        event: widget.event,
        selectedSeats: widget.selectedSeats,
      ),
      tag: _controllerTag,
    );
  }

  @override
  void dispose() {
    if (Get.isRegistered<BookingController>(tag: _controllerTag)) {
      Get.delete<BookingController>(tag: _controllerTag);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: Form(
        key: controller.formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Complete Your Booking',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter your details to reserve your seats.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),

            // Event summary.
            _EventSummaryCard(
              event: widget.event,
              selectedSeats: widget.selectedSeats,
            ),

            const SizedBox(height: 24),

            Text(
              'Attendee Details',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Attendee name.
            TextFormField(
              controller: controller.nameController,
              textCapitalization: TextCapitalization.words,
              validator: controller.validateName,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                hintText: 'Enter your full name',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // Attendee email.
            TextFormField(
              controller: controller.emailController,
              keyboardType: TextInputType.emailAddress,
              validator: controller.validateEmail,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                hintText: 'example@email.com',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // Attendee phone.
            TextFormField(
              controller: controller.phoneController,
              keyboardType: TextInputType.phone,
              validator: controller.validatePhone,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                hintText: 'Enter your phone number',
                prefixIcon: Icon(Icons.phone_outlined),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            // Price summary.
            _PriceSummaryCard(
              controller: controller,
              seatCount: widget.selectedSeats.length,
            ),

            const SizedBox(height: 24),

            // Confirm booking.
            Obx(
              () => SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton.icon(
                  onPressed: controller.isBooking.value
                      ? null
                      : controller.confirmBookingAndNavigate,
                  icon: controller.isBooking.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.check_circle_outline),
                  label: Text(
                    controller.isBooking.value
                        ? 'Confirming Booking...'
                        : 'Confirm Booking',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _EventSummaryCard extends StatelessWidget {
  const _EventSummaryCard({
    required this.event,
    required this.selectedSeats,
  });

  final Event event;
  final List<Seat> selectedSeats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(event.venue),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Selected Seats',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: selectedSeats.map((seat) {
                return Chip(
                  avatar: const Icon(
                    Icons.event_seat,
                    size: 18,
                  ),
                  label: Text(seat.seatNumber),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceSummaryCard extends StatelessWidget {
  const _PriceSummaryCard({
    required this.controller,
    required this.seatCount,
  });

  final BookingController controller;
  final int seatCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _PriceRow(
              label: 'Tickets ($seatCount)',
              amount: controller.totalAmount,
            ),
            const SizedBox(height: 12),
            Obx(
              () => _PriceRow(
                label: 'Discount (10% when eligible)',
                amount: -controller.discountAmount.value,
                amountColor: Colors.green,
              ),
            ),
            const Divider(height: 24),
            Obx(
              () => _PriceRow(
                label: 'Final Amount',
                amount: controller.finalAmount.value,
                isTotal: true,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No online payment is required for this offline demo.',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.amount,
    this.isTotal = false,
    this.amountColor,
  });

  final String label;
  final double amount;
  final bool isTotal;
  final Color? amountColor;

  @override
  Widget build(BuildContext context) {
    final textStyle = isTotal
        ? Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            )
        : Theme.of(context).textTheme.bodyMedium;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: textStyle,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '${amount < 0 ? '- ' : ''}₹${amount.abs().toStringAsFixed(2)}',
          style: textStyle?.copyWith(
            color: amountColor,
          ),
        ),
      ],
    );
  }
}
