package com.game.service.teaminstance;

import com.game.grpc.proto.team.*;
import com.game.server.GameContext;
import com.game.util.LogUtil;
import io.grpc.stub.StreamObserver;

/**
 * @author ：yeding
 * @date ：Created in 2019/4/22 17:09
 * @description：远程实现
 */
public class TeamRpcServiceImpl extends TeamHandlerGrpc.TeamHandlerImplBase {

    /**
     * 同步数据
     */
    @Override
    public void synPlayer(CrossTeamProto.RpcSynPlayerRequest request, StreamObserver<CrossTeamProto.RpcCodeTeamResponse> responseObserver) {
        //LogUtil.s2sRpcMessage(request);
        try {
            CrossTeamProto.RpcCodeTeamResponse response = GameContext.getAc().getBean(CrossTeamService.class).synPlayer(request);
            //LogUtil.s2sRpcMessage(response);
            responseObserver.onNext(response);
            responseObserver.onCompleted();
        } catch (Exception e) {
            LogUtil.error(e);
            responseObserver.onError(e);
        }
    }

    /**
     * 创建队伍
     */
    @Override
    public void createTeam(CrossTeamProto.RpcCreateTeamRequest request, StreamObserver<CrossTeamProto.RpcCreateTeamResponse> responseObserver) {
        LogUtil.s2sRpcMessage(request);
        try {
            CrossTeamProto.RpcCreateTeamResponse response = GameContext.getAc().getBean(CrossTeamService.class).createTeam(request.getRoleId(), request.getTeamType(), request.getFight());
            LogUtil.s2sRpcMessage(response);
            responseObserver.onNext(response);
            responseObserver.onCompleted();
        } catch (Exception e) {
            LogUtil.error(e);
            responseObserver.onError(e);
        }
    }


    /**
     * 解散队伍
     */
    @Override
    public void dismissTeam(CrossTeamProto.RpcDisMissTeamRequest request, StreamObserver<CrossTeamProto.RpcCodeTeamResponse> responseObserver) {
        LogUtil.s2sRpcMessage(request);
        try {
            CrossTeamProto.RpcCodeTeamResponse response = GameContext.getAc().getBean(CrossTeamService.class).disMissTeam(request.getRoleId());
            LogUtil.s2sRpcMessage(response);
            responseObserver.onNext(response);
            responseObserver.onCompleted();
        } catch (Exception e) {
            LogUtil.error(e);
            responseObserver.onError(e);
        }
    }

    /**
     * 寻找队伍
     */
    @Override
    public void findTeam(CrossTeamProto.RpcFindTeamRequest request, StreamObserver<CrossTeamProto.RpcCodeTeamResponse> responseObserver) {
        LogUtil.s2sRpcMessage(request);
        try {
            CrossTeamProto.RpcCodeTeamResponse response = GameContext.getAc().getBean(CrossTeamService.class).findTeam(request.getRoleId(), request.getTeamType());
            LogUtil.s2sRpcMessage(response);
            responseObserver.onNext(response);
            responseObserver.onCompleted();
        } catch (Exception e) {
            LogUtil.error(e);
            responseObserver.onError(e);
        }
    }

    /**
     * 离开队伍
     */
    @Override
    public void leaveTeam(CrossTeamProto.RpcLeaveTeamRequest request, StreamObserver<CrossTeamProto.RpcCodeTeamResponse> responseObserver) {
        LogUtil.s2sRpcMessage(request);
        try {
            CrossTeamProto.RpcCodeTeamResponse response = GameContext.getAc().getBean(CrossTeamService.class).leaveTeam(request.getRoleId());
            LogUtil.s2sRpcMessage(response);
            responseObserver.onNext(response);
            responseObserver.onCompleted();
        } catch (Exception e) {
            LogUtil.error(e);
            responseObserver.onError(e);
        }
    }

    /**
     * 踢出队伍
     */
    @Override
    public void kickTeam(CrossTeamProto.RpcKickTeamRequest request, StreamObserver<CrossTeamProto.RpcCodeTeamResponse> responseObserver) {
        LogUtil.s2sRpcMessage(request);
        try {
            CrossTeamProto.RpcCodeTeamResponse response = GameContext.getAc().getBean(CrossTeamService.class).kickTeam(request.getRoleId(), request.getBroleId());
            LogUtil.s2sRpcMessage(response);
            responseObserver.onNext(response);
            responseObserver.onCompleted();
        } catch (Exception e) {
            LogUtil.error(e);
            responseObserver.onError(e);
        }

    }

    /**
     * 加入队伍
     */
    @Override
    public void joinTeam(CrossTeamProto.RpcJoinTeamRequest request, StreamObserver<CrossTeamProto.RpcCodeTeamResponse> responseObserver) {
        LogUtil.s2sRpcMessage(request);
        try {
            CrossTeamProto.RpcCodeTeamResponse response = GameContext.getAc().getBean(CrossTeamService.class).joinTeam(request.getRoleId(), request.getTeamId());
            LogUtil.s2sRpcMessage(response);
            responseObserver.onNext(response);
            responseObserver.onCompleted();
        } catch (Exception e) {
            LogUtil.error(e);
            responseObserver.onError(e);
        }
    }

    /**
     * 加入队伍
     */
    @Override
    public void changeMemberStatus(CrossTeamProto.RpcChangeMemberStatusRequest request, StreamObserver<CrossTeamProto.RpcCodeTeamResponse> responseObserver) {
        LogUtil.s2sRpcMessage(request);
        try {
            CrossTeamProto.RpcCodeTeamResponse response = GameContext.getAc().getBean(CrossTeamService.class).changeMemberStatus(request.getRoleId());
            LogUtil.s2sRpcMessage(response);
            responseObserver.onNext(response);
            responseObserver.onCompleted();
        } catch (Exception e) {
            LogUtil.error(e);
            responseObserver.onError(e);
        }
    }

    /**
     * 交换出站顺序
     */
    @Override
    public void changeTeamOrder(CrossTeamProto.CrossExchangeOrderRequest request, StreamObserver<CrossTeamProto.RpcCodeTeamResponse> responseObserver) {
        LogUtil.s2sRpcMessage(request);
        try {
            CrossTeamProto.RpcCodeTeamResponse response = GameContext.getAc().getBean(CrossTeamService.class).changeOrder(request.getRoleId(), request.getRoleOne(), request.getRoleTwo());
            LogUtil.s2sRpcMessage(response);
            responseObserver.onNext(response);
            responseObserver.onCompleted();
        } catch (Exception e) {
            LogUtil.error(e);
            responseObserver.onError(e);
        }
    }

    /**
     * 查看队员阵型
     */
    @Override
    public void lookForm(CrossTeamProto.CrossLookFormRequest request, StreamObserver<CrossTeamProto.CrossLookFormResponse> responseObserver) {
        LogUtil.s2sRpcMessage(request);
        try {
            CrossTeamProto.CrossLookFormResponse response = GameContext.getAc().getBean(CrossTeamService.class).lookForm(request.getRoleId());
            LogUtil.s2sRpcMessage(response);
            responseObserver.onNext(response);
            responseObserver.onCompleted();
        } catch (Exception e) {
            LogUtil.error(e);
            responseObserver.onError(e);
        }
    }

    /**
     * 世界频道发消息
     */
    @Override
    public void teamInvite(CrossTeamProto.CrossInviteRequest request, StreamObserver<CrossTeamProto.RpcCodeTeamResponse> responseObserver) {
        LogUtil.s2sRpcMessage(request);
        try {
            CrossTeamProto.RpcCodeTeamResponse response = GameContext.getAc().getBean(CrossTeamService.class).teamInvite(request.getRoleId(), request.getStageId());
            LogUtil.s2sRpcMessage(response);
            responseObserver.onNext(response);
            responseObserver.onCompleted();
        } catch (Exception e) {
            LogUtil.error(e);
            responseObserver.onError(e);
        }
    }

    /**
     * 战斗
     */
    @Override
    public void fight(CrossTeamProto.CrossTeamFightRequest request, StreamObserver<CrossTeamProto.RpcCodeTeamResponse> responseObserver) {
        LogUtil.s2sRpcMessage(request);
        try {
            CrossTeamProto.RpcCodeTeamResponse response = GameContext.getAc().getBean(CrossTeamService.class).fight(request.getRoleId());
            LogUtil.s2sRpcMessage(response);
            responseObserver.onNext(response);
            responseObserver.onCompleted();
        } catch (Exception e) {
            LogUtil.error(e);
            responseObserver.onError(e);
        }
    }

    /**
     * 同步阵型
     */
    @Override
    public void synForm(CrossTeamProto.CrossSynFormRequest request, StreamObserver<CrossTeamProto.RpcCodeTeamResponse> responseObserver) {
        LogUtil.s2sRpcMessage(request);
        try {
            CrossTeamProto.RpcCodeTeamResponse response = GameContext.getAc().getBean(CrossTeamService.class).synForm(request);
            LogUtil.s2sRpcMessage(response);
            responseObserver.onNext(response);
            responseObserver.onCompleted();
        } catch (Exception e) {
            LogUtil.error(e);
            responseObserver.onError(e);
        }
    }

    /**
     * 玩家退出游戏
     */
    @Override
    public void logOut(CrossTeamProto.CrossLogOutRequest request, StreamObserver<CrossTeamProto.RpcCodeTeamResponse> responseObserver) {
        LogUtil.s2sRpcMessage(request);
        try {
            CrossTeamProto.RpcCodeTeamResponse response = GameContext.getAc().getBean(CrossTeamService.class).logOut(request);
            LogUtil.s2sRpcMessage(response);
            responseObserver.onNext(response);
            responseObserver.onCompleted();
        } catch (Exception e) {
            LogUtil.error(e);
            responseObserver.onError(e);
        }
    }


    /**
     * 跨服组队聊天
     */
    @Override
    public void worldChat(CrossTeamProto.CrossWorldChatRequest request, StreamObserver<CrossTeamProto.RpcCodeTeamResponse> responseObserver) {
        LogUtil.s2sRpcMessage(request);
        try {
            CrossTeamProto.RpcCodeTeamResponse response = GameContext.getAc().getBean(CrossTeamService.class).worldChat(request);
            LogUtil.s2sRpcMessage(response);
            responseObserver.onNext(response);
            responseObserver.onCompleted();
        } catch (Exception e) {
            LogUtil.error(e);
            responseObserver.onError(e);
        }
    }

    /**
     * 游戏服获取跨服服务器列表
     */
    @Override
    public void queryServerList(CrossTeamProto.CrossServerListRequest request, StreamObserver<CrossTeamProto.CrossServerListResponse> responseObserver) {
        LogUtil.s2sRpcMessage(request);
        try {
            CrossTeamProto.CrossServerListResponse response = GameContext.getAc().getBean(CrossTeamService.class).queryServerList();
            //LogUtil.s2sRpcMessage(response);
            responseObserver.onNext(response);
            responseObserver.onCompleted();
        } catch (Exception e) {
            LogUtil.error(e);
            responseObserver.onError(e);
        }
    }
}

