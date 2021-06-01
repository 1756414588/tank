/**
 * @Title: GmService.java
 * @Package com.game.service
 * @Description:
 * @author ZhangJun
 * @date 2015年9月6日 下午7:11:51
 * @version V1.0
 */
package com.game.service;

import com.game.constant.*;
import com.game.dao.impl.p.BuildingDao;
import com.game.dao.impl.p.DataNewDao;
import com.game.dao.impl.p.LordDao;
import com.game.dao.impl.p.ResourceDao;
import com.game.dataMgr.*;
import com.game.domain.MedalBouns;
import com.game.domain.Member;
import com.game.domain.PartyData;
import com.game.domain.Player;
import com.game.domain.p.*;
import com.game.domain.p.lordequip.LordEquip;
import com.game.domain.s.*;
import com.game.domain.s.tactics.StaticTactics;
import com.game.manager.HonourDataManager;
import com.game.manager.PartyDataManager;
import com.game.manager.PlayerDataManager;
import com.game.manager.StaffingDataManager;
import com.game.message.handler.ClientHandler;
import com.game.pb.CommonPb;
import com.game.pb.CommonPb.Mail;
import com.game.pb.GamePb1.DoSomeRq;
import com.game.pb.GamePb1.DoSomeRs;
import com.game.pb.InnerPb.PayBackRq;
import com.game.server.GameServer;
import com.game.service.airship.AirshipTeamService;
import com.game.service.crossmine.MineRpcService;
import com.game.util.LogUtil;
import com.game.util.TimeHelper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.lang.reflect.Field;
import java.util.*;
import java.util.Map.Entry;
import java.util.regex.Pattern;

/**
 * @author ZhangJun
 * @ClassName: GmService
 * @Description: GM相关
 * @date 2015年9月6日 下午7:11:51
 */
@Service
public class GmService {
    @Autowired
    private StaffingDataManager staffingDataManager;

    @Autowired
    private PlayerDataManager playerDataManager;

    @Autowired
    private BuildingService buildingService;

    @Autowired
    private GmToolService gmToolService;

    @Autowired
    private PartyService partyService;

    @Autowired
    private ChatService chatService;

    @Autowired
    private LordDao lordDao;

    @Autowired
    private CrossService crossService;

    @Autowired
    private WarService warService;

    @Autowired
    private CrossPartyService crossPartyService;

    @Autowired
    private StaticEquipDataMgr staticEquipDataMgr;

    @Autowired
    private StaticVipDataMgr staticVipDataMgr;

    @Autowired
    private StaticHeroDataMgr staticHeroDataMgr;

    @Autowired
    private AirshipTeamService airshipTeamService;

    @Autowired
    private PayService payService;
    @Autowired
    private RedPlanService redPlanService;

    @Autowired
    private SecretWeaponService secretWeaponService;

    @Autowired
    private StaticCombatDataMgr staticCombatDataMgr;
    @Autowired
    private FightLabService gightLabService;
    @Autowired
    private MilitaryScienceService militaryScienceService;
    @Autowired
    private ActivityNewService activityNewService;
    @Autowired
    private LordEquipService lordEquipService;
    @Autowired
    private FightLabService fightLabService;
    @Autowired
    private HonourDataManager honourDataManager;
    @Autowired
    private WorldService worldService;
    @Autowired
    private AltarBossService altarBossService;
    @Autowired
    private PartyDataManager partyDataManager;
    @Autowired
    private CombatService combatService;
    @Autowired
    private TacticsService tacticsService;
    @Autowired
    private ActivityKingService activityKingService;
    @Autowired
    private StaticTacticsDataMgr staticTacticsDataMgr;
    @Autowired
    private FriendService friendService;
    @Autowired
    private EnergyCoreService energyCoreService;

    /**
     * @param req
     * @param handler void
     * @throws @Title: doSome
     * @Description: 执行GM命令
     */
    public void doSome(DoSomeRq req, ClientHandler handler) {

        String str = req.getStr();
        String[] words = str.split(" ");
        int paramCount = words.length;
        if (paramCount < 2 || paramCount > 6) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }

        try {
            String cmd = null;
            String type = null;
            String id = "0";
            String count = "0";
            String lv = "0";
            String refitLv = "0";
            if (paramCount == 2) {
                cmd = words[0];
                type = words[1];
            } else if (paramCount == 3) {
                cmd = words[0];
                type = words[1];
                count = words[2];
                id = "0";
            } else if (paramCount == 4) {
                cmd = words[0];
                type = words[1];
                id = words[2];
                count = words[3];
            } else if (paramCount == 5) {
                cmd = words[0];
                type = words[1];
                id = words[2];
                count = words[3];
                lv = words[4];
            } else if (paramCount == 6) {
                cmd = words[0];
                type = words[1];
                id = words[2];
                count = words[3];
                lv = words[4];
                refitLv = words[5];
            }

            Player player = playerDataManager.getPlayer(handler.getRoleId());

            if (player.account.getIsGm() <= 0) {
                // LogHelper.GM_LOGGER.trace("player {" + player.roleId + "}
                // ilegal operating!");
                LogUtil.error("player {" + player.roleId + "} ilegal GM operating!");
                handler.sendErrorMsgToPlayer(GameError.NO_AUTHORITY);
                return;
            }

            // LogHelper.GM_LOGGER.trace("gm {" + player.lord.getNick() + "|" +
            // player.roleId + "} do operate {" + str + "}");
            LogUtil.gm("{" + player.lord.getNick() + "|" + player.roleId + "} do operate {" + str + "}");

            if ("add".equalsIgnoreCase(cmd)) {
                gmAdd(player, type, Long.valueOf(id), Integer.valueOf(count), Integer.valueOf(lv), Integer.valueOf(refitLv));
            } else if ("del".equalsIgnoreCase(cmd)) {
                delMail(Long.parseLong(type), Integer.parseInt(count));
            } else if ("set".equalsIgnoreCase(cmd)) {

                if ("friendliness".equalsIgnoreCase(type)) {
                    friendService.setPlayerFriendliness(player, id, Integer.valueOf(count));
                } else if (isInteger(count)) {
                    gmSet(handler, player, type, Integer.valueOf(id), Integer.valueOf(count), lv);
                } else {
                    copyPlayer(player.lord.getNick(), count);
                }

            } else if ("clear".equalsIgnoreCase(cmd)) {
                gmClear(player, type);
            } else if ("build".equalsIgnoreCase(cmd)) {
                gmBuild(player, Integer.valueOf(type), Integer.valueOf(count), handler);
                // return;
            } else if ("system".equalsIgnoreCase(cmd)) {
                gmSystem(type);
            } else if ("mail".equalsIgnoreCase(cmd)) {
                Mail mail = null;
                if (req.hasMail()) {
                    mail = req.getMail();
                } else {
                    handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
                    return;
                }

                // LogHelper.GM_LOGGER.trace("gm {" + player.roleId + "} send
                // mail {" + mail + "}");
                LogUtil.gm("{" + player.roleId + "} send mail {" + mail + "}");
                gmMail(mail, type);
                // return;
            } else if ("platMail".equalsIgnoreCase(cmd)) {
                Mail mail = null;
                if (req.hasMail()) {
                    mail = req.getMail();
                } else {
                    handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
                    return;
                }

                // LogHelper.GM_LOGGER.trace("gm {" + player.roleId + "} send
                // plat mail {" + mail + "}");
                LogUtil.gm("{" + player.roleId + "} send plat mail {" + mail + "}");
                gmPlatMail(mail, type);
                // return;
            } else if ("kick".equalsIgnoreCase(cmd)) {
                gmKick(type);
                // return;
            } else if ("silence".equalsIgnoreCase(cmd)) {
                gmSilence(type, Integer.valueOf(count));
                // return;
            } else if ("ganVip".equalsIgnoreCase(cmd)) {
                gmVip(type, Integer.valueOf(count));
                // return;
            } else if ("clearPlayer".equalsIgnoreCase(cmd)) {
                gmClearPlayer(type, count);
                // return;
            } else if ("clearAllPlayer".equalsIgnoreCase(cmd)) {
                gmClearAllPlayer(type);
                // return;
            } else if ("ganTopup".equalsIgnoreCase(cmd)) {
                gmTopup(type, Integer.valueOf(count));
                // return;
            } else if ("remove".equalsIgnoreCase(cmd)) {
                gmRemove(player, type, Integer.valueOf(count));
                // return;
            } else if ("removePlayer".equalsIgnoreCase(cmd)) {
                gmRemovePlayer(type, id, Integer.valueOf(count));
                // return;
            } else if ("removeAllPlayer".equalsIgnoreCase(cmd)) {
                gmRemoveAllPlayer(type, Integer.valueOf(count));
                // return;
            } else if ("setParty".equalsIgnoreCase(cmd)) {
                gmSetParty(type, id, Integer.valueOf(count), Integer.valueOf(lv));
            } else if ("setPlayer".equalsIgnoreCase(cmd)) {
                if (paramCount == 4) {
                    cmd = words[0];
                    type = words[1];
                    id = words[2];
                    lv = words[3];
                }
                gmSetPlayer(type, id, Integer.valueOf(count), Integer.valueOf(lv), refitLv);
            } else if ("airship".equalsIgnoreCase(cmd)) {
                gmAirship(player, handler, words);
            } else if ("relevance".equalsIgnoreCase(cmd)) {
                lordRelevance(player, type);
            } else if ("crossadd".equalsIgnoreCase(cmd)) {
                addCrossScore(1, type, count);
            } else if ("crossclear".equalsIgnoreCase(cmd)) {
                addCrossScore(2, type, count);
            }
        } catch (Exception e) {
            LogUtil.error(str, e);
        }

        DoSomeRs.Builder builder = DoSomeRs.newBuilder();
        handler.sendMsgToPlayer(DoSomeRs.ext, builder.build());
    }

    public static boolean isInteger(String str) {
        Pattern pattern = Pattern.compile("^[-\\+]?[\\d]*$");
        return pattern.matcher(str).matches();
    }

    /**
     * gm给前十军团报名跨服军团战
     *
     * @param handler void
     */
    private void gmCrossPartyReg(ClientHandler handler) {
        crossPartyService.gmCrossPartyReg(handler);
    }

    /**
     * 账号关联的GM 命令 relevance
     * @param srcPlayer
     * @param destName
     */
    private void lordRelevance(Player srcPlayer, String destName) {
        Lord destLord = lordDao.selectLordByNick(destName);
        Player destPlayer = playerDataManager.getPlayer(destLord.getLordId());

        Account srcAcc = srcPlayer.account;
        Account destAcc = destPlayer.account;

        // 更新数据库
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

        // 更新内存
        destAcc.setLordId(srcPlayer.lord.getLordId());
        srcAcc.setLordId(destPlayer.lord.getLordId());

        // 更新player 与account 关联
        destPlayer.account = srcAcc;
        srcPlayer.account = destAcc;

    }

    /**
     * 飞艇相关的GM 命令
     * @param player
     * @param handler
     * @param words
     */
    private void gmAirship(Player player, ClientHandler handler, String[] words) {
        String type = words[1];
        if ("crtt".equalsIgnoreCase(type)) {
            int airshipId = Integer.valueOf(words[2]);
            // 创建进攻队伍,并且把工会玩家全部加入进来
            airshipTeamService.gmCreateAirshipTeamAndJoin(player, handler, airshipId);
        } else if ("npc".equalsIgnoreCase(type)) {
            int airshipId = Integer.valueOf(words[2]);
            airshipTeamService.gmResetAirship2Npc(player, handler, airshipId);
        } else if ("guard".equalsIgnoreCase(type)) {
            int airshipId = Integer.valueOf(words[2]);
            airshipTeamService.gmJoinGuard(player, handler, airshipId);
        }
    }

    /**
     * 设置觉醒技能
     *
     * @param player
     * @param heroId void
     */
    private void awakeSkill1(Player player, int heroId, int skillId, int level) {
        for (AwakenHero awakenHero : player.awakenHeros.values()) {

            StaticHero curHero = staticHeroDataMgr.getStaticHero(awakenHero.getHeroId());

            StaticHero newHero = null;
            // 是否觉醒完成
            if (curHero.getAwakenSkillArr().size() == 0) {
                newHero = staticHeroDataMgr.getStaticHero(curHero.getAwakenHeroId());
            } else {
                newHero = curHero;
            }

            if (heroId == newHero.getHeroId()) {

                if (!newHero.getAwakenSkillArr().contains(skillId)) {
                    return;
                }
                StaticHeroAwakenSkill heroAwakenSkill = staticHeroDataMgr.getHeroAwakenSkill(skillId, level);

                if (heroAwakenSkill == null) {
                    return;
                }

                awakenHero.getSkillLv().put(skillId, level);

            }
        }
    }

    private void awakeSkill2(Player player, int heroId, int level) {
        for (AwakenHero awakenHero : player.awakenHeros.values()) {

            StaticHero curHero = staticHeroDataMgr.getStaticHero(awakenHero.getHeroId());

            StaticHero newHero = null;
            // 是否觉醒完成
            if (curHero.getAwakenSkillArr().size() == 0) {
                newHero = staticHeroDataMgr.getStaticHero(curHero.getAwakenHeroId());
            } else {
                newHero = curHero;
            }

            if (heroId == newHero.getHeroId()) {

                List<Integer> awakenSkillArr = newHero.getAwakenSkillArr();

                for (Integer skillId : awakenSkillArr) {
                    StaticHeroAwakenSkill heroAwakenSkill = null;

                    for (int l = 1; l <= level; l++) {
                        StaticHeroAwakenSkill temp = staticHeroDataMgr.getHeroAwakenSkill(skillId, l);
                        if (temp == null) {
                            heroAwakenSkill = staticHeroDataMgr.getHeroAwakenSkill(skillId, level - 1);
                            break;
                        } else {
                            heroAwakenSkill = temp;
                        }
                    }

                    awakenHero.getSkillLv().put(skillId, heroAwakenSkill.getLevel());
                }
            }
        }
    }

    private void awakeSkill3(Player player, int heroId) {
        for (AwakenHero awakenHero : player.awakenHeros.values()) {
            if (heroId == awakenHero.getHeroId()) {
                int keyId = awakenHero.getKeyId();
                awakenHero.getSkillLv().put(6, 4);
                player.awakenHeros.put(keyId, awakenHero);
            }
        }
    }

    private void awakeSkill4(Player player, int heroId) {
        for (AwakenHero awakenHero : player.awakenHeros.values()) {
            if (heroId == awakenHero.getHeroId()) {
                int keyId = awakenHero.getKeyId();
                awakenHero.getSkillLv().put(7, 5);
                awakenHero.getSkillLv().put(8, 5);
                awakenHero.getSkillLv().put(9, 5);
                awakenHero.getSkillLv().put(10, 5);
                player.awakenHeros.put(keyId, awakenHero);
            }
        }
    }

    /**
     * 给满坦克和将领
     *
     * @param player void
     */
    private void setGst(Player player) {
        // 拥有所有坦克并且99999个
        StaticTankDataMgr staticTankDataMgr = GameServer.ac.getBean(StaticTankDataMgr.class);
        for (Map.Entry<Integer, StaticTank> entry : staticTankDataMgr.getTankMap().entrySet()) {
            StaticTank std = entry.getValue();
            if (std.getTankId() > 130)
                continue;
            if (std.getName().contains("-"))
                continue;
            player.tanks.put(entry.getKey(), new Tank(entry.getKey(), 999999, 0));
        }
        // 获取所有普通将领1个
        player.heros.clear();
        for (Entry<Integer, StaticHero> entry : staticHeroDataMgr.getStaticHeroMap().entrySet()) {
            if (!staticHeroDataMgr.isAwakenHero(entry.getKey())) {
                playerDataManager.addAward(player, AwardType.HERO, entry.getKey(), 1, AwardFrom.DO_SOME);
            }
        }
    }

    /**
     * GM设置玩家到最强
     *
     * @param player void
     */
    public void gmNiub(Player player) {
        int lv = 90;
        // 设置玩家等级为80级
        player.lord.setLevel(lv);
        player.lord.setCommand(90);
        // 设置金币1000W
        playerDataManager.addAward(player, AwardType.GOLD, 0, 10000000, AwardFrom.DO_SOME);
        // 建筑等级都是80级
        player.building.setCommand(lv);
        player.building.setFactory1(lv);
        player.building.setFactory2(lv);
        player.building.setRefit(lv);
        player.building.setTech(lv);
        player.building.setWare1(lv);
        player.building.setWare2(lv);
        player.building.setWorkShop(lv);
        player.building.setLeqm(4);

        // 拥有所有坦克并且99999个
        StaticTankDataMgr staticTankDataMgr = GameServer.ac.getBean(StaticTankDataMgr.class);
        for (Map.Entry<Integer, StaticTank> entry : staticTankDataMgr.getTankMap().entrySet()) {
            StaticTank std = entry.getValue();
            if (std.getTankId() > 130)
                continue;
            if (std.getName().contains("-"))
                continue;
            player.tanks.put(entry.getKey(), new Tank(entry.getKey(), 999999, 0));
        }

        // 设置所有资源拥有20亿
        long value = 2000000000;
        Field[] fields = Resource.class.getDeclaredFields();
        for (Field field : fields) {
            field.setAccessible(true);
            String name = field.getName();
            if (name.equals("lordId") || name.equals("storeTime"))
                continue;
            if (name.indexOf("F") != name.length() - 1) {
                try {
                    field.setLong(player.resource, value);
                } catch (IllegalAccessException e) {
                    LogUtil.error("", e);
                }
            }
        }

        // 设置10万的繁荣度
        playerDataManager.addProsMax(player, 100000);

        // 设置VIP12
        player.lord.setVip(12);

        // 添加将领
        for (int i = 100; i < 109; i++) {

            StaticHero curHero = staticHeroDataMgr.getStaticHero(i);

            if (curHero != null) {
                playerDataManager.addAward(player, AwardType.HERO, i, 100, AwardFrom.DO_SOME);
            }


        }
        for (int j = 200; j < 340; j++) {
            StaticHero curHero = staticHeroDataMgr.getStaticHero(j);
            if (curHero != null) {
                playerDataManager.addAward(player, AwardType.HERO, j, 100, AwardFrom.DO_SOME);
            }
        }

        // 添加觉醒将领
        int[] array = {331, 340, 341, 342, 343, 344, 345, 346, 347, 348, 349, 350, 351, 357, 374};
        player.awakenHeros = new HashMap<Integer, AwakenHero>();
        for (int i = 0; i < array.length; i++) {
            StaticHero curHero = staticHeroDataMgr.getStaticHero(array[i]);

            if (curHero == null) {
                continue;
            }
            playerDataManager.addAwakenHero(player, array[i], AwardFrom.DO_SOME);
            awakeSkill2(player, array[i], 5);

        }

        // 6个位置的装备全部橙色满级
        Map<Integer, StaticEquip> equipMap = staticEquipDataMgr.getEquipsByQuality(5);
        for (int i = 0; i < 7; i++) {
            player.equips.put(i, new HashMap<Integer, Equip>());
        }
        for (int i = 1; i <= 6; i++) {
            for (Entry<Integer, StaticEquip> entry : equipMap.entrySet()) {
                StaticEquip data = entry.getValue();
                if (data.getEquipId() / 100 != 7) {// 经验装备
                    Equip equip = playerDataManager.addEquip(player, data.getEquipId(), lv, i, AwardFrom.DO_SOME);
                    equip.setStarlv(5);//目前最高5星
                }
            }
        }

        militaryScienceService.gm2UpMilitaryScience(player, 0);

        // 勋章
        if (!player.medals.get(0).containsKey(805)) {
            playerDataManager.addMedal(player, 805, 0, 80, 10, AwardFrom.DO_SOME);
        }
        if (!player.medals.get(0).containsKey(305)) {
            playerDataManager.addMedal(player, 305, 0, 80, 10, AwardFrom.DO_SOME);
        }
        // if (!player.medals.get(0).containsKey(1101)) {
        // playerDataManager.addMedal(player, 1101, 0, 80, 10, AwardFrom.DO_SOME);
        // }
        if (!player.medals.get(0).containsKey(605)) {
            playerDataManager.addMedal(player, 605, 0, 80, 10, AwardFrom.DO_SOME);
        }
        if (!player.medals.get(0).containsKey(105)) {
            playerDataManager.addMedal(player, 105, 0, 80, 10, AwardFrom.DO_SOME);
        }
        if (!player.medals.get(0).containsKey(405)) {
            playerDataManager.addMedal(player, 405, 0, 80, 10, AwardFrom.DO_SOME);
        }
        if (!player.medals.get(0).containsKey(905)) {
            playerDataManager.addMedal(player, 905, 0, 80, 10, AwardFrom.DO_SOME);
        }
        if (!player.medals.get(0).containsKey(705)) {
            playerDataManager.addMedal(player, 705, 0, 80, 10, AwardFrom.DO_SOME);
        }
        if (!player.medals.get(0).containsKey(205)) {
            playerDataManager.addMedal(player, 205, 0, 80, 10, AwardFrom.DO_SOME);
        }
        if (!player.medals.get(0).containsKey(1005)) {
            playerDataManager.addMedal(player, 1005, 0, 80, 10, AwardFrom.DO_SOME);
        }
        if (!player.medals.get(0).containsKey(505)) {
            playerDataManager.addMedal(player, 505, 0, 80, 10, AwardFrom.DO_SOME);
        }


        for (int a = 101; a <= 116; a++) {
            playerDataManager.addPart(player, a, 0, 80, 10, AwardFrom.DO_SOME);
        }

        for (int a = 201; a <= 216; a++) {
            playerDataManager.addPart(player, a, 0, 80, 10, AwardFrom.DO_SOME);
        }

        for (int a = 301; a <= 316; a++) {
            playerDataManager.addPart(player, a, 0, 80, 10, AwardFrom.DO_SOME);
        }

        for (int a = 401; a <= 416; a++) {
            playerDataManager.addPart(player, a, 0, 80, 10, AwardFrom.DO_SOME);
        }

        for (int a = 501; a <= 516; a++) {
            playerDataManager.addPart(player, a, 0, 80, 10, AwardFrom.DO_SOME);
        }

        for (int a = 601; a <= 616; a++) {
            playerDataManager.addPart(player, a, 0, 80, 10, AwardFrom.DO_SOME);
        }


        for (int a = 701; a <= 716; a++) {
            playerDataManager.addPart(player, a, 0, 80, 10, AwardFrom.DO_SOME);
        }

        for (int a = 801; a <= 816; a++) {
            playerDataManager.addPart(player, a, 0, 80, 10, AwardFrom.DO_SOME);
        }

        for (int a = 1001; a <= 1016; a++) {
            playerDataManager.addPart(player, a, 0, 80, 10, AwardFrom.DO_SOME);
        }

        for (int a = 1101; a <= 1116; a++) {
            playerDataManager.addPart(player, a, 0, 80, 10, AwardFrom.DO_SOME);
        }


        playerDataManager.addEnergyStone(player, 109, 100, AwardFrom.DO_SOME);
        playerDataManager.addEnergyStone(player, 209, 100, AwardFrom.DO_SOME);
        playerDataManager.addEnergyStone(player, 309, 100, AwardFrom.DO_SOME);
        playerDataManager.addEnergyStone(player, 409, 100, AwardFrom.DO_SOME);
        playerDataManager.addEnergyStone(player, 509, 100, AwardFrom.DO_SOME);
        playerDataManager.addEnergyStone(player, 609, 100, AwardFrom.DO_SOME);

        // 军备
        playerDataManager.addAward(player, 32, 1005, 3, AwardFrom.DO_SOME);
        playerDataManager.addAward(player, 32, 2005, 3, AwardFrom.DO_SOME);
        playerDataManager.addAward(player, 32, 3005, 3, AwardFrom.DO_SOME);
        playerDataManager.addAward(player, 32, 4005, 3, AwardFrom.DO_SOME);
        playerDataManager.addAward(player, 32, 5005, 3, AwardFrom.DO_SOME);
        playerDataManager.addAward(player, 32, 6005, 3, AwardFrom.DO_SOME);
        playerDataManager.addAward(player, 32, 7005, 3, AwardFrom.DO_SOME);
        playerDataManager.addAward(player, 32, 8005, 3, AwardFrom.DO_SOME);

        for (int i = 0; i < 5; i++) {
            playerDataManager.addAward(player, 32, 1004, 5, AwardFrom.DO_SOME);
            playerDataManager.addAward(player, 32, 2004, 5, AwardFrom.DO_SOME);
            playerDataManager.addAward(player, 32, 3004, 5, AwardFrom.DO_SOME);
            playerDataManager.addAward(player, 32, 4004, 5, AwardFrom.DO_SOME);
            playerDataManager.addAward(player, 32, 5004, 5, AwardFrom.DO_SOME);
            playerDataManager.addAward(player, 32, 6004, 5, AwardFrom.DO_SOME);
            playerDataManager.addAward(player, 32, 7004, 5, AwardFrom.DO_SOME);
            playerDataManager.addAward(player, 32, 8004, 5, AwardFrom.DO_SOME);
        }

        // 军备洗练
        Map<Integer, LordEquip> leqMap = player.leqInfo.getStoreLordEquips();
        if (!leqMap.isEmpty()) {
            for (LordEquip le : leqMap.values()) {
                for (int i = 1; i < 500; i++) {
                    lordEquipService.change(2, 0, le);
                }
            }
        }

        fightLabService.gmSetFightLabGraduateLevel(player);
    }

    /**
     * 增加玩家道具或属性
     *
     * @param player
     * @param str
     * @param id
     * @param count
     * @param lv
     * @param refitLv void
     */
    private void gmAdd(Player player, String str, long id, long count, int lv, int refitLv) {
        // GameServer.mainteEndTime = System.currentTimeMillis() + 2 * 60 * 1000;
        if ("exp".equalsIgnoreCase(str)) {
            playerDataManager.addAward(player, AwardType.EXP, (int) id, count, AwardFrom.DO_SOME);
        } else if ("gold".equalsIgnoreCase(str)) {
            playerDataManager.addAward(player, AwardType.GOLD, (int) id, count, AwardFrom.DO_SOME);
        } else if ("prop".equalsIgnoreCase(str)) {
            playerDataManager.addAward(player, AwardType.PROP, (int) id, count, AwardFrom.DO_SOME);
        } else if ("equip".equalsIgnoreCase(str)) {
            playerDataManager.addAward(player, AwardType.EQUIP, (int) id, lv, AwardFrom.DO_SOME);
        } else if ("chip".equalsIgnoreCase(str)) {
            playerDataManager.addAward(player, AwardType.CHIP, (int) id, count, AwardFrom.DO_SOME);
        } else if ("part".equalsIgnoreCase(str)) {
            // playerDataManager.addAward(player, AwardType.PART, id, lv,
            // AwardFrom.DO_SOME);
            playerDataManager.addPart(player, (int) id, 0, lv, refitLv, AwardFrom.DO_SOME);
        } else if ("hero".equalsIgnoreCase(str)) {
            playerDataManager.addAward(player, AwardType.HERO, (int) id, count, AwardFrom.DO_SOME);
        } else if ("tank".equalsIgnoreCase(str)) {
            playerDataManager.addAward(player, AwardType.TANK, (int) id, count, AwardFrom.DO_SOME);
        } else if ("power".equalsIgnoreCase(str)) {
            playerDataManager.addAward(player, AwardType.POWER, (int) id, count, AwardFrom.DO_SOME);
        } else if ("score".equalsIgnoreCase(str)) {
            playerDataManager.addAward(player, AwardType.SCORE, (int) id, count, AwardFrom.DO_SOME);
        } else if ("donate".equalsIgnoreCase(str)) {
            playerDataManager.addAward(player, AwardType.CONTRIBUTION, (int) id, count, AwardFrom.DO_SOME);
        } else if ("build".equalsIgnoreCase(str)) {
            playerDataManager.addAward(player, AwardType.PARTY_BUILD, (int) id, count, AwardFrom.DO_SOME);
        } else if ("material".equalsIgnoreCase(str)) {
            playerDataManager.addAward(player, AwardType.PART_MATERIAL, (int) id, count, AwardFrom.DO_SOME);
        } else if ("military_material".equalsIgnoreCase(str)) {
            playerDataManager.addAward(player, AwardType.MILITARY_MATERIAL, (int) id, count, AwardFrom.DO_SOME);
        } else if ("energy_stone".equalsIgnoreCase(str)) {
            playerDataManager.addAward(player, AwardType.ENERGY_STONE, (int) id, count, AwardFrom.DO_SOME);
        } else if ("medalChip".equalsIgnoreCase(str)) {
            playerDataManager.addAward(player, AwardType.MEDAL_CHIP, (int) id, count, AwardFrom.DO_SOME);
        } else if ("medal".equalsIgnoreCase(str)) {
            playerDataManager.addMedal(player, (int) id, 0, lv, refitLv, AwardFrom.DO_SOME);
        } else if ("ccJifen".equalsIgnoreCase(str)) {
            crossService.gmAddCCJiFen(id, (int) (count), lv);
        } else if ("pros".equalsIgnoreCase(str)) {
            if (count > 0) {
                playerDataManager.addAward(player, AwardType.PROS, (int) id, count, AwardFrom.DO_SOME);
            } else {
                playerDataManager.subPros(player, -(int) count);
            }
        } else if ("prosMax".equalsIgnoreCase(str)) {
            if (count > 0) {
                playerDataManager.addProsMax(player, (int) count);
            } else {
                playerDataManager.subProsMax(player, -(int) count);
            }
        } else if ("mplt".equalsIgnoreCase(str)) {
            playerDataManager.addAward(player, AwardType.MILITARY_EXPLOIT, 1, count, AwardFrom.DO_SOME);
        } else if ("pay".equalsIgnoreCase(str)) {
            PayBackRq.Builder req = PayBackRq.newBuilder();
            req.setAmount((int) count);
            req.setOrderId("111");
            req.setPlatId("ppp");
            req.setSerialId("sss");
            req.setRoleId(player.roleId);
            req.setPlatNo(111);
            req.setServerId(1);
            payService.payLogic(req.build(), player);
        } else if ("lab".equalsIgnoreCase(str)) {
            gightLabService.gmAddItem(player, (int) id, (int) count);
        } else if ("labtime".equalsIgnoreCase(str)) {
            gightLabService.gmAddProTime(player, (int) count);
        } else if ("luckycount".equalsIgnoreCase(str)) {
            activityNewService.gmAddLuckyCount(player, (int) count);
        } else if ("honourScore".equalsIgnoreCase(str)) {
            honourDataManager.addHonourScore(player, (int) count);
        } else if ("worldexp".equalsIgnoreCase(str)) {
            worldService.gmAddWorldStaffing(player, (int) count, 0);
        } else if ("worldexprole".equalsIgnoreCase(str)) {
            worldService.gmAddWorldStaffing(player, 0, (int) count);
        } else if ("tactics".equalsIgnoreCase(str)) {
            tacticsService.addTactics(player, (int) id, (int) count, AwardFrom.DO_SOME);
        } else if ("tacticsSlice".equalsIgnoreCase(str)) {
            tacticsService.addTacticsSlice(player, (int) id, (int) count, AwardFrom.DO_SOME);
        } else if ("tacticsItem".equalsIgnoreCase(str)) {
            tacticsService.addTacticsItem(player, (int) id, (int) count, AwardFrom.DO_SOME);
        } else if ("kingRank".equalsIgnoreCase(str)) {
            activityKingService.gmRank();
        } else if ("tacticsAll".equalsIgnoreCase(str)) {

            List<StaticTactics> tacticsConfigAll = staticTacticsDataMgr.getTacticsConfigAll();
            for (StaticTactics config : tacticsConfigAll) {
                if (config.getQuality() <= 3) {
                    tacticsService.addTacticsSlice(player, config.getTacticsId(), 10, AwardFrom.DO_SOME);
                }

                if (config.getTacticsId() != 901) {
                    tacticsService.addTactics(player, config.getTacticsId(), 0, AwardFrom.DO_SOME);
                }

            }

        }
    }

    /**
     * 设置玩家道具或属性
     *
     * @param handler
     * @param player
     * @param str
     * @param id
     * @param count
     * @param param   void
     */
    private void gmSet(ClientHandler handler, Player player, String str, int id, int count, String... param) {
        if ("combat".equalsIgnoreCase(str)) {
            player.combatId = count;
            for (Entry<Integer, StaticCombat> entry : staticCombatDataMgr.getCombatMap().entrySet()) {
                Integer combatId = entry.getKey();
                if (combatId < count && !player.combats.containsKey(combatId)) {
                    player.combats.put(combatId, new Combat(combatId, 3));
                }
            }
            List<Integer> sortList = new ArrayList<>(player.combats.size());
            sortList.addAll(player.combats.keySet());
            Collections.sort(sortList);
            player.combatId = sortList.get(sortList.size() - 1);
        } else if ("equip".equalsIgnoreCase(str)) {
            player.equipEplrId = count;
        } else if ("part".equalsIgnoreCase(str)) {
            player.partEplrId = count;
        } else if ("extr".equalsIgnoreCase(str)) {
            player.extrEplrId = count;
        } else if ("military".equalsIgnoreCase(str)) {
            player.militaryEplrId = count;
        } else if ("time".equalsIgnoreCase(str)) {
            player.timePrlrId = count;
        } else if ("vip".equalsIgnoreCase(str)) {
            player.lord.setVip(count);
            if (count > 0) {
                chatService.sendWorldChat(chatService.createSysChat(SysChatId.BECOME_VIP, player.lord.getNick(), "" + count));
            }
        } else if ("lv".equalsIgnoreCase(str)) {
            player.lord.setLevel(count);
            secretWeaponService.checkLevelUp(player);
        } else if ("topup".equalsIgnoreCase(str)) {
            player.lord.setTopup(count);
        } else if ("staffing".equalsIgnoreCase(str)) {
            player.lord.setStaffingLv(count);
        } else if ("staffingExp".equalsIgnoreCase(str)) {
            player.lord.setStaffingExp(count);
        } else if ("ranks".equalsIgnoreCase(str)) {
            player.lord.setRanks(count);
        } else if ("mill".equalsIgnoreCase(str)) {
            buildingService.gmSetMillLv(player, id, count);
        } else if ("sciences".equalsIgnoreCase(str)) {
            Science science = player.sciences.get(id);
            int currLv = 0;
            if (null != science) {
                currLv = science.getScienceLv();
            }
            count = count > Constant.PLAYER_OPEN_LV ? Constant.PLAYER_OPEN_LV : count;
            if (count > currLv) {
                for (int i = 0; i < count - currLv; i++) {
                    playerDataManager.addScience(player, id);
                }
            }
        } else if ("command".equalsIgnoreCase(str)) {
            player.lord.setCommand(count);
        } else if ("worldLv".equalsIgnoreCase(str)) {
            staffingDataManager.setWorldLv(count);
        } else if ("partyScience".equalsIgnoreCase(str)) {
            if (param.length == 1) {
                partyService.gmSetPartyScienceLv(param[0], id, count);
            }
        } else if ("partyLiveExp".equalsIgnoreCase(str)) {
            partyService.gmSetPartyLiveExp(player, count);
        } else if ("crossReg".equals(str)) {
            crossService.gmCrossReg(id, count, Integer.parseInt(param[0]));
        } else if ("crossForm".equals(str)) {
            crossService.gmSetCrossFrom(count);
        } else if ("crossLastRank".equals(str)) {
            crossService.gmSynCrossLashRank(count);
        } else if ("cpForm".equals(str)) {
            crossPartyService.gmSetCpForm(count);
        } else if ("cpReg".equals(str)) {
            crossPartyService.gmCPReg();
        } else if ("medal".equalsIgnoreCase(str)) {
            player.medalEplrId = count;
        } else if ("partyReg".equals(str)) {
            warService.partyReg(player);
        } else if ("prosMax".equals(str)) {
            player.lord.setProsMax(count);
            playerDataManager.outOfRuins(player);
        } else if ("skill".equals(str)) {
            Integer lv = player.skills.get(id);
            if (lv != null) {
                player.skills.put(id, count);
            }
        } else if ("niub".equalsIgnoreCase(str)) {
            gmNiub(player);
        } else if ("awakeskill1".equalsIgnoreCase(str)) {
            awakeSkill1(player, id, count, Integer.valueOf(param[0]));
        } else if ("awakeskill2".equalsIgnoreCase(str)) {
            awakeSkill2(player, id, count);
        } else if ("mrk".equalsIgnoreCase(str)) {
            player.lord.setMilitaryRank(count);
        } else if ("gst".equalsIgnoreCase(str)) {
            setGst(player);
        } else if ("regparty".equalsIgnoreCase(str)) {
            gmCrossPartyReg(handler);
        } else if ("gold".equalsIgnoreCase(str)) {
            setGold(player, count);
        } else if ("jgkjlevel".equalsIgnoreCase(str)) {
            militaryScienceService.gmUpMilitaryScience(player, id, count);
        } else if ("jgkj2level".equalsIgnoreCase(str)) {
            militaryScienceService.gm2UpMilitaryScience(player, count);
        } else if ("fuel".equalsIgnoreCase(str)) {
            redPlanService.gmSetFuel(player, count);
        } else if ("fuelclear".equalsIgnoreCase(str)) {
            redPlanService.gmClear(player, count);
        } else if ("lablevel".equalsIgnoreCase(str)) {
            gightLabService.gmSetFightLabGraduateLevel(player);
        } else if ("copyPlayer".equalsIgnoreCase(str)) {
            copyPlayer(player.lord.getNick(), str);
        } else if ("staffingExpAll".equalsIgnoreCase(str)) {
            Map<Long, Player> players = playerDataManager.getPlayers();
            for (Player p : players.values()) {
                p.lord.setStaffingExp(count);
            }
        } else if ("waractivity".equalsIgnoreCase(str)) {
            activityNewService.gmWarActivity(player, id, count);
        } else if ("rewp".equalsIgnoreCase(str)) {
            Member member = partyDataManager.getMemberById(player.lord.getLordId());
            PartyData party = partyDataManager.getParty(member.getPartyId());
            party.setAltarBossExp(count);
            altarBossService.sendAltarBossParticipateAward(member.getPartyId(), id, false);
        } else if ("extreprCount".equalsIgnoreCase(str)) {
            combatService.resetExtrEpr(handler);
        } else if ("kingRank".equalsIgnoreCase(str)) {
            activityKingService.gmSetRank(player, id, count);
        } else if ("scienceslevel".equalsIgnoreCase(str)) {
            Science science = player.sciences.get(id);
            science.setScienceLv(count);
        } else if ("ecore".equalsIgnoreCase(str)) {
            energyCoreService.gmSetCore(handler.getRoleId(), id, count, Integer.valueOf(param[0]));
        }
    }

    /**
     * 设置玩家金币
     *
     * @param player
     * @param count  void
     */
    private void setGold(Player player, int count) {
        long g = player.lord.getGold();
        long sub = g - count;
        playerDataManager.subGold(player, (int) sub, AwardFrom.DO_SOME);
    }

    /**
     * GM发送邮件
     *
     * @param mail
     * @param to   void
     */
    public void gmMail(Mail mail, String to) {
        String content = null;
        if (mail.hasContont()) {
            content = mail.getContont();
        }

        int moldId = MailType.MOLD_SYSTEM_PUB_1;
        if (mail.hasMoldId()) {
            moldId = mail.getMoldId();
        }

        if (moldId == MailType.MOLD_SYSTEM_3 || moldId == MailType.MOLD_SYSTEM_2 || moldId == MailType.MOLD_SYSTEM_1
                || moldId == MailType.MOLD_SYSTEM_PUB_2) {
            if ("all".equalsIgnoreCase(to)) {
                Iterator<Player> it = playerDataManager.getPlayers().values().iterator();
                while (it.hasNext()) {
                    Player player = (Player) it.next();
                    if (player != null && player.isActive()) {
                        playerDataManager.sendAttachMail(AwardFrom.GM_SEND, player, mail.getAwardList(), moldId,
                                TimeHelper.getCurrentSecond(), content);
                    }
                }
            } else if ("online".equalsIgnoreCase(to)) {
                Iterator<Player> it = playerDataManager.getAllOnlinePlayer().values().iterator();
                while (it.hasNext()) {
                    Player player = (Player) it.next();
                    if (player != null && player.isActive()) {
                        playerDataManager.sendAttachMail(AwardFrom.GM_SEND, player, mail.getAwardList(), moldId,
                                TimeHelper.getCurrentSecond(), content);
                    }
                }
            } else {
                String[] names = to.split("\\|");
                if (names == null) {
                    LogUtil.info("gmMail to null");
                    return;
                }

                for (String name : names) {
                    LogUtil.info("gmMail to " + name);
                    Player player = playerDataManager.getPlayer(name);
                    if (player != null && player.isActive()) {
                        playerDataManager.sendAttachMail(AwardFrom.GM_SEND, player, mail.getAwardList(), moldId,
                                TimeHelper.getCurrentSecond(), content);
                    }
                }
            }
        } else if (moldId == MailType.MOLD_SYSTEM_PUB_1) {
            if ("all".equalsIgnoreCase(to)) {
                Iterator<Player> it = playerDataManager.getPlayers().values().iterator();
                while (it.hasNext()) {
                    Player player = (Player) it.next();
                    if (player != null && player.isActive()) {
                        playerDataManager.sendNormalMail(player, moldId, TimeHelper.getCurrentSecond(), content);
                    }
                }
            } else if ("online".equalsIgnoreCase(to)) {
                Iterator<Player> it = playerDataManager.getAllOnlinePlayer().values().iterator();
                while (it.hasNext()) {
                    Player player = (Player) it.next();
                    if (player != null && player.isActive()) {
                        playerDataManager.sendNormalMail(player, moldId, TimeHelper.getCurrentSecond(), content);
                    }
                }
            } else {
                String[] names = to.split("\\|");
                if (names == null) {
                    LogUtil.info("gmMail to null");
                    return;
                }

                for (String name : names) {
                    LogUtil.info("gmMail to " + name);
                    Player player = playerDataManager.getPlayer(name);
                    if (player != null && player.isActive()) {
                        playerDataManager.sendNormalMail(player, moldId, TimeHelper.getCurrentSecond(), content);
                    }
                }
            }
        }
    }

    /**
     * 删除玩家邮件
     *
     * @param playerId
     * @param keyId    void
     */
    public void delMail(long playerId, int keyId) {
        Player player = playerDataManager.getPlayer(playerId);
        if (player != null && player.isActive()) {
            if (player.getMails().containsKey(keyId)) {
                player.delMail(keyId);
            }
        }
    }

    /**
     * 给玩家邮件
     *
     * @param to
     * @param moldId
     * @param content
     */
    public void playerMail(String to, int moldId, List<CommonPb.Award> awards, String... content) {
        String[] names = to.split("\\|");
        if (names == null) {
            LogUtil.info("gmMail to null");
            return;
        }
        if (awards == null || awards.size() == 0) {
            for (String name : names) {
                LogUtil.info("gmMail to " + name);
                Player player = playerDataManager.getPlayer(name);
                if (player != null && player.isActive()) {
                    playerDataManager.sendNormalMail(player, moldId, TimeHelper.getCurrentSecond(), content);
                }
            }
        } else {
            for (String name : names) {
                LogUtil.info("gmMail to " + name);
                Player player = playerDataManager.getPlayer(name);
                if (player != null && player.isActive()) {
                    playerDataManager.sendAttachMail(AwardFrom.GM_SEND, player, awards, moldId, TimeHelper.getCurrentSecond(), content);
                }
            }
        }
    }

    /**
     * 给若干玩家发系统邮件
     *
     * @param to      给谁发 用|隔开的lordid
     * @param moldId
     * @param awards
     * @param content void
     */
    public void playerMailByLordId(String to, int moldId, List<CommonPb.Award> awards, String... content) {
        String[] lordIds = to.split("\\|");
        if (lordIds == null) {
            LogUtil.info("gmMail to null");
            return;
        }
        if (awards == null || awards.size() == 0) {
            for (String lordId : lordIds) {
                Player player = playerDataManager.getPlayer(Long.valueOf(lordId.trim()));
                if (player != null && player.isActive()) {
                    playerDataManager.sendNormalMail(player, moldId, TimeHelper.getCurrentSecond(), content);
                }
            }
        } else {
            for (String lordId : lordIds) {
                Player player = playerDataManager.getPlayer(Long.valueOf(lordId.trim()));
                if (player != null && player.isActive()) {
                    playerDataManager.sendAttachMail(AwardFrom.GM_SEND, player, awards, moldId, TimeHelper.getCurrentSecond(), content);
                }
            }
        }
    }

    /**
     * 全服邮件
     *
     * @param moldId
     * @param awards
     * @param content
     */
    public void toServerOrPlat(int moldId, int online, int channelId, List<CommonPb.Award> awards, String... content) {
        Iterator<Player> it = playerDataManager.getPlayers().values().iterator();
        if (awards == null || awards.size() == 0) {
            while (it.hasNext()) {
                Player player = (Player) it.next();
                if (player != null && player.account != null && player.isActive()) {
                    if (channelId == 0 || player.account.getPlatNo() == channelId) {
                        if (online == 0) {// 全体成员
                            playerDataManager.sendNormalMail(player, moldId, TimeHelper.getCurrentSecond(), content);
                        } else if (online == 1 && player.ctx != null) {// 在线玩家
                            playerDataManager.sendNormalMail(player, moldId, TimeHelper.getCurrentSecond(), content);
                        }
                    }
                }
            }
        } else {
            while (it.hasNext()) {
                Player player = (Player) it.next();
                if (player != null && player.account != null && player.isActive()) {
                    if (channelId == 0 || player.account.getPlatNo() == channelId) {
                        if (online == 0) {// 全体成员
                            playerDataManager.sendAttachMail(AwardFrom.GM_SEND, player, awards, moldId, TimeHelper.getCurrentSecond(),
                                    content);
                        } else if (online == 1 && player.ctx != null) {// 在线玩家
                            playerDataManager.sendAttachMail(AwardFrom.GM_SEND, player, awards, moldId, TimeHelper.getCurrentSecond(),
                                    content);
                        }
                    }
                }
            }
        }
    }

    /**
     * 给若干渠道发邮件
     *
     * @param mail
     * @param to   void
     */
    public void gmPlatMail(Mail mail, String to) {
        String content = null;
        if (mail.hasContont()) {
            content = mail.getContont();
        }

        int moldId = MailType.MOLD_SYSTEM_PUB_1;
        if (mail.hasMoldId()) {
            moldId = mail.getMoldId();
        }

        if (moldId == MailType.MOLD_SYSTEM_3 || moldId == MailType.MOLD_SYSTEM_2 || moldId == MailType.MOLD_SYSTEM_1
                || moldId == MailType.MOLD_SYSTEM_PUB_2) {
            if ("all".equalsIgnoreCase(to)) {
                Iterator<Player> it = playerDataManager.getPlayers().values().iterator();
                while (it.hasNext()) {
                    Player player = (Player) it.next();
                    if (player != null && player.isActive()) {
                        playerDataManager.sendAttachMail(AwardFrom.GM_SEND, player, mail.getAwardList(), moldId,
                                TimeHelper.getCurrentSecond(), content);
                    }
                }
            } else if ("online".equalsIgnoreCase(to)) {
                Iterator<Player> it = playerDataManager.getAllOnlinePlayer().values().iterator();
                while (it.hasNext()) {
                    Player player = (Player) it.next();
                    if (player != null && player.isActive()) {
                        playerDataManager.sendAttachMail(AwardFrom.GM_SEND, player, mail.getAwardList(), moldId,
                                TimeHelper.getCurrentSecond(), content);
                    }
                }
            } else {
                String[] plats = to.split("\\|");
                if (plats == null) {
                    LogUtil.info("gmPlatMail to null");
                    return;
                }

                Set<Integer> set = new HashSet<Integer>();
                for (String plat : plats) {
                    set.add(Integer.valueOf(plat));
                }

                // LogUtil.info("gmPlatMail to " + plat);

                Iterator<Player> it = playerDataManager.getPlayers().values().iterator();
                while (it.hasNext()) {
                    Player player = (Player) it.next();
                    if (player != null && player.isActive()) {
                        if (player.account != null && set.contains(player.account.getPlatNo())) {
                            playerDataManager.sendAttachMail(AwardFrom.GM_SEND, player, mail.getAwardList(), moldId,
                                    TimeHelper.getCurrentSecond(), content);
                        }
                    }
                }
            }
        } else if (moldId == MailType.MOLD_SYSTEM_PUB_1) {
            if ("all".equalsIgnoreCase(to)) {
                Iterator<Player> it = playerDataManager.getPlayers().values().iterator();
                while (it.hasNext()) {
                    Player player = (Player) it.next();
                    if (player != null && player.isActive()) {
                        playerDataManager.sendNormalMail(player, moldId, TimeHelper.getCurrentSecond(), content);
                    }
                }
            } else if ("online".equalsIgnoreCase(to)) {
                Iterator<Player> it = playerDataManager.getAllOnlinePlayer().values().iterator();
                while (it.hasNext()) {
                    Player player = (Player) it.next();
                    if (player != null && player.isActive()) {
                        playerDataManager.sendNormalMail(player, moldId, TimeHelper.getCurrentSecond(), content);
                    }
                }
            } else {
                String[] plats = to.split("\\|");
                if (plats == null) {
                    LogUtil.info("gmPlatMail to null");
                    return;
                }

                Set<Integer> set = new HashSet<Integer>();
                for (String plat : plats) {
                    set.add(Integer.valueOf(plat));
                }

                // LogUtil.info("gmPlatMail to " + plat);

                Iterator<Player> it = playerDataManager.getPlayers().values().iterator();
                while (it.hasNext()) {
                    Player player = (Player) it.next();
                    if (player != null && player.isActive()) {
                        if (player.account != null && set.contains(player.account.getPlatNo())) {
                            playerDataManager.sendNormalMail(player, moldId, TimeHelper.getCurrentSecond(), content);
                        }
                    }
                }
            }
        }
    }

    /**
     * 设置玩家建筑等级
     *
     * @param player
     * @param buildingId
     * @param lv
     * @param handler    void
     */
    private void gmBuild(Player player, int buildingId, int lv, ClientHandler handler) {
        buildingService.setBuildingLv(buildingId, lv, player, handler);
    }

    private void gmSystem(String str) {
        if ("resource".equalsIgnoreCase(str)) {
            buildingService.recalcResourceOut();
        } else if ("loadSystem".equalsIgnoreCase(str.trim())) {// 重加载s_system表数据
            gmToolService.reloadParam(1);
        } else if ("reloadAll".equalsIgnoreCase(str.trim())) {// 重加载所有配置数据
            gmToolService.reloadParam(2);
        }
    }

    /**
     * 重新计算所有玩家资源产量 void
     */
    public void recalcResource() {
        buildingService.recalcResourceOut();
    }

    /**
     * 强制踢玩家下线
     *
     * @param name void
     */
    public void gmKick(String name) {
        Player player = playerDataManager.getPlayer(name);
        if (player != null && player.isLogin && player.account.getIsGm() == 0) {
            if (player.ctx != null) {
                player.ctx.close();
            }
        }
    }

    /**
     * 禁言某玩家
     *
     * @param name
     * @param s    void
     */
    public void gmSilence(String name, int s) {
        Player player = playerDataManager.getPlayer(name);
        if (player != null && player.account.getIsGm() == 0) {
            player.lord.setSilence(s);
        }
    }

    /**
     * 禁账号
     *
     * @param name
     * @param s    void
     */
    public void gmForbidden(String name, int s) {
        Player player = playerDataManager.getPlayer(name);
        if (player != null && player.account.getIsGm() == 0) {
            player.account.setForbid(s);
        }
    }

    /**
     * 设置VIP
     *
     * @param name
     * @param s    void
     */
    public void gmVip(String name, int s) {
        Player player = playerDataManager.getPlayer(name);
        if (player != null && (s >= 0 && s <= 12)) {
            player.lord.setVip(s);
            if (s > 0) {
                chatService.sendWorldChat(chatService.createSysChat(SysChatId.BECOME_VIP, player.lord.getNick(), "" + s));
            }
        }
    }

    /**
     * GM设置已充值金币数量
     *
     * @param name
     * @param s    void
     */
    private void gmTopup(String name, int s) {
        Player player = playerDataManager.getPlayer(name);
        if (player != null && (s >= 0)) {
            player.lord.setTopup(s);
            player.lord.setVip(staticVipDataMgr.calcVip(player.lord.getTopup()));
        }
    }

    /**
     * 清空玩家数据
     *
     * @param player
     * @param str    void
     */
    private void gmClear(Player player, String str) {
        LogUtil.gm("清空玩家数据, lordId:" + player.lord.getLordId() + ", nick:" + player.lord.getNick() + ", cmd:" + str);
        if ("prop".equalsIgnoreCase(str)) {
            player.props.clear();
        } else if ("equip".equalsIgnoreCase(str)) {
            player.equips.put(0, new HashMap<Integer, Equip>());
            player.equips.put(1, new HashMap<Integer, Equip>());
            player.equips.put(2, new HashMap<Integer, Equip>());
            player.equips.put(3, new HashMap<Integer, Equip>());
            player.equips.put(4, new HashMap<Integer, Equip>());
            player.equips.put(5, new HashMap<Integer, Equip>());
            player.equips.put(6, new HashMap<Integer, Equip>());
        } else if ("part".equalsIgnoreCase(str)) {
            player.parts.put(0, new HashMap<Integer, Part>());
            player.parts.put(1, new HashMap<Integer, Part>());
            player.parts.put(2, new HashMap<Integer, Part>());
            player.parts.put(3, new HashMap<Integer, Part>());
            player.parts.put(4, new HashMap<Integer, Part>());
        } else if ("hero".equalsIgnoreCase(str)) {
            player.heros.clear();
            player.lockHeros.clear();
            player.awakenHeros.clear();
            player.forms.clear();
            player.herosCdTime.clear();
            player.herosExpiredTime.clear();
            player.heroClearCdCount.clear();
            player.newHeroAddClearCdTime = System.currentTimeMillis();
            player.newHeroAddGold = 0;
            player.newHeroAddGoldTime = System.currentTimeMillis();
        } else if ("chip".equalsIgnoreCase(str)) {
            player.chips.clear();
        } else if ("skill".equalsIgnoreCase(str)) {
            player.skills.clear();
        } else if ("science".equalsIgnoreCase(str)) {
            player.sciences.clear();
        } else if ("tank".equalsIgnoreCase(str)) {
            player.tanks.clear();
        } else if ("mail".equalsIgnoreCase(str)) {
            player.clearMails();
        } else if ("explore".equalsIgnoreCase(str)) {
            player.lord.setExtrEplr(0);
        } else if ("military".equalsIgnoreCase(str)) {
            player.militarySciences.clear();
            player.militaryScienceGrids.clear();
        } else if ("army".equals(str)) {
            player.armys.clear();
        } else if ("fortressArmyBack".equals(str)) {
            player.gmRmoveFortressArmy();
        } else if ("gmRmoveWarArmy".equals(str)) {
            player.gmRmoveWarArmy();
        } else if ("energyStone".equals(str)) {
            player.energyStone.clear();
        } else if ("partMaterial".equals(str)) {
            player.lord.setFitting(0);
            player.lord.setMetal(0);
            player.lord.setPlan(0);
            player.lord.setMineral(0);
            player.lord.setTool(0);
            player.lord.setDraw(0);
            player.lord.setTankDrive(0);
            player.lord.setChariotDrive(0);
            player.lord.setArtilleryDrive(0);
            player.lord.setRocketDrive(0);
            player.partMatrial.clear();
        } else if ("gmRmoveDrillArmy".equals(str)) {
            player.forms.remove(FormType.DRILL_1);
            player.forms.remove(FormType.DRILL_2);
            player.forms.remove(FormType.DRILL_3);
        } else if ("removeCrossForm".equals(str)) {
            player.forms.remove(FormType.Cross1);
            player.forms.remove(FormType.Cross2);
            player.forms.remove(FormType.Cross3);
        } else if ("removeAllCrossForm".equals(str)) {
            crossService.gmClearAllCrossForm();
        } else if ("myBet".equals(str)) {
            // player.myBets.clear();
        } else if ("medal".equals(str)) {
            player.medals.put(0, new HashMap<Integer, Medal>());
            player.medals.put(1, new HashMap<Integer, Medal>());
        } else if ("medalChip".equals(str)) {
            player.medalChips.clear();
        } else if ("medalMaterial".equals(str)) {
            player.lord.setDetergent(0);
            player.lord.setGrindstone(0);
            player.lord.setPolishingMtr(0);
            player.lord.setMaintainOil(0);
            player.lord.setGrindTool(0);
            player.lord.setPrecisionInstrument(0);
            player.lord.setMysteryStone(0);
            player.lord.setInertGas(0);
            player.lord.setCorundumMatrial(0);
        } else if ("medalBouns".equals(str)) {
            player.medalBounss.put(0, new HashMap<Integer, MedalBouns>());
            player.medalBounss.put(1, new HashMap<Integer, MedalBouns>());
        } else if ("fame".equals(str)) {
            player.lord.setFameLv(0);
            player.lord.setFame(0);
        } else if ("res".equals(str)) {
            player.resource.setIron(0);
            player.resource.setOil(0);
            player.resource.setCopper(0);
            player.resource.setSilicon(0);
            player.resource.setStone(0);
        } else if ("drawing".equalsIgnoreCase(str)) {// 清除全部军备图纸
            Map<Integer, Prop> map = player.leqInfo.getLeqMat();
            for (Integer key : map.keySet()) {
                if (key > 2000) {
                    map.get(key).setCount(0);
                }
            }
        } else if ("material".equalsIgnoreCase(str)) {// 清除全部军备材料
            Map<Integer, Prop> map = player.leqInfo.getLeqMat();
            for (Integer key : map.keySet()) {
                if (key < 2000) {
                    map.get(key).setCount(0);
                }
            }
        } else if ("fes".equalsIgnoreCase(str)) {
            activityNewService.gmFestivalClear(player);
        } else if ("combat".equalsIgnoreCase(str)) {
            player.combats.clear();
            player.combatId = 0;
        } else if ("honourlive".equalsIgnoreCase(str)) {
            honourDataManager.endClear();
        } else if ("loginwelfare".equalsIgnoreCase(str)) {
            player.activitys.remove(ActivityConst.ACT_LOGIN_WELFARE);
        } else if ("contributeCount".equalsIgnoreCase(str)) {
            player.getContributeCount().clear();
        } else if ("extreprCount".equalsIgnoreCase(str)) {
            player.lord.setExtrReset(0);
        } else if ("kingRank".equalsIgnoreCase(str)) {
            activityKingService.gmClearRank();
        } else if ("tactics".equalsIgnoreCase(str)) {
            player.tacticsInfo.getTacticsMap().clear();
            player.tacticsInfo.getTacticsSliceMap().clear();
            player.tacticsInfo.getTacticsItemMap().clear();
            Map<Integer, Form> forms = player.forms;
            for (Integer f : new ArrayList<>(forms.keySet())) {
                Form form = forms.get(f);
                form.getTacticsList().clear();
                form.getTactics().clear();
            }
        } else if ("tacticsform".equalsIgnoreCase(str)) {
            player.tacticsInfo.getTacticsForm().clear();
        } else if ("tanxian".equalsIgnoreCase(str)) {
            player.lord.setEquipEplr(0);
            player.lord.setPartEplr(0);
            player.lord.setMilitaryEplr(0);
            player.lord.setPartBuy(0);
            player.lord.setMilitaryBuy(0);
            player.lord.setEnergyStoneEplr(0);
            player.lord.setEnergyStoneBuy(0);
            player.lord.setMedalEplr(0);
            player.lord.setMedalBuy(0);
            player.lord.setTacticsBuy(0);
            player.lord.setTacticsReset(0);

        } else if ("getGiveProp".equalsIgnoreCase(str)) {
            player.getGetGivePropList().clear();
        }
    }

    /**
     * 删除玩家的指定道具
     *
     * @param player
     * @param str
     * @param id     void
     */
    private void gmRemove(Player player, String str, int id) {
        if ("part".equalsIgnoreCase(str)) {
            for (Map<Integer, Part> store : player.parts.values()) {
                Iterator<Part> parts = store.values().iterator();
                while (parts.hasNext()) {
                    Part part = parts.next();
                    if (part.getPartId() == id) {
                        parts.remove();
                    }
                }
            }
        } else if ("medal".equalsIgnoreCase(str)) {
            for (Map<Integer, Medal> store : player.medals.values()) {
                Iterator<Medal> medals = store.values().iterator();
                while (medals.hasNext()) {
                    Medal medal = medals.next();
                    if (medal.getMedalId() == id) {
                        medals.remove();
                    }
                }
            }
        } else if ("medalBouns".equalsIgnoreCase(str)) {
            for (Map<Integer, MedalBouns> store : player.medalBounss.values()) {
                Iterator<MedalBouns> it = store.values().iterator();
                while (it.hasNext()) {
                    MedalBouns medalBouns = it.next();
                    if (medalBouns.getMedalId() == id) {
                        it.remove();
                    }
                }
            }
        } else if ("prop".equalsIgnoreCase(str)) {
            player.props.remove(id);
        } else if ("lordequip".equalsIgnoreCase(str)) {// 清除指定ID军备
            Map<Integer, LordEquip> putonLordEquips = player.leqInfo.getPutonLordEquips();
            Map<Integer, LordEquip> storeLordEquips = player.leqInfo.getStoreLordEquips();
            for (Integer key : putonLordEquips.keySet()) {
                if (putonLordEquips.get(key).getEquipId() == id) {
                    putonLordEquips.remove(key);
                    break;
                }
            }
            List<Integer> list = new ArrayList<Integer>();
            for (Integer key : storeLordEquips.keySet()) {
                if (storeLordEquips.get(key).getEquipId() == id) {
                    list.add(key);
                }
            }
            for (int i = 0; i < list.size(); i++) {
                storeLordEquips.remove(list.get(i));
            }
        } else if ("allequip".equalsIgnoreCase(str)) {
            player.leqInfo.getStoreLordEquips().clear();
            player.leqInfo.getPutonLordEquips().clear();
        } else if ("hero".equalsIgnoreCase(str)) {
            Map<Integer, Hero> heros = player.heros;
            Map<Integer, AwakenHero> awakenHeros = player.awakenHeros;
            Iterator<Entry<Integer, Hero>> it = heros.entrySet().iterator();
            Iterator<Entry<Integer, AwakenHero>> it2 = awakenHeros.entrySet().iterator();
            Set<Integer> set = new HashSet<>();
            while (it.hasNext()) {
                Entry<Integer, Hero> next = it.next();
                if (next.getValue().getHeroId() == id) {
                    set.add(next.getKey());
                }
            }
            while (it2.hasNext()) {
                Entry<Integer, AwakenHero> next = it2.next();
                if (next.getValue().getHeroId() == id) {
                    set.add(next.getKey());
                }
            }
            for (Integer keyId : set) {
                heros.remove(keyId);
                awakenHeros.remove(keyId);
            }
        }

    }

    /**
     * 删除玩家的指定道具
     *
     * @param name
     * @param str
     * @param id   void
     */
    private void gmRemovePlayer(String name, String str, int id) {
        Player player = playerDataManager.getPlayer(name);
        if (player != null) {
            gmRemove(player, str, id);
        }
    }

    /**
     * 删除所有玩家的指定道具
     *
     * @param str
     * @param id  void
     */
    private void gmRemoveAllPlayer(String str, int id) {
        Iterator<Player> it = playerDataManager.getPlayers().values().iterator();
        while (it.hasNext()) {
            Player player = it.next();
            try {
                gmRemove(player, str, id);
            } catch (Exception e) {
                LogUtil.error(e + str + "|" + player.lord.getNick() + "|" + player.lord.getLordId());
            }
        }
    }

    /**
     * 清空玩家道具
     *
     * @param name
     * @param str  void
     */
    private void gmClearPlayer(String name, String str) {
        Player player = playerDataManager.getPlayer(name);
        if (player != null) {
            gmClear(player, str);
        }
    }

    /**
     * 情况所有玩家指定道具
     *
     * @param str void
     */
    private void gmClearAllPlayer(String str) {
        Iterator<Player> it = playerDataManager.getPlayers().values().iterator();
        while (it.hasNext()) {
            Player player = it.next();
            try {
                gmClear(player, str);
            } catch (Exception e) {
                LogUtil.error(e + str + "|" + player.lord.getNick() + "|" + player.lord.getLordId());
            }
        }
    }

    /**
     * 设置军团属性
     *
     * @param type
     * @param partyName
     * @param id
     * @param lv        void
     */
    private void gmSetParty(String type, String partyName, int id, int lv) {
        if ("buildLv".equals(type)) {
            partyService.gmPartyBuildLv(partyName, id, lv);
        } else if ("scienceLv".equalsIgnoreCase(type)) {
            partyService.gmSetPartyScienceLv(partyName, id, lv);
        } else if ("addProp".equalsIgnoreCase(type)) {
            partyService.gmAddPartyProp(partyName, id, lv);
        } else if ("addAllDonate".equalsIgnoreCase(type)) {
            partyService.gmAddPartyAllMemberDonate(partyName, id);
        } else if ("addBuild".equalsIgnoreCase(type)) {
            partyService.gmAddPartyBuild(partyName, id);
        }
    }

    /**
     * 设置玩家道具或属性
     *
     * @param name
     * @param str
     * @param id
     * @param count
     * @param param void
     */
    private void gmSetPlayer(String name, String str, int id, int count, String... param) {
        Player player = playerDataManager.getPlayer(name);
        if (player != null) {
            gmSet(null, player, str, id, count, param);
        }
    }

    /**
     * 复制角色
     *
     * @param name1 被复制的玩家
     * @param name2
     */
    private void copyPlayer(String name1, String name2) {

        try {
            Player srcPlayer1 = playerDataManager.getPlayer(name1);

            Player destPlayer2 = playerDataManager.getPlayer(name2);

            if (destPlayer2 == null) {
                LogUtil.error("destPlayer2 is null name2" + name2);
                return;
            }

            LogUtil.error("复制角色 1 " + srcPlayer1.lord.getNick() + " ==>>" + destPlayer2.lord.getNick());

            try {
                if (destPlayer2.ctx != null) {
                    destPlayer2.ctx.close();
                }
            } catch (Exception e) {
                LogUtil.error(e.getMessage());
            }

            DataNewDao dataNew = GameServer.ac.getBean(DataNewDao.class);

            DataNew dataNew1 = dataNew.selectData(srcPlayer1.roleId);
            dataNew1.setLordId(destPlayer2.roleId);

            LordDao lordDao = GameServer.ac.getBean(LordDao.class);
            Lord lordNew = lordDao.selectLordById(srcPlayer1.roleId);

            lordNew.setNick(destPlayer2.lord.getNick());
            lordNew.setPos(destPlayer2.lord.getPos());
            lordNew.setLordId(destPlayer2.roleId);

            BuildingDao buildingDao = GameServer.ac.getBean(BuildingDao.class);
            Building buildingNew = buildingDao.selectBuilding(srcPlayer1.roleId);
            buildingNew.setLordId(destPlayer2.roleId);

            ResourceDao resourceDao = GameServer.ac.getBean(ResourceDao.class);
            Resource resourceNew = resourceDao.selectResource(srcPlayer1.roleId);
            resourceNew.setLordId(destPlayer2.roleId);

            resourceDao.updateResource(resourceNew);
            buildingDao.updateBuilding(buildingNew);
            dataNew.updateData(dataNew1);
            lordDao.updateLord(lordNew);

            destPlayer2.resource = resourceNew;
            destPlayer2.building = buildingNew;
            destPlayer2.dserNewData(dataNew1);
            destPlayer2.lord = lordNew;

            LogUtil.error("复制角色成功 2 " + srcPlayer1.lord.getNick() + " ==>>" + destPlayer2.lord.getNick());
        } catch (Exception e) {
            LogUtil.error(e.getMessage());
        }
    }

    public void addCrossScore(int type, String nick, String score) {
        Player player = playerDataManager.getPlayer(nick.trim());
        if (player != null) {
            player.setCrossMineScore(0);
        }
        MineRpcService.gm(type, nick, score);
    }

}
