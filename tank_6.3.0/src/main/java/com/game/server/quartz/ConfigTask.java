package com.game.server.quartz;

import com.game.message.handler.DealType;
import com.game.server.GameServer;
import com.game.server.ICommand;
import com.game.service.GmToolService;
import com.game.util.LogUtil;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

/**
 * @author ：Liu Gui Jie
 * @date ：Created in 2019/5/27 10:13
 * @description：配置刷新定时
 */
@Component
public class ConfigTask {

    /**
     * 配置刷新 凌晨一次
     */
    @Scheduled(cron = "1 0 0 * * ?")
    public void activityConfigLogic() {
        try {
            if (GameServer.getInstance().mainLogicServer == null) {
                LogUtil.error("GameServer.getInstance().mainLogicServer  is null");
                return;
            }
            GameServer.getInstance().mainLogicServer.
                    addCommand(new ICommand() {
                        @Override
                        public void action() {
                            GameServer.ac.getBean(GmToolService.class).reloadParamLogic(2);
                        }
                    }, DealType.INNER);
        } catch (Exception e) {
            LogUtil.error(e);
        }
    }
}
