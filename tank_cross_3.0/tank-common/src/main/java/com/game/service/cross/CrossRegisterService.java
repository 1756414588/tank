package com.game.service.cross;

import com.game.common.ServerSetting;
import com.game.message.handler.ClientHandler;
import com.game.pb.BasePb;
import com.game.pb.CrossGamePb;
import com.game.pb.InnerPb;
import com.game.server.GameContext;
import com.game.server.util.ChannelUtil;
import com.game.server.config.gameServer.Server;
import com.game.util.LogUtil;
import org.springframework.stereotype.Service;

/**
 * @author ：Liu Gui Jie
 * @date ：Created in 2019/3/13 14:03
 * @description：跨服通道注册
 */
@Service
public class CrossRegisterService {
    /**
     * game服注册
     *
     * @param rq
     * @param handler
     */
    public void gameServerReg(CrossGamePb.CCGameServerRegRq rq, ClientHandler handler) {
        int serverId = rq.getServerId();
        String name = rq.getServerName();
        Server server = GameContext.gameServerMaps.get(serverId);
        server.ctx = handler.getCtx();
        server.setConect(true);
        ChannelUtil.setServerId(server.ctx, serverId);
        LogUtil.info("[跨服战或者跨服军团战] 游戏服注册  serverId={},name={} 注册成功", serverId, name);
        CrossGamePb.CCGameServerRegRs.Builder builder = CrossGamePb.CCGameServerRegRs.newBuilder();
        handler.sendMsgToPlayer(CrossGamePb.CCGameServerRegRs.ext, builder.build());
    }

    /**
     * 通知没有连上cross服务器的game服连
     */
    public void watchGameServerTimerLogic() {
        String crossIp = GameContext.getAc().getBean(ServerSetting.class).getCrossServerIp();
        String port = GameContext.getAc().getBean(ServerSetting.class).getClientPort();
        String beginTime = GameContext.getAc().getBean(ServerSetting.class).getCrossBeginTime();
        String crossType = GameContext.getAc().getBean(ServerSetting.class).getCrossType();
        // 判断是否在线,若不在线,通知游戏服来注册
        for (Server server : GameContext.getGameServerConfig().getList()) {
            if (!server.isConect() && System.currentTimeMillis() - server.sendTime > 30000) {

                server.sendTime = System.currentTimeMillis();

                LogUtil.info("[跨服战或者跨服军团战] game 服未注册,发送注册请求:" + server);
                String gameServerURL = "http://" + server.getIp() + ":" + server.getHttpPort() + "/inner.do";
                InnerPb.NotifyCrossOnLineRq.Builder builder = InnerPb.NotifyCrossOnLineRq.newBuilder();
                builder.setCrossIp(crossIp);
                builder.setPort(Integer.parseInt(port));
                builder.setBeginTime(beginTime);
                builder.setCrossType(Integer.parseInt(crossType));
                builder.setServerId(server.getId());
                BasePb.Base.Builder baseBuilder = BasePb.Base.newBuilder();
                baseBuilder.setCmd(InnerPb.NotifyCrossOnLineRq.EXT_FIELD_NUMBER);
                baseBuilder.setExtension(InnerPb.NotifyCrossOnLineRq.ext, builder.build());
                BasePb.Base msg = baseBuilder.build();
                GameContext.getHttpServer().sendHttpMsg(gameServerURL, msg);
            }
        }
    }
}