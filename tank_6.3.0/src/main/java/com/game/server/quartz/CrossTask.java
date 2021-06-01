package com.game.server.quartz;

import com.game.message.handler.DealType;
import com.game.server.GameServer;
import com.game.server.ICommand;
import com.game.service.CrossService;
import com.game.service.crossmin.CrossMinService;
import com.game.util.LogUtil;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

/**
 * @author ：Liu Gui Jie
 * @date ：Created in 2019/5/27 11:02
 * @description：跨服业务相关定时
 */
@Component
public class CrossTask {

    /**
     * 跨服战心跳
     */
    @Scheduled(initialDelay = 90 * 1000, fixedDelay = 22 * 1000)
    public void crossLogic() {
        try {
            if (GameServer.getInstance().mainLogicServer == null) {
                return;
            }
            GameServer.getInstance().mainLogicServer.
                    addCommand(new ICommand() {
                        @Override
                        public void action() {
                            GameServer.ac.getBean(CrossService.class).heartRq();
                        }
                    }, DealType.MAIN);
        } catch (Exception e) {
            LogUtil.error(e);
        }
    }

    /**
     * 跨服组队心跳
     */
    @Scheduled(initialDelay = 90 * 1000, fixedDelay = 42 * 1000)
    public void crossMinLogic() {
        try {
            if (GameServer.getInstance().mainLogicServer == null) {
                return;
            }
            GameServer.getInstance().mainLogicServer.
                    addCommand(new ICommand() {
                        @Override
                        public void action() {
                            GameServer.ac.getBean(CrossMinService.class).crossMinheartRq();
                        }
                    }, DealType.MAIN);
        } catch (Exception e) {
            LogUtil.error(e);
        }
    }
}
