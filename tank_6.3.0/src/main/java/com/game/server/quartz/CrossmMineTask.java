package com.game.server.quartz;

import com.game.message.handler.DealType;
import com.game.server.GameServer;
import com.game.server.ICommand;
import com.game.service.CrossService;
import com.game.service.crossmine.CrossSeniorMineService;
import com.game.util.LogUtil;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

/**
 * @author yeding
 * @create 2019/6/17 17:01
 * @decs
 */
@Component
public class CrossmMineTask {


    /**
     * 星期一凌晨  将跨服军矿采集资源添加玩家,并且移除部队
     */
    @Scheduled(cron = "0 0 0 ? * MON")
    public void crossLogic() {
        try {
            if (GameServer.getInstance().mainLogicServer == null) {
                return;
            }
            GameServer.getInstance().mainLogicServer.
                    addCommand(new ICommand() {
                        @Override
                        public void action() {
                            GameServer.ac.getBean(CrossSeniorMineService.class).flushArmy();
                        }
                    }, DealType.MAIN);
        } catch (Exception e) {
            LogUtil.error(e);
        }
    }



}
