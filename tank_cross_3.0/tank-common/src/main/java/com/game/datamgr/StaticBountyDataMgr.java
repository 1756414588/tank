package com.game.datamgr;

import com.game.dao.impl.s.StaticDataDao;
import com.game.domain.s.*;
import com.game.util.LogUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.*;

/**
 * @author: LiFeng
 * @date: 4.19
 * @description: 赏金活动组队副本
 */
@Component
public class StaticBountyDataMgr extends BaseDataMgr {

	@Autowired
	private StaticDataDao staticDataDao;
	
	private Map<Integer, StaticBountySkill> bountySkillConfig = new HashMap<>();
	private Map<Integer, StaticBountyWanted> bountyWantedConfig = new HashMap<>();
	private List<StaticBountyWanted> bountyWantedConfigList = Collections.synchronizedList(new ArrayList<StaticBountyWanted>());
	private Map<Integer, List<StaticBountyWanted>> bountyWantedConfigMap = new HashMap<>();
	private Map<Integer, List<StaticBountyEnemy>> bountyEnemyConfig = new HashMap<>();
	private Map<Integer, StaticBountyStage> bountyStageConfig = new HashMap<>();
	private Map<Integer, StaticBountyBoss> bountyBossConfig = new HashMap<>();
	private Map<Integer, StaticBountyShop> bountyShopConfigMap = new HashMap<>();
	private List<StaticBountyShop> bountyShopConfigList = new ArrayList<>();
	private StaticBountyConfig bountyConfig = new StaticBountyConfig() ;

	/**
	 * 赏金商店
	 * 
	 * @param goodId
	 * @return
	 */
	public StaticBountyShop getBountyShopConfig(int goodId) {
		return bountyShopConfigMap.get(goodId);
	}
	
	public StaticBountyStage getBountyStageConfig(int id) {
		return bountyStageConfig.get(id);
	}
	
	public Map<Integer, StaticBountyStage> getBountyStageConfigMap() {
		return new HashMap<Integer, StaticBountyStage>(bountyStageConfig);
	}

	public StaticBountyBoss getBountyBossConfig(int id) {
		return bountyBossConfig.get(id);
	}

	public List<StaticBountyEnemy> getBountyEnemyConfig(int id) {
		return bountyEnemyConfig.get(id);
	}
	
	public List<StaticBountyShop> getBountyShopConfigList(){
		return bountyShopConfigList;
	}
	
	public List<StaticBountyWanted> getBountyWantedConfigList(){
		return new ArrayList<>(bountyWantedConfigList);
	}
	
	public StaticBountyWanted getBountyWantedConfig(int id) {
		return bountyWantedConfig.get(id);
	}

	public List<StaticBountyWanted> getBountyWantedConfigList(int taskType) {
		return bountyWantedConfigMap.get(taskType);
	}
	
	public StaticBountySkill getBountySkillConfig(int id) {
		return bountySkillConfig.get(id);
	}
	
	public StaticBountyConfig getBountyConfig() {
		return bountyConfig;
	}

	@Override
	public void init() {
		try {
			shopInit();
		} catch (Exception e) {
			LogUtil.error("赏金活动商店解析配置出错", e);
		}

		try {
			bossInit();
		} catch (Exception e) {
			LogUtil.error("赏金活动boss信息解析配置出错", e);
		}

		try {
			stageInit();
		} catch (Exception e) {
			LogUtil.error("赏金活动关卡信息解析配置出错", e);
		}

		try {
			enemyInit();
		} catch (Exception e) {
			LogUtil.error("赏金活动怪物阵容解析配置出错", e);
		}
		
		try {
			skillInit();
		} catch (Exception e) {
			LogUtil.error("赏金活动boss技能解析配置出错", e);
		}

		try {
			wantedInit();
		} catch (Exception e) {
			LogUtil.error("赏金活动通缉令解析配置出错", e);
		}
		
		try {
			configInit();
		} catch (Exception e) {
			LogUtil.error("赏金活动零散解析配置出错", e);
		}
	}

	private void wantedInit() {
		Map<Integer, StaticBountyWanted> tempWantedConfig = new HashMap<>();
		Map<Integer, List<StaticBountyWanted>> tempBountyWantedConfigMap = new HashMap<>();
		List<StaticBountyWanted> tempBountyWantedConfigList = Collections.synchronizedList(new ArrayList<StaticBountyWanted>());


		List<StaticBountyWanted> wantedConfig = staticDataDao.selectStaticBountyWanted();

		if (wantedConfig != null && !wantedConfig.isEmpty()) {
			for (StaticBountyWanted c : wantedConfig) {
				tempBountyWantedConfigList.add(c);
				tempWantedConfig.put(c.getId(), c);
				
				if(!tempBountyWantedConfigMap.containsKey(c.getType())){
					tempBountyWantedConfigMap.put(c.getType(),new ArrayList<StaticBountyWanted>());
				}
				tempBountyWantedConfigMap.get(c.getType()).add(c);
			}
		}
		this.bountyWantedConfig.clear();
		this.bountyWantedConfig = tempWantedConfig;

		this.bountyWantedConfigMap.clear();
		this.bountyWantedConfigMap = tempBountyWantedConfigMap;
		
		this.bountyWantedConfigList.clear();
		this.bountyWantedConfigList = tempBountyWantedConfigList;
		
	}

	private void shopInit() {
		Map<Integer, StaticBountyShop> tempShopConfigMap = new HashMap<>();
		List<StaticBountyShop> tempShopConfigList = new ArrayList<>();

		List<StaticBountyShop> shopConfig = staticDataDao.selectStaticBountyShop();

		if (shopConfig != null && !shopConfig.isEmpty()) {
			for (StaticBountyShop c : shopConfig) {
				tempShopConfigMap.put(c.getGoodId(), c);
				tempShopConfigList.add(c);
			}
		}
		this.bountyShopConfigMap.clear();
		this.bountyShopConfigList.clear();
		this.bountyShopConfigMap = tempShopConfigMap;
		this.bountyShopConfigList = tempShopConfigList;
	}

	private void bossInit() {
		Map<Integer, StaticBountyBoss> tempBossConfig = new HashMap<>();
		List<StaticBountyBoss> bossConfig = staticDataDao.selectStaticBountyBoss();

		if (bossConfig != null && !bossConfig.isEmpty()) {
			for (StaticBountyBoss c : bossConfig) {
				tempBossConfig.put(c.getId(), c);
			}
		}
		this.bountyBossConfig.clear();
		this.bountyBossConfig = tempBossConfig;
	}

	private void stageInit() {
		Map<Integer, StaticBountyStage> tempStageConfig = new HashMap<>();
		List<StaticBountyStage> stageConfig = staticDataDao.selectStaticBountyStage();

		if (stageConfig != null && !stageConfig.isEmpty()) {
			for (StaticBountyStage c : stageConfig) {
				tempStageConfig.put(c.getId(), c);
			}
		}
		this.bountyStageConfig.clear();
		this.bountyStageConfig = tempStageConfig;
	}

	private void enemyInit() {
		Map<Integer, List<StaticBountyEnemy>> tempEnemyConfig = new HashMap<>();
		List<StaticBountyEnemy> enemyConfig = staticDataDao.selectStaticBountyEnemy();

		if (enemyConfig != null && !enemyConfig.isEmpty()) {
			for (StaticBountyEnemy c : enemyConfig) {

				if(!tempEnemyConfig.containsKey(c.getStageId())){
					tempEnemyConfig.put(c.getStageId(),new ArrayList<StaticBountyEnemy>());
				}
				tempEnemyConfig.get(c.getStageId()).add(c);
			}
		}
		this.bountyEnemyConfig.clear();
		this.bountyEnemyConfig = tempEnemyConfig;
	}
	
	private void skillInit() {
		Map<Integer, StaticBountySkill> tempSkillConfig = new HashMap<>();
		List<StaticBountySkill> skillConfig = staticDataDao.selectStaticBountySkill();

		if (skillConfig != null && !skillConfig.isEmpty()) {
			for (StaticBountySkill c : skillConfig) {
				tempSkillConfig.put(c.getId(), c);
			}
		}
		this.bountySkillConfig.clear();
		this.bountySkillConfig = tempSkillConfig;
	}
	
	private void configInit() {
		StaticBountyConfig config = staticDataDao.selectStaticBountyConfig();
		this.bountyConfig = config;
	}

}
