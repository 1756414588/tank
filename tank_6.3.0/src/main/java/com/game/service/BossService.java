/**   
 * @Title: BossService.java    
 * @Package com.game.service    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年12月30日 下午1:48:22    
 * @version V1.0   
 */
package com.game.service;

import com.game.bossFight.domain.Boss;
import com.game.common.ServerSetting;
import com.game.constant.*;
import com.game.dataMgr.StaticWarAwardDataMgr;
import com.game.domain.Player;
import com.game.domain.p.BossFight;
import com.game.domain.p.Form;
import com.game.fight.FightLogic;
import com.game.fight.domain.Fighter;
import com.game.fight.domain.Force;
import com.game.manager.BossDataManager;
import com.game.manager.PlayerDataManager;
import com.game.message.handler.ClientHandler;
import com.game.pb.CommonPb;
import com.game.pb.GamePb3.*;
import com.game.util.LogUtil;
import com.game.util.PbHelper;
import com.game.util.RandomHelper;
import com.game.util.TimeHelper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

/**
 * @ClassName: BossService
 * @Description: 世界boss相关业务
 * @author ZhangJun
 * @date 2015年12月30日 下午1:48:22
 * 
 */
@Service
public class BossService {
	@Autowired
	private BossDataManager bossDataManager;

	@Autowired
	private PlayerDataManager playerDataManager;

	@Autowired
	private StaticWarAwardDataMgr staticWarAwardDataMgr;

	@Autowired
	private FightService fightService;

	@Autowired
	private ChatService chatService;

	@Autowired
	private ServerSetting serverSetting;

	/**
	 * 
	 * Method: getBoss
	 * 
	 * @Description: 获取世界boss数据
	 * @param handler
	 * @return void

	 */
	public void getBoss(ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		if (player.lord.getLevel() < 30) {
			handler.sendErrorMsgToPlayer(GameError.LV_NOT_ENOUGH);
			return;
		}

		GetBossRs.Builder builder = GetBossRs.newBuilder();

		BossFight bossFight = bossDataManager.getBossFight(player.roleId);
		if (bossFight == null) {
			bossFight = bossDataManager.createBossFight(player.roleId);
		}

		if (bossDataManager.getBoss().getBossState() == BossState.FIGHT_STATE) {
			builder.setCdTime(bossFight.getAttackTime() + 60);
		}

		builder.setHurtRank(bossDataManager.getHurtRank(player.roleId));

		String killer = bossDataManager.getKiller();
		if (killer != null) {
			builder.setKiller(killer);
		}

		builder.setAutoFight(bossFight.getAutoFight());
		builder.setBless1(bossFight.getBless1());
		builder.setBless2(bossFight.getBless2());
		builder.setBless3(bossFight.getBless3());
		builder.setHurt(bossFight.getHurt());
		builder.setWhich(bossDataManager.getBoss().getBossWhich());
		builder.setBossHp(bossDataManager.getBoss().getBossHp());
		builder.setState(bossDataManager.getBoss().getBossState());
		builder.setTotalHurt(bossDataManager.getBoss().getHurt());
		handler.sendMsgToPlayer(GetBossRs.ext, builder.build());
	}

	/**
	 * 
	 * Method: getBossHurtRank
	 * 
	 * @Description: 获取世界boss伤害排行
	 * @param handler
	 * @return void

	 */
	public void getBossHurtRank(ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		if (player.lord.getLevel() < 30) {
			handler.sendErrorMsgToPlayer(GameError.LV_NOT_ENOUGH);
			return;
		}

		GetBossHurtRankRs.Builder builder = GetBossHurtRankRs.newBuilder();

		int rank = 0;
		for (BossFight bossFight : bossDataManager.getHurtRankList()) {
			rank++;
			Player f = playerDataManager.getPlayer(bossFight.getLordId());
			if (f != null) {
				builder.addHurtRank(PbHelper.createHurtRankPb(bossFight, f.lord.getNick(), rank));
			}
		}

		BossFight b = bossDataManager.getBossFight(player.roleId);
		if (b != null) {
			builder.setHurt(b.getHurt());
		}

		int myRank = bossDataManager.getHurtRank(player.roleId);
		builder.setRank(myRank);

		boolean canGet = false;
		if (bossDataManager.getBoss().getBossState() == BossState.BOSS_DIE) {
			if (myRank > 0 && myRank < 11) {
				if (!bossDataManager.hadGetHurtRankAward(player.roleId)) {
					canGet = true;
				}
			}
		}

		builder.setCanGet(canGet);
		handler.sendMsgToPlayer(GetBossHurtRankRs.ext, builder.build());
	}

	/**
	 * 
	 * Method: setAutoFight
	 * 
	 * @Description: 世界boss 设置vip自动战斗
	 * @param req
	 * @param handler
	 * @return void

	 */
	public void setAutoFight(SetBossAutoFightRq req, ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		if (player.lord.getLevel() < 30) {
			handler.sendErrorMsgToPlayer(GameError.LV_NOT_ENOUGH);
			return;
		}

		if (player.lord.getVip() < 6) {
			handler.sendErrorMsgToPlayer(GameError.VIP_NOT_ENOUGH);
			return;
		}

		Form form = player.forms.get(FormType.BOSS);
		if (form == null) {
			handler.sendErrorMsgToPlayer(GameError.BOSS_FORM);
			return;
		}

		boolean auto = req.getAutoFight();
		BossFight b = bossDataManager.getBossFight(player.roleId);
		if (b != null) {
			if (auto) {
				b.setAutoFight(1);
			} else {
				b.setAutoFight(0);
			}
		}

		SetBossAutoFightRs.Builder builder = SetBossAutoFightRs.newBuilder();
		handler.sendMsgToPlayer(SetBossAutoFightRs.ext, builder.build());
	}

	final static private int[] BLESS_COST = { 20, 40, 80, 120, 160, 240, 320, 400, 600, 1000 };

	/**
	 * 
	 * Method: blessBossFight
	 * 
	 * @Description: 世界boss祝福
	 * @param req
	 * @param handler
	 * @return void

	 */
	public void blessBossFight(BlessBossFightRq req, ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		if (player.lord.getLevel() < 30) {
			handler.sendErrorMsgToPlayer(GameError.LV_NOT_ENOUGH);
			return;
		}

		if (bossDataManager.getBoss().getBossState() != BossState.PREPAIR_STATE && bossDataManager.getBoss().getBossState() != BossState.FIGHT_STATE) {
			handler.sendErrorMsgToPlayer(GameError.BOSS_STATE);
			return;
		}

		BlessBossFightRs.Builder builder = BlessBossFightRs.newBuilder();

		int index = req.getIndex();
		BossFight b = bossDataManager.getBossFight(player.roleId);
		if (b != null) {
			int cost = 0;
			int lv = 0;
			switch (index) {
			case 1:
				lv = b.getBless1();
				if (lv >= 10) {
					handler.sendErrorMsgToPlayer(GameError.MAX_BLESS_LV);
					return;
				}

				cost = BLESS_COST[lv];
				if (player.lord.getGold() < cost) {
					handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
					return;
				}

				playerDataManager.subGold(player, cost, AwardFrom.BLESS_FIGHT);
				lv = lv + 1;
				b.setBless1(lv);
				break;
			case 2:
				lv = b.getBless2();
				if (lv >= 10) {
					handler.sendErrorMsgToPlayer(GameError.MAX_BLESS_LV);
					return;
				}

				cost = BLESS_COST[lv];
				if (player.lord.getGold() < cost) {
					handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
					return;
				}

				playerDataManager.subGold(player, cost, AwardFrom.BLESS_FIGHT);
				lv = lv + 1;
				b.setBless2(lv);
				break;
			case 3:
				lv = b.getBless3();
				if (lv >= 10) {
					handler.sendErrorMsgToPlayer(GameError.MAX_BLESS_LV);
					return;
				}

				cost = BLESS_COST[lv];
				if (player.lord.getGold() < cost) {
					handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
					return;
				}

				playerDataManager.subGold(player, cost, AwardFrom.BLESS_FIGHT);
				lv = lv + 1;
				b.setBless3(lv);
				break;
			default:
				break;
			}

			builder.setLv(lv);
			builder.setGold(player.lord.getGold());
		}

		handler.sendMsgToPlayer(BlessBossFightRs.ext, builder.build());
	}

	/**
	 * 
	 * Method: buyBossCd
	 * 
	 * @Description: 消除世界boss CD时间
	 * @param req
	 * @param handler
	 * @return void

	 */
	public void buyBossCd(BuyBossCdRq req, ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		if (player.lord.getLevel() < 30) {
			handler.sendErrorMsgToPlayer(GameError.LV_NOT_ENOUGH);
			return;
		}

		if (bossDataManager.getBoss().getBossState() != BossState.FIGHT_STATE) {
			handler.sendErrorMsgToPlayer(GameError.BOSS_END);
			return;
		}

		BossFight b = bossDataManager.getBossFight(player.roleId);
		// int s = req.getS();
		int now = TimeHelper.getCurrentSecond();
		int leftTime = b.getAttackTime() + 60 - now;
		if (leftTime > 0) {
			if (player.lord.getGold() < leftTime) {
				handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
				return;
			}

			playerDataManager.subGold(player, leftTime, AwardFrom.BOSS_CD);
			b.setAttackTime(now - 60);
		}

		BuyBossCdRs.Builder builder = BuyBossCdRs.newBuilder();
		builder.setGold(player.lord.getGold());
		handler.sendMsgToPlayer(BuyBossCdRs.ext, builder.build());
	}

	/**
	 * 
	 * Method: hurtAward
	 * 
	 * @Description: 领取世界bosss伤害排名奖励
	 * @param handler
	 * @return void

	 */
	public void hurtAward(ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		if (player.lord.getLevel() < 30) {
			handler.sendErrorMsgToPlayer(GameError.LV_NOT_ENOUGH);
			return;
		}

		if (bossDataManager.getBoss().getBossState() != BossState.BOSS_DIE) {
			handler.sendErrorMsgToPlayer(GameError.BOSS_NOT_END);
			return;
		}

		if (bossDataManager.hadGetHurtRankAward(player.roleId)) {
			handler.sendErrorMsgToPlayer(GameError.ALREADY_GET_BOX);
			return;
		}

		int rank = bossDataManager.getHurtRank(player.roleId);
		if (rank < 1 || rank > 10) {
			handler.sendErrorMsgToPlayer(GameError.NOT_ON_RANK);
			return;
		}

		bossDataManager.setHurtRankAward(player.roleId);

		BossHurtAwardRs.Builder builder = BossHurtAwardRs.newBuilder();

		List<List<Integer>> awards = staticWarAwardDataMgr.getHurtAward(rank);
		builder.addAllAward(playerDataManager.addAwardsBackPb(player, awards, AwardFrom.BOSS_HURT));

		handler.sendMsgToPlayer(BossHurtAwardRs.ext, builder.build());
	}

	static final double[] RESORCE_FACTOR = { 0.024, 0.018, 0.012, 0.006, 0.006 };

	/**
	 * 
	 * Method: fightBoss
	 * 
	 * @Description: 挑战世界boss
	 * @param handler
	 * @return void

	 */
	public void fightBoss(ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		if (player.lord.getLevel() < 30) {
			handler.sendErrorMsgToPlayer(GameError.LV_NOT_ENOUGH);
			return;
		}

		if (bossDataManager.getBoss().getBossState() != BossState.FIGHT_STATE) {
			handler.sendErrorMsgToPlayer(GameError.BOSS_END);
			return;
		}

		BossFight b = bossDataManager.getBossFight(player.roleId);
		int now = TimeHelper.getCurrentSecond();
		int leftTime = b.getAttackTime() + 60 - now;
		if (leftTime > 0) {
			// handler.sendErrorMsgToPlayer(GameError.BOSS_CD);
			FightBossRs.Builder builder = FightBossRs.newBuilder();
			builder.setResult(2);
			builder.setColdTime(b.getAttackTime());
			handler.sendMsgToPlayer(FightBossRs.ext, builder.build());
			return;
		}

		Form form = player.forms.get(FormType.BOSS);
		if (form == null) {
			handler.sendErrorMsgToPlayer(GameError.BOSS_FORM);
			return;
		}

		int originWhich = bossDataManager.getBoss().getBossWhich();
		Fighter attacker = fightService.createFighter(b, player, form, AttackType.ACK_OTHER);
		Fighter boss = fightService.createBoss(bossDataManager.getBoss());

		FightLogic fightLogic = new FightLogic(attacker, boss, FirstActType.ATTACKER, true);
		fightLogic.fightBoss();

		haustBossTank(bossDataManager.getBoss(), boss);

		FightBossRs.Builder builder = FightBossRs.newBuilder();
		CommonPb.Record record = fightLogic.generateRecord();
		int result = (fightLogic.getWinState() == 1) ? 1 : -1;

		builder.setResult(result);
		builder.setRecord(record);

		bossDataManager.addHurt(b, attacker.hurt);

		if (result == 1) {
			bossDataManager.setBossState(BossState.BOSS_DIE);
			clearAutoFight();
			bossDataManager.setKiller(player.lord.getNick());
			List<CommonPb.Award> awards = new ArrayList<CommonPb.Award>();
			awards.add(PbHelper.createAwardPb(AwardType.PROP, PropId.SANT_HERO_CHIP, 25));
			awards.add(PbHelper.createAwardPb(AwardType.PROP, PropId.HERO_BOX_2, 2));
			playerDataManager.sendAttachMail(AwardFrom.FIGHT_BOSS,player, awards, MailType.MOLD_KILL_BOSS, TimeHelper.getCurrentSecond());

			chatService.sendWorldChat(chatService.createSysChat(SysChatId.BOSS_KILL, player.lord.getNick()));
		} else {
			b.setAttackTime(now);
			builder.setColdTime(now);
		}

		int which = bossDataManager.getBoss().getBossWhich();
		for (int i = 0; i < which - originWhich; i++) {
			List<CommonPb.Award> awards = new ArrayList<CommonPb.Award>();
			awards.add(PbHelper.createAwardPb(AwardType.PROP, PropId.SANT_HERO_CHIP, 1));
			awards.add(PbHelper.createAwardPb(AwardType.PROP, PropId.HERO_BOX_1, 5));
			playerDataManager.sendAttachMail(AwardFrom.FIGHT_BOSS,player, awards, MailType.MOLD_HURT_BOSS, TimeHelper.getCurrentSecond());
			chatService.sendWorldChat(chatService.createSysChat(SysChatId.BOSS_HURT, player.lord.getNick()));
//			LogHelper.BOSS_LOGGER.error("boss kill:" + player.lord.getNick() + player.roleId + "|" + (originWhich + i) + "|" + attacker.hurt);
			LogUtil.boss("boss kill:" + player.lord.getNick() + player.roleId + "|" + (originWhich + i) + "|" + attacker.hurt);
		}

		int resourceType = RandomHelper.randomInSize(5) + 1;
		int resource = (int) (attacker.hurt * RESORCE_FACTOR[resourceType - 1]);
		playerDataManager.addAward(player, AwardType.RESOURCE, resourceType, resource, AwardFrom.ATTACK_BOSS);
		playerDataManager.updTask(player, TaskType.COND_WORLD_BOSS, 1);//更新攻打世界boss的任务
		builder.addAward(PbHelper.createAwardPb(AwardType.RESOURCE, resourceType, resource));
		builder.setHurt(b.getHurt());
		builder.setRank(bossDataManager.getHurtRank(player.roleId));
		builder.setWhich(which);
		builder.setBossHp(bossDataManager.getBoss().getBossHp());
		handler.sendMsgToPlayer(FightBossRs.ext, builder.build());

//		LogHelper.BOSS_LOGGER.error("boss resource:" + player.lord.getNick() + player.roleId + "|" + resourceType + "|" + resource);
		LogUtil.boss("boss resource:" + player.lord.getNick() + player.roleId + "|" + resourceType + "|" + resource);
	}

	/**
	 * 
	* 计算boss被打到剩多少血了
	* @param boss
	* @param fighter  boss的fighter
	* void
	 */
	private void haustBossTank(Boss boss, Fighter fighter) {
		for (int i = 0; i < fighter.forces.length; i++) {
			Force force = fighter.forces[i];
			if (force != null) {
				if (force.alive()) {
					bossDataManager.setBossHp(force.count);
					bossDataManager.setBossWhich(i);
					return;
				}
			}
		}

		bossDataManager.setBossWhich(5);
		bossDataManager.setBossHp(0);
	}

	/**
	 * 
	* 打boss
	* @param b  
	* void
	 */
	private void fightBoss(BossFight b) {
		int now = TimeHelper.getCurrentSecond();
		int leftTime = b.getAttackTime() + 60 - now;
		if (leftTime > 0) {
			return;
		}

		Player player = playerDataManager.getPlayer(b.getLordId());
		if (player == null) {
			return;
		}

		Form form = player.forms.get(FormType.BOSS);
		if (form == null) {
			return;
		}

		int originWhich = bossDataManager.getBoss().getBossWhich();
		Fighter attacker = fightService.createFighter(b, player, form, AttackType.ACK_OTHER);
		Fighter boss = fightService.createBoss(bossDataManager.getBoss());

		FightLogic fightLogic = new FightLogic(attacker, boss, FirstActType.ATTACKER, true);
		fightLogic.fightBoss();

		haustBossTank(bossDataManager.getBoss(), boss);

		int result = (fightLogic.getWinState() == 1) ? 1 : -1;
		bossDataManager.addHurt(b, attacker.hurt);

		if (result == 1) {
			bossDataManager.setBossState(BossState.BOSS_DIE);
			clearAutoFight();
			bossDataManager.setKiller(player.lord.getNick());
			List<CommonPb.Award> awards = new ArrayList<CommonPb.Award>();
			awards.add(PbHelper.createAwardPb(AwardType.PROP, PropId.SANT_HERO_CHIP, 25));
			awards.add(PbHelper.createAwardPb(AwardType.PROP, PropId.HERO_BOX_2, 2));
			playerDataManager.sendAttachMail(AwardFrom.FIGHT_BOSS,player, awards, MailType.MOLD_KILL_BOSS, TimeHelper.getCurrentSecond());

			chatService.sendWorldChat(chatService.createSysChat(SysChatId.BOSS_KILL, player.lord.getNick()));
		} else {
			b.setAttackTime(now);
		}

		int which = bossDataManager.getBoss().getBossWhich();
		for (int i = 0; i < which - originWhich; i++) {
			List<CommonPb.Award> awards = new ArrayList<CommonPb.Award>();
			awards.add(PbHelper.createAwardPb(AwardType.PROP, PropId.SANT_HERO_CHIP, 1));
			awards.add(PbHelper.createAwardPb(AwardType.PROP, PropId.HERO_BOX_1, 5));
			playerDataManager.sendAttachMail(AwardFrom.FIGHT_BOSS,player, awards, MailType.MOLD_HURT_BOSS, TimeHelper.getCurrentSecond());

			chatService.sendWorldChat(chatService.createSysChat(SysChatId.BOSS_HURT, player.lord.getNick()));
//			LogHelper.BOSS_LOGGER.error("boss kill:" + player.lord.getNick() + player.roleId + "|" + (originWhich + i) + "|" + attacker.hurt);
			LogUtil.boss("boss kill:" + player.lord.getNick() + player.roleId + "|" + (originWhich + i) + "|" + attacker.hurt);
		}

		int resourceType = RandomHelper.randomInSize(5) + 1;
		int resource = (int) (attacker.hurt * RESORCE_FACTOR[resourceType - 1]);
		playerDataManager.addAward(player, AwardType.RESOURCE, resourceType, resource, AwardFrom.ATTACK_BOSS);
		playerDataManager.updTask(player, TaskType.COND_WORLD_BOSS, 1);//更新攻打世界boss的任务
//		LogHelper.BOSS_LOGGER.error("boss resource:" + player.lord.getNick() + player.roleId + "|" + resourceType + "|" + resource);
		LogUtil.boss("boss resource:" + player.lord.getNick() + player.roleId + "|" + resourceType + "|" + resource);
		playerDataManager.synResourceToPlayer(player, resourceType, resource);
	}

	/**
	 * 
	*   时间到了自动打boss
	* void
	 */
	private void autoFight() {
		Map<Long, BossFight> map = bossDataManager.getPlayerMap();
		Iterator<BossFight> it = map.values().iterator();
		while (it.hasNext()) {
			if (bossDataManager.getBoss().getBossState() != BossState.FIGHT_STATE) {
				return;
			}

			BossFight bossFight = (BossFight) it.next();
			if (bossFight.getAutoFight() == 1) {
				fightBoss(bossFight);
			}
		}
	}

	/**
	 * 
	*   清除自动打boss设置
	* void
	 */
	private void clearAutoFight() {
		Map<Long, BossFight> map = bossDataManager.getPlayerMap();
		Iterator<BossFight> it = map.values().iterator();
		while (it.hasNext()) {
			BossFight bossFight = (BossFight) it.next();
			bossFight.setAutoFight(0);
		}
	}

	/**
	 * 
	*   boss定时器调用 
	* void
	 */
	public void bossTimerLogic() {
		if (TimeHelper.isBossDay()) {
			Boss boss = bossDataManager.getBoss();
			if (TimeHelper.isBossBegin()) {
				int nowDay = TimeHelper.getCurrentDay();
				if (boss.getBossCreateTime() != nowDay) {
					bossDataManager.refreshBoss();
				}
			} else if (TimeHelper.isBossFightBegin()) {
				if (boss.getBossState() == BossState.PREPAIR_STATE) {
					bossDataManager.setBossState(BossState.FIGHT_STATE);
				}
			} else if (TimeHelper.isBossFightEnd()) {
				if (boss.getBossState() == BossState.FIGHT_STATE) {
					bossDataManager.setBossState(BossState.BOSS_END);
					clearAutoFight();
				}
			}

			if (boss.getBossState() == BossState.FIGHT_STATE) {
				autoFight();
			}
		}
	}
}
