package com.game.server.timer;

import com.game.message.handler.DealType;
import com.game.server.GameContext;
import com.game.server.ICommand;
import com.game.service.GmToolService;
import com.game.util.LogUtil;
import org.springframework.beans.BeansException;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

/**
 * @author yeding
 * @create 2019/5/18 5:34
 * @decs
 */
@Component
public class CrossRefreshConfig {

    /**
     * 每2个小时加载一次配置
     */
    @Scheduled(cron = "0 0 */2 * * ?")
    public void refreshWarConfig() {
        GameContext.getMainLogicServer().addCommand(new ICommand() {
            @Override
            public void action() {
                try {
                    LogUtil.error("开始加载init配置");
                    GameContext.getAc().getBean(GmToolService.class).reloadParamLogic(1);
                    GameContext.getAc().getBean(GmToolService.class).reloadParamLogic(2);
                    LogUtil.error("加载init配置完成");
                } catch (BeansException e) {
                    LogUtil.error(e);
                }
            }
        }, DealType.MAIN);
    }
}
