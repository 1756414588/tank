package com.game.server.quartz;

import com.game.manager.HotfixDataManager;
import com.game.message.handler.DealType;
import com.game.server.GameServer;
import com.game.server.ICommand;
import com.game.util.LogUtil;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

/**
 * @author ：Liu Gui Jie
 * @date ：Created in 2019/5/27 10:43
 * @description：热加载定时器
 */
@Component
public class HotFixTask {

    /**
     * 热更 记录  定时
     */
    @Scheduled(initialDelay = 180 * 1000, fixedDelay = 20000)
    public void hotFixLogic() {
        try {
            if (GameServer.getInstance().mainLogicServer == null) {
                return;
            }
            GameServer.getInstance().mainLogicServer.addCommand(new ICommand() {
                @Override
                public void action() {
                    GameServer.ac.getBean(HotfixDataManager.class).hotfixWithTimeLogic();
                }
            }, DealType.MAIN);
        } catch (Exception e) {
            LogUtil.error(e);
        }
    }

}
