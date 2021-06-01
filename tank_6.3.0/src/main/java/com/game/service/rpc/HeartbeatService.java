package com.game.service.rpc;

import com.game.common.ServerSetting;
import com.game.grpc.proto.rpc.HeartbeatGrpc;
import com.game.grpc.proto.rpc.HeartbeatProto;
import com.game.server.GameServer;
import com.game.util.DateHelper;
import com.game.util.LogUtil;
import com.google.common.util.concurrent.ListenableFuture;
import io.grpc.ManagedChannel;

import java.util.concurrent.ExecutionException;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;

/**
 * @author ：Liu Gui Jie
 * @date ：Created in 2019/4/18 15:59
 * @description：
 */
public class HeartbeatService {

    /**
     * 检测连接是否有效
     *
     * @param channel
     * @return
     */
    public static boolean checkChannel(int id, ManagedChannel channel) {
        try {
            //第一次创建耗时长
            long timeout = id == 0 ? 3000L:1000L;
            int serverId = GameServer.ac.getBean(ServerSetting.class).getServerID();
            HeartbeatProto.HeartbeatRequest heartbeatRequest = HeartbeatProto.HeartbeatRequest.newBuilder().setServerId(serverId).setId(id).setTime(System.currentTimeMillis()).build();
            HeartbeatGrpc.HeartbeatFutureStub heartbeatFutureStub = HeartbeatGrpc.newFutureStub(channel);

            ListenableFuture<HeartbeatProto.HeartbeatResponse> heartbeatResponseListenableFuture1 = heartbeatFutureStub.validateChannel(heartbeatRequest);
            long t = System.currentTimeMillis();
            HeartbeatProto.HeartbeatResponse response = heartbeatResponseListenableFuture1.get(timeout, TimeUnit.MILLISECONDS);
            String formatTime = DateHelper.formatTime(response.getTime(), "yyyy-MM-dd HH:mm:ss.SSS");
            LogUtil.crossInfo("rpc client 收到验证心跳,耗时 {} ms , server id={},time={} ,ip={},rpcPort={}", (System.currentTimeMillis() - t), response.getId(), formatTime, response.getIp(), response.getPort());
            return true;
        } catch (InterruptedException | ExecutionException | TimeoutException e) {
            LogUtil.error("rpc 连接验证错误", e);
        }
        return false;
    }
}
