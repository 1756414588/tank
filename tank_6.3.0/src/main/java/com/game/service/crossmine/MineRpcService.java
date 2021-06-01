package com.game.service.crossmine;

import com.game.common.ServerSetting;
import com.game.grpc.proto.mine.*;
import com.game.server.GameServer;
import com.game.server.rpc.pool.GRpcConnection;
import com.game.server.rpc.pool.GRpcPoolManager;
import com.game.util.LogUtil;
import com.google.common.util.concurrent.ListenableFuture;

import java.util.concurrent.TimeUnit;

/**
 * @author yeding
 * @create 2019/6/15 12:52
 * @decs
 */
public class MineRpcService {


    public static final long timeOut = 300L;


    /**
     * 查看跨服矿
     *
     * @return
     */
    public static CrossSeniorMineProto.RpcFindMineResponse findMine(CrossSeniorMineProto.RpcFindMineRequest.Builder builder) {
        try {
            MineHandlerGrpc.MineHandlerFutureStub stub = getStub();
            if (stub == null) {
                return null;
            }
            long t = System.currentTimeMillis();
            ListenableFuture<CrossSeniorMineProto.RpcFindMineResponse> response = stub.findMine(builder.build());
            CrossSeniorMineProto.RpcFindMineResponse rpcfindMineResponse = response.get(timeOut, TimeUnit.MILLISECONDS);
            LogUtil.crossInfo(" 查看矿区地图信息 耗时 roleId={}, {} ms", builder.build().getRoleId(), (System.currentTimeMillis() - t));
            return rpcfindMineResponse;
        } catch (Exception e) {
            LogUtil.error(e);
        }
        return null;
    }


    /**
     * 侦查矿
     *
     * @param roleId
     * @return
     */
    public static CrossSeniorMineProto.RpcScoutMineResponse scoutMine(long roleId, int now, int pos) {
        try {
            MineHandlerGrpc.MineHandlerFutureStub stub = getStub();
            if (stub == null) {
                return null;
            }
            CrossSeniorMineProto.RpcScoutMineRequest.Builder builder = CrossSeniorMineProto.RpcScoutMineRequest.newBuilder();
            builder.setRoleId(roleId);
            builder.setTime(now);
            builder.setPos(pos);
            long t = System.currentTimeMillis();
            ListenableFuture<CrossSeniorMineProto.RpcScoutMineResponse> response = stub.scoutMine(builder.build());
            CrossSeniorMineProto.RpcScoutMineResponse rpcScoutMineResponse = response.get(timeOut, TimeUnit.MILLISECONDS);
            LogUtil.crossInfo(" 侦查矿 耗时 roleId={}, {} ms", roleId, (System.currentTimeMillis() - t));
            return rpcScoutMineResponse;
        } catch (Exception e) {
            LogUtil.error(e);
        }
        return null;
    }

    /**
     * 侦查矿
     *
     * @param roleId
     * @return
     */
    public static CrossSeniorMineProto.FightMineResponse fightMine(long roleId, int pos, int type, int num) {
        try {
            MineHandlerGrpc.MineHandlerFutureStub stub = getStub();
            if (stub == null) {
                return null;
            }
            CrossSeniorMineProto.FightMineRequest.Builder builder = CrossSeniorMineProto.FightMineRequest.newBuilder();
            builder.setRoleId(roleId);
            builder.setPos(pos);
            builder.setType(type);
            builder.setNum(num);
            long t = System.currentTimeMillis();
            ListenableFuture<CrossSeniorMineProto.FightMineResponse> response = stub.fightMine(builder.build());
            CrossSeniorMineProto.FightMineResponse rpcScoutMineResponse = response.get(timeOut, TimeUnit.MILLISECONDS);
            LogUtil.crossInfo(" 侦查矿 耗时 roleId={}, {} ms", roleId, (System.currentTimeMillis() - t));
            return rpcScoutMineResponse;
        } catch (Exception e) {
            LogUtil.error(e);
        }
        return null;
    }


    /**
     * 查看排名
     *
     * @param roleId
     * @return
     */
    public static CrossSeniorMineProto.RpcScoreRankResponse checkScoreRank(long roleId) {

        try {
            MineHandlerGrpc.MineHandlerFutureStub stub = getStub();
            if (stub == null) {
                return null;
            }
            CrossSeniorMineProto.RpcScoreRankRequest.Builder builder = CrossSeniorMineProto.RpcScoreRankRequest.newBuilder();
            builder.setRoleId(roleId);
            long t = System.currentTimeMillis();
            ListenableFuture<CrossSeniorMineProto.RpcScoreRankResponse> response = stub.checkScoreRank(builder.build());
            CrossSeniorMineProto.RpcScoreRankResponse rpcScoutMineResponse = response.get(timeOut, TimeUnit.MILLISECONDS);
            LogUtil.crossInfo(" 查看排名 耗时 roleId={}, {} ms", roleId, (System.currentTimeMillis() - t));
            return rpcScoutMineResponse;
        } catch (Exception e) {
            LogUtil.error(e);
        }
        return null;
    }

    /**
     * 领取个人排名奖励
     *
     * @param roleId
     * @return
     */
    public static CrossSeniorMineProto.RpcCoreAwardResponse getScoreRankAward(long roleId) {

        try {
            MineHandlerGrpc.MineHandlerFutureStub stub = getStub();
            if (stub == null) {
                return null;
            }
            CrossSeniorMineProto.RpcCoreAwardRequest.Builder builder = CrossSeniorMineProto.RpcCoreAwardRequest.newBuilder();
            builder.setRoleId(roleId);
            long t = System.currentTimeMillis();
            ListenableFuture<CrossSeniorMineProto.RpcCoreAwardResponse> response = stub.getScoreRank(builder.build());
            CrossSeniorMineProto.RpcCoreAwardResponse rpcScoutMineResponse = response.get(timeOut, TimeUnit.MILLISECONDS);
            LogUtil.crossInfo(" 领取个人排名奖励 耗时 roleId={}, {} ms", roleId, (System.currentTimeMillis() - t));
            return rpcScoutMineResponse;
        } catch (Exception e) {
            LogUtil.error(e);
        }
        return null;
    }


    /**
     * 查看服务器排名
     *
     * @return
     */
    public static CrossSeniorMineProto.RpcServerScoreRankResponse checkServerScoreRank() {

        try {
            MineHandlerGrpc.MineHandlerFutureStub stub = getStub();
            if (stub == null) {
                return null;
            }
            CrossSeniorMineProto.RpcServerScoreRankRequest.Builder builder = CrossSeniorMineProto.RpcServerScoreRankRequest.newBuilder();
            builder.setRoleId(GameServer.ac.getBean(ServerSetting.class).getServerID());
            long t = System.currentTimeMillis();
            ListenableFuture<CrossSeniorMineProto.RpcServerScoreRankResponse> response = stub.checkServerScoreRank(builder.build());
            CrossSeniorMineProto.RpcServerScoreRankResponse rpcScoutMineResponse = response.get(timeOut, TimeUnit.MILLISECONDS);
            LogUtil.crossInfo(" 查看服务器排名 耗时, {} ms", (System.currentTimeMillis() - t));
            return rpcScoutMineResponse;
        } catch (Exception e) {
            LogUtil.error(e);
        }
        return null;
    }

    /**
     * 领取服务器排名奖励
     *
     * @param roleId
     * @return
     */
    public static CrossSeniorMineProto.RpcCoreAwardResponse getServerRankAward(long roleId) {
        try {
            MineHandlerGrpc.MineHandlerFutureStub stub = getStub();
            if (stub == null) {
                return null;
            }
            CrossSeniorMineProto.RpcCoreAwardRequest.Builder builder = CrossSeniorMineProto.RpcCoreAwardRequest.newBuilder();
            builder.setRoleId(roleId);
            long t = System.currentTimeMillis();
            ListenableFuture<CrossSeniorMineProto.RpcCoreAwardResponse> response = stub.getServerScoreRank(builder.build());
            CrossSeniorMineProto.RpcCoreAwardResponse rpcScoutMineResponse = response.get(timeOut, TimeUnit.MILLISECONDS);
            LogUtil.crossInfo(" 领取服务器排名奖励 耗时 roleId={}, {} ms", roleId, (System.currentTimeMillis() - t));
            return rpcScoutMineResponse;
        } catch (Exception e) {
            LogUtil.error(e);
        }
        return null;
    }


    /**
     * 撤回部队
     *
     * @return
     */
    public static CrossSeniorMineProto.RpcRetreatArmyResponse resetArmy(CrossSeniorMineProto.RpcRetreatArmyRequest request) {
        try {
            MineHandlerGrpc.MineHandlerFutureStub stub = getStub();
            if (stub == null) {
                return null;
            }
            long t = System.currentTimeMillis();
            ListenableFuture<CrossSeniorMineProto.RpcRetreatArmyResponse> response = stub.retreatArmy(request);
            CrossSeniorMineProto.RpcRetreatArmyResponse rpcScoutMineResponse = response.get(timeOut, TimeUnit.MILLISECONDS);
            LogUtil.crossInfo(" 撤回部队 耗时 , {} ms", (System.currentTimeMillis() - t));
            return rpcScoutMineResponse;
        } catch (Exception e) {
            LogUtil.error(e);
        }
        return null;
    }

    /**
     * gm
     *
     * @return
     */
    public static CrossSeniorMineProto.RpcRetreatArmyResponse gm(int type, String nick, String score) {
        try {
            MineHandlerGrpc.MineHandlerFutureStub stub = getStub();
            if (stub == null) {
                return null;
            }
            long t = System.currentTimeMillis();
            CrossSeniorMineProto.RpcGmquest.Builder request = CrossSeniorMineProto.RpcGmquest.newBuilder();
            request.setType(type);
            request.setNick(nick);
            request.setScore(Integer.valueOf(score));

            ListenableFuture<CrossSeniorMineProto.RpcRetreatArmyResponse> response = stub.crossMineGm(request.build());
            CrossSeniorMineProto.RpcRetreatArmyResponse rpcScoutMineResponse = response.get(timeOut, TimeUnit.MILLISECONDS);
            LogUtil.crossInfo(" gm 耗时 , {} ms", (System.currentTimeMillis() - t));
            return rpcScoutMineResponse;
        } catch (Exception e) {
            LogUtil.error(e);
        }
        return null;
    }


    public static MineHandlerGrpc.MineHandlerFutureStub getStub() {
        GRpcConnection rpcConnection = null;
        try {
            rpcConnection = GRpcPoolManager.getRpcConnection();
            MineHandlerGrpc.MineHandlerFutureStub scoutMine = null;
            if (rpcConnection != null) {
                scoutMine = MineHandlerGrpc.newFutureStub(rpcConnection.getChannel());
            }
            return scoutMine;
        } catch (Exception e) {
            LogUtil.error(e);
        } finally {
            if (rpcConnection != null) {
                rpcConnection.close();
            }
        }
        return null;
    }
}
