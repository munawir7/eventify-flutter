import '../entities/event.dart';

abstract class EventRepository {
  Future<List<Event>> getAllEvents();

  Future<Event?> getEventById(int id);

  Future<List<Event>> searchEvents(String query);

  Future<List<Event>> getEventsByCategory(String category);

  Future<List<Event>> getEventsSortedByPrice({
    bool ascending = true,
  });

  Future<List<Event>> getEventsSortedByDate({
    bool ascending = true,
  });
}