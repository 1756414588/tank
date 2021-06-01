package com.game.service;

import com.game.actor.role.PlayerEventService;
import com.game.constant.*;
import com.game.dataMgr.*;
import com.game.domain.Player;
import com.game.domain.p.*;
import com.game.domain.s.*;
import com.game.manager.ActivityDataManager;
import com.game.manager.PlayerDataManager;
import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb1.*;
import com.game.util.LogUtil;
import com.game.util.NumberHelper;
import com.game.util.PbHelper;
import com.game.util.TimeHelper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Iterator;
import java.util.List;
import java.util.Map;

/**
 * @author ChenKui
 * @version 创建时间：2015-8-27 下午2:26:54
 * @declare 科技馆科技相关
 */
@Service
public class ScienceService {
	@Autowired
	private StaticRefineDataMgr staticRefineDataMgr;

	@Autowired
	private StaticPropDataMgr staticPropDataMgr;

	@Autowired
	private StaticHeroDataMgr staticHeroDataMgr;

	@Autowired
	private StaticVipDataMgr staticVipDataMgr;

	@Autowired
	private PlayerDataManager playerDataManager;

	@Autowired
	private PlayerEventService playerEventService;

	@Autowired
	private ActivityDataManager activityDataManager;

	@Autowired
	private ActivityNewService activityNewService;

	@Autowired
	private StaticFunctionPlanDataMgr staticFunctionPlanDataMgr;

	/**
	 * 
	 * Method: getScience
	 * 
	 * @Description: 客户端获取科技馆数据 @param handler @return void @throws
	 */
	public void getScience(ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		if (player == null) {
			// LogHelper.ERROR_LOGGER.error("getScience exception " + handler.getRoleId());
			LogUtil.error("getScience exception " + handler.getRoleId());
			return;
		}

		// Map<Integer, StaticRefine> staticRefineMap =
		// staticRefineDataMgr.getStaticRefineMap();
		GetScienceRs.Builder builder = GetScienceRs.newBuilder();
		// Map<Integer, Science> refineMap = player.sciences;
		// Iterator<StaticRefine> it = staticRefineMap.values().iterator();
		Iterator<Science> it = player.sciences.values().iterator();
		while (it.hasNext()) {
			// StaticRefine next = it.next();
			// if (next.getRefineType() != 1) {
			// continue;
			// }
			// Science refine = refineMap.get(next.getRefineId());
			// if (refine == null) {
			// refine = new Science(next.getRefineId(), 0);
			// }
			Science science = it.next();
			// if (science.getScienceId() / 100 == 1) {
			builder.addScience(PbHelper.createSciencePb(science));
			// }
		}

		for (ScienceQue refineQue : player.scienceQue) {
			builder.addQueue(PbHelper.createScienceQuePb(refineQue));
		}

		handler.sendMsgToPlayer(GetScienceRs.ext, builder.build());
	}

	/**
	 * 
	 * 返回升科技花的时间
	 * 
	 * @param player
	 * @param time
	 * @param buildingLv
	 * @return int
	 */
	private int upScienceTime(Player player, int time, int buildingLv, StaticActTechsell config) {
		float add = 0;
		if (staticFunctionPlanDataMgr.isHeroPutOpen()) {
			if (player.isHeroPut(HeroId.KE_JI_GUAN)) {
				if (player.isHeroPut(HeroId.KE_JI_BING)) {
					StaticHeroPut staticHeroPut = staticHeroDataMgr.getHeroPutMap().get(HeroId.KE_JI);
					if (staticHeroPut != null) {
						add = staticHeroPut.getFullSkillValue() / NumberHelper.HUNDRED_FLOAT;
					}
				} else {
					add = staticHeroDataMgr.getStaticHero(HeroId.KE_JI_GUAN).getSkillValue() / NumberHelper.HUNDRED_FLOAT;
				}
			} else if (player.isHeroPut(HeroId.KE_JI_BING)) {
				add = staticHeroDataMgr.getStaticHero(HeroId.KE_JI_BING).getSkillValue() / NumberHelper.HUNDRED_FLOAT;
			}
		} else {
			if (player.hasHero(HeroId.KE_JI_GUAN)) {
				add = staticHeroDataMgr.getStaticHero(HeroId.KE_JI_GUAN).getSkillValue() / NumberHelper.HUNDRED_FLOAT;
			} else if (player.hasHero(HeroId.KE_JI_BING)) {
				add = staticHeroDataMgr.getStaticHero(HeroId.KE_JI_BING).getSkillValue() / NumberHelper.HUNDRED_FLOAT;
			}
		}
		StaticVip staticVip = staticVipDataMgr.getStaticVip(player.lord.getVip());
		if (staticVip != null) {
			add += (staticVip.getSpeedScience() / NumberHelper.HUNDRED_FLOAT);
		}

		// Effect影响科技升级
		Effect effect = player.effects.get(EffectType.ADD_SCIENCE_SPEED_PS);
		if (effect != null) {
			add += (5 / NumberHelper.HUNDRED_FLOAT);
		}
		effect = player.effects.get(EffectType.SUB_SCIENCE_SPEED_PS);
		if (effect != null) {
			add += (-10 / NumberHelper.HUNDRED_FLOAT);
		}

		float addtion = 1 + buildingLv * 0.05f + add;

		if (config != null) {
			addtion += config.getLv() * 0.05f;
		}

		int result = (int) Math.ceil(time / addtion);

		return result;
	}

	/**
	 * 
	 * 最大科技等待队列数
	 * 
	 * @param lord
	 * @return int
	 */
	private int getScienceQueWaitCount(Lord lord) {
		StaticVip staticVip = staticVipDataMgr.getStaticVip(lord.getVip());
		if (staticVip != null) {
			return staticVip.getWaitQue();
		}
		return 0;
	}

	/**
	 * 
	 * Method: upgradeScience
	 * 
	 * @Description: 升级科技 @param req @param handler @return void @throws
	 */
	public void upgradeScience(UpgradeScienceRq req, ClientHandler handler) {
		int scienceId = req.getScienceId();
		if (scienceId / 100 != 1) {
			handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
			return;
		}

		Player player = playerDataManager.getPlayer(handler.getRoleId());
		Map<Integer, Science> refineMap = player.sciences;
		Science refine = refineMap.get(scienceId);
		if (refine == null) {
			refine = new Science();
		}
		int level = refine.getScienceLv() + 1;
		StaticRefineLv staticRefineLv = staticRefineDataMgr.getStaticRefineLv(scienceId, level);
		if (staticRefineLv == null) {
			handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
			return;
		}
		Lord lord = player.lord;
		int fameLv = staticRefineLv.getFameLv();
		int scienceLv = staticRefineLv.getScienceLv();
		if (lord.getFameLv() < fameLv) {
			handler.sendErrorMsgToPlayer(GameError.FAME_LEVEL_ERROR);
			return;
		}

		Building building = player.building;
		int buildingLv = PlayerDataManager.getBuildingLv(BuildingId.TECH, building);
		if (buildingLv < scienceLv) {
			handler.sendErrorMsgToPlayer(GameError.BUILD_LEVEL);
			return;
		}

		StaticActTechsell config = activityNewService.getStaticActTechsell(scienceId);

		int[] discount = activityDataManager.scienceDiscount(player, scienceId);
		int oilCost = staticRefineLv.getOilCost() / discount[1];
		int copperCost = staticRefineLv.getCopperCost() / discount[1];
		int ironCost = staticRefineLv.getIronCost() / discount[1];
		int stone = staticRefineLv.getGoldCost() / discount[1];
		int siliconCost = staticRefineLv.getSilionCost() / discount[1];

		if (config != null) {
			oilCost = (int) (oilCost * ((100 - config.getResource()) / 100.0f));
			copperCost = (int) (copperCost * ((100 - config.getResource()) / 100.0f));
			ironCost = (int) (ironCost * ((100 - config.getResource()) / 100.0f));
			stone = (int) (stone * ((100 - config.getResource()) / 100.0f));
			siliconCost = (int) (siliconCost * ((100 - config.getResource()) / 100.0f));
		}

		Resource resource = player.resource;
		if (resource.getOil() < oilCost || resource.getCopper() < copperCost || resource.getIron() < ironCost
				|| resource.getSilicon() < siliconCost || resource.getStone() < stone) {
			handler.sendErrorMsgToPlayer(GameError.RESOURCE_NOT_ENOUGH);
			return;
		}

		List<ScienceQue> list = player.scienceQue;
		int queSize = list.size();
		int now = (int) (System.currentTimeMillis() / 1000);
		int haust = upScienceTime(player, staticRefineLv.getUpTime(), buildingLv + discount[0], config);

		ScienceQue que = null;
		if (queSize == 0) {
			que = new ScienceQue(player.maxKey(), scienceId, haust, 1, now + haust);
			que.saveCost(stone, ironCost, copperCost, oilCost, siliconCost);
		} else {
			if (queSize > 0 && queSize < getScienceQueWaitCount(player.lord) + 1) {
				que = new ScienceQue(player.maxKey(), scienceId, haust, 0, now + haust);
				que.saveCost(stone, ironCost, copperCost, oilCost, siliconCost);
			} else {
				handler.sendErrorMsgToPlayer(GameError.MAX_SCIENCE_QUE);
				return;
			}
		}

		list.add(que);
		if (oilCost > 0)
			playerDataManager.modifyOil(player, -oilCost, AwardFrom.UP_SCIENCE);
		if (copperCost > 0)
			playerDataManager.modifyCopper(player, -copperCost, AwardFrom.UP_SCIENCE);
		if (ironCost > 0)
			playerDataManager.modifyIron(player, -ironCost, AwardFrom.UP_SCIENCE);
		if (siliconCost > 0)
			playerDataManager.modifySilicon(player, -siliconCost, AwardFrom.UP_SCIENCE);
		if (stone > 0)
			playerDataManager.modifyStone(player, -stone, AwardFrom.UP_SCIENCE);

		UpgradeScienceRs.Builder builder = UpgradeScienceRs.newBuilder();
		builder.setQueue(PbHelper.createScienceQuePb(que));
		builder.setOil(resource.getOil());
		builder.setIron(resource.getIron());
		builder.setCopper(resource.getCopper());
		builder.setSilicon(resource.getSilicon());
		builder.setStone(resource.getStone());
		handler.sendMsgToPlayer(UpgradeScienceRs.ext, builder.build());

		// 重新计算最强实力
		playerEventService.calcStrongestFormAndFight(player);
	}

	/**
	 * 
	 * 科技计时器调用 void
	 */
	public void scienceQueTimerLogic() {
		Iterator<Player> iterator = playerDataManager.getRecThreeMonOnlPlayer().values().iterator();
		int now = TimeHelper.getCurrentSecond();
		while (iterator.hasNext()) {
			Player player = iterator.next();

			/*if(player.is3MothLogin()){
				continue;
			}*/

			if (player.isActive() && !player.scienceQue.isEmpty()) {
				try {
					dealScienceQue(player, player.scienceQue, now);
				} catch (Exception e) {
					LogUtil.error("科技队列定时任务出错, lordId:" + player.lord.getLordId(), e);
				}
			}
		}
	}

	/**
	 * 
	 * 科技升级成功处理
	 * 
	 * @param player
	 * @param list
	 * @param now void
	 */
	private void dealScienceQue(Player player, List<ScienceQue> list, int now) {
		Iterator<ScienceQue> it = list.iterator();
		int endTime = 0;
		while (it.hasNext()) {
			ScienceQue scienceQue = it.next();
			try {
				if (scienceQue.getState() == 1) {
					endTime = scienceQue.getEndTime();
					if (now >= endTime) {
						playerDataManager.addScience(player, scienceQue.getScienceId());
						it.remove();
						continue;
					}
					break;
				} else {
					if (endTime == 0) {
						endTime = now;
					}
					endTime += scienceQue.getPeriod();
					if (now >= endTime) {
						playerDataManager.addScience(player, scienceQue.getScienceId());
						it.remove();
						continue;
					}

					scienceQue.setState(1);
					scienceQue.setEndTime(endTime);
					break;
				}
			} catch (Exception e) {
				LogUtil.error("处理玩家科技报错, lordId:" + player.lord.getLordId() + ", scienceQue:" + scienceQue, e);
			}
		}
	}

	/**
	 * 
	 * Method: speedScienceQue
	 * 
	 * @Description: 加速科技 @param req @param handler @return void @throws
	 */
	public void speedScienceQue(SpeedQueRq req, ClientHandler handler) {
		int keyId = req.getKeyId();
		int cost = req.getCost();
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		List<ScienceQue> list = player.scienceQue;
		ScienceQue que = null;
		for (ScienceQue e : list) {
			if (e.getKeyId() == keyId) {
				que = e;
				break;
			}
		}

		if (que == null) {
			handler.sendErrorMsgToPlayer(GameError.NO_EXIST_QUE);
			return;
		}

		if (que.getState() == 0) {
			handler.sendErrorMsgToPlayer(GameError.SPEED_WAIT_QUE);
			return;
		}

		int now = TimeHelper.getCurrentSecond();
		int leftTime = que.getEndTime() - now;

		SpeedQueRs.Builder builder = SpeedQueRs.newBuilder();
		if (cost == 1) {// 金币
			if (leftTime <= 0) {
				leftTime = 1;
			}
			int sub = (int) Math.ceil(leftTime / 60.0);
			Lord lord = player.lord;
			if (lord.getGold() < sub) {
				handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
				return;
			}
			playerDataManager.subGold(player, sub, AwardFrom.SPEED_SCIENCE_QUE);
			que.setEndTime(now);

			dealScienceQue(player, list, now);

			builder.setGold(lord.getGold());
			handler.sendMsgToPlayer(SpeedQueRs.ext, builder.build());
			return;
		} else {// 道具
			if (!req.hasPropId()) {
				handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
				return;
			}

			int propId = req.getPropId();

			int propCount =1;
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
			int speedTime = one.get(1)*propCount;
			if (type != 3) {// 科技加速
				handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
				return;
			}

			playerDataManager.subProp(player, prop, propCount, AwardFrom.SPEED_SCIENCE_QUE);

			que.setEndTime(que.getEndTime() - speedTime);
			dealScienceQue(player, list, now);

			builder.setCount(prop.getCount());
			builder.setEndTime(que.getEndTime());
			handler.sendMsgToPlayer(SpeedQueRs.ext, builder.build());
			return;
		}
	}

	/**
	 * 
	 * Method: cancelPropQue
	 * 
	 * @Description: 取消科技升级 @param req @param handler @return void @throws
	 */
	public void cancelScienceQue(CancelQueRq req, ClientHandler handler) {
		int keyId = req.getKeyId();
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		List<ScienceQue> list = player.scienceQue;
		ScienceQue que = null;
		for (ScienceQue e : list) {
			if (e.getKeyId() == keyId) {
				que = e;
				break;
			}
		}

		if (que == null) {
			handler.sendErrorMsgToPlayer(GameError.NO_EXIST_QUE);
			return;
		}

		int scienceId = que.getScienceId();
		StaticRefine staticRefine = staticRefineDataMgr.getStaticRefine(scienceId);
		if (staticRefine == null) {
			handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
			return;
		}

		Science science = player.sciences.get(scienceId);
		int level = 1;
		if (science != null) {
			level = science.getScienceLv() + 1;
		}
		StaticRefineLv staticRefineLv = staticRefineDataMgr.getStaticRefineLv(scienceId, level);
		if (staticRefineLv == null) {
			handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
			return;
		}
		list.remove(que);

		int stoneCost = que.getStoneCost() / 2;
		int ironCost = que.getIronCost() / 2;
		int copperCost = que.getCopperCost() / 2;
		int oilCost = que.getOilCost() / 2;
		int silionCost = que.getSilionCost() / 2;

		Resource resource = player.resource;
		CancelQueRs.Builder builder = CancelQueRs.newBuilder();
		if (stoneCost > 0) {
			playerDataManager.modifyStone(player, stoneCost, AwardFrom.CANCEL_SCIENCE_QUE);
		}

		if (ironCost > 0) {
			playerDataManager.modifyIron(player, ironCost, AwardFrom.CANCEL_SCIENCE_QUE);
		}

		if (copperCost > 0) {
			playerDataManager.modifyCopper(player, copperCost, AwardFrom.CANCEL_SCIENCE_QUE);
		}

		if (oilCost > 0) {
			playerDataManager.modifyOil(player, oilCost, AwardFrom.CANCEL_SCIENCE_QUE);
		}

		if (silionCost > 0) {
			playerDataManager.modifySilicon(player, silionCost, AwardFrom.CANCEL_SCIENCE_QUE);
		}

		builder.setStone(resource.getStone());
		builder.setSilicon(resource.getSilicon());
		builder.setIron(resource.getIron());
		builder.setCopper(resource.getCopper());
		builder.setOil(resource.getOil());

		handler.sendMsgToPlayer(CancelQueRs.ext, builder.build());
	}

}
