package com.game.server.quartz;

import com.game.message.handler.DealType;
import com.game.server.GameServer;
import com.game.server.ICommand;
import com.game.service.FightLabService;
import com.game.util.LogUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

/**
 * @author ：Liu Gui Jie
 * @date ：Created in 2019/5/22 11:45
 * @description：作战实验室
 */
@Component
public class FightLabTask {

    @Autowired
    private FightLabService fightLabService;

    /**
     * 每60秒执行一次
     */
    @Scheduled(initialDelay = 120 * 1000, fixedRate = 60 * 1000)
    public void labTimerLogic() {

        try {
            if (GameServer.getInstance().mainLogicServer == null) {
                return;
            }
            GameServer.getInstance().mainLogicServer.addCommand(new ICommand() {
                @Override
                public void action() {
                    fightLabService.labTimerLogic();

                }
            }, DealType.MAIN);
        } catch (Exception e) {
            LogUtil.error(e);
        }
    }

    /**
     * 23 59 59 秒执行
     */
    @Scheduled(cron = "59 59 23 * * ?")
    public void spyTaskTimerLogic() {

        try {
            if (GameServer.getInstance().mainLogicServer == null) {
                return;
            }
            GameServer.getInstance().mainLogicServer.addCommand(new ICommand() {
                @Override
                public void action() {
                    fightLabService.spyTaskTimerLogic();
                }
            }, DealType.MAIN);
        } catch (Exception e) {
            LogUtil.error(e);
        }
    }
}
