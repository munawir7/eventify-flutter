import 'dart:developer' as developer;

import 'package:sqflite/sqflite.dart';

import '../../data/database/app_database.dart';
import '../../domain/entities/event.dart';
import '../../domain/repositories/event_repository.dart' as domain;
import '../../features/events/models/event_model.dart';

class EventRepository implements domain.EventRepository {
  EventRepository({AppDatabase? appDatabase})
      : _appDatabase = appDatabase ?? AppDatabase.instance;

  final AppDatabase _appDatabase;

  static const String _logName = 'Eventify.EventRepository';

  void _logError(
    String operation,
    Object error,
    StackTrace stackTrace,
  ) {
    developer.log(
      'Failed to $operation.',
      error: error,
      stackTrace: stackTrace,
      name: _logName,
    );
  }

  // Convert the database model into a domain entity.
  Event _toEntity(EventModel model) {
    return Event(
      id: model.id,
      title: model.title,
      category: model.category,
      description: model.description,
      venue: model.venue,
      eventDate: model.eventDate,
      price: model.price,
      posterUrl: model.posterUrl,
      totalSeats: model.totalSeats,
      isFeatured: model.isFeatured,
    );
  }

  @override
  Future<List<Event>> getAllEvents() async {
    try {
      final Database db = await _appDatabase.database;

      final List<Map<String, dynamic>> maps = await db.query(
        'events',
        orderBy: 'event_date ASC',
      );

      return maps
          .map(EventModel.fromMap)
          .map(_toEntity)
          .toList();
    } on DatabaseException catch (e, stackTrace) {
      _logError('fetch all events', e, stackTrace);
      rethrow;
    } catch (e, stackTrace) {
      _logError('convert or fetch all events', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<Event?> getEventById(int id) async {
    try {
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

      return _toEntity(EventModel.fromMap(maps.first));
    } on DatabaseException catch (e, stackTrace) {
      _logError('fetch event by ID', e, stackTrace);
      rethrow;
    } catch (e, stackTrace) {
      _logError('convert or fetch event by ID', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<List<Event>> searchEvents(String query) async {
    try {
      final Database db = await _appDatabase.database;
      final searchQuery = query.trim();

      final List<Map<String, dynamic>> maps = await db.query(
        'events',
        where: '''
          title LIKE ? OR
          category LIKE ? OR
          venue LIKE ?
        ''',
        whereArgs: [
          '%$searchQuery%',
          '%$searchQuery%',
          '%$searchQuery%',
        ],
        orderBy: 'event_date ASC',
      );

      return maps
          .map(EventModel.fromMap)
          .map(_toEntity)
          .toList();
    } on DatabaseException catch (e, stackTrace) {
      _logError('search events', e, stackTrace);
      rethrow;
    } catch (e, stackTrace) {
      _logError('convert or search events', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<List<Event>> getEventsByCategory(String category) async {
    try {
      final Database db = await _appDatabase.database;

      final List<Map<String, dynamic>> maps = await db.query(
        'events',
        where: 'category = ?',
        whereArgs: [category],
        orderBy: 'event_date ASC',
      );

      return maps
          .map(EventModel.fromMap)
          .map(_toEntity)
          .toList();
    } on DatabaseException catch (e, stackTrace) {
      _logError('fetch events by category', e, stackTrace);
      rethrow;
    } catch (e, stackTrace) {
      _logError('convert or fetch events by category', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<List<Event>> getEventsSortedByPrice({
    bool ascending = true,
  }) async {
    try {
      final Database db = await _appDatabase.database;

      final List<Map<String, dynamic>> maps = await db.query(
        'events',
        orderBy: 'price ${ascending ? 'ASC' : 'DESC'}',
      );

      return maps
          .map(EventModel.fromMap)
          .map(_toEntity)
          .toList();
    } on DatabaseException catch (e, stackTrace) {
      _logError('sort events by price', e, stackTrace);
      rethrow;
    } catch (e, stackTrace) {
      _logError('convert or sort events by price', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<List<Event>> getEventsSortedByDate({
    bool ascending = true,
  }) async {
    try {
      final Database db = await _appDatabase.database;

      final List<Map<String, dynamic>> maps = await db.query(
        'events',
        orderBy: 'event_date ${ascending ? 'ASC' : 'DESC'}',
      );

      return maps
          .map(EventModel.fromMap)
          .map(_toEntity)
          .toList();
    } on DatabaseException catch (e, stackTrace) {
      _logError('sort events by date', e, stackTrace);
      rethrow;
    } catch (e, stackTrace) {
      _logError('convert or sort events by date', e, stackTrace);
      rethrow;
    }
  }
}