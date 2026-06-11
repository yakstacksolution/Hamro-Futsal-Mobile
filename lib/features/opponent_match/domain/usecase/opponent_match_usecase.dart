import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/opponent_match/data/model/opponent_match_model.dart';
import 'package:hamro_footsall/features/opponent_match/domain/entities/opponent_match_entities.dart';
import 'package:hamro_footsall/features/opponent_match/domain/repository/opponent_match_repository.dart';

final class OpponentMatchUseCase {
  const OpponentMatchUseCase(this.repository);

  final OpponentMatchRepository repository;

  Future<Either<AppException, List<TeamModel>>> getTeams() async =>
      await repository.getTeams();

  Future<Either<AppException, TeamModel>> getTeam(String teamId) async =>
      await repository.getTeam(teamId);

  Future<Either<AppException, List<String>>> getVenues() async =>
      await repository.getVenues();

  Future<Either<AppException, List<OpponentRequestModel>>> getRequests() async =>
      await repository.getRequests();

  Future<Either<AppException, List<TeamModel>>> createTeam(String name) async =>
      await repository.createTeam(name);

  Future<Either<AppException, List<TeamModel>>> updateTeam(
    String teamId,
    String name,
  ) async => await repository.updateTeam(teamId, name);

  Future<Either<AppException, List<TeamModel>>> deleteTeam(
    String teamId,
  ) async => await repository.deleteTeam(teamId);

  Future<Either<AppException, List<TeamModel>>> addMember(
    String teamId,
    PlayerModel player,
  ) async => await repository.addMember(teamId, player);

  Future<Either<AppException, List<TeamModel>>> removeMember(
    String teamId,
    String memberId,
  ) async => await repository.removeMember(teamId, memberId);

  Future<Either<AppException, List<OpponentRequestModel>>> sendRequest(
    CreateOpponentRequestEntity data,
  ) async => await repository.sendRequest(data);

  Future<Either<AppException, List<OpponentRequestModel>>> updateRequestStatus(
    String id,
    RequestStatus status,
  ) async => await repository.updateRequestStatus(id, status);

  Future<Either<AppException, List<OpponentRequestModel>>> deleteRequest(
    String id,
  ) async => await repository.deleteRequest(id);
}
