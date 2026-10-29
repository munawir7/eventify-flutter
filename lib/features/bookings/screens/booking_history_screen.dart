
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/repositories/booking_repository_impl.dart';
import '../../../domain/entities/booking.dart';
import '../../../domain/repositories/booking_repository.dart';
import '../../../domain/usecases/bookings/cancel_booking_usecases.dart';
import '../../../domain/usecases/bookings/get_all_bookings_usecases.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() =>
      _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  late final GetAllBookingsUseCase _getAllBookingsUseCase;
  late final CancelBookingUseCase _cancelBookingUseCase;

  List<Booking> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    final repo = Get.isRegistered<BookingRepository>()
        ? Get.find<BookingRepository>()
        : Get.put<BookingRepository>(BookingRepositoryImpl());

    _getAllBookingsUseCase = Get.isRegistered<GetAllBookingsUseCase>()
        ? Get.find<GetAllBookingsUseCase>()
        : Get.put(GetAllBookingsUseCase(repo));

    _cancelBookingUseCase = Get.isRegistered<CancelBookingUseCase>()
        ? Get.find<CancelBookingUseCase>()
        : Get.put(CancelBookingUseCase(repo));

    _loadBookings();
  }

  Future<void> _loadBookings() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final bookings = await _getAllBookingsUseCase.call();

      if (!mounted) return;

      setState(() {
        _bookings = bookings;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      Get.snackbar(
        'Error',
        'Unable to load booking history.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _cancelBooking(Booking booking) async {
    final bool? confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Cancel Ticket?'),
        content: Text(
          'Are you sure you want to cancel booking '
          '${booking.bookingReference}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Keep Ticket'),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Cancel Ticket'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final bool success =
          await _cancelBookingUseCase.call(booking.bookingReference);

      if (!mounted) return;

      if (success) {
        Get.snackbar(
          'Ticket Cancelled',
          'Your booking has been cancelled successfully.',
          snackPosition: SnackPosition.BOTTOM,
        );

        await _loadBookings();
      } else {
        Get.snackbar(
          'Unable to Cancel',
          'This booking may already be cancelled or checked in.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (error) {
      if (!mounted) return;

      Get.snackbar(
        'Error',
        'Unable to cancel this booking. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking History'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loadBookings,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bookings.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.confirmation_number_outlined,
                          size: 64,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'No bookings yet',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Your event bookings will appear here.',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadBookings,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _bookings.length,
                    itemBuilder: (context, index) {
                      final booking = _bookings[index];

                      final bool isConfirmed =
                          booking.status.toLowerCase() == 'confirmed';

                      final bool canCancel =
                          isConfirmed && !booking.isCheckedIn;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 14),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.confirmation_number,
                                    size: 30,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      booking.bookingReference,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  _statusBadge(booking),
                                ],
                              ),
                              const Divider(height: 24),
                              _detail(
                                'Attendee',
                                booking.attendeeName,
                              ),
                              _detail(
                                'Email',
                                booking.attendeeEmail,
                              ),
                              _detail(
                                'Booking date',
                                _formatDate(booking.bookingDate),
                              ),
                              _detail(
                                'Amount paid',
                                '₹${booking.finalAmount.toStringAsFixed(2)}',
                              ),
                              _detail(
                                'Check-in',
                                booking.isCheckedIn
                                    ? 'Already checked in'
                                    : 'Not checked in',
                              ),
                              if (canCancel) ...[
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: () =>
                                        _cancelBooking(booking),
                                    icon: const Icon(
                                      Icons.cancel_outlined,
                                    ),
                                    label: const Text('Cancel Ticket'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _statusBadge(Booking booking) {
    final bool isConfirmed =
        booking.status.toLowerCase() == 'confirmed';

    final Color color = isConfirmed ? Colors.green : Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        booking.status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _detail(String label, String value) {
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

  String _formatDate(DateTime date) {
    final String day = date.day.toString().padLeft(2, '0');
    final String month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }
}
