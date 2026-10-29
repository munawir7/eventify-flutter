import 'dart:developer' as developer;

import 'package:sqflite/sqflite.dart';

class SeedData {
SeedData._();

static Future<void> insertSampleData(Database db) async {
try {
await db.transaction((txn) async {
final existingEvents = await txn.query(
'events',
columns: ['id'],
limit: 1,
);


    // Insert sample data only when the events table is empty.
    if (existingEvents.isNotEmpty) {
      return;
    }

    final batch = txn.batch();

    final sampleEvents = [
      {
        'title': 'Live Music Night',
        'category': 'Music',
        'description':
            'Enjoy an unforgettable evening with live music, '
                'amazing performances, and your favourite songs.',
        'venue': 'Calicut Beach, Kozhikode',
        'event_date': DateTime.now()
            .add(const Duration(days: 7))
            .toIso8601String(),
        'price': 499.0,
        'poster_url': '',
        'total_seats': 20,
        'is_featured': 1,
      },
      {
        'title': 'Champions Football Cup',
        'category': 'Sports',
        'description':
            'Experience the excitement of a thrilling football '
                'match with passionate fans and incredible action.',
        'venue': 'EMS Stadium, Kozhikode',
        'event_date': DateTime.now()
            .add(const Duration(days: 14))
            .toIso8601String(),
        'price': 699.0,
        'poster_url': '',
        'total_seats': 20,
        'is_featured': 1,
      },
      {
        'title': 'Flutter Developer Workshop',
        'category': 'Workshop',
        'description':
            'Learn Flutter development, state management, '
                'and mobile application architecture in this '
                'beginner-friendly workshop.',
        'venue': 'Technology Centre, Kozhikode',
        'event_date': DateTime.now()
            .add(const Duration(days: 21))
            .toIso8601String(),
        'price': 299.0,
        'poster_url': '',
        'total_seats': 20,
        'is_featured': 0,
      },
      {
        'title': 'Movie Premiere Night',
        'category': 'Movies',
        'description':
            'Join us for a special movie screening experience '
                'with comfortable seating and a cinematic atmosphere.',
        'venue': 'Mall Cinema, Kozhikode',
        'event_date': DateTime.now()
            .add(const Duration(days: 10))
            .toIso8601String(),
        'price': 399.0,
        'poster_url': '',
        'total_seats': 20,
        'is_featured': 0,
      },
      {
        'title': 'Tech Innovation Conference',
        'category': 'Conference',
        'description':
            'Explore modern technology, connect with developers, '
                'and discover new ideas from the technology industry.',
        'venue': 'Convention Centre, Kozhikode',
        'event_date': DateTime.now()
            .add(const Duration(days: 30))
            .toIso8601String(),
        'price': 999.0,
        'poster_url': '',
        'total_seats': 20,
        'is_featured': 1,
      },
    ];

    for (final event in sampleEvents) {
      final eventId = await txn.insert(
        'events',
        event,
      );

      // Create seats for this event.
      for (int i = 1; i <= 10; i++) {
        batch.insert('seats', {
          'event_id': eventId,
          'seat_number': 'A$i',
          'category': 'Regular',
          'price': 499.0,
          'status': 'available',
        });
      }

      for (int i = 1; i <= 6; i++) {
        batch.insert('seats', {
          'event_id': eventId,
          'seat_number': 'B$i',
          'category': 'Premium',
          'price': 799.0,
          'status': 'available',
        });
      }

      for (int i = 1; i <= 4; i++) {
        batch.insert('seats', {
          'event_id': eventId,
          'seat_number': 'C$i',
          'category': 'VIP',
          'price': 1499.0,
          'status': 'available',
        });
      }
    }

    // Insert all seats as part of the same transaction.
    await batch.commit(noResult: true);
  });

  developer.log(
    'Sample data initialized successfully.',
    name: 'Eventify.SeedData',
  );
} on DatabaseException catch (e, stackTrace) {
  developer.log(
    'Database error while inserting sample data.',
    error: e,
    stackTrace: stackTrace,
    name: 'Eventify.SeedData',
  );

  rethrow;
} catch (e, stackTrace) {
  developer.log(
    'Unexpected error while initializing sample data.',
    error: e,
    stackTrace: stackTrace,
    name: 'Eventify.SeedData',
  );

  rethrow;
}


}
}
