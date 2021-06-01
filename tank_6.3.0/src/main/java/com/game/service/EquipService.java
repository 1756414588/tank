/**   
 * @Title: EquipService.java    
 * @Package com.game.service    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年8月18日 下午2:42:27    
 * @version V1.0   
 */
package com.game.service;

import com.game.actor.role.PlayerEventService;
import com.game.constant.*;
import com.game.dataMgr.StaticActivityDataMgr;
import com.game.dataMgr.StaticEquipDataMgr;
import com.game.domain.ActivityBase;
import com.game.domain.Player;
import com.game.domain.p.Equip;
import com.game.domain.p.Lord;
import com.game.domain.s.StaticEquip;
import com.game.domain.s.StaticEquipLv;
import com.game.domain.s.StaticEquipUpStar;
import com.game.manager.ActivityDataManager;
import com.game.manager.PlayerDataManager;
import com.game.manager.RankDataManager;
import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb1.*;
import com.game.pb.GamePb5.EquipQualityUpRq;
import com.game.pb.GamePb5.EquipQualityUpRs;
import com.game.pb.GamePb6;
import com.game.util.LogLordHelper;
import com.game.util.PbHelper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.*;

/**
 * @ClassName: EquipService
 * @Description: 装备
 * @author ZhangJun
 * @date 2015年8月18日 下午2:42:27
 * 
 */

@Service
public class EquipService {
	@Autowired
	private PlayerDataManager playerDataManager;

	@Autowired
	private ActivityDataManager activityDataManager;

	@Autowired
	private StaticEquipDataMgr staticEquipDataMgr;

	@Autowired
	private ChatService chatService;

	@Autowired
	private EnergyStoneService energyStoneService;

	@Autowired
	private RankDataManager rankDataManager;

	@Autowired
	private PlayerEventService playerEventService;

	@Autowired
	private RewardService rewardService;
	
	@Autowired
	private StaticActivityDataMgr staticActivityDataMgr;
	
	

	/**
	 * 
	 * Method: getEquip
	 * 
	 * @Description: 客户端获取装备数据
	 * @param handler
	 * @return void
	 * 
	 */
	public void getEquip(ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		GetEquipRs.Builder builder = GetEquipRs.newBuilder();
		for (int i = 0; i < 7; i++) {
			Map<Integer, Equip> equipMap = player.equips.get(i);
			Iterator<Equip> it = equipMap.values().iterator();
			while (it.hasNext()) {
				builder.addEquip(PbHelper.createEquipPb(it.next()));
			}
		}
		handler.sendMsgToPlayer(GetEquipRs.ext, builder.build());
	}

	/**
	 * 
	 * Method: sellEquip
	 * 
	 * @Description: 出售装备
	 * @param req
	 * @param handler
	 * @return void
	 * 
	 */
	public void sellEquip(SellEquipRq req, ClientHandler handler) {
		List<Integer> list = req.getKeyIdList();
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		Map<Integer, Equip> store = player.equips.get(0);

		if (list.isEmpty()) {
			handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
			return;
		}

		for (Integer keyId : list) {
			if (!store.containsKey(keyId)) {
				handler.sendErrorMsgToPlayer(GameError.NO_EQUIP);
				return;
			}
		}

		int stoneAdd = 0;
		for (Integer keyId : list) {
			Equip equip = store.get(keyId);
			StaticEquip staticEquip = staticEquipDataMgr.getStaticEquip(equip.getEquipId());
			if (staticEquip == null) {
				continue;
			}

			store.remove(keyId);
			stoneAdd += staticEquip.getPrice();
			LogLordHelper.equip(AwardFrom.SELL_EQUIP, player.account, player.lord, keyId, equip.getEquipId(),
					equip.getLv(), 0);
		}

		playerDataManager.modifyStone(player, stoneAdd, AwardFrom.SELL_EQUIP);

		SellEquipRs.Builder builder = SellEquipRs.newBuilder();
		builder.setStone(player.resource.getStone());
		handler.sendMsgToPlayer(SellEquipRs.ext, builder.build());
	}

	/**
	 * 
	 * Method: upEquip
	 * 
	 * @Description: 玩家升级装备
	 * @param req
	 * @param handler
	 * @return void
	 * 
	 */
	public void upEquip(UpEquipRq req, ClientHandler handler) {
		int keyId = req.getKeyId();
		int pos = req.getPos();
		if (pos < 0 || pos > 6) {
			handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
			return;
		}

		Player player = playerDataManager.getPlayer(handler.getRoleId());
		Lord lord = player.lord;
		Map<Integer, Equip> equips = player.equips.get(pos);

		Equip to = equips.get(keyId);
		if (to == null) {
			handler.sendErrorMsgToPlayer(GameError.NO_EQUIP);
			return;
		}

		if (to.getLv() >= Constant.EQUIP_OPEN_LV) {
			handler.sendErrorMsgToPlayer(GameError.MAX_EQUIP_LV);
			return;
		}

		if (to.getLv() >= player.lord.getLevel()) {
			handler.sendErrorMsgToPlayer(GameError.LV_NOT_ENOUGH);
			return;
		}

		if (to.getEquipId() >= 701) {
			handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
			return;
		}

		StaticEquip staticToEquip = staticEquipDataMgr.getStaticEquip(to.getEquipId());
		if (staticToEquip == null) {
			handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
			return;
		}

		List<Integer> from = req.getFromList();
		List<Equip> list = new ArrayList<>();
		Map<Integer, Equip> store = player.equips.get(0);
		boolean find = true;
		for (Integer key : from) {
			Equip equip = store.get(key);
			if (equip == null) {
				find = false;
				break;
			}
			list.add(equip);
		}

		if (!find) {
			handler.sendErrorMsgToPlayer(GameError.NO_EQUIP);
			return;
		}

		int addExp = 0;
		int cardExp = 0;
		for (Equip equip : list) {
			StaticEquip staticEquip = staticEquipDataMgr.getStaticEquip(equip.getEquipId());
			if (equip.getEquipId() < 701) {
				StaticEquipLv staticEquipLv = staticEquipDataMgr.getStaticEquipLv(staticEquip.getQuality(),
						equip.getLv());
				addExp += staticEquipLv.getGiveExp();
			} else {
				cardExp += staticEquip.getA();
			}
			LogLordHelper.equip(AwardFrom.EAT_EQUIP, player.account, lord, equip.getKeyId(), equip.getEquipId(),
					equip.getLv(), keyId);
			store.remove(equip.getKeyId());
		}

		cardExp = activityDataManager.upEquipExp(cardExp);
		addExp += cardExp;

		int lv = to.getLv();
		if (staticEquipDataMgr.addEquipExp(player.lord.getLevel(), to, addExp) && pos != 0) {
			playerDataManager.updateFight(player);
		}

		playerDataManager.updTask(player, TaskType.COND_EQUIP_LV_UP, 1);
		
		// 紫装升级活动
		ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_PURPLE_UP);
		if (lv != to.getLv() && activityBase != null) {
			activityDataManager.purpleEquipUp(player, staticToEquip, lv, to.getLv());

			if (staticToEquip.getQuality() == 4 && (lv != to.getLv())) {
				if (to.getLv() == 20) {
					chatService.sendWorldChat(chatService.createSysChat(SysChatId.PURPLE_EQUIP, player.lord.getNick(),
							String.valueOf(staticToEquip.getEquipId()), "20"));
				} else if (to.getLv() == 40) {
					chatService.sendWorldChat(chatService.createSysChat(SysChatId.PURPLE_EQUIP, player.lord.getNick(),
							String.valueOf(staticToEquip.getEquipId()), "40"));
				} else if (to.getLv() == 60) {
					chatService.sendWorldChat(chatService.createSysChat(SysChatId.PURPLE_EQUIP, player.lord.getNick(),
							String.valueOf(staticToEquip.getEquipId()), "60"));
				} else if (to.getLv() == 80) {
					chatService.sendWorldChat(chatService.createSysChat(SysChatId.PURPLE_EQUIP, player.lord.getNick(),
							String.valueOf(staticToEquip.getEquipId()), "80"));
				}
			}
		}

		playerDataManager.updDay7ActSchedule(player, 4);

		UpEquipRs.Builder builder = UpEquipRs.newBuilder();
		builder.setLv(to.getLv());
		builder.setExp(to.getExp());
		handler.sendMsgToPlayer(UpEquipRs.ext, builder.build());


		// 玩家升级身上已经穿戴的装备后,重新计算最强实力
		if (pos > 0 && lv != to.getLv()) {
			playerEventService.calcStrongestFormAndFight(player);
		}
	}

	/**
	 * 装备升星
	 * 
	 * @param req
	 * @param handler
	 */
	public void upEquipStarLv(GamePb6.UpEquipStarLvRq req, ClientHandler handler) {
		int keyId = req.getKeyId();
		int pos = req.getPos();

		if (pos < 0 || pos > 6) {
			handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
			return;
		}

		Player player = playerDataManager.getPlayer(handler.getRoleId());
		Map<Integer, Equip> equips = player.equips.get(pos);

		Equip to = equips.get(keyId);
		if (to == null) {
			handler.sendErrorMsgToPlayer(GameError.NO_EQUIP);
			return;
		}

		StaticEquip staticEquip = staticEquipDataMgr.getStaticEquip(to.getEquipId());

		if (staticEquip.getQuality() != 5) {
			handler.sendErrorMsgToPlayer(GameError.NO_EQUIP);
			return;
		}

		StaticEquipUpStar config = staticEquipDataMgr.getEquipStar(to.getStarlv());
		if (config == null) {
			handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
			return;
		}

		if (!rewardService.checkItem(player, config.getNeed())) {
			handler.sendErrorMsgToPlayer(GameError.PROP_NOT_ENOUGH);
			return;
		}

		List<Integer> needEquip = getNeedEquip(player, to.getEquipId(), config.getNeedEquip());
		if (needEquip.size() == 0) {
			handler.sendErrorMsgToPlayer(GameError.PROP_NOT_ENOUGH);
			return;
		}
		GamePb6.UpEquipStarLvRs.Builder builder = GamePb6.UpEquipStarLvRs.newBuilder();

		for (Integer e : needEquip) {
			player.equips.get(0).remove(e);
			builder.addNeedKeyId(e);
		}

		rewardService.decrItem(player, AwardFrom.EQUIP_STAR_LV, config.getNeed());
		to.setStarlv(to.getStarlv() + 1);

		for (List<Integer> it : config.getNeed()) {
			int type = it.get(0);
			int itemId = it.get(1);
			int count = it.get(2);
			builder.addAward(PbHelper.createAwardPb(type, itemId, count));
		}
		builder.setEquip(PbHelper.createEquipPb(to));

		handler.sendMsgToPlayer(GamePb6.UpEquipStarLvRs.ext, builder.build());
		
		String msg = to.getEquipId() + ":" + to.getLv()+ ":" + to.getStarlv() ;
		
		chatService.sendHornChat(
				chatService.createSysChat(SysChatId.EQUIP_UPSTAR, player.lord.getNick(), msg), 1);
	}

	private List<Integer> getNeedEquip(Player player, int equipId, int count) {

		List<Integer> result = new ArrayList<>();

		Map<Integer, Equip> equipMap = player.equips.get(0);
		if (equipMap == null) {
			return result;
		}

		if (equipMap.size() < count) {
			return result;
		}

		List<Equip> list = new ArrayList<>();
		for (Equip e : equipMap.values()) {
			if (e.getEquipId() == (equipId - 1)) {
				list.add(e);
			}
		}

		if (list.size() < count) {
			return result;
		}

		Collections.sort(list, new Comparator<Equip>() {
			@Override
			public int compare(Equip o1, Equip o2) {

				if (o1.getLv() > o2.getLv()) {
					return 1;
				}

				if (o1.getLv() < o2.getLv()) {
					return -1;
				}

				return 0;
			}
		});

		List<Equip> list1 = list.subList(0, count);
		for (Equip e : list1) {
			result.add(e.getKeyId());
		}
		return result;
	}

	/**
	 * 
	 * Method: onEquip
	 * 
	 * @Description: 穿戴装备
	 * @param req
	 * @param handler
	 * @return void
	 * 
	 */
	public void onEquip(OnEquipRq req, ClientHandler handler) {
		int from = req.getFrom();
		int fromPos = req.getFromPos();
		int toPos = req.getToPos();
		int to = 0;
		if (req.hasTo()) {
			to = req.getTo();
		}

		if (fromPos < 0 || fromPos > 6) {
			handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
			return;
		}

		if (toPos < 0 || toPos > 6) {
			handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
			return;
		}

		if (toPos == 0) {// 卸下
			offEquip(from, fromPos, handler);
		} else if ((to != 0) && (from != 0)) {// 单个替换
			replaceEquip(from, fromPos, to, toPos, handler);
		} else if (to == 0 && from == 0) {// 部队互换
			exchangeEquip(fromPos, toPos, handler);
		} else {// 装备到空位子
			onEquip(from, fromPos, toPos, handler);
		}
		// 玩家身上装备发生变化，重新计算最强实力
		playerEventService.calcStrongestFormAndFight(playerDataManager.getPlayer(handler.getRoleId()));
	}

	/**
	 * 
	 * Method: allEquip
	 * 
	 * @Description: 一键装备、卸下
	 * @param req
	 * @param handler
	 * @return void
	 * 
	 */
	public void allEquip(AllEquipRq req, ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		Map<Integer, Equip> store = player.equips.get(0);
		List<Integer> onList = req.getOnList();
		List<Integer> offList = req.getOffList();
		int pos = req.getPos();
		if (pos < 0 || pos > 6 || onList.size() > 6) {
			handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
			return;
		}

		int storeCount = offList.size() - onList.size();
		if (storeCount > player.lord.getEquip() - store.size()) {
			handler.sendErrorMsgToPlayer(GameError.MAX_EQUIP_STORE);
			return;
		}

		Set<Integer> set = new HashSet<>();
		for (Integer on : onList) {
			Equip equip = store.get(on);
			if (equip == null) {
				handler.sendErrorMsgToPlayer(GameError.NO_EQUIP);
				return;
			}

			int index = equip.getEquipId() / 100;
			if (set.contains(index) || index == 7) {
				handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
				return;
			}

			set.add(index);
		}

		Map<Integer, Equip> slot = player.equips.get(pos);
		for (Integer off : offList) {
			if (!slot.containsKey(off)) {
				handler.sendErrorMsgToPlayer(GameError.NO_EQUIP);
				return;
			}
		}

		for (Integer off : offList) {
			Equip equip = slot.get(off);
			slot.remove(off);
			equip.setPos(0);
			store.put(off, equip);
		}

		for (Integer on : onList) {
			Equip equip = store.get(on);
			store.remove(on);
			equip.setPos(pos);
			slot.put(on, equip);
		}

		playerDataManager.updateFight(player);

		AllEquipRs.Builder builder = AllEquipRs.newBuilder();
		handler.sendMsgToPlayer(AllEquipRs.ext, builder.build());

		// 更新最强实力
		playerEventService.calcStrongestFormAndFight(player);
	}

	/**
	 * 
	 * Method: onEquip
	 * 
	 * @Description: 穿戴装备
	 * @param keyId
	 * @param pos
	 * @param handler
	 * @return void
	 * 
	 */
	private void onEquip(int from, int fromPos, int toPos, ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		// Map<Integer, Equip> store = player.equips.get(0);
		Map<Integer, Equip> fromSlot = player.equips.get(fromPos);
		Map<Integer, Equip> toSlot = player.equips.get(toPos);
		if (toSlot.size() == 6) {
			handler.sendErrorMsgToPlayer(GameError.FULL_EQUIP_ON);
			return;
		}

		Equip equip = fromSlot.get(from);
		if (equip == null) {
			handler.sendErrorMsgToPlayer(GameError.NO_EQUIP);
			return;
		}

		StaticEquip staticEquip = staticEquipDataMgr.getStaticEquip(equip.getEquipId());
		if (staticEquip == null) {
			handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
			return;
		}

		int index = equip.getEquipId() / 100;
		if (index == 7) {
			handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
			return;
		}

		Iterator<Equip> it = toSlot.values().iterator();
		while (it.hasNext()) {
			Equip e = it.next();
			if ((e.getEquipId() / 100) == index) {
				handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
				return;
			}
		}

		fromSlot.remove(equip.getKeyId());
		equip.setPos(toPos);
		toSlot.put(equip.getKeyId(), equip);

		playerDataManager.updateFight(player);

		OnEquipRs.Builder builder = OnEquipRs.newBuilder();
		handler.sendMsgToPlayer(OnEquipRs.ext, builder.build());
	}

	/**
	 * 
	 * Method: replaceEquip
	 * 
	 * @Description: 替换装备
	 * @param from
	 * @param fromPos
	 * @param to
	 * @param toPos
	 * @param handler
	 * @return void
	 * 
	 */
	private void replaceEquip(int from, int fromPos, int to, int toPos, ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		// Map<Integer, Equip> store = player.equips.get(0);
		Map<Integer, Equip> fromSlot = player.equips.get(fromPos);
		Map<Integer, Equip> toSlot = player.equips.get(toPos);
		if (fromPos == 0 || fromPos == toPos) {
			handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
			return;
		}

		Equip fromEquip = fromSlot.get(from);
		if (fromEquip == null) {
			handler.sendErrorMsgToPlayer(GameError.NO_EQUIP);
			return;
		}

		StaticEquip staticFrom = staticEquipDataMgr.getStaticEquip(fromEquip.getEquipId());
		if (staticFrom == null) {
			handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
			return;
		}

		Equip toEquip = toSlot.get(to);
		if (toEquip == null) {
			handler.sendErrorMsgToPlayer(GameError.NO_EQUIP);
			return;
		}

		StaticEquip staticTo = staticEquipDataMgr.getStaticEquip(toEquip.getEquipId());
		if (staticTo == null) {
			handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
			return;
		}

		if (staticTo.getAttributeId() != staticFrom.getAttributeId()) {
			handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
			return;
		}

		toSlot.remove(toEquip.getKeyId());
		toEquip.setPos(fromPos);
		fromSlot.put(toEquip.getKeyId(), toEquip);

		fromSlot.remove(fromEquip.getKeyId());
		fromEquip.setPos(toPos);
		toSlot.put(fromEquip.getKeyId(), fromEquip);

		playerDataManager.updateFight(player);

		OnEquipRs.Builder builder = OnEquipRs.newBuilder();
		handler.sendMsgToPlayer(OnEquipRs.ext, builder.build());
	}

	/**
	 * 
	 * Method: exchangeEquip
	 * 
	 * @Description: 互换部队装备
	 * @param fromPos
	 * @param toPos
	 * @param handler
	 * @return void
	 * 
	 */
	private void exchangeEquip(int fromPos, int toPos, ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		Map<Integer, Equip> fromSlot = player.equips.get(fromPos);
		Map<Integer, Equip> toSlot = player.equips.get(toPos);
		if (fromPos == 0 || fromPos == toPos) {
			handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
			return;
		}

		Map<Integer, Equip> fromMap = new HashMap<Integer, Equip>();
		fromMap.putAll(fromSlot);

		Map<Integer, Equip> toMap = new HashMap<Integer, Equip>();
		toMap.putAll(toSlot);

		Iterator<Equip> fromIt = fromSlot.values().iterator();
		while (fromIt.hasNext()) {
			Equip equip = (Equip) fromIt.next();
			equip.setPos(toPos);
			fromIt.remove();
		}

		Iterator<Equip> toIt = toSlot.values().iterator();
		while (toIt.hasNext()) {
			Equip equip = (Equip) toIt.next();
			equip.setPos(fromPos);
			toIt.remove();
		}

		toSlot.putAll(fromMap);
		fromSlot.putAll(toMap);

		playerDataManager.updateFight(player);

		// 交换镶嵌的能晶信息
		energyStoneService.exchangeEnergyInlay(fromPos, toPos, player);

		OnEquipRs.Builder builder = OnEquipRs.newBuilder();
		handler.sendMsgToPlayer(OnEquipRs.ext, builder.build());
	}

	/**
	 * 
	 * Method: offEquip
	 * 
	 * @Description: 卸下装备
	 * @param keyId
	 * @param handler
	 * @return void
	 * 
	 */
	private void offEquip(int keyId, int pos, ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		Map<Integer, Equip> store = player.equips.get(0);
		Map<Integer, Equip> slot = player.equips.get(pos);
		Equip equip = slot.get(keyId);
		if (equip == null || equip.getPos() == 0) {
			handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
			return;
		}

		if (store.size() >= player.lord.getEquip()) {
			handler.sendErrorMsgToPlayer(GameError.MAX_EQUIP_STORE);
			return;
		}

		slot.remove(keyId);
		equip.setPos(0);
		store.put(keyId, equip);

		playerDataManager.updateFight(player);

		OnEquipRs.Builder builder = OnEquipRs.newBuilder();
		handler.sendMsgToPlayer(OnEquipRs.ext, builder.build());
	}

	private static final int[] UP_CAPACITY_COST = { 10, 10, 20, 20, 30, 30, 40, 40, 50, 50 };

	/**
	 * 
	 * Method: upCapacity
	 * 
	 * @Description: 增加装备仓库容量
	 * @param handler
	 * @return void
	 * 
	 */
	public void upCapacity(ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		Lord lord = player.lord;
		if (lord.getEquip() >= PlayerDataManager.EQUIP_STORE_LIMIT) {
			handler.sendErrorMsgToPlayer(GameError.EQUIP_STORE_LIMIT);
			return;
		}

		int cost = UP_CAPACITY_COST[(lord.getEquip() - 100) / 20];
		if (lord.getGold() < cost) {
			handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
			return;
		}
		playerDataManager.addEquipCapacity(player, cost, 20);
		UpCapacityRs.Builder builder = UpCapacityRs.newBuilder();
		builder.setGold(lord.getGold());
		handler.sendMsgToPlayer(UpCapacityRs.ext, builder.build());
	}

	/** 装备进阶 */
	public void equipQualityUp(EquipQualityUpRq req, ClientHandler handler) {
		int keyId = req.getKeyId();
		int pos = req.getPos();

		Player player = playerDataManager.getPlayer(handler.getRoleId());
		Map<Integer, Equip> store = player.equips.get(pos);
		if (store == null || store.size() == 0) {
			handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
			return;
		}

		Equip equip = store.get(keyId);
		if (equip == null) {
			handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
			return;
		}

		StaticEquip staticEquip = staticEquipDataMgr.getStaticEquip(equip.getEquipId());
		if (staticEquip.getTransform() <= 0) {
			handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
			return;
		}

		StaticEquip staticNewEquip = staticEquipDataMgr.getStaticEquip(staticEquip.getTransform());
		if (staticNewEquip == null) {
			handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
			return;
		}

		List<List<Integer>> costlist = staticEquip.getCost();
		for (List<Integer> list : costlist) {
			if (!playerDataManager.checkPropIsEnougth(player, list.get(0), list.get(1), list.get(2))) {
				handler.sendErrorMsgToPlayer(GameError.PROP_NOT_ENOUGH);
				return;
			}
		}

		EquipQualityUpRs.Builder builder = EquipQualityUpRs.newBuilder();
		// 进阶
		for (List<Integer> list2 : costlist) {
			builder.addAtom2(playerDataManager.subProp(player, list2.get(0), list2.get(1), list2.get(2),
					AwardFrom.UP_PART_QUALITY));
		}

		int exp = staticEquipDataMgr.getEquipExpTotal(equip, staticEquip.getQuality());
		equip.setEquipId(staticNewEquip.getEquipId());
		equip.setExp(0);
		equip.setLv(1);
		staticEquipDataMgr.addEquipExp(player.lord.getLevel(), equip, exp);

		int index = equip.getEquipId() / 100;
		if (index == 1) {
			rankDataManager.setAttack(player.lord, equip);
		} else if (index == 4) {
			rankDataManager.setDodge(player.lord, equip);
		} else if (index == 5) {
			rankDataManager.setCrit(player.lord, equip);
		}

		builder.setEquipId(equip.getEquipId());
		builder.setLv(equip.getLv());
		builder.setExp(equip.getExp());

		handler.sendMsgToPlayer(EquipQualityUpRs.ext, builder.build());

		chatService.sendWorldChat(chatService.createSysChat(SysChatId.Equip_Quality_Up, player.lord.getNick(),
				String.valueOf(staticEquip.getEquipId()), String.valueOf(staticNewEquip.getEquipId())));

		LogLordHelper.equip(AwardFrom.EQUIP_QUALITY_UP, player.account, player.lord, equip.getKeyId(),
				equip.getEquipId(), equip.getLv(), keyId);

		// 重新计算最强实力
		playerEventService.calcStrongestFormAndFight(player);
	}
}
