
import 'package:sqflite/sqflite.dart';

import '../database/app_database.dart';
import '../../features/events/models/seat_model.dart';

class SeatRepository {
  final AppDatabase _appDatabase = AppDatabase.instance;

  /// Retrieves all seats belonging to a particular event.
  Future<List<SeatModel>> getSeatsByEventId(int eventId) async {
    final Database db = await _appDatabase.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'seats',
      where: 'event_id = ?',
      whereArgs: [eventId],
      orderBy: 'id ASC',
    );

    return maps.map(SeatModel.fromMap).toList();
  }

  /// Retrieves a particular seat by its database ID.
  Future<SeatModel?> getSeatById(int seatId) async {
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

    return SeatModel.fromMap(maps.first);
  }

  /// Retrieves seats belonging to a particular category.
  Future<List<SeatModel>> getSeatsByCategory({
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

    return maps.map(SeatModel.fromMap).toList();
  }
}
