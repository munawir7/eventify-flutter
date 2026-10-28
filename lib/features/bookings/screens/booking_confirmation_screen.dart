
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../events/models/event_model.dart';
import '../../events/models/seat_model.dart';
import '../../tickets/screens/digital_ticket_screen.dart';

class BookingConfirmationScreen extends StatelessWidget {
  const BookingConfirmationScreen({
    super.key,
    required this.event,
    required this.selectedSeats,
    required this.bookingReference,
    required this.attendeeName,
    required this.attendeeEmail,
    required this.attendeePhone,
    required this.totalAmount,
    required this.discountAmount,
    required this.finalAmount,
  });

  final EventModel event;
  final List<SeatModel> selectedSeats;
  final String bookingReference;
  final String attendeeName;
  final String attendeeEmail;
  final String attendeePhone;
  final double totalAmount;
  final double discountAmount;
  final double finalAmount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Booking Confirmation'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 16),

            // Success icon.
            const CircleAvatar(
              radius: 42,
              backgroundColor: Color(0xFFDDF5E4),
              child: Icon(
                Icons.check_circle,
                size: 64,
                color: Colors.green,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'Booking Successful!',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Your seats have been reserved successfully.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),

            const SizedBox(height: 28),

            // Booking reference.
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    const Icon(
                      Icons.confirmation_number_outlined,
                      size: 36,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Booking Reference',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      bookingReference,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Keep this reference for your ticket.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Event information.
            _SectionCard(
              title: 'Event Details',
              icon: Icons.event,
              children: [
                _DetailRow(
                  label: 'Event',
                  value: event.title,
                ),
                _DetailRow(
                  label: 'Venue',
                  value: event.venue,
                ),
                _DetailRow(
                  label: 'Date',
                  value: DateFormat(
                    'dd MMM yyyy, hh:mm a',
                  ).format(event.eventDate.toLocal()),
                ),
                _DetailRow(
                  label: 'Seats',
                  value: selectedSeats
                      .map((seat) => seat.seatNumber)
                      .join(', '),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Attendee information.
            _SectionCard(
              title: 'Attendee Details',
              icon: Icons.person_outline,
              children: [
                _DetailRow(
                  label: 'Name',
                  value: attendeeName,
                ),
                _DetailRow(
                  label: 'Email',
                  value: attendeeEmail,
                ),
                _DetailRow(
                  label: 'Phone',
                  value: attendeePhone,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Price summary.
            _SectionCard(
              title: 'Payment Summary',
              icon: Icons.receipt_long_outlined,
              children: [
                _DetailRow(
                  label: 'Ticket Total',
                  value: '₹${totalAmount.toStringAsFixed(2)}',
                ),
                _DetailRow(
                  label: 'Discount',
                  value: '- ₹${discountAmount.toStringAsFixed(2)}',
                  valueColor: Colors.green,
                ),
                const Divider(height: 24),
                _DetailRow(
                  label: 'Final Amount',
                  value: '₹${finalAmount.toStringAsFixed(2)}',
                  isBold: true,
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Return to home.
        
SizedBox(
  height: 52,
  child: FilledButton.icon(
    onPressed: () {
      Get.to(
        () => DigitalTicketScreen(
          event: event,
          selectedSeats: selectedSeats,
          bookingReference: bookingReference,
          attendeeName: attendeeName,
        ),
      );
    },
    icon: const Icon(Icons.confirmation_number_outlined),
    label: const Text('View Digital Ticket'),
  ),
),
const SizedBox(height: 12),



            OutlinedButton.icon(
              onPressed: () {
                Get.back();
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back'),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          color: valueColor,
        );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(label),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: style,
            ),
          ),
        ],
      ),
    );
  }
}
