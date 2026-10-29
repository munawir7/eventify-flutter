
import 'package:sqflite/sqflite.dart';

import '../database/app_database.dart';
import '../../domain/entities/seat.dart' as domain_entity;
import '../../domain/repositories/seat_repository.dart'
    as domain_repository;
import '../../features/events/models/seat_model.dart';

class SeatRepository implements domain_repository.SeatRepository {
  SeatRepository({AppDatabase? appDatabase})
      : _appDatabase = appDatabase ?? AppDatabase.instance;

  final AppDatabase _appDatabase;

  // Convert the database model into a domain entity.
  domain_entity.Seat _toEntity(SeatModel model) {
    return domain_entity.Seat(
      id: model.id,
      eventId: model.eventId,
      seatNumber: model.seatNumber,
      category: model.category,
      price: model.price,
      status: model.status,
    );
  }

  @override
  Future<List<domain_entity.Seat>> getSeatsByEventId(
    int eventId,
  ) async {
    final Database db = await _appDatabase.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'seats',
      where: 'event_id = ?',
      whereArgs: [eventId],
      orderBy: 'id ASC',
    );

    return maps.map(SeatModel.fromMap).map(_toEntity).toList();
  }

  @override
  Future<domain_entity.Seat?> getSeatById(int seatId) async {
    final Database db = await _appDatabase.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'seats',
      where: 'id = ?',
      whereArgs: [seatId],
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return _toEntity(SeatModel.fromMap(maps.first));
  }

  @override
  Future<List<domain_entity.Seat>> getSeatsByCategory({
    required int eventId,
    required String category,
  }) async {
    final Database db = await _appDatabase.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'seats',
      where: 'event_id = ? AND category = ?',
      whereArgs: [eventId, category],
      orderBy: 'id ASC',
    );

    return maps.map(SeatModel.fromMap).map(_toEntity).toList();
  }
}