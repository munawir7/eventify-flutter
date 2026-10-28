
import 'package:eventify/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../models/event_model.dart';

class EventDetailsScreen extends StatelessWidget {
  final EventModel event;

  const EventDetailsScreen({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event poster placeholder.
            Container(
              width: double.infinity,
              height: 230,
              color: theme.colorScheme.primaryContainer,
              child: Icon(
                _getCategoryIcon(event.category),
                size: 100,
                color: theme.colorScheme.primary,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category and featured badge.
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(
                        avatar: Icon(
                          _getCategoryIcon(event.category),
                          size: 18,
                        ),
                        label: Text(event.category),
                      ),
                      if (event.isFeatured)
                        const Chip(
                          avatar: Icon(
                            Icons.star,
                            size: 18,
                            color: Colors.amber,
                          ),
                          label: Text('Featured Event'),
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Event title.
                  Text(
                    event.title,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Event date and time.
                  _buildInfoRow(
                    context,
                    icon: Icons.calendar_month_outlined,
                    title: 'Date & Time',
                    value: DateFormat('EEEE, dd MMM yyyy • hh:mm a')
                        .format(event.eventDate),
                  ),

                  const SizedBox(height: 16),

                  // Venue.
                  _buildInfoRow(
                    context,
                    icon: Icons.location_on_outlined,
                    title: 'Venue',
                    value: event.venue,
                  ),

                  const SizedBox(height: 16),

                  // Total seats.
                  _buildInfoRow(
                    context,
                    icon: Icons.event_seat_outlined,
                    title: 'Total Seats',
                    value: '${event.totalSeats} seats',
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'About this event',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    event.description,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Price information.
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Starting from',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₹${event.price.toStringAsFixed(0)}',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Final price depends on your selected seats.',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

              
// Continue to seat selection.
SizedBox(
  width: double.infinity,
  height: 54,
  child: FilledButton.icon(
    onPressed: () {
      Get.toNamed(
        AppRoutes.seatSelection,
        arguments: event,
      );
    },
    icon: const Icon(Icons.event_seat_outlined),
    label: const Text(
      'Choose Seats',
      style: TextStyle(fontSize: 16),
    ),
  ),
),

const SizedBox(height: 16),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: theme.colorScheme.primary,
          size: 24,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'music':
        return Icons.music_note;
      case 'movies':
        return Icons.movie_outlined;
      case 'sports':
        return Icons.sports_soccer;
      case 'workshop':
        return Icons.laptop_mac;
      case 'conference':
        return Icons.groups_outlined;
      default:
        return Icons.event;
    }
  }
}
