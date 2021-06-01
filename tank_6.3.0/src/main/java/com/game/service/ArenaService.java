/**   
 * @Title: ArenaService.java    
 * @Package com.game.service    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年9月7日 下午3:38:36    
 * @version V1.0   
 */
package com.game.service;

import com.game.constant.*;
import com.game.dataMgr.StaticHeroDataMgr;
import com.game.dataMgr.StaticPropDataMgr;
import com.game.dataMgr.StaticVipDataMgr;
import com.game.domain.Player;
import com.game.domain.p.*;
import com.game.domain.s.StaticArenaAward;
import com.game.domain.s.StaticHero;
import com.game.domain.s.StaticProp;
import com.game.domain.s.StaticVip;
import com.game.fight.FightLogic;
import com.game.fight.domain.Fighter;
import com.game.manager.*;
import com.game.message.handler.ClientHandler;
import com.game.pb.CommonPb;
import com.game.pb.CommonPb.Report;
import com.game.pb.CommonPb.RptAtkArena;
import com.game.pb.GamePb1.*;
import com.game.pb.GamePb2.GetRankRs;
import com.game.pb.GamePb3.BuyArenaCdRq;
import com.game.pb.GamePb3.BuyArenaCdRs;
import com.game.util.LogUtil;
import com.game.util.PbHelper;
import com.game.util.TimeHelper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Iterator;
import java.util.List;
import java.util.Map;

/**
 * @ClassName: ArenaService
 * @Description: 
 * @author ZhangJun
 * @date 2015年9月7日 下午3:38:36
 * 
 */
@Service
public class ArenaService {
	@Autowired
	private PlayerDataManager playerDataManager;

	@Autowired
	private ArenaDataManager arenaDataManager;

	@Autowired
	private StaticHeroDataMgr staticHeroDataMgr;

	@Autowired
	private StaticPropDataMgr staticPropDataMgr;

	@Autowired
	private StaticVipDataMgr staticVipDataMgr;

	@Autowired
	private FightService fightService;

	@Autowired
	private ActivityService activityService;

	@Autowired
	private ChatService chatService;

	@Autowired
	private PartyDataManager partyDataManager;

	@Autowired
	private ActivityDataManager activityDataManager;

	@Autowired
	private GlobalDataManager globalDataManager;

	final static public int ARENA_LV = 15;

	/**
	 * 
	 * Method: getArena
	 * 
	 * @Description: 获取竞技场数据 @param handler @return void @throws
	 */
	public void getArena(ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		GetArenaRs.Builder builder = GetArenaRs.newBuilder();
		if (player.lord.getLevel() >= ARENA_LV) {
			Arena arena = arenaDataManager.enterArena(player.roleId);
			if (arena != null) {
				builder.setCount(arena.getCount());
				builder.setScore(arena.getScore());
				builder.setRank(arena.getRank());
				builder.setLastRank(arena.getLastRank());
				builder.setWinCount(arena.getWinCount());
				builder.setFight(arena.getFight());
				builder.setBuyCount(arena.getBuyCount());
				builder.setColdTime(arena.getColdTime());
				int nowDay = TimeHelper.getCurrentDay();
				if (arena.getAwardTime() != nowDay) {
					builder.setAward(false);
				} else {
					builder.setAward(true);
				}

				List<Arena> list = arenaDataManager.randomEnemy(arena.getRank());
				for (int i = 0; i < list.size(); i++) {
					Arena one = list.get(i);
					if (one == null) {
						// LogHelper.ERROR_LOGGER.error("getArena get a null
						// rank:" + player.roleId);
						LogUtil.error("getArena get a null rank:" + player.roleId);
						continue;
					}

					Player player1 = playerDataManager.getPlayer(one.getLordId());
					if(player1 == null ){
						LogUtil.error("getArena get b null rank:" + one.getLordId());
						continue;
					}

					builder.addRankPlayer(PbHelper.createRankPlayer(one, player1));
				}

				int unRead = 0;
				Iterator<Mail> it = player.getMails().values().iterator();
				while (it.hasNext()) {
					Mail mail = it.next();
					if (mail.getType() == MailType.ARENA_MAIL && mail.getState() == MailType.STATE_UNREAD) {
						++unRead;
					}
				}
				builder.setUnread(unRead);
			}
		}

		Arena champion = arenaDataManager.getArenaByRank(1);
		if (champion != null) {
			Player championPlayer = playerDataManager.getPlayer(champion.getLordId());
			if (championPlayer != null) {
				builder.setChampion(championPlayer.lord.getNick());
			}
		}
		handler.sendMsgToPlayer(GetArenaRs.ext, builder.build());
	}

	/**
	 * 
	 * Method: initArena
	 * 
	 * @Description: 初始化玩家竞技场 @param req @param handler @return void @throws
	 */
	public void initArena(InitArenaRq req, ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		if (player.lord.getLevel() < ARENA_LV) {
			handler.sendErrorMsgToPlayer(GameError.LV_NOT_ENOUGH);
			return;
		}

		Arena arena = arenaDataManager.getArena(player.roleId);
		if (arena != null) {
			handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
			return;
		}

		CommonPb.Form form = req.getForm();
		Form attackForm = PbHelper.createForm(form);

		if (attackForm.getType() != FormType.ARENA) {
			handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
			return;
		}

		StaticHero staticHero = null;
		int heroId = 0;
		AwakenHero awakenHero = null;
		Hero hero = null;
		if(attackForm.getAwakenHero() != null){//使用觉醒将领
			awakenHero = player.awakenHeros.get(attackForm.getAwakenHero().getKeyId());
			if(awakenHero == null || awakenHero.isUsed()){
				handler.sendErrorMsgToPlayer(GameError.NO_HERO);
				return;
			}
			attackForm.setAwakenHero(awakenHero.clone());
			heroId = awakenHero.getHeroId();
		} else if (attackForm.getCommander() > 0) {
			hero = player.heros.get(attackForm.getCommander());
			if (hero == null || hero.getCount() <= 0) {
				handler.sendErrorMsgToPlayer(GameError.NO_HERO);
				return;
			}
			heroId = hero.getHeroId();
		}
		
		if(heroId != 0){
			staticHero = staticHeroDataMgr.getStaticHero(heroId);
			if (staticHero == null) {
				handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
				return;
			}
			
			if (staticHero.getType() != 2) {
				handler.sendErrorMsgToPlayer(GameError.NOT_HERO);
				return;
			}
		}

		int maxTankCount = playerDataManager.formTankCount(player, staticHero, awakenHero);
		if (!playerDataManager.checkTank(player, attackForm, maxTankCount)) {
			handler.sendErrorMsgToPlayer(GameError.TANK_COUNT);
			return;
		}

		player.forms.put(FormType.ARENA, attackForm);

		long fight = fightService.calcFormFight(player, attackForm);
		arena = arenaDataManager.addNew(player.roleId);
		arena.setFight(fight);
		playerDataManager.updDay7ActSchedule(player, 8,arena.getRank());

		InitArenaRs.Builder builder = InitArenaRs.newBuilder();
		builder.setRank(arena.getRank());
		builder.setCount(arena.getCount());
		builder.setFight(fight);
		List<Arena> list = arenaDataManager.randomEnemy(arena.getRank());
		for (int i = 0; i < list.size(); i++) {
			Arena one = list.get(i);
			builder.addRankPlayer(PbHelper.createRankPlayer(one, playerDataManager.getPlayer(one.getLordId())));
		}

		handler.sendMsgToPlayer(InitArenaRs.ext, builder.build());
	}

	/**
	 * 
	* 竞技场功方或者守方信息
	* @param player
	* @param hero
	* @param haust
	* @param firstValue
	* @return  
	* CommonPb.RptMan
	 */
	private CommonPb.RptMan createRptMan(Player player, int hero, Map<Integer, RptTank> haust, int firstValue) {
		CommonPb.RptMan.Builder builder = CommonPb.RptMan.newBuilder();
		Lord lord = player.lord;
		builder.setName(lord.getNick());
		builder.setVip(lord.getVip());
		builder.setFirstValue(firstValue);
		String party = partyDataManager.getPartyNameByLordId(player.roleId);
		if (party != null) {
			builder.setParty(party);
		}

		if (hero != 0) {
			builder.setHero(hero);
		}

		if (haust != null) {
			Iterator<RptTank> it = haust.values().iterator();
			while (it.hasNext()) {
				builder.addTank(PbHelper.createRtpTankPb(it.next()));
			}
		}

		return builder.build();
	}

	/**
	 * 
	* 进攻方战报
	* @param rpt
	* @param now
	* @return  
	* Report
	 */
	private Report createAtkArenaReport(RptAtkArena rpt, int now) {
		Report.Builder report = Report.newBuilder();
		report.setAtkArena(rpt);
		report.setTime(now);
		return report.build();
	}

	/**
	 * 
	* 防守方战报
	* @param rpt
	* @param now
	* @return  
	* Report
	 */
	private Report createDefArenaReport(RptAtkArena rpt, int now) {
		Report.Builder report = Report.newBuilder();
		report.setDefArena(rpt);
		report.setTime(now);
		return report.build();
	}

	/**
	 * 
	* 全服战报
	* @param rpt
	* @param now
	* @return  
	* Report
	 */
	private Report createGloabalArenaReport(RptAtkArena rpt, int now) {
		Report.Builder report = Report.newBuilder();
		report.setGlobalArena(rpt);
		report.setTime(now);
		return report.build();
	}

	/**
	 * 
	 * Method: doArena
	 * 
	 * @Description: 竞技场挑战 @param rank @param handler @return void @throws
	 */
	public void doArena(int rank, ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		if (player.lord.getLevel() < ARENA_LV) {
			handler.sendErrorMsgToPlayer(GameError.LV_NOT_ENOUGH);
			return;
		}

		Map<Integer, Equip> store = player.equips.get(0);
		if (store.size() >= player.lord.getEquip()) {
			handler.sendErrorMsgToPlayer(GameError.MAX_EQUIP_STORE);
			return;
		}

		Arena arena = arenaDataManager.enterArena(player.roleId);
		if (arena == null) {
			handler.sendErrorMsgToPlayer(GameError.SERVER_EXCEPTION);
			return;
		}

		if (arena.getCount() <= 0) {
			handler.sendErrorMsgToPlayer(GameError.ARENA_COUNT);
			return;
		}

		int now = TimeHelper.getCurrentSecond();
		if (now < arena.getColdTime() + 10 * 60) {
			handler.sendErrorMsgToPlayer(GameError.ARENA_CD);
			return;
		}

		Form form = player.forms.get(FormType.ARENA);
		if (form == null) {
			handler.sendErrorMsgToPlayer(GameError.ARENA_FORM);
			return;
		}

		Arena targetArena = arenaDataManager.getArenaByRank(rank);
		if (targetArena == null) {
			handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
			return;
		}

		if (targetArena.getLordId() == player.roleId) {
			handler.sendErrorMsgToPlayer(GameError.ARENA_ERROR);
			return;
		}

		Player target = playerDataManager.getPlayer(targetArena.getLordId());
		if (target == null) {
			handler.sendErrorMsgToPlayer(GameError.SERVER_EXCEPTION);
			return;
		}

		Form targetForm = target.forms.get(FormType.ARENA);
		if (targetForm == null) {
			handler.sendErrorMsgToPlayer(GameError.ARENA_FORM);
			return;
		}

		Fighter attacker = fightService.createFighter(player, form, AttackType.ACK_PLAYER);
		Fighter defencer = fightService.createFighter(target, targetForm, AttackType.ACK_PLAYER);

		FightLogic fightLogic = new FightLogic(attacker, defencer, FirstActType.FISRT_VALUE_2, true);
		fightLogic.packForm(form, targetForm);
		fightLogic.fight();

		CommonPb.Record record = fightLogic.generateRecord();
		int result = (fightLogic.getWinState() == 1) ? 1 : -1;

		Map<Integer, RptTank> attackHaust = fightService.statisticHaustTank(attacker);
		Map<Integer, RptTank> defenceHaust = fightService.statisticHaustTank(defencer);

		RptAtkArena.Builder rpt = RptAtkArena.newBuilder();
		rpt.setFirst(fightLogic.attackerIsFirst());
		rpt.setAttacker(createRptMan(player, form.getAwakenHero() != null ? form.getAwakenHero().getHeroId() : form.getCommander(), attackHaust, attacker.firstValue));
		rpt.setDefencer(createRptMan(target, targetForm.getAwakenHero() != null ?  targetForm.getAwakenHero().getHeroId() : targetForm.getCommander(), defenceHaust, defencer.firstValue));
		
		rpt.setRecord(record);

		DoArenaRs.Builder builder = DoArenaRs.newBuilder();
		builder.setRecord(record);
		builder.setForm(PbHelper.createFormPb(targetForm));
		builder.setResult(result);
		builder.setFirstValue1(attacker.firstValue);
		builder.setFirstValue2(defencer.firstValue);
		int scoreAward = 0;
		if (result == 1) {
			boolean aquirement = false;
			if (arena.getRank() > targetArena.getRank()) {
				arenaDataManager.exchangeArena(arena, targetArena);
				if (arena.getRank() == 1) {
					aquirement = true;
					chatService.sendWorldChat(
							chatService.createSysChat(SysChatId.ARENA_2, player.lord.getNick(), target.lord.getNick()));
				}
				playerDataManager.updDay7ActSchedule(player, 8,arena.getRank());
				playerDataManager.updDay7ActSchedule(target, 8,targetArena.getRank());
			}

			arena.setWinCount(arena.getWinCount() + 1);
			targetArena.setWinCount(0);

			scoreAward = scoreAward(arena.getWinCount());
			// arena.setScore(arena.getScore() + scoreAward);
			playerDataManager.addArenaScore(player, scoreAward, AwardFrom.DO_ARENA);

			// 竞技场宝箱
			playerDataManager.addProp(player, PropId.ARENA_BOX, 1, AwardFrom.DO_ARENA);

			CommonPb.Award box = PbHelper.createAwardPb(AwardType.PROP, PropId.ARENA_BOX, 1);
			CommonPb.Award score = PbHelper.createAwardPb(AwardType.SCORE, 0, scoreAward);
			builder.addAward(box);
			builder.setScore(arena.getScore());

			rpt.addAward(box);
			rpt.addAward(score);
			rpt.setResult(true);

			RptAtkArena rptAtkArena = rpt.build();
			playerDataManager.sendArenaReportMail(player, createAtkArenaReport(rptAtkArena, now), MailType.MOLD_ARENA_3,
					now, target.lord.getNick());
			playerDataManager.sendArenaReportMail(target, createDefArenaReport(rptAtkArena, now), MailType.MOLD_ARENA_5,
					now, player.lord.getNick());

			if (arena.getRank() <= 10 || targetArena.getRank() <= 10) {
				globalDataManager.addGlobalReportMail(createGloabalArenaReport(rptAtkArena, now), MailType.MOLD_ARENA_2,
						now, player.lord.getNick(), target.lord.getNick());
			}

			if (!aquirement && arena.getWinCount() % 5 == 0) {
				chatService.sendWorldChat(chatService.createSysChat(SysChatId.ARENA_1, player.lord.getNick(),
						String.valueOf(arena.getWinCount())));
			}

			activityDataManager.updActivity(player, ActivityConst.ACT_CRAZY_ARENA, 1, 0);

		} else {
			scoreAward = 5;
			arena.setWinCount(0);
			arena.setColdTime(TimeHelper.getCurrentSecond());
			arena.setScore(arena.getScore() + scoreAward);

			// 装备卡【50】
			int keyId = playerDataManager.addEquip(player, 701, 1, 0, AwardFrom.DO_ARENA).getKeyId();

			CommonPb.Award equip = PbHelper.createAwardPb(AwardType.EQUIP, 701, 1, keyId);
			CommonPb.Award score = PbHelper.createAwardPb(AwardType.SCORE, 0, scoreAward);

			builder.addAward(equip);
			builder.setScore(arena.getScore());
			builder.setColdTime(arena.getColdTime());

			rpt.addAward(equip);
			rpt.addAward(score);
			rpt.setResult(false);

			RptAtkArena rptAtkArena = rpt.build();
			playerDataManager.sendArenaReportMail(player, createAtkArenaReport(rptAtkArena, now), MailType.MOLD_ARENA_4,
					now, target.lord.getNick());
			playerDataManager.sendArenaReportMail(target, createDefArenaReport(rptAtkArena, now), MailType.MOLD_ARENA_6,
					now, player.lord.getNick());

			if (arena.getRank() <= 10 || targetArena.getRank() <= 10) {
				globalDataManager.addGlobalReportMail(createGloabalArenaReport(rptAtkArena, now), MailType.MOLD_ARENA_1,
						now, player.lord.getNick(), target.lord.getNick());
			}
		}

		arena.setCount(arena.getCount() - 1);
		playerDataManager.updTask(player, TaskType.COND_ARENA, 1, null);
		handler.sendMsgToPlayer(DoArenaRs.ext, builder.build());
	}

	/**
	 * 
	 * Method: buyArena
	 * 
	 * @Description: 购买竞技场次数 @param handler @return void @throws
	 */
	public void buyArena(ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());

		Arena arena = arenaDataManager.enterArena(player.roleId);
		if (arena == null) {
			handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
			return;
		}

		if (arena.getBuyCount() >= buyCount(player)) {
			handler.sendErrorMsgToPlayer(GameError.MAX_BUY_ARENA);
			return;
		}

		int cost = 10 + arena.getBuyCount() * 2;
		cost = (cost > 100) ? 100 : cost;
		if (player.lord.getGold() < cost) {
			handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
			return;
		}

		playerDataManager.subGold(player, cost, AwardFrom.BUY_ARENA);
		arena.setCount(arena.getCount() + 1);
		arena.setBuyCount(arena.getBuyCount() + 1);

		BuyArenaRs.Builder builder = BuyArenaRs.newBuilder();
		builder.setCount(arena.getCount());
		builder.setGold(player.lord.getGold());
		handler.sendMsgToPlayer(BuyArenaRs.ext, builder.build());
	}

	/**
	 * 
	 * Method: useScore
	 * 
	 * @Description: 竞技场积分兑换 @param propId @param handler @return void @throws
	 */
	public void useScore(int propId, ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		Arena arena = arenaDataManager.enterArena(player.roleId);
		if (arena == null) {
			handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
			return;
		}

		StaticProp staticProp = staticPropDataMgr.getStaticProp(propId);
		if (staticProp == null) {
			handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
			return;
		}

		if (staticProp.getArenaScore() == 0) {
			handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
			return;
		}

		if (arena.getScore() < staticProp.getArenaScore()) {
			handler.sendErrorMsgToPlayer(GameError.ARENA_SCORE);
			return;
		}

		// arena.setScore(arena.getScore() - staticProp.getArenaScore());
		playerDataManager.addArenaScore(player, -staticProp.getArenaScore(), AwardFrom.ARENA_SCORE);

		if (propId == PropId.TOOL) {//
			playerDataManager.addPartMaterial(player, 5, 1, AwardFrom.ARENA_SCORE);
		} else {
			playerDataManager.addAward(player, AwardType.PROP, propId, 1, AwardFrom.ARENA_SCORE);
		}

		UseScoreRs.Builder builder = UseScoreRs.newBuilder();
		builder.setScore(arena.getScore());
		handler.sendMsgToPlayer(UseScoreRs.ext, builder.build());
	}

	/**
	 * 
	 * Method: arenaAward
	 * 
	 * @Description: 领取排名奖励 @param handler @return void @throws
	 */
	public void arenaAward(ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		Arena arena = arenaDataManager.enterArena(player.roleId);
		if (arena == null) {
			handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
			return;
		}

		if (arena.getLastRank() > 500) {
			handler.sendErrorMsgToPlayer(GameError.RANK_NOT_ENOUGH);
			return;
		}

		int nowDay = TimeHelper.getCurrentDay();
		if (arena.getAwardTime() == nowDay) {
			handler.sendErrorMsgToPlayer(GameError.ALREADY_ARENA_AWARD);
			return;
		}

		StaticArenaAward staticArenaAward = arenaDataManager.getRankAward(arena.getLastRank());
		if (staticArenaAward == null) {
			handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
			return;
		}

		arena.setAwardTime(nowDay);

		ArenaAwardRs.Builder builder = ArenaAwardRs.newBuilder();
		builder.addAllAward(
				playerDataManager.addAwardsBackPb(player, staticArenaAward.getAward(), AwardFrom.ARENA_RANK));
		handler.sendMsgToPlayer(ArenaAwardRs.ext, builder.build());
	}

	/**
	 * 
	* 竞技场购买次数
	* @param player
	* @return  
	* int
	 */
	private int buyCount(Player player) {
		StaticVip staticVip = staticVipDataMgr.getStaticVip(player.lord.getVip());
		if (staticVip != null) {
			return staticVip.getBuyArena();
		}

		return 1;
	}

	/**
	 * 
	* 积分奖励
	* @param winCount
	* @return  
	* int
	 */
	private int scoreAward(int winCount) {
		if (winCount < 6) {
			return 10;
		} else if (winCount < 11) {
			return 12;
		} else if (winCount < 21) {
			return 14;
		} else if (winCount < 51) {
			return 16;
		} else if (winCount < 101) {
			return 18;
		} else {
			return 20;
		}
	}

	/**
	 * 
	* 排行信息
	* @param page
	* @param handler  
	* void
	 */
	public void getRankData(int page, ClientHandler handler) {
		GetRankRs.Builder builder = GetRankRs.newBuilder();
		int begin = (page - 1) * 20 + 1;
		int end = page * 20 + 1;
		for (int i = begin; i < end; i++) {
			Arena arena = arenaDataManager.getArenaByRank(i);
			if (arena != null) {
				Lord lord = playerDataManager.getPlayer(arena.getLordId()).lord;
				if (lord != null) {
					builder.addRankData(PbHelper.createRankData(lord.getNick(), lord.getLevel(), arena.getFight(),0));
				}
			}
		}

		Arena arena = arenaDataManager.getArena(handler.getRoleId());
		int rank = 0;
		if (arena != null) {
			rank = arena.getRank();
		}
		builder.setRank(rank);
		handler.sendMsgToPlayer(GetRankRs.ext, builder.build());
	}

	/**
	 * 
	* 金币清除cd
	* @param req
	* @param handler  
	* void
	 */
	public void buyArenaCd(BuyArenaCdRq req, ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());

		Arena arena = arenaDataManager.enterArena(player.roleId);
		if (arena == null) {
			handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
			return;
		}

		int now = TimeHelper.getCurrentSecond();
		// if (now < arena.getColdTime() + 10 * 60) {
		// handler.sendErrorMsgToPlayer(GameError.ARENA_CD);
		// return;
		// }

		int leftTime = arena.getColdTime() + 10 * 60 - now;
		if (leftTime > 0) {
			int cost = (int) Math.ceil(leftTime / 60.0);
			if (player.lord.getGold() < cost) {
				handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
				return;
			}

			playerDataManager.subGold(player, cost, AwardFrom.ARENA_CD);
			arena.setColdTime(now - 60 * 10);
		}

		BuyArenaCdRs.Builder builder = BuyArenaCdRs.newBuilder();
		builder.setGold(player.lord.getGold());
		handler.sendMsgToPlayer(BuyArenaCdRs.ext, builder.build());
	}

	/**
	 * 
	 * Method: arenaTimerLogic
	 * 
	 * @Description: 竞技场定时器逻辑 @return void @throws
	 */
	public void arenaTimerLogic() {
		ArenaLog serverLog = arenaDataManager.getArenaLog();
		int nowDay = TimeHelper.getCurrentDay();
		if (nowDay != serverLog.getArenaTime()) {
			dayRank(nowDay);
			activityService.activityTimeLogic();
			arenaDataManager.setArenaLog(new ArenaLog(nowDay, 0));
			arenaDataManager.flushArenaLog();
		}
	}

	/**
	 * 
	* 凌晨获取昨天排行
	* @param awardDay  
	* void
	 */
	private void dayRank(int awardDay) {
		arenaDataManager.getLastRankMap().clear();

		Iterator<Arena> it = arenaDataManager.getRankMap().values().iterator();
		int rank;
		Arena arena = null;
		while (it.hasNext()) {
			arena = (Arena) it.next();
			try {
				rank = arena.getRank();
				arena.setLastRank(rank);
				
				// 上次排名(200名)
				if (arena.getLastRank() >= 1 && arena.getLastRank() <= 200) {
					arenaDataManager.getLastRankMap().put(arena.getLastRank(), arena);
				}
			} catch (Exception e) {
				LogUtil.error("竞技场定时器报错, arena:" + arena, e);
			}
		}
	}

}
