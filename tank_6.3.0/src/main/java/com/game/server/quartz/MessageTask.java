package com.game.server.quartz;

import com.game.server.GameServer;
import com.game.util.LogUtil;
import io.netty.handler.traffic.TrafficCounter;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

/**
 * @author ：Liu Gui Jie
 * @date ：Created in 2019/5/17 10:03
 * @description：统计定时
 */
@Component
public class MessageTask {

    /**
     * 每60秒执行一次
     */
    @Scheduled(initialDelay = 60000, fixedRate = 60000)
    public void messageTask() {
        try {
            GameServer gameServer = GameServer.getInstance();
            if (gameServer.connectServer != null) {
                LogUtil.flow("Monitor GameServer Message  待处理 {} ,待发送 {},共接收 {} ,在线玩家 {} ", gameServer.connectServer.recvExcutor.getTaskCounts(), gameServer.connectServer.sendExcutor.getTaskCounts(), gameServer.connectServer.maxMessage.get(), gameServer.connectServer.maxConnect.get());
            }
            if (gameServer.connectServer != null && gameServer.connectServer.trafficShapingHandler != null) {
                TrafficCounter trafficCounter = gameServer.connectServer.trafficShapingHandler.trafficCounter();
                LogUtil.flow("Monitor netty {}", trafficCounter.toString());
            }
        } catch (Exception e) {
            LogUtil.error(e);
        }
    }
}
