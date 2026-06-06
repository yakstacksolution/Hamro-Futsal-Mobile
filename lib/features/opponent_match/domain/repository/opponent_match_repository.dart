import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/opponent_match/data/model/opponent_match_model.dart';
import 'package:hamro_footsall/features/opponent_match/domain/entities/opponent_match_entities.dart';

abstract class OpponentMatchRepository {
  Future<Either<AppException, List<TeamModel>>> getTeams();
  Future<Either<AppException, List<String>>> getVenues();
  Future<Either<AppException, List<OpponentRequestModel>>> getRequests();
  Future<Either<AppException, List<TeamModel>>> createTeam(String name);
  Future<Either<AppException, List<TeamModel>>> addPlayer(
    String teamId,
    PlayerModel player,
  );
  Future<Either<AppException, List<TeamModel>>> removePlayer(
    String teamId,
    int playerIndex,
  );
  Future<Either<AppException, List<OpponentRequestModel>>> sendRequest(
    CreateOpponentRequestEntity data,
  );
  Future<Either<AppException, List<OpponentRequestModel>>> updateRequestStatus(
    String id,
    RequestStatus status,
  );
  Future<Either<AppException, List<OpponentRequestModel>>> deleteRequest(
    String id,
  );
}
