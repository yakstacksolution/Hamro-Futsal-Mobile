import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/opponent_match/data/model/accept_opponent_request_request.dart';
import 'package:hamro_footsall/features/opponent_match/data/model/opponent_match_model.dart';
import 'package:hamro_footsall/features/opponent_match/data/model/opponent_match_step_request.dart';
import 'package:hamro_footsall/features/opponent_match/data/model/opponent_request_tab.dart';
import 'package:hamro_footsall/features/opponent_match/domain/entities/opponent_match_entities.dart';

abstract class OpponentMatchRepository {
  Future<Either<AppException, List<TeamModel>>> getTeams();
  Future<Either<AppException, TeamModel>> getTeam(String teamId);
  Future<Either<AppException, List<PlayerPositionModel>>> getPositions();
  Future<Either<AppException, List<OpponentLevelModel>>> getOpponentLevels();
  Future<Either<AppException, List<String>>> getVenues();
  Future<Either<AppException, List<OpponentRequestModel>>> getRequests();
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

  /// Opens a request from the wizard's first step, or re-sends the match
  /// section of one already opened when [requestId] is given. Resolves to the
  /// request's id either way.
  Future<Either<AppException, OpponentRequestRefModel>> saveMatchStep(
    OpponentMatchStepRequest data, {
    String? requestId,
  });

  /// One server-side slice of `GET /auth/opponent-requests?tab=…`. Each
  /// section of the requests list maps to its own [OpponentRequestTab].
  Future<Either<AppException, List<OpponentRequestModel>>> getRequestsByTab(
    OpponentRequestTab tab,
  );

  /// The signed-in user's own opponent requests — shorthand for
  /// [getRequestsByTab] with [OpponentRequestTab.myRequests].
  Future<Either<AppException, List<OpponentRequestModel>>> getMyRequests();

  /// `GET /auth/opponent-requests/{id}` — one of my own requests, drafts
  /// included. The wizard hydrates a resumed draft from this.
  Future<Either<AppException, OpponentRequestModel>> getMyRequest(String id);

  /// Sends the wizard's second step — the venue behind the match — against the
  /// request [requestId] opened by the first step.
  Future<Either<AppException, OpponentRequestRefModel>> saveVenueStep(
    String requestId,
    OpponentVenueStepRequest data,
  );

  /// `PUT /auth/opponent-requests/{id}/cost` — the wizard's third step.
  Future<Either<AppException, OpponentRequestRefModel>> saveCostStep(
    String requestId,
    OpponentCostStepRequest data,
  );

  /// `POST /auth/opponent-requests/{id}/publish` — the wizard's last step.
  /// Returns the server's confirmation message.
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

  /// `DELETE /auth/opponent-requests/{id}`. Returns the server's confirmation
  /// message; the deleted row is dropped from state locally, so no list is
  /// re-fetched.
  Future<Either<AppException, String>> deleteRequest(String id);

  /// Requester confirms the accepting team — the match is created and the
  /// venue linked.
  Future<Either<AppException, List<OpponentRequestModel>>> selectOpponent(
    String id,
  );

  /// Requester turns the acceptance down with [reason] — the request re-opens
  /// for other teams.
  Future<Either<AppException, List<OpponentRequestModel>>> rejectInvitation(
    String id,
    String reason,
  );

  /// Accepts the request with one of my teams; returns the updated request
  /// (`invitationSent` until the requester picks an opponent).
  Future<Either<AppException, OpponentRequestModel>> acceptRequest(
    AcceptOpponentRequestRequest request,
  );
}
