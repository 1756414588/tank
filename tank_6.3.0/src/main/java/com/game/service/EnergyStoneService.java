package com.game.service;

import com.game.actor.role.PlayerEventService;
import com.game.constant.AwardFrom;
import com.game.constant.GameError;
import com.game.constant.SysChatId;
import com.game.dataMgr.StaticEnergyStoneDataMgr;
import com.game.domain.Player;
import com.game.domain.p.EnergyStoneInlay;
import com.game.domain.p.Prop;
import com.game.domain.s.StaticEnergyStone;
import com.game.manager.PlayerDataManager;
import com.game.message.handler.ClientHandler;
import com.game.pb.CommonPb.TwoInt;
import com.game.pb.GamePb4.*;
import com.game.pb.GamePb5.AllEnergyStoneRq;
import com.game.pb.GamePb5.AllEnergyStoneRs;
import com.game.util.CheckNull;
import com.game.util.PbHelper;
import com.game.util.RandomHelper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.Map.Entry;

/**
 * @ClassName EnergyStoneService
 * @Description 能晶系统相关操作服务类
 *              <p>
 *              玩家对能晶的操作包括合成、镶嵌、卸下镶嵌，能晶的镶嵌对象为玩家部队装备的出战部位
 * 
 * @author TanDonghai
 * @date 创建时间：2016年7月12日 下午1:48:26
 *
 */
@Service
public class EnergyStoneService {
	@Autowired
	private PlayerDataManager playerDataManager;

	@Autowired
	private StaticEnergyStoneDataMgr staticEnergyStoneDataMgr;

	@Autowired
	private ChatService chatService;

	@Autowired
	private PlayerEventService playerEventService;

	/**
	 * 获取能晶仓库信息
	 * 
	 * @param handler
	 */
	public void getRoleEnergyStone(ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		GetRoleEnergyStoneRs.Builder builder = GetRoleEnergyStoneRs.newBuilder();

		// 遍历能晶仓库，返回所有能晶数量
		for (Prop prop : player.energyStone.values()) {
			builder.addProp(PbHelper.createPropPb(prop));
		}
		handler.sendMsgToPlayer(GetRoleEnergyStoneRs.ext, builder.build());
	}

	/**
	 * 获取能晶镶嵌信息
	 * 
	 * @param handler
	 */
	public void getEnergyStoneInlay(ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		GetEnergyStoneInlayRs.Builder builder = GetEnergyStoneInlayRs.newBuilder();

		// 遍历六个出战部位对应的镶嵌信息，返回
		for (int pos = 1; pos <= 6; pos++) {
			Map<Integer, EnergyStoneInlay> stoneMap = player.energyInlay.get(pos);
			if (!CheckNull.isEmpty(stoneMap)) {
				for (EnergyStoneInlay inlay : stoneMap.values()) {
					builder.addInlay(PbHelper.createEnergyStoneInlayPb(inlay));
				}
			}
		}
		handler.sendMsgToPlayer(GetEnergyStoneInlayRs.ext, builder.build());
	}

	/**
	 * 合成能晶
	 * 
	 * @param req
	 * @param handler
	 */
	public void combineEnergyStone(CombineEnergyStoneRq req, ClientHandler handler) {
		int count = req.getCount();
		if (count < 1 || count > 3) {
			handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);// 单次合成，最少1个，最多3个
			return;
		}

		int stoneId = req.getStoneId();
		StaticEnergyStone stone = staticEnergyStoneDataMgr.getEnergyStoneById(stoneId);
		if (null == stone) {
			handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);// 能晶id未配置
			return;
		}

		Player player = playerDataManager.getPlayer(handler.getRoleId());
		Prop prop = player.energyStone.get(stoneId);
		if (null == prop || prop.getCount() < count) {
			handler.sendErrorMsgToPlayer(GameError.ENERGY_STONE_NOT_ENOUGH);// 玩家没有足够的能晶
			return;
		}

		if (stone.getSynthesizing() <= 0) {
			handler.sendErrorMsgToPlayer(GameError.ENERGY_STONE_MAX_LEVEL);// 能晶已达到最高等级
			return;
		}

		int num = 1;// 记录需要合成的次数
		if (req.getBatch()) {
			num = prop.getCount() / count;
		}

		int successNum = num;// 记录合成成功的次数
		if (count < 3) {// 单次3个必然成功，所以只有单次小于3个的合成才会出现失败
			int rate = COMBINE_RATE[count];// 合成成功的几率
			for (int i = 0; i < num; i++) {
				int random = RandomHelper.randomInSize(100);
				if (random > rate) {
					successNum--;// 随机到的数如果大于概率百分比的数，即视为失败，成功次数减1
				}
			}
		}

		// 扣除材料和失败损失的能晶
		int failNum = num - successNum;
		int totalCost = failNum + successNum * count;// 消耗的数量=失败损失的+成功需要扣除的
		playerDataManager.subEnergyStone(player, stoneId, totalCost, AwardFrom.ENERGY_STONE_COMBINE);

		// 增加合成成功的下一级能晶
		playerDataManager.addEnergyStone(player, stone.getSynthesizing(), successNum, AwardFrom.ENERGY_STONE_COMBINE);

		CombineEnergyStoneRs.Builder builder = CombineEnergyStoneRs.newBuilder();
		builder.setSuccessNum(successNum);
		handler.sendMsgToPlayer(CombineEnergyStoneRs.ext, builder.build());

		// 合成的能晶等级达到6级及以上，广播
		if (successNum > 0 && stone.getLevel() >= 5) {
			chatService.sendWorldChat(chatService.createSysChat(SysChatId.Energy_Stone_Combine, player.lord.getNick(),
					String.valueOf(stone.getSynthesizing()), String.valueOf(stone.getLevel() + 1)));
		}
	}

	// 能晶合成的成功率百分比，-1为补位数值，1=33%（实际概率20%），2=66%（实际概率40%），3=100%
	private final static int[] COMBINE_RATE = { -1, 20, 40, 100 };


	private int getHoleNeedLv(int pos){
		switch (pos) {
		case 1:
		case 2:
		case 3:
			return 55;
		case 4:
			return 60;
		case 5:
			return 65;
		case 6:
			return 70;
		}
		return 70;
	}
	/**
	 * 镶嵌、卸下能晶
	 * 
	 * @param req
	 * @param handler
	 */
	public void onEnergyStone(OnEnergyStoneRq req, ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());

		int pos = req.getPos();
		int hole = req.getHole();
		if (pos < 1 || pos > 6) {
			handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);// 出战部位在1-6之间
			return;
		}

		if (hole < 1 || hole > 6) {
			handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);// 目前镶嵌孔在1-6之间
			return;
		}
		
		if(player.lord.getLevel() < getHoleNeedLv(hole)){
			handler.sendErrorMsgToPlayer(GameError.LV_NOT_ENOUGH);//孔需要角色等级
			return;
		}

		int stoneId = req.getStoneId();
		Map<Integer, EnergyStoneInlay> stoneMap = player.energyInlay.get(pos);
		if (null == stoneMap) {
			stoneMap = new HashMap<Integer, EnergyStoneInlay>();
			player.energyInlay.put(pos, stoneMap);
		}
		EnergyStoneInlay inlay = stoneMap.get(hole);
		if (null == inlay) {
			inlay = new EnergyStoneInlay(pos, hole, -1);
			stoneMap.put(hole, inlay);
		}
		if (stoneId != -1) {// 镶嵌操作
			if (inlay.getStoneId() > 0) {
				handler.sendErrorMsgToPlayer(GameError.ENERGY_STONE_INLAYED);// 镶嵌孔已经镶嵌有能晶
				return;
			}

			StaticEnergyStone stone = staticEnergyStoneDataMgr.getEnergyStoneById(stoneId);
			if (null == stone) {
				handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);// 能晶id未配置
				return;
			}
			
			//14 25 36 红 蓝 黄            getHoleType 1 2 3
			int holeType = (hole > 3) ? hole - 3 : hole;
			if (stone.getHoleType() != holeType) {
				handler.sendErrorMsgToPlayer(GameError.ENERGY_STONE_HOLE_ERROR);// 镶嵌孔类型不匹配
				return;
			}

			Prop prop = player.energyStone.get(stoneId);
			if (null == prop || prop.getCount() < 1) {
				handler.sendErrorMsgToPlayer(GameError.ENERGY_STONE_NOT_ENOUGH);// 玩家没有足够的能晶
				return;
			}
			
			//验证不能出现重复类型能晶
			int type = stoneId / 100;
			for (EnergyStoneInlay energyStone : stoneMap.values()) {
				if(energyStone.getStoneId() > 0 && (energyStone.getStoneId() / 100) == type){
					handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);//出现同类型能晶镶嵌
					return;
				}
			}
			
			// 扣除能晶
			playerDataManager.subEnergyStone(player, stoneId, 1, AwardFrom.ENERGY_STONE_EQUIP);

			// 镶嵌
			inlay.setStoneId(stoneId);
		} else {// 卸下镶嵌操作
			if (inlay.getStoneId() <= 0) {
				handler.sendErrorMsgToPlayer(GameError.ENERGY_STONE_NOT_INLAY);// 镶嵌孔还未镶嵌
				return;
			}

			stoneId = inlay.getStoneId();
			// 卸下能晶
			inlay.setStoneId(0);

			// 增加玩家的能晶
			playerDataManager.addEnergyStone(player, stoneId, 1, AwardFrom.ENERGY_STONE_EQUIP);
		}

		OnEnergyStoneRs.Builder builder = OnEnergyStoneRs.newBuilder();
		handler.sendMsgToPlayer(OnEnergyStoneRs.ext, builder.build());

        playerEventService.calcStrongestFormAndFight(player);
	}

	/**
	 * 交换装备阵型时更新镶嵌信息
	 * 
	 * @param fromPos
	 * @param toPos
	 * @param player
	 */
	public void exchangeEnergyInlay(int fromPos, int toPos, Player player) {
		if (fromPos == 0 || toPos == 0 || fromPos == toPos) {
			return;
		}

		Map<Integer, EnergyStoneInlay> fromMap = player.energyInlay.get(fromPos);
		Map<Integer, EnergyStoneInlay> toMap = player.energyInlay.get(toPos);
		if (!CheckNull.isEmpty(fromMap)) {
			for (EnergyStoneInlay inlay : fromMap.values()) {
				if (null != inlay) {
					inlay.setPos(toPos);// 更新部位信息
				}
			}
		}
		if (!CheckNull.isEmpty(toMap)) {
			for (EnergyStoneInlay inlay : toMap.values()) {
				if (null != inlay) {
					inlay.setPos(fromPos);// 更新部位信息
				}
			}
		}
		player.energyInlay.put(fromPos, toMap);
		player.energyInlay.put(toPos, fromMap);
	}
	
	/** 一键镶嵌  */
	public void allEnergyStone(AllEnergyStoneRq req, ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());

		int pos = req.getPos();
		List<TwoInt> holeAndStoneIds = req.getHoleAndStoneIdList();
		
		if(holeAndStoneIds.size() == 0){
			handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);// 没有能晶数据
			return;
		}
		
		if (pos < 1 || pos > 6) {
			handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);// 出战部位在1-6之间
			return;
		}
		Map<Integer, EnergyStoneInlay> stoneMap = player.energyInlay.get(pos);
		if (null == stoneMap) {
			stoneMap = new HashMap<Integer, EnergyStoneInlay>();
			player.energyInlay.put(pos, stoneMap);
		}
		
		Set<Integer> typeSet = new HashSet<>();//准备镶嵌的能晶类型集合
		Map<Integer, Integer> holeAndStoneIdMap = new HashMap<>();
		
		for (TwoInt twoInt : holeAndStoneIds) {
			int hole = twoInt.getV1();
			int stoneId = twoInt.getV2();
			
			if (hole < 1 || hole > 6) {
				handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);// 目前镶嵌孔在1-6之间
				return;
			}
			
			if(player.lord.getLevel() < getHoleNeedLv(hole)){
				handler.sendErrorMsgToPlayer(GameError.LV_NOT_ENOUGH);//孔需要角色等级
				return;
			}
			
			EnergyStoneInlay inlay = stoneMap.get(hole);
			if (null == inlay) {
				inlay = new EnergyStoneInlay(pos, hole, -1);
				stoneMap.put(hole, inlay);
			}
			
			if(stoneId > 0){
				StaticEnergyStone stone = staticEnergyStoneDataMgr.getEnergyStoneById(stoneId);
				if (null == stone) {
					handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);// 能晶id未配置
					return;
				}
				
				//14 25 36 红 蓝 黄            getHoleType 1 2 3
				int holeType = (hole > 3) ? hole - 3 : hole;
				if (stone.getHoleType() != holeType) {
					handler.sendErrorMsgToPlayer(GameError.ENERGY_STONE_HOLE_ERROR);// 镶嵌孔类型不匹配
					return;
				}
				
				int type = stoneId / 100;
				if(typeSet.contains(type)){
					handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);//出现同类型能晶镶嵌
					return;
				}
				typeSet.add(type);
			}
			
			if(holeAndStoneIdMap.containsKey(hole)){
				handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);//同一个位置发送多次
				return;
			}
			holeAndStoneIdMap.put(hole, stoneId);
		}
		
		//准备卸下的能晶id和数量
		Map<Integer, Integer> energyStoneMap = new HashMap<>();//因为以前服务器镶嵌时未验证是否有重复，所以使用map而非set
		for (EnergyStoneInlay energyStoneInlay :  stoneMap.values()) {
			if(energyStoneInlay.getStoneId() <= 0){
				continue;
			}
			Integer curNum = energyStoneMap.get(energyStoneInlay.getStoneId());
			if(curNum == null){
				curNum = 0;
			}
			curNum++;
			energyStoneMap.put(energyStoneInlay.getStoneId(), curNum);
		}
		
		for(Entry<Integer, Integer> entry : holeAndStoneIdMap.entrySet()) {
			if(entry.getValue() > 0){
				int count = 0;
				Prop prop = player.energyStone.get(entry.getValue());
				if(prop != null){
					count += prop.getCount();
				}
				Integer unCount = energyStoneMap.get(entry.getValue());
				if(unCount != null){
					count += unCount;
				}
				if (count < 1) {
					handler.sendErrorMsgToPlayer(GameError.ENERGY_STONE_NOT_ENOUGH);// 玩家没有足够的能晶
					return;
				}
			}
		}
		
		//卸下能晶
		for (EnergyStoneInlay inlay :  stoneMap.values()) {
			if(inlay.getStoneId() <= 0){
				continue;
			}
			int stoneId = inlay.getStoneId();
			// 卸下能晶
			inlay.setStoneId(0);
			// 增加玩家的能晶
			playerDataManager.addEnergyStone(player, stoneId, 1, AwardFrom.ALL_ENERGY_STONE);
		}
		
		//镶上
		for(Entry<Integer, Integer> entry : holeAndStoneIdMap.entrySet()) {
			if(entry.getValue() <= 0){
				continue;
			}
			EnergyStoneInlay inlay = stoneMap.get(entry.getKey());
			// 镶嵌
			inlay.setStoneId(entry.getValue());
			// 扣除能晶
			playerDataManager.subEnergyStone(player, entry.getValue(), 1, AwardFrom.ALL_ENERGY_STONE);
		}
		
		AllEnergyStoneRs.Builder builder = AllEnergyStoneRs.newBuilder();
		handler.sendMsgToPlayer(AllEnergyStoneRs.ext, builder.build());

        playerEventService.calcStrongestFormAndFight(player);
	}
}
