package com.game.server.quartz;

import com.game.manager.GlobalDataManager;
import com.game.message.handler.DealType;
import com.game.persistence.SavePartyOptimizeTask;
import com.game.persistence.SavePlayerOptimizeTask;
import com.game.server.GameServer;
import com.game.server.ICommand;
import com.game.service.*;
import com.game.util.LogUtil;
import com.game.util.TimeHelper;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

/**
 * @author yeding
 * @create 2019/5/17 16:08
 * @decs
 */
@Component
public class SaveTask {

    /**
     * 保存活动数据定时器
     */
    @Scheduled(initialDelay = 5 * 60 * 1000, fixedRate = 80 * 1000)
    public void saveActivity() {
        try {
            if (GameServer.getInstance().mainLogicServer == null) {
                return;
            }

            GameServer.getInstance().mainLogicServer.addCommand(new ICommand() {
                @Override
                public void action() {
                    GameServer.ac.getBean(ActivityService.class).saveActivityTimerLogic();
                }
            }, DealType.MAIN);
        } catch (Exception e) {
            LogUtil.error(e);
        }
    }

    /**
     * 保存极限探险数据定时器
     */
    @Scheduled(initialDelay = 5 * 60 * 1000, fixedRate = 300 * 1000)
    public void saveExtreme() {
        try {
            if (GameServer.getInstance().mainLogicServer == null) {
                return;
            }

            GameServer.getInstance().mainLogicServer.addCommand(new ICommand() {
                @Override
                public void action() {
                    GameServer.ac.getBean(CombatService.class).saveExtremeTimerLogic();
                }
            }, DealType.MAIN);
        } catch (Exception e) {
            LogUtil.error(e);
        }
    }

    /**
     * 保存全局数据定时器
     */
    @Scheduled(initialDelay = 3 * 60 * 1000, fixedRate = 200 * 1000)
    public void saveGlobal() {
        try {
            if (GameServer.getInstance().mainLogicServer == null) {
                return;
            }

            GameServer.getInstance().mainLogicServer.addCommand(new ICommand() {
                @Override
                public void action() {
                    GameServer.ac.getBean(GlobalDataManager.class).saveGlobalTimerLogic();
                }
            }, DealType.MAIN);
        } catch (Exception e) {
            LogUtil.error(e);
        }
    }

    /**
     * 军团数据保存定时器
     */
    @Scheduled(initialDelay = 3 * 60 * 1000, fixedRate = 250 * 1000)
    public void saveParty() {
        try {
            if (GameServer.getInstance().mainLogicServer == null) {
                return;
            }

            GameServer.getInstance().mainLogicServer.addCommand(new ICommand() {
                @Override
                public void action() {
                    GameServer.ac.getBean(PartyService.class).savePartyTimerLogic();
                }
            }, DealType.MAIN);
        } catch (Exception e) {
            LogUtil.error(e);
        }
    }

    /**
     * 玩家数据保存定时器
     */
    @Scheduled(initialDelay = 2 * 60 * 1000, fixedRate = 10 * 1000)
    public void savePlayer() {
        try {

            if (GameServer.getInstance().mainLogicServer == null) {
                return;
            }

            GameServer.getInstance().mainLogicServer.addCommand(new ICommand() {
                @Override
                public void action() {
                    GameServer.ac.getBean(PlayerService.class).saveTimerLogic();
                }
            }, DealType.MAIN);
        } catch (Exception e) {
            LogUtil.error(e);
        }
    }

    /**
     * 玩家举报信息保存定时器
     */
    @Scheduled(initialDelay = 5 * 60 * 1000, fixedRate = 310 * 1000)
    public void saveTipGuy() {
        try {
            if (GameServer.getInstance().mainLogicServer == null) {
                return;
            }

            GameServer.getInstance().mainLogicServer.addCommand(new ICommand() {
                @Override
                public void action() {
                    GameServer.ac.getBean(TipGuyService.class).saveTimerLogic();
                }
            }, DealType.MAIN);
        } catch (Exception e) {
            LogUtil.error(e);
        }
    }

    /**
     * 定时全局遍历一次 每天凌晨 4 -5点 每两分钟执行一次
     */
    @Scheduled(cron = "0 */2 4-5 * * ?")
    public void saveAllPlayer() {
        try {

            if (GameServer.getInstance().mainLogicServer == null) {
                LogUtil.error("GameServer.getInstance().mainLogicServer  is null");
                return;
            }

            GameServer.getInstance().mainLogicServer.addCommand(new ICommand() {
                @Override
                public void action() {
                    int now = TimeHelper.getCurrentSecond();
                    GameServer.ac.getBean(SavePlayerOptimizeTask.class).saveAllPlayer(now);
                }
            }, DealType.MAIN);
        } catch (Exception e) {
            LogUtil.error(e);
        }
    }

    /**
     * 定时全局遍历一次 延迟12分钟 每12分钟执行一次
     */
    @Scheduled(initialDelay = 12 * 60 * 1000, fixedRate = 12 * 60 * 1000)
    public void flushPlayerAddIdleSave() {
        try {
            if (GameServer.getInstance().mainLogicServer == null) {
                return;
            }

            GameServer.getInstance().mainLogicServer.addCommand(new ICommand() {
                @Override
                public void action() {
                    int now = TimeHelper.getCurrentSecond();
                    GameServer.ac.getBean(SavePlayerOptimizeTask.class).flushPlayerAddIdleSave(now);
                }
            }, DealType.MAIN);
        } catch (Exception e) {
            LogUtil.error(e);
        }
    }


    /**
     * 计算玩家离线集合 延迟30分钟 每60分钟执行一次
     */
    @Scheduled(initialDelay = 30 * 60 * 1000, fixedRate = 60 * 60 * 1000)
    public void refreshOfflineCountPlayer() {
        try {
            if (GameServer.getInstance().mainLogicServer == null) {
                return;
            }

            GameServer.getInstance().mainLogicServer.addCommand(new ICommand() {
                @Override
                public void action() {
                    int now = TimeHelper.getCurrentSecond();
                    GameServer.ac.getBean(SavePlayerOptimizeTask.class).refreshOfflineCountPlayer(now);
                }
            }, DealType.MAIN);
        } catch (Exception e) {
            LogUtil.error(e);
        }
    }

    /**
     * 定时30分钟执行全局军团保存
     */
    @Scheduled(initialDelay = 30 * 60 * 1000, fixedRate = 30 * 60 * 1000)
    public void flushPartyAllSave() {
        try {
            if (GameServer.getInstance().mainLogicServer == null) {
                return;
            }

            GameServer.getInstance().mainLogicServer.addCommand(new ICommand() {
                @Override
                public void action() {
                    int now = TimeHelper.getCurrentSecond();
                    GameServer.ac.getBean(SavePartyOptimizeTask.class).flushPartyAllSave(now);
                }
            }, DealType.MAIN);
        } catch (Exception e) {
            LogUtil.error(e);
        }
    }
}
