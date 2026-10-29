
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../domain/entities/event.dart';
import '../../../domain/entities/seat.dart';

class DigitalTicketScreen extends StatelessWidget {
  const DigitalTicketScreen({
    super.key,
    required this.event,
    required this.selectedSeats,
    required this.bookingReference,
    required this.attendeeName,
  });

  final Event event;
  final List<Seat> selectedSeats;
  final String bookingReference;
  final String attendeeName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital Ticket'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  // Ticket header.
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    color: theme.colorScheme.primary,
                    child: Column(
                      children: [
                        const Icon(
                          Icons.confirmation_number,
                          size: 48,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          event.title,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'EVENTIFY DIGITAL TICKET',
                          style: TextStyle(
                            color: Colors.white,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // QR code.
                        QrImageView(
                          data: bookingReference,
                          version: QrVersions.auto,
                          size: 200,
                          backgroundColor: Colors.white,
                          errorCorrectionLevel: QrErrorCorrectLevel.H,
                        ),

                        const SizedBox(height: 12),

                        Text(
                          'Scan this code to identify your booking',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall,
                        ),

                        const SizedBox(height: 24),
                        const Divider(),

                        _TicketDetail(
                          label: 'Booking Reference',
                          value: bookingReference,
                        ),

                        _TicketDetail(
                          label: 'Attendee',
                          value: attendeeName,
                        ),

                        _TicketDetail(
                          label: 'Venue',
                          value: event.venue,
                        ),

                        _TicketDetail(
                          label: 'Date & Time',
                          value: DateFormat(
                            'dd MMM yyyy, hh:mm a',
                          ).format(event.eventDate.toLocal()),
                        ),

                        _TicketDetail(
                          label: 'Seat Numbers',
                          value: selectedSeats
                              .map((seat) => seat.seatNumber)
                              .join(', '),
                        ),

                        const SizedBox(height: 16),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'BOOKING CONFIRMED',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: () {
                  Get.back();
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to Confirmation'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TicketDetail extends StatelessWidget {
  const _TicketDetail({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
