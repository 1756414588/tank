package com.game.service;

import com.alibaba.fastjson.JSONArray;
import com.game.chat.domain.Chat;
import com.game.constant.*;
import com.game.dataMgr.StaticVipDataMgr;
import com.game.domain.MedalBouns;
import com.game.domain.Member;
import com.game.domain.PartyData;
import com.game.domain.Player;
import com.game.domain.p.*;
import com.game.domain.p.lordequip.LordEquip;
import com.game.manager.*;
import com.game.message.handler.DealType;
import com.game.message.handler.ServerHandler;
import com.game.message.handler.ss.LordRelevanceRqHandler;
import com.game.pb.BasePb.Base;
import com.game.pb.CommonPb;
import com.game.pb.CommonPb.Award;
import com.game.pb.InnerPb;
import com.game.pb.InnerPb.*;
import com.game.server.GameServer;
import com.game.server.ICommand;
import com.game.util.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.*;

/**
 * GM工具 gm在后台通过账号服发消息到游戏服来进行的操作
 *
 * @author ChenKui
 */
@Service
public class GmToolService {
    @Autowired
    private GmService gmService;
    @Autowired
    private PlayerDataManager playerDataManager;
    @Autowired
    private ChatService chatService;
    @Autowired
    private LoadService loadService;
    @Autowired
    private PartyDataManager partyDataManager;
    @Autowired
    private ArenaDataManager arenaDataManager;
    @Autowired
    private RankDataManager rankDataManager;
    @Autowired
    private StaticVipDataMgr staticVipDataMgr;
    @Autowired
    private DataRepairDM dataRepairDM;
    @Autowired
    private HotfixDataManager hotfixDataManager;

    /**
     * 禁用账号
     *
     * @param req
     * @param handler void
     */
    public void forbidden(final ForbiddenRq req, final ServerHandler handler) {
        GameServer.getInstance().mainLogicServer.addCommand(new ICommand() {
            @Override
            public void action() {
                int forbiddenId = req.getForbiddenId();
                if (req.hasNick()) {
                    String nick = req.getNick();
                    int time = Integer.parseInt(String.valueOf(req.getTime()));// 注意 int 时间搓 到 2038 年
                    forbiddenLogic(forbiddenId, nick, time);
                } else if (req.hasLordId()) {
                    long lordId = req.getLordId();
                    int time = Integer.parseInt(String.valueOf(req.getTime()));// 注意 int 时间搓 到 2038 年
                    forbiddenLogic(forbiddenId, lordId, time);
                }

            }
        }, DealType.MAIN);

    }

    /**
     * 修改vip等级
     *
     * @param req
     * @param handler void
     */
    public void modVip(final ModVipRq req, final ServerHandler handler) {
        GameServer.getInstance().mainLogicServer.addCommand(new ICommand() {
            @Override
            public void action() {
                long lordId = req.getLordId();
                int type = req.getType();
                int value = req.getValue();
                modVipLogic(lordId, type, value);
            }
        }, DealType.MAIN);

    }

    /**
     * 修改玩家身上的军备
     *
     * @param req
     * @param handler void
     */
    public void modLord(final ModLordRq req, final ServerHandler handler) {
        GameServer.getInstance().mainLogicServer.addCommand(new ICommand() {
            @Override
            public void action() {
                long lordId = req.getLordId();
                int type = req.getType();
                int keyId = req.getKeyId();
                int value = req.getValue();
                modLordLogic(lordId, type, keyId, value);
            }
        }, DealType.MAIN);

    }

    /**
     * 修改玩家道具
     *
     * @param req
     * @param handler void
     */
    public void modProp(final ModPropRq req, final ServerHandler handler) {
        GameServer.getInstance().mainLogicServer.addCommand(new ICommand() {
            @Override
            public void action() {
                long lordId = req.getLordId();
                int type = req.getType();
                String porps = req.getProps();
                modPropLogic(lordId, type, porps);
            }
        }, DealType.MAIN);

    }

    /**
     * 给玩家改名
     *
     * @param req
     * @param handler void
     */
    public void modName(final ModNameRq req, final ServerHandler handler) {
        GameServer.getInstance().mainLogicServer.addCommand(new ICommand() {
            @Override
            public void action() {
                long lordId = req.getLordId();
                String porps = req.getName();
                modNameLogic(lordId, porps);
            }
        }, DealType.MAIN);

    }

    /**
     * 修改军团职位
     *
     * @param req
     * @param handler void
     */
    public void modPartyMemberJob(final ModPartyMemberJobRq req,
                                  ServerHandler handler) {
        GameServer.getInstance().mainLogicServer.addCommand(new ICommand() {
            public void action() {
                long lordId = req.getLordId();
                int job = req.getJob();
                modPartyMemberJob(lordId, job);
            }
        }, DealType.MAIN);
    }

    /**
     * 后台获取玩家属性
     *
     * @param req
     * @param handler void
     */
    public void getLordBase(final GetLordBaseRq req, final ServerHandler handler) {
        GameServer.getInstance().mainLogicServer.addCommand(new ICommand() {
            @Override
            public void action() {
                String marking = req.getMarking();
                long lordId = req.getLordId();
                int type = req.getType();
                backLordBaseLogic(marking, lordId, type);
            }
        }, DealType.MAIN);

    }

    /**
     * 后他获取排行信息
     *
     * @param req
     * @param handler void
     */
    public void getRankBase(final GetRankBaseRq req, ServerHandler handler) {
        GameServer.getInstance().mainLogicServer.addCommand(new ICommand() {
            public void action() {
                String marking = req.getMarking();
                int type = req.getType();
                int num = req.getNum();
                backRankBaseLogic(marking, type, num);
            }
        }, DealType.MAIN);
    }

    /**
     * 后台获取军团成员
     *
     * @param req
     * @param handler void
     */
    public void getPartyMembers(final GetPartyMembersRq req,
                                ServerHandler handler) {
        GameServer.getInstance().mainLogicServer.addCommand(new ICommand() {
            public void action() {
                String marking = req.getMarking();
                String partyName = req.getPartyName();
                backPartyMembersLogic(marking, partyName);
            }
        }, DealType.MAIN);
    }

    /**
     * 统计信息记录到日志
     *
     * @param req
     * @param handler void
     */
    public void censusBase(final CensusBaseRq req, final ServerHandler handler) {
        GameServer.getInstance().mainLogicServer.addCommand(new ICommand() {
            @Override
            public void action() {
                String marking = req.getMarking();
                int alv = req.getAlv();
                int blv = req.getBlv();
                int vip = req.getVip();
                int type = req.getType();
                int id = req.getId();
                int count = req.getCount();
                censusBaseLogic(marking, alv, blv, vip, type, id, count);
            }
        }, DealType.MAIN);

    }

    /**
     * 后台通过账号服调用给玩家发邮件
     *
     * @param req
     * @param handler void
     */
    public void sendMail(final SendToMailRq req, final ServerHandler handler) {
        String moldId = req.getMoldId();
        if (moldId == null || "".equals(moldId)) {
            LogUtil.error("后台通过账号服调用给玩家发邮件 出错 ={}", moldId);
            return;
        }
        GameServer.getInstance().mainLogicServer.addCommand(new ICommand() {
            @Override
            public void action() {
                int moldId = Integer.parseInt(req.getMoldId());
                String title = req.getTitle();
                String content = req.getContont();
                String award = req.getAward();
                String to = req.getTo();
                int type = req.getType();
                String channelNo = req.getChannelNo();// 0全体  其他  渠道1|渠道2
                int online = req.getOnline();// 0全体 1在线
                String making = req.getMarking();
                int avip = req.getAvip();
                int bvip = req.getBvip();
                int alv = req.getAlv();
                int blv = req.getBlv();
                String partys = req.getPartys();
                sendMailLogic(making, type, channelNo, online, moldId, title, content, award, to, alv, blv, avip, bvip, partys);
            }
        }, DealType.MAIN);

    }

    /**
     * GM发送公告
     *
     * @param req
     * @param handler void
     */
    public void sendNotice(final NoticeRq req, final ServerHandler handler) {
        GameServer.getInstance().mainLogicServer.addCommand(new ICommand() {
            @Override
            public void action() {
                sendNoticeLogic(req.getContent());
            }
        }, DealType.MAIN);
    }

    /**
     * 重新加载配置
     *
     * @param type void
     */
    public void reloadParam(final int type) {
        GameServer.getInstance().mainLogicServer.addCommand(new ICommand() {
            @Override
            public void action() {
                reloadParamLogic(type);
            }
        }, DealType.MAIN);
    }

    /**
     * 后台获取玩家属性
     *
     * @param markging
     * @param lordId
     * @param type
     * @return boolean
     */
    public boolean backLordBaseLogic(String markging, long lordId, int type) {
        Player player = playerDataManager.getPlayer(lordId);
        BackLordBaseRq.Builder builder = BackLordBaseRq.newBuilder();
        builder.setMarking(markging);
        builder.setType(type);
        if (player == null) {
            builder.setCode(1);
            Base.Builder baseBuilder = PbHelper.createRqBase(BackLordBaseRq.EXT_FIELD_NUMBER, null, BackLordBaseRq.ext, builder.build());
            GameServer.getInstance().sendMsgToPublic(baseBuilder, 1);
        } else {
            builder.setCode(200);
            switch (type) {
                case 1: {// 背包道具
                    Iterator<Prop> it = player.props.values().iterator();
                    while (it.hasNext()) {
                        Prop next = it.next();
                        if (next.getCount() > 0) {
                            builder.addTowInt(PbHelper.createTwoIntPb(next.getPropId(), next.getCount()));
                        }
                    }
                    break;
                }
                case 2: {// 武将
                    Iterator<Hero> it = player.heros.values().iterator();
                    while (it.hasNext()) {
                        Hero next = it.next();
                        if (next.getCount() > 0) {
                            builder.addTowInt(PbHelper.createTwoIntPb(next.getHeroId(), next.getCount()));
                        }
                    }
                    break;
                }
                case 3: {// 坦克
                    Iterator<Tank> it = player.tanks.values().iterator();
                    while (it.hasNext()) {
                        Tank next = it.next();
                        if (next.getCount() > 0) {
                            builder.addTowInt(PbHelper.createTwoIntPb(next.getTankId(), next.getCount()));
                        }
                    }
                    break;
                }
                case 4: {// 建筑
                    BackBuildingRq.Builder buildingBuilder = BackBuildingRq.newBuilder();
                    buildingBuilder.setMarking(markging);
                    buildingBuilder.setType(type);
                    buildingBuilder.setCode(200);

                    buildingBuilder.setWare1(player.building.getWare1());
                    buildingBuilder.setWare2(player.building.getWare2());
                    buildingBuilder.setTech(player.building.getTech());
                    buildingBuilder.setFactory1(player.building.getFactory1());
                    buildingBuilder.setFactory2(player.building.getFactory2());
                    buildingBuilder.setRefit(player.building.getRefit());
                    buildingBuilder.setCommand(player.building.getCommand());
                    buildingBuilder.setWorkShop(player.building.getWorkShop());
                    buildingBuilder.setLeqm(player.building.getLeqm());

                    Base.Builder baseBuilder = PbHelper.createRqBase(BackBuildingRq.EXT_FIELD_NUMBER, null, BackBuildingRq.ext, buildingBuilder.build());
                    GameServer.getInstance().sendMsgToPublic(baseBuilder, 1);
                    return true;
                }
                case 5: {// 科技
                    Iterator<Science> it = player.sciences.values().iterator();
                    while (it.hasNext()) {
                        Science next = it.next();
                        builder.addTowInt(PbHelper.createTwoIntPb(next.getScienceId(), next.getScienceLv()));
                    }
                    break;
                }
                case 6: {// 配件
                    BackPartRq.Builder partBuilder = BackPartRq.newBuilder();
                    partBuilder.setMarking(markging);
                    partBuilder.setType(type);

                    partBuilder.setCode(200);
                    for (int i = 0; i < 5; i++) {
                        Map<Integer, Part> map = player.parts.get(i);
                        if (map != null) {
                            Iterator<Part> it = map.values().iterator();
                            while (it.hasNext()) {
                                partBuilder.addPart(PbHelper.createPartPb(it.next()));
                            }
                        }
                    }
                    Base.Builder baseBuilder = PbHelper.createRqBase(BackPartRq.EXT_FIELD_NUMBER, null, BackPartRq.ext, partBuilder.build());
                    GameServer.getInstance().sendMsgToPublic(baseBuilder, 1);
                    return true;
                }
                case 7: {// 装备
                    BackEquipRq.Builder equipBuilder = BackEquipRq.newBuilder();
                    equipBuilder.setMarking(markging);
                    equipBuilder.setType(type);

                    equipBuilder.setCode(200);
                    for (int i = 0; i < 7; i++) {
                        Map<Integer, Equip> equipMap = player.equips.get(i);
                        Iterator<Equip> it = equipMap.values().iterator();
                        while (it.hasNext()) {
                            equipBuilder.addEquip(PbHelper.createEquipPb(it.next()));
                        }
                    }
                    Base.Builder baseBuilder = PbHelper.createRqBase(BackEquipRq.EXT_FIELD_NUMBER, null, BackEquipRq.ext, equipBuilder.build());
                    GameServer.getInstance().sendMsgToPublic(baseBuilder, 1);
                    return true;
                }
                case 8: {// 阵型
                    BackFormRq.Builder formBuilder = BackFormRq.newBuilder();
                    formBuilder.setMarking(markging);
                    formBuilder.setType(type);

                    formBuilder.setCode(200);
                    for (Form form : player.forms.values()) {
                        formBuilder.addForms(PbHelper.createFormPb(form));
                    }
                    Base.Builder baseBuilder = PbHelper.createRqBase(BackFormRq.EXT_FIELD_NUMBER, null, BackFormRq.ext, formBuilder.build());
                    GameServer.getInstance().sendMsgToPublic(baseBuilder, 1);
                    return true;
                }
                case 9: { //勋章详情
                    BackPartRq.Builder partBuilder = BackPartRq.newBuilder();
                    partBuilder.setMarking(markging);
                    partBuilder.setType(type);
                    partBuilder.setCode(200);

                    for (Map<Integer, Medal> map : player.medals.values()) {
                        Iterator<Medal> it = map.values().iterator();

                        while (it.hasNext()) {
                            Medal next = it.next();

                            CommonPb.Part.Builder pbuilder = CommonPb.Part.newBuilder();
                            pbuilder.setKeyId(next.getKeyId());
                            pbuilder.setPartId(next.getMedalId());
                            pbuilder.setPos(next.getPos());
                            pbuilder.setUpLv(next.getUpLv());
                            pbuilder.setRefitLv(next.getRefitLv());

                            partBuilder.addPart(pbuilder);
                        }
                    }
                    Base.Builder baseBuilder = PbHelper.createRqBase(BackPartRq.EXT_FIELD_NUMBER, null, BackPartRq.ext, partBuilder.build());
                    GameServer.getInstance().sendMsgToPublic(baseBuilder, 1);
                    return true;
                }
                case 10: { //多余勋章
                    BackPartRq.Builder partBuilder = BackPartRq.newBuilder();
                    partBuilder.setMarking(markging);
                    partBuilder.setType(type);
                    partBuilder.setCode(200);

                    for (Map<Integer, Medal> map : player.medals.values()) {
                        Iterator<Medal> it = map.values().iterator();

                        while (it.hasNext()) {
                            Medal next = it.next();
                            if (next.getPos() == 1) //在身上
                                continue;

                            CommonPb.Part.Builder pbuilder = CommonPb.Part.newBuilder();
                            pbuilder.setKeyId(next.getKeyId());
                            pbuilder.setUpLv(next.getUpLv());
                            pbuilder.setRefitLv(next.getRefitLv());
                            pbuilder.setPos(next.getPos());
                            pbuilder.setPartId(next.getMedalId());

                            partBuilder.addPart(pbuilder);
                        }
                    }
                    Base.Builder baseBuilder = PbHelper.createRqBase(BackPartRq.EXT_FIELD_NUMBER, null, BackPartRq.ext, partBuilder.build());
                    GameServer.getInstance().sendMsgToPublic(baseBuilder, 1);
                    return true;
                }
                case 11: { //勋章碎片
                    Iterator<MedalChip> it = player.medalChips.values().iterator();
                    while (it.hasNext()) {
                        MedalChip chip = it.next();
                        builder.addTowInt(PbHelper.createTwoIntPb(chip.getChipId(), chip.getCount()));
                    }
                    break;
                }
                case 12: { //勋章材料
                    Lord lord = player.lord;
                    builder.addTowInt(PbHelper.createTwoIntPb(1, lord.getDetergent()));
                    builder.addTowInt(PbHelper.createTwoIntPb(2, lord.getGrindstone()));
                    builder.addTowInt(PbHelper.createTwoIntPb(3, lord.getPolishingMtr()));
                    builder.addTowInt(PbHelper.createTwoIntPb(4, lord.getMaintainOil()));
                    builder.addTowInt(PbHelper.createTwoIntPb(5, lord.getGrindTool()));
                    builder.addTowInt(PbHelper.createTwoIntPb(6, lord.getPrecisionInstrument()));
                    builder.addTowInt(PbHelper.createTwoIntPb(7, lord.getMysteryStone()));
                    builder.addTowInt(PbHelper.createTwoIntPb(8, lord.getCorundumMatrial()));
                    builder.addTowInt(PbHelper.createTwoIntPb(9, lord.getInertGas()));
                    break;
                }
                case 13: { //军备详情
                    for (LordEquip equip : player.leqInfo.getPutonLordEquips().values()) {
                        builder.addTowInt(PbHelper.createTwoIntPb(equip.getEquipId(), equip.getLv()));
                    }
                    break;
                }
                case 14: { //多余军备
                    //<equipId, count>
                    for (LordEquip equip : player.leqInfo.getStoreLordEquips().values()) {
                        builder.addTowInt(PbHelper.createTwoIntPb(equip.getEquipId(), equip.getLv()));
                    }
                    break;
                }
                case 15: { //军备图纸、材料
                    if (!player.leqInfo.getLeqMat().isEmpty()) {
                        Iterator<Prop> it = player.leqInfo.getLeqMat().values().iterator();
                        Prop prop;
                        while (it.hasNext()) {
                            prop = it.next();
                            builder.addTowInt(PbHelper.createTwoIntPb(prop.getPropId(), prop.getCount()));
                        }
                    }
                    break;
                }
                case 16: { // 荒宝碎片数
                    Lord lord = player.lord;
                    builder.addTowInt(PbHelper.createTwoIntPb(1, lord.getHuangbao()));
                    break;
                }
                case 17: { // 勋章展厅展示勋章id
                    for (Map<Integer, MedalBouns> map : player.medalBounss.values()) {
                        Iterator<MedalBouns> it = map.values().iterator();
                        while (it.hasNext()) {
                            MedalBouns medalBouns = it.next();
                            builder.addTowInt(PbHelper.createTwoIntPb(medalBouns.getMedalId(), medalBouns.getState()));
                        }
                    }
                    break;
                }
                default:
                    break;
            }
            Base.Builder baseBuilder = PbHelper.createRqBase(BackLordBaseRq.EXT_FIELD_NUMBER, null, BackLordBaseRq.ext, builder.build());
            GameServer.getInstance().sendMsgToPublic(baseBuilder, 1);
        }
        return true;
    }

    /**
     * 获取排行信息
     *
     * @param markging
     * @param type
     * @param num
     * @return boolean
     */
    public boolean backRankBaseLogic(String markging, int type, int num) {
        BackRankBaseRq.Builder builder = BackRankBaseRq.newBuilder();
        builder.setMarking(markging);
        builder.setType(type);
        builder.setCode(200);
        switch (type) {
            case 7:
                for (int i = 0; i < num; i++) {
                    Arena arena = arenaDataManager.getArenaByRank(i);
                    if (arena == null) {
                        continue;
                    }
                    Lord lord = playerDataManager.getPlayer(Long.valueOf(arena.getLordId())).lord;
                    if (lord != null) {
                        builder.addRankData(PbHelper.createRankData(lord.getNick(), lord.getLevel(), arena.getFight(), 0));
                    }
                }
                break;
            case 20:
                List<PartyRank> partyRankList = partyDataManager.getPartyRanks();
                for (int i = 0; i < partyRankList.size() && i < num; i++) {
                    PartyRank partyRank = partyRankList.get(i);
                    PartyData partyData = partyDataManager.getParty(partyRank.getPartyId());
                    builder.addRankData(PbHelper.createRankData(partyData.getPartyName(), partyRank.getLevel(), partyRank.getFight(), 0));
                }
                break;
            default:
                rankDataManager.getRank(type, num, builder);
                break;
        }
        Base.Builder baseBuilder = PbHelper.createRqBase(BackRankBaseRq.EXT_FIELD_NUMBER, null, BackRankBaseRq.ext, builder.build());
        GameServer.getInstance().sendMsgToPublic(baseBuilder, 1);
        return true;
    }

    /**
     * 查询军团成员
     *
     * @param marking
     * @param partyName
     * @return boolean
     */
    public boolean backPartyMembersLogic(String marking, String partyName) {
        BackPartyMembersRq.Builder builder = BackPartyMembersRq.newBuilder();
        builder.setMarking(marking);
        builder.setCode(200);

        PartyData partyData = partyDataManager.getParty(partyName);
        List<Member> list = partyDataManager.getMemberList(partyData.getPartyId());
        for (Member e : list) {
            Player player = playerDataManager.getPlayer(e.getLordId());
            if (player == null) {
                continue;
            }
            Lord lord = player.lord;
            if (lord == null) {
                continue;
            }
            int online = 0;
            if (!player.isLogin) {
                online = player.lord.getOffTime();
            }
            builder.addPartyMember(PbHelper.createPartyMemberPb(e, lord, online));
        }
        Base.Builder baseBuilder = PbHelper.createRqBase(BackPartyMembersRq.EXT_FIELD_NUMBER, null, BackPartyMembersRq.ext, builder.build());
        GameServer.getInstance().sendMsgToPublic(baseBuilder, 1);
        return true;
    }

    /**
     * 统计数据记录到日志
     *
     * @param markging
     * @param alv
     * @param blv
     * @param vip
     * @param type
     * @param id
     * @param count
     * @return boolean
     */
    public boolean censusBaseLogic(String markging, int alv, int blv, int vip, int type, int id, int count) {
        Map<Long, Player> playerCache = playerDataManager.getPlayers();

        String time = DateHelper.displayNowDateTime();

        switch (type) {
            case 1: {// 道具
                Iterator<Player> it = playerCache.values().iterator();

                while (it.hasNext()) {
                    Player next = it.next();
                    Lord lord = next.lord;
                    if (lord == null) {
                        continue;
                    }
                    if (alv != 0 && lord.getLevel() < alv) {
                        continue;
                    }
                    if (blv != 0 && lord.getLevel() > blv) {
                        continue;
                    }
                    Prop prop = next.props.get(id);
                    if (prop != null && prop.getCount() >= count) {
                        StringBuffer sb = new StringBuffer();
                        sb.append("censusBase").append("|").append("prop").append("|");
                        sb.append(time + "|" + lord.getLordId()).append("|").append(lord.getNick()).append("|").append(lord.getLevel()).append("|")
                                .append(lord.getVip()).append("|").append(prop.getPropId()).append("|").append(prop.getCount());
//					LogHelper.PROP_LOGGER.error(sb.toString());
                        LogUtil.gm(sb);
                    }
                }
                break;
            }
            case 2: {// 武将
                Iterator<Player> it = playerCache.values().iterator();
                while (it.hasNext()) {
                    Player next = it.next();
                    Lord lord = next.lord;
                    if (lord == null) {
                        continue;
                    }
                    if (alv != 0 && lord.getLevel() < alv) {
                        continue;
                    }
                    if (blv != 0 && lord.getLevel() > blv) {
                        continue;
                    }
                    Hero hero = next.heros.get(id);
                    if (hero != null && hero.getCount() >= count) {
                        StringBuffer sb = new StringBuffer();
                        sb.append("censusBase").append("|").append("hero").append("|");
                        sb.append(time + "|" + lord.getLordId()).append("|").append(lord.getNick()).append("|").append(lord.getLevel()).append("|")
                                .append(lord.getVip()).append("|").append(hero.getHeroId()).append("|").append(hero.getCount());
//					LogHelper.HERO_LOGGER.error(sb.toString());
                        LogUtil.gm(sb);
                    }
                }
                break;
            }
            case 16: {// 金币
                Iterator<Player> it = playerCache.values().iterator();
                while (it.hasNext()) {
                    Player next = it.next();
                    Lord lord = next.lord;
                    if (lord == null) {
                        continue;
                    }
                    if (alv != 0 && lord.getLevel() < alv) {
                        continue;
                    }
                    if (blv != 0 && lord.getLevel() > blv) {
                        continue;
                    }
                    if (lord.getGold() >= count) {
                        StringBuffer sb = new StringBuffer();
                        sb.append("censusBase").append("|").append("gold").append("|");
                        sb.append(time + "|" + lord.getLordId()).append("|").append(lord.getNick()).append("|").append(lord.getLevel()).append("|")
                                .append(lord.getVip()).append("|").append(lord.getGold());
//					LogHelper.GOLD_LOGGER.error(sb.toString());
                        LogUtil.gm(sb);
                    }
                }
                break;
            }

            default:
                break;
        }
        // BackLordBaseRq.Builder builder = BackLordBaseRq.newBuilder();
        // builder.setMarking(markging);
        // builder.setType(type);
        // if (player == null) {
        // builder.setCode(1);
        // Base.Builder baseBuilder =
        // PbHelper.createRqBase(BackLordBaseRq.EXT_FIELD_NUMBER, null,
        // BackLordBaseRq.ext, builder.build());
        // GameServer.getInstance().sendMsgToPublic(baseBuilder);
        // } else {
        // builder.setCode(200);
        // switch (type) {
        // case 1: {// 背包道具
        // Iterator<Prop> it = player.props.values().iterator();
        // while (it.hasNext()) {
        // Prop next = it.next();
        // builder.addTowInt(PbHelper.createTwoIntPb(next.getPropId(),
        // next.getCount()));
        // }
        // break;
        // }
        // case 2: {// 武将
        // Iterator<Hero> it = player.heros.values().iterator();
        // while (it.hasNext()) {
        // Hero next = it.next();
        // builder.addTowInt(PbHelper.createTwoIntPb(next.getHeroId(),
        // next.getCount()));
        // }
        // break;
        // }
        // case 3: {// 坦克
        // Iterator<Tank> it = player.tanks.values().iterator();
        // while (it.hasNext()) {
        // Tank next = it.next();
        // builder.addTowInt(PbHelper.createTwoIntPb(next.getTankId(),
        // next.getCount()));
        // }
        // break;
        // }
        // case 4: {// 建筑
        // BackBuildingRq.Builder buildingBuilder = BackBuildingRq.newBuilder();
        // buildingBuilder.setMarking(markging);
        // buildingBuilder.setType(type);
        // buildingBuilder.setCode(200);
        //
        // buildingBuilder.setWare1(player.building.getWare1());
        // buildingBuilder.setWare2(player.building.getWare2());
        // buildingBuilder.setTech(player.building.getTech());
        // buildingBuilder.setFactory1(player.building.getFactory1());
        // buildingBuilder.setFactory2(player.building.getFactory2());
        // buildingBuilder.setRefit(player.building.getRefit());
        // buildingBuilder.setCommand(player.building.getCommand());
        // buildingBuilder.setWorkShop(player.building.getWorkShop());
        //
        // Base.Builder baseBuilder =
        // PbHelper.createRqBase(BackBuildingRq.EXT_FIELD_NUMBER, null,
        // BackBuildingRq.ext, buildingBuilder.build());
        // GameServer.getInstance().sendMsgToPublic(baseBuilder);
        // return true;
        // }
        // case 5: {// 科技
        // Iterator<Science> it = player.sciences.values().iterator();
        // while (it.hasNext()) {
        // Science next = it.next();
        // builder.addTowInt(PbHelper.createTwoIntPb(next.getScienceId(),
        // next.getScienceLv()));
        // }
        // break;
        // }
        // case 6: {// 配件
        // BackPartRq.Builder partBuilder = BackPartRq.newBuilder();
        // partBuilder.setMarking(markging);
        // partBuilder.setType(type);
        //
        // partBuilder.setCode(200);
        // for (int i = 0; i < 5; i++) {
        // Map<Integer, Part> map = player.parts.get(i);
        // Iterator<Part> it = map.values().iterator();
        // while (it.hasNext()) {
        // partBuilder.addPart(PbHelper.createPartPb(it.next()));
        // }
        // }
        // Base.Builder baseBuilder =
        // PbHelper.createRqBase(BackPartRq.EXT_FIELD_NUMBER, null,
        // BackPartRq.ext, partBuilder.build());
        // GameServer.getInstance().sendMsgToPublic(baseBuilder);
        // return true;
        // }
        // default:
        // break;
        // }
        // Base.Builder baseBuilder =
        // PbHelper.createRqBase(BackLordBaseRq.EXT_FIELD_NUMBER, null,
        // BackLordBaseRq.ext, builder.build());
        // GameServer.getInstance().sendMsgToPublic(baseBuilder);
        // }
        return true;
    }

    /**
     * 禁用角色
     *
     * @param forbiddenId
     * @param nick        角色名
     * @param time
     * @return boolean
     */
    public boolean forbiddenLogic(int forbiddenId, String nick, int time) {
        if (forbiddenId == 1) {
            gmService.gmSilence(nick, time);
        } else if (forbiddenId == 2) {
            gmService.gmSilence(nick, 0);
        } else if (forbiddenId == 3) {
            gmService.gmForbidden(nick, time);
            gmService.gmKick(nick);
        } else if (forbiddenId == 4) {
            gmService.gmForbidden(nick, 0);
        } else if (forbiddenId == 5) {
            gmService.gmKick(nick);
        }
        return true;
    }

    /**
     * 禁用角色
     *
     * @param forbiddenId
     * @param lordId      角色编号
     * @param time
     * @return boolean
     */
    public boolean forbiddenLogic(int forbiddenId, long lordId, int time) {
        if (forbiddenId == 1) {
            Player player = playerDataManager.getPlayer(lordId);
            if (player != null && player.account.getIsGm() == 0) {
                player.lord.setSilence(time);
            }
        } else if (forbiddenId == 2) {
            Player player = playerDataManager.getPlayer(lordId);
            if (player != null && player.account.getIsGm() == 0) {
                player.lord.setSilence(0);
            }
        } else if (forbiddenId == 3) {
            Player player = playerDataManager.getPlayer(lordId);
            if (player != null && player.account.getIsGm() == 0) {
                player.account.setForbid(time);
                if (player.isLogin && player.account.getIsGm() == 0 && player.ctx != null) {
                    player.ctx.close();
                }
            }
        } else if (forbiddenId == 4) {
            Player player = playerDataManager.getPlayer(lordId);
            if (player != null && player.account.getIsGm() == 0) {
                player.account.setForbid(0);
            }
        } else if (forbiddenId == 5) {
            Player player = playerDataManager.getPlayer(lordId);
            if (player != null && player.account.getIsGm() == 0) {
                if (player.isLogin && player.account.getIsGm() == 0 && player.ctx != null) {
                    player.ctx.close();
                }
            }
        }
        return true;
    }

    /**
     * 修改VIP
     *
     * @param lordId
     * @param type
     * @param value
     * @return boolean
     */
    public boolean modVipLogic(long lordId, int type, int value) {
        Player player = playerDataManager.getPlayer(lordId);
        LogUtil.info("lordId" + lordId + "type" + type + "value" + value);
        if (type == 1) {// 修改VIP
            if (player != null && value >= 0 && value <= 15) {
                player.lord.setVip(value);
                if (value > 0) {
                    chatService.sendWorldChat(chatService.createSysChat(SysChatId.BECOME_VIP, player.lord.getNick(), "" + value));
                }
            }
        } else if (type == 2) {
            if (player != null && value >= 0) {
                player.lord.setTopup(value);
                player.lord.setVip(staticVipDataMgr.calcVip(player.lord.getTopup()));
            }
        }
        return true;
    }

    /**
     * 修改玩家军备
     *
     * @param lordId
     * @param type
     * @param keyId
     * @param value
     * @return boolean
     */
    public boolean modLordLogic(long lordId, int type, int keyId, int value) {
        Player player = playerDataManager.getPlayer(lordId);
        if (player == null) {
            return true;
        }
        switch (type) {
            case 1: {// 背包道具
                return true;
            }
            case 2: {// 武将
                return true;
            }
            case 3: {// 坦克
                return true;
            }
            case 4: {// 建筑
                return true;
            }
            case 5: {// 科技
                return true;
            }
            case 6: {// 配件
                return true;
            }
            case 7: {// 装备
                for (int i = 0; i < 7; i++) {
                    Map<Integer, Equip> map = player.equips.get(i);
                    if (map != null) {
                        Iterator<Equip> it = map.values().iterator();
                        while (it.hasNext()) {
                            Equip equip = it.next();
                            if (equip.getKeyId() == keyId) {
                                equip.setLv(value);
                                equip.setExp(0);
                            }
                        }
                    }
                }
                return true;
            }
            default:
                break;
        }
        return true;
    }

    /**
     * 修改玩家道具属性
     *
     * @param lordId
     * @param type
     * @param props
     * @return boolean
     */
    public boolean modPropLogic(long lordId, int type, String props) {
        Player player = playerDataManager.getPlayer(lordId);
        List<List<Integer>> listList = new ArrayList<List<Integer>>();
        if (props == null || props.isEmpty()) {
            LogUtil.error("modPropLogic error  props:" + props);
            return false;
        }
        try {
            JSONArray arrays = JSONArray.parseArray(props);
            for (int i = 0; i < arrays.size(); i++) {
                List<Integer> list = new ArrayList<Integer>();
                JSONArray array = arrays.getJSONArray(i);
                for (int j = 0; j < array.size(); j++) {
                    list.add(array.getInteger(j));
                }
                listList.add(list);
            }
        } catch (Exception e) {
            LogUtil.error("modPropLogic error  props:" + props);
            throw e;
        }
        if (type == -1) { // 扣除道具
            for (List<Integer> list : listList) {
                if (!playerDataManager.checkPropIsEnougth(player, list.get(0),
                        list.get(1), list.get(2))) {
                    LogUtil.error("modPropLogic prope not enougth :"
                            + list.get(0) + "_" + list.get(1) + "_"
                            + list.get(2));
                    return false;
                }
            }
            for (List<Integer> list : listList) {
                playerDataManager.subProp(player, list.get(0), list.get(1),
                        list.get(2), AwardFrom.INNER_MOD_PROPS);
            }
        } else if (type == 1) { // 添加道具
            playerDataManager.addAwardList(player, listList,
                    AwardFrom.INNER_MOD_PROPS);
        }
        playerDataManager.synInnerModPropsToPlayer(player, type, listList);
        return true;
    }

    /**
     * 给玩家改名
     *
     * @param lordId
     * @param name
     * @return boolean
     */
    public boolean modNameLogic(long lordId, String name) {
        Player player = playerDataManager.getPlayer(lordId);
        if (name == null || name.isEmpty() || name.length() >= 12) {
            LogUtil.error("modNameLogic error  name:" + name);
            return false;
        }

        if (EmojiHelper.containsEmoji(name)) {
            LogUtil.error("modNameLogic error invalid char");
            return false;
        }

        if (!playerDataManager.takeNick(name)) {
            LogUtil.error("modNameLogic error same name");
            return false;
        }

        playerDataManager.replaceName(player, name);
        playerDataManager.rename(player, name);
        return true;
    }

    /**
     * 修改军团成员官职
     *
     * @param lordId
     * @param job
     * @return boolean
     */
    public boolean modPartyMemberJob(long lordId, int job) {
        Member member = partyDataManager.getMemberById(lordId);
        if (member == null) {
            return false;
        }
        int partyId = member.getPartyId();
        PartyData partyData = partyDataManager.getParty(partyId);
        if (partyData == null) {
            return false;
        }
        int count = partyDataManager.getMemberJobCount(partyId, job);
        Player player = playerDataManager.getPlayer(Long
                .valueOf(lordId));
        if (job == PartyType.LEGATUS) {
            if (count == 0) {
                member.setJob(job);
                partyDataManager.addPartyTrend(partyId, 5, new String[]{String.valueOf(lordId)});
                chatService.sendPartyChat(chatService.createSysChat(SysChatId.PARTY_LEADER, new String[]{player.lord.getNick()}), member.getPartyId());
            }
        } else if (job == PartyType.LEGATUS_CP) {
            if (count < PartyType.LEGATUS_CP) {
                member.setJob(job);
                partyDataManager.addPartyTrend(partyId, 6, new String[]{String.valueOf(lordId)});
                chatService.sendPartyChat(chatService.createSysChat(SysChatId.PARTY_VICE_LEADER, new String[]{player.lord.getNick()}), member.getPartyId());
            }
        } else if ((job == PartyType.JOB1) || (job == PartyType.JOB2) || (job == PartyType.JOB3) || (job == PartyType.JOB4)) {
            if (count < 3) {
                member.setJob(job);
                partyDataManager.addPartyTrend(partyId, 4, new String[]{String.valueOf(lordId), String.valueOf(job)});
                chatService.sendPartyChat(chatService.createSysChat(SysChatId.PARTY_JOB, new String[]{player.lord.getNick(), String.valueOf(job)}), member.getPartyId());
            }
        } else {
            member.setJob(job);
            partyDataManager.addPartyTrend(partyId, 4, new String[]{String.valueOf(lordId), String.valueOf(job)});
        }
        return true;
    }

    /**
     * 群发邮件
     *
     * @param marking
     * @param type
     * @param channelNo
     * @param online
     * @param moldId
     * @param title
     * @param content
     * @param award
     * @param to
     * @param alv
     * @param blv
     * @param avip
     * @param bvip
     * @param partys
     * @return boolean
     */
    public boolean sendMailLogic(String marking, int type, String channelNo, int online, int moldId, String title, String content, String award, String to,
                                 int alv, int blv, int avip, int bvip, String partys) {
        // 邮件内容
        String[] params = null;
        if (!title.equals("") && !content.equals("")) {
            params = new String[]{title, content};
        } else if (title.equals("") && !content.equals("")) {
            params = new String[]{content};
        } else if (!title.equals("") && content.equals("")) {
            params = new String[]{title};
        }

        // 附件内容
        List<Award> awardList = new ArrayList<Award>();
        if (!award.equals("")) {
            //道具类型|道具id|1|1,2&
            String[] awards = award.split("&");
            for (String itemStr : awards) {
                String[] item = itemStr.split("\\|");
                int item_type = Integer.parseInt(item[0]);
                int item_id = Integer.parseInt(item[1]);
                long item_num = Long.parseLong(item[2]);

                Award en = null;
                if (item.length == 4) {
                    String[] param = item[3].split(",");
                    if (param.length > 0) {
                        switch (item_type) {
                            case AwardType.EQUIP:
                                if (item_id < 701) {//只有装备有等级
                                    //等级
                                    int equipLv = Integer.parseInt(param[0]);
                                    if (equipLv < 1 || equipLv > Constant.EQUIP_OPEN_LV) {
                                        LogUtil.common("gm 发送装备 等级超过最大上限 " + equipLv);
                                        return false;
                                    }
                                    int starLv = 0;
                                    if (param.length >= 2) {
                                        starLv = Integer.parseInt(param[1]);
                                    }

                                    if (starLv > Constant.EQUIP_STAR_LV) {
                                        starLv = Constant.EQUIP_STAR_LV;
                                    }

                                    en = PbHelper.createAwardPbWithParam(item_type, item_id, item_num, 0, equipLv, starLv);
                                }
                                break;
                            case AwardType.PART:
                                //强化等级
                                int partStrengthLv = Integer.parseInt(param[0]);
                                //改造等级
                                int partRefitLv = Integer.parseInt(param[1]);
                                if (partStrengthLv < 0 || partStrengthLv > Constant.MAX_PART_UP_LV) {
                                    LogUtil.common("gm 发送配件强化等级超过最大上限 " + partStrengthLv);
                                    return false;
                                }
                                if (partRefitLv < 0 || partRefitLv > Constant.MAX_PART_REFIT_LV) {
                                    LogUtil.common("gm 发送配件改造等级超过最大上限 " + partRefitLv);
                                    return false;
                                }
                                en = PbHelper.createAwardPbWithParam(item_type, item_id, item_num, 0, partStrengthLv, partRefitLv);
                                break;
                            case AwardType.MEDAL:
                                //强化等级
                                int strengthLv = Integer.parseInt(param[0]);
                                //改造等级
                                int refitLv = Integer.parseInt(param[1]);
                                if (strengthLv < 0 || strengthLv > MedalConst.MAX_MEDAL_UP_LV) {
                                    LogUtil.common("gm 发送勋章强化等级超过最大上限 " + strengthLv);
                                    return false;
                                }
                                if (refitLv < 0 || refitLv > MedalConst.MAX_MEDAL_REFIT_LV) {
                                    LogUtil.common("gm 发送勋章改造等级超过最大上限 " + refitLv);
                                    return false;
                                }
                                en = PbHelper.createAwardPbWithParam(item_type, item_id, item_num, 0, strengthLv, refitLv);
                                break;
                            case AwardType.AWARK_HERO:
                                //觉醒将领
                                List<Integer> skillList = new ArrayList<>(5);
                                for (String lv : param) {
                                    if (lv.isEmpty()) {
                                        skillList.add(0);
                                    } else {
                                        skillList.add(Integer.parseInt(lv));
                                    }
                                }
                                en = PbHelper.createAwardPbWithParamList(item_type, item_id, 1, 0, skillList);
                                break;
                            case AwardType.LORD_EQUIP:
                                //军备+技能
                                skillList = new ArrayList<>(5);
                                for (String prm : param) {
                                    skillList.add(Integer.parseInt(prm));
                                }
                                en = PbHelper.createAwardPbWithParamList(item_type, item_id, 1, 0, skillList);
                                break;
                        }
                    }
                }
                if (en == null) {
                    en = PbHelper.createAwardPb(item_type, item_id, item_num);
                }
                awardList.add(en);
            }
        }
        // 渠道
        List<Integer> channelNoList = new ArrayList<>();
        String[] channelNos = channelNo.split("\\|");
        for (int i = 0; i < channelNos.length; i++) {
            channelNoList.add(Integer.valueOf(channelNos[i]));
        }

        // 发送对象
        if (type == 1) {// 按玩家发放
            gmService.playerMail(to, moldId, awardList, params);
            return true;
        } else if ((type == 2) || (type == 3)) {  // 按全服渠道发放  按军团发放
            Iterator<Player> it;
            if (type == 2) {
                it = this.playerDataManager.getPlayers().values().iterator();
            } else {
                List<Player> partyList = new ArrayList<>();
                String[] party = partys.split("\\|");
                for (int i = 0; i < party.length; i++) {
                    PartyData partyData = this.partyDataManager.getParty(party[i]);
                    if (partyData != null) {
                        List<Member> members = this.partyDataManager.getMemberList(partyData.getPartyId());
                        for (Member member : members) {
                            partyList.add(playerDataManager.getPlayer(Long.valueOf(member.getLordId())));
                        }
                    }
                }
                it = partyList.iterator();
            }
            while (it.hasNext()) {
                Player player = (Player) it.next();
                if (player == null || player.account == null || !player.isActive() || player.lord == null) {
                    continue;
                }
                if ((channelNo.equals("0")) || (channelNoList.contains(player.account.getPlatNo()))) {
                    Lord lord = player.lord;
                    if (alv != 0 && lord.getLevel() < alv) {
                        continue;
                    }
                    if (blv != 0 && lord.getLevel() > blv) {
                        continue;
                    }
                    if (avip != 0 && lord.getVip() < avip) {
                        continue;
                    }
                    if (bvip != 0 && lord.getVip() > bvip) {
                        continue;
                    }
                    if (awardList.size() == 0) {
                        if (online == 0) {// 全体成员
                            playerDataManager.sendNormalMail(player, moldId, TimeHelper.getCurrentSecond(), params);
                        } else if (online == 1 && (player.ctx != null)) {// 在线玩家
                            playerDataManager.sendNormalMail(player, moldId, TimeHelper.getCurrentSecond(), params);
                        }
                    } else {
                        if (online == 0) {// 全体成员
                            playerDataManager.sendAttachMail(AwardFrom.GM_SEND, player, awardList, moldId, TimeHelper.getCurrentSecond(), params);
                        } else if (online == 1 && player.ctx != null) {// 在线玩家
                            playerDataManager.sendAttachMail(AwardFrom.GM_SEND, player, awardList, moldId, TimeHelper.getCurrentSecond(), params);
                        }
                    }
                }
            }
            return true;
        } else if (type == 3) {  // 按军团发放

        } else if (type == 4) {// 按玩家发放 角色id
            gmService.playerMailByLordId(to, moldId, awardList, params);
        }
        return true;
    }

    /**
     * 发系统公告
     *
     * @param content
     * @return boolean
     */
    public boolean sendNoticeLogic(String content) {
        Chat chat = chatService.createSysChat(SysChatId.SYS_HORN, content);
        chatService.sendHornChat(chat, 1);
        return true;
    }

    /**
     * 重新加载配置
     *
     * @param type
     * @return boolean
     */
    public boolean reloadParamLogic(int type) {
        try {
            if (type == 1) {
                loadService.loadSystem();
            } else if (type == 2) {
                loadService.reloadAll();
            }
        } catch (Exception e) {
            LogUtil.error("热加载配置数据数据出错", e);
            return false;
        }
        return true;
    }

    /**
     * 互换两个账号的角色
     *
     * @param req
     * @param lordRelevanceRqHandler void
     */
    public void lordRelevance(final InnerPb.LordRelevanceRq req, LordRelevanceRqHandler lordRelevanceRqHandler) {
        GameServer.getInstance().mainLogicServer.addCommand(new ICommand() {
            @Override
            public void action() {
                long srcLordId = req.getSrcLordId();
                long destLordId = req.getDestLordId();
                lordRelevanceLogic(srcLordId, destLordId);
            }
        }, DealType.MAIN);
    }

    /**
     * 互换两个账号的角色
     *
     * @param srcLordId
     * @param destLordId void
     */
    private void lordRelevanceLogic(long srcLordId, long destLordId) {
        Player srcPlayer = playerDataManager.getPlayer(srcLordId);
        Player destPlayer = playerDataManager.getPlayer(destLordId);

        //先将2个玩家都踢下线
        if (srcPlayer.isLogin && srcPlayer.ctx != null) {
            srcPlayer.ctx.close();
        }

        if (destPlayer.isLogin && destPlayer.ctx != null) {
            destPlayer.ctx.close();
        }

        Account srcAcc = srcPlayer.account;

        LogUtil.common("lordRelevance  before:  source" + srcAcc.getLordId() + ",name" + srcAcc.getWhiteName() + ",regist time" + srcAcc.getCreateDate());
        Account destAcc = destPlayer.account;
        LogUtil.common("lordRelevance  before:  dest  " + destAcc.getLordId() + ",name" + destAcc.getWhiteName() + ",regist time" + destAcc.getCreateDate());


        //更新数据库
        Account destSaveAcc = new Account();
        destSaveAcc.setLordId(0);
        destSaveAcc.setKeyId(destAcc.getKeyId());
        playerDataManager.updatePlatNo(destSaveAcc);


        Account srcSaveAcc = new Account();
        srcSaveAcc.setLordId(destPlayer.lord.getLordId());
        srcSaveAcc.setKeyId(srcAcc.getKeyId());
        playerDataManager.updatePlatNo(srcSaveAcc);

        destSaveAcc.setLordId(srcPlayer.lord.getLordId());
        playerDataManager.updatePlatNo(destSaveAcc);

        //更新内存
        destAcc.setLordId(srcPlayer.lord.getLordId());
        srcAcc.setLordId(destPlayer.lord.getLordId());

        //更新player 与account 关联
        destPlayer.account = srcAcc;
        srcPlayer.account = destAcc;
        LogUtil.common("lordRelevance  after change:  source " + srcAcc.getLordId() + ",regist time" + srcAcc.getCreateDate());
        LogUtil.common("lordRelevance  after change:  dest   " + destAcc.getLordId() + ",regist time" + destAcc.getCreateDate());
    }

    /**
     * 热更指定类名的Class定义
     *
     * @param req
     * @return
     */
    public boolean hotfixClass(InnerPb.HotfixClassRq req) {
        hotfixDataManager.hotfixWithId(req.getHotfixId());
        return true;
    }

    /**
     * 临时执行线上玩家修复逻辑
     *
     * @return
     */
    public boolean executeHotfix(InnerPb.ExecutHotfixRq req) {
        dataRepairDM.executeHotfix();
        return true;
    }

    /**
     * 给玩家增加保护罩(通常使用在停服维护时间过长时)
     *
     * @param req
     * @return
     */
    public boolean addAttackFreeBuff(AddAttackFreeBuffRq req) {
        int vaildSec = req.getSecond();
        if (vaildSec < 1) {
            LogUtil.error("add attack buff fail, because add error second :" + req.getSecond());
            return false;
        }
        List<Long> list = req.getLordIdList();
        if (list != null && !list.isEmpty()) {
            //给部分玩家增加保护罩
            int nowSec = TimeHelper.getCurrentSecond();
            int endTime = nowSec + vaildSec;
            for (Long lordId : list) {
                Player player = playerDataManager.getPlayer(lordId);
                if (player != null) {
                    Effect effect = player.effects.get(EffectType.ATTACK_FREE);
                    if (effect != null) {

                        int oldEndTime = effect.getEndTime();
                        effect.setEndTime(Math.max(effect.getEndTime(), nowSec) + vaildSec);
                        LogLordHelper.attackFreeBuff(AwardFrom.DO_SOME, player, 1, oldEndTime, effect.getEndTime(), 0);

                    } else {
                        effect = new Effect(EffectType.ATTACK_FREE, endTime);
                        player.effects.put(EffectType.ATTACK_FREE, effect);
                        LogLordHelper.attackFreeBuff(AwardFrom.DO_SOME, player, 1, 0, effect.getEndTime(), 0);
                    }
                    playerDataManager.sendNormalMail(player, MailType.MOLD_ATTACK_FREE_MAINTAIN, nowSec, String.valueOf(vaildSec));
                    LogUtil.common(String.format("lordId :%d, add attack free succ, endTime :%s", lordId, DateHelper.formatDateMiniTime(new Date(effect.getEndTime() * 1000L))));
                }
            }
        } else {
            //给全服玩家增加保护罩
            playerDataManager.addAllPlayerFree(vaildSec, req.getSendMail());
            LogUtil.common("add attack free buff to all player finish : " + vaildSec);
        }
        return true;
    }


    /**
     * 后台获取玩家属性
     *
     * @param req
     */
    public void getEnergyBase(final GetEnergyBaseRq req) {
        GameServer.getInstance().mainLogicServer.addCommand(new ICommand() {
            @Override
            public void action() {
                String marking = req.getMarking();
                backEnergy(marking, req.getLordId());
            }
        }, DealType.MAIN);
    }


    public void backEnergy(String mak, long roleId) {
        Player player = playerDataManager.getPlayer(roleId);
        if (player == null) {
            return;
        }
        BackEnergyRq.Builder msg = BackEnergyRq.newBuilder();
        msg.setMarking(mak);
        msg.setCode(GameError.OK.getCode());
        CommonPb.LordEnergyInfo.Builder builder = CommonPb.LordEnergyInfo.newBuilder();
        builder.setRoleId(player.lord.getLordId());
        builder.setNick(player.lord.getNick());
        builder.setLevel(player.lord.getLevel());
        builder.setFight(player.lord.getFight());
        builder.setEnLevel(player.energyCore.getLevel());
        if (player.lord.getVip() > 0) {
            builder.setVip(player.lord.getVip());
        }
        if (player.lord.getTopup() > 0) {
            builder.setAllmoney(player.lord.getTopup());
        }
        Map<Integer, Map<Integer, Part>> parts = player.parts;
        for (int i = 1; i < parts.size(); i++) {
            Map<Integer, Part> integerPartMap = parts.get(i);
            if (integerPartMap != null && !integerPartMap.isEmpty()) {
                for (Part part : integerPartMap.values()) {
                    CommonPb.LordPart.Builder builder1 = CommonPb.LordPart.newBuilder();
                    if (part.getPartId() > 0) {
                        builder1.setPartId(part.getPartId());
                    }
                    if (part.getRefitLv() > 0) {
                        builder1.setUpLv(part.getRefitLv());
                    }
                    if (part.getRefitLv() > 0) {
                        builder1.setRefitLv(part.getRefitLv());
                    }
                    if (part.getSmeltLv() > 0) {
                        builder1.setSmeltLv(part.getSmeltLv());
                    }
                    builder.addPart(builder1);
                }
            }
        }
        msg.addInfo(builder);
        Base.Builder baseBuilder = PbHelper.createRqBase(BackEnergyRq.EXT_FIELD_NUMBER, null, BackEnergyRq.ext, msg.build());
        GameServer.getInstance().sendMsgToPublic(baseBuilder);
    }
}
