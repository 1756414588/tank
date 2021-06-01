package com.game.crossserver.server;

import com.game.common.ServerSetting;
import com.game.constant.CrossConst;
import com.game.message.handler.DealType;
import com.game.server.GameContext;
import com.game.server.ICommand;
import com.game.service.cross.CrossRegisterService;
import com.game.service.cross.fight.CrossService;
import com.game.service.cross.party.CrossPartyService;
import com.game.util.LogUtil;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

/**
 * @author yeding
 * @create 2019/5/18 5:04
 * @decs
 */
@Component
public class CrossTask {
    /**
     * 刷新服务器id配置
     */
 /*   @Scheduled(initialDelay =20000, fixedDelay = 60000)
    public void refreshConfig() {
        try {
            GameContext.getMainLogicServer().addCommand(new ICommand() {
                @Override
                public void action() {
                    try {
                        ServerListManager.refreshCrossServerIds();
                    } catch (IOException e) {
                        LogUtil.error(e);
                    }
                    ServerListManager.refreshCrossServerListConfig();
                }
            }, DealType.MAIN);
        } catch (Exception e) {
            LogUtil.error(e);
        }
    }*/


    /**
     * 检测游戏服链接
     */
    @Scheduled(initialDelay = 30000, fixedDelay = 20000)
    public void watchServer() {
        GameContext.getMainLogicServer().addCommand(new ICommand() {
            @Override
            public void action() {
                try {
                    GameContext.getAc().getBean(CrossRegisterService.class).watchGameServerTimerLogic();
                } catch (Exception e) {
                    LogUtil.error(e);

                }
            }
        }, DealType.MAIN);
    }

    /**
     * 跨服战/跨服军团战逻辑
     */
    @Scheduled(initialDelay = 30000, fixedDelay = 1000)
    public void warLogic() {
        GameContext.getMainLogicServer().addCommand(new ICommand() {
            @Override
            public void action() {
                try {
                    int type = Integer.parseInt(GameContext.getAc().getBean(ServerSetting.class).getCrossType());
                    switch (type) {
                        case CrossConst.CrossType:
                            GameContext.getAc().getBean(CrossService.class).crossWarTimerLogic();
                            break;
                        case CrossConst.CrossPartyType:
                            GameContext.getAc().getBean(CrossPartyService.class).crossPartyWarTimerLogic();
                            break;
                        default:
                            break;
                    }
                } catch (Exception e) {
                    LogUtil.error(e);
                }
            }
        }, DealType.MAIN);
    }
}
