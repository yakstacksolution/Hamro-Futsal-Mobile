import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/opponent_match/data/model/accept_opponent_request_request.dart';
import 'package:hamro_footsall/features/opponent_match/data/model/opponent_accept_quote_model.dart';
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

  /// Requester approves the accepter's advance — the match is confirmed.
  Future<Either<AppException, List<OpponentRequestModel>>> verifyPayment(
    String id,
  );

  /// Requester rejects the proof with [reason] — the request re-opens.
  Future<Either<AppException, List<OpponentRequestModel>>> rejectPayment(
    String id,
    String reason,
  );

  /// Step 1 of accepting: places the accept hold and returns the
  /// server-authoritative advance quote + payment QR.
  Future<Either<AppException, OpponentAcceptQuoteModel>> getAcceptQuote(
    String requestId,
    String teamId,
  );

  /// Step 2 of accepting: submits the hold token + payment proof; returns the
  /// updated request (`paymentPending` until the advance is verified).
  Future<Either<AppException, OpponentRequestModel>> acceptRequest(
    AcceptOpponentRequestRequest request,
  );
}
