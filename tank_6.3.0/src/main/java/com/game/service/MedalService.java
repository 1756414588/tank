package com.game.service;

import com.game.actor.role.PlayerEventService;
import com.game.constant.*;
import com.game.dataMgr.StaticActivityDataMgr;
import com.game.dataMgr.StaticFunctionPlanDataMgr;
import com.game.dataMgr.StaticHeroDataMgr;
import com.game.dataMgr.StaticMedalDataMgr;
import com.game.domain.MedalBouns;
import com.game.domain.Player;
import com.game.domain.p.Lord;
import com.game.domain.p.Medal;
import com.game.domain.p.MedalChip;
import com.game.domain.p.MedalResolve;
import com.game.domain.s.StaticMedal;
import com.game.domain.s.StaticMedalRefit;
import com.game.domain.s.StaticMedalUp;
import com.game.manager.ActivityDataManager;
import com.game.manager.PlayerDataManager;
import com.game.manager.RankDataManager;
import com.game.message.handler.ClientHandler;
import com.game.message.handler.cs.medal.TransMedalHandler;
import com.game.pb.CommonPb;
import com.game.pb.GamePb5.*;
import com.game.pb.GamePb6.QuickUpMedalRq;
import com.game.pb.GamePb6.QuickUpMedalRs;
import com.game.util.LogLordHelper;
import com.game.util.PbHelper;
import com.game.util.RandomHelper;
import com.game.util.TimeHelper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.Map.Entry;

/**
 * 勋章相关逻辑
 * 
 * @ClassName: MedalService
 * @Description:
 * @author
 */
@Service
public class MedalService {

	@Autowired
	private PlayerDataManager playerDataManager;

	@Autowired
	private RankDataManager rankDataManager;

	@Autowired
	private StaticMedalDataMgr staticMedalDataMgr;

	@Autowired
	private ChatService chatService;

	@Autowired
	private PlayerEventService playerEventService;

	@Autowired
	private StaticFunctionPlanDataMgr staticFunctionPlanDataMgr;

	@Autowired
	private StaticHeroDataMgr staticHeroDataMgr;

	@Autowired
	private StaticActivityDataMgr staticActivityDataMgr;

	@Autowired
	private ActivityDataManager activityDataManager;

	/** 所有勋章：0仓库、1身上 */
	public void getMedal(ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		GetMedalRs.Builder builder = GetMedalRs.newBuilder();

		for (Map<Integer, Medal> map : player.medals.values()) {
			Iterator<Medal> it = map.values().iterator();
			while (it.hasNext()) {
				builder.addMedal(PbHelper.createMedalPb(it.next()));
			}
		}

		handler.sendMsgToPlayer(GetMedalRs.ext, builder.build());
	}

	/** 勋章碎片 */
	public void getMedalChip(ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		GetMedalChipRs.Builder builder = GetMedalChipRs.newBuilder();

		Iterator<MedalChip> it = player.medalChips.values().iterator();
		while (it.hasNext()) {
			builder.addMedalChip(PbHelper.createMedalChipPb(it.next()));
		}

		handler.sendMsgToPlayer(GetMedalChipRs.ext, builder.build());
	}

	/** 展厅数据：0获得过且未展示 1获得过且已展示 */
	public void getMedalBouns(ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		GetMedalBounsRs.Builder builder = GetMedalBounsRs.newBuilder();

		for (Map<Integer, MedalBouns> map : player.medalBounss.values()) {
			Iterator<MedalBouns> it = map.values().iterator();
			while (it.hasNext()) {
				builder.addMedalBouns(PbHelper.createMedalBounsPb(it.next()));
			}
		}

		handler.sendMsgToPlayer(GetMedalBounsRs.ext, builder.build());
	}

	/** 合成勋章 */
	public void combineMedal(CombineMedalRq req, ClientHandler handler) {
		int medalId = req.getMedalChipId();
		Player player = playerDataManager.getPlayer(handler.getRoleId());

		if (medalId == MedalConst.UNIVERSAL_MEDAL_CHIP_ID) {
			handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
			return;
		}

		StaticMedal staticMedal = staticMedalDataMgr.getStaticMedal(medalId);
		if (staticMedal == null) {
			handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
			return;
		}

		MedalChip chip = player.medalChips.get(medalId);
		MedalChip whatChip = player.medalChips.get(MedalConst.UNIVERSAL_MEDAL_CHIP_ID);
		int chipCount = 0;
		int whatCount = 0;
		if (chip != null) {
			chipCount = chip.getCount();
		}

		if (whatChip != null) {
			whatCount = whatChip.getCount();
		}

		if (chipCount + whatCount < staticMedal.getChipCount()) {
			handler.sendErrorMsgToPlayer(GameError.MEDAL_CHIP_NOT_ENOUGH);
			return;
		}

		/**
		 * 判断合成仓库勋章数量是否已经到最大上限
		 */
		Map<Integer, Medal> storeMap = player.medals.get(0);
		if (storeMap.size() >= MedalConst.MEDAL_STORE_LIMIT) {
			handler.sendErrorMsgToPlayer(GameError.MAX_MEDAL_STORE);
			return;
		}

		if (chip != null) {
			if (chipCount >= staticMedal.getChipCount()) {
				playerDataManager.subMedalChip(player, chip, staticMedal.getChipCount(), AwardFrom.COMBINE_MEDAL);
			} else {
				int count = staticMedal.getChipCount() - chipCount;
				if (chipCount > 0) {
					playerDataManager.subMedalChip(player, chip, chipCount, AwardFrom.COMBINE_MEDAL);
				}
				playerDataManager.subMedalChip(player, whatChip, count, AwardFrom.COMBINE_MEDAL);
			}
		}

		Medal medal = playerDataManager.addMedal(player, medalId, 0, 0, 0, AwardFrom.COMBINE_MEDAL);

		CombineMedalRs.Builder builder = CombineMedalRs.newBuilder();
		builder.setMedal(PbHelper.createMedalPb(medal));
		handler.sendMsgToPlayer(CombineMedalRs.ext, builder.build());
	}

	/**
	 * 
	 * 用来增加道具数量
	 * 
	 * @param map key1=type key2=id value2= count
	 * @param type
	 * @param id
	 * @param count void
	 */
	private void addMapNum(Map<Integer, Map<Integer, Integer>> map, int type, int id, int count) {
		if (count <= 0) {
			return;
		}
		Map<Integer, Integer> map2 = map.get(type);
		if (map2 == null) {
			map2 = new HashMap<>();
			map.put(type, map2);
		}
		Integer curCount = map2.get(id);
		if (curCount == null) {
			curCount = 0;
		}
		curCount += count;
		map2.put(id, curCount);
	}

	/** 分解勋章 */
	public void explodeMedal(ExplodeMedalRq req, ClientHandler handler) {
		int keyId = 0;
		if (req.hasKeyId()) {
			keyId = req.getKeyId();
		}

		Player player = playerDataManager.getPlayer(handler.getRoleId());

		// detergent 洗涤剂
		// grindstone 研磨石
		// inertGas 惰性气体
		// maintainOil 保养油
		// polishingMtr 抛光材料
		Map<Integer, Map<Integer, Integer>> map = new HashMap<>();

		List<MedalResolve> resolveList = new ArrayList<>();
		if (keyId != 0) {// 分解单个
			Map<Integer, Medal> store = player.medals.get(0);
			Medal medal = store.get(keyId);
			if (medal == null) {
				handler.sendErrorMsgToPlayer(GameError.NO_MEDAL);
				return;
			}

			if (medal.isLocked()) {
				handler.sendErrorMsgToPlayer(GameError.MEDAL_LOCKED);
				return;
			}

			StaticMedal staticMedal = staticMedalDataMgr.getStaticMedal(medal.getMedalId());
			if (staticMedal == null) {
				handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
				return;
			}

			StaticMedalUp staticMedalUp = staticMedalDataMgr.getStaticMedalUp(staticMedal.getQuality(), medal.getUpLv());
			if (staticMedalUp == null) {
				handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
				return;
			}

			StaticMedalRefit staticMedalRefit = staticMedalDataMgr.getStaticMedalRefit(staticMedal.getQuality(), medal.getRefitLv());
			if (staticMedalRefit == null) {
				handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
				return;
			}

			store.remove(keyId);

			// 强化返还
			for (List<Integer> cost : staticMedalUp.getExplode()) {
				int type = cost.get(0);
				int id = cost.get(1);
				int count = cost.get(2);

				if (count <= 0) {
					continue;
				}
				playerDataManager.addAward(player, type, id, count, AwardFrom.EXPLODE_MEDAL);

				addMapNum(map, type, id, count);
			}
			// 改造返还
			for (List<Integer> cost : staticMedalRefit.getExplode()) {
				int type = cost.get(0);
				int id = cost.get(1);
				int count = cost.get(2);

				if (count <= 0) {
					continue;
				}
				playerDataManager.addAward(player, type, id, count, AwardFrom.EXPLODE_MEDAL);

				addMapNum(map, type, id, count);
			}
			resolveList.add(new MedalResolve(AwardType.MEDAL, staticMedal.getQuality(), 1, staticMedal.getPosition()));
			LogLordHelper.medal(AwardFrom.EXPLODE_MEDAL, player.account, player.lord, medal, 1);
		} else {// 批量分解
			List<Integer> qualites = req.getQualityList();
			Map<Integer, Medal> store = player.medals.get(0);
			Iterator<Medal> it = store.values().iterator();
			while (it.hasNext()) {
				Medal medal = it.next();
				if (medal.isLocked()) {
					continue;
				}

				StaticMedal staticMedal = staticMedalDataMgr.getStaticMedal(medal.getMedalId());
				if (staticMedal == null) {
					handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
					return;
				}

				if (qualites.contains(staticMedal.getQuality())) {
					StaticMedalUp staticMedalUp = staticMedalDataMgr.getStaticMedalUp(staticMedal.getQuality(), medal.getUpLv());
					if (staticMedalUp == null) {
						continue;
					}

					StaticMedalRefit staticMedalRefit = staticMedalDataMgr.getStaticMedalRefit(staticMedal.getQuality(),
							medal.getRefitLv());
					if (staticMedalRefit == null) {
						continue;
					}

					it.remove();
					resolveList.add(new MedalResolve(AwardType.MEDAL, staticMedal.getQuality(), 1, staticMedal.getPosition()));
					// 强化返还
					for (List<Integer> cost : staticMedalUp.getExplode()) {
						int type = cost.get(0);
						int id = cost.get(1);
						int count = cost.get(2);

						if (count <= 0) {
							continue;
						}
						playerDataManager.addAward(player, type, id, count, AwardFrom.EXPLODE_MEDAL);

						addMapNum(map, type, id, count);
					}
					// 改造返还
					for (List<Integer> cost : staticMedalRefit.getExplode()) {
						int type = cost.get(0);
						int id = cost.get(1);
						int count = cost.get(2);

						if (count <= 0) {
							continue;
						}
						playerDataManager.addAward(player, type, id, count, AwardFrom.EXPLODE_MEDAL);

						addMapNum(map, type, id, count);
					}

					LogLordHelper.medal(AwardFrom.EXPLODE_MEDAL, player.account, player.lord, medal, 1);
				}
			}
		}
		activityDataManager.medalResolve(player, resolveList);

		ExplodeMedalRs.Builder builder = ExplodeMedalRs.newBuilder();
		// 返回增加奖励信息
		for (Entry<Integer, Map<Integer, Integer>> entry : map.entrySet()) {
			int type = entry.getKey();
			Map<Integer, Integer> entryMap = entry.getValue();
			for (Entry<Integer, Integer> entry1 : entryMap.entrySet()) {
				CommonPb.Award.Builder award = CommonPb.Award.newBuilder();
				award.setType(type);
				award.setId(entry1.getKey());
				award.setCount(entry1.getValue());

				builder.addAwards(award);
			}
		}
		handler.sendMsgToPlayer(ExplodeMedalRs.ext, builder.build());
	}

	/** 分解勋章碎片 */
	public void explodeMedalChip(ExplodeMedalChipRq req, ClientHandler handler) {
		int chipId = 0;
		if (req.hasChipId()) {
			chipId = req.getChipId();
		}

		Player player = playerDataManager.getPlayer(handler.getRoleId());

		Map<Integer, Map<Integer, Integer>> map = new HashMap<>();
		List<MedalResolve> resolveList = new ArrayList<>();
		if (chipId != 0) {
			int count = req.getCount();
			if (count < 0) {
				handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
				return;
			}

			MedalChip chip = player.medalChips.get(chipId);
			if (chip == null || chip.getCount() < count) {
				handler.sendErrorMsgToPlayer(GameError.MEDAL_CHIP_NOT_ENOUGH);
				return;
			}

			StaticMedal staticMedal = staticMedalDataMgr.getStaticMedal(chipId);
			if (staticMedal == null) {
				handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
				return;
			}

			StaticMedalRefit staticMedalRefit = staticMedalDataMgr.getStaticMedalRefit(staticMedal.getQuality(), 0);
			if (staticMedalRefit == null) {
				return;
			}

			for (List<Integer> cost : staticMedalRefit.getExplode()) {
				int type = cost.get(0);
				int id = cost.get(1);
				int num = 0;
				if (staticMedal.getExplodeChipCount() > 0) {
					num = (int) Math.ceil(cost.get(2) / staticMedal.getExplodeChipCount());
				} else {
					num = cost.get(2);
				}
				if (num <= 0) {
					continue;
				}
				num = num * count;
				playerDataManager.addAward(player, type, id, num, AwardFrom.EXPLODE_MEDAL);

				addMapNum(map, type, id, num);
			}
			resolveList.add(new MedalResolve(AwardType.MEDAL_CHIP, staticMedal.getQuality(), count, staticMedal.getPosition()));
			playerDataManager.subMedalChip(player, chip, count, AwardFrom.EXPLODE_MEDAL_CHIP);

		} else {
			List<Integer> qualites = req.getQualityList();

			Map<Integer, MedalChip> chips = player.medalChips;
			Iterator<MedalChip> it = chips.values().iterator();
			while (it.hasNext()) {
				MedalChip chip = (MedalChip) it.next();
				StaticMedal staticMedal = staticMedalDataMgr.getStaticMedal(chip.getChipId());
				if (staticMedal == null) {
					continue;
				}

				int count = chip.getCount();
				if (count > 0 && qualites.contains(staticMedal.getQuality())) {
					StaticMedalRefit staticMedalRefit = staticMedalDataMgr.getStaticMedalRefit(staticMedal.getQuality(), 0);
					if (staticMedalRefit == null) {
						continue;
					}

					it.remove();
					resolveList.add(
							new MedalResolve(AwardType.MEDAL_CHIP, staticMedal.getQuality(), chip.getCount(), staticMedal.getPosition()));

					for (List<Integer> cost : staticMedalRefit.getExplode()) {
						int type = cost.get(0);
						int id = cost.get(1);
						int num = 0;
						if (staticMedal.getExplodeChipCount() > 0) {
							num = (int) Math.ceil(cost.get(2) / staticMedal.getExplodeChipCount());
						} else {
							num = cost.get(2);
						}
						if (num <= 0) {
							continue;
						}
						num = num * count;
						playerDataManager.addAward(player, type, id, num, AwardFrom.EXPLODE_MEDAL);

						addMapNum(map, type, id, num);
					}
					LogLordHelper.medalChip(AwardFrom.EXPLODE_MEDAL_CHIP, player.account, player.lord, chip.getChipId(), 0, -count);
				}
			}
		}
		activityDataManager.medalResolve(player, resolveList);
		ExplodeMedalChipRs.Builder builder = ExplodeMedalChipRs.newBuilder();
		// 返回增加奖励信息
		for (Entry<Integer, Map<Integer, Integer>> entry : map.entrySet()) {
			int type = entry.getKey();
			Map<Integer, Integer> entryMap = entry.getValue();
			for (Entry<Integer, Integer> entry1 : entryMap.entrySet()) {
				CommonPb.Award.Builder award = CommonPb.Award.newBuilder();
				award.setType(type);
				award.setId(entry1.getKey());
				award.setCount(entry1.getValue());
				builder.addAwards(award);
			}
		}
		handler.sendMsgToPlayer(ExplodeMedalChipRs.ext, builder.build());
	}

	/**
	 * 
	 * 是否符合穿戴等级
	 * 
	 * @param lv
	 * @param index
	 * @return boolean
	 */
	private boolean canOnMedal(int lv, int index) {
		Integer openLv = MedalConst.MEDAL_POS_OPEN_LV.get(index);
		if (openLv != null && lv >= openLv) {
			return true;
		}
		return false;
	}

	/** 穿上、卸下勋章 */
	public void onMedal(OnMedalRq req, ClientHandler handler) {
		int keyId = req.getKeyId();
		int pos = 0;
		if (req.hasPos()) {
			pos = req.getPos();
		}

		if (pos < 0 || pos > 1) {
			handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
			return;
		}

		Player player = playerDataManager.getPlayer(handler.getRoleId());
		Map<Integer, Medal> map = player.medals.get(pos);
		if (map == null) {
			handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
			return;
		}

		Medal medal = map.get(keyId);
		if (medal == null) {
			handler.sendErrorMsgToPlayer(GameError.NO_MEDAL);
			return;
		}

		StaticMedal staticMedal = staticMedalDataMgr.getStaticMedal(medal.getMedalId());
		if (staticMedal == null) {
			handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
			return;
		}

		OnMedalRs.Builder builder = OnMedalRs.newBuilder();

		if (pos == 0) {// 穿上
			int toPos = 1;
			Map<Integer, Medal> toMap = player.medals.get(toPos);
			if (toMap.size() >= 10) {
				handler.sendErrorMsgToPlayer(GameError.FULL_MEDAL_ON);
				return;
			}

			int index = medal.getMedalId() / 100;
			if (!canOnMedal(player.lord.getLevel(), index)) {
				handler.sendErrorMsgToPlayer(GameError.LV_NOT_ENOUGH);
				return;
			}

			Iterator<Medal> it = toMap.values().iterator();
			while (it.hasNext()) {
				Medal putonMedal = it.next();
				// 已穿戴勋章，则先卸下
				if (putonMedal.getMedalId() / 100 == index) {
					putonMedal.setPos(0);
					toMap.remove(putonMedal.getKeyId());
					player.medals.get(0).put(putonMedal.getKeyId(), putonMedal);
					builder.addMedals(PbHelper.createMedalPb(putonMedal));
					break;
				}
			}
			medal.setPos(toPos);
			map.remove(keyId);
			toMap.put(keyId, medal);
		} else {// 卸下
			Map<Integer, Medal> storeMap = player.medals.get(0);
			if (storeMap.size() >= MedalConst.MEDAL_STORE_LIMIT) {
				handler.sendErrorMsgToPlayer(GameError.MAX_MEDAL_STORE);
				return;
			}

			medal.setPos(0);
			map.remove(keyId);
			player.medals.get(0).put(keyId, medal);
		}

		playerDataManager.updateFight(player);

		builder.addMedals(PbHelper.createMedalPb(medal));
		handler.sendMsgToPlayer(OnMedalRs.ext, builder.build());

		playerEventService.calcStrongestFormAndFight(player);
	}

	/** 锁定勋章 */
	public void lockMedal(LockMedalRq req, ClientHandler handler) {
		int keyId = req.getKeyId();
		int pos = req.getPos();
		boolean locked = req.getLocked();

		if (pos < 0 || pos > 1) {
			handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
			return;
		}

		Player player = playerDataManager.getPlayer(handler.getRoleId());
		Map<Integer, Medal> map = player.medals.get(pos);
		if (map == null) {
			handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
			return;
		}

		Medal medal = map.get(keyId);
		if (medal == null) {
			handler.sendErrorMsgToPlayer(GameError.NO_MEDAL);
			return;
		}

		StaticMedal staticMedal = staticMedalDataMgr.getStaticMedal(medal.getMedalId());
		if (staticMedal == null) {
			handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
			return;
		}

		medal.setLocked(locked);

		LockMedalRs.Builder builder = LockMedalRs.newBuilder();
		builder.setLocked(locked);
		handler.sendMsgToPlayer(LockMedalRs.ext, builder.build());
	}

	/** 增加勋章经验 */
	private void addMedalExp(Medal medal, StaticMedalUp staticMedalUp, int exp) {
		int curExp = medal.getUpExp() + exp;
		int curLv = medal.getUpLv();
		while (staticMedalUp != null) {
			if (curExp >= staticMedalUp.getExp()) {
				curExp -= staticMedalUp.getExp();
				curLv++;

				staticMedalUp = staticMedalDataMgr.getStaticMedalUp(staticMedalUp.getQuality(), curLv + 1);
			} else {
				break;
			}
		}
		if (staticMedalUp == null) {
			medal.setUpLv(curLv);
			medal.setUpExp(0);
		} else {
			medal.setUpLv(curLv);
			medal.setUpExp(curExp);
		}
	}

	/** 购买强化勋章cd */
	public void buyMedalCdTime(BuyMedalCdTimeRq req, ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());

		int curTime = TimeHelper.getCurrentSecond();
		int cdTime = player.lord.getMedalUpCdTime();
		int costCdTime = (cdTime - curTime);

		if (cdTime < curTime) {// cd已经全部冷却
			player.lord.setMedalUpCdTime(curTime);
		} else {// 还在冷却中
			int sub = (int) Math.ceil(costCdTime / 60.0);
			Lord lord = player.lord;
			if (lord.getGold() < sub) {
				handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
				return;
			}
			playerDataManager.subGold(player, sub, AwardFrom.BUY_MEDAL_CD_TIME);
			player.lord.setMedalUpCdTime(curTime - 1000);
		}

		BuyMedalCdTimeRs.Builder builder = BuyMedalCdTimeRs.newBuilder();
		builder.setCdTime(player.lord.getMedalUpCdTime());
		builder.setGold(player.lord.getGold());
		handler.sendMsgToPlayer(BuyMedalCdTimeRs.ext, builder.build());
	}

	/** 强化勋章 */
	public void upMedal(UpMedalRq req, ClientHandler handler) {
		int keyId = req.getKeyId();
		int pos = req.getPos();
		if (pos < 0 || pos > 1) {
			handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
			return;
		}

		Player player = playerDataManager.getPlayer(handler.getRoleId());

		Map<Integer, Medal> map = player.medals.get(pos);
		if (map == null) {
			handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
			return;
		}

		Medal medal = map.get(keyId);
		if (medal == null) {
			handler.sendErrorMsgToPlayer(GameError.NO_MEDAL);
			return;
		}

		if (medal.getUpLv() >= player.lord.getLevel()) {
			handler.sendErrorMsgToPlayer(GameError.LV_NOT_ENOUGH);
			return;
		}

		if (medal.getUpLv() >= MedalConst.MAX_MEDAL_UP_LV) {
			handler.sendErrorMsgToPlayer(GameError.MAX_MEDAL_UP_LV);
			return;
		}

		StaticMedal staticMedal = staticMedalDataMgr.getStaticMedal(medal.getMedalId());
		if (staticMedal == null) {
			handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
			return;
		}

		StaticMedalUp staticMedalUp = staticMedalDataMgr.getStaticMedalUp(staticMedal.getQuality(), medal.getUpLv() + 1);
		if (staticMedalUp == null) {
			handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
			return;
		}

		for (List<Integer> award : staticMedalUp.getCost()) {
			if (!playerDataManager.checkPropIsEnougth(player, award.get(0), award.get(1), award.get(2))) {
				handler.sendErrorMsgToPlayer(GameError.PROP_NOT_ENOUGH);
				return;
			}
		}

		// 荣誉勋章活动期间玩家升级没有CD消耗
		boolean isActMedalofhonorOpen = staticActivityDataMgr.isMedalofhonorActivityOpen();
		int curTime = TimeHelper.getCurrentSecond();
		int cdTime = player.lord.getMedalUpCdTime();
		if (!isActMedalofhonorOpen) {
			int costCdTime = (cdTime - curTime);
			if (costCdTime > 0 && costCdTime > MedalConst.MEDAL_UP_TIME_MAX) {
				handler.sendErrorMsgToPlayer(GameError.MEDAL_UP_CD_ENOUGH);
				return;
			}
		}

		// 是否能触发直接升级
		int hitState = 0; // 0未发生 1发生升级 2发生经验暴击
		if (medal.getUpExp() >= staticMedalUp.getLeastExp()) {
			// 直接升级
			if (RandomHelper.isHitRangeIn10000(staticMedalUp.getBonusLv())) {
				hitState = 1;
			}
		}

		int prevUpLv = medal.getUpLv();

		if (hitState == 1) {
			medal.setUpExp(0);
			medal.setUpLv(medal.getUpLv() + 1);
		} else {
			int addExp = MedalConst.MEDAL_UP_ADD_EXP;

			// 军需官入驻，则增加3点经验
			if (player.isHeroPut(HeroId.JUN_XU_GUAN)) {
				addExp += staticHeroDataMgr.getStaticHero(HeroId.JUN_XU_GUAN).getSkillValue();
			}

			// 是否经验暴击
			if (RandomHelper.isHitRangeIn10000(staticMedalUp.getBonusExp())) {
				addExp = addExp * 2;
				hitState = 2;
			}
			addMedalExp(medal, staticMedalUp, addExp);
		}
		if (!isActMedalofhonorOpen) {
			if (cdTime < curTime) {// cd已经全部冷却
				player.lord.setMedalUpCdTime(curTime + MedalConst.MEDAL_UP_TIME);
			} else {// 还在冷却中
				player.lord.setMedalUpCdTime(cdTime + MedalConst.MEDAL_UP_TIME);
			}
		}

		if (pos != 0) {
			playerDataManager.updateFight(player);
			playerEventService.calcStrongestFormAndFight(player);
		}

		UpMedalRs.Builder builder = UpMedalRs.newBuilder();
		builder.setHitState(hitState);
		builder.setCdTime(player.lord.getMedalUpCdTime());
		for (List<Integer> award : staticMedalUp.getCost()) {
			CommonPb.Atom2 atom = playerDataManager.subProp(player, award.get(0), award.get(1), award.get(2), AwardFrom.UP_MEDAL);
			builder.addAtom(atom);
		}
		builder.setUpLv(medal.getUpLv());
		builder.setUpExp(medal.getUpExp());
		handler.sendMsgToPlayer(UpMedalRs.ext, builder.build());

		if (medal.getUpLv() > prevUpLv) {
			if (medal.getUpLv() == 20) {
				chatService.sendWorldChat(
						chatService.createSysChat(SysChatId.MEDAL_UP, player.lord.getNick(), String.valueOf(medal.getMedalId()), "20"));
			} else if (medal.getUpLv() == 40) {
				chatService.sendWorldChat(
						chatService.createSysChat(SysChatId.MEDAL_UP, player.lord.getNick(), String.valueOf(medal.getMedalId()), "40"));
			} else if (medal.getUpLv() == 60) {
				chatService.sendWorldChat(
						chatService.createSysChat(SysChatId.MEDAL_UP, player.lord.getNick(), String.valueOf(medal.getMedalId()), "60"));
			} else if (medal.getUpLv() == 80) {
				chatService.sendWorldChat(
						chatService.createSysChat(SysChatId.MEDAL_UP, player.lord.getNick(), String.valueOf(medal.getMedalId()), "80"));
			}
		}

		LogLordHelper.medal(AwardFrom.UP_MEDAL, player.account, player.lord, medal, 2);
	}

	/**
	 * 一键升级勋章
	 * 
	 * @param handler
	 * @param req
	 */
	public void quickUpMedal(ClientHandler handler, QuickUpMedalRq req) {
		int keyId = req.getKeyId();
		int pos = req.getPos();
		if (pos < 0 || pos > 1) {
			handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
			return;
		}

		Player player = playerDataManager.getPlayer(handler.getRoleId());

		Map<Integer, Medal> map = player.medals.get(pos);
		if (map == null) {
			handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
			return;
		}

		Medal medal = map.get(keyId);
		if (medal == null) {
			handler.sendErrorMsgToPlayer(GameError.NO_MEDAL);
			return;
		}

		StaticMedal staticMedal = staticMedalDataMgr.getStaticMedal(medal.getMedalId());
		if (staticMedal == null) {
			handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
			return;
		}

		if (medal.getUpLv() >= player.lord.getLevel()) {
			handler.sendErrorMsgToPlayer(GameError.LV_NOT_ENOUGH);
			return;
		}

		if (medal.getUpLv() >= MedalConst.MAX_MEDAL_UP_LV) {
			handler.sendErrorMsgToPlayer(GameError.MAX_MEDAL_UP_LV);
			return;
		}

		StaticMedalUp staticMedalUp = staticMedalDataMgr.getStaticMedalUp(staticMedal.getQuality(), medal.getUpLv() + 1);
		if (staticMedalUp == null) {
			handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
			return;
		}

		int oldLv = medal.getUpLv();

		// 导致一键升级停止的原因
		int state = 0;
		// 是否触发幸运升级
		int luckyUp = 0;
		// 触发幸运暴击的次数
		int luckyHit = 0;
		// 总共消耗的道具物品集合
		List<CommonPb.Atom2.Builder> builderList = new ArrayList<>();
		outer: while (true) {
			for (List<Integer> award : staticMedalUp.getCost()) {
				if (!playerDataManager.checkPropIsEnougth(player, award.get(0), award.get(1), award.get(2))) {
					state = 1;
					break outer;
				}
			}

			// 荣誉勋章活动期间玩家升级没有CD消耗
			boolean isActMedalofhonorOpen = staticActivityDataMgr.isMedalofhonorActivityOpen();
			int curTime = TimeHelper.getCurrentSecond();
			int cdTime = player.lord.getMedalUpCdTime();
			if (!isActMedalofhonorOpen) {
				int costCdTime = (cdTime - curTime);
				if (costCdTime > 0 && costCdTime > MedalConst.MEDAL_UP_TIME_MAX) {
					state = 2;
					break;
				}
			}

			// 是否能触发直接升级
			int hitState = 0; // 0未发生 1发生升级 2发生经验暴击
			if (medal.getUpExp() >= staticMedalUp.getLeastExp()) {
				// 直接升级
				if (RandomHelper.isHitRangeIn10000(staticMedalUp.getBonusLv())) {
					hitState = 1;
				}
			}

			if (hitState == 1) {
				medal.setUpExp(0);
				medal.setUpLv(medal.getUpLv() + 1);
				luckyUp = 1;
				state = 3;
				break;
			} else {
				int addExp = MedalConst.MEDAL_UP_ADD_EXP;

				// 军需官入驻，则增加3点经验
				if (player.isHeroPut(HeroId.JUN_XU_GUAN)) {
					addExp += staticHeroDataMgr.getStaticHero(HeroId.JUN_XU_GUAN).getSkillValue();
				}

				// 是否经验暴击
				if (RandomHelper.isHitRangeIn10000(staticMedalUp.getBonusExp())) {
					addExp = addExp * 2;
					hitState = 2;
					luckyHit++;
				}
				addMedalExp(medal, staticMedalUp, addExp);
			}

			if (!isActMedalofhonorOpen) {
				if (cdTime < curTime) {// cd已经全部冷却
					player.lord.setMedalUpCdTime(curTime + MedalConst.MEDAL_UP_TIME);
				} else {// 还在冷却中
					player.lord.setMedalUpCdTime(cdTime + MedalConst.MEDAL_UP_TIME);
				}
			}

			// 处理返回给客户端的剩余材料信息
			for (List<Integer> award : staticMedalUp.getCost()) {
				CommonPb.Atom2.Builder builder = playerDataManager
						.subProp(player, award.get(0), award.get(1), award.get(2), AwardFrom.UP_MEDAL).toBuilder();
				if (builderList.size() == 0) {
					builderList.add(builder);
					continue;
				}
				for (int i = 0; i < builderList.size(); i++) {
					CommonPb.Atom2.Builder atom2 = builderList.get(i);
					if (atom2.getKind() == award.get(0) && atom2.getId() == award.get(1)) {
						atom2.setCount(builder.getCount());
						break;
					}
					if (i == builderList.size() - 1) {
						builderList.add(builder);
					}
				}
			}

			if (medal.getUpLv() > oldLv) {
				state = 3;
				break;
			}
		}

		QuickUpMedalRs.Builder builder = QuickUpMedalRs.newBuilder();
		builder.setCdTime(player.lord.getMedalUpCdTime());
		builder.setUpLv(medal.getUpLv());
		builder.setUpExp(medal.getUpExp());
		builder.setLuckyHit(luckyHit);
		builder.setLuckyUp(luckyUp);
		builder.setState(state);

		for (CommonPb.Atom2.Builder atom2 : builderList) {
			builder.addAtom(atom2.build());
		}
		handler.sendMsgToPlayer(QuickUpMedalRs.ext, builder.build());

		if (medal.getUpLv() > oldLv) {
			if (medal.getUpLv() == 20) {
				chatService.sendWorldChat(
						chatService.createSysChat(SysChatId.MEDAL_UP, player.lord.getNick(), String.valueOf(medal.getMedalId()), "20"));
			} else if (medal.getUpLv() == 40) {
				chatService.sendWorldChat(
						chatService.createSysChat(SysChatId.MEDAL_UP, player.lord.getNick(), String.valueOf(medal.getMedalId()), "40"));
			} else if (medal.getUpLv() == 60) {
				chatService.sendWorldChat(
						chatService.createSysChat(SysChatId.MEDAL_UP, player.lord.getNick(), String.valueOf(medal.getMedalId()), "60"));
			} else if (medal.getUpLv() == 80) {
				chatService.sendWorldChat(
						chatService.createSysChat(SysChatId.MEDAL_UP, player.lord.getNick(), String.valueOf(medal.getMedalId()), "80"));
			}
		}

		LogLordHelper.medal(AwardFrom.UP_MEDAL, player.account, player.lord, medal, 2);
	}

	/** 改造勋章 */
	public void refitMedal(RefitMedalRq req, ClientHandler handler) {
		int keyId = req.getKeyId();
		int pos = req.getPos();

		if (pos < 0 || pos > 1) {
			handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
			return;
		}

		Player player = playerDataManager.getPlayer(handler.getRoleId());
		Map<Integer, Medal> map = player.medals.get(pos);
		if (map == null) {
			handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
			return;
		}

		Medal medal = map.get(keyId);
		if (medal == null) {
			handler.sendErrorMsgToPlayer(GameError.NO_MEDAL);
			return;
		}

		if (medal.getRefitLv() >= MedalConst.MAX_MEDAL_REFIT_LV) {
			handler.sendErrorMsgToPlayer(GameError.MAX_MEDAL_REFIT_LV);
			return;
		}

		StaticMedal staticMedal = staticMedalDataMgr.getStaticMedal(medal.getMedalId());
		if (staticMedal == null) {
			handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
			return;
		}

		if (staticMedal.getRefit() != 1) {
			handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
			return;
		}

		StaticMedalRefit staticMedalRefit = staticMedalDataMgr.getStaticMedalRefit(staticMedal.getQuality(), medal.getRefitLv() + 1);
		if (staticMedalRefit == null) {
			handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
			return;
		}

		for (List<Integer> award : staticMedalRefit.getCost()) {
			if (!playerDataManager.checkPropIsEnougth(player, award.get(0), award.get(1), award.get(2))) {
				handler.sendErrorMsgToPlayer(GameError.PROP_NOT_ENOUGH);
				return;
			}
		}

		RefitMedalRs.Builder builder = RefitMedalRs.newBuilder();

		for (List<Integer> award : staticMedalRefit.getCost()) {
			CommonPb.Atom2 atom = playerDataManager.subProp(player, award.get(0), award.get(1), award.get(2), AwardFrom.REFIT_MEDAL);
			builder.addAtom(atom);
		}

		if (pos != 0) {
			playerDataManager.updateFight(player);
			playerEventService.calcStrongestFormAndFight(player);
		}

		medal.setRefitLv(staticMedalRefit.getLv());

		builder.setRefitLv(medal.getRefitLv());
		handler.sendMsgToPlayer(RefitMedalRs.ext, builder.build());

		if (medal.getRefitLv() >= 1) {
			chatService.sendWorldChat(chatService.createSysChat(SysChatId.MEDAL_REFIT, player.lord.getNick(),
					String.valueOf(medal.getMedalId()), medal.getRefitLv() + ""));
		}
		LogLordHelper.medal(AwardFrom.REFIT_MEDAL, player.account, player.lord, medal, 2);
	}

	/** 勋章展示 */
	public void doMedalBouns(DoMedalBounsRq req, ClientHandler handler) {
		int costMedalKeyId = req.getCostMedalKeyId();

		Player player = playerDataManager.getPlayer(handler.getRoleId());

		Map<Integer, Medal> medalStore = player.medals.get(0);
		Medal medal = medalStore.get(costMedalKeyId);
		if (medal == null) {
			handler.sendErrorMsgToPlayer(GameError.NO_MEDAL);
			return;
		}

		if (medal.isLocked()) {
			handler.sendErrorMsgToPlayer(GameError.MEDAL_LOCKED);
			return;
		}

		Map<Integer, MedalBouns> medalBouns0 = player.medalBounss.get(0);
		MedalBouns medalBouns = medalBouns0.get(medal.getMedalId());
		if (medalBouns == null) {
			handler.sendErrorMsgToPlayer(GameError.NO_MEDAL_BOUNS);
			return;
		}

		Map<Integer, MedalBouns> medalBouns1 = player.medalBounss.get(1);
		if (medalBouns1.containsKey(medal.getMedalId())) {
			handler.sendErrorMsgToPlayer(GameError.ALRADY_ON_MEDAL_BOUNS);
			return;
		}

		medalStore.remove(costMedalKeyId);
		LogLordHelper.medal(AwardFrom.DO_MEDAL_BOUNS, player.account, player.lord, medal, 1);

		medalBouns0.remove(medal.getMedalId());
		medalBouns.setState(1);// 已展示激活
		medalBouns1.put(medal.getMedalId(), medalBouns);
		LogLordHelper.medalBouns(AwardFrom.DO_MEDAL_BOUNS, player.account, player.lord, medalBouns);

		rankDataManager.setMedalBounsNum(player);

		DoMedalBounsRs.Builder builder = DoMedalBounsRs.newBuilder();
		handler.sendMsgToPlayer(DoMedalBounsRs.ext, builder.build());

		playerEventService.calcStrongestFormAndFight(player);
	}

	/**
	 * 精炼勋章
	 * 
	 * @param req
	 * @param transMedalHandler
	 */
	public void transMedal(TransMedalRq req, TransMedalHandler handler) {
		if (!staticFunctionPlanDataMgr.isTransMedalOpen())
			return;// 功能未开放

		int keyId = req.getKeyId();
		int pos = req.getPos();

		if (pos < 0 || pos > 1) {
			handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
			return;
		}

		Player player = playerDataManager.getPlayer(handler.getRoleId());
		Map<Integer, Medal> map = player.medals.get(pos);
		if (map == null) {
			handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
			return;
		}

		// 判断是否有此勋章*/
		Medal medal = map.get(keyId);
		if (medal == null) {
			handler.sendErrorMsgToPlayer(GameError.NO_MEDAL);
			return;
		}

		// 判断是否可精炼*/
		StaticMedal staticMedal = staticMedalDataMgr.getStaticMedal(medal.getMedalId());
		if (staticMedal.getTransform() < 1) {
			handler.sendErrorMsgToPlayer(GameError.CANNOT_MEDAL_TRANS);
			return;
		}

		// 材料
		List<List<Integer>> materials = staticMedal.getTransformCost();
		for (List<Integer> list : materials) {
			int type = list.get(0);
			int id = list.get(1);
			int count = list.get(2);
			// 判断材料是否够
			if (!playerDataManager.checkPropIsEnougth(player, type, id, count)) {
				handler.sendErrorMsgToPlayer(GameError.TRANS_NOT_ENOUGH);
				return;
			}
		}

		TransMedalRs.Builder builder = TransMedalRs.newBuilder();

		// 扣资源
		for (List<Integer> list : materials) {
			int type = list.get(0);
			int id = list.get(1);
			int count = list.get(2);
			builder.addAtom2(playerDataManager.subProp(player, type, id, count, AwardFrom.TRANS_MEDAL));
		}

		// 穿戴改变属性
		if (pos == 1) {
			playerDataManager.updateFight(player);
			playerEventService.calcStrongestFormAndFight(player);
		}
		// player.medalBounss.get(0).remove(medal.getMedalId());
		// player.medalBounss.get(1).remove(medal.getMedalId());
		StaticMedal newMedal = staticMedalDataMgr.getStaticMedal(staticMedal.getTransform());
		transLogic(medal, newMedal);
		// 如果新勋章没有展示过 则将其放入未展示列表
		if (player.medalBounss.get(1).get(medal.getMedalId()) == null) {
			player.medalBounss.get(0).put(medal.getMedalId(), new MedalBouns(medal.getMedalId(), 0));
		}
		builder.setMedal(PbHelper.createMedalPb(medal));

		chatService.sendWorldChat(chatService.createSysChat(SysChatId.MEDAL_TRAINS, player.lord.getNick(), staticMedal.getMedalId() + "",
				staticMedal.getTransform() + ""));
		handler.sendMsgToPlayer(TransMedalRs.ext, builder.build());
	}

	/**
	 * 精炼逻辑
	 * 
	 * @param req
	 * @param transMedalHandler
	 */
	public void transLogic(Medal pMedal, StaticMedal staticMedal) {
		pMedal.setMedalId(staticMedal.getMedalId());

	}
}
