/**
 * @Title: PlayerService.java
 * @Package com.game.service
 * @Description:
 * @author ZhangJun
 * @date 2015年8月3日 下午1:21:20
 * @version V1.0
 */
package com.game.service;

import com.alibaba.fastjson.JSONArray;
import com.game.actor.log.LogEventService;
import com.game.actor.role.PlayerEventService;
import com.game.common.ServerSetting;
import com.game.constant.*;
import com.game.dao.impl.p.AccountDao;
import com.game.dataMgr.*;
import com.game.domain.Player;
import com.game.domain.p.*;
import com.game.domain.s.*;
import com.game.manager.*;
import com.game.message.handler.ClientHandler;
import com.game.message.handler.DealType;
import com.game.message.handler.Handler;
import com.game.message.handler.ServerHandler;
import com.game.pb.BasePb.Base;
import com.game.pb.CommonPb;
import com.game.pb.CommonPb.Award;
import com.game.pb.GamePb1.*;
import com.game.pb.GamePb2.*;
import com.game.pb.GamePb3.DoPartyTipAwardRs;
import com.game.pb.GamePb4.*;
import com.game.pb.GamePb5.Day7ActLvUpRs;
import com.game.pb.GamePb5.GetDay7ActRs;
import com.game.pb.GamePb5.GetDay7ActTipsRs;
import com.game.pb.GamePb5.RecvDay7ActAwardRs;
import com.game.pb.GamePb6.GetActiveBoxAwardRq;
import com.game.pb.GamePb6.GetActiveBoxAwardRs;
import com.game.pb.InnerPb.*;
import com.game.persistence.SavePlayerOptimizeTask;
import com.game.server.GameServer;
import com.game.server.ICommand;
import com.game.server.util.ChannelUtil;
import com.game.util.*;
import io.netty.channel.ChannelHandlerContext;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.Map.Entry;

/**
 * @author ZhangJun
 * @ClassName: PlayerService
 * @Description: 玩家相关逻辑
 * @date 2015年8月3日 下午1:21:20
 */
@Service
public class PlayerService {

    @Autowired
    private AccountDao accountDao;

    @Autowired
    private PlayerDataManager playerDataManager;

    @Autowired
    private StaticLordDataMgr staticLordDataMgr;

    @Autowired
    private StaticPropDataMgr staticPropDataMgr;

    @Autowired
    private StaticHeroDataMgr staticHeroDataMgr;

    @Autowired
    private StaticVipDataMgr staticVipDataMgr;

    @Autowired
    private StaticEquipDataMgr staticEquipDataMgr;

    @Autowired
    private StaticAwardsDataMgr staticAwardsDataMgr;

    @Autowired
    private StaticActivityDataMgr staticActivityDataMgr;

    @Autowired
    private StaticIniDataMgr staticIniDataMgr;

    @Autowired
    private StaticBackDataMgr staticBackDataMgr;

    @Autowired
    private ServerSetting serverSetting;

    @Autowired
    private ActivityDataManager activityDataManager;

    @Autowired
    private WorldDataManager worldDataManager;

    @Autowired
    private RankDataManager rankDataManager;

    @Autowired
    private CombatService combatService;

    @Autowired
    private ChatService chatService;

    @Autowired
    private WorldService worldService;

    @Autowired
    private LogEventService logEventService;

    @Autowired
    private SmallIdManager smallIdManager;

    @Autowired
    private StaticFortressDataMgr staticFortressDataMgr;

    @Autowired
    private StaticWarAwardDataMgr staticWarAwardDataMgr;

    @Autowired
    private DrillDataManager drillDataManager;

    @Autowired
    private StaticFunctionPlanDataMgr staticFunctionPlanDataMgr;

    @Autowired
    private PlayerEventService playerEventService;

    @Autowired
    private ArmyService armyService;

    @Autowired
    private FightService fightService;

    @Autowired
    private DataRepairDM dataRepairDM;

    @Autowired
    private HonourDataManager honourDataManager;

    @Autowired
    private HonourSurviveService honourSurviveService;

    @Autowired
    private StaticActiveBoxDataMgr staticActiveBoxDataMgr;
    @Autowired
    private SavePlayerOptimizeTask savePlayerOptimizeTask;

    /**
     * Method: saveTimerLogic
     *
     * @Description: 定时保存玩家数据 @return void @throws
     */
    public void saveTimerLogic() {
        int now = TimeHelper.getCurrentSecond();
        savePlayerOptimizeTask.saveTimerLogic(now);

    }

    /**
     * Method: beginGame
     *
     * @Description: 客户端发过来的登陆验证请求，这里转发给账号服务器做验证 @param req @return void @throws
     */
    public void beginGame(BeginGameRq req, Handler handler) {
        int keyId = req.getKeyId();
        String token = req.getToken();
        int serverId = req.getServerId();
        String curVersion = req.getCurVersion();
        String deviceNo = req.getDeviceNo();

        VerifyRq.Builder builder = VerifyRq.newBuilder();
        builder.setKeyId(keyId);
        builder.setServerId(serverId);
        builder.setToken(token);
        builder.setCurVersion(curVersion);
        builder.setDeviceNo(deviceNo);
        builder.setChannelId(handler.getChannelId());
        Base.Builder baseBuilder = PbHelper.createRqBase(VerifyRq.EXT_FIELD_NUMBER, null, VerifyRq.ext, builder.build());
        handler.sendMsgToPublic(baseBuilder);
    }

    /**
     * Method: roleLogin
     *
     * @Description: 登陆 @param handler @return void @throws
     */
    public void roleLogin(ClientHandler handler) {
        RoleLoginRs.Builder builder = RoleLoginRs.newBuilder();
        builder.setState(1);

        Player player = playerDataManager.getPlayer(handler.getRoleId());

        if (player == null) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }

        if (player.account.getCreated() != 1) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }

        ChannelHandlerContext preCtx = player.ctx;
        player.ctx = handler.getCtx();
        if (player.isLogin) {
            if (preCtx != null) {
                StcHelper.synLoginElseWhere(preCtx);
                // preCtx.close();
            }
        } else {
            player.setLogin(true);
            player.logIn();
            playerDataManager.checkPendant(player);
            playerDataManager.checkPortrait(player);
            playerDataManager.addOnline(player);
        }

        // 封测送vip
        // Calendar now = Calendar.getInstance();
        // int day = now.get(Calendar.DAY_OF_MONTH);
        // int vip = player.lord.getVip();
        // if (vip < day - 4) {
        // player.lord.setVip(day - 4);
        // }

        // 添加低等级经验加成buff
        addLevelExpBuff(player);

        if (honourDataManager.isOpen()) {
            honourSurviveService.notifyOpenOrClose(player, 1);
            honourSurviveService.synUpdateSafeArea(player);
            int phase = honourDataManager.getPhase();
            phase = phase >= 0 ? phase : -phase - 1;
            honourSurviveService.synNextSafeArea(Math.abs(phase), player);
        }

        playerDataManager.loginWelfare(player);

        if (TimeHelper.isWarOpen()) {
            builder.setWar(1);
        }

        if (TimeHelper.isBossOpen()) {
            builder.setBoss(1);
        }

        if (TimeHelper.isStaffingOpen()) {
            builder.setStaffing(1);
        }

        if (TimeHelper.isFortresssOpen()) {
            builder.setFortress(1);

            // FortressJobAppoint f = warDataManager.getFortressJobAppointMapByLordId().get(handler.getRoleId());
            // if (f != null && f.getEndTime() >= TimeHelper.getCurrentSecond()) {
            // StaticFortressJob s = staticFortressDataMgr.getFortressJob(f.getJobId());
            //
            // int chatId = SysChatId.Buff_Job_On_Line;
            // if (s.getBuffType() == FortressFightConst.DeBuff) {
            // chatId = SysChatId.DeBuff_Job_On_Line;
            // }
            //
            // // 发系统公告
            // chatService.sendWorldChat(chatService.createSysChat(chatId, s.getName(), player.lord.getNick()));
            // }
        }

        // 玩家是否已报名红蓝大战
        builder.setDrill(drillDataManager.getEnrolledRoleSet().contains(player.lord.getLordId()));

        // 跨服战是否开启
        if (TimeHelper.isCrossOpen(CrossConst.CrossType)) {
            builder.setCrossFight(1);
        }

        // 跨服军团战是否开启
        if (TimeHelper.isCrossOpen(CrossConst.CrossPartyType)) {
            builder.setCrossParty(1);
        }

        handler.sendMsgToPlayer(RoleLoginRs.ext, builder.build());

        LogHelper.logLogin(player);
        // 向Gdps 发送登录记录
        logEventService.sendRoleLogin2Gdps(player);
    }

    /**
     * Method: verifyRs
     *
     * @Description: 账号服务器的验证返回处理 @param req @return void @throws
     */
    public void verifyRs(VerifyRs req, ServerHandler handler, ChannelHandlerContext playerCtx) {
        int platNo = req.getPlatNo();
        int childNo = req.getChildNo();
        String platId = req.getPlatId();
        int keyId = req.getKeyId();
        int serverId = req.getServerId();
        // String curVersion = req.getCurVersion();
        String deviceNo = req.getDeviceNo();

        BeginGameRs.Builder builder = BeginGameRs.newBuilder();
        Date now = new Date();

        String ip = ChannelUtil.getIp(playerCtx, 0);

        Account account = playerDataManager.getAccount(serverId, keyId);
        if (account == null) {
            account = new Account();
            account.setServerId(serverId);
            account.setAccountKey(keyId);
            account.setPlatId(platId);
            account.setPlatNo(platNo);
            account.setChildNo(childNo);
            account.setDeviceNo(deviceNo);
            account.setLoginDays(1);
            account.setCreateDate(new Date());
            account.setLoginDate(new Date());
            account.setIp(ip);
            if (staticFunctionPlanDataMgr.isPlayerBackOpen()) {
                account.setBackEndTime(new Date());
            }
            playerDataManager.createPlayer(account);
            LogHelper.logRegister(account);
            // player.connected = true;
        } else {
            Account dbAccount = accountDao.selectAccountByKeyId(account.getKeyId());
            if (dbAccount != null) {
                // 若是小号，走创建流程,但不创建account
                if (smallIdManager.isSmallId(dbAccount.getLordId())) {
                    playerDataManager.createPlayerAfterCutSmallId(account);
                } else {
                    account.setIsGm(dbAccount.getIsGm());
                    account.setIsGuider(dbAccount.getIsGuider());
                    account.setWhiteName(dbAccount.getWhiteName());
                    // account.setForbid(dbAccount.getForbid());
                    account.setLordId(dbAccount.getLordId());

                    // account.setPlatNo(dbAccount.getPlatNo());
                    account.setCreateDate(dbAccount.getCreateDate());
                    account.setLoginDays(dbAccount.getLoginDays());
                    account.setLoginDate(dbAccount.getLoginDate());
                }
                Date loginDate = account.getLoginDate();
                Player player = playerDataManager.getPlayer(account.getLordId());
                if (player != null && staticFunctionPlanDataMgr.isPlayerBackOpen()) {// 如果老玩家回归开启中，则根据玩家上次的登陆天数来给玩家添加老玩家回归状态
                    setPlayerBackState(player, now, loginDate);
                }
                if (!DateHelper.isSameDate(now, loginDate)) {
                    account.setLoginDays(account.getLoginDays() + 1);
                }

                if (player != null && player.lord.getLevel() >= Constant.LAST_MAX_LEVEL) {
                    boolean b = staticLordDataMgr.addExp(player, 0);
                    if (b) {
                        playerDataManager.checkEquipExpOverflow(player);
                        // 向Gdps 发送升级记录
                        logEventService.sendRoleUp2Gdps(player);
                    }
                }
            }
            account.setDeviceNo(deviceNo);
            account.setChildNo(childNo);
            account.setLoginDate(now);
            account.setIp(ip);
            playerDataManager.recordLogin(account);
        }
        if (AccountHelper.isForbid(account)) {
            builder.setState(3);
            builder.setTime(TimeHelper.getCurrentSecond());
            Base.Builder baseBuilder = handler.createRsBase(GameError.OK, BeginGameRs.ext, builder.build());
            GameServer.getInstance().sendMsgToPlayer(playerCtx, baseBuilder);
            return;
        }
        if (account.getCreated() == 1) {// 角色已创建
            builder.setState(2);
        } else {
            builder.setState(1);
            builder.addAllName(generateNames());
        }
        GameServer.getInstance().registerRoleChannel(playerCtx, account.getLordId());
        builder.setTime(TimeHelper.getCurrentSecond());
        Base.Builder baseBuilder = handler.createRsBase(GameError.OK, BeginGameRs.ext, builder.build());
        GameServer.getInstance().sendMsgToPlayer(playerCtx, baseBuilder);
    }

    /**
     * 设置老玩家回归状态
     *
     * @param player
     * @param now
     * @param loginDate void
     */
    private void setPlayerBackState(Player player, Date now, Date loginDate) {// 设置老玩家回归状态
        int state = player.account.getBackState();
        if (player.account.getBackEndTime() != null) {
            if (now.after(player.account.getBackEndTime())) {// 如果现在处于回归状态的结束时间之后，重置玩家的回归状态
                player.account.setBackState(0);
            }
        }
        if ((now.getTime() - loginDate.getTime()) > TimeHelper.DAY_MS * 28) {// 如果距离上次登陆时间相差28天以上,赋予玩家4级回归状态
            state = 4;
            changeBackStates(player, state, now);
        } else if ((now.getTime() - loginDate.getTime()) > TimeHelper.DAY_MS * 21) {// 如果距离上次登陆时间相差21天以上,赋予玩家3级回归状态
            state = 3;
            changeBackStates(player, state, now);
        } else if ((now.getTime() - loginDate.getTime()) > TimeHelper.DAY_MS * 14) {// 如果距离上次登陆时间相差14天以上,赋予玩家2级回归状态
            state = 2;
            changeBackStates(player, state, now);
        } else if ((now.getTime() - loginDate.getTime()) > TimeHelper.DAY_MS * 7) {// 如果距离上次登陆时间相差7天以上,赋予玩家1级回归状态
            state = 1;
            changeBackStates(player, state, now);
        }
        if (state != 0) {// 如果回归状态不等于0则调用赋予玩家回归buff的方法
            playerBackBuff(player);
        }
    }

    /**
     * 设置玩家回归等级
     *
     * @param player
     * @param state
     * @param now    void
     */
    public void changeBackStates(Player player, int state, Date now) {// 设置玩家回归等级
        player.account.setBackState(state);// 设置回归等级
        player.account.setBackEndTime(TimeHelper.getAfter10Days(now));// 设置回归状态结束时间
        player.backAward = new TreeMap<Integer, Integer>();// 根据回归等级创建回归奖励的状态列表
        TreeMap<Integer, StaticBackOne> treeMap = staticBackDataMgr.getBackOneList(player.account.getBackState());// 添加礼物信息
        if (treeMap != null) {
            Iterator<StaticBackOne> it = treeMap.values().iterator();
            while (it.hasNext()) {
                StaticBackOne next = it.next();
                player.backAward.put(next.getKeyId(), -1);// 将所有的礼物状态信息均设置为尚不可领取
            }
        }
    }

    /**
     * Method: useGiftCodeRs
     *
     * @Description: 使用兑换码 @param req @param handler @return void @throws
     */
    public void useGiftCodeRs(final UseGiftCodeRs req, final ServerHandler handler) {
        GameServer.getInstance().mainLogicServer.addCommand(new ICommand() {
            @Override
            public void action() {
                // Auto-generated method stub

                long roleId = req.getLordId();
                String award = req.getAward();

                Player player = playerDataManager.getPlayer(roleId);
                ChannelHandlerContext ctx = player.ctx;

                GiftCodeRs.Builder builder = GiftCodeRs.newBuilder();
                builder.setState(req.getState());

                int state = req.getState();
                if (state != 0) {
                    if (player.isLogin && ctx != null) {
                        Base.Builder baseBuilder = handler.createRsBase(GameError.OK, GiftCodeRs.ext, builder.build());
                        GameServer.getInstance().sendMsgToPlayer(ctx, baseBuilder);
                    }
                    return;
                }

                try {
                    JSONArray arrays = JSONArray.parseArray(award);
                    for (int i = 0; i < arrays.size(); i++) {
                        JSONArray array = arrays.getJSONArray(i);
                        if (array.size() != 3) {
                            continue;
                        }
                        int type = array.getInteger(0);
                        int id = array.getInteger(1);
                        int count = array.getInteger(2);
                        int keyId = playerDataManager.addAward(player, type, id, count, AwardFrom.GIFT_CODE);
                        builder.addAward(PbHelper.createAwardPb(type, id, count, keyId));

                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }

                if (player.isLogin && ctx != null) {
                    Base.Builder baseBuilder = handler.createRsBase(GameError.OK, GiftCodeRs.ext, builder.build());
                    GameServer.getInstance().sendMsgToPlayer(ctx, baseBuilder);
                }
            }
        }, DealType.MAIN);

    }

    /**
     * Method: createRole
     *
     * @Description: 玩家创建角色 @param req @param ctx @return void @throws
     */
    public void createRole(CreateRoleRq req, ClientHandler handler) {
        GameError err;
        int state;
        CreateRoleRs.Builder builder = CreateRoleRs.newBuilder();
        Player newPlayer = playerDataManager.getNewPlayer(handler.getRoleId());
        if (newPlayer == null) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }

        if (newPlayer.account.getCreated() == 1) {
            err = GameError.ALREADY_CREATE;
            builder.setNick(newPlayer.lord.getNick());
            builder.setPortrait(newPlayer.lord.getPortrait());
            state = 3;
        } else {
            String nick = req.getNick();
            int portrait = req.getPortrait();
            int sex = req.getSex();
            nick = nick.replaceAll(" ", "");
            nick = EmojiHelper.replace(nick);

            if (nick == null || nick.isEmpty() || nick.length() >= 12) {
                handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
                return;
            }

            if (EmojiHelper.containsEmoji(nick)) {
                handler.sendErrorMsgToPlayer(GameError.INVALID_CHAR);
                return;
            }

            if (playerDataManager.takeNick(nick)) {
                // newPlayer.account.setNick(nick);
                newPlayer.account.setCreated(1);
                newPlayer.account.setCreateDate(new Date());
                newPlayer.lord.setPortrait(portrait);
                newPlayer.lord.setNick(nick);
                newPlayer.lord.setSex(sex);

                if (playerDataManager.createFullPlayer(newPlayer)) {
                    err = GameError.OK;
                    state = 1;
                    // playerDataManager.removeNewPlayer(newPlayer.roleId);
                    // playerDataManager.addPlayer(newPlayer);
                    changeNewPlayer(newPlayer.roleId, handler);
                    Account account = newPlayer.account;
                    LogHelper.logRegister(account);
                    playerEventService.calcStrongestFormAndFight(newPlayer);
                    // 向Gdps 发送角色记录
                    logEventService.sendRoleCreate2Gdps(newPlayer);
                    return;
                } else {
                    newPlayer.account.setCreated(0);
                    handler.sendErrorMsgToPlayer(GameError.SERVER_EXCEPTION);
                    // LogHelper.ERROR_LOGGER.error("createFullPlayer {" + newPlayer.roleId + "} error");
                    LogUtil.error("createFullPlayer {" + newPlayer.roleId + "} error");
                    return;
                }
            } else {
                err = GameError.SAME_NICK;
                state = 2;
            }
        }

        builder.setState(state);
        handler.sendMsgToPlayer(err, CreateRoleRs.ext, builder.build());
    }

    /**
     * 新建角色时把新角色池里的角色给玩家
     *
     * @param roleId
     * @param handler void
     */
    private void changeNewPlayer(final long roleId, final ClientHandler handler) {
        GameServer.getInstance().mainLogicServer.addCommand(new ICommand() {
            @Override
            public void action() {
                // Auto-generated method stub
                Player newPlayer = playerDataManager.getNewPlayer(roleId);
                if (newPlayer == null) {
                    // LogHelper.ERROR_LOGGER.error("changeNewPlayer {" + roleId + "} error");
                    LogUtil.error("changeNewPlayer {" + roleId + "} error");
                    return;
                }

                playerDataManager.removeNewPlayer(roleId);
                playerDataManager.addPlayer(newPlayer);

                CreateRoleRs.Builder builder = CreateRoleRs.newBuilder();
                builder.setState(1);

                handler.sendMsgToPlayer(GameError.OK, CreateRoleRs.ext, builder.build());
            }
        }, DealType.MAIN);

    }

    /**
     * Method: getLord
     *
     * @Description: 客户端请求玩家数据 @param roleId @param ctx @return void @throws
     */
    public void getLord(ClientHandler handler) {
        Long roleId = handler.getRoleId();
        Player player = playerDataManager.getPlayer(roleId);
        if (player != null) {
            playerDataManager.replaceRuinsName(player);
            Lord lord = playerDataManager.getPlayer(roleId).lord;
            CombatService.cleanExplore(lord);
            restoreProsAndPower(player, TimeHelper.getCurrentSecond());
            GetLordRs.Builder builder = GetLordRs.newBuilder();
            builder.setLordId(lord.getLordId());
            builder.setNick(lord.getNick());
            builder.setPortrait(lord.getPortrait());
            builder.setLevel(lord.getLevel());
            builder.setExp(lord.getExp());
            builder.setVip(lord.getVip());
            builder.setPos(lord.getPos());
            builder.setGold(lord.getGold());
            builder.setRanks(lord.getRanks());
            builder.setCommand(lord.getCommand());
            builder.setFame(lord.getFame());
            builder.setFameLv(lord.getFameLv());
            builder.setHonour(lord.getHonour());
            builder.setPros(lord.getPros());
            builder.setProsMax(lord.getProsMax());
            builder.setProsTime(playerDataManager.leftBackProsTime(lord));
            builder.setPower(lord.getPower());
            builder.setPowerTime(playerDataManager.leftBackPowerTime(lord));
            builder.setNewState(lord.getNewState());
            builder.setFight(lord.getFight());
            builder.setEquip(lord.getEquip());
            builder.setFitting(lord.getFitting());
            builder.setMetal(lord.getMetal());
            builder.setPlan(lord.getPlan());
            builder.setMineral(lord.getMineral());
            builder.setTool(lord.getTool());
            builder.setDraw(lord.getDraw());
            builder.setTankDrive(lord.getTankDrive());
            builder.setChariotDrive(lord.getChariotDrive());
            builder.setArtilleryDrive(lord.getArtilleryDrive());
            builder.setRocketDrive(lord.getRocketDrive());
            Iterator<Entry<Integer, Integer>> it = player.partMatrial.entrySet().iterator();
            while (it.hasNext()) {
                Entry<Integer, Integer> entry = it.next();
                builder.addPartMatrial(PbHelper.createTwoIntPb(entry.getKey(), entry.getValue()));
            }

            builder.setEquipEplr(lord.getEquipEplr());
            builder.setPartEplr(lord.getPartEplr());
            builder.setMilitaryEplr(lord.getMilitaryEplr());
            builder.setExtrEplr(lord.getExtrEplr());
            builder.setTimeEplr(lord.getTimeEplr());
            builder.setEquipBuy(lord.getEquipBuy());
            builder.setPartBuy(lord.getPartBuy());
            builder.setMilitaryBuy(lord.getMilitaryBuy());
            builder.setExtrReset(lord.getExtrReset());
            builder.setEnergyStoneEplrId(lord.getEnergyStoneEplr());
            builder.setEnergyStoneBuy(lord.getEnergyStoneBuy());
            builder.setTimeBuy(lord.getTimeBuy());

            builder.setHuangbao(lord.getHuangbao());
            builder.setCreateRoleTime(player.account.getCreateDate().getTime());

            int nowDay = TimeHelper.getCurrentDay();
            int curTime = TimeHelper.getCurrentSecond();
            if (nowDay != lord.getFameTime1()) {
                builder.setClickFame(true);
            } else {
                builder.setClickFame(false);
            }

            if (nowDay != lord.getFameTime2()) {
                builder.setBuyFame(true);
            } else {
                builder.setBuyFame(false);
            }

            if (nowDay != lord.getScountDate()) {
                builder.setScout(0);
            } else {
                builder.setScout(lord.getScount());
            }

            builder.setSex(lord.getSex());

            refreshBuyPower(lord);
            builder.setBuyPower(lord.getBuyPower());
            builder.setNewerGift(lord.getNewerGift());
            builder.setBuildCount(lord.getBuildCount());

            builder.setOlTime(player.onLineTime());

            builder.setCtTime(lord.getCtTime());
            builder.setOlAward(lord.getOlAward());
            builder.setGm(player.account.getIsGm());
            builder.setGuider(player.account.getIsGuider());
            builder.setTopup(lord.getTopup());
            builder.setPartyTipAward(lord.getPartyTipAward());
            builder.setStaffing(lord.getStaffing());
            builder.setStaffingLv(lord.getStaffingLv());
            builder.setStaffingExp(lord.getStaffingExp());

            builder.setRuins(PbHelper.createRuinsPb(player.ruins));
            builder.setOpenServerDay(DateHelper.getServerOpenDay());

            builder.setDetergent(lord.getDetergent());
            builder.setGrindstone(lord.getGrindstone());
            builder.setPolishingMtr(lord.getPolishingMtr());
            builder.setMaintainOil(lord.getMaintainOil());
            builder.setGrindTool(lord.getGrindTool());
            builder.setPrecisionInstrument(lord.getPrecisionInstrument());
            builder.setMysteryStone(lord.getMysteryStone());
            if (lord.getMedalUpCdTime() > curTime && staticActivityDataMgr.isMedalofhonorActivityOpen()) {
                lord.setMedalUpCdTime(curTime);
            }
            builder.setMedalUpCdTime(lord.getMedalUpCdTime());
            builder.setMedalEplr(lord.getMedalEplr());
            builder.setMedalBuy(lord.getMedalBuy());
            // player.lord.setMaxFight(fightService.calcMaxMaxFight(player));
            builder.setBubbleId(player.getCurrentSkin(SkinType.BUBBLE));
            builder.setCorundumMatrial(lord.getCorundumMatrial());
            builder.setInertGas(lord.getInertGas());
            builder.addAllActiveBox(player.activeBox);
            // 将新老角色发给客户端
            long oldLordId = dataRepairDM.getOldLordId(lord.getLordId());
            if (lord.getLordId() != oldLordId) {
                builder.setOldLordId(oldLordId);
            }


            builder.setTacticsBuy(lord.getTacticsBuy());
            builder.setTacticsReset(lord.getTacticsReset());
            handler.sendMsgToPlayer(GetLordRs.ext, builder.build());
        }
    }

    /**
     * Method: getGuideGift
     *
     * @Description: 领取新手引导礼包 @throws
     */
    public void getGuideGift(ClientHandler handler) {
        Long roleId = handler.getRoleId();
        Player player = playerDataManager.getPlayer(roleId);
        if (player == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }
        Lord lord = player.lord;
        if (lord == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }
        if (lord.getNewerGift() == 1) {
            handler.sendErrorMsgToPlayer(GameError.GIFT_HAD_GOT);
            return;
        }
        StaticAwards staticAward = staticAwardsDataMgr.getAwardById(38);
        List<List<Integer>> awardList = staticAward.getAwardList();
        GetGuideGiftRs.Builder builder = GetGuideGiftRs.newBuilder();
        for (List<Integer> ee : awardList) {
            if (ee.size() < 3) {
                continue;
            }
            int type = ee.get(0);
            int id = ee.get(1);
            int count = ee.get(2);
            int keyId = playerDataManager.addAward(player, type, id, count, AwardFrom.NEWER_GIFT);
            builder.addAward(PbHelper.createAwardPb(type, id, count, keyId));
        }
        lord.setNewerGift(1);
        builder.setNewerGift(lord.getNewerGift());
        handler.sendMsgToPlayer(GetGuideGiftRs.ext, builder.build());
    }

    private void refreshBuyPower(Lord lord) {
        int nowDay = TimeHelper.getCurrentDay();
        if (lord.getBuyPowerTime() != nowDay) {
            lord.setBuyPower(0);
            lord.setBuyPowerTime(nowDay);
        }
    }

    /**
     * Method: buyPower
     *
     * @Description: 购买体力 @param handler @return void @throws
     */
    public void buyPower(ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        Lord lord = player.lord;
        refreshBuyPower(lord);

        int buyCount = lord.getBuyPower();
        StaticVip staticVip = staticVipDataMgr.getStaticVip(lord.getVip());

        if (lord.getPower() >= PowerConst.POWER_MAX) {
            handler.sendErrorMsgToPlayer(GameError.POWER_LIMIT);
            return;
        }

        if (buyCount >= staticVip.getBuyPower()) {
            handler.sendErrorMsgToPlayer(GameError.VIP_NOT_ENOUGH);
            return;
        }

        int cost = (buyCount < 12) ? (buyCount + 1) * 5 : 120;
        if (lord.getGold() < cost) {
            handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
            return;
        }

        playerDataManager.subGold(player, cost, AwardFrom.BUY_POWER);
        playerDataManager.addPower(lord, 5);
        lord.setBuyPower(buyCount + 1);

        BuyPowerRs.Builder builder = BuyPowerRs.newBuilder();
        builder.setGold(lord.getGold());
        builder.setPower(lord.getPower());
        handler.sendMsgToPlayer(BuyPowerRs.ext, builder.build());
        return;
    }

    /**
     * Method: upRank
     *
     * @Description: 升级军衔 @param handler @return void @throws
     */
    public void upRank(ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        Lord lord = player.lord;

        int maxLevel = staticLordDataMgr.getMaxLordRank();
        if (lord.getRanks() >= maxLevel) {
            LogUtil.error("升级军衔upRank error level= " + lord.getRanks() + " maxLevel= " + maxLevel);
            handler.sendErrorMsgToPlayer(GameError.MAX_RANKS);
            return;
        }

        StaticLordRank staticLordRank = staticLordDataMgr.getStaticLordRank(lord.getRanks() + 1);
        if (staticLordRank == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }

        if (lord.getLevel() < staticLordRank.getLordLv()) {
            handler.sendErrorMsgToPlayer(GameError.LV_NOT_ENOUGH);
            return;
        }

        if (player.resource.getStone() < staticLordRank.getStoneCost()) {
            handler.sendErrorMsgToPlayer(GameError.STONE_NOT_ENOUGH);
            return;
        }

        playerDataManager.modifyStone(player, -staticLordRank.getStoneCost(), AwardFrom.UP_RANK);
        lord.setRanks(lord.getRanks() + 1);

        lord.setStaffing(playerDataManager.calcStaffing(player));

        UpRankRs.Builder builder = UpRankRs.newBuilder();
        builder.setStone(player.resource.getStone());
        handler.sendMsgToPlayer(UpRankRs.ext, builder.build());

        if (lord.getRanks() >= 7) {
            chatService.sendWorldChat(chatService.createSysChat(SysChatId.RANKS_UP, player.lord.getNick(), staticLordRank.getName()));
        }

        playerDataManager.synStaffingToPlayer(player);
    }

    /**
     * Method: upCommand
     *
     * @Description: 提升统帅等级 @param useGold @param handler @return void @throws
     */
    public void upCommand(boolean useGold, ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        Lord lord = player.lord;
        StaticLordCommand staticLordCommand = staticLordDataMgr.getStaticCommandLv(lord.getCommand() + 1);
        if (staticLordCommand == null) {
            handler.sendErrorMsgToPlayer(GameError.MAX_COMMAND);
            return;
        }

        if (lord.getCommand() >= lord.getLevel()) {
            handler.sendErrorMsgToPlayer(GameError.LV_NOT_ENOUGH);
            return;
        }

        int bookCount = staticLordCommand.getBook();
        UpCommandRs.Builder builder = UpCommandRs.newBuilder();

        if (useGold) {
            StaticProp book = staticPropDataMgr.getStaticProp(PropId.COMMAND_BOOK);
            int cost = book.getPrice() * bookCount;
            if (lord.getGold() < cost) {
                handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
                return;
            }

            playerDataManager.subGold(player, cost, AwardFrom.UP_COMMAND);
            builder.setGold(lord.getGold());
        } else {
            Prop prop = player.props.get(PropId.COMMAND_BOOK);
            if (prop == null || prop.getCount() < bookCount) {
                handler.sendErrorMsgToPlayer(GameError.PROP_NOT_ENOUGH);
                return;
            }

            playerDataManager.subProp(player, prop, bookCount, AwardFrom.UP_COMMAND);
            builder.setBook(prop.getCount());
        }

        int probAdd = 0;
        // 功能开启则按文官入驻规则计算，否则按是否有文官计算
        if (staticFunctionPlanDataMgr.isHeroPutOpen()) {
            if (player.isHeroPut(HeroId.TONG_SHUAI_GUAN)) {
                probAdd = staticHeroDataMgr.getStaticHero(HeroId.TONG_SHUAI_GUAN).getSkillValue() * 10;
            }
        } else {
            if (player.hasHero(HeroId.TONG_SHUAI_GUAN)) {
                probAdd = staticHeroDataMgr.getStaticHero(HeroId.TONG_SHUAI_GUAN).getSkillValue() * 10;
            }
        }
        int[] revelry = activityDataManager.revelry();

        FailNum f = playerDataManager.getFailNumByOperType(player, OperType.upCommand);
        if (RandomHelper
                .isHitRangeIn1000((int) ((calcuLordCommandProb(f.getNum(), staticLordCommand.getA(), staticLordCommand.getB()) + probAdd)
                        * ((1000 + revelry[0]) / 1000.0f)))) {
            lord.setCommand(lord.getCommand() + 1);
            LogLordHelper.command(AwardFrom.UP_COMMAND, player.account, lord, useGold ? 1 : 2);
            builder.setSuccess(true);
            // 更新失败次数为0
            f.setNum(0);

            if (lord.getCommand() >= 15) {
                chatService.sendWorldChat(
                        chatService.createSysChat(SysChatId.COMMAND_UP, player.lord.getNick(), String.valueOf(lord.getCommand())));
            }
            playerDataManager.updDay7ActSchedule(player, 12, lord.getCommand());
        } else {
            // 更新失败次数+1
            builder.setSuccess(false);
            f.setNum(f.getNum() + 1);
        }
        playerEventService.calcStrongestFormAndFight(player);
        handler.sendMsgToPlayer(UpCommandRs.ext, builder.build());
    }

    /**
     * 失败次数计入升级统率概率 y=x/(x + ab) x = 失败次数 + 1 a,b 为配表值
     *
     * @param failNum
     * @return
     */
    private float calcuLordCommandProb(int failNum, int a, float b) {
        int x = failNum + 1;
        return x * 1000 / (x + a * b);
    }

    /**
     * Method: buyPros
     *
     * @Description: 购买繁荣度 @param handler @return void @throws
     */
    public void buyPros(ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        Lord lord = player.lord;
        if (playerDataManager.fullPros(lord)) {
            handler.sendErrorMsgToPlayer(GameError.FULL_PROSP);
            return;
        }

        int cost = 0;
        int tempPros = 0; // 恢复的繁荣度
        // 若是非废墟,繁荣度必须买满
        if (!playerDataManager.isRuins(player)) {
            tempPros = lord.getProsMax() - lord.getPros();
            cost = (int) Math.ceil(tempPros / 50.0);
        } else {
            // 废墟必须买到脱离废墟(繁荣度最大值低于600恢复满,繁荣度大于等于600时恢复至600)
            if (lord.getProsMax() < 600) {
                tempPros = lord.getProsMax() - lord.getPros();
                cost = (int) Math.ceil(tempPros / 25.0);
            } else {
                tempPros = 600 - lord.getPros();
                cost = (int) Math.ceil(tempPros / 25.0);
            }
        }

        cost = (int) (cost * Constant.RUINS_RECOVER / 10000.0f);

        if (lord.getGold() < cost) {
            handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
            return;
        }

        playerDataManager.subGold(player, cost, AwardFrom.BUY_PROSP);
        playerDataManager.addPros(player, tempPros);
        playerDataManager.outOfRuins(player);

        BuyProsRs.Builder builder = BuyProsRs.newBuilder();
        builder.setGold(lord.getGold());
        handler.sendMsgToPlayer(BuyProsRs.ext, builder.build());
    }

    /**
     * Method: buyFame
     *
     * @Description: 授勋 @param type @param handler @return void @throws
     */
    public void buyFame(int type, ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        Lord lord = player.lord;

        int now = TimeHelper.getCurrentDay();
        if (lord.getFameTime2() == now) {
            handler.sendErrorMsgToPlayer(GameError.ALREADY_FAME);
            return;
        }

        int add = 0;
        BuyFameRs.Builder builder = BuyFameRs.newBuilder();
        if (type == 1) {
            if (player.resource.getStone() < 1000) {
                handler.sendErrorMsgToPlayer(GameError.STONE_NOT_ENOUGH);
                return;
            }
            playerDataManager.modifyStone(player, -1000, AwardFrom.BUY_FAME);
            builder.setStone(player.resource.getStone());
            add = 10;
        } else if (type == 2) {
            if (lord.getGold() < 10) {
                handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
                return;
            }
            playerDataManager.subGold(player, 10, AwardFrom.BUY_FAME);
            builder.setGold(lord.getGold());
            add = 100;
        } else if (type == 3) {
            if (lord.getGold() < 40) {
                handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
                return;
            }
            playerDataManager.subGold(player, 40, AwardFrom.BUY_FAME);
            builder.setGold(lord.getGold());
            add = 400;
        } else {
            if (lord.getGold() < 100) {
                handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
                return;
            }
            playerDataManager.subGold(player, 100, AwardFrom.BUY_FAME);
            builder.setGold(lord.getGold());
            add = 1200;
        }

        playerDataManager.addFame(player, add, AwardFrom.BUY_FAME);
        lord.setFameTime2(now);
        builder.setFame(lord.getFame());
        builder.setFameLv(lord.getFameLv());
        handler.sendMsgToPlayer(BuyFameRs.ext, builder.build());
    }

    /**
     * Method: getSkill
     *
     * @Description: 获取技能数据 @param handler @return void @throws
     */

    public void getSkill(ClientHandler handler) {
        GetSkillRs.Builder builder = GetSkillRs.newBuilder();
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        for (Map.Entry<Integer, Integer> entry : player.skills.entrySet()) {
            builder.addSkill(PbHelper.createSkillPb(entry.getKey(), entry.getValue()));
        }
        handler.sendMsgToPlayer(GetSkillRs.ext, builder.build());
    }

    /**
     * Method: upSkill
     *
     * @Description: 升级技能 @param skillId @param handler @return void @throws
     */
    public void upSkill(int skillId, ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        Integer lv = player.skills.get(skillId);
        if (lv == null) {
            lv = 0;
        }

        int upLv = lv + 1;
        int bookCount = upLv;
        int lordLv = upLv;

        if (player.lord.getLevel() < lordLv) {
            handler.sendErrorMsgToPlayer(GameError.LV_NOT_ENOUGH);
            return;
        }

        Prop book = player.props.get(PropId.SKILL_BOOK);
        if (book == null || book.getCount() < bookCount) {
            handler.sendErrorMsgToPlayer(GameError.BOOK_NOT_ENOUGH);
            return;
        }

        playerDataManager.subProp(player, book, bookCount, AwardFrom.UP_SKILL);
        player.skills.put(skillId, upLv);

        playerDataManager.updDay7ActSchedule(player, 14);

        UpSkillRs.Builder builder = UpSkillRs.newBuilder();
        builder.setLv(upLv);
        builder.setBookCount(book.getCount());
        handler.sendMsgToPlayer(UpSkillRs.ext, builder.build());

        playerEventService.calcStrongestFormAndFight(player);
    }

    /**
     * Method: resetSkill
     *
     * @Description: 重置技能 @param handler @return void @throws
     */
    public void resetSkill(ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player.lord.getGold() < 58) {
            handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
            return;
        }

        playerDataManager.subGold(player, 58, AwardFrom.RESET_SKILL);

        int bookCount = 0;
        Iterator<Integer> it = player.skills.values().iterator();
        while (it.hasNext()) {
            Integer lv = (Integer) it.next();
            bookCount += ((1 + lv) * lv / 2);
        }

        Prop prop = playerDataManager.addProp(player, PropId.SKILL_BOOK, bookCount, AwardFrom.RESET_SKILL);
        player.skills.clear();

        ResetSkillRs.Builder builder = ResetSkillRs.newBuilder();
        builder.setGold(player.lord.getGold());
        builder.setBook(prop.getCount());
        handler.sendMsgToPlayer(ResetSkillRs.ext, builder.build());

        playerEventService.calcStrongestFormAndFight(player);
    }

    /**
     * Method: clickFame
     *
     * @Description: 领取军衔声望 @param handler @return void @throws
     */
    public void clickFame(ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        Lord lord = player.lord;
        int now = TimeHelper.getCurrentDay();
        if (lord.getFameTime1() == now) {
            handler.sendErrorMsgToPlayer(GameError.ALREADY_RANK_FAME);
            return;
        }

        StaticLordRank staticLordRank = staticLordDataMgr.getStaticLordRank(lord.getRanks());
        if (staticLordRank == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }

        lord.setFameTime1(now);

        playerDataManager.addFame(player, staticLordRank.getFame(), AwardFrom.CLICK_FAME);
        ClickFameRs.Builder builder = ClickFameRs.newBuilder();
        builder.setFameLv(lord.getFameLv());
        builder.setFame(lord.getFame());
        handler.sendMsgToPlayer(ClickFameRs.ext, builder.build());
    }

    /**
     * Method: getTime
     *
     * @Description: 客户端获取服务器时间 @param ctx @return void @throws
     */
    public void getTime(ClientHandler handler) {
        GetTimeRs.Builder builder = GetTimeRs.newBuilder();
        builder.setTime(TimeHelper.getCurrentSecond());
        builder.setOpenPay(serverSetting.isOpenPay());

        handler.sendMsgToPlayer(GetTimeRs.ext, builder.build());
    }

    /**
     * Method: getResource
     *
     * @Description: 客户端获取资源数据 @param handler @return void @throws
     */
    public void getResource(ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        Resource resource = player.resource;
        GetResourceRs.Builder builder = GetResourceRs.newBuilder();
        builder.setIron(resource.getIron());
        builder.setOil(resource.getOil());
        builder.setCopper(resource.getCopper());
        builder.setSilicon(resource.getSilicon());
        builder.setStone(resource.getStone());

        handler.sendMsgToPlayer(GetResourceRs.ext, builder.build());
    }

    /**
     * Method: getEffect
     *
     * @Description: 获取特殊效果加成 @param handler @return void @throws
     */
    public void getEffect(ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        GetEffectRs.Builder builder = GetEffectRs.newBuilder();
        Iterator<Effect> it = player.effects.values().iterator();
        while (it.hasNext()) {
            builder.addEffect(PbHelper.createEffectPb(it.next()));
        }
        handler.sendMsgToPlayer(GetEffectRs.ext, builder.build());
    }

    /**
     * 完成新手引导
     *
     * @param handler void
     */
    public void doneGuide(ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        DoneGuideRs.Builder builder = DoneGuideRs.newBuilder();
        if (player.lord.getPos() == -1 && player.lord.getLevel() >= 2) {
            playerDataManager.addEffect(player, EffectType.ATTACK_FREE, 14400);
            worldDataManager.addNewPlayer(player);
            rankDataManager.setHonour(player.lord);
            builder.setPos(player.lord.getPos());
        }

        handler.sendMsgToPlayer(DoneGuideRs.ext, builder.build());
    }

    /**
     * 玩家的军备
     *
     * @param player
     * @param keyId
     * @return Equip
     */
    private Equip getEquip(Player player, int keyId) {
        for (int i = 0; i < 7; i++) {
            Map<Integer, Equip> map = player.equips.get(i);
            Equip equip = map.get(keyId);
            if (equip != null) {
                return equip;
            }
        }

        return null;
    }

    /**
     * 设置玩家排名属性并更新排名
     *
     * @param req
     * @param handler void
     */
    public void setData(SetDataRq req, ClientHandler handler) {
        int type = req.getType();
        long value = req.getValue();

        if (value < 0) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null) {
            return;
        }
        if (type == 1) {
            // todo: zhangdh 注意此处写法有问题, 不应该直接采用客户端传送的战力，以后优化
            player.lord.setFight(value);
            rankDataManager.setFight(player.lord);
            playerDataManager.updDay7ActSchedule(player, 13, value);
        } else if (type == 2) {
            // player.lord.setStars((int) value);
            // rankDataManager.setStars(player.lord);
        } else if (type == 3) {
            // rankDataManager.setHonour(player.lord);
        } else if (type == 4) {
            int keyId = (int) value;
            Equip equip = getEquip(player, keyId);
            if (equip == null || equip.getEquipId() / 100 != 1) {
                handler.sendErrorMsgToPlayer(GameError.NO_EQUIP);
                return;
            }
            rankDataManager.setAttack(player.lord, equip);
        } else if (type == 5) {
            int keyId = (int) value;
            Equip equip = getEquip(player, keyId);
            if (equip == null || equip.getEquipId() / 100 != 5) {
                handler.sendErrorMsgToPlayer(GameError.NO_EQUIP);
                return;
            }

            rankDataManager.setCrit(player.lord, equip);
        } else if (type == 6) {
            int keyId = (int) value;
            Equip equip = getEquip(player, keyId);
            if (equip == null || equip.getEquipId() / 100 != 4) {
                handler.sendErrorMsgToPlayer(GameError.NO_EQUIP);
                return;
            }

            rankDataManager.setDodge(player.lord, equip);
        } else if (type == 7) {// 勋章震慑总和
            player.lord.setFrighten((int) value);
            rankDataManager.setFrighten(player.lord);
        } else if (type == 8) {// 勋章刚毅总和
            player.lord.setFortitude((int) value);
            rankDataManager.setFortitude(player.lord);
        } else if (type == 9) {// 勋章价值总和
            player.lord.setMedalPrice((int) value);
            rankDataManager.setMedalPrice(player.lord);
        } else if (type == 10) {// 最强战力
            if (!staticFunctionPlanDataMgr.isRankStrongestOpen()) {
                handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
                return;
            }
            CommonPb.Form pbForm = req.getForm();
            if (pbForm == null) {
                return;
            }

            Form form = PbHelper.createForm(pbForm);
            if (!armyService.checkStrongestForm(player, form)) {
                LogUtil.error(String.format("nick :%s, strongest form check fail!!! form %s", player.lord.getNick(), form));
                // handler.sendErrorMsgToPlayer(GameError.STRONGEST_FORM_SET_ERR);
                // return;
            } else {
                long fight = fightService.calcFormFight(player, form);
                if (player.lord.getMaxFight() != fight) {
                    player.lord.setMaxFight(fight);
                    rankDataManager.upStrongestFormRankSortInfo(player.lord);
                }

                if (req.getValue() > fight) {
                    if ((fight - req.getValue()) * NumberHelper.TEN_THOUSAND / fight > 0) {// 误差超过万分之一
                        LogUtil.error(String.format("nick %s, client :%d, srv calc fight :%d, form :%s", player.lord.getNick(),
                                req.getValue(), fight, form.toString()));
                    }
                }
            }
        }

        SetDataRs.Builder builder = SetDataRs.newBuilder();
        handler.sendMsgToPlayer(SetDataRs.ext, builder.build());
    }

    /**
     * Method: restoreProsAndPower
     *
     * @Description: 恢复体力和繁荣度 @param player @param now @return void @throws
     */
    private void restoreProsAndPower(Player player, int now) {
        Lord lord = player.lord;
        if (!playerDataManager.fullPower(lord)) {
            playerDataManager.backPower(lord, now);
        }

        if (!playerDataManager.fullPros(lord)) {
            playerDataManager.backPros(player, now);
        }
    }

    /**
     * @Description: 回归玩家Buff @param player @param now @return void @throws
     */
    public void playerBackBuff(Player player) {
        if (!staticFunctionPlanDataMgr.isPlayerBackOpen())
            return;// 如果老玩家回归未开启
        int day = 10;// 计算当前是第几天
        int subTime = (int) ((player.account.getBackEndTime().getTime() - System.currentTimeMillis()) / 1000);// 计算距离下个回归点的秒数
        while (subTime > TimeHelper.DAY_S) {// 距离第二个回归点的秒数
            subTime = subTime - TimeHelper.DAY_S;
            day -= 1;
        }
        playerDataManager.playerBackBuff(player, player.account.getBackState(), day, subTime);
    }

    /**
     * 没用到
     *
     * @param player
     * @param nowSec
     * @return int
     */
    public int calcBackDays(Player player, long nowSec) {
        int day = (int) ((nowSec - (player.account.getBackEndTime().getTime() - 10 * TimeHelper.DAY_MS)) / TimeHelper.DAY_MS);// 计算当前是第几天
        int subTime = (int) ((player.account.getBackEndTime().getTime() - System.currentTimeMillis()) / 1000);// 计算距离下个回归点的秒数
        if (subTime > 0) {
            day++;
        }
        return day;
    }

    /**
     * Method: checkEffectEnd
     *
     * @Description: 检查效果加成 @param player @param now @return void @throws
     */
    private void checkEffectEnd(Player player, int now) {
        Iterator<Effect> it = player.effects.values().iterator();
        while (it.hasNext()) {
            Effect effect = (Effect) it.next();
            int id = effect.getEffectId();
            if (effect.getEndTime() != 0 && effect.getEndTime() <= now) {
                playerDataManager.vaildEffect(player, id, -1);
                // 如果是皮肤的effect，则确认到期的皮肤是否正在使用，如果正在使用，则选择默认皮肤
                if ((id >= EffectType.CHANGE_SURFACE_1 && id <= EffectType.CHANGE_SURFACE_7) || (id > 1000 && id < 3000)) {
                    // 如果已过期的皮肤正在使用，则当前皮肤为默认皮肤
                    if (player.surface == id - 10) {
                        player.surface = 0;// 当前皮肤已过期
                    }
                }
                it.remove();

                if (id == EffectType.ATTACK_FREE) {
                    LogLordHelper.attackFreeBuff(AwardFrom.DO_SOME, player, 3, 0, effect.getEndTime(), 0);
                }

                if (effect.getEffectId() == EffectType.MARCH_SPEED || effect.getEffectId() == EffectType.MARCH_SPEED_SUPER) {
                    worldService.recalcArmyMarch(player);
                }
            }
        }

        // 从皮肤map里删除过期皮肤
        it = player.surfaceSkins.values().iterator();
        while (it.hasNext()) {
            Effect effect = it.next();
            if (effect.getEndTime() == 0) {
                continue;
            }
            if (effect.getEndTime() <= now) {
                it.remove();
            }
        }

        // 删掉过期的铭牌、聊天气泡
        for (Entry<Integer, Map<Integer, Effect>> entry : player.getUsedSkin().entrySet()) {
            int type = entry.getKey();

            it = entry.getValue().values().iterator();
            while (it.hasNext()) {
                Effect effect = it.next();
                if (effect.getEndTime() == 0) {
                    continue;
                }
                if (effect.getEndTime() <= now) {
                    it.remove();
                }
            }

            Map<Integer, Effect> map = entry.getValue();
            // 如果删除了当前铭牌，则选择默认铭牌做当前铭牌
            int currentSkinId = player.getCurrentSkin(type);
            if (!map.containsKey(currentSkinId)) {
                player.setCurrentSkin(type, type * 1000 + 1);
            }

        }

    }

    /**
     * Method: restoreDataTimerLogic
     *
     * @Description: 恢复能量和繁荣度的定时器逻辑 @return void @throws
     */
    public void restoreDataTimerLogic() {
        Iterator<Player> iterator = playerDataManager.getRecThreeMonOnlPlayer().values().iterator();
        int now = TimeHelper.getCurrentSecond();

        while (iterator.hasNext()) {
            Player player = iterator.next();

            try {
                if (player.isActive()) {

                  /*  if (player.is3MothLogin()) {
                        continue;
                    }
*/
                    restoreProsAndPower(player, now);
                    if (player.wipeTime != 0) {
                        combatService.checkWipe(player, now);
                    }
                }
            } catch (Exception e) {
                LogUtil.error("恢复能量和繁荣度的定时器报错, lordId:" + player.lord.getLordId(), e);
            }
        }
    }

    /**
     * Method: effectTimerLogic
     *
     * @Description: 判断加成效果是否结束的定时器逻辑 @return void @throws
     */
    public void effectTimerLogic() {
        Iterator<Player> iterator = playerDataManager.getPlayers().values().iterator();
        int now = TimeHelper.getCurrentSecond();
        int goldTime;
        while (iterator.hasNext()) {
            Player player = iterator.next();
            try {
                Effect effect = player.effects.get(EffectType.ADD_GOLD_PER_HOUR_PS);
                if (effect != null && now >= effect.getEndTime()) {
                    List<CommonPb.Award> awardList = new ArrayList<CommonPb.Award>();
                    awardList.add(PbHelper.createAwardPb(AwardType.GOLD, 0, 240));

                    // FortressJobAppoint f =
                    // warDataManager.getFortressJobAppointMapByLordId().get(player.lord.getLordId());
                    // if (f != null) {
                    StaticFortressJob s = staticFortressDataMgr.getFortressJob(FortressFightConst.CaiWuGuanId);
                    playerDataManager.sendAttachMail(AwardFrom.FORTRESS_JOB, player, awardList, MailType.MOLD_FORTRESS_JOB_REWAD, now, s.getName());
                    // }
                    player.effects.remove(effect.getEffectId());
                }
                if (player.isActive()) {
                    checkEffectEnd(player, now);
                    boolean hasCaiZhengGuan;
                    if (staticFunctionPlanDataMgr.isHeroPutOpen()) {
                        hasCaiZhengGuan = player.isHeroPut(HeroId.CAI_ZHENG_GUAN);
                    } else {
                        hasCaiZhengGuan = player.hasHero(HeroId.CAI_ZHENG_GUAN);
                    }

                    if (hasCaiZhengGuan) {
                        goldTime = player.lord.getGoldTime();
                        if (goldTime <= now) {
                            // playerDataManager.addGold(player.lord, 30,
                            // GoldGive.CAIZHENG);

                            player.lord.setGoldTime(now + TimeHelper.DAY_S);
                            List<CommonPb.Award> awardList = new ArrayList<CommonPb.Award>();
                            awardList.add(PbHelper.createAwardPb(AwardType.GOLD, 0, 30));
                            playerDataManager.sendAttachMail(AwardFrom.CAIZHENG, player, awardList, MailType.MOLD_GOLD, now, "30");
                        }
                    }
                }
            } catch (Exception e) {
                LogUtil.error("判断加成效果是否结束的定时器报错, lordId:" + player.lord.getLordId(), e);
            }
        }
    }


    /**
     * 产生3个男名字 3个女名字
     *
     * @return List<String>
     */
    private List<String> generateNames() {
        List<String> names = new ArrayList<String>();
        while (names.size() < 3) {
            String name = staticIniDataMgr.getManNick();
            if (playerDataManager.canUseName(name)) {
                names.add(name);
            }
        }

        while (names.size() < 6) {
            String name = staticIniDataMgr.getWomanNick();
            if (playerDataManager.canUseName(name)) {
                names.add(name);
            }
        }

        return names;
    }

    /**
     * 获得可用名字 男女各3个
     *
     * @return List<String>
     */
    public List<String> getAvailabelNames() {
        return generateNames();
    }

    public void setPortrait(int portrait, ClientHandler handler) {
        int pendent = portrait / 100;
        int base = portrait - pendent * 100;

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (pendent != 0) {
            // 挂件判断
            StaticPendant staticPendant = staticLordDataMgr.getPendant(pendent);
            if (staticPendant == null) {
                handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
                return;
            }

            int type = staticPendant.getType();
            switch (type) {
                case 1:// 等级挂件
                    if (staticPendant.getValue() > player.lord.getLevel()) {
                        handler.sendErrorMsgToPlayer(GameError.LV_NOT_ENOUGH);
                        return;
                    }
                    break;
                case 2:// vip挂件
                    if (staticPendant.getValue() > player.lord.getVip()) {
                        handler.sendErrorMsgToPlayer(GameError.VIP_NOT_ENOUGH);
                        return;
                    }
                    break;
                case 3:// 期限挂件
                    Pendant pendant = playerDataManager.getPendant(player, staticPendant.getPendantId());
                    if (pendant == null) {
                        handler.sendErrorMsgToPlayer(GameError.NOT_HAVE);
                        return;
                    }
                    break;
                default:
                    handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
                    return;
            }
        }
        // 肖像判断
        StaticPortrait staticPortrait = staticLordDataMgr.getPortraitMap().get(base);
        if (staticPortrait == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }

        int type = staticPortrait.getType();
        switch (type) {
            case 1:// 等级挂件
                if (staticPortrait.getValue() > player.lord.getLevel()) {
                    handler.sendErrorMsgToPlayer(GameError.LV_NOT_ENOUGH);
                    return;
                }
                break;
            case 2:// vip挂件
                if (staticPortrait.getValue() > player.lord.getVip()) {
                    handler.sendErrorMsgToPlayer(GameError.VIP_NOT_ENOUGH);
                    return;
                }
                break;
            case 3:// 期限
                Portrait sPortrait = playerDataManager.getPortrait(player, staticPortrait.getId());
                if (sPortrait == null) {
                    handler.sendErrorMsgToPlayer(GameError.NOT_HAVE);
                    return;
                }
                break;
            default:
                handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
                return;
        }

        player.lord.setPortrait(portrait);
        SetPortraitRs.Builder builder = SetPortraitRs.newBuilder();
        handler.sendMsgToPlayer(SetPortraitRs.ext, builder.build());
    }

    private static final int[] BUY_BUILD_COST = {68, 108, 198, 368, 688};

    public void buyBuild(ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        int count = 0;
        StaticVip staticVip = staticVipDataMgr.getStaticVip(player.lord.getVip());
        if (staticVip != null) {
            count = staticVip.getBuildQue();
        }

        int buildCount = player.lord.getBuildCount();
        if (buildCount >= count) {
            handler.sendErrorMsgToPlayer(GameError.VIP_NOT_ENOUGH);
            return;
        }

        buildCount += 1;

        if (buildCount > BUY_BUILD_COST.length) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }

        int cost = BUY_BUILD_COST[buildCount - 1];
        if (player.lord.getGold() < cost) {
            handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
            return;
        }

        playerDataManager.subGold(player, cost, AwardFrom.BUY_BUILD);

        player.lord.setBuildCount(buildCount);
        BuyBuildRs.Builder builder = BuyBuildRs.newBuilder();
        builder.setGold(player.lord.getGold());
        handler.sendMsgToPlayer(BuyBuildRs.ext, builder.build());
    }

    /**
     * 玩家填入验证码协议处理
     *
     * @param code
     * @param handler void
     */
    public void giftCode(String code, ClientHandler handler) {
        if (code.length() != 12) {
            handler.sendErrorMsgToPlayer(GameError.GIFT_CODE_LENTH);
            return;
        }

        Player player = playerDataManager.getPlayer(handler.getRoleId());

        UseGiftCodeRq.Builder builder = UseGiftCodeRq.newBuilder();
        builder.setCode(code);
        builder.setLordId(player.roleId);
        builder.setServerId(player.account.getServerId());
        builder.setPlatNo(player.account.getPlatNo());

        Base.Builder baseBuilder = PbHelper.createRqBase(UseGiftCodeRq.EXT_FIELD_NUMBER, 0L, UseGiftCodeRq.ext, builder.build());
        handler.sendMsgToPublic(baseBuilder);
    }

    /**
     * 在线奖励
     *
     * @param handler void
     */
    public void olAward(ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null) {
            return;
        }
        int ctTime = player.lord.getCtTime();
        int lastCtDay = TimeHelper.getDay(ctTime);

        int now = TimeHelper.getCurrentSecond();
        int nowDay = TimeHelper.getDay(now);
        if (lastCtDay != nowDay) {// 跨零点在线在线的玩家
            int todayZone = TimeHelper.getTodayZone(now);
            player.lord.setCtTime(todayZone);
            player.lord.setOlAward(0);
        }

        int id = player.lord.getOlAward();
        int keyId = 0;
        switch (id) {
            case 0:
                keyId = 1001;
                break;
            case 1:
                keyId = 1002;
                break;
            case 2:
                keyId = 1003;
                break;
            case 3:
                keyId = 1004;
                break;
            case 4:
                keyId = 1005;
                break;
            case 5:
                keyId = 1006;
                break;
            case 6:
                keyId = 1007;
                break;
            default:
                handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
                return;
        }

        StaticActAward staticActAward = staticActivityDataMgr.getActAward(keyId);
        if (staticActAward == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }

        if (now - player.lord.getCtTime() < staticActAward.getCond()) {
            handler.sendErrorMsgToPlayer(GameError.OL_NOT_ENOUGH);
            return;
        }

        player.lord.setOlAward(id + 1);
        player.lord.setCtTime(now);
        List<Award> awards = playerDataManager.addAwardsBackPb(player, staticActAward.getAwardList(), AwardFrom.OL_AWARD);

        OlAwardRs.Builder builder = OlAwardRs.newBuilder();
        builder.setId(player.lord.getOlAward());
        builder.addAllAward(awards);
        handler.sendMsgToPlayer(OlAwardRs.ext, builder.build());
    }

    /**
     * 领取军团tip奖励
     *
     * @param handler void
     */
    public void doPartyTipAwardRq(ClientHandler handler) {
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

        if (lord.getPartyTipAward() == 2) {// 奖励已领取
            handler.sendErrorMsgToPlayer(GameError.AWARD_HAD_GOT);
            return;
        }
        lord.setPartyTipAward(2);
        DoPartyTipAwardRs.Builder builder = DoPartyTipAwardRs.newBuilder();
        int keyId = playerDataManager.addAward(player, AwardType.PROP, 56, 5, AwardFrom.PARTY_TIP_AWARD);
        builder.addAward(PbHelper.createAwardPb(AwardType.PROP, 56, 5, keyId));
        handler.sendMsgToPlayer(DoPartyTipAwardRs.ext, builder.build());
    }

    /**
     * 获取玩家挂件
     *
     * @param handler
     */
    public void getPendant(ClientHandler handler) {
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

        GetPendantRs.Builder builder = GetPendantRs.newBuilder();
        // 挂件
        List<Pendant> pendantList = playerDataManager.getPendants(player);
        for (Pendant e : pendantList) {
            StaticPendant staticPendant = staticLordDataMgr.getPendant(e.getPendantId());
            if (staticPendant == null) {
                continue;
            }
            builder.addPendant(PbHelper.createPendantPb(staticPendant, e));
        }
        // 肖像
        List<Portrait> portraitList = playerDataManager.getPortraits(player);
        for (Portrait e : portraitList) {
            StaticPortrait staticPortrait = staticLordDataMgr.getPortraitMap().get(e.getId());
            if (staticPortrait == null) {
                continue;
            }
            builder.addPortrait(PbHelper.createPortraitPb(staticPortrait, e));
        }
        handler.sendMsgToPlayer(GetPendantRs.ext, builder.build());
    }

    /**
     * 获取侦查次数
     *
     * @param handler
     */
    public void getScoutRq(ClientHandler handler) {
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

        int nowDay = TimeHelper.getCurrentDay();

        checkAndResetScount(player, nowDay);

        GetScoutRs.Builder builder = GetScoutRs.newBuilder();
        builder.setScout(lord.getScount());
        handler.sendMsgToPlayer(GetScoutRs.ext, builder.build());
    }

    /**
     * 侦查数量检测与重置
     *
     * @param player
     * @param nowDay
     */
    public void checkAndResetScount(Player player, int nowDay) {
        if (player.lord.getScountDate() != nowDay) {
            player.lord.setScountDate(nowDay);
            player.lord.setScount(0);
        }
    }

    /**
     * 获取推送评论的状态<br>
     * 是否推送等
     */
    public void getPushState(ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        GetPushStateRs.Builder builder = GetPushStateRs.newBuilder();

        if (player.pushComment.getState() == 0) {
            if (player.pushComment.getLastCommentTime() == 0 && player.pushComment.getShouldPushTime() == 0) {
                player.pushComment.setShouldPushTime(TimeHelper.getCurrentSecond() + TimeHelper.DAY_S);
            }

            builder.setState(0);
            builder.setShouldPushTime(player.pushComment.getShouldPushTime());
        } else {
            builder.setState(1);
        }

        handler.sendMsgToPlayer(GetPushStateRs.ext, builder.build());
    }

    /**
     * 推送评论 <br>
     * 评论状态: 1已经评论 2关闭
     *
     * @param rq
     */
    public void pushComment(PushCommentRq rq, ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        PushCommentRs.Builder builder = PushCommentRs.newBuilder();

        if (rq.getCommentState() == 1) {
            player.pushComment.setState(1);
            builder.setState(1);

        } else if (rq.getCommentState() == 2) {
            player.pushComment.setLastCommentTime(TimeHelper.getCurrentSecond());
            player.pushComment.setShouldPushTime(player.pushComment.getLastCommentTime() + 7 * TimeHelper.DAY_S);

            builder.setState(0);
            builder.setShouldPushTime(player.pushComment.getShouldPushTime());
        }

        handler.sendMsgToPlayer(PushCommentRs.ext, builder.build());
    }

    /**
     * 获取7日活动小红点
     */
    public void getDay7ActTips(ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());

        List<Integer> listTips = playerDataManager.getActDayTaskTips(player);

        GetDay7ActTipsRs.Builder builder = GetDay7ActTipsRs.newBuilder();
        builder.addAllTips(listTips);
        builder.setLvUpIsUse(player.day7Act.getLvUpDay() == TimeHelper.getCurrentDay());
        handler.sendMsgToPlayer(GetDay7ActTipsRs.ext, builder.build());
    }

    /**
     * 获取7日活动界面数据
     */
    public void getDay7Act(int day, ClientHandler handler) {
        List<StaticDay7Act> list = staticWarAwardDataMgr.getDay7ActList(day);
        if (list == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        Day7Act day7Act = player.day7Act;

        Date now = new Date();
        Date beginTime = TimeHelper.getDateZeroTime(player.account.getCreateDate());
        int dayiy = DateHelper.dayiy(beginTime, now);

        List<CommonPb.Day7Act> listDay7Act = new ArrayList<>();
        for (StaticDay7Act e : list) {
            if (day7Act.getRecvAwardIds().contains(e.getKeyId())) {
                listDay7Act.add(PbHelper.createDay7ActPb(e.getKeyId(), e.getCond(), 3));
                continue;
            }

            int status = playerDataManager.getDay7ActStatus(player, e);
            if (e.getDay() > dayiy) {
                listDay7Act.add(PbHelper.createDay7ActPb(e.getKeyId(), status, 2));
            } else {
                if (e.getType() != 8) {
                    listDay7Act.add(PbHelper.createDay7ActPb(e.getKeyId(), status, status >= e.getCond() ? 0 : 1));
                } else {
                    listDay7Act.add(PbHelper.createDay7ActPb(e.getKeyId(), status, status <= e.getCond() ? 0 : 1));
                }
            }
        }

        GetDay7ActRs.Builder builder = GetDay7ActRs.newBuilder();
        builder.addAllDay7Acts(listDay7Act);
        handler.sendMsgToPlayer(GetDay7ActRs.ext, builder.build());
    }

    /**
     * 领取7日活动奖励
     */
    public void recvDay7ActAward(int keyId, ClientHandler handler) {
        StaticDay7Act staticDay7Act = staticWarAwardDataMgr.getDay7Act(keyId);
        if (staticDay7Act == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        Day7Act day7Act = player.day7Act;

        Date beginTime = TimeHelper.getDateZeroTime(player.account.getCreateDate());
        long time = beginTime.getTime() + (7 + 3) * TimeHelper.DAY_S * 1000;
        if (System.currentTimeMillis() > time) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }

        Date now = new Date();
        int dayiy = DateHelper.dayiy(beginTime, now);
        if (staticDay7Act.getDay() > dayiy) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_FINISH);
            return;
        }

        if (day7Act.getRecvAwardIds().contains(staticDay7Act.getKeyId())) {
            handler.sendErrorMsgToPlayer(GameError.AWARD_HAD_GOT);
            return;
        }

        RecvDay7ActAwardRs.Builder builder = RecvDay7ActAwardRs.newBuilder();

        switch (staticDay7Act.getType()) {
            case 15:// 免费赠送1
                break;
            case 18:// 半价限购1
                if (player.lord.getGold() < staticDay7Act.getParam().get(1)) {
                    handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
                    return;
                }
                builder.addAtom2(
                        playerDataManager.subProp(player, AwardType.GOLD, 0, staticDay7Act.getParam().get(1), AwardFrom.RECV_DAY_7_ACT_AWARD));
                break;
            default:
                int status = playerDataManager.getDay7ActStatus(player, staticDay7Act);
                if (staticDay7Act.getType() == 8) {
                    if (status > staticDay7Act.getCond()) {
                        handler.sendErrorMsgToPlayer(GameError.DAY_7_ACT_ARENA_RANK_ENOUGH);
                        return;
                    }
                } else {
                    if (status < staticDay7Act.getCond()) {
                        handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_FINISH);
                        return;
                    }
                }
                break;
        }

        day7Act.getRecvAwardIds().add(staticDay7Act.getKeyId());

        for (List<Integer> e : staticDay7Act.getAwardList()) {
            int type = e.get(0);
            int itemId = e.get(1);
            int count = e.get(2);
            if (type == AwardType.EQUIP || type == AwardType.PART) {
                for (int c = 0; c < count; c++) {
                    int itemkey = playerDataManager.addAward(player, type, itemId, 1, AwardFrom.RECV_DAY_7_ACT_AWARD);
                    builder.addAwards(PbHelper.createAwardPb(type, itemId, 1, itemkey));
                }
            } else {
                int itemkey = playerDataManager.addAward(player, type, itemId, count, AwardFrom.RECV_DAY_7_ACT_AWARD);
                builder.addAwards(PbHelper.createAwardPb(type, itemId, count, itemkey));
            }
        }

        handler.sendMsgToPlayer(RecvDay7ActAwardRs.ext, builder.build());
    }

    /**
     * 7日活动立即升级
     */
    public void day7ActLvUp(ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());

        Day7Act day7Act = player.day7Act;
        int now = TimeHelper.getCurrentDay();
        if (day7Act.getLvUpDay() == now) {
            handler.sendErrorMsgToPlayer(GameError.AWARD_HAD_GOT);
            return;
        }

        Date beginTime = TimeHelper.getDateZeroTime(player.account.getCreateDate());
        long time = beginTime.getTime() + (7) * TimeHelper.DAY_S * 1000;
        if (System.currentTimeMillis() > time) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        // int dayiy = DateHelper.dayiy(beginTime, new Date());
        //
        // if(dayiy >7){
        // 50级以后，无论如何都不再有7日活动
        if (player.lord.getLevel() >= 70) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_FINISYH);
            return;
        }
        // }

        long add = 0;
        StaticLordLv staticLordLv = staticLordDataMgr.getStaticLordLv(player.lord.getLevel() + 1);
        if (staticLordLv != null) {
            add = staticLordLv.getNeedExp() - player.lord.getExp();
            playerDataManager.addExp(player, add);
        }

        day7Act.setLvUpDay(now);

        Day7ActLvUpRs.Builder builder = Day7ActLvUpRs.newBuilder();
        builder.addAward(PbHelper.createAwardPb(AwardType.EXP, 0, add));
        handler.sendMsgToPlayer(Day7ActLvUpRs.ext, builder.build());
    }

    /**
     * 互换俩账号的角色
     *
     * @param req
     * @param handler void
     */
    public void changePlatNoRq(ChangePlatNoRq req, ServerHandler handler) {
        long srctLordId = req.getSrcLordId();
        long destLordId = req.getDestLordId();
        try {
            Player srcPlayer = playerDataManager.getPlayer(srctLordId);
            Player destPlayer = playerDataManager.getPlayer(destLordId);

            if (srcPlayer == null || destPlayer == null) {
                return;
            }
            Account srcAcc = srcPlayer.account;
            Account destAcc = destPlayer.account;

            // 更新数据库
            Account destSaveAcc = new Account();
            destSaveAcc.setLordId(0);
            destSaveAcc.setKeyId(destAcc.getKeyId());
            destSaveAcc.setLoginDays(srcPlayer.account.getLoginDays());
            playerDataManager.updatePlatNo(destSaveAcc);

            Account srcSaveAcc = new Account();
            srcSaveAcc.setLordId(destPlayer.lord.getLordId());
            srcSaveAcc.setLoginDays(destPlayer.account.getLoginDays());
            srcSaveAcc.setKeyId(srcAcc.getKeyId());
            playerDataManager.updatePlatNo(srcSaveAcc);

            destSaveAcc.setLordId(srcPlayer.lord.getLordId());
            playerDataManager.updatePlatNo(destSaveAcc);

            // 更新内存
            int destPlatNo = destPlayer.account.getLoginDays();
            long lordId = destPlayer.lord.getLordId();
            destAcc.setLordId(srcPlayer.lord.getLordId());
            destAcc.setLoginDays(srcPlayer.account.getLoginDays());
            srcAcc.setLordId(lordId);
            srcAcc.setLoginDays(destPlatNo);

            // 更新player 与account 关联
            destPlayer.account = srcAcc;
            srcPlayer.account = destAcc;
        } catch (Exception e) {
            e.printStackTrace();
        }

    }

    private void addLevelExpBuff(Player player) {
        List<List<Float>> buff = Constant.LEVEL_EXP_BUFF;
        player.effects.remove(EffectType.LEVEL_EXP_UP);
        for (List<Float> level : buff) {
            if (player.lord.getLevel() <= level.get(1)) {
                // 只要玩家不是连续在线一个月以上,始终保持该BUFF另类实现永久BUFF的形式
                playerDataManager.addEffect(player, EffectType.LEVEL_EXP_UP, 30 * 24 * TimeHelper.HOUR_S);
                break;
            }
        }
    }

    /**
     * 领取活跃宝箱奖励
     *
     * @param handler
     */
    public void getActiveBoxAward(ClientHandler handler, GetActiveBoxAwardRq req) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player.activeBox.isEmpty() || !player.activeBox.containsAll(req.getBoxIdList())) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }
        GetActiveBoxAwardRs.Builder builder = GetActiveBoxAwardRs.newBuilder();
        StaticActiveBoxConfig activeBoxCfg = staticActiveBoxDataMgr.getActiveBoxCfg();
        Map<List<Integer>, Float> awardMap = LotteryUtil.listToMap(activeBoxCfg.getAward());
        for (int i = 0; i < req.getBoxIdList().size(); i++) {
            List<Integer> award = LotteryUtil.getRandomKey(awardMap);
            int type = award.get(0);
            int id = award.get(1);
            int count = award.get(2);

            if ((type == AwardType.PROP && id == PropId.COMMAND_BOOK) || type == AwardType.GOLD
                    || (type == AwardType.LORD_EQUIP_METERIAL && staticEquipDataMgr.getLordEquipMaterial(id).getQuality() >= 3)) {
                String name;
                if (type == AwardType.PROP) {
                    name = staticPropDataMgr.getStaticProp(id).getPropName();
                } else if (type == AwardType.LORD_EQUIP_METERIAL) {
                    name = staticEquipDataMgr.getLordEquipMaterial(id).getName();
                } else {
                    name = "金币";
                }
                chatService.sendWorldChat(chatService.createSysChat(SysChatId.ACTIVE_BOX, player.lord.getNick(), name, String.valueOf(count)));
            }
            builder.addAward(playerDataManager.addAwardBackPb(player, award, AwardFrom.ACTIVE_BOX));
        }
        player.activeBox.clear();
        handler.sendMsgToPlayer(GetActiveBoxAwardRs.ext, builder.build());
    }

}
