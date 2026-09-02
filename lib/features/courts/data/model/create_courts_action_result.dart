import 'package:hamro_futsal/features/courts/data/model/create_futsal_court_payload.dart';

class CreateCourtsActionResult {
  const CreateCourtsActionResult({this.payload, this.errorMessage});

  final CreateFutsalCourtPayload? payload;
  final String? errorMessage;
}
