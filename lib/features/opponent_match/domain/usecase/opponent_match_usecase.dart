import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/opponent_match/data/model/accept_opponent_request_request.dart';
import 'package:hamro_footsall/features/opponent_match/data/model/opponent_accept_quote_model.dart';
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

  Future<Either<AppException, List<PlayerPositionModel>>>
  getPositions() async => await repository.getPositions();

  Future<Either<AppException, List<OpponentLevelModel>>>
  getOpponentLevels() async => await repository.getOpponentLevels();

  Future<Either<AppException, List<String>>> getVenues() async =>
      await repository.getVenues();

  Future<Either<AppException, List<OpponentRequestModel>>>
  getRequests() async => await repository.getRequests();

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

  Future<Either<AppException, List<TeamModel>>> updateMember(
    String teamId,
    PlayerModel player,
  ) async => await repository.updateMember(teamId, player);

  Future<Either<AppException, List<TeamModel>>> removeMember(
    String teamId,
    String memberId,
  ) async => await repository.removeMember(teamId, memberId);

  Future<Either<AppException, List<OpponentRequestModel>>> sendRequest(
    CreateOpponentRequestEntity data,
  ) async => await repository.sendRequest(data);

  Future<Either<AppException, List<OpponentRequestModel>>> declineRequest(
    String id,
  ) async => await repository.declineRequest(id);

  Future<Either<AppException, List<OpponentRequestModel>>> deleteRequest(
    String id,
  ) async => await repository.deleteRequest(id);

  Future<Either<AppException, List<OpponentRequestModel>>> verifyPayment(
    String id,
  ) async => await repository.verifyPayment(id);

  Future<Either<AppException, List<OpponentRequestModel>>> rejectPayment(
    String id,
    String reason,
  ) async => await repository.rejectPayment(id, reason);

  Future<Either<AppException, OpponentAcceptQuoteModel>> getAcceptQuote(
    String requestId,
    String teamId,
  ) async => await repository.getAcceptQuote(requestId, teamId);

  Future<Either<AppException, OpponentRequestModel>> acceptRequest(
    AcceptOpponentRequestRequest request,
  ) async => await repository.acceptRequest(request);
}
