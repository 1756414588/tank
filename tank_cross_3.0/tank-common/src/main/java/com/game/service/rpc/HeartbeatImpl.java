package com.game.service.rpc;

import com.game.common.ServerSetting;
import com.game.grpc.proto.rpc.HeartbeatGrpc;
import com.game.grpc.proto.rpc.HeartbeatProto;
import com.game.server.GameContext;
import com.game.util.LogUtil;
import com.game.util.TimeHelper;
import io.grpc.stub.StreamObserver;

/**
 * @author ：Liu Gui Jie
 * @date ：Created in 2019/4/18 10:22
 * @description：心跳检测
 */
public class HeartbeatImpl extends HeartbeatGrpc.HeartbeatImplBase {
    @Override
    public void validateChannel(HeartbeatProto.HeartbeatRequest request, StreamObserver<HeartbeatProto.HeartbeatResponse> responseObserver) {

        try {
            LogUtil.s2sRpcMessage(request);
            String formatTime = TimeHelper.formatTime(request.getTime(), TimeHelper.FORMART);
            LogUtil.crossInfo("rpc server 收到验证心跳 id={}, serverId={}  time={}", request.getId(), request.getServerId(), formatTime);
            HeartbeatProto.HeartbeatResponse heartbeatResponse = HeartbeatProto.HeartbeatResponse.newBuilder().setId(request.getId()).setTime(System.currentTimeMillis()).setIp(GameContext.getAc().getBean(ServerSetting.class).getCrossServerIp()).setPort(GameContext.getRpcServer().getPort()).build();
            LogUtil.s2sRpcMessage(heartbeatResponse);
            responseObserver.onNext(heartbeatResponse);
            responseObserver.onCompleted();
        } catch (Exception e) {
            LogUtil.error(e);
            responseObserver.onError(e);
        }

    }
}
