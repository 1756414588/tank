package com.game.service;

import com.game.bossFight.domain.Boss;
import com.game.constant.*;
import com.game.dataMgr.StaticActionAltarBossDataMgr;
import com.game.dataMgr.StaticEnergyStoneDataMgr;
import com.game.domain.Member;
import com.game.domain.PartyData;
import com.game.domain.Player;
import com.game.domain.p.BossFight;
import com.game.domain.p.Form;
import com.game.domain.p.Resource;
import com.game.domain.s.StaticAltarBoss;
import com.game.domain.s.StaticAltarBossAward;
import com.game.domain.s.StaticAltarBossContribute;
import com.game.domain.s.StaticAltarBossStar;
import com.game.fight.FightLogic;
import com.game.fight.domain.Fighter;
import com.game.fight.domain.Force;
import com.game.manager.ActivityDataManager;
import com.game.manager.BossDataManager;
import com.game.manager.PartyDataManager;
import com.game.manager.PlayerDataManager;
import com.game.message.handler.ClientHandler;
import com.game.pb.BasePb;
import com.game.pb.CommonPb;
import com.game.pb.GamePb4.*;
import com.game.pb.GamePb6;
import com.game.pb.GamePb6.GetFeedAltarContriButeRs;
import com.game.server.GameServer;
import com.game.util.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * @ClassName AltarBossService.java
 * @Description 祭坛BOSS服务类
 * @author TanDonghai
 * @date 创建时间：2016年7月14日 上午10:44:24
 *
 */
@Service
public class AltarBossService {
	@Autowired
	private BossDataManager bossDataManager;

	@Autowired
	private PartyDataManager partyDataManager;

	@Autowired
	private PlayerDataManager playerDataManager;

	@Autowired
	private StaticEnergyStoneDataMgr staticEnergyStoneDataMgr;
	@Autowired
	private ActivityDataManager activityDataManager;
	@Autowired
	private FightService fightService;

	@Autowired
	private ChatService chatService;

	private static final int ATTACK_CD = 60;// 攻击cd时间，单位： s

	@Autowired
	private StaticActionAltarBossDataMgr staticActionAltarBossDataMgr;

	/**
	 * 获取祭坛BOSS数据
	 * 
	 * @param handler
	 */
	public void getAltarBossData(ClientHandler handler) {
		Member member = partyDataManager.getMemberById(handler.getRoleId());
		if (member == null || member.getPartyId() == 0) {
			handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
			return;
		}

		int partyId = member.getPartyId();
		GetAltarBossDataRs.Builder builder = GetAltarBossDataRs.newBuilder();
		builder.setHurtRank(bossDataManager.getAltarHurtRank(partyId, handler.getRoleId()));

		// 获取玩家的设置
		BossFight bossFight = bossDataManager.getAltarBossFight(handler.getRoleId());
		builder.setAutoFight(bossFight.getAutoFight());
		builder.setBless1(bossFight.getBless1());
		builder.setBless2(bossFight.getBless2());
		builder.setBless3(bossFight.getBless3());
		builder.setHurt(bossFight.getHurt());

		// 获取BOSS的数据
		PartyData party = partyDataManager.getParty(partyId);
		builder.setBossHp(party.getBossHp());
		builder.setState(party.getBossState());
		builder.setWhich(party.getBossWhich());
		builder.setBossLv(party.getBossLv());
		Boss boss = bossDataManager.getAltarBoss(partyId);
		if (party.getBossState() == BossState.PREPAIR_STATE) {
			builder.setFightCdTime(boss.getNextStateTime());// 返回进入战斗状态的时间
			builder.setNextStateTime(boss.getNextStateTime());
		} else if (party.getBossState() == BossState.FIGHT_STATE) {
			builder.setFightCdTime(bossFight.getAttackTime() + ATTACK_CD);// 返回下次可以攻击的时间
			builder.setNextStateTime(boss.getNextStateTime());
		} else {
			builder.setFightCdTime(party.getNextCallBossSec());// 返回下次可以召唤BOSS的时间
			builder.setNextStateTime(party.getNextCallBossSec());
		}
		handler.sendMsgToPlayer(GetAltarBossDataRs.ext, builder.build());
	}

	/**
	 * 获取祭坛BOSS伤害排行
	 * 
	 * @param handler
	 */
	public void getAltarBossHurtRank(ClientHandler handler) {
		Member member = partyDataManager.getMemberById(handler.getRoleId());
		if (member == null || member.getPartyId() == 0) {
			handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
			return;
		}

		int partyId = member.getPartyId();
		GetAltarBossHurtRankRs.Builder builder = GetAltarBossHurtRankRs.newBuilder();

		List<BossFight> rankList = bossDataManager.getAltarBossHurtRank(partyId);
		if (!CheckNull.isEmpty(rankList)) {// 伤害排行信息
			int rank = 0;
			for (BossFight bossFight : rankList) {
				rank++;
				Player f = playerDataManager.getPlayer(bossFight.getLordId());
				if (f != null) {
					builder.addHurtRank(PbHelper.createHurtRankPb(bossFight, f.lord.getNick(), rank));
				}
			}
		}

		BossFight bossFight = bossDataManager.getAltarBossFight(handler.getRoleId());
		builder.setHurt(bossFight.getHurt());// 玩家伤害

		int rank = bossDataManager.getAltarHurtRank(partyId, handler.getRoleId());
		builder.setRank(rank);// 玩家排行
		boolean canGet = false;// 排行奖励已通过邮件发送，默认返回false
		// Boss boss = bossDataManager.getAltarBoss(partyId);
		// if (null != boss && boss.getBossState() == BossState.BOSS_DIE) {
		// if (rank > 0 && rank < 11) {
		// if (!bossDataManager.hadGetAltarAward(partyId, handler.getRoleId())) {
		// canGet = true;
		// }
		// }
		// }
		builder.setCanGet(canGet);// 玩家是否已领取排行奖励
		handler.sendMsgToPlayer(GetAltarBossHurtRankRs.ext, builder.build());
	}

	/**
	 * 祭坛BOSS设置vip自动战斗
	 * 
	 * @param autoFight
	 * @param handler
	 */
	public void setAltarBossAutoFight(boolean autoFight, ClientHandler handler) {
		Member member = partyDataManager.getMemberById(handler.getRoleId());
		if (member == null || member.getPartyId() == 0) {
			handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
			return;
		}

		int enterTime = member.getEnterTime();
		int currDay = TimeHelper.getCurrentDay();
		if (TimeHelper.subDay(currDay, enterTime) < 7) {// 参加祭坛BOSS需要加入军团7天以上
			handler.sendErrorMsgToPlayer(GameError.ALTAR_BOSS_IN_PARTY_TIME);
			return;
		}

		Player player = playerDataManager.getPlayer(handler.getRoleId());
		if (player.lord.getVip() < 6) {// 检查VIP等级
			handler.sendErrorMsgToPlayer(GameError.VIP_NOT_ENOUGH);
			return;
		}

		Form form = player.forms.get(FormType.ALTARBOSS);
		if (form == null) {// 检查阵型是否已设置
			handler.sendErrorMsgToPlayer(GameError.ALTAR_NO_FORM);
			return;
		}

		BossFight bossFight = bossDataManager.getAltarBossFight(handler.getRoleId());
		if (autoFight) {
			bossFight.setAutoFight(1);
		} else {
			bossFight.setAutoFight(0);
		}

		SetAltarBossAutoFightRs.Builder builder = SetAltarBossAutoFightRs.newBuilder();
		handler.sendMsgToPlayer(SetAltarBossAutoFightRs.ext, builder.build());
	}

	/**
	 * 祭坛BOSS祝福
	 * 
	 * @param index
	 * @param handler
	 */
	public void blessAltarBossFight(int index, ClientHandler handler) {
		if (index < 1 || index > 3) {
			handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
			return;
		}

		Member member = partyDataManager.getMemberById(handler.getRoleId());
		if (member == null || member.getPartyId() == 0) {
			handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
			return;
		}

		int enterTime = member.getEnterTime();
		int currDay = TimeHelper.getCurrentDay();
		if (TimeHelper.subDay(currDay, enterTime) < 7) {// 参加祭坛BOSS需要加入军团7天以上
			handler.sendErrorMsgToPlayer(GameError.ALTAR_BOSS_IN_PARTY_TIME);
			return;
		}

		int partyId = member.getPartyId();
		PartyData party = partyDataManager.getParty(partyId);
		if (party.getBossState() != BossState.PREPAIR_STATE && party.getBossState() != BossState.FIGHT_STATE) {
			handler.sendErrorMsgToPlayer(GameError.BOSS_STATE);// BOSS状态不正确
			return;
		}

		Player player = playerDataManager.getPlayer(handler.getRoleId());

		BossFight bossFight = bossDataManager.getAltarBossFight(handler.getRoleId());
		int lv = getBlessLevel(bossFight, index);
		int cost = BLESS_COST[lv];
		if (player.lord.getGold() < cost) {
			handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
			return;
		}

		// 扣除金币消耗
		playerDataManager.subGold(player, cost, AwardFrom.ALTAR_BOSS_BLESS_FIGHT);
		// 设置祝福等级
		setBlessLevel(bossFight, index, lv + 1);

		BlessAltarBossFightRs.Builder builder = BlessAltarBossFightRs.newBuilder();
		handler.sendMsgToPlayer(BlessAltarBossFightRs.ext, builder.build());
	}

	/**
	 * 获取祭坛BOSS祝福等级
	 * 
	 * @param bossFight
	 * @param index
	 * @return
	 */
	private int getBlessLevel(BossFight bossFight, int index) {
		int lv = 0;
		switch (index) {
		case 1:
			lv = bossFight.getBless1();
			break;
		case 2:
			lv = bossFight.getBless2();
			break;
		case 3:
			lv = bossFight.getBless3();
			break;
		}
		return lv;
	}

	/**
	 * 设置祭坛BOSS祝福等级
	 * 
	 * @param bossFight
	 * @param index
	 * @param lv
	 */
	private void setBlessLevel(BossFight bossFight, int index, int lv) {
		switch (index) {
		case 1:
			bossFight.setBless1(lv);
			break;
		case 2:
			bossFight.setBless2(lv);
			break;
		case 3:
			bossFight.setBless3(lv);
			break;
		}
	}

	/** 祝福值消耗数组 */
	private final static int[] BLESS_COST = { 20, 40, 80, 120, 160, 240, 320, 400, 600, 1000 };

	/** 祭坛BOSS准备阶段的时长，秒 */
	private final static int PREPARE_TIME = 300;

	/**
	 * 召唤祭坛BOSS
	 * 
	 * @param handler
	 */
	public void callAltarBoss(ClientHandler handler) {
		Member member = partyDataManager.getMemberById(handler.getRoleId());
		if (member == null || member.getPartyId() == 0) {
			handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
			return;
		}

		int partyId = member.getPartyId();
		PartyData party = partyDataManager.getParty(partyId);

		// 检查玩家是否有权限
		if (member.getJob() != PartyType.LEGATUS && member.getJob() != PartyType.LEGATUS_CP) {
			handler.sendErrorMsgToPlayer(GameError.AUTHORITY_ERR);
			return;
		}

		if (party.getPartyLv() < 20) {// 祭坛在军团20级后开启
			handler.sendErrorMsgToPlayer(GameError.ALTAR_PARTY_LV_LIMIT);
			return;
		}

		int now = TimeHelper.getCurrentSecond();
		if (party.getNextCallBossSec() > now) {// 还在召唤CD中
			handler.sendErrorMsgToPlayer(GameError.ALTAR_BOSS_CD);
			return;
		}

		StaticAltarBoss sab = staticEnergyStoneDataMgr.getAltarBossDataByLv(party.getAltarLv());
		if (null == sab) {
			handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
			return;
		}

		//添加上Boss的额外消耗建设度
		int altarBossExp = party.getAltarBossExp();
		StaticAltarBossStar staticAltarBossStar = staticActionAltarBossDataMgr.getAltarStarMaps(altarBossExp);
		int tatoalBuid = sab.getCallBossCost() + staticAltarBossStar.getCost();

		if (party.getBuild() < tatoalBuid) {// 军团建设度不足
			handler.sendErrorMsgToPlayer(GameError.ALTAR_BOSS_BUILD_NOT_ENOUGH);
			return;
		}

		// 扣除消耗的建设度
		party.setBuild(party.getBuild() - tatoalBuid);
		// 设置下次召唤时间
		party.setNextCallBossSec(now + sab.getCallBossCD());

		// 召唤祭坛BOSS
		Boss boss = bossDataManager.callAltarBoss(partyId);

		// 更新军团BOSS信息
		party.setBossLv(boss.getBossLv());
		party.setBossHp(boss.getBossHp());
		party.setBossWhich(boss.getBossWhich());
		party.setBossState(boss.getBossState());
		// 设置进入下移阶段的时间
		boss.setNextStateTime(now + PREPARE_TIME);
		// 清空BOSS排行信息
		party.getBossAwardList().clear();
		party.getBossHurtRankList().clear();

		CallAltarBossRs.Builder builder = CallAltarBossRs.newBuilder();
		builder.setBossHp(boss.getBossHp());
		builder.setBossLv(boss.getBossLv());
		builder.setState(boss.getBossState());
		builder.setWhich(boss.getBossWhich());
		builder.setNextStateTime(boss.getNextStateTime());

		handler.sendMsgToPlayer(CallAltarBossRs.ext, builder.build());

		// 军情通知 军团BOSS召唤
		partyDataManager.addPartyTrend(partyId, 20);

		// 在军团聊天中显示消息
		chatService.sendPartyChat(chatService.createSysChat(SysChatId.Altar_Boss_Call), partyId);
	}

	/**
	 * 消除祭坛BOSS的CD时间
	 * 
	 * @param handler
	 */
	public void buyAltarBossCd(ClientHandler handler) {
		Member member = partyDataManager.getMemberById(handler.getRoleId());
		if (member == null || member.getPartyId() == 0) {
			handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
			return;
		}

		int enterTime = member.getEnterTime();
		int currDay = TimeHelper.getCurrentDay();
		if (TimeHelper.subDay(currDay, enterTime) < 7) {// 参加祭坛BOSS需要加入军团7天以上
			handler.sendErrorMsgToPlayer(GameError.ALTAR_BOSS_IN_PARTY_TIME);
			return;
		}

		int partyId = member.getPartyId();
		Boss boss = bossDataManager.getAltarBoss(partyId);
		if (null == boss || boss.getBossState() != BossState.FIGHT_STATE) {
			handler.sendErrorMsgToPlayer(GameError.BOSS_END);
			return;
		}
		Player player = playerDataManager.getPlayer(handler.getRoleId());

		BossFight bossFight = bossDataManager.getAltarBossFight(handler.getRoleId());
		int now = TimeHelper.getCurrentSecond();
		int leftTime = bossFight.getAttackTime() + ATTACK_CD - now;
		if (leftTime > 0) {
			if (player.lord.getGold() < leftTime) {
				handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
				return;
			}

			playerDataManager.subGold(player, leftTime, AwardFrom.ALTAR_BOSS_BUY_CD);
			bossFight.setAttackTime(now - ATTACK_CD - 1);
		}

		BuyAltarBossCdRs.Builder builder = BuyAltarBossCdRs.newBuilder();
		builder.setGold(player.lord.getGold());
		handler.sendMsgToPlayer(BuyAltarBossCdRs.ext, builder.build());
	}

	/**
	 * 挑战祭坛BOSS
	 * 
	 * @param handler
	 */
	public void fightAltarBoss(ClientHandler handler) {
		Member member = partyDataManager.getMemberById(handler.getRoleId());
		if (member == null || member.getPartyId() == 0) {
			handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
			return;
		}

		int enterTime = member.getEnterTime();
		int currDay = TimeHelper.getCurrentDay();
		if (TimeHelper.subDay(currDay, enterTime) < 7) {// 参加祭坛BOSS需要加入军团7天以上
			handler.sendErrorMsgToPlayer(GameError.ALTAR_BOSS_IN_PARTY_TIME);
			return;
		}

		int partyId = member.getPartyId();
		Boss boss = bossDataManager.getAltarBoss(partyId);
//		LogHelper.BOSS_LOGGER.info("altar boss fight, boss:" + boss + ", partyId:" + partyId);
		LogUtil.boss("altar boss fight, boss:" + boss + ", partyId:" + partyId);
		if (null == boss || boss.getBossState() != BossState.FIGHT_STATE) {
			handler.sendErrorMsgToPlayer(GameError.BOSS_END);
			return;
		}

		BossFight b = bossDataManager.getAltarBossFight(handler.getRoleId());
		int now = TimeHelper.getCurrentSecond();
		int leftTime = b.getAttackTime() + ATTACK_CD - now;
		if (leftTime > 0) {
			FightAltarBossRs.Builder builder = FightAltarBossRs.newBuilder();
			builder.setResult(2);// cd中
			builder.setCdTime(b.getAttackTime());
			handler.sendMsgToPlayer(FightAltarBossRs.ext, builder.build());
			return;
		}

		Player player = playerDataManager.getPlayer(handler.getRoleId());
		Form form = player.forms.get(FormType.ALTARBOSS);
		if (form == null) {
			handler.sendErrorMsgToPlayer(GameError.BOSS_FORM);
			return;
		}

		Fighter attacker = fightService.createFighter(b, player, form, AttackType.ACK_OTHER);

		PartyData partydata = partyDataManager.getParty(partyId);
		StaticAltarBossStar staticAltarBossStar = staticActionAltarBossDataMgr.getAltarStarMaps(partydata.getAltarBossExp());


		Fighter attacked = fightService.createAltarBoss(boss,staticAltarBossStar.getAmount());

		FightLogic fightLogic = new FightLogic(attacker, attacked, FirstActType.ATTACKER, true);
		fightLogic.fightBoss();

		refreshBossTank(boss, attacked);// 更新战斗后的祭坛BOSS的血量

		FightAltarBossRs.Builder builder = FightAltarBossRs.newBuilder();
		CommonPb.Record record = fightLogic.generateRecord();
		int result = (fightLogic.getWinState() == 1) ? 1 : -1;

		builder.setResult(result);
		builder.setRecord(record);

		bossDataManager.addAltarBossHurt(partyId, b, attacker.hurt);// 记录伤害量，并更新伤害排行

		if (result == 1) {
			boss.setBossState(BossState.BOSS_DIE);
			try {
				StaticAltarBoss sab = staticEnergyStoneDataMgr.getAltarBossDataByLv(boss.getBossLv());
				if (null != sab) {
					// 邮件发送最后一击的奖励
					List<CommonPb.Award> awards = PbHelper.createAwardsPb(sab.getKillAward());
					playerDataManager.sendAttachMail(AwardFrom.ALTAR_BOSS_KILL, player, awards,
							MailType.MOLD_KILL_ALTAR_BOSS, TimeHelper.getCurrentSecond());

					// 邮件发送伤害排行奖励
					sendHurtRankReward(boss);

					// 邮件发送参与奖励
					sendAltarBossParticipateAward(partyId, boss.getBossLv(), true);

					clearAltarBossExp(boss.getPartyId());

					bossDataManager.resetAltarBossAutoFight(boss.getPartyId());// 重置玩家的自动战斗状态
				}
			} catch (Exception e) {
				LogUtil.error("发送祭坛BOSS奖励出错， boss:" + boss, e);
				LogUtil.boss("发送祭坛BOSS奖励出错， boss:" + boss + ", exception:" + e.getMessage());
			}
		} else {
			b.setAttackTime(now);
			builder.setCdTime(now + ATTACK_CD);
		}

		updatePatyBossData(partyId);// 同步军团中关于祭坛BOSS的数据

		builder.setHurt(b.getHurt());
		builder.setRank(bossDataManager.getAltarHurtRank(partyId, handler.getRoleId()));
		builder.setWhich(boss.getBossWhich());
		builder.setBossHp(boss.getBossHp());
		handler.sendMsgToPlayer(FightAltarBossRs.ext, builder.build());
	}

	/**
	 * 通过邮件发送玩家的参与奖励
	 * 
	 * @param partyId
	 * @param bossLv
	 * @param isSuccess 是否胜利，胜利发送全部奖励，失败则奖励减半
	 */
	public void sendAltarBossParticipateAward(int partyId, int bossLv, boolean isSuccess) {
		StaticAltarBoss sab = staticEnergyStoneDataMgr.getAltarBossDataByLv(bossLv);
		Set<Long> roles = bossDataManager.getAltarparticipateRoles(partyId);
//		LogHelper.BOSS_LOGGER.info("发送Altar Boss参与奖励, partyId:" + partyId + ", bossLv:" + bossLv + ", isSuccess:"
//				+ isSuccess + " ,玩家:" + roles);
		LogUtil.boss("发送Altar Boss参与奖励, partyId:" + partyId + ", bossLv:" + bossLv + ", isSuccess:"
				+ isSuccess + " ,玩家:" + roles);
		if (null != sab && !CheckNull.isEmpty(roles)) {
			Player player;
			List<CommonPb.Award> awards;
			List<List<Integer>> partAward = new ArrayList<>();
			int moldId = MailType.MOLD_PART_ALTAR_BOSS_SUCCESS;

			PartyData partydata = partyDataManager.getParty(partyId);
			StaticAltarBossStar staticAltarBossStar = staticActionAltarBossDataMgr.getAltarStarMaps(partydata.getAltarBossExp());
			StaticAltarBossAward  staticAltarBossAward =null;


			if (isSuccess) {
//				partAward.addAll(sab.getPartAward());

				// 军情通知 军团BOSS击杀
				partyDataManager.addPartyTrend(partyId, 21);

				// 在军团聊天中显示消息
				chatService.sendPartyChat(chatService.createSysChat(SysChatId.Altar_Boss_Kill), partyId);




			} else {// BOSS逃跑，奖励减半
//				partAward = sab.getHalfPartAward();

				// 军情通知 军团BOSS逃跑
				partyDataManager.addPartyTrend(partyId, 22);

				// 在军团聊天中显示消息
				chatService.sendPartyChat(chatService.createSysChat(SysChatId.Altar_Boss_End), partyId);

				moldId = MailType.MOLD_PART_ALTAR_BOSS_FAIL;
			}


			for (Long lordId : roles) {
				partAward.clear();
				if (isSuccess) {
					partAward.addAll(sab.getPartAward());
					if ( staticAltarBossStar != null) {
						staticAltarBossAward = staticActionAltarBossDataMgr.getAltarAwardMaps(bossLv, staticAltarBossStar.getStar());
						if(staticAltarBossAward != null ){

							//随机两个奖励
							List<Integer> randomKey  = LotteryUtil.getRandomKey(LotteryUtil.listToMap(staticAltarBossAward.getAward()));
							if(randomKey != null ){
								partAward.add(randomKey);
							}
							List<Integer> randomKey2  = LotteryUtil.getRandomKey(LotteryUtil.listToMap(staticAltarBossAward.getAward()));
							if(randomKey2 != null ){
								partAward.add(randomKey2);
							}
						}

					}
				} else {
					partAward = new ArrayList<>(sab.getHalfPartAward());

				}
				awards = PbHelper.createAwardsPb(partAward);
				player = playerDataManager.getPlayer(lordId);
				playerDataManager.sendAttachMail(AwardFrom.ALTAR_BOSS_PARTICIPATE, player, awards, moldId,
						TimeHelper.getCurrentSecond());
			}
		}
	}

	/**
	 * 更新战斗后的祭坛BOSS的血量
	 * 
	 * @param boss
	 * @param fighter
	 */
	private void refreshBossTank(Boss boss, Fighter fighter) {
		for (int i = 0; i < fighter.forces.length; i++) {
			Force force = fighter.forces[i];
			if (force != null) {
				if (force.alive()) {
					boss.setBossHp(force.count);
					boss.setBossWhich(i);
					return;
				}
			}
		}

		boss.setBossWhich(5);
		boss.setBossHp(0);
	}

	/**
	 * 同步BOSS数据到军团信息中
	 * 
	 * @param partyId
	 */
	public void updatePatyBossData(int partyId) {
		PartyData party = partyDataManager.getParty(partyId);
		Boss boss = bossDataManager.getAltarBoss(partyId);
		if (null == party || null == boss) {
			return;
		}

		party.setBossLv(boss.getBossLv());
		party.setBossHp(boss.getBossHp());
		party.setBossWhich(boss.getBossWhich());
		party.setBossState(boss.getBossState());

		// 如果战斗结束（BOSS死亡或逃跑），更新伤害排行信息
		if (boss.getBossState() == BossState.BOSS_END || boss.getBossState() == BossState.BOSS_DIE) {
			party.getBossHurtRankList().clear();
			List<BossFight> rankList = bossDataManager.getAltarBossHurtRank(partyId);
			if (!CheckNull.isEmpty(rankList)) {
				for (BossFight b : rankList) {
					party.getBossHurtRankList().add(b.getLordId());
				}
			}
		}
	}

	/**
	 * 祭坛BOSS自动战斗逻辑
	 * 
	 * @param b
	 */
	public void altarBossAutoFight(BossFight b) {
		Member member = partyDataManager.getMemberById(b.getLordId());
		if (member == null || member.getPartyId() == 0) {
			return;
		}

		int now = TimeHelper.getCurrentSecond();
		int leftTime = b.getAttackTime() + ATTACK_CD - now;
		if (leftTime > 0) {
			return;
		}

		Player player = playerDataManager.getPlayer(b.getLordId());
		if (player == null) {
			return;
		}

		Form form = player.forms.get(FormType.ALTARBOSS);
		if (form == null) {
			return;
		}

		int partyId = member.getPartyId();
		Boss boss = bossDataManager.getAltarBoss(partyId);
//		LogHelper.BOSS_LOGGER.info("altar boss auto fight, boss:" + boss + ", partyId:" + partyId);
		LogUtil.boss("altar boss auto fight, boss:" + boss + ", partyId:" + partyId);
		if (null == boss || boss.getBossState() != BossState.FIGHT_STATE) {
//			LogHelper.BOSS_LOGGER.info("altar boss auto fight, boss dead, skip...");
			LogUtil.boss("altar boss auto fight, boss dead, skip...");
			return;
		}

		Fighter attacker = fightService.createFighter(b, player, form, AttackType.ACK_OTHER);


		PartyData partydata = partyDataManager.getParty(partyId);
		StaticAltarBossStar staticAltarBossStar = staticActionAltarBossDataMgr.getAltarStarMaps(partydata.getAltarBossExp());

		Fighter attacked = fightService.createAltarBoss(boss,staticAltarBossStar.getAmount());

		FightLogic fightLogic = new FightLogic(attacker, attacked, FirstActType.ATTACKER, true);
		fightLogic.fightBoss();

		refreshBossTank(boss, attacked);// 更新战斗后的祭坛BOSS的血量

		int result = (fightLogic.getWinState() == 1) ? 1 : -1;

		bossDataManager.addAltarBossHurt(partyId, b, attacker.hurt);// 记录伤害量，并更新伤害排行

		if (result == 1) {
			boss.setBossState(BossState.BOSS_DIE);
			try {
				StaticAltarBoss sab = staticEnergyStoneDataMgr.getAltarBossDataByLv(boss.getBossLv());
				if (null != sab) {
					// 邮件发送最后一击的奖励
					List<CommonPb.Award> awards = PbHelper.createAwardsPb(sab.getKillAward());
					playerDataManager.sendAttachMail(AwardFrom.ALTAR_BOSS_KILL, player, awards,
							MailType.MOLD_KILL_ALTAR_BOSS, TimeHelper.getCurrentSecond());

					// 邮件发送伤害排行奖励
					sendHurtRankReward(boss);

					// 邮件发送参与奖励
					sendAltarBossParticipateAward(partyId, boss.getBossLv(), true);
					clearAltarBossExp(boss.getPartyId());

					bossDataManager.resetAltarBossAutoFight(boss.getPartyId());// 重置玩家的自动战斗状态
				}
			} catch (Exception e) {
				LogUtil.error("发送祭坛BOSS奖励出错， boss:" + boss, e);
				LogUtil.boss("发送祭坛BOSS奖励出错， boss:" + boss + ", exception:" + e.getMessage());
			}
		} else {
			b.setAttackTime(now);
		}

		updatePatyBossData(partyId);// 同步军团中关于祭坛BOSS的数据
	}

	/**
	 * 领取祭坛BOSS伤害排名奖励
	 * 
	 * @param handler
	 */
	public void altarBossHurtAward(ClientHandler handler) {
		// Member member = partyDataManager.getMemberById(handler.getRoleId());
		// if (member == null || member.getPartyId() == 0) {
		// handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
		// return;
		// }
		//
		// int partyId = member.getPartyId();
		// PartyData party = partyDataManager.getParty(partyId);
		// if (party.getBossState() != BossState.BOSS_DIE) {
		// handler.sendErrorMsgToPlayer(GameError.BOSS_NOT_END);// BOSS未死
		// return;
		// }
		//
		// if (bossDataManager.hadGetAltarAward(partyId, handler.getRoleId())) {
		// handler.sendErrorMsgToPlayer(GameError.ALREADY_GET_BOX);// 奖励已领取
		// return;
		// }
		//
		// int rank = bossDataManager.getAltarHurtRank(partyId, handler.getRoleId());
		// if (rank < 1 || rank > 3) {
		// handler.sendErrorMsgToPlayer(GameError.NOT_ON_RANK);// 玩家未进排行榜
		// return;
		// }
		//
		// bossDataManager.setAltarAward(partyId, handler.getRoleId());// 记录玩家已领取奖励
		//
		// AltarBossHurtAwardRs.Builder builder = AltarBossHurtAwardRs.newBuilder();
		// Player player = playerDataManager.getPlayer(handler.getRoleId());
		//
		// StaticAltarBoss sab = staticEnergyStoneDataMgr.getAltarBossDataByLv(party.getBossLv());
		// if (null != sab && rank <= 3) {// 只有前3名有奖励
		// List<List<Integer>> awards = null;
		// if (rank == 1) {
		// awards = sab.getRankAward1();
		// } else if (rank == 2) {
		// awards = sab.getRankAward2();
		// } else if (rank == 3) {
		// awards = sab.getRankAward3();
		// }
		// List<CommonPb.Award> awardList = PbHelper.createAwardsPb(awards);
		// playerDataManager.sendAttachMail(AwardFrom.ALTAR_BOSS_HURT_RANK, player, awardList,
		// MailType.MOLD_ALTAR_BOSS_RANK_REWARD, TimeHelper.getCurrentSecond(), String.valueOf(rank));
		// }
		// handler.sendMsgToPlayer(AltarBossHurtAwardRs.ext, builder.build());
	}

	/**
	 * 通过邮件发送伤害排行前3名的奖励
	 * 
	 * @param boss
	 */
	public void sendHurtRankReward(Boss boss) {
		List<BossFight> rankList = bossDataManager.getAltarBossHurtRank(boss.getPartyId());
		StaticAltarBoss sab = staticEnergyStoneDataMgr.getAltarBossDataByLv(boss.getBossLv());
		if (null != sab && !CheckNull.isEmpty(rankList)) {
			BossFight bf = rankList.get(0);// 发送第1名的奖励
			Player player = playerDataManager.getPlayer(bf.getLordId());
			List<List<Integer>> awards = sab.getRankAward1();
			playerDataManager.sendAttachMail(AwardFrom.ALTAR_BOSS_HURT_RANK, player, PbHelper.createAwardsPb(awards),
					MailType.MOLD_ALTAR_BOSS_RANK_REWARD, TimeHelper.getCurrentSecond(), String.valueOf(1));

			if (rankList.size() >= 2) {
				bf = rankList.get(1);// 发送第2名的奖励
				player = playerDataManager.getPlayer(bf.getLordId());
				awards = sab.getRankAward2();
				playerDataManager.sendAttachMail(AwardFrom.ALTAR_BOSS_HURT_RANK, player,
						PbHelper.createAwardsPb(awards), MailType.MOLD_ALTAR_BOSS_RANK_REWARD,
						TimeHelper.getCurrentSecond(), String.valueOf(2));
			}

			if (rankList.size() >= 3) {
				bf = rankList.get(2);// 发送第3名的奖励
				player = playerDataManager.getPlayer(bf.getLordId());
				awards = sab.getRankAward3();
				playerDataManager.sendAttachMail(AwardFrom.ALTAR_BOSS_HURT_RANK, player,
						PbHelper.createAwardsPb(awards), MailType.MOLD_ALTAR_BOSS_RANK_REWARD,
						TimeHelper.getCurrentSecond(), String.valueOf(3));
			}
		}

	}

	/**
	 * 祭坛BOSS定时处理逻辑
	 */
	public void altarBossTimerLogic() {
		Set<Boss> startBoss = bossDataManager.getStartAltarBossSet();
		if (!CheckNull.isEmpty(startBoss)) {
			int now = TimeHelper.getCurrentSecond();
			for (Boss boss : startBoss) {
				try{
					if (boss.getBossState() == BossState.PREPAIR_STATE || boss.getBossState() == BossState.FIGHT_STATE) {
						if (boss.getNextStateTime() <= now) {
							if (boss.getBossState() == BossState.PREPAIR_STATE) {
								boss.setBossState(BossState.FIGHT_STATE);
	
								// 设置进入下一状态（BOSS逃跑）的时间
								PartyData party = partyDataManager.getParty(boss.getPartyId());
								StaticAltarBoss sab = staticEnergyStoneDataMgr.getAltarBossDataByLv(party.getAltarLv());
								boss.setNextStateTime(now + sab.getFightTime());
							} else if (boss.getBossState() == BossState.FIGHT_STATE) {
								boss.setBossState(BossState.BOSS_END);// BOSS逃跑
								bossDataManager.resetAltarBossAutoFight(boss.getPartyId());// 重置玩家的自动战斗状态
	
								// 邮件发送参与奖励，奖励减半
								sendAltarBossParticipateAward(boss.getPartyId(), boss.getBossLv(), false);
								clearAltarBossExp(boss.getPartyId());


							}
	
							updatePatyBossData(boss.getPartyId());// 同步数据到数据库
						}
						if (boss.getBossState() == BossState.FIGHT_STATE) {
							altarBossAutoFight(boss.getPartyId());// VIP自动战斗处理
						}
					}
				} catch (Exception e) {
					LogUtil.error("祭坛BOSS定时处理报错, boss:" + boss, e);
				}
			}
		}
	}

	/**
	 * 祭坛BOSS自动战斗处理
	 * 
	 * @param partyId
	 */
	public void altarBossAutoFight(int partyId) {
		List<Member> mList = partyDataManager.getMemberList(partyId);
		if (CheckNull.isEmpty(mList)) {
			return;
		}
		for (Member member : mList) {
			BossFight bossFight = bossDataManager.getAltarBossFight(member.getLordId());
			if (null != bossFight && bossFight.getAutoFight() == 1) {
				altarBossAutoFight(bossFight);
			}
		}
	}

	/**
	 * 重置玩家的自动战斗状态，玩家离开军团时调用
	 * 
	 * @param lordId
	 */
	public void resetBossAutoFight(int partyId, long lordId) {
		BossFight bossFight = bossDataManager.getAltarBossFight(lordId);
		bossFight.setAttackTime(0);
		bossFight.setAutoFight(0);
		bossFight.setBless1(0);
		bossFight.setBless2(0);
		bossFight.setBless3(0);
		bossFight.setHurt(0);

		// 清除玩家的祭坛BOSS伤害排行
		List<BossFight> rankList = bossDataManager.getAltarBossHurtRank(partyId);
		if (!CheckNull.isEmpty(rankList)) {
			rankList.remove(bossFight);
		}
		Set<Long> hurtSet = bossDataManager.getAltarparticipateRoles(partyId);
		if (!CheckNull.isEmpty(hurtSet)) {
			hurtSet.remove(lordId);
		}
	}
	
	/**
	 * 祭坛Boss
	 * @param req
	 * @param handler
	 */
	public void getFeedAltarBossRq(com.game.pb.GamePb6.GetFeedAltarBossRq req, ClientHandler handler) {
		 Player player = playerDataManager.getPlayer(handler.getRoleId());
		 
		 Map<Integer, Integer>  contribute = player.getContributeCount();

		 
		 
		 GamePb6.GetFeedAltarBossRs.Builder builder = GamePb6.GetFeedAltarBossRs.newBuilder();

	        for (Map.Entry<Integer, Integer> e : contribute.entrySet()) {
	            builder.addContributeCount(PbHelper.createTwoIntPb(e.getKey(), e.getValue()));
	        }

	        handler.sendMsgToPlayer(GamePb6.GetFeedAltarBossRs.ext, builder.build());
	}

	/**
	 * 祭坛Boss
	 * 资源捐献
	 * @param rq
	 * @param handler
	 */
	public void donateAllAltarBossRes(com.game.pb.GamePb6.GetFeedAltarContriButeRq rq,ClientHandler handler) {


		List<Integer> typeList = rq.getTypeList();
		
		Member member = partyDataManager.getMemberById(handler.getRoleId());
		if (member == null || member.getPartyId() == 0) {
			handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
			return;
		}

		int partyId = member.getPartyId();
		PartyData  partyData = partyDataManager.getParty(partyId);

		if (partyData == null) {
			handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
			return;
		}

		//如果Boss状态是1 和 2 直接返回不捐献
		if ( partyData.getBossState() == 1 || partyData.getBossState() == 2) {
            handler.sendErrorMsgToPlayer(GameError.ALTAR_BOSS_READY);
			return;
		}

		//祭坛BOSS经验超过6000不予捐献
		if (partyData.getAltarBossExp() >= staticActionAltarBossDataMgr.getMaxExp()) {
			handler.sendErrorMsgToPlayer(GameError.ALTAR_BOSS_UPLIMIT);
			return;
		}

		partyDataManager.refreshMember(member);
		partyDataManager.refreshPartyData(partyData);
		
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		Resource resource = player.resource;

		com.game.pb.GamePb6.GetFeedAltarContriButeRs.Builder builder = GetFeedAltarContriButeRs.newBuilder();


		int contribute = 0;
		int exp =0;
		Map<Integer, Integer> contributeCount = player.getContributeCount();
		
		for (Integer type : typeList) {

			Integer count = 0;
			
			if (contributeCount.containsKey(type)) {
				count = contributeCount.get(type);
			}

			StaticAltarBossContribute altarBossContribute = staticActionAltarBossDataMgr.getStaticAltarBossContribute(type,count+1);
			
			if(altarBossContribute == null){
				continue;
			}

			if ( partyData.getAltarBossExp() + exp >= staticActionAltarBossDataMgr.getMaxExp() ) {
				break;
			}
			
			if (type == PartyType.RESOURCE_STONE) {
				
				if( resource.getStone() < altarBossContribute.getPrice()){
					continue;
				}

				playerDataManager.modifyStone(player, -altarBossContribute.getPrice(), AwardFrom.Altar_BOSS_CONTRIBUTE);
				builder.setStone(resource.getStone());
				
			} else if(type == PartyType.RESOURCE_IRON){
				if( resource.getIron() < altarBossContribute.getPrice()){
					continue;
				}

				playerDataManager.modifyIron(player, -altarBossContribute.getPrice(), AwardFrom.Altar_BOSS_CONTRIBUTE);
				builder.setIron(resource.getIron());
				
			} else if(type == PartyType.RESOURCE_SILICON){
				if( resource.getSilicon() < altarBossContribute.getPrice()){
					continue;
				}

				playerDataManager.modifySilicon(player, -altarBossContribute.getPrice(), AwardFrom.Altar_BOSS_CONTRIBUTE);
				builder.setSilicon(resource.getSilicon());
				
			} else if(type == PartyType.RESOURCE_COPPER){
				if( resource.getCopper() < altarBossContribute.getPrice()){
					continue;
				}

				playerDataManager.modifyCopper(player, -altarBossContribute.getPrice(), AwardFrom.Altar_BOSS_CONTRIBUTE);
				builder.setCopper(resource.getCopper());
				
			} else if(type == PartyType.RESOURCE_OIL){
				if( resource.getOil() < altarBossContribute.getPrice()){
					continue;
				}

				playerDataManager.modifyOil(player, -altarBossContribute.getPrice(), AwardFrom.Altar_BOSS_CONTRIBUTE);
				builder.setOil(resource.getOil());
			}
			contribute += activityDataManager.fireSheet(player, partyId, altarBossContribute.getContribute());

			exp+=altarBossContribute.getExp();
			
			//添加 捐献的类型和次数
			contributeCount.put(type, count+1);


		}

		//超过最大经验按照最大经验设置
		if ( partyData.getAltarBossExp()+exp >= staticActionAltarBossDataMgr.getMaxExp()) {
			partyData.setAltarBossExp(staticActionAltarBossDataMgr.getMaxExp());
		} else {
			partyData.setAltarBossExp(partyData.getAltarBossExp()+exp);
		}

		member.setDonate(member.getDonate() + contribute);
		member.setWeekDonate(member.getWeekDonate() + contribute);
		member.setWeekAllDonate(member.getWeekAllDonate() + contribute);

		for (Map.Entry<Integer, Integer> e : contributeCount.entrySet()) {
			builder.addContributeCount(PbHelper.createTwoIntPb(e.getKey(), e.getValue()));
		}
		builder.setContribute(contribute);
		builder.setExp(partyData.getAltarBossExp());
		handler.sendMsgToPlayer(GamePb6.GetFeedAltarContriButeRs.ext, builder.build());

	}

	/**
	 * 清除BOSS经验和玩家捐献的类型和次数
	 * @param partyId
	 */
	public void clearAltarBossExp(int partyId) {
		PartyData party = partyDataManager.getParty(partyId);
		party.setAltarBossExp(0);

		List<Member> memberList = partyDataManager.getMemberList(partyId);

		GamePb6.SynFeedAltarContriButeExpRq.Builder builder = GamePb6.SynFeedAltarContriButeExpRq.newBuilder();
		builder.setExp(party.getAltarBossExp());

		BasePb.Base.Builder msg = PbHelper.createSynBase(GamePb6.SynFeedAltarContriButeExpRq.EXT_FIELD_NUMBER, GamePb6.SynFeedAltarContriButeExpRq.ext, builder.build());

		if (memberList != null) {
			for (Member member : memberList) {
				Player player = playerDataManager.getPlayer(member.getLordId());
				if( player != null ){
					player.getContributeCount().clear();

					if(player.ctx != null && player.isLogin){
						GameServer.getInstance().synMsgToPlayer(player.ctx, msg);
					}
				}
			}
		}


	}

}
