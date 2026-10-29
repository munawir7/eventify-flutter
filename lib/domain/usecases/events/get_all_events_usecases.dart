import '../../entities/event.dart';
import '../../repositories/event_repository.dart';

class GetAllEventsUseCase {
  final EventRepository _repository;

  GetAllEventsUseCase(this._repository);

  Future<List<Event>> call() {
    return _repository.getAllEvents();
  }
}