
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/ticket_controller.dart';

class TicketValidationScreen extends StatefulWidget {
  const TicketValidationScreen({super.key});

  @override
  State<TicketValidationScreen> createState() =>
      _TicketValidationScreenState();
}

class _TicketValidationScreenState extends State<TicketValidationScreen> {
  final TextEditingController _referenceController =
      TextEditingController();

  late final TicketController _ticketController;

  @override
  void initState() {
    super.initState();
    _ticketController = Get.isRegistered<TicketController>()
        ? Get.find<TicketController>()
        : Get.put(TicketController());
  }

  @override
  void dispose() {
    _referenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ticket Validation'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.confirmation_number_outlined,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 20),
            const Text(
              'Validate Your Ticket',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Enter a booking reference to check ticket validity '
              'and manage event check-in.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // Booking reference input.
            TextField(
              controller: _referenceController,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                labelText: 'Booking Reference',
                hintText: 'Enter booking reference',
                prefixIcon: const Icon(Icons.qr_code),
                suffixIcon: IconButton(
                  tooltip: 'Clear',
                  onPressed: () {
                    _referenceController.clear();
                    _ticketController.clearValidation();
                  },
                  icon: const Icon(Icons.clear),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: _ticketController.validateTicket,
            ),
            const SizedBox(height: 20),

            // Validate button.
            Obx(
              () => ElevatedButton.icon(
                onPressed: _ticketController.isLoading.value
                    ? null
                    : () => _ticketController.validateTicket(
                          _referenceController.text,
                        ),
                icon: const Icon(Icons.verified_outlined),
                label: const Text('Validate Ticket'),
              ),
            ),
            const SizedBox(height: 24),

            // Validation result.
            Obx(() {
              final String resultType =
                  _ticketController.resultType.value;
              final String message =
                  _ticketController.message.value;
              final booking = _ticketController.booking.value;
              final bool isLoading =
                  _ticketController.isLoading.value;

              if (isLoading && resultType.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (resultType.isEmpty) {
                return const SizedBox.shrink();
              }

              final Color resultColor;
              final IconData resultIcon;

              switch (resultType) {
                case 'valid':
                  resultColor = Colors.green;
                  resultIcon = Icons.check_circle_outline;
                  break;
                case 'used':
                  resultColor = Colors.orange;
                  resultIcon = Icons.history;
                  break;
                case 'cancelled':
                case 'invalid':
                case 'error':
                default:
                  resultColor = Colors.red;
                  resultIcon = Icons.error_outline;
              }

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        resultIcon,
                        color: resultColor,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        resultType == 'valid'
                            ? 'Valid Ticket'
                            : resultType == 'used'
                                ? 'Ticket Already Used'
                                : resultType == 'cancelled'
                                    ? 'Booking Cancelled'
                                    : resultType == 'error'
                                        ? 'Something Went Wrong'
                                        : 'Invalid Ticket',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: resultColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                      ),

                      if (booking != null) ...[
                        const Divider(height: 28),
                        _buildDetail(
                          'Booking Reference',
                          booking.bookingReference,
                        ),
                        _buildDetail(
                          'Attendee',
                          booking.attendeeName,
                        ),
                        _buildDetail(
                          'Email',
                          booking.attendeeEmail,
                        ),
                        _buildDetail(
                          'Event ID',
                          booking.eventId.toString(),
                        ),
                        _buildDetail(
                          'Booking Status',
                          booking.status,
                        ),
                        _buildDetail(
                          'Check-in Status',
                          booking.isCheckedIn
                              ? 'Already checked in'
                              : 'Not checked in',
                        ),
                        _buildDetail(
                          'Amount Paid',
                          '₹${booking.finalAmount.toStringAsFixed(2)}',
                        ),
                      ],

                      if (resultType == 'valid') ...[
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: isLoading
                              ? null
                              : _ticketController.checkInTicket,
                          icon: const Icon(Icons.how_to_reg),
                          label: const Text('Check In Ticket'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
