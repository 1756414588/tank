package com.game.server.quartz;

import com.game.message.handler.DealType;
import com.game.server.GameServer;
import com.game.server.ICommand;
import com.game.service.teaminstance.TeamInstanceService;
import com.game.service.teaminstance.TeamService;
import com.game.util.LogUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

/**
 * @author yeding
 * @create 2019/4/27 0:00
 * @decs
 */
@Component
public class TeamTask {

    @Autowired
    private TeamService teamService;
    @Autowired
    private TeamInstanceService teamInstanceService;

    /**
     * 每周六0点
     */
    @Scheduled(cron = "1 0 0 ? * SAT")
    public void openCrossMin() {
        try {

            if (GameServer.getInstance().mainLogicServer == null) {
                return;
            }

            GameServer.getInstance().mainLogicServer.addCommand(new ICommand() {
                @Override
                public void action() {
                    if (teamInstanceService.isCrossOpen()) {
                        teamService.synServerList(2);
                    }
                }
            }, DealType.MAIN);
        } catch (Exception e) {
            LogUtil.error(e);
        }
    }

    /**
     * 每周1零点
     */
    @Scheduled(cron = "0 0 0 ? * MON")
    public void closeCrossMin() {
        try {
            if (GameServer.getInstance().mainLogicServer == null) {
                return;
            }
            GameServer.getInstance().mainLogicServer.addCommand(new ICommand() {
                @Override
                public void action() {
                    teamService.synServerList(1);
                }
            }, DealType.MAIN);
        } catch (Exception e) {
            LogUtil.error(e);
        }
    }

    /**
     * 每3秒执行一次
     */
    @Scheduled(initialDelay = 60 * 1000, fixedRate = 3 * 1000)
    public void refreshTask() {

        try {
            if (GameServer.getInstance().mainLogicServer == null) {
                return;
            }
            GameServer.getInstance().mainLogicServer.addCommand(new ICommand() {
                @Override
                public void action() {
                    teamInstanceService.logicRefreshTask();
                }
            }, DealType.MAIN);
        } catch (Exception e) {
            LogUtil.error(e);
        }
    }
}
