import 'dart:developer' as developer;

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../core/constants/app_constants.dart';
import 'seed_data.dart';

class AppDatabase {
AppDatabase._();

static final AppDatabase instance = AppDatabase._();

Database? _database;

Future<Database> get database async {
if (_database != null && _database!.isOpen) {
return _database!;
}

try {
  final database = await _initDatabase();
  _database = database;
  return database;
} on DatabaseException catch (e, stackTrace) {
  developer.log(
    'Failed to initialize Eventify database.',
    error: e,
    stackTrace: stackTrace,
    name: 'Eventify.AppDatabase',
  );

  rethrow;
} catch (e, stackTrace) {
  developer.log(
    'Unexpected error during database initialization.',
    error: e,
    stackTrace: stackTrace,
    name: 'Eventify.AppDatabase',
  );

  rethrow;
}

}

Future<Database> _initDatabase() async {
try {
final databasePath = await getDatabasesPath();

  final path = join(
    databasePath,
    AppConstants.databaseName,
  );

  return await openDatabase(
    path,
    version: AppConstants.databaseVersion,
    onConfigure: _onConfigure,
    onCreate: _createTables,
  );
} on DatabaseException catch (e, stackTrace) {
  developer.log(
    'SQLite could not open the Eventify database.',
    error: e,
    stackTrace: stackTrace,
    name: 'Eventify.AppDatabase',
  );

  rethrow;
} catch (e, stackTrace) {
  developer.log(
    'Unexpected error while opening the Eventify database.',
    error: e,
    stackTrace: stackTrace,
    name: 'Eventify.AppDatabase',
  );

  rethrow;
}

}

Future<void> _onConfigure(Database db) async {
try {
await db.execute('PRAGMA foreign_keys = ON');
} on DatabaseException catch (e, stackTrace) {
developer.log(
'Failed to enable SQLite foreign-key enforcement.',
error: e,
stackTrace: stackTrace,
name: 'Eventify.AppDatabase',
);

  rethrow;
}

}

Future<void> _createTables(
Database db,
int version,
) async {
try {
await db.execute('''
CREATE TABLE events (
id INTEGER PRIMARY KEY AUTOINCREMENT,
title TEXT NOT NULL,
category TEXT NOT NULL,
description TEXT NOT NULL,
venue TEXT NOT NULL,
event_date TEXT NOT NULL,
price REAL NOT NULL,
poster_url TEXT NOT NULL,
total_seats INTEGER NOT NULL,
is_featured INTEGER NOT NULL DEFAULT 0
)
''');

  await db.execute('''
    CREATE TABLE seats (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      event_id INTEGER NOT NULL,
      seat_number TEXT NOT NULL,
      category TEXT NOT NULL,
      price REAL NOT NULL,
      status TEXT NOT NULL DEFAULT 'available',
      FOREIGN KEY (event_id) REFERENCES events (id),
      UNIQUE (event_id, seat_number)
    )
  ''');

  await db.execute('''
    CREATE TABLE bookings (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      booking_reference TEXT NOT NULL UNIQUE,
      event_id INTEGER NOT NULL,
      attendee_name TEXT NOT NULL,
      attendee_email TEXT NOT NULL,
      attendee_phone TEXT NOT NULL,
      total_amount REAL NOT NULL,
      discount_amount REAL NOT NULL DEFAULT 0,
      final_amount REAL NOT NULL,
      booking_date TEXT NOT NULL,
      status TEXT NOT NULL DEFAULT 'confirmed',
      checked_in INTEGER NOT NULL DEFAULT 0,
      FOREIGN KEY (event_id) REFERENCES events (id)
    )
  ''');

  await db.execute('''
    CREATE TABLE booking_seats (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      booking_id INTEGER NOT NULL,
      seat_id INTEGER NOT NULL,
      FOREIGN KEY (booking_id) REFERENCES bookings (id),
      FOREIGN KEY (seat_id) REFERENCES seats (id),
      UNIQUE (booking_id, seat_id),
      UNIQUE (seat_id)
    )
  ''');

  await db.execute('''
    CREATE TABLE favourites (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      event_id INTEGER NOT NULL UNIQUE,
      FOREIGN KEY (event_id) REFERENCES events (id)
    )
  ''');

  await SeedData.insertSampleData(db);

  developer.log(
    'Eventify database tables created successfully.',
    name: 'Eventify.AppDatabase',
  );
} on DatabaseException catch (e, stackTrace) {
  developer.log(
    'Database error while creating tables or inserting sample data.',
    error: e,
    stackTrace: stackTrace,
    name: 'Eventify.AppDatabase',
  );

  rethrow;
} catch (e, stackTrace) {
  developer.log(
    'Unexpected error while creating tables or inserting sample data.',
    error: e,
    stackTrace: stackTrace,
    name: 'Eventify.AppDatabase',
  );

  rethrow;
}

}
}
