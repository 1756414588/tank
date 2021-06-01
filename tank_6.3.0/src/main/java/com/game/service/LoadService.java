package com.game.service;

import com.alibaba.fastjson.JSONArray;
import com.game.constant.*;
import com.game.dataMgr.*;
import com.game.dataMgr.friend.StaticFriendDataMgr;
import com.game.dataMgr.friend.StaticFriendGiftDataMgr;
import com.game.domain.Player;
import com.game.domain.p.Prop;
import com.game.domain.s.StaticSystem;
import com.game.honour.domain.HonourConstant;
import com.game.manager.PlayerDataManager;
import com.game.util.CheckNull;
import com.game.util.LogUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * @ClassName LoadService.java
 * @Description 角色相关
 * @author TanDonghai
 * @date 创建时间：2016年9月6日 上午11:32:18
 *
 */
@Service
public class LoadService {
	@Autowired
	private StaticActionMsgDataMgr staticActionMsgDataMgr;
	@Autowired
	private StaticActivityDataMgr staticActivityDataMgr;
	@Autowired
	private StaticAwardsDataMgr staticAwardsDataMgr;
	@Autowired
	private StaticBuildingDataMgr staticBuildingDataMgr;
	@Autowired
	private StaticCombatDataMgr staticCombatDataMgr;
	@Autowired
	private StaticCostDataMgr staticCostDataMgr;
	@Autowired
	private StaticDrillDataManager staticDrillDataManager;
	@Autowired
	private StaticEnergyStoneDataMgr staticEnergyStoneDataMgr;
	@Autowired
	private StaticBackDataMgr staticBackDataMgr;
	@Autowired
	private StaticEquipDataMgr staticEquipDataMgr;
	@Autowired
	private StaticFortressDataMgr staticFortressDataMgr;
	@Autowired
	private StaticHeroDataMgr staticHeroDataMgr;
	@Autowired
	private StaticIniDataMgr staticIniDataMgr;
	@Autowired
	private StaticLordDataMgr staticLordDataMgr;
	@Autowired
	private StaticMailDataMgr staticMailDataMgr;
	@Autowired
	private StaticMilitaryDataMgr staticMilitaryDataMgr;
	@Autowired
	private StaticPartDataMgr staticPartDataMgr;
	@Autowired
	private StaticPartyDataMgr staticPartyDataMgr;
	@Autowired
	private StaticPropDataMgr staticPropDataMgr;
	@Autowired
	private StaticRebelDataMgr staticRebelDataMgr;
	@Autowired
	private StaticRefineDataMgr staticRefineDataMgr;
	@Autowired
	private StaticShopDataMgr staticShopDataMgr;
	@Autowired
	private StaticSignDataMgr staticSignDataMgr;
	@Autowired
	private StaticStaffingDataMgr staticStaffingDataMgr;
	@Autowired
	private StaticTankDataMgr staticTankDataMgr;
	@Autowired
	private StaticTaskDataMgr staticTaskDataMgr;
	@Autowired
	private StaticVipDataMgr staticVipDataMgr;
	@Autowired
	private StaticWarAwardDataMgr staticWarAwardDataMgr;
	@Autowired
	private StaticWorldDataMgr staticWorldDataMgr;
	@Autowired
	private StaticMedalDataMgr staticMedalDataMgr;
	@Autowired
	private StaticFormulaDataMgr staticFormulaDataMgr;
	@Autowired
	private StaticFunctionPlanDataMgr staticFunctionPlanDataMgr;
    @Autowired
	private StaticSecretWeaponDataMgr staticSecretWeaponDataMgr;
    @Autowired
    private StaticAttackEffectDataMgr staticAttackEffectDataMgr;
	@Autowired
	private StaticCrossDataMgr staticCrossDataMgr;
	@Autowired
	private PlayerDataManager playerDataManager;
	@Autowired
	private StaticLabDataMgr staticLabDataMgr;
	@Autowired
	private StaticGifttoryDataMgr staticGifttoryDataMgr;
	@Autowired
	private StaticRedPlanMgr staticRedPlanMgr;
	@Autowired
	private StaticActivateNewMgr staticActivateNewMgr;
	@Autowired
	private StaticBountyDataMgr staticBountyDataMgr;
	@Autowired
	private StaticTankConvertDataMgr staticTankConvertDataMgr;
	@Autowired
	private StaticActiveBoxDataMgr staticActiveBoxDataMgr;
	@Autowired
	private StaticHonourSurviveMgr staticHonourSurviveMgr;
	@Autowired
	private StaticScoutDataMgr staticScoutDataMgr;
	@Autowired
	private StaticActionAltarBossDataMgr staticActionAltarBossDataMgr;
	@Autowired
	private StaticTacticsDataMgr staticTacticsDataMgr;
	@Autowired
	private StaticActivateKingMgr staticActivateKingMgr;
	@Autowired
	private StaticFriendDataMgr staticFriendDataMgr;
	@Autowired
	private StaticFriendGiftDataMgr staticFriendGiftDataMgr;
	@Autowired
	private StaticCoreDataMgr staticCoreDataMgr;

	@Autowired
	private StaticPeakMgr staticPeakMgr;


	/**
	 * 重加载s_system表数据，并重新初始化相关数据
	 */
	public void loadSystem() {
		staticIniDataMgr.initSystem();
		Constant.loadSystem(this);
		LogUtil.common("*************Constant加载完成*************");
		RebelConstant.loadSystem(this);
		LogUtil.common("*************RebelConstant加载完成*************");
		MedalConst.loadSystem(this);
		LogUtil.common("*************MedalConst加载完成*************");
		BuildConst.loadSystem(this);
		LogUtil.common("*************BuildConst加载完成*************");
		MineConst.loadSystem(this);
		LogUtil.common("*************MineConst加载完成*************");
		AirshipConst.loadSystem(this);
		LogUtil.common("*************AirshipConst加载完成*************");
        LordEquipConst.loadSystem(this);
        LogUtil.common("*************LordEquipConst加载完成*************");
        HonourConstant.loadSystem(this);
        LogUtil.common("*************HonourSurviveConst加载完成*************");

	}
	
	/**
	 * 
	*   移除97-99三种物品
	* void
	 */
	public void clearErrorProps() {
		Map<Integer, Prop> props;
		Map<Long, Player> players = playerDataManager.getPlayers();
		for (Player player : players.values()) {
			if (null != player) {
				props = player.props;
				// 移除97-99三种物品
				props.remove(97);
				props.remove(98);
				props.remove(99);
			}
		}
	}

	/**
	 * 重加载所有配置数据
	 */
	public void reloadAll() {
		LogUtil.common("------------------重加载数据：行为推送消息-----------------");
		staticActionMsgDataMgr.reload();
		LogUtil.common("------------------重加载数据：活动相关-----------------");
		staticActivityDataMgr.reload();
		LogUtil.common("------------------重加载数据：奖励项配置-----------------");
		staticAwardsDataMgr.reload();
		LogUtil.common("------------------重加载数据：建筑相关-----------------");
		staticBuildingDataMgr.reload();
		LogUtil.common("------------------重加载数据：副本相关-----------------");
		staticCombatDataMgr.reload();
		LogUtil.common("------------------重加载数据：消费配置-----------------");
		staticCostDataMgr.reload();
		LogUtil.common("------------------重加载数据：军事演习（红蓝大战）相关-----------------");
		staticDrillDataManager.reload();
		LogUtil.common("------------------重加载数据：能晶相关-----------------");
		staticEnergyStoneDataMgr.reload();
		LogUtil.common("------------------重加载数据：装备相关-----------------");
		staticEquipDataMgr.reload();
		LogUtil.common("------------------重加载数据：要塞战相关-----------------");
		staticFortressDataMgr.reload();
		LogUtil.common("------------------重加载数据：将领相关-----------------");
		staticHeroDataMgr.reload();
		LogUtil.common("------------------重加载数据：玩家昵称、初始属性等-----------------");
		staticIniDataMgr.reload();
		LogUtil.common("------------------重加载数据：玩家属性相关配置-----------------");
		staticLordDataMgr.reload();
		LogUtil.common("------------------重加载数据：邮件-----------------");
		staticMailDataMgr.reload();
		LogUtil.common("------------------重加载数据：科技相关-----------------");
		staticMilitaryDataMgr.reload();
		LogUtil.common("------------------重加载数据：配件相关-----------------");
		staticPartDataMgr.reload();
		LogUtil.common("------------------重加载数据：军团相关-----------------");
		staticPartyDataMgr.reload();
		LogUtil.common("------------------重加载数据：物品配置-----------------");
		staticPropDataMgr.reload();
		LogUtil.common("------------------重加载数据：叛军入侵相关-----------------");
		staticRebelDataMgr.reload();
		LogUtil.common("------------------重加载数据：精炼配置-----------------");
		staticRefineDataMgr.reload();
		LogUtil.common("------------------重加载数据：（荒宝）商店配置-----------------");
		staticShopDataMgr.reload();
		LogUtil.common("------------------重加载数据：登陆活动-----------------");
		staticSignDataMgr.reload();
		LogUtil.common("------------------重加载数据：编制经验相关-----------------");
		staticStaffingDataMgr.reload();
		LogUtil.common("------------------重加载数据：坦克配置相关-----------------");
		staticTankDataMgr.reload();
		LogUtil.common("------------------重加载数据：任务相关-----------------");
		staticTaskDataMgr.reload();
		LogUtil.common("------------------重加载数据：充值、VIP相关-----------------");
		staticVipDataMgr.reload();
		LogUtil.common("------------------重加载数据：战争类活动奖励-----------------");
		staticWarAwardDataMgr.reload();
		LogUtil.common("------------------重加载数据：矿区配置-----------------");
		staticWorldDataMgr.reload();
		staticWarAwardDataMgr.reload();
		LogUtil.common("------------------重加载数据：勋章-----------------");
		staticMedalDataMgr.reload();
        LogUtil.common("------------------重加载数据：合成公式-----------------");
        staticFormulaDataMgr.reload();
        LogUtil.common("------------------重加载数据：功能开关-----------------");
        staticFunctionPlanDataMgr.reload();
		LogUtil.common("------------------重加载数据：跨服战-----------------");
		staticCrossDataMgr.reload();
	    LogUtil.common("------------------重加载数据：回归-----------------");
		staticBackDataMgr.reload();
		LogUtil.common("------------------重加载数据：秘密武器-----------------");
        staticSecretWeaponDataMgr.reload();
        LogUtil.common("------------------重加载数据：兵种攻击特效-----------------");
        staticAttackEffectDataMgr.reload();
		LogUtil.common("------------------重加载数据：作战研究院-----------------");
		staticLabDataMgr.reload();
		LogUtil.common("------------------重加载数据：点击宝箱获得奖励-----------------");
		staticGifttoryDataMgr.reload();
		LogUtil.common("------------------重加载数据：红色方案-----------------");
		staticRedPlanMgr.reload();
		LogUtil.common("------------------重加载数据：假日碎片 幸运奖池-----------------");
		staticActivateNewMgr.reload();
		LogUtil.common("------------------重加载数据：组队副本-----------------");
		staticBountyDataMgr.reload();
		LogUtil.common("------------------重加载数据：坦克转换活动-----------------");
		staticTankConvertDataMgr.reload();
		LogUtil.common("------------------重加载数据：活跃宝箱-----------------");
		staticActiveBoxDataMgr.reload();
		LogUtil.common("------------------重加载数据：荣耀生存-----------------");
		staticScoutDataMgr.reload();
		LogUtil.common("------------------重加载数据：扫矿验证图片-----------------");
		staticHonourSurviveMgr.reload();
		LogUtil.common("------------------重加载数据：祭坛Boss喂养-----------------");
		staticActionAltarBossDataMgr.reload();
		LogUtil.common("------------------重加载数据：战术大师-----------------");
		staticTacticsDataMgr.reload();
		LogUtil.common("------------------重加载数据：最强王者活動-----------------");
		staticActivateKingMgr.reload();
		LogUtil.common("------------------重加载数据：好友度增加数据-----------------");
		staticFriendDataMgr.reload();
		LogUtil.common("------------------重加载数据：好友赠送道具数据-----------------");
		staticFriendGiftDataMgr.reload();

		LogUtil.common("------------------重加载数据：-----------------");
		staticCoreDataMgr.reload();

		staticPeakMgr.reload();
		LogUtil.common("------------------重加载数据：重新初始化system表数据-----------------");
		loadSystem();
		LogUtil.common("------------------所有配置表数据重加载完成-----------------");

	}

	/**
	 * 根据systemId获取对应的值，以int类型返回
	 * 
	 * @param systemId
	 * @param defaultVaule 当表中找不到该配置项时，返回的默认值
	 * @return
	 */
	public int getIntegerSystemValue(int systemId, int defaultVaule) {
		StaticSystem ss = staticIniDataMgr.getSystemConstantById(systemId);
		if (null != ss) {
			return Integer.valueOf(ss.getValue());
		}
		return defaultVaule;
	}

	/**
	 * 
	* 获得系统参数 s_system表 必须是数字型
	* @param systemId
	* @param defaultVaule
	* @return  
	* long
	 */
	public long getLongSystemValue(int systemId, long defaultVaule) {
		StaticSystem ss = staticIniDataMgr.getSystemConstantById(systemId);
		if (null != ss) {
			return Long.valueOf(ss.getValue());
		}
		return defaultVaule;
	}

	/**
	 * 
	* 获得系统参数 s_system表 
	* @param systemId
	* @param defaultVaule
	* @return  
	* float
	 */
	public float getFloatSystemValue(int systemId, float defaultVaule) {
		StaticSystem ss = staticIniDataMgr.getSystemConstantById(systemId);
		if (null != ss) {
			return Float.valueOf(ss.getValue());
		}
		return defaultVaule;
	}

	/**
	 * 
	* 获得系统参数 s_system表 
	* @param systemId
	* @param defaultVaule
	* @return  
	* double
	 */
	public double getDoubleSystemValue(int systemId, double defaultVaule) {
		StaticSystem ss = staticIniDataMgr.getSystemConstantById(systemId);
		if (null != ss) {
			return Double.valueOf(ss.getValue());
		}
		return defaultVaule;
	}

	/**
	 * 
	*  获得系统参数 s_system表 
	* @param systemId
	* @param defaultVaule
	* @return  
	* String
	 */
	public String getStringSystemValue(int systemId, String defaultVaule) {
		StaticSystem ss = staticIniDataMgr.getSystemConstantById(systemId);
		if (null != ss) {
			return ss.getValue();
		}
		return defaultVaule;
	}
	
	/**
	 * 
	*  获得系统参数 s_honour_live_system表 
	* @param systemId
	* @param defaultVaule
	* @return  
	* String
	 */
	public String getStringHonourValue(int systemId, String defaultVaule) {
		StaticSystem ss = staticIniDataMgr.getHonourConstantById(systemId);
		if (null != ss) {
			return ss.getValue();
		}
		return defaultVaule;
	}
	
	/**
	 * 根据systemId获取对应的值，返回 嵌套List 类型
	 * 
	 * @param systemId
	 * @param defaultVaule 当表中找不到该配置项时，返回由该字符串解析出的 嵌套List，<br>
	 *            <tt>特别注意：<tt>如果找不到配置项且传入的字符串为null或空字符串，将会返回null
	 * @return
	 */
	public List<List<Integer>> getListListIntSystemValue(int systemId, String defaultVaule) {
		String str = getStringSystemValue(systemId, defaultVaule);
		if (CheckNull.isNullTrim(str)) {
			return null;
		}

		JSONArray arrs = JSONArray.parseArray(str);
		List<List<Integer>> list = new ArrayList<>();
		for (int i = 0; i < arrs.size(); i++) {
			JSONArray a = arrs.getJSONArray(i);
			List<Integer> arr = new ArrayList<>();
			for (int j = 0; j < a.size(); j++) {
				arr.add(a.getInteger(j));
			}
			list.add(arr);
		}
		return list;
	}
}
