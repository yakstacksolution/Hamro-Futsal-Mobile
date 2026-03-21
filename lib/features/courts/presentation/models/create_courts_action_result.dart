import 'package:hamro_footsall/features/courts/presentation/models/create_footsall_court_payload.dart';

class CreateCourtsActionResult {
  const CreateCourtsActionResult({this.payload, this.errorMessage});

  final CreateFootsallCourtPayload? payload;
  final String? errorMessage;
}
