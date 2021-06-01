package com.game.crossminserver.quartztask;

import com.game.manager.cross.seniormine.CrossMineDataManager;
import com.game.message.handler.DealType;
import com.game.server.GameContext;
import com.game.server.ICommand;
import com.game.service.seniormine.SeniorMineDataManager;
import com.game.util.LogUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

/**
 * @author yeding
 * @create 2019/6/17 16:23
 * @decs
 */
@Component
public class CrossMineTask {

    @Autowired
    private SeniorMineDataManager seniorMineDataManager;

    @Autowired
    private CrossMineDataManager crossMineDataManager;

    /**
     * 周六凌晨 清楚所有排行榜信息
     */
    @Scheduled(cron = "0 0 0 ? * SAT")
    public void flushMineRank() {
        try {
            GameContext.getMainLogicServer().addCommand(new ICommand() {
                @Override
                public void action() {
                    try {
                        GameContext.getMainLogicServer().addCommand(new ICommand() {
                            @Override
                            public void action() {
                                seniorMineDataManager.clearRanking();
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
     * 周一凌晨 清楚矿点所有驻军
     */
    @Scheduled(cron = "0 0 0 ? * MON")
    public void flushMineState() {
        try {
            GameContext.getMainLogicServer().addCommand(new ICommand() {
                @Override
                public void action() {
                    try {
                        GameContext.getMainLogicServer().addCommand(new ICommand() {
                            @Override
                            public void action() {
                                seniorMineDataManager.calRanking();
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
     * 定时刷新驻军  排行信息
     */
    @Scheduled(initialDelay = 20000, fixedDelay = 60000)
    public void fulshArmyToDb() {
        try {
            GameContext.getMainLogicServer().addCommand(new ICommand() {
                @Override
                public void action() {
                    try {
                        GameContext.getMainLogicServer().addCommand(new ICommand() {
                            @Override
                            public void action() {
                                crossMineDataManager.flushArmy();
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

}
