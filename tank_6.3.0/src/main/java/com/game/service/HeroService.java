package com.game.service;

import com.alibaba.fastjson.JSONArray;
import com.game.actor.role.PlayerEventService;
import com.game.constant.*;
import com.game.dataMgr.StaticAwardsDataMgr;
import com.game.dataMgr.StaticCostDataMgr;
import com.game.dataMgr.StaticFunctionPlanDataMgr;
import com.game.dataMgr.StaticHeroDataMgr;
import com.game.domain.Player;
import com.game.domain.p.*;
import com.game.domain.s.StaticCost;
import com.game.domain.s.StaticHero;
import com.game.domain.s.StaticHeroPut;
import com.game.manager.ActivityDataManager;
import com.game.manager.PlayerDataManager;
import com.game.message.handler.ClientHandler;
import com.game.message.handler.cs.GetHeroPutInfoHandler;
import com.game.message.handler.cs.SetHeroPutHandler;
import com.game.pb.CommonPb;
import com.game.pb.GamePb1.*;
import com.game.pb.GamePb4.MultiHeroImproveRq;
import com.game.pb.GamePb4.MultiHeroImproveRs;
import com.game.pb.GamePb5.*;
import com.game.util.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.Map.Entry;

/**
 * @author ChenKui
 * @version 创建时间：2015-9-1 上午11:23:50
 * @declare 将领相关
 */
@Service
public class HeroService {

	// @Autowired
	// private ResourceDao resourceDao;

	@Autowired
	private StaticHeroDataMgr staticHeroDataMgr;

	@Autowired
	private StaticAwardsDataMgr staticAwardsDataMgr;

	@Autowired
	private StaticCostDataMgr staticCostDataMgr;

	@Autowired
	private PlayerDataManager playerDataManager;

	@Autowired
	private ActivityDataManager activityDataManager;

	@Autowired
	private StaticFunctionPlanDataMgr staticFunctionPlanDataMgr;

	@Autowired
	private PlayerEventService playerEventService;

	@Autowired
	private ChatService chatService;
	@Autowired
	private WorldService worldService;

	/**
	 * Function:获取我的将领数据
	 * 
	 * @param handler
	 */
	public void GetMyHerosRq(ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());

		//删除过期英雄
		worldService.removeExpireHero(player,0);

		Map<Integer, Hero> heroMap = player.heros;
		GetMyHerosRs.Builder builder = GetMyHerosRs.newBuilder();
		Iterator<Hero> it = heroMap.values().iterator();
		while (it.hasNext()) {
			Hero next = it.next();
			if (next.getCount() <= 0) {
				continue;
			}
			builder.addHero(PbHelper.createHeroPb(next));
		}
		Lord lord = player.lord;
		int goldTime = lord.getGoldHeroTime();
		int currentDay = TimeHelper.getCurrentDay();
		if (currentDay != goldTime) {
			builder.setCoinCount(0);
			builder.setResCount(0);
		} else {
			builder.setCoinCount(lord.getGoldHeroCount());
			builder.setResCount(lord.getStoneHeroCount());
		}
		builder.addAllLockHero(player.lockHeros);
		for (AwakenHero awakenHero : player.awakenHeros.values()) {
			builder.addAwakenHero(PbHelper.createAwakenHeroPb(awakenHero));
		}
		handler.sendMsgToPlayer(GetMyHerosRs.ext, builder.build());
	}

	/**
	 * Function:武将分解
	 * 
	 * @param req
	 * @param handler
	 */
	public void heroDecompose(HeroDecomposeRq req, ClientHandler handler) {
		int type = req.getType();
		int id = req.getId();
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		if (player == null) {
			handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
			return;
		}

		HeroDecomposeRs.Builder builder = HeroDecomposeRs.newBuilder();
		Map<Integer, Hero> heroMap = player.heros;
		List<List<Integer>> rewardsList = new ArrayList<List<Integer>>();
		if (type == 1) {
			Hero hero = heroMap.get(id);
			if (hero == null || hero.getCount() <= 0) {
				handler.sendErrorMsgToPlayer(GameError.NO_HERO);
				return;
			}
			if(player.lockHeros.contains(hero.getHeroId())){
				handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
				return;
			}
			int count = hero.getCount();
			//分解文官时，如果入驻参谋部的文官数等于拥有的hero数，则不能分解，则返回错误提示
			if(staticFunctionPlanDataMgr.isHeroPutOpen()) {
				if(count == player.heroPutNum(id)) {
					handler.sendErrorMsgToPlayer(GameError.HERO_ALREADY_PUT);
					return;
				}
			}
			StaticHero staticHero = staticHeroDataMgr.getStaticHero(hero.getHeroId());
			if (staticHero == null) {
				handler.sendErrorMsgToPlayer(GameError.NO_HERO);
				return;
			}
			rewardsList = staticAwardsDataMgr.getAwards(staticHero.getResolveId());
			hero.setCount(count - 1);
			if (hero.getCount() <= 0) {
				heroMap.remove(id);
			}
			LogLordHelper.hero(AwardFrom.HERO_DECOMPOSE, player.account, player.lord, hero.getHeroId(), hero.getCount(), -1,hero.getEndTime(),hero.getCd());
		} else {
			Iterator<Hero> it = heroMap.values().iterator();
			while (it.hasNext()) {
				Hero next = it.next();
				if(player.lockHeros.contains(next.getHeroId())){
					continue;
				}
				StaticHero staticHero = staticHeroDataMgr.getStaticHero(next.getHeroId());
				if (staticHero == null) {
					continue;
				}
				if (staticHero.getStar() == id) {// 星级相同
					int hcount = next.getCount();
					if (hcount <= 0) {
						it.remove();
						continue;
					}
					List<List<Integer>> entity = staticAwardsDataMgr.getAwards(staticHero.getResolveId());
					for (List<Integer> dropOne : entity) {
						if (dropOne.size() != 3) {
							continue;
						}
						int count = dropOne.get(2);
						dropOne.set(2, count * hcount);
					}
					rewardsList.addAll(entity);
					it.remove();
					LogLordHelper.hero(AwardFrom.HERO_DECOMPOSE, player.account, player.lord, next.getHeroId(), 0, -hcount,next.getEndTime(),next.getCd());
				}
			}
		}

		for (int i = 0; i < rewardsList.size(); i++) {
			List<Integer> li = rewardsList.get(i);
			if (li.size() != 3) {
				continue;
			}
			int itemType = li.get(0);
			int itemId = li.get(1);
			int itemCount = li.get(2);
			int keyId = playerDataManager.addAward(player, itemType, itemId, itemCount, AwardFrom.HERO_DECOMPOSE);
			builder.addAward(PbHelper.createAwardPb(itemType, itemId, itemCount, keyId));
		}
		handler.sendMsgToPlayer(HeroDecomposeRs.ext, builder.build());

		//重新计算最强实力
		playerEventService.calcStrongestFormAndFight(player);
	}

	/**
	 * Function:武将升级
	 * 
	 * @param req
	 * @param handler
	 */
	public void heroLevelUp(HeroLevelUpRq req, ClientHandler handler) {
		int keyId = req.getKeyId();
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		
		int heroId = 0;
		if(keyId >= 0){
			Map<Integer, Hero> heroMap = player.heros;
			Hero hero = heroMap.get(keyId);
			if (hero == null || hero.getCount() <= 0) {
				handler.sendErrorMsgToPlayer(GameError.HERO_CHIP_NOT_ENOUGH);
				return;
			}
			
//			if (player.lockHeros.contains(hero.getHeroId())) {
//				handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
//				return;
//			}//允许升级

			heroId = hero.getHeroId();
		}else{
			Map<Integer, AwakenHero> heroMap = player.awakenHeros;
			AwakenHero hero = heroMap.get(-keyId);
			if (hero == null || hero.isUsed()) {
				handler.sendErrorMsgToPlayer(GameError.HERO_CHIP_NOT_ENOUGH);
				return;
			}
			heroId = hero.getHeroId();
		}
		
		StaticHero staticHero = staticHeroDataMgr.getStaticHero(heroId);
		if (staticHero == null) {
			handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
			return;
		}

		int canupHeroId = staticHero.getCanup();
		if (canupHeroId == 0) {
			handler.sendErrorMsgToPlayer(GameError.HERO_CANT_UP);
			return;
		}

		StaticHero staticHeroUp = staticHeroDataMgr.getStaticHero(canupHeroId);
		if (staticHeroUp == null) {
			handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
			return;
		}

		List<List<Integer>> needMeteList = staticHero.getMeta();
		for (int i = 0; i < needMeteList.size(); i++) {
			List<Integer> ll = needMeteList.get(i);
			int id = ll.get(1);
			int count = ll.get(2);
			Prop prop = player.props.get(id);
			if (prop == null || prop.getCount() < count) {
				handler.sendErrorMsgToPlayer(GameError.PROP_NOT_ENOUGH);
				return;
			}
		}

		for (int i = 0; i < needMeteList.size(); i++) {
			List<Integer> ll = needMeteList.get(i);
			int id = ll.get(1);
			int count = ll.get(2);
			Prop prop = player.props.get(id);
			playerDataManager.subProp(player, prop, count, AwardFrom.HERO_UP);
		}

		if (player.lockHeros.contains(heroId)) {
			if (!player.heros.containsKey(heroId)) {
				player.lockHeros.remove(heroId);
			}
			player.lockHeros.add(canupHeroId);
		}

		HeroLevelUpRs.Builder builder = HeroLevelUpRs.newBuilder();
		
		if(keyId >= 0){
			playerDataManager.addHero(player, canupHeroId, 1, AwardFrom.HERO_UP);
			playerDataManager.addHero(player, heroId, -1, AwardFrom.HERO_UP);
			Hero upHero = player.heros.get(staticHero.getCanup());
			builder.setHero(PbHelper.createHeroPb(upHero));
		}else{
			AwakenHero hero = player.awakenHeros.get(-keyId);
			//保留技能 和 次数
			LogLordHelper.awakenHero(AwardFrom.HERO_UP, player.account, player.lord,hero,canupHeroId);
			hero.setHeroId(canupHeroId);
		}
		
		handler.sendMsgToPlayer(HeroLevelUpRs.ext, builder.build());
		if (staticHero.getStar() > 3) {
			chatService.sendWorldChat(chatService.createSysChat(SysChatId.UPGRADE_HERO, player.lord.getNick(), String.valueOf(heroId)));
		}
		//重新计算玩家最强战力
		playerEventService.calcStrongestFormAndFight(player);	}

	/**
	 * Function:武将升阶
	 * 
	 * @param req
	 * @param handler
	 */
	public void heroImprove(HeroImproveRq req, ClientHandler handler) {
		List<CommonPb.Hero> heroList = req.getHeroList();
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		Map<Integer, Hero> heroMap = player.heros;
		int count = 0;
		int star = 0;
		Map<Integer, Integer> costheroMap = new HashMap<Integer, Integer>();
		for (CommonPb.Hero e : heroList) {
			int heroId = e.getHeroId();
			Integer heroCount = costheroMap.get(heroId);
			if (heroCount == null) {
				costheroMap.put(heroId, e.getCount());
			} else {
				heroCount += e.getCount();
				costheroMap.put(heroId, heroCount);
			}
		}

		Iterator<Entry<Integer, Integer>> it = costheroMap.entrySet().iterator();
		while (it.hasNext()) {
			Entry<Integer, Integer> next = it.next();
			int heroId = next.getKey();
			int heroCount = next.getValue();

			StaticHero staticHero = staticHeroDataMgr.getStaticHero(heroId);
			if (staticHero == null) {
				handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
				return;
			}

			Hero hero = heroMap.get(heroId);
			if (hero == null || hero.getCount() <= 0 || hero.getCount() < heroCount) {
				handler.sendErrorMsgToPlayer(GameError.COUNT_NOT_ENOUGH);
				return;
			}
			
			if (player.lockHeros.contains(hero.getHeroId())) {
				handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
				return;
			}

			if (star == 0) {
				star = staticHero.getStar();
			}
			if (staticHero.getStar() != star) {
				handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
				return;
			}

			count += heroCount;
		}

		if (count != 6) {
			handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
			return;
		}

		if (star >= 5) {
			handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
			return;
		}

		List<StaticHero> listHero = staticHeroDataMgr.getStarListLv(star + 1);
		if (listHero == null || listHero.size() == 0) {
			handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
			return;
		}
		StaticHero staticHero = null;
		int seeds[] = { 0, 0 };
		for (StaticHero e : listHero) {
			seeds[0] += e.getProbability();
		}
		seeds[0] = RandomHelper.randomInSize(seeds[0]);
		for (StaticHero e : listHero) {
			seeds[1] += e.getProbability();
			if (seeds[0] <= seeds[1]) {
				staticHero = e;
				break;
			}
		}

		if (staticHero == null) {
			handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
			return;
		}

		int needSoul = staticHeroDataMgr.costSoul(star);
		Prop prop = player.props.get(PropId.HERO_STONE);
		if (prop == null || prop.getCount() < needSoul) {
			handler.sendErrorMsgToPlayer(GameError.PROP_NOT_ENOUGH);
			return;
		}
		int serverId = player.account.getServerId();

		int newHeroId = staticHero.getHeroId();
		for (CommonPb.Hero e : heroList) {
			playerDataManager.addHero(player, e.getHeroId(), -e.getCount(), AwardFrom.HERO_IMPROVE);
			if (staticHero.getStar() >= 3) {
				LogHelper.logItem(player.lord, AwardFrom.HERO_IMPROVE, serverId, AwardType.HERO, e.getHeroId(), -e.getCount(), "sig");
			}
		}

		playerDataManager.subProp(player, prop, needSoul, AwardFrom.HERO_IMPROVE);
		playerDataManager.addHero(player, newHeroId, 1, AwardFrom.HERO_IMPROVE);

		Hero upHero = player.heros.get(newHeroId);
		HeroImproveRs.Builder builder = HeroImproveRs.newBuilder();
		builder.setHero(PbHelper.createHeroPb(upHero));
		playerDataManager.updTask(player, TaskType.COND_HERO_UP, 1, null);
		activityDataManager.heroImprove(player, star + 1);
		handler.sendMsgToPlayer(HeroImproveRs.ext, builder.build());

		if (staticHero.getStar() > 3) {
			chatService.sendWorldChat(chatService.createSysChat(SysChatId.IMPROVE_HERO, player.lord.getNick(), String.valueOf(newHeroId)));
			LogHelper.logItem(player.lord, AwardFrom.HERO_IMPROVE, serverId, AwardType.HERO, staticHero.getHeroId(), 1, "sigln");
		}
		//重新计算玩家最强战力
        playerEventService.calcStrongestFormAndFight(player);	}

	/**
	 * Function:多武将武将升阶
	 * 
	 * @param req
	 * @param handler
	 */
	public void multiHeroImproveRq(MultiHeroImproveRq req, ClientHandler handler) {
		List<CommonPb.Hero> heroList = req.getHeroList();
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		Map<Integer, Hero> heroMap = player.heros;
		int count = 0;
		int star = 0;
		Map<Integer, Integer> costheroMap = new HashMap<Integer, Integer>();
		for (CommonPb.Hero e : heroList) {
			int heroId = e.getHeroId();
			Integer heroCount = costheroMap.get(heroId);
			if (heroCount == null) {
				costheroMap.put(heroId, e.getCount());
			} else {
				heroCount += e.getCount();
				costheroMap.put(heroId, heroCount);
			}
		}

		Iterator<Entry<Integer, Integer>> it = costheroMap.entrySet().iterator();
		while (it.hasNext()) {
			Entry<Integer, Integer> next = it.next();
			int heroId = next.getKey();
			int heroCount = next.getValue();

			StaticHero staticHero = staticHeroDataMgr.getStaticHero(heroId);
			if (staticHero == null) {
				handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
				return;
			}

			Hero hero = heroMap.get(heroId);
			if (hero == null || hero.getCount() <= 0 || hero.getCount() < heroCount) {
				handler.sendErrorMsgToPlayer(GameError.COUNT_NOT_ENOUGH);
				return;
			}
			
			if (player.lockHeros.contains(hero.getHeroId())) {
				handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
				return;
			}

			if (star == 0) {
				star = staticHero.getStar();
			}
			if (staticHero.getStar() != star) {
				handler.sendErrorMsgToPlayer(GameError.HERO_STAR_NOT_SAME);
				return;
			}

			count += heroCount;
		}

		if (count % 6 != 0) {
			handler.sendErrorMsgToPlayer(GameError.COUNT_ERROR);
			return;
		}

		if (star >= 5) {
			handler.sendErrorMsgToPlayer(GameError.HERO_STAR_ERROR);
			return;
		}

		List<StaticHero> listHero = staticHeroDataMgr.getStarListLv(star + 1);
		if (listHero == null || listHero.size() == 0) {
			handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
			return;
		}

		List<StaticHero> awardList = new ArrayList<StaticHero>();
		int repeat = count / 6;
		for (int i = 0; i < repeat; i++) {
			StaticHero staticHero = null;
			int seeds[] = { 0, 0 };
			for (StaticHero e : listHero) {
				seeds[0] += e.getProbability();
			}
			seeds[0] = RandomHelper.randomInSize(seeds[0]);
			for (StaticHero e : listHero) {
				seeds[1] += e.getProbability();
				if (seeds[0] <= seeds[1]) {
					staticHero = e;
					break;
				}
			}

			if (staticHero == null) {
				handler.sendErrorMsgToPlayer(GameError.NO_HERO);
				return;
			}
			awardList.add(staticHero);
		}

		int needSoul = staticHeroDataMgr.costSoul(star) * repeat;
		Prop prop = player.props.get(PropId.HERO_STONE);
		if (prop == null || prop.getCount() < needSoul) {
			handler.sendErrorMsgToPlayer(GameError.PROP_NOT_ENOUGH);
			return;
		}

		int serverId = player.account.getServerId();

		for (CommonPb.Hero e : heroList) {
			int heroId = e.getHeroId();
			int heroCount = e.getCount();
			playerDataManager.addHero(player, e.getHeroId(), -e.getCount(), AwardFrom.HERO_IMPROVE);
			StaticHero staticHero = staticHeroDataMgr.getStaticHero(e.getHeroId());
			if (staticHero.getStar() >= 3) {
				LogHelper.logItem(player.lord, AwardFrom.HERO_IMPROVE, serverId, AwardType.HERO, heroId, -heroCount, "multi");
			}
		}

		playerDataManager.subProp(player, prop, needSoul, AwardFrom.HERO_IMPROVE);

		MultiHeroImproveRs.Builder builder = MultiHeroImproveRs.newBuilder();
		for (StaticHero e : awardList) {
			int newHeroId = e.getHeroId();
			playerDataManager.addHero(player, newHeroId, 1, AwardFrom.HERO_IMPROVE);
			Hero upHero = player.heros.get(newHeroId);
			builder.addHero(PbHelper.createHeroPb(upHero));
			playerDataManager.updTask(player, TaskType.COND_HERO_UP, 1, null);
			activityDataManager.heroImprove(player, star + 1);
			if (e.getStar() > 3) {
				chatService.sendWorldChat(chatService.createSysChat(SysChatId.IMPROVE_HERO, player.lord.getNick(), String.valueOf(newHeroId)));
				LogHelper.logItem(player.lord, AwardFrom.HERO_IMPROVE, serverId, AwardType.HERO, newHeroId, 1, "multi");
			}
		}

		handler.sendMsgToPlayer(MultiHeroImproveRs.ext, builder.build());

		//重新计算玩家最强战力
        playerEventService.calcStrongestFormAndFight(player);
	}

	/**
	 * Function：招募武将
	 * 
	 * @param req
	 * @param handler
	 */
	public void LotteryHero(LotteryHeroRq req, ClientHandler handler) {
		int type = req.getType();
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		if (player == null) {
			handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
			return;
		}
		Lord lord = player.lord;
		if (lord == null) {
			handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
			return;
		}
		int awardId = 8;
		Resource resource = player.resource;
		int costStone = 0;
		int costGold = 0;
		int stoneAdd = 0;
		int goldHeroCount = lord.getGoldHeroCount();
		int stoneHeroCount = lord.getStoneHeroCount();
		int goldTime = lord.getGoldHeroTime();
		int currentDay = TimeHelper.getCurrentDay();
		if (goldTime != currentDay) {
			goldHeroCount = 0;
			stoneHeroCount = 0;
			lord.setGoldHeroCount(0);
			lord.setStoneHeroCount(0);
			lord.setGoldHeroTime(currentDay);
			lord.setStoneHeroTime(currentDay);
		}
		// 1 资源1次 2 资源5次 3 金币1次 4 金币5次
		if (type == 1) {
			StaticCost staticCost = staticCostDataMgr.getCost(2, stoneHeroCount + 1);
			float a = activityDataManager.discountActivity(ActivityConst.ACT_ENLARGE, 2);
			costStone = staticCost.getPrice();
			costStone *= a / 100f;
			if (resource.getStone() < costStone || costStone == 0) {
				handler.sendErrorMsgToPlayer(GameError.STONE_NOT_ENOUGH);
				return;
			}
			lord.setStoneHeroCount(stoneHeroCount + 1);
		} else if (type == 2) {
			StaticCost staticCost = staticCostDataMgr.getCost(2, stoneHeroCount + 1, 5);
			costStone = staticCost.getPrice();
			float a = activityDataManager.discountActivity(ActivityConst.ACT_ENLARGE, 3);
			costStone *= a / 100f;
			if (resource.getStone() < costStone || costStone == 0) {
				handler.sendErrorMsgToPlayer(GameError.STONE_NOT_ENOUGH);
				return;
			}
			awardId = 10;
			lord.setStoneHeroCount(stoneHeroCount + 5);
		} else if (type == 3) {
			StaticCost staticCost = staticCostDataMgr.getCost(1, goldHeroCount + 1);
			costGold = staticCost.getPrice();
			float a = activityDataManager.discountActivity(ActivityConst.ACT_ENLARGE, 0);
			costGold *= a / 100f;
			if (lord.getGold() < costGold || costGold == 0) {
				handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
				return;
			}
			awardId = 9;
			lord.setGoldHeroCount(goldHeroCount + 1);
			stoneAdd = 100;
		} else if (type == 4) {
			StaticCost staticCost = staticCostDataMgr.getCost(1, goldHeroCount + 1, 5);
			costGold = staticCost.getPrice();
			float a = activityDataManager.discountActivity(ActivityConst.ACT_ENLARGE, 1);
			costGold *= a / 100f;
			if (lord.getGold() < costGold || costGold == 0) {
				handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
				return;
			}
			awardId = 11;
			lord.setGoldHeroCount(goldHeroCount + 5);
			stoneAdd = 100 * 5;
		}

		if (costStone > 0) {
			playerDataManager.modifyStone(player, -costStone, AwardFrom.LOTTERY_HERO);
		}
		if (costGold > 0) {
			playerDataManager.subGold(player, costGold, AwardFrom.LOTTERY_HERO);
		}
		if (stoneAdd > 0){
			playerDataManager.modifyStone(player, stoneAdd, AwardFrom.LOTTERY_HERO);
		}

		List<List<Integer>> rewardList = staticAwardsDataMgr.getAwards(awardId);
		LotteryHeroRs.Builder builder = LotteryHeroRs.newBuilder();
		int size = rewardList.size();
		for (int i = 0; i < size; i++) {// 添加武将数据
			List<Integer> reward = rewardList.get(i);
			int itemType = reward.get(0);
			int heroId = reward.get(1);
			int count = reward.get(2);
			playerDataManager.addAward(player, itemType, heroId, count, AwardFrom.LOTTERY_HERO);
			Hero hero = new Hero(heroId, heroId, count);
			builder.addHero(PbHelper.createHeroPb(hero));

			StaticHero staticHero = staticHeroDataMgr.getStaticHero(heroId);
			if (staticHero != null && staticHero.getStar() >= 3) {
				chatService.sendWorldChat(chatService.createSysChat(SysChatId.LOTTERY_HERO, player.lord.getNick(), String.valueOf(heroId)));
			}
		}
		if (stoneAdd > 0){
			builder.setStoneAdd(stoneAdd);
		}
		builder.setStone(player.resource.getStone());
		builder.setGold(lord.getGold());
		playerDataManager.updTask(player, TaskType.COND_HERO_LOTTERY, 1, null);
		if (type == 1 || type == 3) {
			playerDataManager.updTask(player, TaskType.COND_HERO_LOTTERY2, 1, null);
		} else if (type == 2 || type == 4) {
			playerDataManager.updTask(player, TaskType.COND_HERO_LOTTERY2, 5, null);
		}
		handler.sendMsgToPlayer(LotteryHeroRs.ext, builder.build());
		//重新计算玩家最强战力
        playerEventService.calcStrongestFormAndFight(player);
	}
	
	/** 锁定将领 */
	public void lockHero(LockHeroRq req,ClientHandler handler){
		int heroId = req.getHeroId();
		boolean locked = req.getLocked();

		StaticHero staticHero = staticHeroDataMgr.getStaticHero(heroId);
		if (staticHero == null) {
			handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
			return;
		}
		
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		
		if(locked){
			player.lockHeros.add(heroId);
		}else{
			player.lockHeros.remove(heroId);
		}

		LockHeroRs.Builder builder = LockHeroRs.newBuilder();
		handler.sendMsgToPlayer(LockHeroRs.ext, builder.build());
	}
	
	/** 将领觉醒 */
	public void heroAwaken(int heroId, ClientHandler handler) {
		//功能开关没有开启，则风行者不能觉醒
		if (!staticFunctionPlanDataMgr.isAwakenHeroOpen() && (heroId == 246 || heroId == 260 || heroId == 274 || heroId == 288 || heroId == 314 || heroId == 331)) return;
		StaticHero e = staticHeroDataMgr.getStaticHero(heroId);
		if (e == null) {
			handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
			return;
		}

		// 不能觉醒
		if (e.getAwakenHeroId() <= 0) {
			handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
			return;
		}

		Player player = playerDataManager.getPlayer(handler.getRoleId());

		if (player.lord.getLevel() < e.getCommanderLv()) {
			handler.sendErrorMsgToPlayer(GameError.LV_NOT_ENOUGH);
			return;
		}

		Hero hero = player.heros.get(heroId);
		if (hero == null || hero.getCount() < 1) {
			handler.sendErrorMsgToPlayer(GameError.NO_HERO);
			return;
		}

		Map<Integer, Map<Integer, Integer>> mapHeroSkillLv = new HashMap<>();
		for (AwakenHero awakenHero : player.awakenHeros.values()) {
			Map<Integer, Integer> skillMap = mapHeroSkillLv.get(awakenHero.getHeroId());
			if (skillMap == null) {
				skillMap = new HashMap<>();
				mapHeroSkillLv.put(awakenHero.getHeroId(), skillMap);
			}
			for (Entry<Integer, Integer> entry : awakenHero.getSkillLv().entrySet()) {
				Integer lv = skillMap.get(entry.getKey());
				if (lv == null) {
					lv = 0;
				}
				if (entry.getValue() > lv) {
					skillMap.put(entry.getKey(), entry.getValue());
				}
			}
		}

		// [[[346,6,4],[347,6,4],[348,6,4],[349,6,4],[350,6,4],[351,6,4]]]--多个之间是且关系，都必须达到
		JSONArray cond = JSONArray.parseArray(e.getAwakenCond());
		if (cond != null) {
			for (int i = 0; i < cond.size(); i++) {
				JSONArray cond1 = cond.getJSONArray(i);
				// [[346,6,4],[347,6,4],[348,6,4],[349,6,4],[350,6,4],[351,6,4]]--里面条件是或关系，一个达到就行
				boolean condOver = false;
				for (int j = 0; j < cond1.size(); j++) {
					JSONArray cond2 = cond1.getJSONArray(j);
					// [341,6:4]
					Map<Integer, Integer> skillMap = mapHeroSkillLv.get(cond2.getIntValue(0));
					if (skillMap == null) {
						continue;
					}
					for (Entry<Integer, Integer> entry : skillMap.entrySet()) {
						if (cond2.getIntValue(1) == entry.getKey() && entry.getValue() >= cond2.getIntValue(2)) {
							condOver = true;
							break;
						}
					}
					if (condOver) {
						break;
					}
				}
				if (!condOver) {
					handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
					return;
				}
			}
		}

		playerDataManager.addHero(player, e.getHeroId(), -1, AwardFrom.HERO_AWAKEN);// 消耗一个
		AwakenHero awakenHero = playerDataManager.addAwakenHero(player, e.getHeroId(), AwardFrom.HERO_AWAKEN);

		HeroAwakenRs.Builder builder = HeroAwakenRs.newBuilder();
		builder.setAwakenHero(PbHelper.createAwakenHeroPb(awakenHero));
		handler.sendMsgToPlayer(HeroAwakenRs.ext, builder.build());
		// 重新计算玩家最强实力
		playerEventService.calcStrongestFormAndFight(player);
	}
	
	/** 觉醒将领-技能升级 */
	public void heroAwakenSkillLv(int keyId,int id,ClientHandler handler){
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		
		AwakenHero hero = player.awakenHeros.get(keyId);
		if(hero == null){
			handler.sendErrorMsgToPlayer(GameError.NO_HERO);
			return;
		}
		
		StaticHero curHero = staticHeroDataMgr.getStaticHero(hero.getHeroId());
		if (curHero == null) {
			handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
			return;
		}
		
		StaticHero newHero = null;
		//是否觉醒完成
		if(curHero.getAwakenSkillArr().size() == 0){
			newHero = staticHeroDataMgr.getStaticHero(curHero.getAwakenHeroId());
		}else{
			newHero = curHero;
		}
		
		if (newHero == null) {
			handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
			return;
		}
		
		if(hero.isUsed()){
			handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
			return;
		}
		
		List<Integer> tmplSkillIds = newHero.getAwakenSkillArr();
		List<Integer> skillIds = new ArrayList<>();
		//过滤满级的
		int levelFull = 0;//当前满级数量
		boolean mainSkillFull = false; //主动技能是否满级
		for (Integer skillId : tmplSkillIds) {
			Integer skillLv = hero.getSkillLv().get(skillId);
			if(skillLv != null){
				if(staticHeroDataMgr.getHeroAwakenSkill(skillId, skillLv + 1) == null){
					if(tmplSkillIds.get(0) == skillId.intValue()){//主动技能
						mainSkillFull = true;
					}
					levelFull++;
					continue;
				}
			}
			skillIds.add(skillId);
		}
		//全部满级了
		if(levelFull == tmplSkillIds.size()){
			handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
			return;
		}
		
		List<Integer> cost = null;
		int upProb = 0;
		if(id == 1){
			cost = newHero.getCost1();
			upProb = newHero.getUpProb1();
		}else{
			cost = newHero.getCost2();
			upProb = newHero.getUpProb2();
		}
		
		if (!playerDataManager.checkPropIsEnougth(player, cost.get(0), cost.get(1), cost.get(2))) {
			handler.sendErrorMsgToPlayer(GameError.PROP_NOT_ENOUGH);
			return;
		}
		
		Integer upSkillId = null;
		Integer upSkillLv = null;
		
		int lvState = 0;
		if(skillIds.size() > 0){
			//如果主动技能未满级且失败次数达到，主动技能升级
			if(hero.getFailTimes()  >= newHero.getFailTimes() && !mainSkillFull){
				upSkillId = tmplSkillIds.get(0);
				lvState = 1;
			}else{
				int random = RandomHelper.randomInSize(10000);
				if(upProb + hero.getFailTimes() >= random){
					lvState = 1;
					upSkillId = skillIds.get(RandomHelper.randomInSize(skillIds.size()));
				}else{
					hero.setFailTimes(hero.getFailTimes() + 1);
				}
			}
			if(lvState > 0){
				upSkillLv = hero.getSkillLv().get(upSkillId);
				if(upSkillLv == null){
					upSkillLv = 0;
				}
				upSkillLv++;
				hero.getSkillLv().put(upSkillId, upSkillLv);
				hero.setFailTimes(0);
				if(upSkillId.intValue() == tmplSkillIds.get(0)){
					if(staticHeroDataMgr.getHeroAwakenSkill(upSkillId, upSkillLv + 1) == null){
						int heroId = newHero.getHeroId();
						lvState = 2;//主动技能满级 觉醒成功
						LogLordHelper.awakenHero(AwardFrom.HERO_AWAKEN_SKILL_LV, player.account, player.lord,hero,heroId);
						hero.setHeroId(heroId);
						chatService.sendWorldChat(chatService.createSysChat(SysChatId.AWAKEN_HERO_SKILL_MAIN_LV_FULL, player.lord.getNick(),String.valueOf(heroId)));
						
						//发觉醒将领头像邮件
						playerDataManager.sendAwakenHeroIconMail(heroId, newHero.getHeroName(), player);
						
					}else{
						LogLordHelper.awakenHero(AwardFrom.HERO_AWAKEN_SKILL_LV, player.account, player.lord,hero,0);
					}
				}else{
					chatService.sendWorldChat(chatService.createSysChat(SysChatId.AWAKEN_HERO_SKILL_LV_FULL, player.lord.getNick(),String.valueOf(upSkillId)));
					LogLordHelper.awakenHero(AwardFrom.HERO_AWAKEN_SKILL_LV, player.account, player.lord,hero,0);
				}
			}
		}
		
		HeroAwakenSkillLvRs.Builder builder = HeroAwakenSkillLvRs.newBuilder();
		builder.addAtom2(playerDataManager.subProp(player, cost.get(0), cost.get(1), cost.get(2), AwardFrom.HERO_AWAKEN_SKILL_LV));
		builder.setKeyId(keyId);
		builder.setLvState(lvState);
		if(lvState > 0){
			for (Entry<Integer, Integer> entry : hero.getSkillLv().entrySet()) {
				builder.addSkill(PbHelper.createTwoIntPb(entry.getKey(), entry.getValue()));
			}
		}
		builder.setFailTimes(hero.getFailTimes());
		
		handler.sendMsgToPlayer(HeroAwakenSkillLvRs.ext, builder.build());

        //重新计算玩家最强实力
        playerEventService.calcStrongestFormAndFight(player);
	}
	
	/**
	 * 获得文官进驻列表  （参谋配置）
	 * @param req
	 * @param getHeroPutInfoHandler
	 */
	public void getHeroPutInfo(GetHeroPutInfoRq req, GetHeroPutInfoHandler handler) {
		if(!staticFunctionPlanDataMgr.isHeroPutOpen()) return;//功能开关
		
		Map<Integer, List<Integer>> heroPutMap = playerDataManager.getPlayer(handler.getRoleId()).lord.getHeroPut();

		GetHeroPutInfoRs.Builder builder = GetHeroPutInfoRs.newBuilder();

		for (List<Integer> heroList : getHeroPutList(heroPutMap)) {
			builder.addHeroPut(PbHelper.createHeroPut(heroList));
		}

		handler.sendMsgToPlayer(GetHeroPutInfoRs.ext, builder.build());
	}

	/**
	 * 设置文官进驻
	 * @param req
	 * @param setHeroPutHandler
	 */
	public void setHeroPut(SetHeroPutRq req, SetHeroPutHandler handler) {
		if(!staticFunctionPlanDataMgr.isHeroPutOpen()) return;//功能开关
		
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		Map<Integer, List<Integer>> heroPutMap = player.lord.getHeroPut();

		int id = req.getId();
		int partId = req.getPartId();
		int heroId = req.getHeroId();
		
		StaticHeroPut staticHeroPut = staticHeroDataMgr.getHeroPutMap().get(partId);

		// 如果超过最大设置数量，则返回错误
		int boxNum = staticHeroPut.getBoxNamber();
		if (id > boxNum) {
			handler.sendErrorMsgToPlayer(GameError.HERO_OVER_NUM);
			return;
		}

		// 验证是否可以设置，如果将领不在配置表中，则返回错误;heroId为0则为卸下功能
		if (heroId != 0 && !staticHeroPut.getHeroId().contains(heroId)) {
			handler.sendErrorMsgToPlayer(GameError.HERO_CANNOT_PUT);
			return;
		}
		
		List<Integer> heroPut = heroPutMap.get(partId);
		//之前没有该part的文官，则初始化该part
		if (heroPut == null || heroPut.size() == 0) {
			heroPut = new ArrayList<>();
			heroPut.add(partId);
			for(int i = 0; i < boxNum; i++) {
				heroPut.add(0);
			}
			heroPutMap.put(partId, heroPut);
		}
		
		// 入驻的将领是否超过拥有的将领
		if (player.heros.get(heroId) != null && player.heros.get(heroId).getCount() < player.heroPutNum(heroId) + 1) {
			handler.sendErrorMsgToPlayer(GameError.HERO_NOT_ENOUGH);
			return;
		}
		heroPut.set(id, heroId);

		SetHeroPutRs.Builder builder = SetHeroPutRs.newBuilder();

		for (List<Integer> heroList : getHeroPutList(heroPutMap)) {
			builder.addHeroPut(PbHelper.createHeroPut(heroList));
		}
		
		handler.sendMsgToPlayer(SetHeroPutRs.ext, builder.build());
	}
	
	//文官入驻信息
	private List<List<Integer>> getHeroPutList(Map<Integer, List<Integer>> heroPutMap) {
		Map<Integer, StaticHeroPut> heroMap = staticHeroDataMgr.getHeroPutMap();
		List<Integer> heroPut;
		List<List<Integer>> list = new ArrayList<>();
		//遍历配置里的所有part
		for(Entry<Integer, StaticHeroPut> entry : heroMap.entrySet()) {
			heroPut = heroPutMap.get(entry.getKey());
			//如果没有配置该part的文官，则填0
			if (heroPut == null) {
				heroPut = new ArrayList<>();
				StaticHeroPut staticHeroPut = staticHeroDataMgr.getHeroPutMap().get(entry.getKey());
				int boxNum = staticHeroPut.getBoxNamber();
				heroPut.add(entry.getKey());
				for(int i = 0; i < boxNum; i++) {
					heroPut.add(0);
				}
			}
			
			list.add(heroPut);
		}
		return list;
	}
}