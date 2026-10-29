import '../../entities/booking_request.dart';
import '../../repositories/booking_repository.dart';

class CreateBookingUseCase {
final BookingRepository _repository;

CreateBookingUseCase(this._repository);

Future<String> call(BookingRequest request) {
return _repository.createBooking(request);
}
}
