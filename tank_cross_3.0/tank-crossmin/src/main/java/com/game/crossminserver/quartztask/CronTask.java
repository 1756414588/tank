package com.game.crossminserver.quartztask;

import com.game.message.handler.DealType;
import com.game.server.GameContext;
import com.game.server.ICommand;
import com.game.service.crossmin.CrossMinService;
import com.game.service.crossmin.ServerListManager;
import com.game.service.teaminstance.CrossTeamService;
import com.game.util.LogUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.io.IOException;

/**
 * @author yeding
 * @create 2019/4/27 0:00
 * @decs
 */
@Component
public class CronTask {

    @Autowired
    private CrossTeamService crossTeamService;

    /**
     * 周一凌晨解散所有跨服组队
     */
    @Scheduled(cron = "0 0 0 ? * MON")
    public void closeCrossMin() {
        try {
            GameContext.getMainLogicServer().addCommand(new ICommand() {
                @Override
                public void action() {
                    try {
                        GameContext.getMainLogicServer().addCommand(new ICommand() {
                            @Override
                            public void action() {
                                crossTeamService.closeAllTeam();
                            }
                        }, DealType.MAIN);
                    } catch (Exception e) {
                        LogUtil.error(e);
                    }
                }
            }, DealType.MAIN);
        } catch (Exception e) {
            LogUtil.error(e);
        }
    }

    /**
     * 刷新服务器id配置
     */
    @Scheduled(initialDelay =20000, fixedDelay = 60000)
    public void refreshConfig() {
        try {
            GameContext.getMainLogicServer().addCommand(new ICommand() {
                @Override
                public void action() {
                    try {
                        ServerListManager.refreshServerIds();
                    } catch (IOException e) {
                        LogUtil.error(e);
                    }
                    ServerListManager.refreshServerListConfig();
                }
            }, DealType.MAIN);
        } catch (Exception e) {
            LogUtil.error(e);
        }
    }

    /**
     * 检测链接服务器
     */
    @Scheduled(initialDelay = 20000, fixedDelay = 10000)
    public void watchGameServer() {
        try {
            GameContext.getMainLogicServer().addCommand(new ICommand() {
                @Override
                public void action() {
                    GameContext.getAc().getBean(CrossMinService.class).watchGameServerTimerLogic();
                }
            }, DealType.MAIN);
        } catch (Exception e) {
            LogUtil.error(e);
        }
    }

    /**
     * 每天凌晨对赏金副本的队伍进行检查，解散无效队伍
     */
    @Scheduled(cron = "1 0 0 * * ?")
    public void checkTeamCross() {
        try {
            GameContext.getMainLogicServer().addCommand(new ICommand() {
                @Override
                public void action() {
                    GameContext.getAc().getBean(CrossTeamService.class).disInvalidTeamLogic();
                }
            }, DealType.MAIN);
        } catch (Exception e) {
            LogUtil.error(e);
        }
    }
}

