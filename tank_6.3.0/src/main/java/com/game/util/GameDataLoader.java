package com.game.util;

import com.game.common.TankException;
import com.game.manager.*;
import com.game.server.GameServer;
import com.game.service.LoadService;
import com.hotfix.GameAgent;

/**
 * @ClassName GameDataLoader.java
 * @Description 游戏数据统一加载类
 * @author TanDonghai
 * @date 创建时间:2017年3月17日 上午11:29:20
 *
 */
public class GameDataLoader {

	private static GameDataLoader instance = new GameDataLoader();

	private GameDataLoader() {
	}

	public static GameDataLoader getIns() {
		return instance;
	}

	/**
	 * 游戏启动时，按次序加载数据
	 * 
	 * @throws TankException
	 */
	public void loadGameData() throws TankException {
		// 加载配置文件数据
		loadFileData();

		// 加载常量数据
		loadConstant();

		// 加载玩家相关数据
		loadPlayerData();
	}

	private void loadFileData() {
		LogUtil.start("**********开始加载配置文件数据**********");
		LogUtil.start("**********加载配置文件数据完成**********");
	}

	private void loadConstant() throws TankException {
		LogUtil.start("**********开始加载配置表数据**********");
		try {
			LoadService loadService = GameServer.ac.getBean(LoadService.class);
			loadService.reloadAll();
		} catch (Exception e) {
			throw new TankException("加载配置表数据出错", e);
		}
		LogUtil.start("**********配置表数据加载完成**********");
	}

	private void loadPlayerData() throws TankException {
		LogUtil.start("**********开始加载用户相关数据**********");
		try {
		    //加载需要修复的数据
		    GameServer.ac.getBean(DataRepairDM.class).init();
		    LogUtil.start("加载完成:修复数据表");

			// 加载小号数据
			GameServer.ac.getBean(SmallIdManager.class).init();
			LogUtil.start("加载完成:小号数据");

			// 加载全局公用数据
			GameServer.ac.getBean(GlobalDataManager.class).init();
			LogUtil.start("加载完成:global数据");

            //todo:zhangdh 替换Global中的LordId
            GameServer.ac.getBean(DataRepairDM.class).replaceLordIdInGlobal();
            
            //todo: zhangdh 替换Global中的PartyId
            GameServer.ac.getBean(DataRepairDM.class).replacePartyInGlobal();

			// 加载编制数据
			GameServer.ac.getBean(StaffingDataManager.class).init();
			LogUtil.start("加载完成:编制数据");

			// 加载世界地图相关数据
			GameServer.ac.getBean(WorldDataManager.class).init();
			LogUtil.start("加载完成:世界地图数据");

			// 加载军团数据
			GameServer.ac.getBean(PartyDataManager.class).init();
			LogUtil.start("加载完成:军团数据");

            //todo:zhangdh 替换军团中的LordId
            GameServer.ac.getBean(DataRepairDM.class).replaceLordIdInPartyData();

			// 加载世界BOSS数据
			GameServer.ac.getBean(BossDataManager.class).init();
			LogUtil.start("加载完成:BOSS");

			// 加载玩家角色数据
			GameServer.ac.getBean(PlayerDataManager.class).init();
			LogUtil.start("加载完成:角色相关数据");

            //todo: zhangdh 更新玩家自己保存的LordId
            GameServer.ac.getBean(DataRepairDM.class).replacePlayerLordId();

			// 加载竞技场数据
			GameServer.ac.getBean(ArenaDataManager.class).init();
			LogUtil.start("加载完成:竞技场");

			// 加载副本挑战数据
			GameServer.ac.getBean(ExtremeDataManager.class).init();
			LogUtil.start("加载完成:极限副本");

			// 加载军事矿区数据
			GameServer.ac.getBean(SeniorMineDataManager.class).init();
			LogUtil.start("加载完成:军事矿区");

			// 加载要塞战、军团战等活动数据
			GameServer.ac.getBean(WarDataManager.class).init();
			LogUtil.start("加载完成:要塞战、军团战等活动数据");

			// 加载军事演习活动数据
			GameServer.ac.getBean(DrillDataManager.class).init();
			LogUtil.start("加载完成:军事演习活动数据");

			// 加载叛军活动数据
			GameServer.ac.getBean(RebelDataManager.class).init();
			LogUtil.start("加载完成:叛军活动数据");
			
			// 加载荣耀玩法数据
			GameServer.ac.getBean(HonourDataManager.class).init();
			LogUtil.start("加载完成:荣耀生存玩法数据");

			// 加载活动数据
			GameServer.ac.getBean(ActivityDataManager.class).init();
			LogUtil.start("加载完成:活动数据");

            //todo:zhangdh 替换活动中的lordId
            GameServer.ac.getBean(DataRepairDM.class).replaceLordIdInActivity();

            //todo: zhangdh 替换活动中的PartyId
            GameServer.ac.getBean(DataRepairDM.class).reaplcePartyIdInActivity();

			// 加载跨服战数据
			GameServer.ac.getBean(CrossDataManager.class).init();
			LogUtil.start("加载完成:跨服战数据");

			//加载服务器热更数据
            GameServer.ac.getBean(HotfixDataManager.class).init();
            LogUtil.start("服务器热更已启动");

            LogUtil.start("服务器热更钩子 game-agent : "+ GameAgent.inst);
		} catch (Exception e) {
			throw new TankException("加载玩家数据失败", e);
		}
		LogUtil.start("**********用户相关数据加载完成**********");
	}
}
