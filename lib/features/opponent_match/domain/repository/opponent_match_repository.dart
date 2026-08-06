import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/opponent_match/data/model/accept_opponent_request_request.dart';
import 'package:hamro_footsall/features/opponent_match/data/model/opponent_match_model.dart';
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
  Future<Either<AppException, List<OpponentRequestModel>>> sendRequest(
    CreateOpponentRequestEntity data,
  );
  Future<Either<AppException, List<OpponentRequestModel>>> declineRequest(
    String id,
  );
  Future<Either<AppException, List<OpponentRequestModel>>> deleteRequest(
    String id,
  );

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
