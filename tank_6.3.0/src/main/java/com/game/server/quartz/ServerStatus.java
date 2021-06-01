package com.game.server.quartz;

import com.game.actor.system.ServerEventService;
import com.game.message.handler.DealType;
import com.game.server.GameServer;
import com.game.server.ICommand;
import com.game.server.task.ServerStatusLogTask;
import com.game.util.LogUtil;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

/**
 * @author ：Liu Gui Jie
 * @date ：Created in 2019/5/22 9:53
 * @description：服务器状态监控定时
 */
@Component
public class ServerStatus {
    @Scheduled(initialDelay = 60 * 1000, fixedRate = 60 * 1000)
    public void memoryStatus() {

        try {
            ServerStatusLogTask.print();
        } catch (Exception e) {
            LogUtil.error(e);
        }

    }

    /**
     * 更新服务器维护时间
     */
    @Scheduled(initialDelay = 30 * 1000, fixedDelay = 90 * 1000)
    public void updateServerLogic() {
        try {
            if (GameServer.getInstance().mainLogicServer == null) {
                return;
            }
            GameServer.getInstance().mainLogicServer.addCommand(new ICommand() {
                @Override
                public void action() {
                    GameServer.ac.getBean(ServerEventService.class).updateServerMainte();
                }
            }, DealType.MAIN);
        } catch (Exception e) {
            LogUtil.error(e);
        }
    }
}
