
import 'package:sqflite/sqflite.dart';

import '../../data/database/app_database.dart';
import '../../features/events/models/event_model.dart';

class EventRepository {
  final AppDatabase _appDatabase = AppDatabase.instance;

  Future<List<EventModel>> getAllEvents() async {
    final Database db = await _appDatabase.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'events',
      orderBy: 'event_date ASC',
    );

    return maps.map(EventModel.fromMap).toList();
  }

  Future<EventModel?> getEventById(int id) async {
    final Database db = await _appDatabase.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'events',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return EventModel.fromMap(maps.first);
  }

  Future<List<EventModel>> searchEvents(String query) async {
    final Database db = await _appDatabase.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'events',
      where: '''
        title LIKE ? OR
        category LIKE ? OR
        venue LIKE ?
      ''',
      whereArgs: [
        '%$query%',
        '%$query%',
        '%$query%',
      ],
      orderBy: 'event_date ASC',
    );

    return maps.map(EventModel.fromMap).toList();
  }

  Future<List<EventModel>> getEventsByCategory(
    String category,
  ) async {
    final Database db = await _appDatabase.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'events',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'event_date ASC',
    );

    return maps.map(EventModel.fromMap).toList();
  }

  Future<List<EventModel>> getEventsSortedByPrice({
    bool ascending = true,
  }) async {
    final Database db = await _appDatabase.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'events',
      orderBy: 'price ${ascending ? 'ASC' : 'DESC'}',
    );

    return maps.map(EventModel.fromMap).toList();
  }

  Future<List<EventModel>> getEventsSortedByDate({
    bool ascending = true,
  }) async {
    final Database db = await _appDatabase.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'events',
      orderBy: 'event_date ${ascending ? 'ASC' : 'DESC'}',
    );

    return maps.map(EventModel.fromMap).toList();
  }
}
