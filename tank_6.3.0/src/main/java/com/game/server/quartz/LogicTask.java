package com.game.server.quartz;

import com.game.dataMgr.StaticFunctionPlanDataMgr;
import com.game.domain.Player;
import com.game.manager.PartyDataManager;
import com.game.manager.PlayerDataManager;
import com.game.message.handler.DealType;
import com.game.server.GameServer;
import com.game.server.ICommand;
import com.game.service.*;
import com.game.service.activity.simple.ActVipCountService;
import com.game.service.airship.AirshipService;
import com.game.service.crossmine.CrossSeniorMineService;
import com.game.service.teaminstance.TeamService;
import com.game.util.LogUtil;
import com.game.util.TimeHelper;
import org.springframework.beans.BeansException;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.util.Calendar;

/**
 * @author yeding
 * @create 2019/5/24 2:52
 * @decs
 */
@Component
public class LogicTask {
    /**
     * 活动相关的定时器
     * 每秒一次
     */
    @Scheduled(initialDelay = 120 * 1000, fixedDelay = 1000)
    public void activityLogic() {
        try {
            if (GameServer.getInstance().mainLogicServer == null) {

                return;
            }
            GameServer.getInstance().mainLogicServer.
                    addCommand(new ICommand() {
                        @Override
                        public void action() {
                            GameServer.ac.getBean(ActVipCountService.class).activityTimeLogic();
                        }
                    }, DealType.MAIN);
        } catch (Exception e) {
            LogUtil.error(e);
        }
    }


    /**
     * 配置刷新 凌晨一次
     * 清除前一天活跃宝箱信息
     * 设置登陆福利活动的状态
     */
    @Scheduled(cron = "1 0 0 * * ?")
    public void activityConfigLogic() {
        try {
            if (GameServer.getInstance().mainLogicServer == null) {

                return;
            }
            GameServer.getInstance().mainLogicServer.
                    addCommand(new ICommand() {
                        @Override
                        public void action() {
                            PlayerDataManager playerDataManager = GameServer.ac.getBean(PlayerDataManager.class);
                            playerDataManager.clearActiveBox();
                            for (Player player : playerDataManager.getAllOnlinePlayer().values()) {
                                if (player != null && player.ctx != null) {
                                    playerDataManager.loginWelfare(player);
                                }
                            }
                        }
                    }, DealType.MAIN);
        } catch (Exception e) {
            LogUtil.error(e);
        }
    }


    /**
     * 竞技场相关定时器
     * 凌晨执行一次(服务器启动判断当天是否有执行过,如果未执行则执行一次)
     */
    @Scheduled(cron = "1 0 0 * * ?")
    public void arenaLogic() {
        try {
            if (GameServer.getInstance().mainLogicServer == null) {

                return;
            }
            GameServer.getInstance().mainLogicServer.addCommand(new ICommand() {
                @Override
                public void action() {
                    GameServer.ac.getBean(ArenaService.class).arenaTimerLogic();
                }
            }, DealType.MAIN);
        } catch (Exception e) {
            LogUtil.error(e);
        }
    }


    /**
     * boss相关定时器
     * 每秒一次发送到tank_account_role
     */
    @Scheduled(initialDelay = 120 * 1000, fixedDelay = 1000)
    public void boosLogic() {
        try {
            if (GameServer.getInstance().mainLogicServer == null) {

                return;
            }
            GameServer.getInstance().mainLogicServer.addCommand(new ICommand() {
                @Override
                public void action() {
                    try {
                        GameServer.ac.getBean(BossService.class).bossTimerLogic();
                    } catch (BeansException e) {
                        LogUtil.error(e);
                    }
                    try {
                        GameServer.ac.getBean(AltarBossService.class).altarBossTimerLogic();
                    } catch (BeansException e) {
                        LogUtil.error(e);
                    }
                    try {
                        GameServer.ac.getBean(ActionCenterService.class).actBossLogic();
                    } catch (BeansException e) {
                        LogUtil.error(e);
                    }
                    try {
                        GameServer.ac.getBean(ActionCenterService.class).actRebelLogic();
                    } catch (BeansException e) {
                        LogUtil.error(e);
                    }
                }
            }, DealType.MAIN);
        } catch (Exception e) {
            LogUtil.error(e);
        }
    }

    /**
     * 建筑相关定时器
     * 每秒一次
     */
    @Scheduled(initialDelay = 120 * 1000, fixedDelay = 1000)
    public void buildLogic() {
        try {
            if (GameServer.getInstance().mainLogicServer == null) {

                return;
            }
            GameServer.getInstance().mainLogicServer.addCommand(new ICommand() {
                @Override
                public void action() {
                    GameServer.ac.getBean(BuildingService.class).buildQueTimerLogic();
                }
            }, DealType.MAIN);
        } catch (Exception e) {
            LogUtil.error(e);
        }
    }

    /**
     * 每天早上五点执行一次
     * 每天凌晨5点定时删除超过30天的邮件
     */
    @Scheduled(cron = "0 0 5 * * ?")
    public void deleteMailLogic() {
        try {
            if (GameServer.getInstance().mainLogicServer == null) {

                return;
            }

            GameServer.getInstance().mainLogicServer.addCommand(new ICommand() {
                @Override
                public void action() {
                    StaticFunctionPlanDataMgr funcPlanDataMgr = GameServer.ac.getBean(StaticFunctionPlanDataMgr.class);
                    if (funcPlanDataMgr.isOptimizeMailOpen()) {
                        GameServer.ac.getBean(MailService.class).delExpiredMail();
                    }
                }
            }, DealType.MAIN);
        } catch (Exception e) {
            LogUtil.error(e);
        }
    }


    /**
     * 玩家buff定时定时器
     * 每秒一次
     */
    @Scheduled(initialDelay = 120 * 1000, fixedDelay = 1000)
    public void effectLogic() {
        try {
            if (GameServer.getInstance().mainLogicServer == null) {

                return;
            }
            GameServer.getInstance().mainLogicServer.addCommand(new ICommand() {
                @Override
                public void action() {
                    GameServer.ac.getBean(PlayerService.class).effectTimerLogic();
                }
            }, DealType.MAIN);
        } catch (Exception e) {
            LogUtil.error(e);
        }
    }


    /**
     * 荣耀生存玩法定时器
     * 一分钟一次
     */
    @Scheduled(initialDelay = 120 * 1000, fixedDelay = 60 * 1000)
    public void honourSurviveLogic() {
        try {
            if (GameServer.getInstance().mainLogicServer == null) {

                return;
            }
            GameServer.getInstance().mainLogicServer.addCommand(new ICommand() {
                @Override
                public void action() {
                    Calendar calendar = Calendar.getInstance();
                    int dayOfMonth = calendar.get(Calendar.DAY_OF_MONTH);
                    int hourOfDay = calendar.get(Calendar.HOUR_OF_DAY);
                    int minute = calendar.get(Calendar.MINUTE);
                    GameServer.ac.getBean(HonourSurviveService.class).honourLogic(dayOfMonth, hourOfDay, minute);
                }
            }, DealType.MAIN);
        } catch (Exception e) {
            LogUtil.error(e);
        }
    }


    /**
     * 资源/编制
     * 每秒一次
     */
    @Scheduled(initialDelay = 120 * 1000, fixedDelay = 1000)
    public void mineStaffingLogic() {
        try {
            if (GameServer.getInstance().mainLogicServer == null) {

                return;
            }
            GameServer.getInstance().mainLogicServer.addCommand(new ICommand() {
                @Override
                public void action() {
                    if (TimeHelper.isStaffingOpen()) {
                        GameServer.ac.getBean(WorldService.class).mineStaffingLogic();
                        GameServer.ac.getBean(SeniorMineService.class).mineStaffingLogic();
                        GameServer.ac.getBean(StaffingService.class).recalcWorldLv();
                        GameServer.ac.getBean(StaffingService.class).checkSaveExpAdd();

                        //跨服部队采集增加编制经验
                        GameServer.ac.getBean(CrossSeniorMineService.class).crossMineArmyStaffingLogic();
                    }
                }
            }, DealType.MAIN);
        } catch (Exception e) {
            LogUtil.error(e);
        }
    }

    /**
     * 在线玩家记录日志
     * 5分钟一次
     */
    @Scheduled(initialDelay = 120 * 1000, fixedDelay = 5 * 60 * 1000)
    public void onlinePlayerLogLogic() {
        try {
            if (GameServer.getInstance().mainLogicServer == null) {

                return;
            }
            GameServer.getInstance().mainLogicServer.addCommand(new ICommand() {
                @Override
                public void action() {
                    GameServer.ac.getBean(PlayerDataManager.class).logOnlinePlayer();
                }
            }, DealType.MAIN);
        } catch (Exception e) {
            LogUtil.error(e);
        }
    }

    /**
     * 军团排行
     * 5分钟一次
     */
    @Scheduled(initialDelay = 5 * 60 * 1000, fixedDelay = 5 * 60 * 1000)
    public void partyRankLogic() {
        try {
            if (GameServer.getInstance().mainLogicServer == null) {

                return;
            }
            GameServer.getInstance().mainLogicServer.addCommand(new ICommand() {
                @Override
                public void action() {
                    GameServer.ac.getBean(PartyService.class).partyTimerLogic();
                }
            }, DealType.MAIN);
        } catch (Exception e) {
            LogUtil.error(e);
        }
    }

    /**
     * 制造车间定时器
     * 每秒一次
     */
    @Scheduled(initialDelay = 120 * 1000, fixedDelay = 1000)
    public void propQueLogic() {
        try {
            if (GameServer.getInstance().mainLogicServer == null) {

                return;
            }
            GameServer.getInstance().mainLogicServer.addCommand(new ICommand() {
                @Override
                public void action() {
                    GameServer.ac.getBean(PropService.class).propQueTimerLogic();
                }
            }, DealType.MAIN);
        } catch (Exception e) {
            LogUtil.error(e);
        }
    }

    /**
     * 定时检查并删除红包 1.每天凌晨3点，清除所有红包
     */
    @Scheduled(cron = "0 0 3 * * ?")
    public void deleteRebelRedBagLogic() {
        try {
            if (GameServer.getInstance().mainLogicServer == null) {

                return;
            }
            GameServer.getInstance().mainLogicServer.addCommand(new ICommand() {
                @Override
                public void action() {
                    GameServer.ac.getBean(RebelService.class).clearRedBagLogic();
                }
            }, DealType.MAIN);
        } catch (Exception e) {
            LogUtil.error(e);
        }
    }


    /**
     * 红色方案 燃料生产
     * 每秒一次
     */
    @Scheduled(initialDelay = 120 * 1000, fixedDelay = 1000)
    public void redPlanFuelLogic() {
        try {
            if (GameServer.getInstance().mainLogicServer == null) {

                return;
            }
            GameServer.getInstance().mainLogicServer.addCommand(new ICommand() {
                @Override
                public void action() {
                    GameServer.ac.getBean(RedPlanService.class).redPlanFuelLogic();
                }
            }, DealType.MAIN);
        } catch (Exception e) {
            LogUtil.error(e);
        }
    }

    /**
     * 记录资源产量
     */
    @Scheduled(initialDelay = 60 * 60 * 1000, fixedDelay = 60 * 60 * 1000)
    public void resourceLogLogic() {
        try {
            if (GameServer.getInstance().mainLogicServer == null) {

                return;
            }
            GameServer.getInstance().mainLogicServer.addCommand(new ICommand() {
                @Override
                public void action() {
                    GameServer.ac.getBean(PlayerDataManager.class).logResourceHour();
                }
            }, DealType.MAIN);
        } catch (Exception e) {
            LogUtil.error(e);
        }
    }

    /**
     * 玩家资源
     * 每秒一次
     */
    @Scheduled(initialDelay = 120 * 1000, fixedDelay = 1000)
    public void resourceLogic() {
        try {
            if (GameServer.getInstance().mainLogicServer == null) {

                return;
            }
            GameServer.getInstance().mainLogicServer.addCommand(new ICommand() {
                @Override
                public void action() {
                    GameServer.ac.getBean(BuildingService.class).resourceTimerLogic();
                }
            }, DealType.MAIN);
        } catch (Exception e) {
            LogUtil.error(e);
        }
    }

    /**
     * 恢复能量和繁荣度
     * 每秒一次
     */
    @Scheduled(initialDelay = 120 * 1000, fixedDelay = 1000)
    public void restoreLogic() {
        try {
            if (GameServer.getInstance().mainLogicServer == null) {

                return;
            }
            GameServer.getInstance().mainLogicServer.addCommand(new ICommand() {
                @Override
                public void action() {
                    GameServer.ac.getBean(PlayerService.class).restoreDataTimerLogic();
                }
            }, DealType.MAIN);
        } catch (Exception e) {
            LogUtil.error(e);
        }
    }

    /**
     * 科技升级定时器
     * 每秒一次
     */
    @Scheduled(initialDelay = 120 * 1000, fixedDelay = 1000)
    public void scienceQueLogic() {
        try {
            if (GameServer.getInstance().mainLogicServer == null) {

                return;
            }
            GameServer.getInstance().mainLogicServer.addCommand(new ICommand() {
                @Override
                public void action() {
                    GameServer.ac.getBean(ScienceService.class).scienceQueTimerLogic();
                }
            }, DealType.MAIN);
        } catch (Exception e) {
            LogUtil.error(e);
        }
    }

    /**
     * 军事矿区计时器
     * 每秒一次
     */
    @Scheduled(cron = "0 0 0 ? * SAT")
    public void flushSeniorInSat() {
        try {
            if (GameServer.getInstance().mainLogicServer == null) {
                return;
            }
            GameServer.getInstance().mainLogicServer.addCommand(new ICommand() {
                @Override
                public void action() {
                    GameServer.ac.getBean(SeniorMineService.class).flushSeniorInSat();
                }
            }, DealType.MAIN);
        } catch (Exception e) {
            LogUtil.error(e);
        }
    }

    @Scheduled(cron = "0 0 0 ? * MON")
    public void flushSeniorInMon() {
        try {
            if (GameServer.getInstance().mainLogicServer == null) {
                return;
            }
            GameServer.getInstance().mainLogicServer.addCommand(new ICommand() {
                @Override
                public void action() {
                    GameServer.ac.getBean(SeniorMineService.class).flushSeniorInMon();
                }
            }, DealType.MAIN);
        } catch (Exception e) {
            LogUtil.error(e);
        }
    }

    /**
     * 玩家数据统计定时器
     * 每天0点1分执行
     */
    @Scheduled(cron = "0 1 0 * * ?")
    public void statisticsLogLogic() {
        try {
            if (GameServer.getInstance().mainLogicServer == null) {

                return;
            }
            GameServer.getInstance().mainLogicServer.addCommand(new ICommand() {
                @Override
                public void action() {
                    GameServer.ac.getBean(StatisticsService.class).logOperationStatisticsTimerLogic();
                }
            }, DealType.MAIN);
        } catch (Exception e) {
            LogUtil.error(e);
        }
    }


    /**
     * 坦克/军备 生产\
     * 每秒一次
     */
    @Scheduled(initialDelay = 120 * 1000, fixedDelay = 1000)
    public void tankQueLogic() {
        try {
            if (GameServer.getInstance().mainLogicServer == null) {

                return;
            }
            GameServer.getInstance().mainLogicServer.addCommand(new ICommand() {
                @Override
                public void action() {
                    //坦克成产队列
                    GameServer.ac.getBean(ArmyService.class).tankQueTimerLogic();
                    //军备材料生产队列逻辑
                    GameServer.ac.getBean(LordEquipService.class).materailQueueTimeLogic();
                }
            }, DealType.MAIN);
        } catch (Exception e) {
            LogUtil.error(e);
        }
    }

    /**
     * 每天凌晨过5秒 解散 赏金队伍
     */
    @Scheduled(cron = "5 0 0 * * ?")
    public void disInvalidTeamLogic() {
        try {
            if (GameServer.getInstance().mainLogicServer == null) {

                return;
            }
            GameServer.getInstance().mainLogicServer.
                    addCommand(new ICommand() {
                        @Override
                        public void action() {
                            GameServer.ac.getBean(TeamService.class).disInvalidTeamLogic();
                        }
                    }, DealType.MAIN);
        } catch (Exception e) {
            LogUtil.error(e);
        }
    }

    /**
     * 百团大战 红蓝大战 叛军 跨服心跳定时器
     * 每秒一次
     */
    @Scheduled(initialDelay = 120 * 1000, fixedDelay = 1000)
    public void warLogic() {
        try {
            if (GameServer.getInstance().mainLogicServer == null) {

                return;
            }
            GameServer.getInstance().mainLogicServer.
                    addCommand(new ICommand() {
                        @Override
                        public void action() {
                            GameServer.ac.getBean(WarService.class).warTimerLogic();
                            GameServer.ac.getBean(DrillService.class).drillTimerLogic();
                            GameServer.ac.getBean(RebelService.class).rebelTimerLogic();
                        }
                    }, DealType.MAIN);
        } catch (Exception e) {
            LogUtil.error(e);
        }
    }

    /**
     * 世界地图上矿点资源的处理(1分钟执行一次)
     */
    @Scheduled(initialDelay = 120 * 1000, fixedDelay = 60 * 1000)
    public void worldMineLogic() {
        try {
            if (GameServer.getInstance().mainLogicServer == null) {

                return;
            }
            GameServer.getInstance().mainLogicServer.
                    addCommand(new ICommand() {
                        @Override
                        public void action() {
                            GameServer.ac.getBean(WorldMineService.class).wroldMineLogic();
                        }
                    }, DealType.MAIN);
        } catch (Exception e) {
            LogUtil.error(e);
        }
    }

    /**
     * 行军/飞艇  定时
     * 每秒一次
     */
    @Scheduled(initialDelay = 120 * 1000, fixedDelay = 1000)
    public void armyShipLogic() {
        try {
            if (GameServer.getInstance().mainLogicServer == null) {

                return;
            }
            GameServer.getInstance().mainLogicServer.
                    addCommand(new ICommand() {
                        @Override
                        public void action() {
                            GameServer.ac.getBean(WorldService.class).worldTimerLogic();
                            GameServer.ac.getBean(AirshipService.class).timerLogic();
                        }
                    }, DealType.MAIN);
        } catch (Exception e) {
            LogUtil.error(e);
        }
    }


    /**
     * 军团充值
     * 凌晨一次
     */
    @Scheduled(cron = "1 0 0 * * ?")
    public void signPartyLogic() {
        try {
            if (GameServer.getInstance().mainLogicServer == null) {
                return;
            }
            GameServer.getInstance().mainLogicServer.
                    addCommand(new ICommand() {
                        @Override
                        public void action() {
                            GameServer.ac.getBean(PartyDataManager.class).signPartyRecharge();
                        }
                    }, DealType.MAIN);
        } catch (Exception e) {
            LogUtil.error(e);
        }
    }

}
