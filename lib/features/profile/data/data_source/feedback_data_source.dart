import 'package:hamro_footsall/core/api/api_client/result.dart';
import 'package:hamro_footsall/core/api/client.dart';

abstract class FeedbackRemoteDataSource {
  Future<Result> getFeedbackTypes();
  Future<Result> getFeedbackCategories();
  Future<Result> submitFeedback(Map<String, dynamic> data);
  Future<Result> getMyFeedback({int perPage = 15});
  Future<Result> getFeedbackDetails(String feedbackId);
}

final class FeedbackDataSourceImpl implements FeedbackRemoteDataSource {
  @override
  Future<Result> getFeedbackTypes() async =>
      await Client.instance().getAuthManager().getFeedbackTypes();

  @override
  Future<Result> getFeedbackCategories() async =>
      await Client.instance().getAuthManager().getFeedbackCategories();

  @override
  Future<Result> submitFeedback(Map<String, dynamic> data) async =>
      await Client.instance().getAuthManager().submitFeedback(data);

  @override
  Future<Result> getMyFeedback({int perPage = 15}) async =>
      await Client.instance().getAuthManager().getMyFeedback(perPage: perPage);

  @override
  Future<Result> getFeedbackDetails(String feedbackId) async =>
      await Client.instance().getAuthManager().getFeedbackDetails(feedbackId);
}
