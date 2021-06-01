/**   
 * @Title: BuildingService.java    
 * @Package com.game.service    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年8月10日 下午2:23:42    
 * @version V1.0   
 */
package com.game.service;

import com.game.actor.role.PlayerEventService;
import com.game.constant.*;
import com.game.dataMgr.StaticBuildingDataMgr;
import com.game.dataMgr.StaticPropDataMgr;
import com.game.dataMgr.StaticVipDataMgr;
import com.game.domain.Player;
import com.game.domain.p.*;
import com.game.domain.s.*;
import com.game.manager.PartyDataManager;
import com.game.manager.PlayerDataManager;
import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb1.*;
import com.game.pb.GamePb3.BuyAutoBuildRs;
import com.game.pb.GamePb3.SetAutoBuildRq;
import com.game.pb.GamePb3.SetAutoBuildRs;
import com.game.util.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.*;

/**
 * 
 * @ClassName: Build
 * @Description: 建筑
 * @author
 */
class Build {
	public int id;
	public int lv;
	public int pos;

	/**
	 * @param id
	 * @param lv
	 * @param pos
	 */
	public Build(int id, int lv, int pos) {
		super();
		this.id = id;
		this.lv = lv;
		this.pos = pos;
	}
}

/**
 * 
 * @ClassName: ComparatorBuild
 * @Description: 建筑等级排序器
 * @author
 */
class ComparatorBuild implements Comparator<Build> {

	/**
	 * Overriding: compare
	 * 
	 * @param o1
	 * @param o2
	 * @return
	 * @see java.util.Comparator#compare(java.lang.Object, java.lang.Object)
	 */
	@Override
	public int compare(Build o1, Build o2) {
		// Auto-generated method stub
		if (o1.lv < o2.lv)
			return -1;
		else if (o1.lv > o2.lv) {
			return 1;
		} else {
			if (o1.id < o2.id) {
				return -1;
			} else if (o1.id > o2.id) {
				return 1;
			}

			return 0;
		}
	}
}

/**
 * 
 * @ClassName: BuildingService
 * @Description: 建筑业务相关
 * @author
 */
@Service
public class BuildingService {

	@Autowired
	private StaticBuildingDataMgr staticBuildingDataMgr;

	@Autowired
	private StaticPropDataMgr staticPropDataMgr;

	@Autowired
	private StaticVipDataMgr staticVipDataMgr;

	@Autowired
	private PlayerDataManager playerDataManager;

	@Autowired
	private PartyDataManager partyDataManager;

	@Autowired
	private PlayerEventService playerEventService;

	@Autowired
	private ActivityNewService activityNewService;

	/**
	 * 
	 * Method: getBuilding
	 * 
	 * @Description: 客户端获取建筑数据
	 * @param handler
	 * @return void
	 * 
	 */
	public void getBuilding(ClientHandler handler) {
		GetBuildingRs.Builder builder = GetBuildingRs.newBuilder();
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		Building building = player.building;
		// List<BuildQue> list = player.buildQue;
		Iterator<BuildQue> it1 = player.buildQue.iterator();
		while (it1.hasNext()) {
			builder.addQueue(PbHelper.createBuildQuePb(it1.next()));
		}

		Iterator<Mill> it2 = player.mills.values().iterator();
		while (it2.hasNext()) {
			builder.addMill(PbHelper.createMillPb(it2.next()));
		}

		builder.setWare1(building.getWare1());
		builder.setWare2(building.getWare2());
		builder.setTech(building.getTech());
		builder.setFactory1(building.getFactory1());
		builder.setFactory2(building.getFactory2());
		builder.setRefit(building.getRefit());
		builder.setCommand(building.getCommand());
		builder.setWorkShop(building.getWorkShop());
		builder.setLeqm(building.getLeqm());
		builder.setUpBuildTime(player.lord.getUpBuildTime());
		builder.setOnBuild(player.lord.getOnBuild());
		handler.sendMsgToPlayer(GetBuildingRs.ext, builder.build());
	}

	/**
	 * 
	 * Method: destoryMill
	 * 
	 * @Description: 拆除工厂
	 * @param pos
	 * @param handler
	 * @return void
	 * 
	 */
	public void destroyMill(int pos, ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		Mill mill = player.mills.get(pos);
		if (mill == null || mill.getLv() == 0) {
			handler.sendErrorMsgToPlayer(GameError.NO_BUILDING);
			return;
		}

		int buildingId = mill.getId();
		int pros = 0;
		StaticBuilding staticBuilding = staticBuildingDataMgr.getStaticBuilding(buildingId);
		if (staticBuilding != null) {

			if (mill.getLv() > 90) {
				pros += (mill.getLv() - 90) * staticBuilding.getPros2() + 90 * staticBuilding.getPros();
			} else {
				pros = staticBuilding.getPros() * mill.getLv();
			}

		} else {
			handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
			return;
		}

		int curPros = player.lord.getPros();
		if (curPros > pros) {
			curPros -= pros;
		} else {
			curPros = 0;
		}

		playerDataManager.subProsMax(player, pros);
		playerDataManager.subPros(player, pros);

		if (staticBuilding.getCanResource() == 1) {
			playerDataManager.subResourceOutAndMax(buildingId, mill.getLv(), player.resource);
		}

		player.mills.remove(pos);

		LogLordHelper.build(AwardFrom.BUILD_REMOVE, player.account, player.lord, buildingId, mill.getLv());

		DestroyMillRs.Builder builder = DestroyMillRs.newBuilder();
		builder.setProsMax(player.lord.getProsMax());
		handler.sendMsgToPlayer(DestroyMillRs.ext, builder.build());
	}

	/**
	 * 
	 * 设置建筑等级
	 * 
	 * @param buildingId
	 * @param building
	 * @param lv void
	 */
	private void setBuildingLv(int buildingId, Building building, int lv) {
		switch (buildingId) {
		case BuildingId.COMMAND:
			building.setCommand(lv);
			break;
		case BuildingId.WARE_1:
			building.setWare1(lv);
			break;
		case BuildingId.REFIT:
			building.setRefit(lv);
			break;
		case BuildingId.WORKSHOP:
			building.setWorkShop(lv);
			break;
		case BuildingId.TECH:
			building.setTech(lv);
			break;
		case BuildingId.FACTORY_1:
			building.setFactory1(lv);
			break;
		case BuildingId.FACTORY_2:
			building.setFactory2(lv);
			break;
		case BuildingId.WARE_2:
			building.setWare2(lv);
			break;
		}
	}

	/**
	 * 
	 * 建筑升级
	 * 
	 * @param buildingId
	 * @param building
	 * @return int
	 */
	private int upBuildingLv(int buildingId, Building building) {
		int lv = 0;
		switch (buildingId) {
		case BuildingId.COMMAND:
			lv = building.getCommand() + 1;
			building.setCommand(lv);
			break;
		case BuildingId.WARE_1:
			lv = building.getWare1() + 1;
			building.setWare1(lv);
			break;
		case BuildingId.REFIT:
			lv = building.getRefit() + 1;
			building.setRefit(lv);
			break;
		case BuildingId.WORKSHOP:
			lv = building.getWorkShop() + 1;
			building.setWorkShop(lv);
			break;
		case BuildingId.TECH:
			lv = building.getTech() + 1;
			building.setTech(lv);
			break;
		case BuildingId.FACTORY_1:
			lv = building.getFactory1() + 1;
			building.setFactory1(lv);
			break;
		case BuildingId.FACTORY_2:
			lv = building.getFactory2() + 1;
			building.setFactory2(lv);
			break;
		case BuildingId.WARE_2:
			lv = building.getWare2() + 1;
			building.setWare2(lv);
			break;
		case BuildingId.MATERIAL:
			lv = building.getLeqm() + 1;
			building.setLeqm(lv);
			break;
		}
		return lv;
	}

	/**
	 * 
	 * 升级城外建筑
	 * 
	 * @param player
	 * @param buildQue
	 * @return int
	 */
	private int upMillLv(Player player, BuildQue buildQue) {
		Mill mill = player.mills.get(buildQue.getPos());
		if (mill == null) {
			mill = new Mill(buildQue.getPos(), buildQue.getBuildingId(), 1);
			player.mills.put(buildQue.getPos(), mill);
		} else {
			mill.setLv(mill.getLv() + 1);
		}
		return mill.getLv();
	}

	/**
	 * 
	 * GM设置建筑等级
	 * 
	 * @param player
	 * @param pos
	 * @param lv void
	 */
	public void gmSetMillLv(Player player, int pos, int lv) {
		Mill mill = player.mills.get(pos);
		if (null != mill) {
			mill.setLv(lv);
		}
		StaticBuilding staticBuilding = staticBuildingDataMgr.getStaticBuilding(mill.getId());

		if (staticBuilding.getCanResource() == 1 || mill.getId() == BuildingId.WARE_1 || mill.getId() == BuildingId.WARE_2) {
			playerDataManager.addResourceOutAndMax(mill.getId(), mill.getLv(), player.resource);
		}
	}

	/**
	 * 
	 * 获得建筑位数量
	 * 
	 * @param player
	 * @return int
	 */
	private int getBuildQueCount(Player player) {
		int count = 2 + player.lord.getBuildCount();
		if (player.effects.containsKey(EffectType.CHANGE_SURFACE_3)) {
			count += 1;
		}

		return count;
	}

	/**
	 * 
	 * Method: speedQue
	 * 
	 * @Description: 加速建筑升级
	 * @param req
	 * @param handler
	 * @return void
	 * 
	 */
	public void speedQue(SpeedQueRq req, ClientHandler handler) {
		int keyId = req.getKeyId();
		int cost = req.getCost();
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		List<BuildQue> list = player.buildQue;
		BuildQue que = null;

		for (BuildQue buildQue : list) {
			if (buildQue.getKeyId() == keyId) {
				que = buildQue;
				break;
			}
		}

		if (que == null) {
			handler.sendErrorMsgToPlayer(GameError.NO_EXIST_QUE);
			return;
		}

		int now = TimeHelper.getCurrentSecond();

		SpeedQueRs.Builder builder = SpeedQueRs.newBuilder();
		if (cost == 1) {// 金币
			int leftTime = que.getEndTime() - now;
			if (leftTime <= 0) {
				leftTime = 1;
			}

			int sub = (int) Math.ceil(leftTime / 60.0);
			Lord lord = player.lord;
			if (lord.getGold() < sub) {
				handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
				return;
			}

			playerDataManager.subGold(player, sub, AwardFrom.BUILD_QUE);
			que.setEndTime(now);

			dealBuildQue(player, now);

			builder.setGold(lord.getGold());
			handler.sendMsgToPlayer(SpeedQueRs.ext, builder.build());
			return;
		} else {// 道具
			if (!req.hasPropId()) {
				handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
				return;
			}

			int propId = req.getPropId();
			int propCount = 1;

			if( req.hasPropCount()){
				 propCount = req.getPropCount();
			}


			Prop prop = player.props.get(propId);
			if (prop == null || prop.getCount() < propCount) {
				handler.sendErrorMsgToPlayer(GameError.PROP_NOT_ENOUGH);
				return;
			}

			StaticProp staticProp = staticPropDataMgr.getStaticProp(propId);
			if (staticProp.getEffectType() != 3) {
				handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
				return;
			}

			List<List<Integer>> value = staticProp.getEffectValue();
			if (value == null || value.isEmpty()) {
				handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
				return;
			}

			List<Integer> one = value.get(0);
			if (one.size() != 2) {
				handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
				return;
			}

			int type = one.get(0);
			int speedTime = one.get(1) * propCount;
			if (type != 1) {// 建筑加速
				handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
				return;
			}

			playerDataManager.subProp(player, prop, propCount, AwardFrom.BUILD_QUE);

			que.setEndTime(que.getEndTime() - speedTime);
			dealBuildQue(player, now);

			builder.setCount(prop.getCount());
			builder.setEndTime(que.getEndTime());
			handler.sendMsgToPlayer(SpeedQueRs.ext, builder.build());
			return;
		}
	}

	/**
	 * 
	 * Method: cancelQue
	 * 
	 * @Description: 玩家取消升级建筑
	 * @param req
	 * @param handler
	 * @return void
	 * 
	 */
	public void cancelQue(CancelQueRq req, ClientHandler handler) {
		int keyId = req.getKeyId();
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		List<BuildQue> list = player.buildQue;
		BuildQue que = null;

		for (BuildQue buildQue : list) {
			if (buildQue.getKeyId() == keyId) {
				que = buildQue;
				break;
			}
		}

		if (que == null) {
			handler.sendErrorMsgToPlayer(GameError.NO_EXIST_QUE);
			return;
		}

		Building building = player.building;
		int buildLevel = PlayerDataManager.getBuildingLv(que.getBuildingId(), building);

		list.remove(que);

		if (que.getPos() != 0) {
			Mill mill = player.mills.get(que.getPos());
			if (mill.getLv() == 0) {
				player.mills.remove(que.getPos());
			} else {
				buildLevel = mill.getLv();
			}
		}

		StaticBuildingLv staticBuildingLevel = staticBuildingDataMgr.getStaticBuildingLevel(que.getBuildingId(), buildLevel + 1);
		if (staticBuildingLevel == null) {
			handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
			return;
		}

		Resource resource = player.resource;
		CancelQueRs.Builder builder = CancelQueRs.newBuilder();

		playerDataManager.modifyIron(player, que.getIronCost() / 2, AwardFrom.CANCEL_BUILD_QUE);
		builder.setIron(resource.getIron());

		playerDataManager.modifyOil(player, que.getOilCost() / 2, AwardFrom.CANCEL_BUILD_QUE);
		builder.setOil(resource.getOil());

		playerDataManager.modifyCopper(player, que.getCopperCost() / 2, AwardFrom.CANCEL_BUILD_QUE);
		builder.setCopper(resource.getCopper());

		playerDataManager.modifySilicon(player, que.getSiliconCost() / 2, AwardFrom.CANCEL_BUILD_QUE);
		builder.setSilicon(resource.getSilicon());

		LogLordHelper.build(AwardFrom.CANCEL_BUILD_QUE, player.account, player.lord, que.getBuildingId(), buildLevel);

		handler.sendMsgToPlayer(CancelQueRs.ext, builder.build());
	}

	/**
	 * 
	 * 创建建筑升级任务
	 * 
	 * @param player
	 * @param buildingId
	 * @param pos
	 * @param period
	 * @param endTime
	 * @return BuildQue
	 */
	private BuildQue createQue(Player player, int buildingId, int pos, int period, int endTime) {
		return new BuildQue(player.maxKey(), buildingId, pos, period, endTime);
	}

	/**
	 * 
	 * 计算建筑升级时间
	 * 
	 * @param player
	 * @param baseTime
	 * @return int
	 */
	private int calcBuildTime(Player player, int baseTime, StaticActBuildsell config) {
		int factor = NumberHelper.HUNDRED_INT;
		// 建筑设计科技
		Science science = player.sciences.get(ScienceId.BUILD);
		int lv = 0;
		if (science != null) {
			lv += science.getScienceLv();
		}
		if (config != null) {
			lv += config.getLv();
		}
		factor += lv * 5;

		StaticVip staticVip = staticVipDataMgr.getStaticVip(player.lord.getVip());
		if (staticVip != null) {
			factor += staticVip.getSpeedBuild();
		}

		// effect影响升级时间
		Effect effect = player.effects.get(EffectType.ADD_BUILD_SPEED_PS);
		if (effect != null) {
			factor += 5;
		}

		effect = player.effects.get(EffectType.SUB_BUILD_SPEED_PS);
		if (effect != null) {
			factor += -10;
		}

		effect = player.effects.get(EffectType.ACTIVITY_BUILD_ADD_SPEED);
		if (effect != null) {
			factor += 100;
		}

		return (int) ((long) baseTime * NumberHelper.HUNDRED_INT / factor);
	}

	/**
	 * 
	 * Method: upBuilding
	 * 
	 * @Description: 升级建筑
	 * @param req
	 * @param handler
	 * @return void
	 * 
	 */
	public void upBuilding(UpBuildingRq req, ClientHandler handler) {
		int type = req.getType();
		int buildingId = req.getBuildingId();
		StaticBuilding staticBuilding = staticBuildingDataMgr.getStaticBuilding(buildingId);
		if (staticBuilding == null) {
			handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
			return;
		}

		if (staticBuilding.getCanUp() != 1) {
			handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
			return;
		}

		Player player = playerDataManager.getPlayer(handler.getRoleId());
		Lord lord = player.lord;
		List<BuildQue> buildQue = player.buildQue;
		if (buildQue.size() >= getBuildQueCount(player)) {
			handler.sendErrorMsgToPlayer(GameError.MAX_BUILD_QUE);
			return;
		}

		for (BuildQue build : buildQue) {
			if (build.getBuildingId() == buildingId) {
				handler.sendErrorMsgToPlayer(GameError.ALREADY_BUILD);
				return;
			}
		}

		Building building = player.building;
		int buildLevel = PlayerDataManager.getBuildingLv(buildingId, building);
		StaticBuildingLv staticBuildingLevel = staticBuildingDataMgr.getStaticBuildingLevel(buildingId, buildLevel + 1);
		if (staticBuildingLevel == null) {
			handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
			return;
		}

		if (lord.getLevel() < staticBuildingLevel.getLordLv()) {
			handler.sendErrorMsgToPlayer(GameError.LV_NOT_ENOUGH);
			return;
		}

		if (building.getCommand() < staticBuildingLevel.getCommandLv()) {
			handler.sendErrorMsgToPlayer(GameError.COMMAND_LV_NOT_ENOUGH);
			return;
		}

		StaticActBuildsell config = activityNewService.getStaticActBuildsell(buildingId);

		if (type == 1) {// 金币升级
			int cost = staticBuildingLevel.getGoldCost();

			if (config != null) {
				cost = (int) (cost * ((100 - config.getResource()) / 100.0f));
			}

			if (lord.getGold() < cost) {
				handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
				return;
			}

			playerDataManager.subGold(player, cost, AwardFrom.UP_BUILD);

			int now = TimeHelper.getCurrentSecond();
			int haust = calcBuildTime(player, staticBuildingLevel.getUpTime(), config);
			BuildQue que = createQue(player, buildingId, 0, haust, now + haust);
			que.setGoldCost(cost);
			buildQue.add(que);

			UpBuildingRs.Builder builder = UpBuildingRs.newBuilder();
			builder.setGold(lord.getGold());
			builder.setQueue(PbHelper.createBuildQuePb(que));

			handler.sendMsgToPlayer(UpBuildingRs.ext, builder.build());
		} else if (type == 2) {// 资源升级
			long ironCost = staticBuildingLevel.getIronCost();
			long oilCost = staticBuildingLevel.getOilCost();
			long copperCost = staticBuildingLevel.getCopperCost();
			long siliconCost = staticBuildingLevel.getSiliconCost();

			// float factor = 1;
			int factor = NumberHelper.HUNDRED_INT;
			// 效果影响资源消耗
			Effect effect = player.effects.get(EffectType.ACTIVITY_BUILD_SUB_COST);
			if (effect != null) {
				factor += -50;
			}

			oilCost = oilCost * factor / NumberHelper.HUNDRED_INT;
			copperCost = copperCost * factor / NumberHelper.HUNDRED_INT;
			ironCost = ironCost * factor / NumberHelper.HUNDRED_INT;
			siliconCost = siliconCost * factor / NumberHelper.HUNDRED_INT;

			if (config != null) {
				oilCost = (long) (oilCost * ((100 - config.getResource()) / 100.0f));
				copperCost = (long) (copperCost * ((100 - config.getResource()) / 100.0f));
				ironCost = (long) (ironCost * ((100 - config.getResource()) / 100.0f));
				siliconCost = (long) (siliconCost * ((100 - config.getResource()) / 100.0f));
			}

			Resource resource = player.resource;
			if (resource.getIron() < ironCost || resource.getOil() < oilCost || resource.getCopper() < copperCost
					|| resource.getSilicon() < siliconCost) {
				handler.sendErrorMsgToPlayer(GameError.RESOURCE_NOT_ENOUGH);
				return;
			}

			if (ironCost > 0) {
				playerDataManager.modifyIron(player, (long) (-ironCost * factor / NumberHelper.HUNDRED_INT), AwardFrom.UP_BUILD);
			}
			if (oilCost > 0) {
				playerDataManager.modifyOil(player, (long) (-oilCost * factor / NumberHelper.HUNDRED_INT), AwardFrom.UP_BUILD);
			}
			if (copperCost > 0) {
				playerDataManager.modifyCopper(player, (long) (-copperCost * factor / NumberHelper.HUNDRED_INT), AwardFrom.UP_BUILD);
			}
			if (siliconCost > 0) {
				playerDataManager.modifySilicon(player, (long) (-siliconCost * factor / NumberHelper.HUNDRED_INT), AwardFrom.UP_BUILD);
			}

			int now = TimeHelper.getCurrentSecond();
			int haust = calcBuildTime(player, staticBuildingLevel.getUpTime(), config);
			BuildQue build = createQue(player, buildingId, 0, haust, now + haust);
			build.saveCost(ironCost, oilCost, copperCost, siliconCost);
			buildQue.add(build);

			UpBuildingRs.Builder builder = UpBuildingRs.newBuilder();
			builder.setQueue(PbHelper.createBuildQuePb(build));

			if (ironCost > 0) {
				builder.setIron(resource.getIron());
			}

			if (oilCost > 0) {
				builder.setOil(resource.getOil());
			}

			if (copperCost > 0) {
				builder.setCopper(resource.getCopper());
			}

			if (siliconCost > 0) {
				builder.setSilicon(resource.getSilicon());
			}

			handler.sendMsgToPlayer(UpBuildingRs.ext, builder.build());
		}

		LogLordHelper.build(AwardFrom.UP_BUILD, player.account, lord, buildingId, buildLevel);
	}

	/**
	 * 
	 * 油铁铜数量
	 * 
	 * @param player
	 * @return int
	 */
	private int normalMillCount(Player player) {
		int count = 0;
		Iterator<Mill> it = player.mills.values().iterator();
		int buildingId;
		while (it.hasNext()) {
			buildingId = it.next().getId();
			if (buildingId == BuildingId.OIL || buildingId == BuildingId.COPPER || buildingId == BuildingId.IRON)
				count++;
		}
		return count;
	}

	/**
	 * 
	 * 钛矿厂数量
	 * 
	 * @param player
	 * @return int
	 */
	private int siliconMillCount(Player player) {
		int count = 0;
		Iterator<Mill> it = player.mills.values().iterator();
		int buildingId;
		while (it.hasNext()) {
			buildingId = it.next().getId();
			if (buildingId == BuildingId.SILICON)
				count++;
		}
		return count;
	}

	/**
	 * 
	 * 某种工厂数量是否已到最大值
	 * 
	 * @param player
	 * @param millId
	 * @return boolean
	 */
	private boolean checkMillCount(Player player, int millId) {
		int commandLv = player.building.getCommand();
		int max = 0;
		switch (millId) {
		case BuildingId.OIL:
		case BuildingId.COPPER:
		case BuildingId.IRON:
			max = commandLv / 2 + 5;
			max = (max > 35) ? 35 : max;
			if (normalMillCount(player) < max)
				return true;
			break;
		case BuildingId.SILICON:
			max = commandLv / 10;
			max = (max > 6) ? 6 : max;
			if (siliconMillCount(player) < max)
				return true;
			break;
		case BuildingId.STONE:
			if (player.mills.get(42) == null)
				return true;
			break;
		default:
			break;
		}
		return false;
	}

	/**
	 * 
	 * Method: upMill
	 * 
	 * @Description: 升级城外建筑
	 * @param req
	 * @param handler
	 * @return void
	 * 
	 */
	public void upMill(UpBuildingRq req, ClientHandler handler) {
		int type = req.getType();
		int pos = req.getPos();
		int buildingId = req.getBuildingId();

		if (pos < 1 || pos > 42) {
			handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
			return;
		}

		StaticBuilding staticBuilding = staticBuildingDataMgr.getStaticBuilding(buildingId);
		if (staticBuilding == null) {
			handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
			return;
		}

		if (staticBuilding.getCanUp() != 1) {
			handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
			return;
		}

		Player player = playerDataManager.getPlayer(handler.getRoleId());
		Lord lord = player.lord;

		if (pos == 42 && buildingId != BuildingId.STONE) {// 30只能放宝石矿
			handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
			return;
		}

		if (pos != 42 && buildingId == BuildingId.STONE) {// 宝石矿只能放在30
			handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
			return;
		}

		if ((pos < 36 || pos > 41) && buildingId == BuildingId.SILICON) {
			handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
			return;
		}

		if ((pos > 35 && pos < 42) && buildingId != BuildingId.SILICON) {
			handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
			return;
		}

		List<BuildQue> buildQue = player.buildQue;
		if (buildQue.size() >= getBuildQueCount(player)) {
			handler.sendErrorMsgToPlayer(GameError.MAX_BUILD_QUE);
			return;
		}

		for (BuildQue build : buildQue) {
			if (build.getPos() == pos) {
				handler.sendErrorMsgToPlayer(GameError.ALREADY_BUILD);
				return;
			}
		}

		Mill mill = player.mills.get(pos);
		if (mill == null) {
			if (!checkMillCount(player, buildingId)) {
				handler.sendErrorMsgToPlayer(GameError.MAX_MILL);
				return;
			}

			mill = new Mill(pos, buildingId, 0);
		}

		int buildLevel = mill.getLv();
		StaticBuildingLv staticBuildingLevel = staticBuildingDataMgr.getStaticBuildingLevel(buildingId, buildLevel + 1);
		if (staticBuildingLevel == null) {
			handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
			return;
		}

		if (lord.getLevel() < staticBuildingLevel.getLordLv()) {
			handler.sendErrorMsgToPlayer(GameError.LV_NOT_ENOUGH);
			return;
		}

		if (player.building.getCommand() < staticBuildingLevel.getCommandLv()) {
			handler.sendErrorMsgToPlayer(GameError.COMMAND_LV_NOT_ENOUGH);
			return;
		}

		StaticActBuildsell config = activityNewService.getStaticActBuildsell(buildingId);
		if (type == 1) {// 金币升级
			int cost = staticBuildingLevel.getGoldCost();

			if (config != null) {
				cost = (int) (cost * ((100 - config.getResource()) / 100.0f));
			}

			if (lord.getGold() < cost) {
				handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
				return;
			}

			playerDataManager.subGold(player, cost, AwardFrom.UP_BUILD);

			int now = TimeHelper.getCurrentSecond();
			int haust = calcBuildTime(player, staticBuildingLevel.getUpTime(), config);
			BuildQue que = createQue(player, buildingId, pos, haust, now + haust);
			que.setGoldCost(cost);
			buildQue.add(que);

			player.mills.put(pos, mill);
			UpBuildingRs.Builder builder = UpBuildingRs.newBuilder();
			builder.setGold(lord.getGold());
			builder.setQueue(PbHelper.createBuildQuePb(que));

			handler.sendMsgToPlayer(UpBuildingRs.ext, builder.build());
		} else if (type == 2) {// 资源升级
			long ironCost = staticBuildingLevel.getIronCost();
			long oilCost = staticBuildingLevel.getOilCost();
			long copperCost = staticBuildingLevel.getCopperCost();
			long siliconCost = staticBuildingLevel.getSiliconCost();

			// float factor = 1;
			int factor = NumberHelper.HUNDRED_INT;
			// 效果影响资源消耗
			Effect effect = player.effects.get(EffectType.ACTIVITY_BUILD_SUB_COST);
			if (effect != null) {
				factor += -50;
			}

			oilCost = oilCost * factor / NumberHelper.HUNDRED_INT;
			copperCost = copperCost * factor / NumberHelper.HUNDRED_INT;
			ironCost = ironCost * factor / NumberHelper.HUNDRED_INT;
			siliconCost = siliconCost * factor / NumberHelper.HUNDRED_INT;

			if (config != null) {
				oilCost = (int) (oilCost * ((100 - config.getResource()) / 100.0f));
				copperCost = (int) (copperCost * ((100 - config.getResource()) / 100.0f));
				ironCost = (int) (ironCost * ((100 - config.getResource()) / 100.0f));
				siliconCost = (int) (siliconCost * ((100 - config.getResource()) / 100.0f));
			}

			Resource resource = player.resource;
			if (resource.getIron() < ironCost || resource.getOil() < oilCost || resource.getCopper() < copperCost
					|| resource.getSilicon() < siliconCost) {
				handler.sendErrorMsgToPlayer(GameError.RESOURCE_NOT_ENOUGH);
				return;
			}

			playerDataManager.modifyIron(player, (long) (-ironCost * factor / NumberHelper.HUNDRED_INT), AwardFrom.UP_MILL);
			playerDataManager.modifyOil(player, (long) (-oilCost * factor / NumberHelper.HUNDRED_INT), AwardFrom.UP_MILL);
			playerDataManager.modifyCopper(player, (long) (-copperCost * factor / NumberHelper.HUNDRED_INT), AwardFrom.UP_MILL);
			playerDataManager.modifySilicon(player, (long) (-siliconCost * factor / NumberHelper.HUNDRED_INT), AwardFrom.UP_MILL);

			int now = TimeHelper.getCurrentSecond();
			int haust = calcBuildTime(player, staticBuildingLevel.getUpTime(), config);
			BuildQue build = createQue(player, buildingId, pos, haust, now + haust);
			build.saveCost(ironCost, oilCost, copperCost, siliconCost);
			buildQue.add(build);
			player.mills.put(pos, mill);

			UpBuildingRs.Builder builder = UpBuildingRs.newBuilder();
			builder.setQueue(PbHelper.createBuildQuePb(build));

			if (ironCost > 0) {
				builder.setIron(resource.getIron());
			}

			if (oilCost > 0) {
				builder.setOil(resource.getOil());
			}

			if (copperCost > 0) {
				builder.setCopper(resource.getCopper());
			}

			if (siliconCost > 0) {
				builder.setSilicon(resource.getSilicon());
			}

			handler.sendMsgToPlayer(UpBuildingRs.ext, builder.build());
		}
		LogLordHelper.build(AwardFrom.UP_BUILD, player.account, lord, buildingId, buildLevel);
	}

	/**
	 * 
	 * Method: setBuildingLv
	 * 
	 * @Description: gm设置建筑等级
	 * @param buildingId
	 * @param lv
	 * @param player
	 * @param handler
	 * @return void
	 * 
	 */
	public void setBuildingLv(int buildingId, int lv, Player player, ClientHandler handler) {
		StaticBuilding staticBuilding = staticBuildingDataMgr.getStaticBuilding(buildingId);
		if (staticBuilding == null) {
			handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
			return;
		}

		if (staticBuilding.getCanUp() != 1) {
			handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
			return;
		}

		setBuildingLv(buildingId, player.building, lv);

	}

	/**
	 * 
	 * 返回建筑列表按等级排序
	 * 
	 * @param player
	 * @return List<Build>
	 */
	private List<Build> selectLowLv(Player player) {
		Building building = player.building;
		List<Build> list = new ArrayList<>();

		if (building.getCommand() > 0) {
			list.add(new Build(BuildingId.COMMAND, building.getCommand(), 0));
		}

		if (building.getWare1() > 0) {
			list.add(new Build(BuildingId.WARE_1, building.getWare1(), 0));
		}

		if (building.getRefit() > 0) {
			list.add(new Build(BuildingId.REFIT, building.getRefit(), 0));
		}

		if (building.getTech() > 0) {
			list.add(new Build(BuildingId.TECH, building.getTech(), 0));
		}

		if (building.getFactory1() > 0) {
			list.add(new Build(BuildingId.FACTORY_1, building.getFactory1(), 0));
		}

		if (building.getFactory2() > 0) {
			list.add(new Build(BuildingId.FACTORY_2, building.getFactory2(), 0));
		}

		if (building.getWare2() > 0) {
			list.add(new Build(BuildingId.WARE_2, building.getWare2(), 0));
		}

		Iterator<Mill> it = player.mills.values().iterator();
		while (it.hasNext()) {
			Mill mill = it.next();
			if (mill.getLv() > 0) {
				list.add(new Build(mill.getId(), mill.getLv(), mill.getPos()));
			}
		}

		Collections.sort(list, new ComparatorBuild());
		return list;
	}

	/**
	 * 
	 * 自动升级资源工厂 资源不够时返回false
	 * 
	 * @param player
	 * @param build
	 * @return boolean
	 */
	private boolean doAutoMill(Player player, Build build) {
		for (BuildQue que : player.buildQue) {
			if (build.id == que.getBuildingId() && build.pos == que.getPos()) {
				return false;
			}
		}

		StaticBuildingLv staticBuildingLevel = staticBuildingDataMgr.getStaticBuildingLevel(build.id, build.lv + 1);
		if (staticBuildingLevel == null) {
			return false;
		}

		if (player.lord.getLevel() < staticBuildingLevel.getLordLv()) {
			return false;
		}

		if (player.building.getCommand() < staticBuildingLevel.getCommandLv()) {
			return false;
		}

		StaticActBuildsell config = activityNewService.getStaticActBuildsell(build.id);

		long ironCost = staticBuildingLevel.getIronCost();
		long oilCost = staticBuildingLevel.getOilCost();
		long copperCost = staticBuildingLevel.getCopperCost();
		long siliconCost = staticBuildingLevel.getSiliconCost();

		// float factor = 1;
		int factor = NumberHelper.HUNDRED_INT;
		// 效果影响资源消耗
		Effect effect = player.effects.get(EffectType.ACTIVITY_BUILD_SUB_COST);
		if (effect != null) {
			factor += -50;
		}

		oilCost = oilCost * factor / NumberHelper.HUNDRED_INT;
		copperCost = copperCost * factor / NumberHelper.HUNDRED_INT;
		ironCost = ironCost * factor / NumberHelper.HUNDRED_INT;
		siliconCost = siliconCost * factor / NumberHelper.HUNDRED_INT;

		if (config != null) {
			oilCost = (int) (oilCost * ((100 - config.getResource()) / 100.0f));
			copperCost = (int) (copperCost * ((100 - config.getResource()) / 100.0f));
			ironCost = (int) (ironCost * ((100 - config.getResource()) / 100.0f));
			siliconCost = (int) (siliconCost * ((100 - config.getResource()) / 100.0f));
		}

		Resource resource = player.resource;
		if (resource.getIron() < ironCost || resource.getOil() < oilCost || resource.getCopper() < copperCost
				|| resource.getSilicon() < siliconCost) {
			return false;
		}

		playerDataManager.modifyIron(player, -ironCost, AwardFrom.DO_AUTO_MILL);
		playerDataManager.modifyOil(player, -oilCost, AwardFrom.DO_AUTO_MILL);
		playerDataManager.modifyCopper(player, -copperCost, AwardFrom.DO_AUTO_MILL);
		playerDataManager.modifySilicon(player, -siliconCost, AwardFrom.DO_AUTO_MILL);

		int now = TimeHelper.getCurrentSecond();
		int haust = calcBuildTime(player, staticBuildingLevel.getUpTime(), config);
		BuildQue que = createQue(player, build.id, build.pos, haust, now + haust);
		que.saveCost(ironCost, oilCost, copperCost, siliconCost);
		player.buildQue.add(que);

		playerDataManager.synBuildToPlayer(player, que, 1);
		playerDataManager.synResourceToPlayer(player, -ironCost, -oilCost, -copperCost, -siliconCost, 0);
		LogLordHelper.build(AwardFrom.DO_AUTO_MILL, player.account, player.lord, build.id, build.lv);
		return true;
	}

	/**
	 * 
	 * 自动升级工厂以外的建筑
	 * 
	 * @param player
	 * @param build
	 * @return boolean
	 */
	private boolean doAutoBuild(Player player, Build build) {
		for (BuildQue que : player.buildQue) {
			if (build.id == que.getBuildingId()) {
				return false;
			}
		}

		StaticBuildingLv staticBuildingLevel = staticBuildingDataMgr.getStaticBuildingLevel(build.id, build.lv + 1);
		if (staticBuildingLevel == null) {
			return false;
		}

		if (player.lord.getLevel() < staticBuildingLevel.getLordLv()) {
			return false;
		}

		if (player.building.getCommand() < staticBuildingLevel.getCommandLv()) {
			return false;
		}

		StaticActBuildsell config = activityNewService.getStaticActBuildsell(build.id);

		long ironCost = staticBuildingLevel.getIronCost();
		long oilCost = staticBuildingLevel.getOilCost();
		long copperCost = staticBuildingLevel.getCopperCost();
		long siliconCost = staticBuildingLevel.getSiliconCost();

		// float factor = 1;
		int factor = NumberHelper.HUNDRED_INT;
		// 效果影响资源消耗
		Effect effect = player.effects.get(EffectType.ACTIVITY_BUILD_SUB_COST);
		if (effect != null) {
			factor += -50;
		}

		oilCost = oilCost * factor / NumberHelper.HUNDRED_INT;
		copperCost = copperCost * factor / NumberHelper.HUNDRED_INT;
		ironCost = ironCost * factor / NumberHelper.HUNDRED_INT;
		siliconCost = siliconCost * factor / NumberHelper.HUNDRED_INT;

		if (config != null) {
			oilCost = (int) (oilCost * ((100 - config.getResource()) / 100.0f));
			copperCost = (int) (copperCost * ((100 - config.getResource()) / 100.0f));
			ironCost = (int) (ironCost * ((100 - config.getResource()) / 100.0f));
			siliconCost = (int) (siliconCost * ((100 - config.getResource()) / 100.0f));
		}

		Resource resource = player.resource;
		if (resource.getIron() < ironCost || resource.getOil() < oilCost || resource.getCopper() < copperCost
				|| resource.getSilicon() < siliconCost) {
			return false;
		}

		playerDataManager.modifyIron(player, -ironCost, AwardFrom.DO_AUTO_MILL);
		playerDataManager.modifyOil(player, -oilCost, AwardFrom.DO_AUTO_MILL);
		playerDataManager.modifyCopper(player, -copperCost, AwardFrom.DO_AUTO_MILL);
		playerDataManager.modifySilicon(player, -siliconCost, AwardFrom.DO_AUTO_MILL);

		int now = TimeHelper.getCurrentSecond();
		int haust = calcBuildTime(player, staticBuildingLevel.getUpTime(), config);
		BuildQue que = createQue(player, build.id, 0, haust, now + haust);
		que.saveCost(ironCost, oilCost, copperCost, siliconCost);
		player.buildQue.add(que);

		playerDataManager.synBuildToPlayer(player, que, 1);
		playerDataManager.synResourceToPlayer(player, -ironCost, -oilCost, -copperCost, -siliconCost, 0);
		LogLordHelper.build(AwardFrom.DO_AUTO_MILL, player.account, player.lord, build.id, build.lv);
		return true;
	}

	/**
	 * 
	 * 开启了自动升级建筑 自动选择建筑升级
	 * 
	 * @param player void
	 */
	private void autoBuild(Player player) {
		int count = getBuildQueCount(player) - player.buildQue.size();
		List<Build> list = selectLowLv(player);
		int b = 0;

		for (Build build : list) {
			if (b >= count) {
				break;
			}

			if (build.pos > 0) {
				if (doAutoMill(player, build)) {
					b++;
				}
			} else {
				if (doAutoBuild(player, build)) {
					b++;
				}
			}
		}
	}

	/**
	 * 
	 * 这个是每秒调用一次 执行自动升级并减少剩余自动升级时间
	 * 
	 * @param player void
	 */
	private void dealAutoBuild(Player player) {
		autoBuild(player);
		int leftTime = player.lord.getUpBuildTime();
		player.lord.setUpBuildTime(leftTime - 1);
		if (leftTime <= 0) {
			player.lord.setUpBuildTime(0);
			player.lord.setOnBuild(0);
		}
	}

	/**
	 * 
	 * 建筑升级完成
	 * 
	 * @param player
	 * @param buildQue
	 * @return int
	 */
	private int dealOneQue(Player player, BuildQue buildQue) {
		int pros = 0;
		int buildingId = buildQue.getBuildingId();
		int buildingLv;

		if (buildQue.getPos() != 0) {
			buildingLv = upMillLv(player, buildQue);
			playerDataManager.updTask(player, TaskType.COND_BUILDING_LV_UP, 1);
			playerDataManager.updDay7ActSchedule(player, 7, buildingLv);
		} else {
			buildingLv = upBuildingLv(buildingId, player.building);
			playerDataManager.updTask(player, TaskType.COND_BUILDING_LV_UP, 1);
			switch (buildingId) {
			case BuildingId.COMMAND:
				playerDataManager.updDay7ActSchedule(player, 1, buildingLv);
				break;
			case BuildingId.FACTORY_1:
			case BuildingId.FACTORY_2:
				playerDataManager.updDay7ActSchedule(player, 3, buildingLv);
				playerEventService.calcStrongestFormAndFight(player);
				break;
			case BuildingId.TECH:
				playerDataManager.updDay7ActSchedule(player, 5, buildingLv);
				playerEventService.calcStrongestFormAndFight(player);
				break;
			}
		}

		StaticBuilding staticBuilding = staticBuildingDataMgr.getStaticBuilding(buildingId);

		if (buildingLv > 90) {
			pros += staticBuilding.getPros2();
		} else {
			pros += staticBuilding.getPros();
		}

		if (staticBuilding.getCanResource() == 1 || buildingId == BuildingId.WARE_1 || buildingId == BuildingId.WARE_2) {
			playerDataManager.addResourceOutAndMax(buildingId, buildingLv, player.resource);
		}

		playerDataManager.synBuildToPlayer(player, buildQue, 2);
		LogLordHelper.build(AwardFrom.BUILD_UP_FINISH, player.account, player.lord, buildingId, buildingLv);
		return pros;
	}

	/**
	 * 
	 * 定时器 建筑升级进度处理
	 * 
	 * @param player
	 * @param now void
	 */
	private void dealBuildQue(Player player, int now) {
		List<BuildQue> list = player.buildQue;
		Iterator<BuildQue> it = list.iterator();
		boolean update = false;
		int pros = 0;
		while (it.hasNext()) {
			BuildQue buildQue = it.next();
			if (now >= buildQue.getEndTime()) {
				pros += dealOneQue(player, buildQue);
				update = true;
				it.remove();
			}
		}

		if (update) {
			playerDataManager.addProsMax(player, pros);
		}
	}

	/**
	 * 
	 * 购买自动升级时间
	 * 
	 * @param handler void
	 */
	public void buyAutoBuild(ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		int cost = 238;
		if (player.lord.getGold() < cost) {
			handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
			return;
		}

		playerDataManager.subGold(player, cost, AwardFrom.BUY_AUTO_BUILD);

		player.lord.setUpBuildTime(player.lord.getUpBuildTime() + 4 * TimeHelper.HOUR_S);
		BuyAutoBuildRs.Builder builder = BuyAutoBuildRs.newBuilder();
		builder.setGold(player.lord.getGold());
		builder.setUpBuildTime(player.lord.getUpBuildTime());

		handler.sendMsgToPlayer(BuyAutoBuildRs.ext, builder.build());
	}

	/**
	 * 
	 * 开启建筑自动升级
	 * 
	 * @param req
	 * @param handler void
	 */
	public void setAutoBuild(SetAutoBuildRq req, ClientHandler handler) {
		boolean state = req.getState();
		Player player = playerDataManager.getPlayer(handler.getRoleId());

		if (state) {
			if (player.lord.getUpBuildTime() > 0) {
				player.lord.setOnBuild(1);
			}
		} else {
			player.lord.setOnBuild(0);
		}

		SetAutoBuildRs.Builder builder = SetAutoBuildRs.newBuilder();
		builder.setOnBuild(player.lord.getOnBuild());
		builder.setUpBuildTime(player.lord.getUpBuildTime());

		handler.sendMsgToPlayer(SetAutoBuildRs.ext, builder.build());
	}

	/**
	 * 
	 * Method: buildQueTimerLogic
	 * 
	 * @Description: 建筑队列定时器逻辑
	 * @return void
	 * 
	 */
	public void buildQueTimerLogic() {
		Iterator<Player> iterator = playerDataManager.getRecThreeMonOnlPlayer().values().iterator();
		int now = TimeHelper.getCurrentSecond();
		while (iterator.hasNext()) {
			Player player = iterator.next();
			if (player.isActive()) {
				try {

					/*if(player.is3MothLogin()){
						continue;
					}*/


					if (!player.buildQue.isEmpty()) {
						dealBuildQue(player, now);
					}

					if (player.lord.getOnBuild() == 1) {
						dealAutoBuild(player);
					}
				} catch (Exception e) {
					LogUtil.error("建筑队列定时器报错, lordId:" + player.lord.getLordId(), e);
				}
			}
		}
	}

	/**
	 * 
	 * 每分钟生产资源
	 * 
	 * @param player
	 * @param now void
	 */
	private void dealResourceMinute(Player player, int now) {

		Resource resource = player.resource;
		int reduce = NumberHelper.ZERO;
		if (playerDataManager.isRuins(player)) {
			reduce = NumberHelper.HUNDRED_INT;
		}

		int stoneOut = (int) (resource.getStoneOut() * (NumberHelper.HUNDRED_INT + resource.getStoneOutF() - reduce)
				/ (6 * NumberHelper.THOUSAND));
		int ironOut = (int) (resource.getIronOut() * (NumberHelper.HUNDRED_INT + resource.getIronOutF() - reduce)
				/ (6 * NumberHelper.THOUSAND));
		int oilOut = (int) (resource.getOilOut() * (NumberHelper.HUNDRED_INT + resource.getOilOutF() - reduce)
				/ (6 * NumberHelper.THOUSAND));
		int copperOut = (int) (resource.getCopperOut() * (NumberHelper.HUNDRED_INT + resource.getCopperOutF() - reduce)
				/ (6 * NumberHelper.THOUSAND));
		int siliconOut = (int) (resource.getSiliconOut() * (NumberHelper.HUNDRED_INT + resource.getSiliconOutF() - reduce)
				/ (6 * NumberHelper.THOUSAND));

		long add = NumberHelper.ZERO;
		int storeF = NumberHelper.HUNDRED_INT + resource.getStoreF();
		Map<Integer, PartyScience> sciences = partyDataManager.getScience(player);
		if (sciences != null) {
			PartyScience science = sciences.get(ScienceId.PARTY_STORAGE);
			if (science != null) {
				storeF += science.getScienceLv();
			}
		}

		long max = resource.getStoneMax() * storeF / NumberHelper.HUNDRED_INT;
		if (resource.getStone() < max) {
			add = (resource.getStone() + stoneOut > max) ? (max - resource.getStone()) : stoneOut;
			if (add > 0) {
				playerDataManager.modifyStone(resource, (int) add);
			}
		}

		max = resource.getIronMax() * storeF / NumberHelper.HUNDRED_INT;
		if (resource.getIron() < max) {
			add = (resource.getIron() + ironOut > max) ? (max - resource.getIron()) : ironOut;
			if (add > 0) {
				playerDataManager.modifyIron(resource, (int) add);
			}
		}

		max = resource.getOilMax() * storeF / NumberHelper.HUNDRED_INT;
		if (resource.getOil() < max) {
			add = (resource.getOil() + oilOut > max) ? (max - resource.getOil()) : oilOut;
			if (add > 0) {
				playerDataManager.modifyOil(resource, (int) add);
			}
		}

		max = resource.getCopperMax() * storeF / NumberHelper.HUNDRED_INT;
		if (resource.getCopper() < max) {
			add = (resource.getCopper() + copperOut > max) ? (max - resource.getCopper()) : copperOut;
			if (add > 0) {
				playerDataManager.modifyCopper(resource, (int) add);
			}
		}

		max = resource.getSiliconMax() * storeF / NumberHelper.HUNDRED_INT;
		if (resource.getSilicon() < max) {
			add = (resource.getSilicon() + siliconOut > max) ? (max - resource.getSilicon()) : siliconOut;
			if (add > 0) {
				playerDataManager.modifySilicon(resource, (int) add);
			}
		}

		resource.setStoreTime(now);
	}

	/**
	 * 
	 * 资源
	 * 
	 * @param player
	 * @param now void
	 */
	private void dealResource(Player player, int now) {
		if (!playerDataManager.isOnline(player)) { // 如果不在线 并且离线时间超过指定时间 不自增资源
			if (TimeHelper.getCurrentSecond() - player.lord.getOffTime() > BuildConst.RESOURCE_STOP_ADD_OFFTIME) {
				return;
			}
		}
		if (player.resource.getStoreTime() < now) {
			dealResourceMinute(player, now);
		}
	}

	/**
	 * 
	 * Method: resourceTimerLogic
	 * 
	 * @Description: 资源生产逻辑
	 * @return void
	 */
	public void resourceTimerLogic() {
		Iterator<Player> iterator = playerDataManager.getRecThreeMonOnlPlayer().values().iterator();
		int now = TimeHelper.getCurrentMinute();
		while (iterator.hasNext()) {
			Player player = iterator.next();
			try {

				/*if(player.is3MothLogin()){
					continue;
				}*/

				// if (player.account.getCreated() == 1) {
				dealResource(player, now);
				// }
			} catch (Exception e) {
				LogUtil.error("资源生产逻辑定时器报错, lordId:" + player.lord.getLordId(), e);
			}
		}
	}

	/**
	 * 
	 * 重新计算玩家资源产量
	 * 
	 * @param player void
	 */
	public void recalcResourceOut(Player player) {
		Resource resource = player.resource;
		if(resource == null ){
			return;
		}
		resource.setCopperOut(0);
		resource.setIronOut(0);
		resource.setOilOut(0);
		resource.setStoneOut(0);
		resource.setSiliconOut(0);

		resource.setStoneMax(0);
		resource.setIronMax(0);
		resource.setOilMax(0);
		resource.setCopperMax(0);
		resource.setSiliconMax(0);

		int lv = 0;
		for (int id = BuildingId.COMMAND; id < BuildingId.WARE_2 + 1; id++) {
			lv = PlayerDataManager.getBuildingLv(id, player.building);
			if (lv == 0) {
				continue;
			}

			StaticBuildingLv staticBuildingLevel = staticBuildingDataMgr.getStaticBuildingLevel(id, lv);
			if (staticBuildingLevel != null) {
				resource.setStoneMax(staticBuildingLevel.getStoneMax() + resource.getStoneMax());
				resource.setIronMax(staticBuildingLevel.getIronMax() + resource.getIronMax());
				resource.setOilMax(staticBuildingLevel.getOilMax() + resource.getOilMax());
				resource.setCopperMax(staticBuildingLevel.getCopperMax() + resource.getCopperMax());
				resource.setSiliconMax(staticBuildingLevel.getSiliconMax() + resource.getSiliconMax());

				resource.setStoneOut(staticBuildingLevel.getStoneOut() + resource.getStoneOut());
				resource.setIronOut(staticBuildingLevel.getIronOut() + resource.getIronOut());
				resource.setOilOut(staticBuildingLevel.getOilOut() + resource.getOilOut());
				resource.setCopperOut(staticBuildingLevel.getCopperOut() + resource.getCopperOut());
				resource.setSiliconOut(staticBuildingLevel.getSiliconOut() + resource.getSiliconOut());
			}
		}

		Iterator<Mill> it = player.mills.values().iterator();
		while (it.hasNext()) {
			Mill mill = it.next();
			lv = mill.getLv();
			if (lv == 0) {
				continue;
			}

			StaticBuildingLv staticBuildingLevel = staticBuildingDataMgr.getStaticBuildingLevel(mill.getId(), lv);
			if (staticBuildingLevel != null) {
				resource.setStoneMax(staticBuildingLevel.getStoneMax() + resource.getStoneMax());
				resource.setIronMax(staticBuildingLevel.getIronMax() + resource.getIronMax());
				resource.setOilMax(staticBuildingLevel.getOilMax() + resource.getOilMax());
				resource.setCopperMax(staticBuildingLevel.getCopperMax() + resource.getCopperMax());
				resource.setSiliconMax(staticBuildingLevel.getSiliconMax() + resource.getSiliconMax());

				resource.setStoneOut(staticBuildingLevel.getStoneOut() + resource.getStoneOut());
				resource.setIronOut(staticBuildingLevel.getIronOut() + resource.getIronOut());
				resource.setOilOut(staticBuildingLevel.getOilOut() + resource.getOilOut());
				resource.setCopperOut(staticBuildingLevel.getCopperOut() + resource.getCopperOut());
				resource.setSiliconOut(staticBuildingLevel.getSiliconOut() + resource.getSiliconOut());
			}
		}
	}

	/**
	 * 
	 * 重新计算所有玩家资源产量 void
	 */
	public void recalcResourceOut() {
		Iterator<Player> iterator = playerDataManager.getPlayers().values().iterator();

		while (iterator.hasNext()) {
			Player player = iterator.next();
			recalcResourceOut(player);

		}
	}
}
