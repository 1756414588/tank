package com.game.service;

import com.game.constant.ArmyState;
import com.game.constant.AwardFrom;
import com.game.constant.GameError;
import com.game.constant.SysChatId;
import com.game.dataMgr.StaticHonourSurviveMgr;
import com.game.dataMgr.StaticWarAwardDataMgr;
import com.game.dataMgr.StaticWorldDataMgr;
import com.game.domain.Player;
import com.game.domain.p.Army;
import com.game.domain.p.ArmyStatu;
import com.game.domain.p.Guard;
import com.game.domain.s.StaticHonourScoreGold;
import com.game.domain.s.StaticMine;
import com.game.domain.s.StaticMineLv;
import com.game.honour.domain.HonourConstant;
import com.game.honour.domain.HonourPartyScore;
import com.game.honour.domain.HonourRoleScore;
import com.game.honour.domain.SafeArea;
import com.game.manager.*;
import com.game.message.handler.ClientHandler;
import com.game.pb.BasePb;
import com.game.pb.CommonPb.HonourRank;
import com.game.pb.GamePb6.*;
import com.game.server.GameServer;
import com.game.util.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.LinkedList;
import java.util.List;

/**
 * @author: LiFeng
 * @date:
 * @description:
 */
@Component
public class HonourSurviveService {

	@Autowired
	private HonourDataManager honourDataManager;

	@Autowired
	private PlayerDataManager playerDataManager;

	@Autowired
	private WorldService worldService;

	@Autowired
	private PartyDataManager partyDataManager;

	@Autowired
	private WorldDataManager worldDataManager;

	@Autowired
	private StaticWorldDataMgr staticWorldDataMgr;

	@Autowired
	private WorldMineService worldMineService;

	@Autowired
	private ChatService chatService;

	@Autowired
	private StaticWarAwardDataMgr staticWarAwardDataMgr;

	@Autowired
	private StaticHonourSurviveMgr staticHonourSurviveMgr;

	@Autowired
	private RewardService rewardService;

	@Autowired
	private StaffingDataManager staffingDataManager;
	/**
	 * 当前是毒圈第几阶段
	 * 
	 * @see  以下配置为例 , [60,420],[480,720],[780,1020],[1080,1260]]，0<=now<60表示0， 60<=now<420表示-1，420<=now<480表示1...
	 * 
	 * @return 0表示毒圈尚未出现，-1表示第一阶段开始缩圈，1表示第一阶段到第二阶段的暂停期；-2 表示第二阶段开始缩圈，2表示第二阶段到第三阶段的暂停期，依次类推;
	 */
	public int inWhichPhase() {
		int phase = 0;
		List<Integer[]> list = HonourConstant.refreshTime;
		if (list == null || list.isEmpty()) {
			LogUtil.error("HonourSurvive miss config : refreshTime");
			return phase = 0;
		}
		int haveOpen = honourDataManager.haveOpen();
		if (haveOpen == 0 || haveOpen < list.get(0)[0]) {
			return phase = 0;
		}
		for (int i = 0; i < list.size(); i++) {
			Integer[] duration = list.get(i);
			int start = duration[0];
			int end = duration[1];
			if (i == list.size() - 1 && haveOpen >= end) {
				phase = i + 1;
				break;
			}
			if (haveOpen >= start && haveOpen < end) {
				phase = -i - 1;
			}
			if (haveOpen >= end && haveOpen < list.get(i + 1)[0]) {
				phase = i + 1;
			}
		}
		return phase;
	}

	/**
	 * 通知客户端更新安全区范围
	 * 
	 * @param player 区分是通知所有玩家（player == null）还是单个玩家
	 */
	public void synUpdateSafeArea(Player player) {
		SafeArea safeArea = honourDataManager.getSafeArea();
		if (safeArea == null) {
			LogUtil.error("honourSurvive safeArea init failed, safeArea == null");
			return;
		}
		SynUpdateSafeAreaRq.Builder honourBuilder = SynUpdateSafeAreaRq.newBuilder();
		honourBuilder.setXbegin(safeArea.getBeginx());
		honourBuilder.setYbegin(safeArea.getBeginy());
		honourBuilder.setXend(safeArea.getEndx());
		honourBuilder.setYend(safeArea.getEndy());
		int phase = safeArea.getPhase();
		honourBuilder.setPhase(Math.abs(phase));
		BasePb.Base.Builder msg = PbHelper.createSynBase(SynUpdateSafeAreaRq.EXT_FIELD_NUMBER, SynUpdateSafeAreaRq.ext,
				honourBuilder.build());
		if (player == null) {
			for (Player p : playerDataManager.getAllOnlinePlayer().values()) {
				if (p != null && p.ctx != null) {
					try {
						GameServer.getInstance().synMsgToPlayer(p.ctx, msg);
					} catch (Exception e) {
						LogUtil.error("荣耀生存同步安全区出错 | roleId : " + p.lord.getLordId(), e);
					}
				}
			}
		} else {
			GameServer.getInstance().synMsgToPlayer(player.ctx, msg);
		}
	}

	/**
	 * 玩家登陆时，通知荣耀生存玩法已开启或关闭（一次玩法期间推送一次）
	 * 
	 * @param player
	 * @param type 1表示通知开启；2表示通知关闭
	 */
	public void notifyOpenOrClose(Player player, int type) {
		if (type == 1) {
			if (!honourDataManager.isOpen() || player.honourNotify == true)
				return;
		}
		SynHonourSurviveOpenRq.Builder honourBuilder = SynHonourSurviveOpenRq.newBuilder();
		honourBuilder.setType(type);
		BasePb.Base.Builder msg = PbHelper.createSynBase(SynHonourSurviveOpenRq.EXT_FIELD_NUMBER, SynHonourSurviveOpenRq.ext,
				honourBuilder.build());
		GameServer.getInstance().synMsgToPlayer(player.ctx, msg);
		player.honourNotify = true;
	}

	/**
	 * 开始或刚登陆时，预告下一个安全区
	 * 
	 * @param phase 当前阶段
	 * @param player 区分是通知所有玩家（player == null）还是单个玩家
	 */
	public void synNextSafeArea(int phase, Player player) {
		if (phase < 0) {
			return;
		}
		SynNextSafeAreaRq.Builder honourBuilder = SynNextSafeAreaRq.newBuilder();
		honourBuilder.setPhase(0);

		if (phase >= honourDataManager.getPoints().size()) {
			phase = honourDataManager.getPoints().size() - 1;
			// phase为1即通知客户端不再显示下一个安全区提示
			honourBuilder.setPhase(1);
		}

		Tuple<Integer, Integer> tuple = honourDataManager.getPoints().get(phase);
		int length = HonourConstant.halfLength.get(phase);
		int pos = tuple.getA() + tuple.getB() * 600;
		honourBuilder.setPos(pos);
		honourBuilder.setLength(length);
		honourBuilder.setStartTime(honourDataManager.calcPhaseOpenTime(-(phase + 1)) * 60);
		honourBuilder.setEndTime(honourDataManager.calcPhaseOpenTime(phase + 1) * 60);
		BasePb.Base.Builder msg = PbHelper.createSynBase(SynNextSafeAreaRq.EXT_FIELD_NUMBER, SynNextSafeAreaRq.ext, honourBuilder.build());
		if (player == null) {
			for (Player p : playerDataManager.getAllOnlinePlayer().values()) {
				if (p != null && p.ctx != null) {
					try {
						GameServer.getInstance().synMsgToPlayer(p.ctx, msg);
					} catch (Exception e) {
						LogUtil.error("荣耀生存同步下一个安全区出错 | roleId : " + p.lord.getLordId(), e);
					}
				}
			}
		} else {
			GameServer.getInstance().synMsgToPlayer(player.ctx, msg);
		}
	}

	public void getHonourPlayerRank(ClientHandler handler) {
		GetHonourRankRs.Builder builder = GetHonourRankRs.newBuilder();
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		int rank = honourDataManager.getPlayerRank(handler.getRoleId());
		int score;
		HonourRoleScore honourScore = player.honourScore;
		if (honourScore != null)
			score = honourScore.getScore();
		else
			score = 0;
		builder.setRank(rank);
		builder.setScore(score);
		int status;
		if (honourDataManager.isOpen()) {
			status = 2; // 不可领取
		} else if (rank > 0 && rank <= HonourConstant.playerRankTop) {
			if (honourDataManager.getPlayerRankAward().contains(handler.getRoleId()))
				status = 3; // 已领取
			else
				status = 1; // 可领取
		} else {
			status = 2;
		}
		builder.setAwardStatus(status);
		List<HonourRank> honourRank = new LinkedList<>();
		LinkedList<HonourRoleScore> playerRank = honourDataManager.getHonourPlayerRank();
		for (HonourRoleScore honourRoleScore : playerRank) {
			String nick = playerDataManager.getPlayer(honourRoleScore.getRoleId()).lord.getNick();
			int pscore = honourRoleScore.getScore();
			int prank = honourDataManager.getPlayerRank(honourRoleScore.getRoleId());
			prank = prank < 0 ? 0 : prank + 1;
			honourRank.add(PbHelper.createHonourRank(prank, pscore, nick));
		}
		builder.addAllRankList(honourRank);
		handler.sendMsgToPlayer(GetHonourRankRs.ext, builder.build());
	}

	public void getHonourPartyRank(ClientHandler handler) {
		GetHonourRankRs.Builder builder = GetHonourRankRs.newBuilder();
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		if (partyDataManager.getPartyId(handler.getRoleId()) == 0) {
			handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
			return;
		}
		int partyId = player.getHonourPartyId();
		if(honourDataManager.isOpen()) {
			partyId = partyDataManager.getPartyId(player.lord.getLordId());
		}
		String partyName;
		if (partyDataManager.getParty(partyId) == null) {
			partyName = "";
		} else {
			partyName = partyDataManager.getParty(partyId).getPartyName();
		}
		builder.setPartyName(partyName);
		HonourPartyScore honourPartyScore = honourDataManager.getPartyScoreByPartyId(partyId);
		int partyScore;
		if (honourPartyScore != null)
			partyScore = honourPartyScore.getScore();
		else
			partyScore = 0;
		builder.setScore(partyScore);
		int rank = honourDataManager.getPartyRank(partyId);
		builder.setRank(rank);
		int status;
		if (honourDataManager.isOpen() || player.honourScore == null
				|| player.honourScore.getScore() < HonourConstant.partyRankAwardLimit) {
			status = 2; // 不可领取
		} else if (rank > 0 && rank <= HonourConstant.playerRankTop) {
			if (honourDataManager.getPartyRankAward().contains(handler.getRoleId()))
				status = 3; // 已领取
			else
				status = 1; // 可领取
		} else {
			status = 2;
		}
		builder.setAwardStatus(status);

		List<HonourRank> honourRank = new LinkedList<>();
		LinkedList<HonourPartyScore> partyRank = honourDataManager.getHonourPartyRank();
		for (HonourPartyScore partyScore2 : partyRank) {
			String name = partyDataManager.getParty(partyScore2.getPartyId()).getPartyName();
			int score = partyScore2.getScore();
			int rank2 = honourDataManager.getPartyRank(partyScore2.getPartyId());
			honourRank.add(PbHelper.createHonourRank(rank2, score, name));
		}
		builder.addAllRankList(honourRank);
		handler.sendMsgToPlayer(GetHonourRankRs.ext, builder.build());
	}

	/**
	 * 拉取活动状态
	 */
	public void GetHonourStatus(ClientHandler handler) {
		GetHonourStatusRs.Builder builder = GetHonourStatusRs.newBuilder();
		if (honourDataManager.isOpen()) {
			builder.setStatus(0);
		} else {
			builder.setStatus(1);
		}
		handler.sendMsgToPlayer(GetHonourStatusRs.ext, builder.build());
	}

	/**
	 * 第四阶段开始后，采集加速，重新计算所有已经在采集的部队
	 */
	private void recollectArmy(int now) {
		List<Integer> posList = honourDataManager.getPosInArea(honourDataManager.getSafeArea());
		int i = 0;
		for (int pos : posList) {
			Guard guard = worldDataManager.getMineGuard(pos);
			StaticMine staticMine = worldDataManager.evaluatePos(pos);
			if (staticMine == null || guard == null) {
				continue;
			}
			StaticMineLv staticMineLv = staticWorldDataMgr.getStaticMineLvWolrd(staticMine.getLv(),staffingDataManager.getWorldMineLevel() );
			if (staticMineLv == null) {
				continue;
			}
			Player player = guard.getPlayer();
			Army army = guard.getArmy();
			if (army.getState() != ArmyState.COLLECT) {
				continue;
			}
			if (army.getEndTime() < now || army.getEndTime() - army.getPeriod() > now) {
				continue;
			}
			int collect = worldMineService.getMineProdunction(pos, staticMineLv.getProduction());
			long get = playerDataManager.calcCollect(player, army, now, staticMine,
					worldMineService.getMineProdunction(pos, staticMineLv.getProduction()));
			worldService.recollectArmy(player, army, now, staticMine, collect, get);
			playerDataManager.synArmyToPlayer(player, new ArmyStatu(player.roleId, army.getKeyId(), 4));
			i++;
		}
		LogUtil.common("HonourSurvive 4th phase recollectArmy count : " + i);
	}

	// /**
	// * 第四阶段开始后，采集获得金币
	// *
	// * @see 第四阶段开始后，每隔60分钟（配置时间）计算一次采集金币，采集时间time满60分钟加一次金币， 目前存在一个问题，玩家在第N次计算金币和第N+1次计算金币的周期之间进行下矿并被攻击，
	// * （没被消灭的情况下）被攻击之前金币采集的累积时间会清空，已采集的金币不受影响
	// * @param now 当前时间，精确到分
	// */
	// private void recollectGold(int now) {
	// int phaseOpen = honourDataManager.caclPhaseOpenTime(HonourConstant.refreshTime.size());
	// List<Integer> posList = honourDataManager.getPosInArea(honourDataManager.getSafeArea());
	// for (int pos : posList) {
	// Guard guard = worldDataManager.getMineGuard(pos);
	// StaticMine staticMine = worldDataManager.evaluatePos(pos);
	// if (staticMine == null || guard == null) {
	// continue;
	// }
	// StaticMineLv staticMineLv = staticWorldDataMgr.getStaticMineLv(staticMine.getLv());
	// if (staticMineLv == null) {
	// continue;
	// }
	// Army army = guard.getArmy();
	// if (army.getState() != ArmyState.COLLECT) {
	// continue;
	// }
	// if (army.getPeriod() < HonourConstant.goldTime * 60) {
	// continue;
	// }
	// // 实际buff作用期间的采集时间
	// int hasCollect;
	// // 预期结束采集的时间点
	// int armyEnd = army.getEndTime() / 60;
	// if (armyEnd < phaseOpen) {
	// continue;
	// }
	// int armyStart = (army.getEndTime() - army.getPeriod()) / 60;
	// // 这个周期内开始采集金币的时间点
	// int beginTime = army.getHonourGoldTime();
	// if (beginTime == 0) {
	// // 采集金币BUFF作用于army的实际生效开始时间
	// beginTime = armyStart > phaseOpen ? armyStart : phaseOpen;
	// }
	//
	// // 采集金币BUFF在这60分钟内的实际结束时间
	// int endTime = armyEnd > now ? now : armyEnd;
	// // 剩余采集时间不足以等到下一个金币统计时间点
	// if (beginTime < now && armyEnd < now + HonourConstant.goldTime) {
	// hasCollect = armyEnd - beginTime;
	// } else {
	// hasCollect = endTime - beginTime;
	// }
	// // 如果计算出的实际有效采集时间超出预计，记录一下方便测试
	// if (hasCollect < 0 || hasCollect > HonourConstant.duration - HonourConstant.refreshTime.getLast()[1]) {
	// LogUtil.error("HonourSurvie 4th phase collect gold cacl Error | hasCollect : " + hasCollect + " | nick : "
	// + guard.getPlayer().lord.getNick() + " | armyKeyId : " + army.getKeyId());
	// continue;
	// }
	//
	// int rate = hasCollect / HonourConstant.goldTime;
	// // hasCollect == 0表示刚开始采集金币，记录最初的时间，避免之后因为不足一小时被攻击而丢失部分实际采集时间
	// if (rate > 0 || hasCollect == 0) {
	// army.setHonourGold(army.getHonourGold() + rate * staticMineLv.getHonourLiveGold());
	// army.setHonourGoldTime(beginTime + HonourConstant.goldTime * rate);
	// }
	// }
	// }

	public void getPlayerRankAward(ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		int rank = honourDataManager.getPlayerRank(handler.getRoleId());
		if (rank <= 0 || rank > HonourConstant.playerRankTop) {
			handler.sendErrorMsgToPlayer(GameError.NOT_ON_RANK);
			return;
		}
		if (honourDataManager.isReceiveAward(player, 1)) {
			handler.sendErrorMsgToPlayer(GameError.HAVE_RECEIVE);
			return;
		}
		List<List<Integer>> rewards = staticWarAwardDataMgr.getHonourLiveRankReward(rank);
		if (rewards == null) {
			handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
			return;
		}
		honourDataManager.getPlayerRankAward().add(handler.getRoleId());
		GetHonourRankAwardRs.Builder builder = GetHonourRankAwardRs.newBuilder();
		builder.addAllAward(playerDataManager.addAwardsBackPb(player, rewards, AwardFrom.HONOUR_SURVIVE_PLAYER_RANK));
		handler.sendMsgToPlayer(GetHonourRankAwardRs.ext, builder.build());
	}

	/**
	 * 领取军团榜奖励
	 * 
	 * @param handler
	 */
	public void getPartyRankAward(ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		if (partyDataManager.getPartyId(handler.getRoleId()) == 0) {
			handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
			return;
		}
		int partyId = player.getHonourPartyId();
		int rank = honourDataManager.getPartyRank(partyId);
		if (rank <= 0 || rank > HonourConstant.partyRankTop) {
			handler.sendErrorMsgToPlayer(GameError.NOT_ON_RANK);
			return;
		}
		if (honourDataManager.isReceiveAward(player, 2)) {
			handler.sendErrorMsgToPlayer(GameError.HAVE_RECEIVE);
			return;
		}
		List<List<Integer>> rewards = staticWarAwardDataMgr.getHonourLivePartyRankReward(rank);
		if (rewards == null) {
			handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
			return;
		}
		honourDataManager.getPartyRankAward().add(handler.getRoleId());
		GetHonourRankAwardRs.Builder builder = GetHonourRankAwardRs.newBuilder();
		builder.addAllAward(playerDataManager.addAwardsBackPb(player, rewards, AwardFrom.HONOUR_SURVIVE_PARTY_RANK));
		handler.sendMsgToPlayer(GetHonourRankAwardRs.ext, builder.build());
	}

	public void honourCollectInfo(ClientHandler handler, HonourCollectInfoRq req) {
		if (!honourDataManager.isOpen()) {
			handler.sendErrorMsgToPlayer(GameError.HONOURLIVE_NOT_OPEN);
			return;
		}
		int keyId = req.getKeyId();
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		boolean find = false;
		Army army = null;
		for (Army e : player.armys) {
			if (e.getKeyId() == keyId) {
				find = true;
				army = e;
				break;
			}
		}

		if (!find) {
			handler.sendErrorMsgToPlayer(GameError.NO_ARMY);
			return;
		}
		HonourCollectInfoRs.Builder builder = HonourCollectInfoRs.newBuilder();
		// 负数表示与客户端约定的不显示这两条数据
		builder.setHonourScore(-1);
		builder.setHonourGold(-1);

		if(army.getSenior() || army.isCrossMine()){
			handler.sendMsgToPlayer(HonourCollectInfoRs.ext, builder.build());
			return;
		}

		int pos = army.getTarget();
		StaticMine staticMine = worldDataManager.evaluatePos(pos);
		if (staticMine == null) {
			handler.sendMsgToPlayer(HonourCollectInfoRs.ext, builder.build());
			return;
		}
		StaticMineLv staticMineLv = staticWorldDataMgr.getStaticMineLvWolrd(staticMine.getLv(),staffingDataManager.getWorldMineLevel());
		if (staticMineLv == null) {
			handler.sendMsgToPlayer(HonourCollectInfoRs.ext, builder.build());
			return;
		}
		if (army.getState() != ArmyState.COLLECT) {
			handler.sendMsgToPlayer(HonourCollectInfoRs.ext, builder.build());
			return;
		}
		int honourScore = honourDataManager.calcHonourScore(army, TimeHelper.getCurrentSecond(), staticMineLv.getHonourLiveScore(), pos);
		int honourGold = honourDataManager.calcHonourCollectGold(army, TimeHelper.getCurrentMinute());
		builder.setHonourScore(honourScore);
		builder.setHonourGold(honourGold);
		handler.sendMsgToPlayer(HonourCollectInfoRs.ext, builder.build());
	}

	public void honourScoreGoldInfo(ClientHandler handler) {
		HonourScoreGoldInfoRs.Builder builder = HonourScoreGoldInfoRs.newBuilder();
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		int score = 0;
		if (player.honourScore != null) {
			score = player.honourScore.getScore();
		} else {
			score = 0;
		}
		StaticHonourScoreGold scoreGold = staticHonourSurviveMgr.getHonourScoreGoldBySocre(score);
		if (scoreGold != null) {
			builder.setAwardId(scoreGold.getId());
		} else {
			builder.setAwardId(0);
		}
		int status = player.getHonourScoreGoldStatus();
		if (!honourDataManager.isOpen() && scoreGold != null && status == 0) {
			player.setHonourScoreGoldStatus(1);
			status = 1;
		}
		builder.setScore(score);
		builder.setStatus(status);
		handler.sendMsgToPlayer(HonourScoreGoldInfoRs.ext, builder.build());
	}

	public void getHonourScoreGold(ClientHandler handler, GetHonourScoreGoldRq req) {
		if (honourDataManager.isOpen()) {
			handler.sendErrorMsgToPlayer(GameError.ACT_NOT_AWARD_TIME);
			return;
		}
		int awardId = req.getAwardId();
		StaticHonourScoreGold scoreGold = staticHonourSurviveMgr.getHonourScoreGoldByAwardId(awardId);
		if (scoreGold == null) {
			handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
		}
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		int score = 0;
		if (player.honourScore != null) {
			score = player.honourScore.getScore();
		} else {
			score = 0;
		}
		if (score < scoreGold.getScore1() || (scoreGold.getScore2() != 0 && score >= scoreGold.getScore2())) {
			handler.sendErrorMsgToPlayer(GameError.ACT_AWARD_COND_LIMIT);
			return;
		}
		if (player.getHonourScoreGoldStatus() != 1) {
			handler.sendErrorMsgToPlayer(GameError.HAVE_RECEIVE);
			return;
		}
		GetHonourScoreGoldRs.Builder builder = GetHonourScoreGoldRs.newBuilder();
		builder.setAward(rewardService.addAwardBackPb(player, scoreGold.getGoldreward(), AwardFrom.HONOUR_SCORE_GOLD));
		player.setHonourScoreGoldStatus(2);
		handler.sendMsgToPlayer(GetHonourScoreGoldRs.ext, builder.build());
	}

	/**
	 * 活动结束时计算所有部队的采集金币并记录，需要在endClear之前执行
	 */
	private void caclCollectGold() {
		int now = TimeHelper.getCurrentMinute();
		int gold = 0;
		try {
			int phaseOpen = honourDataManager.calcPhaseOpenTime(4);
			List<Integer> posList = honourDataManager.getPosInArea(honourDataManager.getInitSafeAreas().get(4));
			for (int pos : posList) {
				Guard guard = null;
				try {
					guard = worldDataManager.getMineGuard(pos);
					StaticMine staticMine = worldDataManager.evaluatePos(pos);
					if (staticMine == null || guard == null) {
						continue;
					}
					StaticMineLv staticMineLv = staticWorldDataMgr.getStaticMineLvWolrd(staticMine.getLv(),staffingDataManager.getWorldMineLevel());
					if (staticMineLv == null) {
						continue;
					}
					Army army = guard.getArmy();
					if (army.getState() != ArmyState.COLLECT) {
						continue;
					}
					// 4阶段才开始产生金币
					int armyEnd = army.getEndTime() / 60;
					// 如果当前时间小于第四阶段开启时间，或者采集结束时间小于活动开启时间，不加金币
					if (now < phaseOpen || armyEnd < honourDataManager.getOpenTime()) {
						gold = 0;
					}

					// 金币采集生效开始时间
					int goldBegin = army.getCollectBeginTime() / 60;
					goldBegin = goldBegin < phaseOpen ? phaseOpen : goldBegin;

					if (now > honourDataManager.getOpenTime() + HonourConstant.duration) {
						now = honourDataManager.getOpenTime() + HonourConstant.duration;
					}
					// 金币采集实际结算时间
					int goldEnd = armyEnd > now ? now : armyEnd;
					if (goldEnd <= goldBegin) {
						gold = 0;
					}
					int hasCollect = goldEnd - goldBegin;
					// 仅一次采集跨两个玩法时可能出现这种情况
					if (hasCollect > HonourConstant.duration - HonourConstant.refreshTime.getLast()[1]) {
						hasCollect = HonourConstant.duration - HonourConstant.refreshTime.getLast()[1];
					}
					gold = hasCollect / HonourConstant.goldTime * staticMineLv.getHonourLiveGold();
					army.setHonourGold(army.getHonourGold() + gold);
				} catch (Exception e) {
					LogUtil.error("HonourSurvive calcGold error || pos : " + pos + "" + guard.getPlayer().lord.getLordId(), e);
				}
			}
		} catch (Exception e) {
			LogUtil.error("HonourSurvive calcGold error", e);
		}
	}

	/**
	 * 荣耀生存玩法开启定时器
	 */
	public void honourLogic(int dayOfMonth, int hourOfDay, int minute) {
		if (DateHelper.getServerOpenDay() < HonourConstant.openLimit) {
			return;
		}
		int now = TimeHelper.getCurrentMinute();
		// 虽然支持配置玩法开启时间，但不支持在玩法开启时间段内改配置
		for (int day : HonourConstant.openDayInMonth) {
			if (dayOfMonth == day) {
				int state = honourDataManager.isOpenTime(hourOfDay, minute);
				if (-1 == state) {
					return;
				}
				if (0 == state) {
					chatService.sendWorldChat(chatService.createSysChat(SysChatId.HONOURl_LIVE_OPEN));
					chatService.sendWorldChat(chatService.createSysChat(SysChatId.HONOURl_LIVE_PHASE, String.valueOf(1)));
				}
				if (!honourDataManager.isOpen()) {
					honourDataManager.openHonourSurvive(day);
				}

				/**
				 * 为了提高效率而做的条件限制；前提，玩法持续时间必须跨天；这里其实还可以再加一个dayOfMonth 和 day的差值判断，如dayOfMonth -day <5 ,以减少进入else{}的次数，
				 * 但需要服务器保证一次停服的时间不大于 （5 - 玩法持续天数）
				 */
			} else if (dayOfMonth > day) {
				int expectedEndTime = honourDataManager.calcExpectedEndTime(day);
				// 如果在应该开启的时间内未开启，则再次开启活动
				if (now < expectedEndTime && !honourDataManager.isOpen()) {
					honourDataManager.openHonourSurvive(day);
				}
				int haveOpen = honourDataManager.haveOpen();

				// 如果活动已经开启，且已超过结束的时间点，结束活动
				if (haveOpen >= HonourConstant.duration) {
					if (!honourDataManager.isNotifyClose()) {
						caclCollectGold();
						honourDataManager.endClear();
						for (Player player : playerDataManager.getAllOnlinePlayer().values()) {
							try {
								notifyOpenOrClose(player, 2);
							} catch (Exception e) {
								LogUtil.error("荣耀生存通知玩家活动结束报错 | roleId : " + player.lord.getLordId(), e);
							}
						}
						// 发活动结束公告
						chatService.sendWorldChat(chatService.createSysChat(SysChatId.HONOURl_LIVE_CLOSE));
						honourDataManager.setNotifyClose(true);
					}
				}
			}
		}

		if (honourDataManager.isOpen()) {
			// 如果由于长时间停服而跨月了，清除活动信息
			if (!TimeHelper.isSameMonth(honourDataManager.getOpenTime() * 60000L)) {
				caclCollectGold();
				honourDataManager.endClear();
				return;
			}
			int haveOpen = honourDataManager.haveOpen();
			int oldPhase = honourDataManager.getPhase();
			honourDataManager.updateSafeArea();
			int phase = honourDataManager.getPhase();
			if (oldPhase != phase || honourDataManager.getSafeArea().isFlag() == true) {
				if (phase == 4) {
					recollectArmy(TimeHelper.getCurrentSecond());
				}
				synUpdateSafeArea(null);
			}

			// 每阶段缩圈结束时，通知下一个安全区的位置
			List<Integer[]> refreshTime = HonourConstant.refreshTime;
			for (int i = 0; i < refreshTime.size(); i++) {
				if (haveOpen == refreshTime.get(i)[1]) {
					if (phase == 4) {
						chatService.sendWorldChat(chatService.createSysChat(SysChatId.HONOURl_LIVE_FINAL));
					} else {
						chatService.sendWorldChat(chatService.createSysChat(SysChatId.HONOURl_LIVE_PHASE, String.valueOf(phase + 1)));
						synNextSafeArea(phase, null);
					}
				}
			}
		}
	}

}
