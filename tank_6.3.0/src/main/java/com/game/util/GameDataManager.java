package com.game.util;

import com.game.common.TankException;
import com.game.dataMgr.StaticFunctionPlanDataMgr;
import com.game.domain.Player;
import com.game.manager.*;
import com.game.server.GameServer;
import com.game.service.BuildingService;
import com.game.service.FortressWarService;
import com.game.service.SecretWeaponService;

import java.util.Map;

/**
 * @author TanDonghai
 * @ClassName GameDataManager.java
 * @Description 所有数据加载完成后，数据检查，数据管理，或临时bug数据修复等功能的集中处理类
 * @date 创建时间：2017年3月17日 下午4:10:29
 */
public class GameDataManager {
    private static GameDataManager instance = new GameDataManager();

    private GameDataManager() {
    }

    public static GameDataManager getIns() {
        return instance;
    }

    /**
     * 数据加载完成后，数据处理逻辑入口
     *
     * @throws TankException
     */
    public void dataHandle() throws TankException {
        LogUtil.start("数据处理逻辑开始");
        // 处理数据加载完成后，数据检查、计算、整理等相关操作
        calculateLogic();

        // 处理常驻的数据修复或检查逻辑
        usualLogic();

        // 处理临时BUG等只使用一次的逻辑，使用后不需要常驻的注释掉
        repairGameDataLogic();

        repairGameDayiyTaskLogic();

        LogUtil.start("数据处理逻辑结束");
    }

    /**
     * 需要等到所有玩家数据加载完成后，才能并且必须马上执行的逻辑，注册在这里按次序执行
     *
     * @throws TankException
     */
    private void calculateLogic() throws TankException {
        try {
            GameServer.ac.getBean(RebelDataManager.class).initData();
            LogUtil.start("叛军活动数据初始化完成");
            GameServer.ac.getBean(HonourDataManager.class).initData();
            LogUtil.start("荣耀生存玩法数据初始化完成");

            // 计算空余的位置（世界地图中的坐标）集合
            GameServer.ac.getBean(WorldDataManager.class).caluFreePostList();
            LogUtil.start("计算空余坐标逻辑执行完成");

            if (GameServer.ac.getBean(AirshipDataManager.class).firstLoadAirship()) {
                LogUtil.start("飞艇载入世界完成");
            }
        } catch (Exception e) {
            throw new TankException("数据处理逻辑出错", e);
        }
    }

    /**
     * 一些偶然出现的，非必现问题的修复，需要常驻的逻辑，在这里统一执行
     *
     * @throws TankException
     */
    private void usualLogic() throws TankException {
        try {
            // 错误玩家pos重新随机
            GameServer.ac.getBean(WorldDataManager.class).randomNewPos();
            LogUtil.start("错误玩家坐标重新随机逻辑执行完成");

            //在周六23:00---周日19:30 启动服务器(第三次军团战结束到要塞战开启之前)
            if (TimeHelper.isThisWeekSaturday2300ToSunday1930()) {
                int fortressTime = GameServer.ac.getBean(GlobalDataManager.class).gameGlobal.getCalCanJoinFortressTime();
                if (fortressTime > 0 && !TimeHelper.isThisWeek(fortressTime)) {
                    GameServer.ac.getBean(FortressWarService.class).calCanFightFortressParty();
                    LogUtil.start("周六停服维护导致要塞战数据未初始化处理完成");
                }
            }

            //重新计算资源的容量
            PlayerDataManager playerDataManager = GameServer.ac.getBean(PlayerDataManager.class);
            BuildingService bs = GameServer.ac.getBean(BuildingService.class);
            for (Map.Entry<Long, Player> entry : playerDataManager.getPlayers().entrySet()) {
                bs.recalcResourceOut(entry.getValue());
            }

            //修复玩家基地坐标和玩家重复问题
            GameServer.ac.getBean(WorldDataManager.class).updatePlayerPos();

        } catch (Exception e) {
            throw new TankException("常驻的数据修复或检查逻辑出错", e);
        }
    }

    /**
     * 临时BUG，必须马上解决线上问题的修复逻辑，在这里执行
     *
     * @throws TankException
     */
    private void repairGameDataLogic() throws TankException {
        try {
            PlayerDataManager playerDataManager = GameServer.ac.getBean(PlayerDataManager.class);
            // 修复以前玩家重名，修正
            playerDataManager.repairPlayerNameRepeatBug();
            LogUtil.start("玩家重名修正逻辑执行完成");

            //如果秘密武器的功能开关已经打开，则初始化玩家秘密武器
            StaticFunctionPlanDataMgr functionPlanDataMgr = GameServer.ac.getBean(StaticFunctionPlanDataMgr.class);
            if (functionPlanDataMgr.isSecretWeaponOpen()) {
                SecretWeaponService service = GameServer.ac.getBean(SecretWeaponService.class);
                for (Map.Entry<Long, Player> entry : playerDataManager.getPlayers().entrySet()) {
                    service.checkLevelUp(entry.getValue());
                }
            }

            //修复玩家坐标与矿点坐标重复BUG
//            GameServer.ac.getBean(DataRepairDM.class).repaireMineRepeat();

//            for (Map.Entry<Long, Player> entry : playerDataManager.getPlayers().entrySet()) {
//                entry.getValue().activitys.remove(ActivityConst.ACT_LOTTERY_EXPLORE);
//            }



        } catch (Exception e) {
            throw new TankException("临时修复逻辑出错", e);
        }
    }

    /**
     * 修复线上由于等级表未传，导致获取经验报错，导致每日任务领奖后不增加一个任务BUG，数据修正从<5改为5
     */
    private void repairGameDayiyTaskLogic() throws TankException {
        try {
            // 修复以前玩家重名，修正
            GameServer.ac.getBean(PlayerDataManager.class).repairPlayerDayiyTaskBug();
            LogUtil.start("日常任务修正逻辑执行完成");
        } catch (Exception e) {
            throw new TankException("临时修复逻辑出错", e);
        }
    }
}
