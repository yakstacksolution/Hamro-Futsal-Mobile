import 'package:dartz/dartz.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/features/opponent_match/data/model/accept_opponent_request_request.dart';
import 'package:hamro_futsal/features/opponent_match/data/model/opponent_match_details_model.dart';
import 'package:hamro_futsal/features/opponent_match/data/model/opponent_match_model.dart';
import 'package:hamro_futsal/features/opponent_match/data/model/opponent_match_step_request.dart';
import 'package:hamro_futsal/features/opponent_match/data/model/opponent_request_page_model.dart';
import 'package:hamro_futsal/features/opponent_match/data/model/opponent_request_tab.dart';
import 'package:hamro_futsal/features/opponent_match/domain/entities/opponent_match_entities.dart';

abstract class OpponentMatchRepository {
  Future<Either<AppException, List<TeamModel>>> getTeams();
  Future<Either<AppException, TeamModel>> getTeam(String teamId);
  Future<Either<AppException, List<PlayerPositionModel>>> getPositions();
  Future<Either<AppException, List<OpponentLevelModel>>> getOpponentLevels();
  Future<Either<AppException, List<String>>> getVenues();
  Future<Either<AppException, List<TeamModel>>> createTeam(String name);
  Future<Either<AppException, List<TeamModel>>> updateTeam(
    String teamId,
    String name,
  );
  Future<Either<AppException, List<TeamModel>>> deleteTeam(String teamId);
  Future<Either<AppException, List<TeamModel>>> addMember(
    String teamId,
    PlayerModel player,
  );
  Future<Either<AppException, List<TeamModel>>> updateMember(
    String teamId,
    PlayerModel player,
  );
  Future<Either<AppException, List<TeamModel>>> removeMember(
    String teamId,
    String memberId,
  );

  Future<Either<AppException, OpponentRequestRefModel>> saveMatchStep(
    OpponentMatchStepRequest data, {
    String? requestId,
  });

  Future<Either<AppException, OpponentMatchDetailsModel>> getMatchDetails(
    String id,
  );

  Future<Either<AppException, OpponentRequestPageModel>> getRequestsByTab(
    OpponentRequestTab tab, {
    int page = 1,
    int perPage = 15,
  });

  Future<Either<AppException, List<OpponentRequestModel>>> getMyRequests();

  Future<Either<AppException, OpponentRequestModel>> getMyRequest(String id);

  Future<Either<AppException, List<OpponentInvitationModel>>> getInvitations(
    String requestId,
  );

  Future<Either<AppException, OpponentRequestRefModel>> saveVenueStep(
    String requestId,
    OpponentVenueStepRequest data,
  );

  Future<Either<AppException, OpponentRequestRefModel>> saveCostStep(
    String requestId,
    OpponentCostStepRequest data,
  );

  Future<Either<AppException, String>> publishRequest(
    String requestId, {
    String message = '',
  });

  Future<Either<AppException, List<OpponentRequestModel>>> sendRequest(
    CreateOpponentRequestEntity data,
  );
  Future<Either<AppException, List<OpponentRequestModel>>> declineRequest(
    String id,
  );

  Future<Either<AppException, String>> deleteRequest(String id);

  Future<Either<AppException, List<OpponentRequestModel>>> selectOpponent(
    String id,
    String invitationId,
  );

  Future<Either<AppException, List<OpponentRequestModel>>> rejectInvitation(
    String id,
    String reason,
  );

  Future<Either<AppException, OpponentRequestModel>> acceptRequest(
    AcceptOpponentRequestRequest request,
  );
}
