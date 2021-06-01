package com.game.service.seniormine;

import com.game.grpc.proto.mine.*;
import com.game.server.GameContext;
import com.game.util.LogUtil;
import io.grpc.stub.StreamObserver;

/**
 * @author :yeding
 * @date ：Created in 2019/4/22 17:09
 * @description：远程实现
 */
public class SeniorMineRpcServiceImpl extends MineHandlerGrpc.MineHandlerImplBase {
    @Override
    public void scoutMine(CrossSeniorMineProto.RpcScoutMineRequest request, StreamObserver<CrossSeniorMineProto.RpcScoutMineResponse> responseObserver) {
        try {
            CrossSeniorMineProto.RpcScoutMineResponse response = GameContext.getAc().getBean(CrossSeniorMineService.class).scoutMine(request);
            responseObserver.onNext(response);
            responseObserver.onCompleted();
        } catch (Exception e) {
            LogUtil.error(e);
            responseObserver.onError(e);
        }
    }

    @Override
    public void findMine(CrossSeniorMineProto.RpcFindMineRequest request, StreamObserver<CrossSeniorMineProto.RpcFindMineResponse> responseObserver) {
        try {
            CrossSeniorMineProto.RpcFindMineResponse response = GameContext.getAc().getBean(CrossSeniorMineService.class).findMine(request);
            responseObserver.onNext(response);
            responseObserver.onCompleted();
        } catch (Exception e) {
            LogUtil.error(e);
            responseObserver.onError(e);
        }
    }

    @Override
    public void fightMine(CrossSeniorMineProto.FightMineRequest request, StreamObserver<CrossSeniorMineProto.FightMineResponse> responseObserver) {
        try {
            CrossSeniorMineProto.FightMineResponse response = GameContext.getAc().getBean(CrossSeniorMineService.class).fightMine(request);
            responseObserver.onNext(response);
            responseObserver.onCompleted();
        } catch (Exception e) {
            LogUtil.error(e);
            responseObserver.onError(e);
        }
    }

    @Override
    public void checkScoreRank(CrossSeniorMineProto.RpcScoreRankRequest request, StreamObserver<CrossSeniorMineProto.RpcScoreRankResponse> responseObserver) {
        try {
            CrossSeniorMineProto.RpcScoreRankResponse response = GameContext.getAc().getBean(CrossSeniorMineService.class).checkScoreRank(request);
            responseObserver.onNext(response);
            responseObserver.onCompleted();
        } catch (Exception e) {
            LogUtil.error(e);
            responseObserver.onError(e);
        }
    }

    @Override
    public void getScoreRank(CrossSeniorMineProto.RpcCoreAwardRequest request, StreamObserver<CrossSeniorMineProto.RpcCoreAwardResponse> responseObserver) {
        try {
            CrossSeniorMineProto.RpcCoreAwardResponse response = GameContext.getAc().getBean(CrossSeniorMineService.class).getScoreAward(request);
            responseObserver.onNext(response);
            responseObserver.onCompleted();
        } catch (Exception e) {
            LogUtil.error(e);
            responseObserver.onError(e);
        }
    }

    @Override
    public void checkServerScoreRank(CrossSeniorMineProto.RpcServerScoreRankRequest request, StreamObserver<CrossSeniorMineProto.RpcServerScoreRankResponse> responseObserver) {
        try {
            CrossSeniorMineProto.RpcServerScoreRankResponse response = GameContext.getAc().getBean(CrossSeniorMineService.class).getServerRankScore((int) request.getRoleId());
            responseObserver.onNext(response);
            responseObserver.onCompleted();
        } catch (Exception e) {
            LogUtil.error(e);
            responseObserver.onError(e);
        }
    }

    @Override
    public void getServerScoreRank(CrossSeniorMineProto.RpcCoreAwardRequest request, StreamObserver<CrossSeniorMineProto.RpcCoreAwardResponse> responseObserver) {
        try {
            CrossSeniorMineProto.RpcCoreAwardResponse response = GameContext.getAc().getBean(CrossSeniorMineService.class).getServerRankAward(request);
            responseObserver.onNext(response);
            responseObserver.onCompleted();
        } catch (Exception e) {
            LogUtil.error(e);
            responseObserver.onError(e);
        }
    }

    @Override
    public void retreatArmy(CrossSeniorMineProto.RpcRetreatArmyRequest request, StreamObserver<CrossSeniorMineProto.RpcRetreatArmyResponse> responseObserver) {
        try {
            CrossSeniorMineProto.RpcRetreatArmyResponse response = GameContext.getAc().getBean(CrossSeniorMineService.class).retreatArmy(request);
            responseObserver.onNext(response);
            responseObserver.onCompleted();
        } catch (Exception e) {
            LogUtil.error(e);
            responseObserver.onError(e);
        }
    }

    @Override
    public void crossMineGm(CrossSeniorMineProto.RpcGmquest request, StreamObserver<CrossSeniorMineProto.RpcRetreatArmyResponse> responseObserver) {
        try {
            CrossSeniorMineProto.RpcRetreatArmyResponse response = GameContext.getAc().getBean(CrossSeniorMineService.class).gmClear(request);
            responseObserver.onNext(response);
            responseObserver.onCompleted();
        } catch (Exception e) {
            LogUtil.error(e);
            responseObserver.onError(e);
        }
    }
}

