package com.game.service;

import com.game.actor.role.PlayerEventService;
import com.game.constant.*;
import com.game.dataMgr.StaticAwardsDataMgr;
import com.game.dataMgr.StaticHeroDataMgr;
import com.game.dataMgr.StaticPartyDataMgr;
import com.game.dataMgr.StaticPropDataMgr;
import com.game.domain.Member;
import com.game.domain.PartyData;
import com.game.domain.Player;
import com.game.domain.p.*;
import com.game.domain.s.*;
import com.game.fight.FightLogic;
import com.game.fight.domain.Fighter;
import com.game.fight.domain.Force;
import com.game.manager.*;
import com.game.message.handler.ClientHandler;
import com.game.message.handler.InnerHandler;
import com.game.pb.CommonPb;
import com.game.pb.CommonPb.Award;
import com.game.pb.CrossGamePb.CCCanQuitPartyRq;
import com.game.pb.CrossGamePb.CCCanQuitPartyRs;
import com.game.pb.GamePb1.*;
import com.game.pb.GamePb2.*;
import com.game.pb.GamePb3.*;
import com.game.pb.GamePb6.DonateAllPartyResRs;
import com.game.pb.GamePb6.DonateAllPartyScienceRq;
import com.game.pb.GamePb6.DonateAllPartyScienceRs;
import com.game.pb.GamePb6.GetAllPcbtAwardRs;
import com.game.persistence.SavePartyOptimizeTask;
import com.game.service.airship.AirshipService;
import com.game.util.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.Map.Entry;

/**
 * @author ChenKui
 * @version 创建时间：2015-9-9 下午1:53:39
 * @declare 军团相关
 */
@Service
public class PartyService {

    @Autowired
    private PartyDataManager partyDataManager;

    @Autowired
    private PlayerDataManager playerDataManager;

    @Autowired
    private ActivityDataManager activityDataManager;

    @Autowired
    private StaticPartyDataMgr staticPartyDataMgr;

    @Autowired
    private StaticHeroDataMgr staticHeroDataMgr;

    @Autowired
    private StaticPropDataMgr staticPropDataMgr;

    @Autowired
    private StaticAwardsDataMgr staticAwardsDataMgr;

    @Autowired
    private GlobalDataManager globalDataManager;

    @Autowired
    private SeniorMineDataManager mineDataManager;

    @Autowired
    private FightService fightService;

    @Autowired
    private WorldService worldService;

    @Autowired
    private ChatService chatService;

    @Autowired
    private AltarBossService altarBossService;

    @Autowired
    private AirshipService airshipService;

    @Autowired
    private PlayerEventService playerEventService;
    @Autowired
    private DataRepairDM repairDM;
    @Autowired
    private TacticsService tacticsService;
    @Autowired
    private SavePartyOptimizeTask savePartyOptimizeTask;

    /**
     * 资源数量
     *
     * @param resourceId
     * @param resource
     * @param lord
     * @return long
     */
    public long getResource(int resourceId, Resource resource, Lord lord) {
        if (resourceId == PartyType.RESOURCE_STONE) {
            return resource.getStone();
        } else if (resourceId == PartyType.RESOURCE_IRON) {
            return resource.getIron();
        } else if (resourceId == PartyType.RESOURCE_SILICON) {
            return resource.getSilicon();
        } else if (resourceId == PartyType.RESOURCE_COPPER) {
            return resource.getCopper();
        } else if (resourceId == PartyType.RESOURCE_OIL) {
            return resource.getOil();
        } else if (resourceId == PartyType.RESOURCE_GOLD) {
            return lord.getGold();
        }
        return -1;
    }

    /**
     * Function:军团排名信息
     *
     * @param req
     * @param handler
     */
    public void getPartyRank(GetPartyRankRq req, ClientHandler handler) {
        int page = req.getPage();
        int type = req.getType();
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        Lord lord = player.lord;
        GetPartyRankRs.Builder builder = GetPartyRankRs.newBuilder();

        Member member = partyDataManager.getMemberById(handler.getRoleId());
        if (member != null && member.getPartyId() > 0) {
            int partyId = member.getPartyId();
            PartyRank partyRank = partyDataManager.getPartyRank(partyId);
            PartyData partyData = partyDataManager.getParty(partyId);
            int count = partyDataManager.getPartyMemberCount(partyId);
            if (partyRank != null) {
                builder.setParty(PbHelper.createPartyRankPb(partyRank, partyData, count));
            }
        }

        List<PartyRank> partyRankList = partyDataManager.getPartyRank(page, type, lord.getLevel(), lord.getFight());
        for (PartyRank e : partyRankList) {
            int partyId = e.getPartyId();
            PartyData partyData = partyDataManager.getParty(partyId);
            int count = partyDataManager.getPartyMemberCount(partyId);
            builder.addPartyRank(PbHelper.createPartyRankPb(e, partyData, count));
        }
        handler.sendMsgToPlayer(GetPartyRankRs.ext, builder.build());
    }

    /**
     * Function:军团等级排名信息
     *
     * @param req
     * @param handler
     */
    public void getPartyLvRankRq(GetPartyLvRankRq req, ClientHandler handler) {
        int page = req.getPage();
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

        GetPartyLvRankRs.Builder builder = GetPartyLvRankRs.newBuilder();
        PartyData party = partyDataManager.getPartyByLordId(lord.getLordId());
        if (party != null) {
            PartyLvRank partyLvRank = activityDataManager.getPartyLvRank(party.getPartyId());
            if (partyLvRank != null) {
                builder.setParty(PbHelper.createPartyLvRankPb(partyLvRank));
            }
        }

        List<PartyLvRank> partyLvRankList = activityDataManager.getPartyLvRankList(page);
        for (PartyLvRank e : partyLvRankList) {
            int partyId = e.getPartyId();
            if (partyId == 0) {
                continue;
            }
            builder.addPartyLvRank(PbHelper.createPartyLvRankPb(e));
        }
        handler.sendMsgToPlayer(GetPartyLvRankRs.ext, builder.build());
    }

    /**
     * Function:军团信息
     *
     * @param req
     * @param handler
     */
    public void getParty(GetPartyRq req, ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());

        if (player == null) {
            return;
        }

        if (player.lord.getLevel() < 10) {
            handler.sendErrorMsgToPlayer(GameError.LV_NOT_ENOUGH);
            return;
        }

        Member member = partyDataManager.getMemberById(handler.getRoleId());
        if (member == null) {
            member = partyDataManager.createNewMember(player.lord, PartyType.COMMON);
        }

        int partyId = req.getPartyId();
        if (partyId == 0) {
            partyId = member.getPartyId();
        }

        GetPartyRs.Builder builder = GetPartyRs.newBuilder();
        if (partyId != 0) {
            partyDataManager.refreshMember(member);
            PartyData partyData = partyDataManager.getParty(partyId);
            int count = partyDataManager.getPartyMemberCount(partyId);
            int rank = partyDataManager.getRank(partyId);
            builder.setParty(PbHelper.createPartyPb(partyData, count, rank, TimeHelper.getCurrentDay()));
        }

        if (member.getPartyId() != 0) {
            builder.setDonate(member.getDonate());
            builder.setJob(member.getJob());
            builder.setEnterTime(member.getEnterTime());
        }

        handler.sendMsgToPlayer(GetPartyRs.ext, builder.build());
    }

    /**
     * Function：军团成员
     *
     * @param handler
     */
    public void getPartyMember(ClientHandler handler) {
        Member member = partyDataManager.getMemberById(handler.getRoleId());
        if (member == null || member.getPartyId() == 0) {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }

        int partyId = member.getPartyId();
        GetPartyMemberRs.Builder builder = GetPartyMemberRs.newBuilder();
        List<Member> list = partyDataManager.getMemberList(partyId);
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
        handler.sendMsgToPlayer(GetPartyMemberRs.ext, builder.build());
    }

    /**
     * 大厅详细信息
     *
     * @param handler
     */
    public void getPartyHallRq(ClientHandler handler) {
        Member member = partyDataManager.getMemberById(handler.getRoleId());
        if (member == null || member.getPartyId() == 0) {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }

        partyDataManager.refreshMember(member);
        GetPartyHallRs.Builder builder = GetPartyHallRs.newBuilder();
        builder.setPartyDonate(PbHelper.createPartyDonatePb(member.getHallMine()));
        handler.sendMsgToPlayer(GetPartyHallRs.ext, builder.build());
    }

    /**
     * Function：帮派科技信息
     *
     * @param handler
     */
    public void getPartyScienceRq(ClientHandler handler) {
        Member member = partyDataManager.getMemberById(handler.getRoleId());
        GetPartyScienceRs.Builder builder = GetPartyScienceRs.newBuilder();
        if (member == null || member.getPartyId() == 0) {
            handler.sendMsgToPlayer(GetPartyScienceRs.ext, builder.build());
            return;
        }

        int partyId = member.getPartyId();
        partyDataManager.refreshMember(member);
        PartyData partyData = partyDataManager.getParty(partyId);
        builder.setPartyDonate(PbHelper.createPartyDonatePb(member.getScienceMine()));
        List<StaticPartyScience> initPartyScieceList = staticPartyDataMgr.getInitScience();
        for (StaticPartyScience e : initPartyScieceList) {
            int scienceId = e.getScienceId();
            PartyScience science = null;
            if (!partyData.getSciences().containsKey(scienceId)) {
                science = new PartyScience(scienceId, 0);
            } else {
                science = partyData.getSciences().get(scienceId);
            }
            if (science == null) {
                continue;
            }
            builder.addScience(PbHelper.createPartySciencePb(science));
        }
        // Iterator<Science> it = partyData.getSciences().values().iterator();
        // while (it.hasNext()) {
        // builder.addScience(PbHelper.createSciencePb(it.next()));
        // }
        handler.sendMsgToPlayer(GetPartyScienceRs.ext, builder.build());
    }

    /**
     * Function：军团福利院信息
     *
     * @param handler
     */
    public void getPartyWealRq(ClientHandler handler) {
        Member member = partyDataManager.getMemberById(handler.getRoleId());
        if (member == null || member.getPartyId() == 0) {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }

        partyDataManager.refreshMember(member);
        int partyId = member.getPartyId();

        PartyData partyData = partyDataManager.getParty(partyId);
        partyDataManager.refreshPartyData(partyData);

        GetPartyWealRs.Builder builder = GetPartyWealRs.newBuilder();
        builder.setEverWeal(member.getDayWeal());

        builder.setLive(partyData.getLively());
        int source = staticPartyDataMgr.getPartyLiveResource(partyData.getLively());
        Weal resource = new Weal();
        // 军团总资源
        Weal mine = partyData.getReportMine();

        // 可领取总福利
        long iron = mine.getIron() * source / 1000;
        long oil = mine.getOil() * source / 1000;
        long copper = mine.getCopper() * source / 1000;
        long silicon = mine.getSilicon() * source / 1000;
        long stone = mine.getStone() * source / 1000;

        // 剩余领取福利
        Weal wealMine = member.getWealMine();
        iron = iron - wealMine.getIron() < 0 ? 0 : iron - wealMine.getIron();
        oil = oil - wealMine.getOil() < 0 ? 0 : oil - wealMine.getOil();
        copper = copper - wealMine.getCopper() < 0 ? 0 : copper - wealMine.getCopper();
        silicon = silicon - wealMine.getSilicon() < 0 ? 0 : silicon - wealMine.getSilicon();
        stone = stone - wealMine.getStone() < 0 ? 0 : stone - wealMine.getStone();
        resource.setIron(iron);
        resource.setOil(oil);
        resource.setCopper(copper);
        resource.setSilicon(silicon);
        resource.setStone(stone);

        builder.setResource(PbHelper.createWealPb(resource));

        builder.setGetResource(PbHelper.createWealPb(member.getWealMine()));
        Iterator<LiveTask> it = partyData.getLiveTasks().values().iterator();
        while (it.hasNext()) {
            builder.addLiveTask(PbHelper.createLiveTaskPb(it.next()));
        }

        handler.sendMsgToPlayer(GetPartyWealRs.ext, builder.build());
    }

    /**
     * Function:军团道具商店
     *
     * @param handler
     */
    public void getPartyShopRq(ClientHandler handler) {
        Member member = partyDataManager.getMemberById(handler.getRoleId());
        if (member == null || member.getPartyId() == 0) {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }

        PartyData partyData = partyDataManager.getParty(member.getPartyId());
        if (partyData == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }

        partyDataManager.refreshMember(member);
        partyDataManager.refreshPartyData(partyData);

        GetPartyShopRs.Builder builder = GetPartyShopRs.newBuilder();
        Iterator<PartyProp> it = member.getPartyProps().iterator();
        while (it.hasNext()) {
            PartyProp next = it.next();
            StaticPartyProp staticProp = staticPartyDataMgr.getStaticPartyProp(next.getKeyId());
            if (staticProp == null || staticProp.getTreasure() != 1) {
                continue;
            }
            builder.addPartyProp(PbHelper.createPartyPropPb(next));
        }

        // 军团珍品
        List<Integer> shopProps = partyData.getShopProps();
        List<Integer> globalShop = globalDataManager.getPartyShop(partyData);
        for (int i = 0; i < globalShop.size(); i++) {
            int keyId = globalShop.get(i);
            int count = 0;
            if (shopProps.size() < i + 1) {
                shopProps.add(0);
            } else {
                count = shopProps.get(i);
            }
            builder.addPartyProp(PbHelper.createPartyPropPb(keyId, count));
        }

        handler.sendMsgToPlayer(GetPartyShopRs.ext, builder.build());
    }

    /**
     * 大厅捐献，一键捐赠所有非金币资源
     *
     * @param handler
     */
    public void donateAllPartyRes(ClientHandler handler) {
        Member member = partyDataManager.getMemberById(handler.getRoleId());
        if (member == null || member.getPartyId() == 0) {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }

        int partyId = member.getPartyId();
        PartyData partyData = partyDataManager.getParty(partyId);
        if (partyData == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }
        partyDataManager.refreshMember(member);
        partyDataManager.refreshPartyData(partyData);
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        Resource resource = player.resource;
        PartyDonate partyDonate = member.getHallMine();
        DonateAllPartyResRs.Builder builder = DonateAllPartyResRs.newBuilder();

        List<Integer> resDonate = new ArrayList<>();
        int build = 0;
        for (int i = 1; i < 6; i++) {
            int count = partyDataManager.getDonateMember(partyDonate, i);
            StaticPartyContribute staContribute = staticPartyDataMgr.getStaticContribute(i, count + 1);
            if (staContribute == null) {
                continue;
            }
            long hadResource = getResource(i, player.resource, player.lord);
            float discount = activityDataManager.discountDonate(i);
            int price = (int) (discount * staContribute.getPrice() / 100f);
            if (hadResource < price) {
                continue;
            }

            if (i == PartyType.RESOURCE_STONE) {
                partyDonate.setStone(count + 1);
                playerDataManager.modifyStone(player, -staContribute.getPrice(), AwardFrom.DONATE_PARTY);
                builder.setStone(resource.getStone());
            } else if (i == PartyType.RESOURCE_IRON) {
                partyDonate.setIron(count + 1);
                playerDataManager.modifyIron(player, -staContribute.getPrice(), AwardFrom.DONATE_PARTY);
                builder.setIron(resource.getIron());
            } else if (i == PartyType.RESOURCE_SILICON) {
                partyDonate.setSilicon(count + 1);
                playerDataManager.modifySilicon(player, -staContribute.getPrice(), AwardFrom.DONATE_PARTY);
                builder.setSilicon(resource.getSilicon());
            } else if (i == PartyType.RESOURCE_COPPER) {
                partyDonate.setCopper(count + 1);
                playerDataManager.modifyCopper(player, -staContribute.getPrice(), AwardFrom.DONATE_PARTY);
                builder.setCopper(resource.getCopper());
            } else if (i == PartyType.RESOURCE_OIL) {
                partyDonate.setOil(count + 1);
                playerDataManager.modifyOil(player, -staContribute.getPrice(), AwardFrom.DONATE_PARTY);
                builder.setOil(resource.getOil());
            }

            build += activityDataManager.fireSheet(player, partyId, staContribute.getBuild());
            resDonate.add(i);
        }
        builder.setBuild(build);
        builder.setIsBuild(false);

        if (resDonate.size() == 0) {
            handler.sendErrorMsgToPlayer(GameError.DONATE_COUNT);
            return;
        }

        activityDataManager.updActivity(player, ActivityConst.ACT_PARTY_DONATE, resDonate.size(), 0);
        for (int i = 0; i < resDonate.size(); i++) {
            PartyDataManager.doPartyLivelyTask(partyData, member, PartyType.TASK_DONATE);
        }
        playerDataManager.updTask(player, TaskType.COND_PARTY_DONATE, resDonate.size(), null);

        List<Long> donates = partyData.getDonates(1);
        if (donates == null) {
            partyData.setBuild(partyData.getBuild() + build);
            builder.setIsBuild(true);
            donates = new ArrayList<Long>();
            donates.add(handler.getRoleId());
            partyData.putDonates(1, donates);
        } else {
            int index = donates.indexOf(handler.getRoleId());
            if (index == -1) {
                int lvNum = staticPartyDataMgr.getLvNum(partyData.getPartyLv());
                // 避免反复退出再进军团的方式刷军团贡献？缺少注释难以理解+6是什么操作
                if (donates.size() < lvNum + 6) {
                    partyData.setBuild(partyData.getBuild() + build);
                    builder.setIsBuild(true);
                    donates.add(handler.getRoleId());
                }
            } else {
                builder.setIsBuild(true);
                partyData.setBuild(partyData.getBuild() + build);
            }
        }

        member.setDonate(member.getDonate() + build);
        member.setWeekDonate(member.getWeekDonate() + build);
        member.setWeekAllDonate(member.getWeekAllDonate() + build);
        activityDataManager.updatePartyLvRank(partyData);
        LogLordHelper.contribution(AwardFrom.DONATE_PARTY, player.account, player.lord, member.getDonate(), member.getWeekAllDonate(),
                build);

        handler.sendMsgToPlayer(DonateAllPartyResRs.ext, builder.build());

    }

    /**
     * 大厅捐献
     *
     * @param req
     * @param handler
     */
    public void donatePartyRq(DonatePartyRq req, ClientHandler handler) {
        Member member = partyDataManager.getMemberById(handler.getRoleId());
        if (member == null || member.getPartyId() == 0) {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }

        int partyId = member.getPartyId();
        PartyData partyData = partyDataManager.getParty(partyId);
        if (partyData == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }

        partyDataManager.refreshMember(member);
        partyDataManager.refreshPartyData(partyData);
        long roleId = handler.getRoleId();

        Player player = playerDataManager.getPlayer(roleId);
        if (player == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }

        Resource resource = player.resource;
        Lord lord = player.lord;
        int resourceId = req.getResouceId();
        if (resourceId < 1 || resourceId > 6) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }
        PartyDonate partyDonate = member.getHallMine();
        int count = partyDataManager.getDonateMember(partyDonate, resourceId);
        StaticPartyContribute staContribute = staticPartyDataMgr.getStaticContribute(resourceId, count + 1);
        if (staContribute == null) {
            handler.sendErrorMsgToPlayer(GameError.DONATE_COUNT);
            return;
        }
        long hadResource = getResource(resourceId, resource, lord);

        float discount = activityDataManager.discountDonate(resourceId);
        int price = (int) (discount * staContribute.getPrice() / 100f);

        if (hadResource < price) {
            handler.sendErrorMsgToPlayer(GameError.RESOURCE_NOT_ENOUGH);
            return;
        }

        DonatePartyRs.Builder builder = DonatePartyRs.newBuilder();
        if (resourceId == PartyType.RESOURCE_STONE) {
            partyDonate.setStone(count + 1);
            playerDataManager.modifyStone(player, -staContribute.getPrice(), AwardFrom.DONATE_PARTY);
            builder.setStone(resource.getStone());
            activityDataManager.updActivity(player, ActivityConst.ACT_PARTY_DONATE, 1, 0);
        } else if (resourceId == PartyType.RESOURCE_IRON) {
            partyDonate.setIron(count + 1);
            playerDataManager.modifyIron(player, -staContribute.getPrice(), AwardFrom.DONATE_PARTY);
            builder.setIron(resource.getIron());
            activityDataManager.updActivity(player, ActivityConst.ACT_PARTY_DONATE, 1, 0);
        } else if (resourceId == PartyType.RESOURCE_SILICON) {
            partyDonate.setSilicon(count + 1);
            playerDataManager.modifySilicon(player, -staContribute.getPrice(), AwardFrom.DONATE_PARTY);
            builder.setSilicon(resource.getSilicon());
            activityDataManager.updActivity(player, ActivityConst.ACT_PARTY_DONATE, 1, 0);
        } else if (resourceId == PartyType.RESOURCE_COPPER) {
            partyDonate.setCopper(count + 1);
            playerDataManager.modifyCopper(player, -staContribute.getPrice(), AwardFrom.DONATE_PARTY);
            builder.setCopper(resource.getCopper());
            activityDataManager.updActivity(player, ActivityConst.ACT_PARTY_DONATE, 1, 0);
        } else if (resourceId == PartyType.RESOURCE_OIL) {
            partyDonate.setOil(count + 1);
            playerDataManager.modifyOil(player, -staContribute.getPrice(), AwardFrom.DONATE_PARTY);
            builder.setOil(resource.getOil());
            activityDataManager.updActivity(player, ActivityConst.ACT_PARTY_DONATE, 1, 0);
        } else if (resourceId == PartyType.RESOURCE_GOLD) {
            partyDonate.setGold(count + 1);
            playerDataManager.subGold(player, price, AwardFrom.DONATE_PARTY);
            builder.setGold(player.lord.getGold());
            activityDataManager.updActivity(player, ActivityConst.ACT_PARTY_DONATE, 1, 1);
        }

        PartyDataManager.doPartyLivelyTask(partyData, member, PartyType.TASK_DONATE);

        playerDataManager.updTask(player, TaskType.COND_PARTY_DONATE, 1, null);

        // 添加建设度
        int build = staContribute.getBuild();
        build = activityDataManager.fireSheet(player, partyId, build);
        builder.setIsBuild(false);

        List<Long> donates = partyData.getDonates(1);
        if (donates == null) {
            partyData.setBuild(partyData.getBuild() + build);
            builder.setIsBuild(true);
            donates = new ArrayList<Long>();
            donates.add(roleId);
            partyData.putDonates(1, donates);
        } else {
            int index = donates.indexOf(roleId);
            if (index == -1) {
                int lvNum = staticPartyDataMgr.getLvNum(partyData.getPartyLv());
                if (donates.size() < lvNum + 6) {
                    partyData.setBuild(partyData.getBuild() + build);
                    builder.setIsBuild(true);
                    donates.add(roleId);
                }
            } else {
                partyData.setBuild(partyData.getBuild() + build);
                builder.setIsBuild(true);
            }
        }

        member.setDonate(member.getDonate() + build);
        member.setWeekDonate(member.getWeekDonate() + build);
        member.setWeekAllDonate(member.getWeekAllDonate() + build);

        activityDataManager.updatePartyLvRank(partyData);

        handler.sendMsgToPlayer(DonatePartyRs.ext, builder.build());

        // 记日志
        LogLordHelper.contribution(AwardFrom.DONATE_PARTY, player.account, lord, member.getDonate(), member.getWeekAllDonate(), build);
    }

    /**
     * Function:军团建筑:大厅，科技馆，福利院升级
     *
     * @param req
     * @param handler
     */
    public void upPartyBuildingRq(UpPartyBuildingRq req, ClientHandler handler) {
        int buildingId = req.getBuildingId();
        if (buildingId != PartyType.HALL_ID && buildingId != PartyType.SCIENCE_ID && buildingId != PartyType.WEAL_ID
                && buildingId != PartyType.ALTAR_ID) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }

        Member member = partyDataManager.getMemberById(handler.getRoleId());
        if (member == null || member.getPartyId() == 0) {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }

        if (member.getJob() != PartyType.LEGATUS) {
            handler.sendErrorMsgToPlayer(GameError.AUTHORITY_ERR);
            return;
        }

        int partyId = member.getPartyId();
        PartyData partyData = partyDataManager.getParty(partyId);
        if (partyData == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }

        int buildingLv = 0;
        StaticPartyBuildLevel buildLevel = null;
        if (buildingId == PartyType.HALL_ID) {
            buildingLv = partyData.getPartyLv() + 1;
        } else if (buildingId == PartyType.SCIENCE_ID) {
            if (partyData.getScienceLv() >= partyData.getPartyLv()) {// 不能超过军团大厅科技等级
                handler.sendErrorMsgToPlayer(GameError.PARTY_LV_ERROR);
                return;
            }
            buildingLv = partyData.getScienceLv() + 1;
        } else if (buildingId == PartyType.WEAL_ID) {
            if (partyData.getWealLv() >= partyData.getPartyLv()) {// 不能超过军团大厅科技等级
                handler.sendErrorMsgToPlayer(GameError.PARTY_LV_ERROR);
                return;
            }
            buildingLv = partyData.getWealLv() + 1;
        } else if (buildingId == PartyType.ALTAR_ID) {// 军团祭坛
            if (partyData.getPartyLv() < 20) {
                handler.sendErrorMsgToPlayer(GameError.ALTAR_PARTY_LV_LIMIT);// 祭坛字大厅20级后开放
                return;
            }

            if (partyData.getAltarLv() >= partyData.getPartyLv() / 5) {// 不能超过军团大厅科技等级/5
                handler.sendErrorMsgToPlayer(GameError.ALTAR_LV_EXCEED);
                return;
            }

            // 祭坛BOSS开始后，不允许在升级祭坛（由于重启时如果祭坛BOSS没有结束，重启后会重置，需要返还资源，为避免玩家刷资源，不允许召唤后继续升级）
            if (partyData.getBossState() == BossState.PREPAIR_STATE || partyData.getBossState() == BossState.FIGHT_STATE) {
                handler.sendErrorMsgToPlayer(GameError.ALTAR_BOSS_STARTED);
                return;
            }

            buildingLv = partyData.getAltarLv() + 1;

            // 策划已配7级祭坛，但暂时不动祭坛，维持祭坛最大等级在6级
            if (buildingLv > 6) {
                handler.sendErrorMsgToPlayer(GameError.ALTAR_LV_EXCEED);
                return;
            }
        }

        buildLevel = staticPartyDataMgr.getBuildLevel(buildingId, buildingLv);
        UpPartyBuildingRs.Builder builder = UpPartyBuildingRs.newBuilder();
        if (buildLevel != null && partyData.getBuild() >= buildLevel.getNeedExp()) {
            partyData.setBuild(partyData.getBuild() - buildLevel.getNeedExp());
            if (buildingId == PartyType.HALL_ID) {
                partyData.setPartyLv(buildingLv);
                partyDataManager.addPartyTrend(partyId, 7, String.valueOf(buildingLv));
            } else if (buildingId == PartyType.SCIENCE_ID) {
                partyData.setScienceLv(buildingLv);
                partyDataManager.addPartyTrend(partyId, 8, String.valueOf(buildingLv));
            } else if (buildingId == PartyType.WEAL_ID) {
                partyData.setWealLv(buildingLv);
                partyDataManager.addPartyTrend(partyId, 9, String.valueOf(buildingLv));
            } else if (buildingId == PartyType.ALTAR_ID) {
                partyData.setAltarLv(buildingLv);
                partyDataManager.addPartyTrend(partyId, 19, String.valueOf(buildingLv));
            } else {
                buildingLv -= 1;
            }
        }

        activityDataManager.updatePartyLvRank(partyData);

        builder.setBuildingId(buildingId);
        builder.setBuildingLv(buildingLv);
        handler.sendMsgToPlayer(UpPartyBuildingRs.ext, builder.build());
    }

    /**
     * 自定义职位
     *
     * @param req
     * @param handler
     */
    public void setPartyJobRq(SetPartyJobRq req, ClientHandler handler) {
        String jobName1 = req.getJobName1();
        String jobName2 = req.getJobName2();
        String jobName3 = req.getJobName3();
        String jobName4 = req.getJobName4();
        Member member = partyDataManager.getMemberById(handler.getRoleId());
        if (member == null || member.getPartyId() == 0) {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }

        if (member.getJob() != PartyType.LEGATUS) {
            handler.sendErrorMsgToPlayer(GameError.AUTHORITY_ERR);
            return;
        }

        int partyId = member.getPartyId();
        PartyData partyData = partyDataManager.getParty(partyId);
        if (partyData == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }

        if (jobName1 == null || jobName1.length() > 4) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }

        if (jobName2 == null || jobName2.length() > 4) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }

        if (jobName3 == null || jobName3.length() > 4) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }

        if (jobName4 == null || jobName4.length() > 4) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }

        jobName1 = EmojiHelper.filterEmoji(jobName1);
        jobName2 = EmojiHelper.filterEmoji(jobName2);
        jobName3 = EmojiHelper.filterEmoji(jobName3);
        jobName4 = EmojiHelper.filterEmoji(jobName4);

        partyData.setJobName1(jobName1);
        partyData.setJobName2(jobName2);
        partyData.setJobName3(jobName3);
        partyData.setJobName4(jobName4);
        SetPartyJobRs.Builder builder = SetPartyJobRs.newBuilder();
        handler.sendMsgToPlayer(SetPartyJobRs.ext, builder.build());
    }

    /**
     * 贡献兑换军团道具
     *
     * @param req
     * @param handler
     */
    public void buyPartyShopRq(BuyPartyShopRq req, ClientHandler handler) {
        int keyId = req.getKeyId();
        Member member = partyDataManager.getMemberById(handler.getRoleId());
        if (member == null || member.getPartyId() == 0) {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }
        int partyId = member.getPartyId();
        PartyData partyData = partyDataManager.getParty(partyId);
        if (partyData == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }
        StaticPartyProp staticProp = staticPartyDataMgr.getStaticPartyProp(keyId);
        if (staticProp == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }

        partyDataManager.refreshPartyData(partyData);
        partyDataManager.refreshMember(member);

        int itemType = staticProp.getItemType();
        int itemId = staticProp.getItemId();
        int itemCount = staticProp.getItemNum();
        int treasure = staticProp.getTreasure();
        int contribute = staticProp.getContribute();

        PartyProp partyProp = null;
        BuyPartyShopRs.Builder builder = BuyPartyShopRs.newBuilder();
        if (treasure == 1) {
            Iterator<PartyProp> it = member.getPartyProps().iterator();
            while (it.hasNext()) {
                PartyProp next = it.next();
                if (next.getKeyId() == keyId && next.getCount() < staticProp.getCount()) {
                    partyProp = next;
                }
            }
            if (partyProp == null) {
                handler.sendErrorMsgToPlayer(GameError.PROP_REFRESH);
                return;
            }
            if (!partyDataManager.subDonate(member, contribute)) {
                handler.sendErrorMsgToPlayer(GameError.DONATE_NOT_ENOUGH);
                return;
            }
            partyProp.setCount(partyProp.getCount() + 1);
        } else {
            List<Integer> globalShop = globalDataManager.getPartyShop(partyData);
            int buyCount = 0;
            for (int i = 0; i < globalShop.size(); i++) {
                int golKeyId = globalShop.get(i);
                int count = partyData.getShopProps().get(i);
                if (golKeyId == keyId && count < staticProp.getCount()) {
                    buyCount = count + 1;

                    if (!partyDataManager.subDonate(member, contribute)) {
                        handler.sendErrorMsgToPlayer(GameError.DONATE_NOT_ENOUGH);
                        return;
                    }

                    partyData.getShopProps().set(i, buyCount);
                    break;
                }
            }
            if (buyCount == 0) {
                handler.sendErrorMsgToPlayer(GameError.PROP_REFRESH);
                return;
            }
        }

        int awardKeyId = playerDataManager.addAward(player, itemType, itemId, itemCount, AwardFrom.PARTY_SHOP);
        builder.addAward(PbHelper.createAwardPb(itemType, itemId, staticProp.getItemNum(), awardKeyId));

        handler.sendMsgToPlayer(BuyPartyShopRs.ext, builder.build());
        // 军团贡献消耗记录日志
        LogLordHelper.subContribution(AwardFrom.PARTY_SHOP, player.account, player.lord, member.getDonate(), member.getWeekAllDonate(),
                contribute);
        PartyDataManager.doPartyLivelyTask(partyData, member, PartyType.TASK_BUY_SHOP);
        playerDataManager.updTask(player, TaskType.COND_PARTY_PROP, 1, null);
    }

    /**
     * 领取军团福利
     *
     * @param req
     * @param handler void
     */
    public void wealDayPartyRq(WealDayPartyRq req, ClientHandler handler) {
        int type = req.getType();
        Member member = partyDataManager.getMemberById(handler.getRoleId());
        if (member == null || member.getPartyId() == 0) {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }

        int enterTime = member.getEnterTime();
        if (enterTime == TimeHelper.getCurrentDay()) {
            handler.sendErrorMsgToPlayer(GameError.TIME_NOT_ENOUGH);
            return;
        }

        int partyId = member.getPartyId();
        PartyData partyData = partyDataManager.getParty(partyId);
        if (partyData == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }

        WealDayPartyRs.Builder builder = WealDayPartyRs.newBuilder();
        if (type == 1) {
            if (member.getDayWeal() != 0) {
                handler.sendErrorMsgToPlayer(GameError.WEAL_GOT);
                return;
            }
            StaticPartyWeal staticPartyWeal = staticPartyDataMgr.getStaticWeal(partyData.getWealLv());
            if (staticPartyWeal == null) {
                handler.sendErrorMsgToPlayer(GameError.WEAL_NOT_EXIST);
                return;
            }
            int contribute = 5;
            if (contribute > member.getDonate()) {
                handler.sendErrorMsgToPlayer(GameError.DONATE_NOT_ENOUGH);
                return;
            }
            member.setDonate(member.getDonate() - contribute);
            List<List<Integer>> list = staticPartyWeal.getWealList();
            for (List<Integer> e : list) {
                int itemType = e.get(0);
                int itemId = e.get(1);
                int itemCount = e.get(2);
                int keydId = playerDataManager.addAward(player, itemType, itemId, itemCount, AwardFrom.PARTY_WEAL_DAY);
                builder.addAward(PbHelper.createAwardPb(itemType, itemId, itemCount, keydId));
            }
            member.setDayWeal(1);
            // 军团贡献消耗记录日志
            LogLordHelper.subContribution(AwardFrom.PARTY_WEAL_DAY, player.account, player.lord, member.getDonate(),
                    member.getWeekAllDonate(), contribute);
        } else if (type == 2) {
            partyDataManager.refreshPartyData(partyData);
            int source = staticPartyDataMgr.getPartyLiveResource(partyData.getLively());
            // 军团总资源
            Weal mine = partyData.getReportMine();

            // 可领取总福利
            long iron = mine.getIron() * source / 1000;
            long oil = mine.getOil() * source / 1000;
            long copper = mine.getCopper() * source / 1000;
            long silicon = mine.getSilicon() * source / 1000;
            long stone = mine.getStone() * source / 1000;

            // 剩余领取福利
            Weal wealMine = member.getWealMine();
            iron = iron - wealMine.getIron() < 0 ? 0 : iron - wealMine.getIron();
            oil = oil - wealMine.getOil() < 0 ? 0 : oil - wealMine.getOil();
            copper = copper - wealMine.getCopper() < 0 ? 0 : copper - wealMine.getCopper();
            silicon = silicon - wealMine.getSilicon() < 0 ? 0 : silicon - wealMine.getSilicon();
            stone = stone - wealMine.getStone() < 0 ? 0 : stone - wealMine.getStone();

            // 记录领取福利
            wealMine.setIron(wealMine.getIron() + iron);
            wealMine.setOil(wealMine.getOil() + oil);
            wealMine.setCopper(wealMine.getCopper() + copper);
            wealMine.setSilicon(wealMine.getSilicon() + silicon);
            wealMine.setStone(wealMine.getStone() + stone);

            Resource resource = player.resource;
            playerDataManager.modifyIron(player, iron, AwardFrom.WEAL_DAY);
            playerDataManager.modifyOil(player, oil, AwardFrom.WEAL_DAY);
            playerDataManager.modifySilicon(player, silicon, AwardFrom.WEAL_DAY);
            playerDataManager.modifyCopper(player, copper, AwardFrom.WEAL_DAY);
            playerDataManager.modifyStone(player, stone, AwardFrom.WEAL_DAY);
            builder.setIron(resource.getIron());
            builder.setOil(resource.getOil());
            builder.setCopper(resource.getCopper());
            builder.setSilicon(resource.getSilicon());
            builder.setStone(resource.getStone());
        }
        handler.sendMsgToPlayer(WealDayPartyRs.ext, builder.build());
    }

    /**
     * 申请列表
     *
     * @param handler void
     */
    public void partyApplyListRq(ClientHandler handler) {
        Member member = partyDataManager.getMemberById(handler.getRoleId());
        if (member == null || member.getPartyId() == 0) {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }
        if (member.getJob() == PartyType.COMMON) {
            handler.sendErrorMsgToPlayer(GameError.AUTHORITY_ERR);
            return;
        }
        Player p = playerDataManager.getPlayer(handler.getRoleId());
        if (p == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }
        if (p.lord.getLevel() < 10) {
            handler.sendErrorMsgToPlayer(GameError.LV_NOT_ENOUGH);
            return;
        }
        int partyId = member.getPartyId();
        PartyData partyData = partyDataManager.getParty(partyId);
        PartyApplyListRs.Builder builder = PartyApplyListRs.newBuilder();
        Iterator<PartyApply> it = partyData.getApplys().values().iterator();
        while (it.hasNext()) {
            PartyApply partyApply = it.next();
            long lordId = partyApply.getLordId();
            Player player = playerDataManager.getPlayer(lordId);
            if (player == null) {
                continue;
            }
            builder.addPartyApply(PbHelper.createPartyApplyPb(player.lord, partyApply));
        }
        handler.sendMsgToPlayer(PartyApplyListRs.ext, builder.build());
    }

    /**
     * 玩家申请入军团
     *
     * @param req
     * @param handler
     */
    public void partyApplyRq(PartyApplyRq req, ClientHandler handler) {
        long roldId = handler.getRoleId();
        Player player = playerDataManager.getPlayer(roldId);
        if (player == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }

        Member member = partyDataManager.getMemberById(roldId);
        if (member == null) {
            member = partyDataManager.createNewMember(player.lord, PartyType.COMMON);
        }
        if (member.getPartyId() != 0) {
            handler.sendErrorMsgToPlayer(GameError.PARTY_HAD);
            return;
        }
        int partyId = req.getPartyId();
        PartyData partyData = partyDataManager.getParty(partyId);

        Lord lord = player.lord;
        if (partyData.getApplyFight() > lord.getFight()) {
            handler.sendErrorMsgToPlayer(GameError.FIGHT_NOT_ENOUGH);
            return;
        }

        if (partyData.getApplyLv() > lord.getLevel() || lord.getLevel() < 10) {
            handler.sendErrorMsgToPlayer(GameError.LV_NOT_ENOUGH);
            return;
        }

        int memberCount = partyDataManager.getPartyMemberCount(partyId);
        int limitNum = staticPartyDataMgr.getLvNum(partyData.getPartyLv());
        if (limitNum <= memberCount) {
            handler.sendErrorMsgToPlayer(GameError.COUNT_NOT_ENOUGH);
            return;
        }

        if (partyData.getApply() == PartyType.APPLY) {
            Map<Long, PartyApply> applys = partyData.getApplys();
            if (applys.size() >= 20) {
                handler.sendErrorMsgToPlayer(GameError.PARTY_APPLY_FULL);
                return;
            }
            if (applys.containsKey(roldId)) {
                handler.sendErrorMsgToPlayer(GameError.HAD_APPLY);
                return;
            }

            int today = TimeHelper.getCurrentSecond();
            PartyApply partyApply = new PartyApply();
            partyApply.setLordId(roldId);
            partyApply.setApplyDate(today);
            applys.put(roldId, partyApply);

            String applyList = member.getApplyList();
            if (applyList == null || applyList.startsWith("null")) {
                member.setApplyList("|" + partyId + "|");
            } else {
                // 最多只能申请20个军团
                String[] apply_arr = applyList.split("|");
                if (apply_arr.length > 20) {
                    handler.sendErrorMsgToPlayer(GameError.PARTY_APPLY_FULL);
                    return;
                }
                member.setApplyList(applyList + partyId + "|");
            }

            // 异步通知军团长,副军团
            playerDataManager.synApplyPartyToPlayer(partyId, applys.size());
        } else {
            int partyLv = partyData.getPartyLv();
            String applyList = member.getApplyList();
            int flag = partyDataManager.enterParty(partyId, partyLv, member);
            if (flag == 1) {
                handler.sendErrorMsgToPlayer(GameError.PARTY_HAD);
                return;
            } else if (flag == 2) {
                handler.sendErrorMsgToPlayer(GameError.PARTY_MEMBER_FULL);
                return;
            }
            if (lord.getPartyTipAward() == 0) {
                lord.setPartyTipAward(1);
            }
            resetApply(roldId, applyList, 0);// 该玩家的申请全取消

            // LogHelper.MESSAGE_LOGGER.trace("getSeniorState:" +
            // player.lord.getNick() + " state:" +
            // mineDataManager.getSeniorState());
            if (mineDataManager.getSeniorState() == SeniorState.END_STATE) {
                player.seniorAward = 1;
                // LogHelper.MESSAGE_LOGGER.trace("player:" +
                // player.lord.getNick() + " seniorAward:" +
                // player.seniorAward);
            }

            playerEventService.calcStrongestFormAndFight(player);

            // 玩家加入军团的民情
            partyDataManager.addPartyTrend(partyId, 1, String.valueOf(roldId));

            playerDataManager.sendNormalMail(player, MailType.MOLD_ENTER_PARTY, TimeHelper.getCurrentSecond(), partyData.getPartyName());
            chatService.sendPartyChat(chatService.createSysChat(SysChatId.JOIN_PARTY, player.lord.getNick()), partyId);
        }
        PartyApplyRs.Builder builder = PartyApplyRs.newBuilder();
        handler.sendMsgToPlayer(PartyApplyRs.ext, builder.build());
    }

    /**
     * Function：军团申请审批
     *
     * @param req
     * @param handler
     */
    public void partyApplyJudgeRq(PartyApplyJudgeRq req, ClientHandler handler) {
        int judge = req.getJudge();
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }

        Member member = partyDataManager.getMemberById(handler.getRoleId());
        if (member == null || member.getPartyId() == 0) {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }

        if (member.getJob() < PartyType.LEGATUS_CP) {
            handler.sendErrorMsgToPlayer(GameError.AUTHORITY_ERR);
            return;
        }

        int partyId = member.getPartyId();
        PartyData partyData = partyDataManager.getParty(partyId);
        if (judge == 1 || judge == 2) {
            long lordId = req.getLordId();
            PartyApply applyer = partyData.getApplys().get(lordId);
            if (applyer == null) {
                handler.sendErrorMsgToPlayer(GameError.PARTY_HAD);
                return;
            }
            Member memberApplyer = partyDataManager.getMemberById(lordId);
            if (memberApplyer == null || memberApplyer.getPartyId() != 0) {
                handler.sendErrorMsgToPlayer(GameError.PARTY_HAD);
                return;
            }
            Player playerApply = playerDataManager.getPlayer(lordId);
            if (playerApply == null) {
                handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
                return;
            }

            if (judge == 1) {// 通过
                String applyList = memberApplyer.getApplyList();
                int count = partyDataManager.enterParty(partyId, partyData.getPartyLv(), memberApplyer);
                if (count == 0) {
                    partyDataManager.addPartyTrend(partyId, 1, String.valueOf(lordId));
                    playerDataManager.sendNormalMail(playerApply, MailType.MOLD_ENTER_PARTY, TimeHelper.getCurrentSecond(),
                            partyData.getPartyName());

                    playerDataManager.synPartyAcceptToPlayer(playerApply, partyId, 1);
                    resetApply(lordId, applyList, 0);// 该玩家的申请全取消

                    Lord lord = playerApply.lord;

                    if (lord != null && lord.getPartyTipAward() == 0) {
                        lord.setPartyTipAward(1);
                    }

                    if (mineDataManager.getSeniorState() == SeniorState.END_STATE) {
                        playerApply.seniorAward = 1;
                    }

                    chatService.sendPartyChat(chatService.createSysChat(SysChatId.JOIN_PARTY, playerApply.lord.getNick()), partyId);
                    // 更新玩家最强实力
                    playerEventService.calcStrongestFormAndFight(player);
                } else {
                    handler.sendErrorMsgToPlayer(GameError.PARTY_MEMBER_FULL);
                    return;
                }
            } else {// 拒绝
                resetApply(lordId, memberApplyer.getApplyList(), partyId);// 该玩家的申请取消
                memberApplyer.getApplyList().replace("|" + partyId, "");
                playerDataManager.synPartyAcceptToPlayer(playerApply, partyId, 0);
            }
        } else if (judge == 3) {// 清空玩家申请列表
            Iterator<PartyApply> it = partyData.getApplys().values().iterator();
            while (it.hasNext()) {
                PartyApply next = it.next();
                it.remove();
                Member applyMember = partyDataManager.getMemberById(next.getLordId());
                if (applyMember == null) {
                    continue;
                }
                applyMember.getApplyList().replace("|" + partyId, "");
            }
        }
        PartyApplyJudgeRs.Builder builder = PartyApplyJudgeRs.newBuilder();
        handler.sendMsgToPlayer(PartyApplyJudgeRs.ext, builder.build());
    }

    /**
     * Function:创建军团
     *
     * @param req
     * @param handler
     */
    public void createPartyRq(CreatePartyRq req, ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }

        Member member = partyDataManager.getMemberById(handler.getRoleId());
        if (member == null) {
            member = partyDataManager.createNewMember(player.lord, PartyType.COMMON);
        }

        if (member.getPartyId() != 0) {
            handler.sendErrorMsgToPlayer(GameError.PARTY_HAD);
            return;
        }

        String partyName = req.getPartyName().replaceAll(" ", "");
        partyName = EmojiHelper.replace(partyName);

        if (partyDataManager.isExistPartyName(partyName)) {
            handler.sendErrorMsgToPlayer(GameError.SAME_PARTY_NAME);
            return;
        }

        partyDataManager.refreshMember(member);

        int apply = req.getApplyType();
        int createType = req.getType();
        if (apply != 1 && apply != 2) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }
        if (createType != 1 && createType != 2) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }

        if (partyName == null || partyName.isEmpty() || partyName.length() >= 12 || partyName.length() < 2) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }

        if (EmojiHelper.containsEmoji(partyName)) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_CHAR);
            return;
        }

        boolean flag = partyDataManager.isNameExist(partyName);
        if (flag) {
            handler.sendErrorMsgToPlayer(GameError.SAME_PARTY_NAME);
            return;
        }

        if (player.lord.getLevel() < 10) {
            handler.sendErrorMsgToPlayer(GameError.LV_NOT_ENOUGH);
            return;
        }
        int today = TimeHelper.getCurrentDay();
        Lord lord = player.lord;
        Resource resource = player.resource;
        if (createType == 1) {
            int cost = 50;
            if (lord.getGold() < cost) {
                handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
                return;
            }
            playerDataManager.subGold(player, cost, AwardFrom.PARTY_CREATE);
        } else if (createType == 2) {
            int cost = 300 * 1000;
            if (resource.getStone() < cost || resource.getIron() < cost || resource.getSilicon() < cost || resource.getCopper() < cost
                    || resource.getOil() < cost) {
                handler.sendErrorMsgToPlayer(GameError.RESOURCE_NOT_ENOUGH);
                return;
            }
            playerDataManager.modifyStone(resource, -cost);
            playerDataManager.modifyCopper(resource, -cost);
            playerDataManager.modifyIron(resource, -cost);
            playerDataManager.modifySilicon(resource, -cost);
            playerDataManager.modifyOil(resource, -cost);
        }
        if (lord != null && lord.getPartyTipAward() == 0) {
            lord.setPartyTipAward(1);
        }

        PartyData partyData = partyDataManager.createParty(lord, member, partyName, apply, today);
        CreatePartyRs.Builder builder = CreatePartyRs.newBuilder();
        int rank = partyDataManager.getRank(partyData.getPartyId());
        builder.setParty(PbHelper.createPartyPb(partyData, 1, rank, today));
        builder.setStone(resource.getSilicon());
        builder.setIron(resource.getIron());
        builder.setSilicon(resource.getSilicon());
        builder.setCopper(resource.getCopper());
        builder.setOil(resource.getOil());
        builder.setGold(lord.getGold());
        handler.sendMsgToPlayer(CreatePartyRs.ext, builder.build());

        activityDataManager.addPartyLvRank(partyData);
    }

    /**
     * Function:退出军团
     *
     * @param handler
     */
    public void quitPartyRq(ClientHandler handler) {
        Member member = partyDataManager.getMemberById(handler.getRoleId());
        PartyData partyData = member != null ? partyDataManager.getParty(member.getPartyId()) : null;
        if (partyData == null) {
            handler.sendErrorMsgToPlayer(GameError.PARTY_HAD);
            return;
        }

        int partyId = member.getPartyId();
        int count = partyDataManager.getPartyMemberCount(partyId);
        if (count <= 1) {
            handler.sendErrorMsgToPlayer(GameError.PARTY_HAD);
            return;
        }

        if (member.getJob() == PartyType.LEGATUS) {
            handler.sendErrorMsgToPlayer(GameError.PARTY_HAD);
            return;
        }

        if (partyDataManager.inWar(member)) {
            handler.sendErrorMsgToPlayer(GameError.IN_WAR);
            return;
        }
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player.isExistFortressArmy()) {
            handler.sendErrorMsgToPlayer(GameError.Is_In_Fortress);
            return;
        }

        GameError error = airshipService.quitPartyAirshipCheck(player, partyData);
        if (error != null) {
            handler.sendErrorMsgToPlayer(error);
            return;
        }

        // 若在跨服军团战期间,报名了的不能退出军团
        if (TimeHelper.isCrossOpen(CrossConst.CrossPartyType)) {
            CCCanQuitPartyRq.Builder builder = CCCanQuitPartyRq.newBuilder();
            builder.setRoleId(handler.getRoleId());
            builder.setType(1);

            handler.sendMsgToCrossServer(CCCanQuitPartyRq.EXT_FIELD_NUMBER, CCCanQuitPartyRq.ext, builder.build());
        } else {
            partyDataManager.quitParty(partyId, member);

            partyDataManager.addPartyTrend(partyId, 2, String.valueOf(handler.getRoleId()));

            QuitPartyRs.Builder builder = QuitPartyRs.newBuilder();
            handler.sendMsgToPlayer(QuitPartyRs.ext, builder.build());

            worldService.retreatAllGuard(player);

            chatService.sendPartyChat(chatService.createSysChat(SysChatId.QUIT_PARTY, player.lord.getNick()), partyId);

            altarBossService.resetBossAutoFight(partyId, handler.getRoleId());// 重置祭坛BOSS自动战斗状态

            airshipService.afterQuitParty(player, partyData);
            // 更新玩家最强实力
            playerEventService.calcStrongestFormAndFight(player);
        }
    }

    /**
     * 一键捐赠军团科技，非金币资源捐赠
     *
     * @param handler
     */
    public void donateAllScienceRes(DonateAllPartyScienceRq req, ClientHandler handler) {
        int scienceId = req.getScienceId();
        if (!staticPartyDataMgr.getScienceMap().containsKey(scienceId)) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }

        Member member = partyDataManager.getMemberById(handler.getRoleId());
        if (member == null || member.getPartyId() == 0) {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }

        int partyId = member.getPartyId();
        PartyData partyData = partyDataManager.getParty(partyId);
        if (partyData == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }

        partyDataManager.refreshPartyData(partyData);
        partyDataManager.refreshMember(member);
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }
        Resource resource = player.resource;
        PartyDonate partyDonate = member.getScienceMine();

        Map<Integer, PartyScience> scienceMap = partyData.getSciences();
        PartyScience science = scienceMap.get(scienceId);
        if (science == null) {
            science = new PartyScience();
            science.setScienceId(scienceId);
            science.setScienceLv(0);
            science.setSchedule(0);
            scienceMap.put(scienceId, science);
        }

        int scienceLv = partyData.getScienceLv();
        if (scienceLv < science.getScienceLv()) {
            handler.sendErrorMsgToPlayer(GameError.SCIENCE_LV_ERROR);
            return;
        }

        StaticPartyScience staticScience = staticPartyDataMgr.getPartyScience(scienceId, science.getScienceLv() + 1);
        if (staticScience == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }
        int maxSchedule = staticScience.getSchedule();
        if (scienceLv == science.getScienceLv() && science.getSchedule() >= maxSchedule) {
            handler.sendErrorMsgToPlayer(GameError.SCIENCE_LV_ERROR);
            return;
        }

        List<Integer> resDonate = new ArrayList<>();
        int build = 0;
        if (partyDonate.getCopper() == 0 && partyDonate.getGold() == 0 && partyDonate.getIron() == 0 && partyDonate.getOil() == 0
                && partyDonate.getSilicon() == 0 && partyDonate.getStone() == 0) {
            /*
             * 这个值在s_party_lively表中science字段，设计意图为倍数相乘，首次捐献时build=基础build * 活跃加成系数，
             * 但因为现今配置，各项捐献的首次基础都是build=1, 所以这里直接写成了加算，作为额外奖励的方式
             */
            build += staticPartyDataMgr.getPartyLiveBuild(partyData.getLively());
        }

        DonateAllPartyScienceRs.Builder builder = DonateAllPartyScienceRs.newBuilder();
        for (int i = 1; i < 6; i++) {
            int count = partyDataManager.getDonateMember(partyDonate, i);
            StaticPartyContribute staContribute = staticPartyDataMgr.getStaticContribute(i, count + 1);
            if (staContribute == null) {
                continue;
            }
            long hadResource = getResource(i, resource, player.lord);
            float discount = activityDataManager.discountDonate(i);
            int price = (int) (discount * staContribute.getPrice() / 100f);
            if (hadResource < price) {
                continue;
            }
            if (i == PartyType.RESOURCE_STONE) {
                partyDonate.setStone(count + 1);
                playerDataManager.modifyStone(player, -staContribute.getPrice(), AwardFrom.DONATE_SCIENCE);
                builder.setStone(resource.getStone());
            } else if (i == PartyType.RESOURCE_IRON) {
                partyDonate.setIron(count + 1);
                playerDataManager.modifyIron(player, -staContribute.getPrice(), AwardFrom.DONATE_SCIENCE);
                builder.setIron(resource.getIron());
            } else if (i == PartyType.RESOURCE_SILICON) {
                partyDonate.setSilicon(count + 1);
                playerDataManager.modifySilicon(player, -staContribute.getPrice(), AwardFrom.DONATE_SCIENCE);
                builder.setSilicon(resource.getSilicon());
            } else if (i == PartyType.RESOURCE_COPPER) {
                partyDonate.setCopper(count + 1);
                playerDataManager.modifyCopper(player, -staContribute.getPrice(), AwardFrom.DONATE_SCIENCE);
                builder.setCopper(resource.getCopper());
            } else if (i == PartyType.RESOURCE_OIL) {
                partyDonate.setOil(count + 1);
                playerDataManager.modifyOil(player, -staContribute.getPrice(), AwardFrom.DONATE_SCIENCE);
                builder.setOil(resource.getOil());
            }

            resDonate.add(i);
            build += activityDataManager.fireSheet(player, partyId, staContribute.getBuild());
        }
        builder.setBuild(build);
        if (resDonate.size() == 0) {
            handler.sendErrorMsgToPlayer(GameError.DONATE_COUNT);
            return;
        }

        activityDataManager.updActivity(player, ActivityConst.ACT_PARTY_DONATE, resDonate.size(), 2);
        for (int i = 0; i < resDonate.size(); i++) {
            PartyDataManager.doPartyLivelyTask(partyData, member, PartyType.TASK_DONATE);
        }
        playerDataManager.updTask(player, TaskType.COND_PARTY_DONATE, resDonate.size(), null);

        int schedule = science.getSchedule() + build;
        if (scienceLv == science.getScienceLv()) {
            schedule = schedule > maxSchedule ? maxSchedule : schedule;
        }

        List<Long> donates = partyData.getDonates(2);
        if (donates == null) {
            donates = new ArrayList<Long>();
            donates.add(handler.getRoleId());
            partyData.putDonates(2, donates);
            science.setSchedule(schedule);
        } else {
            int index = donates.indexOf(handler.getRoleId());
            if (index == -1) {
                int lvNum = staticPartyDataMgr.getLvNum(partyData.getPartyLv());
                if (donates.size() < lvNum + 6) {
                    donates.add(handler.getRoleId());
                    science.setSchedule(schedule);
                }
            } else {
                science.setSchedule(schedule);
            }
        }

        if (scienceLv > science.getScienceLv() && science.getSchedule() >= maxSchedule) {
            science.setScienceLv(science.getScienceLv() + 1);
            schedule = science.getSchedule() - maxSchedule;
            schedule = schedule < 0 ? 0 : schedule;
            science.setSchedule(schedule);
            // 军团科技升级，更新工会所有成员的玩家最强实力
            List<Member> members = partyDataManager.getMemberList(partyId);
            for (Member mbr : members) {
                Player mbrp = playerDataManager.getPlayer(mbr.getLordId());
                if (mbrp != null) {
                    playerEventService.calcStrongestFormAndFight(mbrp);
                }
            }
        }
        builder.setScience(PbHelper.createPartySciencePb(science));

        member.setDonate(member.getDonate() + build);
        member.setWeekDonate(member.getWeekDonate() + build);
        member.setWeekAllDonate(member.getWeekAllDonate() + build);

        activityDataManager.updatePartyLvRank(partyData);

        handler.sendMsgToPlayer(DonateAllPartyScienceRs.ext, builder.build());
        // 军团贡献增加记录日志
        LogLordHelper.contribution(AwardFrom.DONATE_SCIENCE, player.account, player.lord, member.getDonate(), member.getWeekAllDonate(),
                build);

    }

    /**
     * Function:捐献
     *
     * @param req
     * @param handler
     */
    public void donateScience(DonateScienceRq req, ClientHandler handler) {
        int scienceId = req.getScienceId();
        if (!staticPartyDataMgr.getScienceMap().containsKey(scienceId)) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }

        Member member = partyDataManager.getMemberById(handler.getRoleId());
        if (member == null || member.getPartyId() == 0) {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }

        int partyId = member.getPartyId();
        PartyData partyData = partyDataManager.getParty(partyId);
        if (partyData == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }

        partyDataManager.refreshPartyData(partyData);
        partyDataManager.refreshMember(member);
        long roleId = handler.getRoleId();
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }

        Resource resource = player.resource;
        Lord lord = player.lord;
        int resourceId = req.getResouceId();
        if (resourceId < 1 || resourceId > 6) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }

        PartyDonate partyDonate = member.getScienceMine();
        int count = partyDataManager.getDonateMember(partyDonate, resourceId);
        StaticPartyContribute staContribute = staticPartyDataMgr.getStaticContribute(resourceId, count + 1);
        if (staContribute == null) {
            handler.sendErrorMsgToPlayer(GameError.DONATE_COUNT);
            return;
        }

        long hadResource = getResource(resourceId, resource, lord);
        float discount = activityDataManager.discountDonate(resourceId);
        int price = (int) (discount * staContribute.getPrice() / 100f);

        if (hadResource < price) {
            handler.sendErrorMsgToPlayer(GameError.RESOURCE_NOT_ENOUGH);
            return;
        }

        // 添加科技技能
        Map<Integer, PartyScience> scienceMap = partyData.getSciences();
        PartyScience science = scienceMap.get(scienceId);
        if (science == null) {
            science = new PartyScience();
            science.setScienceId(scienceId);
            science.setScienceLv(0);
            science.setSchedule(0);
            scienceMap.put(scienceId, science);
        }

        int build = staContribute.getBuild();
        StaticPartyScience staticScience = staticPartyDataMgr.getPartyScience(scienceId, science.getScienceLv() + 1);

        if (staticScience == null) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }

        // 科技等级
        int scienceLv = partyData.getScienceLv();
        if (scienceLv < science.getScienceLv()) {
            handler.sendErrorMsgToPlayer(GameError.SCIENCE_LV_ERROR);
            return;
        }

        int maxSchedule = staticScience.getSchedule();
        if (scienceLv == science.getScienceLv() && science.getSchedule() >= maxSchedule) {
            handler.sendErrorMsgToPlayer(GameError.SCIENCE_LV_ERROR);
            return;
        }

        int addBuild = activityDataManager.fireSheet(player, partyId, build);// 基础*活动系数

        if (partyDonate.getCopper() == 0 && partyDonate.getGold() == 0 && partyDonate.getIron() == 0 && partyDonate.getOil() == 0
                && partyDonate.getSilicon() == 0 && partyDonate.getStone() == 0) {

            build = staContribute.getBuild() * staticPartyDataMgr.getPartyLiveBuild(partyData.getLively());// 每日
            // 基础*首次系数
        }
        if (staContribute.getBuild() != build) {// 有首次
            build += addBuild;
        } else {
            build = addBuild;
        }
        int schedule = science.getSchedule() + build;
        if (scienceLv == science.getScienceLv()) {
            schedule = schedule > maxSchedule ? maxSchedule : schedule;
        }

        List<Long> donates = partyData.getDonates(2);
        if (donates == null) {
            donates = new ArrayList<Long>();
            donates.add(roleId);
            partyData.putDonates(2, donates);
            science.setSchedule(schedule);
        } else {
            int index = donates.indexOf(roleId);
            if (index == -1) {
                int lvNum = staticPartyDataMgr.getLvNum(partyData.getPartyLv());
                if (donates.size() < lvNum + 6) {
                    donates.add(roleId);
                    science.setSchedule(schedule);
                }
            } else {
                science.setSchedule(schedule);
            }
        }

        if (scienceLv > science.getScienceLv() && science.getSchedule() >= maxSchedule) {
            science.setScienceLv(science.getScienceLv() + 1);
            schedule = science.getSchedule() - maxSchedule;
            schedule = schedule < 0 ? 0 : schedule;
            science.setSchedule(schedule);
            // 军团科技升级，更新工会所有成员的玩家最强实力
            List<Member> members = partyDataManager.getMemberList(partyId);
            for (Member mbr : members) {
                Player mbrp = playerDataManager.getPlayer(mbr.getLordId());
                if (mbrp != null) {
                    playerEventService.calcStrongestFormAndFight(mbrp);
                }
            }
        }

        DonateScienceRs.Builder builder = DonateScienceRs.newBuilder();
        builder.setScience(PbHelper.createPartySciencePb(science));
        if (resourceId == PartyType.RESOURCE_STONE) {
            partyDonate.setStone(count + 1);
            playerDataManager.modifyStone(player, -staContribute.getPrice(), AwardFrom.DONATE_SCIENCE);
            builder.setStone(resource.getStone());
            activityDataManager.updActivity(player, ActivityConst.ACT_PARTY_DONATE, 1, 2);
        } else if (resourceId == PartyType.RESOURCE_IRON) {
            partyDonate.setIron(count + 1);
            playerDataManager.modifyIron(player, -staContribute.getPrice(), AwardFrom.DONATE_SCIENCE);
            builder.setIron(resource.getIron());
            activityDataManager.updActivity(player, ActivityConst.ACT_PARTY_DONATE, 1, 2);
        } else if (resourceId == PartyType.RESOURCE_SILICON) {
            partyDonate.setSilicon(count + 1);
            playerDataManager.modifySilicon(player, -staContribute.getPrice(), AwardFrom.DONATE_SCIENCE);
            builder.setSilicon(resource.getSilicon());
            activityDataManager.updActivity(player, ActivityConst.ACT_PARTY_DONATE, 1, 2);
        } else if (resourceId == PartyType.RESOURCE_COPPER) {
            partyDonate.setCopper(count + 1);
            playerDataManager.modifyCopper(player, -staContribute.getPrice(), AwardFrom.DONATE_SCIENCE);
            builder.setCopper(resource.getCopper());
            activityDataManager.updActivity(player, ActivityConst.ACT_PARTY_DONATE, 1, 2);
        } else if (resourceId == PartyType.RESOURCE_OIL) {
            partyDonate.setOil(count + 1);
            playerDataManager.modifyOil(player, -staContribute.getPrice(), AwardFrom.DONATE_SCIENCE);
            builder.setOil(resource.getOil());
            activityDataManager.updActivity(player, ActivityConst.ACT_PARTY_DONATE, 1, 2);
        } else if (resourceId == PartyType.RESOURCE_GOLD) {
            partyDonate.setGold(count + 1);
            playerDataManager.subGold(player, price, AwardFrom.DONATE_SCIENCE);
            builder.setGold(player.lord.getGold());
            activityDataManager.updActivity(player, ActivityConst.ACT_PARTY_DONATE, 1, 3);
        }

        PartyDataManager.doPartyLivelyTask(partyData, member, PartyType.TASK_DONATE);

        playerDataManager.updTask(player, TaskType.COND_PARTY_DONATE, 1, null);

        member.setDonate(member.getDonate() + addBuild);
        member.setWeekDonate(member.getWeekDonate() + addBuild);
        // 之前代码一直是 + count，感觉应该是错的，但游戏中似乎没有用到这个字段，所以一直没出问题
        // member.setWeekAllDonate(member.getWeekAllDonate() + count);
        member.setWeekAllDonate(member.getWeekAllDonate() + addBuild);

        activityDataManager.updatePartyLvRank(partyData);
        // 军团贡献增加记录日志
        LogLordHelper.contribution(AwardFrom.DONATE_SCIENCE, player.account, player.lord, member.getDonate(), member.getWeekAllDonate(),
                addBuild);
        handler.sendMsgToPlayer(DonateScienceRs.ext, builder.build());
    }

    /**
     * GM修改军团科技等级
     *
     * @param partyName
     * @param scienceId
     * @param lv        void
     */
    public void gmSetPartyScienceLv(String partyName, int scienceId, int lv) {
        StaticPartyScience staticScience = staticPartyDataMgr.getPartyScience(scienceId, lv);
        if (null == staticScience) {
            return;
        }

        PartyData partyData = partyDataManager.getParty(partyName);
        if (null == partyData) {
            return;
        }

        Map<Integer, PartyScience> scienceMap = partyData.getSciences();
        PartyScience science = scienceMap.get(scienceId);
        if (science == null) {
            science = new PartyScience();
            science.setScienceId(scienceId);
            science.setSchedule(0);
            scienceMap.put(scienceId, science);
        }
        science.setScienceLv(lv);
    }

    /**
     * 搜索军团
     *
     * @param req
     * @param handler void
     */
    public void seachParty(SeachPartyRq req, ClientHandler handler) {
        String partyName = req.getPartyName();
        PartyRank partyRank = partyDataManager.getPartyRankByName(partyName);
        if (partyRank == null) {
            handler.sendErrorMsgToPlayer(GameError.PARTY_NOT_EXIST);
            return;
        }

        SeachPartyRs.Builder builder = SeachPartyRs.newBuilder();
        PartyData partyData = partyDataManager.getParty(partyRank.getPartyId());
        int count = partyDataManager.getPartyMemberCount(partyRank.getPartyId());
        builder.setPartyRank(PbHelper.createPartyRankPb(partyRank, partyData, count));
        handler.sendMsgToPlayer(SeachPartyRs.ext, builder.build());
    }

    /**
     * 玩家申请的军团列表
     *
     * @param handler void
     */
    public void applyList(ClientHandler handler) {
        Member member = partyDataManager.getMemberById(handler.getRoleId());
        if (member == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }

        ApplyListRs.Builder builder = ApplyListRs.newBuilder();
        if (member.getPartyId() != 0) {
            handler.sendMsgToPlayer(ApplyListRs.ext, builder.build());
            return;
        }

        if (member.getApplyList() != null) {
            String applyList = member.getApplyList();
            String[] applyIds = applyList.split("\\|");
            for (String e : applyIds) {
                if (e == null || e.equals("") || e.startsWith("null") || e.endsWith("null")) {
                    continue;
                }
                builder.addPartyId(Integer.valueOf(e));
            }
        }
        handler.sendMsgToPlayer(ApplyListRs.ext, builder.build());
    }

    /**
     * Function:取消申请
     *
     * @param req
     * @param handler
     */
    public void cannlyApplyRq(CannlyApplyRq req, ClientHandler handler) {
        long roleId = handler.getRoleId();
        int partyId = req.getPartyId();
        Member member = partyDataManager.getMemberById(handler.getRoleId());
        if (member == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }
        if (member.getPartyId() != 0) {
            handler.sendErrorMsgToPlayer(GameError.PARTY_HAD);
            return;
        }
        PartyData partyData = partyDataManager.getParty(partyId);
        if (partyData == null) {
            handler.sendErrorMsgToPlayer(GameError.PARTY_NOT_EXIST);
            return;
        }
        ApplyListRs.Builder builder = ApplyListRs.newBuilder();
        String applyList = member.getApplyList();
        member.setApplyList(applyList.replace(partyId + "|", ""));
        Iterator<PartyApply> it = partyData.getApplys().values().iterator();
        while (it.hasNext()) {
            if (it.next().getLordId() == roleId) {
                it.remove();
                break;
            }
        }
        handler.sendMsgToPlayer(ApplyListRs.ext, builder.build());
        // 异步通知军团长,副军团
        Map<Long, PartyApply> applys = partyData.getApplys();
        if (applys != null) {
            playerDataManager.synApplyPartyToPlayer(partyId, applys.size());
        }
    }

    /**
     * Function：获取军团动态
     *
     * @param req
     * @param handler
     */
    public void getPartyTrendRq(GetPartyTrendRq req, ClientHandler handler) {
        int page = req.getPage();
        int type = req.getType();
        long roleId = handler.getRoleId();
        Member member = partyDataManager.getMemberById(roleId);
        if (member == null || member.getPartyId() == 0) {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }

        int partyId = member.getPartyId();
        PartyData partyData = partyDataManager.getParty(partyId);
        if (partyData == null) {
            handler.sendErrorMsgToPlayer(GameError.PARTY_NOT_EXIST);
            return;
        }

        GetPartyTrendRs.Builder builder = GetPartyTrendRs.newBuilder();
        List<Trend> trendList = partyData.getTrends();
        if (trendList == null || trendList.size() <= 0) {
            handler.sendMsgToPlayer(GetPartyTrendRs.ext, builder.build());
            return;
        }

        int count = 0;
        int pages[] = {page * 20, (page + 1) * 20};
        ListIterator<Trend> it = trendList.listIterator(trendList.size());
        while (it.hasPrevious()) {
            Trend trend = it.previous();
            int trendId = trend.getTrendId();
            StaticPartyTrend staticTrend = staticPartyDataMgr.getPartyTrend(trendId);
            if (staticTrend == null || staticTrend.getType() != type) {
                continue;
            }
            if (count >= pages[0]) {
                List<TrendParam> manList = new ArrayList<>();
                List<TrendParam> trendParamList = getTrendParam(partyData, trend);
                if (trendParamList == null) {
                    continue;
                }
                for (TrendParam e : trendParamList) {
                    TrendParam trendParam = new TrendParam();
                    trendParam.setContent(e.getContent());
                    if (e.getMan() != null) {
                        trendParam.setMan(e.getMan());
                    }
                    manList.add(trendParam);
                }
                builder.addTrend(PbHelper.createTrendPb(trend, manList));
            }
            count++;
            if (count >= pages[1]) {
                break;
            }
        }
        handler.sendMsgToPlayer(GetPartyTrendRs.ext, builder.build());
    }

    /**
     * Function:设置公告
     *
     * @param req
     * @param handler
     */
    public void sloganParty(SloganPartyRq req, ClientHandler handler) {
        int type = req.getType();
        String slogan = req.getSlogan();
        Member member = partyDataManager.getMemberById(handler.getRoleId());
        if (member != null && member.getPartyId() == 0) {
            handler.sendErrorMsgToPlayer(GameError.PARTY_HAD);
            return;
        }
        if (member.getJob() < PartyType.LEGATUS_CP) {
            handler.sendErrorMsgToPlayer(GameError.AUTHORITY_ERR);
            return;
        }

        if (slogan == null || slogan.length() >= 30) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }

        slogan = EmojiHelper.filterEmoji(slogan);

        // if (EmojiHelper.containsEmoji(slogan)) {
        // handler.sendErrorMsgToPlayer(GameError.INVALID_CHAR);
        // return;
        // }

        int partyId = member.getPartyId();
        PartyData partyData = partyDataManager.getParty(partyId);
        if (type == 1) {
            partyData.setInnerSlogan(slogan);
        } else {
            partyData.setSlogan(slogan);
        }

        SloganPartyRs.Builder builder = SloganPartyRs.newBuilder();
        handler.sendMsgToPlayer(SloganPartyRs.ext, builder.build());
    }

    /**
     * Function：军团成员主动升职，抢军团长，抢副团长
     *
     * @param req
     * @param handler
     */
    public void upMemberJob(UpMemberJobRq req, ClientHandler handler) {
        int job = req.getJob();
        if (job != PartyType.LEGATUS && job != PartyType.LEGATUS_CP) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }

        Member member = partyDataManager.getMemberById(handler.getRoleId());
        if (member != null && member.getPartyId() == 0) {
            handler.sendErrorMsgToPlayer(GameError.PARTY_HAD);
            return;
        }

        int partyId = member.getPartyId();
        PartyData partyData = partyDataManager.getParty(partyId);
        boolean flag = upJob(partyData, member, job);
        if (!flag) {
            handler.sendErrorMsgToPlayer(GameError.UP_JOB_FAIL);
            return;
        }

        UpMemberJobRs.Builder builder = UpMemberJobRs.newBuilder();
        builder.setJob(member.getJob());
        handler.sendMsgToPlayer(UpMemberJobRs.ext, builder.build());
    }

    /**
     * Function：对帮主和副帮主职位变动需要调用此方法
     *
     * @param partyData
     * @param member
     * @param job
     * @return
     */
    private boolean upJob(PartyData partyData, Member member, int job) {
        List<Member> memberList = partyDataManager.getMemberList(member.getPartyId());
        if (memberList == null || memberList.size() == 0) {
            return false;
        }

        int flag = 0;
        Iterator<Member> it = memberList.iterator();
        Date now = new Date();
        while (it.hasNext()) {
            Member next = it.next();
            if (next.getJob() == job) {
                Player player = playerDataManager.getPlayer(next.getLordId());
                Date loginDate = DateHelper.getTimeZoneDate(player.lord.getOnTime());
                int dayiy = DateHelper.dayiy(loginDate, now);
                if (dayiy < 16) {
                    flag++;
                } else {// 如果有帮主或副帮主15天未登陆,则降为普通帮众
                    next.setJob(PartyType.COMMON);
                }
            }
        }

        if (job == PartyType.LEGATUS && flag == 0) {
            Player player = playerDataManager.getPlayer(member.getLordId());
            partyData.setLegatusName(player.lord.getNick());
            member.setJob(PartyType.LEGATUS);
            chatService.sendPartyChat(chatService.createSysChat(SysChatId.PARTY_LEADER, player.lord.getNick()), partyData.getPartyId());
            return true;
        } else if (job == PartyType.LEGATUS_CP && flag < 2) {
            member.setJob(PartyType.LEGATUS_CP);
            Player player = playerDataManager.getPlayer(member.getLordId());
            chatService.sendPartyChat(chatService.createSysChat(SysChatId.PARTY_VICE_LEADER, player.lord.getNick()),
                    partyData.getPartyId());
            return true;
        }

        return false;
    }

    /**
     * Function：清理,踢出帮派成员
     *
     * @param req
     * @param handler
     */
    public void cleanMemberRq(CleanMemberRq req, ClientHandler handler) {
        long lordId = req.getLordId();
        Member member = partyDataManager.getMemberById(handler.getRoleId());
        PartyData partyData = member != null ? partyDataManager.getParty(member.getPartyId()) : null;
        if (partyData == null) {
            handler.sendErrorMsgToPlayer(GameError.PARTY_HAD);
            return;
        }

        if (member.getJob() < PartyType.LEGATUS) {
            handler.sendErrorMsgToPlayer(GameError.AUTHORITY_ERR);
            return;
        }

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }

        int partyId = member.getPartyId();
        Member cleanMember = partyDataManager.getMemberById(lordId);
        if (cleanMember == null || cleanMember.getPartyId() != partyId) {
            handler.sendErrorMsgToPlayer(GameError.AUTHORITY_ERR);
            return;
        }

        int count = partyDataManager.getPartyMemberCount(partyId);
        if (count <= 1) {
            handler.sendErrorMsgToPlayer(GameError.PARTY_HAD);
            return;
        }

        if (partyDataManager.inWar(cleanMember)) {
            handler.sendErrorMsgToPlayer(GameError.IN_WAR);
            return;
        }

        Player cleanPlayer = playerDataManager.getPlayer(cleanMember.getLordId());
        // PartyData party =
        // partyDataManager.getPartyByLordId(cleanPlayer.roleId);
        // if (party != null) {
        // party.setScore(party.getScore() - cleanPlayer.seniorScore);
        // mineDataManager.setPartyScoreRank(party);
        // }

        if (cleanPlayer.isExistFortressArmy()) {
            handler.sendErrorMsgToPlayer(GameError.Is_In_Fortress);
            return;
        }

        GameError error = airshipService.quitPartyAirshipCheck(cleanPlayer, partyData);
        if (error != null) {
            handler.sendErrorMsgToPlayer(error);
            return;
        }

        // 若在跨服军团战期间,报名了的不能退出军团
        if (TimeHelper.isCrossOpen(CrossConst.CrossPartyType)) {
            CCCanQuitPartyRq.Builder builder = CCCanQuitPartyRq.newBuilder();
            builder.setRoleId(handler.getRoleId());
            builder.setType(2);
            builder.setCleanRoleId(req.getLordId());
            handler.sendMsgToCrossServer(CCCanQuitPartyRq.EXT_FIELD_NUMBER, CCCanQuitPartyRq.ext, builder.build());
        } else {
            partyDataManager.quitParty(partyId, cleanMember);

            String lordId1 = String.valueOf(lordId);
            String lordIdJ = String.valueOf(handler.getRoleId());
            partyDataManager.addPartyTrend(partyId, 3, lordId1, lordIdJ);

            playerDataManager.sendNormalMail(cleanPlayer, MailType.MOLD_CLEAN_MEMBER, TimeHelper.getCurrentSecond(), player.lord.getNick());
            playerDataManager.synPartyOutToPlayer(cleanPlayer, partyId);

            CleanMemberRs.Builder builder = CleanMemberRs.newBuilder();
            handler.sendMsgToPlayer(CleanMemberRs.ext, builder.build());

            worldService.retreatAllGuard(cleanPlayer);

            chatService.sendPartyChat(chatService.createSysChat(SysChatId.PARTY_TICK, cleanPlayer.lord.getNick(), player.lord.getNick()),
                    partyId);

            altarBossService.resetBossAutoFight(partyId, handler.getRoleId());// 重置祭坛BOSS自动战斗状态

            airshipService.afterQuitParty(cleanPlayer, partyData);
            // 更新玩家最强实力
            playerEventService.calcStrongestFormAndFight(cleanPlayer);
        }
    }

    /**
     * Function：军团长让位
     *
     * @param req
     * @param handler
     */
    public void concedeJobRq(ConcedeJobRq req, ClientHandler handler) {
        long lordId = req.getLordId();
        Player mplayer = playerDataManager.getPlayer(handler.getRoleId());
        if (mplayer == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }

        Member member = partyDataManager.getMemberById(handler.getRoleId());
        if (member == null || member.getPartyId() == 0) {
            handler.sendErrorMsgToPlayer(GameError.PARTY_HAD);
            return;
        }

        if (member.getJob() != PartyType.LEGATUS) {
            handler.sendErrorMsgToPlayer(GameError.AUTHORITY_ERR);
            return;
        }

        int partyId = member.getPartyId();
        Member concedeMember = partyDataManager.getMemberById(lordId);
        if (concedeMember == null || concedeMember.getPartyId() != partyId) {
            handler.sendErrorMsgToPlayer(GameError.AUTHORITY_ERR);
            return;
        }

        PartyData partyData = partyDataManager.getParty(partyId);
        if (partyData == null) {
            handler.sendErrorMsgToPlayer(GameError.PARTY_NOT_EXIST);
            return;
        }

        Player player = playerDataManager.getPlayer(concedeMember.getLordId());
        if (player == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }

        String legatusName = player.lord.getNick();
        member.setJob(PartyType.COMMON);
        concedeMember.setJob(PartyType.LEGATUS);
        partyData.setLegatusName(legatusName);

        playerDataManager.sendMailToParty(partyId, MailType.MOLD_CONCEDE, mplayer.lord.getNick(), legatusName);

        CleanMemberRs.Builder builder = CleanMemberRs.newBuilder();
        handler.sendMsgToPlayer(CleanMemberRs.ext, builder.build());

        chatService.sendPartyChat(chatService.createSysChat(SysChatId.PARTY_LEADER, player.lord.getNick()), partyId);
    }

    /**
     * 判断军团名是否存在 Method: isExistPartyName
     *
     * @Description: @param partyName @return @return boolean @throws
     */
    public boolean isExistPartyName(String partyName) {
        return partyDataManager.isExistPartyName(partyName);
    }

    /**
     * Method: 军团改名
     *
     * @Description: @param player @param param @return void @throws
     */
    public void rename(int partyId, String partyName, ClientHandler handler) {
        if (partyDataManager.isExistPartyName(partyName)) {
            handler.sendErrorMsgToPlayer(GameError.SAME_PARTY_NAME);
            return;
        }

        // 改名
        PartyData partyData = partyDataManager.getParty(partyId);
        partyDataManager.rename(partyData, partyName);

        // 发送邮件
        playerDataManager.sendMailToParty(partyId, MailType.MOLD_PARTY_NAME_CHAGE, partyName);

        // 发送帮派聊天信息
        chatService.sendPartyChat(chatService.createSysChat(SysChatId.PARTY_NAME_CHANGE, partyName), partyId);
    }

    /**
     * Function：任命职位
     *
     * @param req
     * @param handler
     */
    public void setMemberJobRq(SetMemberJobRq req, ClientHandler handler) {
        long lordId = req.getLordId();
        int job = req.getJob();
        if (job != PartyType.COMMON && job != PartyType.LEGATUS_CP && job != PartyType.JOB1 && job != PartyType.JOB2
                && job != PartyType.JOB3 && job != PartyType.JOB4) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }

        Member member = partyDataManager.getMemberById(handler.getRoleId());
        if (member != null && member.getPartyId() == 0) {
            handler.sendErrorMsgToPlayer(GameError.PARTY_HAD);
            return;
        }

        if (member.getJob() != PartyType.LEGATUS) {
            handler.sendErrorMsgToPlayer(GameError.AUTHORITY_ERR);
            return;
        }

        int partyId = member.getPartyId();
        Member setMember = partyDataManager.getMemberById(lordId);
        if (setMember == null || setMember.getPartyId() != partyId) {
            handler.sendErrorMsgToPlayer(GameError.AUTHORITY_ERR);
            return;
        }

        if (job == PartyType.LEGATUS_CP) {
            int count = partyDataManager.getMemberJobCount(partyId, job);

            // 任命职位达到上限
            if (count >= PartyType.LEGATUS_CP_MAX_COUNT) {
                handler.sendErrorMsgToPlayer(GameError.Fortress_Job_Is_Full);
                return;
            }

            setMember.setJob(job);
            partyDataManager.addPartyTrend(partyId, 6, String.valueOf(lordId));

            Player player = playerDataManager.getPlayer(lordId);
            chatService.sendPartyChat(chatService.createSysChat(SysChatId.PARTY_VICE_LEADER, player.lord.getNick()),
                    setMember.getPartyId());
        } else if (job == PartyType.JOB1 || job == PartyType.JOB2 || job == PartyType.JOB3 || job == PartyType.JOB4) {
            int count = partyDataManager.getMemberJobCount(partyId, job);
            if (count < 3) {
                setMember.setJob(job);
                partyDataManager.addPartyTrend(partyId, 4, String.valueOf(lordId), String.valueOf(job));
                Player player = playerDataManager.getPlayer(lordId);
                chatService.sendPartyChat(chatService.createSysChat(SysChatId.PARTY_JOB, player.lord.getNick(), String.valueOf(job)),
                        setMember.getPartyId());
            }
        } else {
            setMember.setJob(job);
            partyDataManager.addPartyTrend(partyId, 4, String.valueOf(lordId), String.valueOf(job));
        }
        SetMemberJobRs.Builder builder = SetMemberJobRs.newBuilder();
        builder.setJob(setMember.getJob());
        handler.sendMsgToPlayer(SetMemberJobRs.ext, builder.build());
    }

    /**
     * Function：军团职位情况
     *
     * @param handler
     */
    public void partyJobCount(ClientHandler handler) {
        Member member = partyDataManager.getMemberById(handler.getRoleId());
        if (member != null && member.getPartyId() == 0) {
            handler.sendErrorMsgToPlayer(GameError.PARTY_HAD);
            return;
        }
        int partyId = member.getPartyId();
        int cpcount = partyDataManager.getMemberJobCount(partyId, PartyType.LEGATUS_CP);
        int countJob1 = partyDataManager.getMemberJobCount(partyId, PartyType.JOB1);
        int countJob2 = partyDataManager.getMemberJobCount(partyId, PartyType.JOB2);
        int countJob3 = partyDataManager.getMemberJobCount(partyId, PartyType.JOB3);
        int countJob4 = partyDataManager.getMemberJobCount(partyId, PartyType.JOB4);
        PartyJobCountRs.Builder builder = PartyJobCountRs.newBuilder();
        builder.setJob1(countJob1);
        builder.setJob2(countJob2);
        builder.setJob3(countJob3);
        builder.setJob4(countJob4);
        builder.setCpLegatus(cpcount);
        handler.sendMsgToPlayer(PartyJobCountRs.ext, builder.build());
    }

    /**
     * Function：军团申请条件编辑
     *
     * @param handler
     */
    public void partyApplyEditRq(PartyApplyEditRq req, ClientHandler handler) {
        int applyType = req.getApplyType();
        int applyLv = req.getApplyLv();
        long fight = req.getFight();
        String slogan = req.getSlogan();
        Member member = partyDataManager.getMemberById(handler.getRoleId());
        if (member != null && member.getPartyId() == 0) {
            handler.sendErrorMsgToPlayer(GameError.PARTY_HAD);
            return;
        }
        if (member.getJob() != PartyType.LEGATUS) {
            handler.sendErrorMsgToPlayer(GameError.AUTHORITY_ERR);
            return;
        }

        if (slogan == null || slogan.length() >= 80) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }

        // if (EmojiHelper.containsEmoji(slogan)) {
        // handler.sendErrorMsgToPlayer(GameError.INVALID_CHAR);
        // return;
        // }

        slogan = EmojiHelper.filterEmoji(slogan);

        int partyId = member.getPartyId();
        PartyData partyData = partyDataManager.getParty(partyId);
        partyData.setApply(applyType);
        partyData.setApplyLv(applyLv);
        partyData.setApplyFight(fight);
        partyData.setSlogan(slogan);
        PartyApplyEditRs.Builder builder = PartyApplyEditRs.newBuilder();
        handler.sendMsgToPlayer(PartyApplyEditRs.ext, builder.build());
    }

    /**
     * Function: 获取军团副本信息
     *
     * @param handler
     */
    public void getPartyCombat(ClientHandler handler) {
        Member member = partyDataManager.getMemberById(handler.getRoleId());
        if (member == null || member.getPartyId() == 0) {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }

        int partyId = member.getPartyId();
        PartyData partyData = partyDataManager.getParty(partyId);
        if (partyData == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }

        partyDataManager.refreshPartyData(partyData);
        partyDataManager.refreshMember(member);

        GetPartyCombatRs.Builder builder = GetPartyCombatRs.newBuilder();
        Map<Integer, PartyCombat> pctMap = partyData.getPartyCombats();
        Iterator<PartyCombat> it = pctMap.values().iterator();
        while (it.hasNext()) {
            PartyCombat partyCombat = (PartyCombat) it.next();
            builder.addPartyCombat(PbHelper.createPartyCombatInfoPb(partyCombat));
        }

        int count = 5 - member.getCombatCount();
        count = count < 0 ? 0 : count;

        builder.setCount(count);
        builder.addAllGetAward(member.getCombatIds());
        handler.sendMsgToPlayer(GetPartyCombatRs.ext, builder.build());
        return;
    }

    /**
     * 点击军团副本中一个关卡的协议处理
     *
     * @param combatId
     * @param handler  void
     */
    public void ptcForm(int combatId, ClientHandler handler) {
        Member member = partyDataManager.getMemberById(handler.getRoleId());
        if (member == null || member.getPartyId() == 0) {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }

        int partyId = member.getPartyId();
        PartyData partyData = partyDataManager.getParty(partyId);
        if (partyData == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }

        StaticPartyCombat staticPartyCombat = staticPartyDataMgr.getPartyCombat(combatId);
        if (staticPartyCombat == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }

        partyDataManager.refreshPartyData(partyData);
        partyDataManager.refreshMember(member);

        PtcFormRs.Builder builder = PtcFormRs.newBuilder();

        Map<Integer, PartyCombat> pctMap = partyData.getPartyCombats();
        PartyCombat partyCombat = pctMap.get(combatId);
        if (partyCombat == null) {
            partyCombat = createPartyCombat(staticPartyCombat);
            pctMap.put(combatId, partyCombat);
        } else {
            if (partyCombat.getSchedule() >= 100) {
                builder.setState(1);
                handler.sendMsgToPlayer(PtcFormRs.ext, builder.build());
                return;
            }
        }

        builder.setState(0);
        builder.setForm(PbHelper.createFormPb(partyCombat.getForm()));
        handler.sendMsgToPlayer(PtcFormRs.ext, builder.build());
    }

    /**
     * 创建关卡对象
     *
     * @param staticPartyCombat
     * @return PartyCombat
     */
    private PartyCombat createPartyCombat(StaticPartyCombat staticPartyCombat) {
        PartyCombat partyCombat = new PartyCombat(staticPartyCombat.getCombatId(), 0);
        partyCombat.setForm(PbHelper.createForm(staticPartyCombat.getForm()));
        return partyCombat;
    }

    /**
     * 战斗后把阵型中被杀掉的兵力减掉
     *
     * @param form
     * @param fighter void
     */
    private void haustNpcTank(Form form, Fighter fighter) {
        int killed = 0;
        for (int i = 0; i < fighter.forces.length; i++) {
            Force force = fighter.forces[i];
            if (force != null) {
                killed = force.killed;
                if (killed > 0) {
                    form.c[i] = form.c[i] - killed;
                }
            }
        }
    }

    /**
     * 计算进度
     *
     * @param form
     * @param staticPartyCombat
     * @return int
     */
    private int calcSchedule(Form form, StaticPartyCombat staticPartyCombat) {
        int cur = form.c[0] + form.c[1] + form.c[2] + form.c[3] + form.c[4] + form.c[5];
        int total = staticPartyCombat.getTotalTank();
        return (int) ((total - cur) * 100.0f / total);
    }

    /**
     * Function： 打军团副本
     *
     * @param req
     * @param handler
     */
    public void doPartyCombat(DoPartyCombatRq req, ClientHandler handler) {
        Member member = partyDataManager.getMemberById(handler.getRoleId());
        if (member == null || member.getPartyId() == 0) {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }

        //		if (member.getCombatCount() >= 5) {
        //			handler.sendErrorMsgToPlayer(GameError.COUNT_NOT_ENOUGH);
        //			return;
        //		}

        int partyId = member.getPartyId();
        PartyData partyData = partyDataManager.getParty(partyId);
        if (partyData == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }

        int combatId = req.getCombatId();
        StaticPartyCombat staticPct = staticPartyDataMgr.getPartyCombat(combatId);
        if (staticPct == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }

        Map<Integer, PartyCombat> pctMap = partyData.getPartyCombats();
        PartyCombat partyCombat = pctMap.get(combatId);
        if (partyCombat == null) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }

        if (partyCombat.getSchedule() >= 100) {
            handler.sendErrorMsgToPlayer(GameError.COMBAT_PASS);
            return;
        }

        CommonPb.Form form = req.getForm();
        Form attackForm = PbHelper.createForm(form);
        StaticHero staticHero = null;
        int heroId = 0;
        AwakenHero awakenHero = null;
        Hero hero = null;
        if (attackForm.getAwakenHero() != null) {// 使用觉醒将领
            awakenHero = player.awakenHeros.get(attackForm.getAwakenHero().getKeyId());
            if (awakenHero == null || awakenHero.isUsed()) {
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

        if (heroId != 0) {
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
        //战术验证
        if (!attackForm.getTactics().isEmpty()) {
            boolean checkUseTactics = tacticsService.checkUseTactics(player, attackForm);
            if (!checkUseTactics) {
                handler.sendErrorMsgToPlayer(GameError.USE_TACTICS_ERROR);
                return;
            }
        }
        // 玩家打军团副本数
        member.setCombatCount(member.getCombatCount() + 1);

        Fighter attacker = fightService.createFighter(player, attackForm, AttackType.ACK_COMBIT);
        Fighter npc = fightService.createFighter(partyCombat.getForm(), staticPct);

        FightLogic fightLogic = new FightLogic(attacker, npc, FirstActType.ATTACKER, true);
        fightLogic.packForm(attackForm, partyCombat.getForm());

        fightLogic.fight();

        haustNpcTank(partyCombat.getForm(), npc);

        DoPartyCombatRs.Builder builder = DoPartyCombatRs.newBuilder();
        CommonPb.Record record = fightLogic.generateRecord();
        int result = -1;
        if (fightLogic.getWinState() == 1) {
            result = fightLogic.estimateStar();
        }

        builder.setResult(result);
        builder.setRecord(record);

        int originSchedule = partyCombat.getSchedule();
        if (result > 0) {
            partyCombat.setSchedule(100);
            List<List<Integer>> awardList = staticPct.getLastAward();
            for (List<Integer> e : awardList) {
                int type = e.get(0);
                int id = e.get(1);
                int count = e.get(2);
                int keyId = playerDataManager.addAward(player, type, id, count, AwardFrom.PARTY_COMBAT);
                if (type == AwardType.PARTY_BUILD) {
                    builder.setBuild(count);
                } else {
                    builder.addAward(PbHelper.createAwardPb(type, id, count, keyId));
                }
            }
            partyDataManager.addPartyTrend(partyId, 10, String.valueOf(handler.getRoleId()), staticPct.getName());
        } else {
            int schedule = calcSchedule(partyCombat.getForm(), staticPct);
            if (schedule == 100) {
                schedule = 99;
            }
            partyCombat.setSchedule(schedule);
        }

        List<List<Integer>> awardList = staticPct.getDrop();
        for (List<Integer> e : awardList) {
            int type = e.get(0);
            int id = e.get(1);
            int count = e.get(2);
            int keyId = playerDataManager.addAward(player, type, id, count, AwardFrom.PARTY_COMBAT);
            builder.addAward(PbHelper.createAwardPb(type, id, count, keyId));
        }

        /*
         * 经验获得的逻辑：根据本次战斗结束后，关卡现有 npc坦克的数量/关卡初始坦克数量 得到一个进度值，与原先进度值相减，除以100 再乘以 配表经验 也就是根据本次战斗推进的副本进度百分比去 乘以
         * 配表经验。（如果本次进度不足10%，则按10%算） 但这里相减的顺序出错了，导致现在基本上无论成功或失败都是获得配表经验的10% ，上线时间很久了，经验数量不多，策划决定不改
         */
        int factor = originSchedule - partyCombat.getSchedule();
        if (factor < 10) {
            factor = 10;
        }

        int exp = (int) ((long) staticPct.getExp() * fightService.effectExpAdd(player) * factor / NumberHelper.HUNDRED_INT);
        playerDataManager.addExp(player, exp);

        playerDataManager.updTask(player, TaskType.COND_PARTY_COMBAT, 1, null);
        PartyDataManager.doPartyLivelyTask(partyData, member, PartyType.TASK_COMBAT);

        int realExp = playerDataManager.realExp(player, exp);
        builder.setExp(realExp);
        builder.setPartyCombat(PbHelper.createPartyCombatPb(partyCombat));
        handler.sendMsgToPlayer(DoPartyCombatRs.ext, builder.build());

        if (result > 0) {
            chatService.sendPartyChat(chatService.createSysChat(SysChatId.PARTY_COMBAT, player.lord.getNick(), String.valueOf(combatId)),
                    partyId);
        }
    }

    /**
     * 一键领取所有军团副本奖励
     *
     * @param handler
     */
    public void partyCombatAllAward(ClientHandler handler) {
        Member member = partyDataManager.getMemberById(handler.getRoleId());
        if (member == null || member.getPartyId() == 0) {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }

        int partyId = member.getPartyId();
        PartyData partyData = partyDataManager.getParty(partyId);
        if (partyData == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        GetAllPcbtAwardRs.Builder builder = GetAllPcbtAwardRs.newBuilder();

        // 需要消耗贡献度，可领取奖励关卡
        Map<Integer, PartyCombat> pcombats = new HashMap<>();
        // 所有奖励
        List<List<Integer>> allAwards = new ArrayList<>();
        // 所需总贡献度
        int contribute = 0;
        Map<Integer, PartyCombat> pctMap = partyData.getPartyCombats();
        Set<Integer> combatIds = member.getCombatIds();

        for (Entry<Integer, PartyCombat> entry : pctMap.entrySet()) {
            if (entry.getValue() == null || entry.getValue().getSchedule() != 100) {
                continue;
            }
            if (combatIds.contains(entry.getKey())) {
                continue;
            }
            StaticPartyCombat staticPct = staticPartyDataMgr.getPartyCombat(entry.getKey());
            if (staticPct == null) {
                handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
                return;
            }
            if (staticPct.getContribute() > 0) {
                contribute += staticPct.getContribute();
                pcombats.put(entry.getKey(), entry.getValue());
            } else {
                // 省点事，get(0)写死，不需要消耗贡献度领取的奖励都只配置了一项，不需要随机取值
                List<Integer> award = staticPct.getBox().get(0).subList(0, 3);
                allAwards.add(award);
                combatIds.add(entry.getKey());
            }
        }

        builder.setDonate(0);
        if (contribute > 0) {
            if (contribute > member.getDonate()) {
                builder.setDonate(-contribute);
            } else {
                builder.setDonate(contribute);
                member.setDonate(member.getDonate() - contribute);
                combatIds.addAll(pcombats.keySet());
                for (PartyCombat partyCombat : pcombats.values()) {
                    StaticPartyCombat staticPct = staticPartyDataMgr.getPartyCombat(partyCombat.getCombatId());
                    List<List<Integer>> box = staticPct.getBox();
                    int[] seeds = {0, 0};
                    for (List<Integer> e : box) {
                        if (e.size() < 4) {
                            continue;
                        }
                        seeds[0] += e.get(3);
                    }
                    seeds[0] = RandomHelper.randomInSize(seeds[0]);
                    for (List<Integer> e : box) {
                        if (e.size() < 4) {
                            continue;
                        }
                        seeds[1] += e.get(3);
                        if (seeds[0] <= seeds[1]) {
                            allAwards.add(e.subList(0, 3));
                            break;
                        }
                    }
                }
            }
        }
        if (combatIds.size() == 0 && contribute == 0) {
            handler.sendErrorMsgToPlayer(GameError.PARTY_COMBAT_NO_AWARD);
            return;
        }
        List<Award> backPb = playerDataManager.addAwardsBackPb(player, allAwards, AwardFrom.PARTY_COMBAT_BOX);
        builder.addAllCombatId(member.getCombatIds());
        builder.addAllAward(backPb);
        handler.sendMsgToPlayer(GetAllPcbtAwardRs.ext, builder.build());

    }

    /**
     * Function：军团副本奖励箱子领取
     *
     * @param req
     * @param handler
     */
    public void partyctAward(PartyctAwardRq req, ClientHandler handler) {
        Member member = partyDataManager.getMemberById(handler.getRoleId());
        if (member == null || member.getPartyId() == 0) {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }

        int partyId = member.getPartyId();
        PartyData partyData = partyDataManager.getParty(partyId);
        if (partyData == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }

        int combatId = req.getCombatId();
        Map<Integer, PartyCombat> pctMap = partyData.getPartyCombats();
        PartyCombat partyCombat = pctMap.get(combatId);
        if (partyCombat == null || partyCombat.getSchedule() != 100) {
            handler.sendErrorMsgToPlayer(GameError.PARTY_COMBAT_EXIST);
            return;
        }

        Set<Integer> combatIds = member.getCombatIds();
        if (combatIds.contains(combatId)) {
            handler.sendErrorMsgToPlayer(GameError.AWARD_HAD_GOT);
            return;
        }

        PartyctAwardRs.Builder builder = PartyctAwardRs.newBuilder();
        StaticPartyCombat staticPct = staticPartyDataMgr.getPartyCombat(combatId);
        if (staticPct == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }

        int contribute = staticPct.getContribute();
        if (contribute > 0) {
            if (contribute > member.getDonate()) {
                handler.sendErrorMsgToPlayer(GameError.DONATE_NOT_ENOUGH);
                return;
            }
            member.setDonate(member.getDonate() - contribute);
        }

        combatIds.add(combatId);

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        List<List<Integer>> box = staticPct.getBox();
        int[] seeds = {0, 0};
        for (List<Integer> e : box) {
            if (e.size() < 4) {
                continue;
            }
            seeds[0] += e.get(3);
        }
        seeds[0] = RandomHelper.randomInSize(seeds[0]);
        for (List<Integer> e : box) {
            if (e.size() < 4) {
                continue;
            }
            seeds[1] += e.get(3);
            if (seeds[0] <= seeds[1]) {
                int type = e.get(0);
                int id = e.get(1);
                int count = e.get(2);
                int keyId = playerDataManager.addAward(player, type, id, count, AwardFrom.PARTY_COMBAT_BOX);
                builder.addAward(PbHelper.createAwardPb(type, id, count, keyId));
                break;
            }
        }
        // 军团贡献消耗记录日志
        if (contribute > 0) {
            LogLordHelper.subContribution(AwardFrom.PARTY_COMBAT_BOX, player.account, player.lord, member.getDonate(),
                    member.getWeekAllDonate(), contribute);
        }
        playerDataManager.updTask(player, TaskType.COND_PARTY_BOX, 1, null);
        handler.sendMsgToPlayer(PartyctAwardRs.ext, builder.build());
    }

    /**
     * Function：军团活跃排名
     *
     * @param handler
     */
    public void getPartyLiveRank(ClientHandler handler) {
        Member member = partyDataManager.getMemberById(handler.getRoleId());
        if (member == null || member.getPartyId() == 0) {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }
        int partyId = member.getPartyId();
        if (partyId == 0) {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }
        PartyData partyData = partyDataManager.getParty(partyId);
        if (partyData == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }
        GetPartyLiveRankRs.Builder builder = GetPartyLiveRankRs.newBuilder();
        List<Member> memberList = partyDataManager.getMemberList(partyId);
        Iterator<Member> it = memberList.iterator();
        int today = TimeHelper.getCurrentDay();
        while (it.hasNext()) {
            Member next = it.next();
            long lordId = next.getLordId();
            Player player = playerDataManager.getPlayer(lordId);
            if (player == null) {
                continue;
            }
            Lord lord = player.lord;
            if (lord == null) {
                continue;
            }
            int live = next.getActivity();
            if (today != next.getRefreshTime()) {
                live = 0;
            }
            builder.addPartyLive(PbHelper.createPartyLivePb(lord, next.getJob(), live));
        }
        handler.sendMsgToPlayer(GetPartyLiveRankRs.ext, builder.build());
    }

    /**
     * Function：军团战事福利列表
     *
     * @param handler
     */
    public void getPartyAmyPropsRq(ClientHandler handler) {
        Member member = partyDataManager.getMemberById(handler.getRoleId());
        if (member == null || member.getPartyId() == 0) {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }
        int partyId = member.getPartyId();
        if (partyId == 0) {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }
        PartyData partyData = partyDataManager.getParty(partyId);
        if (partyData == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }
        GetPartyAmyPropsRs.Builder builder = GetPartyAmyPropsRs.newBuilder();

        Map<Integer, Prop> amyProps = partyData.getAmyProps();
        Iterator<Prop> it = amyProps.values().iterator();

        while (it.hasNext()) {
            Prop next = it.next();
            if (next.getCount() <= 0) {
                continue;
            }
            builder.addProp(PbHelper.createPropPb(next));
        }
        handler.sendMsgToPlayer(GetPartyAmyPropsRs.ext, builder.build());
    }

    /**
     * Function：发放军团战事福利
     *
     * @param handler
     */
    public void sendPartyAmyPropRq(SendPartyAmyPropRq req, ClientHandler handler) {
        Member member = partyDataManager.getMemberById(handler.getRoleId());
        if (member == null || member.getPartyId() == 0) {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }

        int partyId = member.getPartyId();
        if (partyId == 0) {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }

        int job = member.getJob();
        if (job != PartyType.LEGATUS) {
            handler.sendErrorMsgToPlayer(GameError.AUTHORITY_ERR);
            return;
        }

        PartyData partyData = partyDataManager.getParty(partyId);
        if (partyData == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }

        List<Long> idList = req.getSendIdList();
        CommonPb.Prop sendProp = req.getProp();
        int sendCount = idList.size();
        if (sendCount == 0 || sendProp == null || sendProp.getCount() <= 0) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }

        Map<Integer, Prop> amyProps = partyData.getAmyProps();

        int propId = sendProp.getPropId();
        int propCount = sendProp.getCount();

        StaticProp staticProp = staticPropDataMgr.getStaticProp(propId);
        if (staticProp == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }

        Prop prop = amyProps.get(propId);
        if (prop == null || propCount * sendCount > prop.getCount()) {
            handler.sendErrorMsgToPlayer(GameError.PROP_NOT_ENOUGH);
            return;
        }

        SendPartyAmyPropRs.Builder builder = SendPartyAmyPropRs.newBuilder();

        List<CommonPb.Award> awardList = new ArrayList<CommonPb.Award>();
        awardList.add(PbHelper.createAwardPb(AwardType.PROP, propId, propCount));

        String propsName = staticProp.getPropName() + "*" + propCount;
        sendCount = 0;
        for (Long lordId : idList) {
            Member partyMember = partyDataManager.getMemberById(lordId.longValue());
            if (partyMember == null || partyMember.getPartyId() != partyId) {
                continue;
            }
            Player role = playerDataManager.getPlayer(lordId.longValue());
            if (role == null) {
                continue;
            }
            sendCount += propCount;

            partyDataManager.addPartyTrend(partyId, 11, propsName, String.valueOf(lordId.longValue()));
            playerDataManager.sendAttachMail(AwardFrom.WAR_PARTY, role, awardList, MailType.MOLD_AMY_PROP, TimeHelper.getCurrentSecond(),
                    player.lord.getNick());
        }

        int count = prop.getCount() - sendCount < 0 ? 0 : prop.getCount() - sendCount;
        prop.setCount(count);
        builder.setProp(PbHelper.createPropPb(prop));
        handler.sendMsgToPlayer(SendPartyAmyPropRs.ext, builder.build());
    }

    /**
     * 使用宝箱道具
     *
     * @param req
     * @param handler void
     */
    public void useAmyPropRq(UseAmyPropRq req, ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }

        CommonPb.Prop sendProp = req.getProp();

        int propId = sendProp.getPropId();
        int propCount = sendProp.getCount();

        Prop prop = player.props.get(propId);
        if (prop == null || propCount > prop.getCount()) {
            handler.sendErrorMsgToPlayer(GameError.PROP_NOT_ENOUGH);
            return;
        }
        StaticProp staticProp = staticPropDataMgr.getStaticProp(propId);
        if (staticProp == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }

        if (staticProp.getEffectType() != 7) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }

        // 消耗箱子
        int useCount = prop.getCount() - propCount > 0 ? propCount : prop.getCount();
        prop.setCount(prop.getCount() - propCount > 0 ? prop.getCount() - propCount : 0);
        // 取最大战车工厂等级
        int lv = PlayerDataManager.getBuildingLv(BuildingId.FACTORY_1, player.building);
        int lv1 = PlayerDataManager.getBuildingLv(BuildingId.FACTORY_2, player.building);
        lv = lv > lv1 ? lv : lv1;

        // 通过战车工厂等级获取掉落ID,进行掉落
        int awardId = 0;
        List<List<Integer>> effectValue = staticProp.getEffectValue();
        for (List<Integer> e : effectValue) {
            int beginLv = e.get(0);
            int endLv = e.get(1);
            if (lv >= beginLv && lv <= endLv) {
                awardId = e.get(2);
                break;
            }
        }
        UseAmyPropRs.Builder builder = UseAmyPropRs.newBuilder();
        Map<Integer, Map<Integer, Integer>> maps = new HashMap<>();
        for (int i = 0; i < useCount; i++) {
            List<List<Integer>> awardList = staticAwardsDataMgr.getAwards(awardId);
            for (List<Integer> e : awardList) {
                if (e.size() < 3) {
                    continue;
                }
                int type = e.get(0);
                int id = e.get(1);
                int itemCount = e.get(2);
                playerDataManager.addAward(player, type, id, itemCount, AwardFrom.USE_AMY_PROP);
                Map<Integer, Integer> map = maps.get(type);
                if (map == null) {
                    map = new HashMap<>();
                    maps.put(type, map);
                }
                Integer count = map.get(id);
                if (count == null) {
                    count = 0;
                }
                map.put(id, count + itemCount);
            }
        }
        for (Entry<Integer, Map<Integer, Integer>> iMapEntry : maps.entrySet()) {
            int type = iMapEntry.getKey();
            Map<Integer, Integer> value = iMapEntry.getValue();
            for (Entry<Integer, Integer> iEntry : value.entrySet()) {
                builder.addAward(PbHelper.createAwardPb(type, iEntry.getKey(), iEntry.getValue(), 0));
            }
        }
        handler.sendMsgToPlayer(UseAmyPropRs.ext, builder.build());
    }

    /**
     * 军情需要用到的军团人员信息
     *
     * @param lordId
     * @return Man
     */
    private Man createMan(long lordId) {
        // todo: zhangdh 等角色ID替换后1个月再删除这段代码
        lordId = repairDM.getNewLordId(lordId);
        Player player = playerDataManager.getPlayer(lordId);
        if (player == null) {
            return new Man();
        }
        Lord lord = player.lord;
        if (lord == null) {
            return new Man();
        }
        Man man = new Man(lord.getLordId(), lord.getSex(), lord.getNick(), lord.getPortrait(), lord.getLevel());
        man.setPos(lord.getPos());
        man.setRanks(lord.getRanks());
        man.setFight(lord.getFight());
        man.setVip(lord.getVip());
        man.setHonour(lord.getHonour());
        man.setPros(lord.getPros());
        man.setProsMax(lord.getProsMax());
        man.setPartyName(partyDataManager.getPartyNameByLordId(lord.getLordId()));
        return man;
    }

    /**
     * 带参数的军情需要在这里配置具体参数信息，不带参数的不需要
     *
     * @param partyData
     * @param trend
     * @return
     */
    public List<TrendParam> getTrendParam(PartyData partyData, Trend trend) {
        List<TrendParam> list = new ArrayList<>();
        int trendId = trend.getTrendId();
        switch (trendId) {
            case 1:// 成员加入{s}
            case 2: {// 成员退出{s}
                TrendParam param = new TrendParam();
                long lordId = Long.valueOf(trend.getParam()[0]);
                Man man = createMan(lordId);
                param.setMan(createMan(lordId));
                param.setContent(man.getNick());
                list.add(param);
                break;
            }
            case 3: {// 踢出军团{s,s}
                long lordId1 = Long.valueOf(trend.getParam()[0]);
                TrendParam param = new TrendParam();
                Man man1 = createMan(lordId1);
                param.setMan(man1);
                param.setContent(man1.getNick());
                list.add(param);

                long lordId2 = Long.valueOf(trend.getParam()[1]);
                TrendParam param2 = new TrendParam();
                Man man2 = createMan(lordId2);
                param2.setMan(man2);
                param2.setContent(man2.getNick());
                list.add(param2);
                break;
            }
            case 4: {// 被任命职位{s,s}
                long lordId1 = Long.valueOf(trend.getParam()[0]);
                TrendParam param = new TrendParam();
                Man man1 = createMan(lordId1);
                param.setMan(man1);
                param.setContent(man1.getNick());
                list.add(param);

                int job = Integer.valueOf(trend.getParam()[1]);
                TrendParam param2 = new TrendParam();
                if (job == PartyType.JOB1) {
                    param2.setContent(partyData.getJobName1());
                } else if (job == PartyType.JOB2) {
                    param2.setContent(partyData.getJobName2());
                } else if (job == PartyType.JOB3) {
                    param2.setContent(partyData.getJobName3());
                } else if (job == PartyType.JOB4) {
                    param2.setContent(partyData.getJobName4());
                } else if (job == PartyType.COMMON) {
                    param2.setContent("成员");
                }

                list.add(param2);
                break;
            }
            case 5:// 被任命军团长{s}
            case 6: {// 被任命副军团长{s}
                TrendParam param = new TrendParam();
                long lordId = Long.valueOf(trend.getParam()[0]);
                Man man = createMan(lordId);
                param.setMan(man);
                param.setContent(man.getNick());
                list.add(param);
                break;
            }
            case 7:// 军团科技大厅等级提升{s}
            case 8:// 军团等级提升{s}
            case 9: // 福利院等级提升{s}
            case 14:// 百团大战,本次百团混战获得第|%s|名,奖励已发放到福利院！
            case 15:// 本次百团混战获得第1名,已激活军团采集加速BUFF
            case 16:// 本次要塞战获得第|%s|名,奖励已发放到福利院！
            case 19:// 军团祭坛升级到|%s| 级
            case 32:// 我军成功夺取飞艇|%s|的控制权,但由于没有足够的指挥官来控制飞艇,改区域已经被武装分子重新控制.
            {
                TrendParam param = new TrendParam();
                param.setContent(trend.getParam()[0]);
                list.add(param);
                break;
            }
            case 10: {// 消灭军团副本关卡{s,s}
                TrendParam param = new TrendParam();
                long lordId = Long.valueOf(trend.getParam()[0]);
                Man man = createMan(lordId);
                param.setMan(man);
                param.setContent(man.getNick());
                list.add(param);

                TrendParam param2 = new TrendParam();
                param2.setContent(trend.getParam()[1]);
                list.add(param2);
                break;
            }
            case 11: {// 福利分配{s,s}
                TrendParam param = new TrendParam();
                param.setContent(trend.getParam()[0]);
                list.add(param);

                long lordId2 = Long.valueOf(trend.getParam()[1]);
                TrendParam param2 = new TrendParam();
                Man man2 = createMan(lordId2);
                param2.setMan(man2);
                param2.setContent(man2.getNick());
                list.add(param2);
                break;
            }
            case 12: {// 防守成功{s,s,s}
                if (trend.getParam().length != 3) {// 错误数据则不发送
                    return null;
                }
                long lordId1 = Long.valueOf(trend.getParam()[0]);
                TrendParam param = new TrendParam();
                Man man1 = createMan(lordId1);
                param.setMan(man1);
                param.setContent(man1.getNick());
                list.add(param);

                TrendParam param2 = new TrendParam();
                param2.setContent(trend.getParam()[1]);
                list.add(param2);

                long lordId3 = Long.valueOf(trend.getParam()[2]);
                TrendParam param3 = new TrendParam();
                Man man3 = createMan(lordId3);
                param3.setMan(man3);
                param3.setContent(man3.getNick());
                list.add(param3);
                break;
            }
            case 13: {// 防守成功{s,s,s,s}
                if (trend.getParam().length != 4) {
                    return null;
                }
                long lordId1 = Long.valueOf(trend.getParam()[0]);
                TrendParam param = new TrendParam();
                Man man1 = createMan(lordId1);
                param.setMan(man1);
                param.setContent(man1.getNick());
                list.add(param);

                TrendParam param2 = new TrendParam();
                param2.setContent(trend.getParam()[1]);
                list.add(param2);

                long lordId3 = Long.valueOf(trend.getParam()[2]);
                TrendParam param3 = new TrendParam();
                Man man3 = createMan(lordId3);
                param3.setMan(man3);
                param3.setContent(man3.getNick());
                list.add(param3);

                TrendParam param4 = new TrendParam();
                param4.setContent(trend.getParam()[3]);
                list.add(param4);
                break;
            }
            case 18: {// 被要塞主任命职务{s,s,s}
                if (trend.getParam().length != 3) {
                    return null;
                }

                long lordId1 = Long.valueOf(trend.getParam()[0]);
                TrendParam param = new TrendParam();
                Man man1 = createMan(lordId1);
                param.setMan(man1);
                param.setContent(man1.getNick());
                list.add(param);

                long lordId2 = Long.valueOf(trend.getParam()[1]);
                TrendParam param2 = new TrendParam();
                Man man2 = createMan(lordId2);
                param2.setMan(man2);
                param2.setContent(man2.getNick());
                list.add(param2);

                TrendParam param3 = new TrendParam();
                param3.setContent(trend.getParam()[2]);
                list.add(param3);

                break;
            }
            case 24:// 我军在|%s|带领下进攻了|%s|，并取得的大捷，获取了飞艇的控制权。
            case 25:// 我军在|%s|带领下进攻了|%s|，但是铩羽而归,厉兵秣马择日再战。
            case 26:// 我军在|%s|带领下进攻了|%s|，但事有变故,我军已经开始撤退。
            case 27: {// 我军在|%s|带领下进攻了|%s|，但飞艇已经处于安全状态,我军已经开始撤退。
                if (trend.getParam().length != 2) {
                    return null;
                }
                // long lordId = Long.valueOf(trend.getParam()[0]);
                // TrendParam param1 = new TrendParam();
                // Man man = createMan(lordId);
                // param1.setMan(man);
                // param1.setContent(man.getNick());
                // list.add(param1);
                TrendParam param1 = new TrendParam();
                param1.setContent(trend.getParam()[0]);
                list.add(param1);

                TrendParam param2 = new TrendParam();
                param2.setContent(trend.getParam()[1]);
                list.add(param2);
                break;
            }
            case 28:// 我军遭受来自军团:|%s|的指挥官:|%s|所率领的进攻|%s|的攻击，一番苦战后获得最终的胜利。
            case 29:
            case 30:
            case 31: {// 我军遭受来自军团:|%s|的指挥官:|%s|所率领的进攻|%s|的攻击，一番苦战后我军失守飞艇的控制权。
                if (trend.getParam().length != 3) {
                    return null;
                }
                TrendParam param1 = new TrendParam();
                param1.setContent(trend.getParam()[0]);
                list.add(param1);

                // long lordId = Long.valueOf(trend.getParam()[1]);
                // TrendParam param2 = new TrendParam();
                // Man man = createMan(lordId);
                // param2.setMan(man);
                // param2.setContent(man.getNick());
                // list.add(param2);

                TrendParam param2 = new TrendParam();
                param2.setContent(trend.getParam()[1]);
                list.add(param2);

                TrendParam param3 = new TrendParam();
                param3.setContent(trend.getParam()[2]);
                list.add(param3);
                break;
            }
            default:
                break;
        }
        return list;
    }

    /**
     * 计算帮派战斗力，排名
     */
    public void partyTimerLogic() {
        List<PartyRank> partyRanks = partyDataManager.getPartyRanks();
        Collections.sort(partyRanks, new CompareParty());
        Iterator<PartyRank> it = partyRanks.iterator();
        int rank = 1;
        while (it.hasNext()) {
            PartyRank next = it.next();
            next.setRank(rank++);
        }
    }

    // public long getPartyFight(int partyId) {
    // int fight = 0;
    // List<Member> memberList = partyDataManager.getMemberList(partyId);
    // if (memberList == null) {
    // return fight;
    // }
    // Iterator<Member> it = memberList.iterator();
    // while (it.hasNext()) {
    // long playerId = it.next().getLordId();
    // Player player = playerDataManager.getPlayer(playerId);
    // if (player != null) {
    // fight += player.lord.getFight();
    // }
    // }
    // return fight;
    // }

    /**
     * 计算军团总战力
     *
     * @param partyData
     * @return long
     */
    public long calcPartyFight(PartyData partyData) {
        List<Member> list = partyDataManager.getMemberList(partyData.getPartyId());
        if (list == null) {
            return 0;
        }
        long fight = 0;
        Member member;
        Player player;
        for (int i = 0; i < list.size(); i++) {
            member = list.get(i);
            player = playerDataManager.getPlayer(member.getLordId());
            if (player == null) {
                continue;
            }
            Lord lord = player.lord;
            if (lord == null) {
                continue;
            }
            fight += player.lord.getFight();
        }
        return fight;
    }

    /**
     * 军团数据定时持久化
     */
    public void savePartyTimerLogic() {
        int now = TimeHelper.getCurrentSecond();
        savePartyOptimizeTask.saveTimerLogic(now);
    }

//    /**
//     * 军团数据定时持久化 void
//     */
//    public void savePartyTimerLogic() {
//        Iterator<PartyData> iterator = partyDataManager.getPartyMap().values().iterator();
//        int now = TimeHelper.getCurrentSecond();
//        int saveCount = 0;
//        long fight = 0;
//        PartyRank partyRank;
//        while (iterator.hasNext()) {
//            PartyData partyData = iterator.next();
//            if (now - partyData.getLastSaveTime() >= 180) {
//                saveCount++;
//                try {
//                    partyData.setLastSaveTime(now);
//                    fight = calcPartyFight(partyData);
//                    partyRank = partyDataManager.getPartyRank(partyData.getPartyId());
//                    partyRank.setFight(fight);
//                    partyData.setFight(fight);
//                    GameServer.getInstance().savePartyServer.saveData(partyData.copyData());
//                } catch (Exception e) {
//                    LogUtil.error("save party {" + partyData.getPartyId() + "} data error", e);
//                }
//
//            }
//        }
//
//        if (saveCount != 0) {
//            // LogHelper.SAVE_LOGGER.error("save party count:" + saveCount);
//            LogUtil.save("save party count:" + saveCount);
//        }
//    }

    /**
     * 玩家清空自己的军团申请列表
     *
     * @param lordId
     * @param applyList
     * @param partyId0时全取消
     */
    public void resetApply(long lordId, String applyList, int partyId) {
        try {
            String[] applyIds = applyList.split("\\|");
            for (String applyPartyId : applyIds) {
                if (applyPartyId.equals("")) {
                    continue;
                }
                int applyId = Integer.parseInt(applyPartyId);
                if (partyId == 0 || applyId == partyId) {
                    PartyData partyData = partyDataManager.getParty(applyId);
                    if (partyData == null) {
                        continue;
                    }
                    Map<Long, PartyApply> applyMap = partyData.getApplys();
                    if (applyMap != null && applyMap.containsKey(lordId)) {
                        applyMap.remove(lordId);
                    }
                }
            }
        } catch (Exception e) {
        }
    }

    /**
     * 设置军团活跃经验
     */
    public void gmSetPartyLiveExp(Player player, int exp) {
        Member member = partyDataManager.getMemberById(player.lord.getLordId());
        if (member == null) {
            return;
        }
        if (member.getPartyId() == 0) {
            return;
        }
        PartyData partyData = partyDataManager.getParty(member.getPartyId());
        if (partyData == null) {
            return;
        }
        partyData.setLively(exp);
    }

    /**
     * 是否可以退出军团
     *
     * @param rq
     * @param handler void
     */
    public void canQuitParty(CCCanQuitPartyRs rq, InnerHandler handler) {
        long roleId = rq.getRoleId();
        int type = rq.getType();
        Player player = playerDataManager.getPlayer(roleId);
        boolean isReg = rq.getIsReg();
        Member member = partyDataManager.getMemberById(roleId);

        if (isReg) {

            if (type == 1) {
                // 报名了不能退出军团
                QuitPartyRs.Builder builder = QuitPartyRs.newBuilder();
                handler.sendMsgToPlayer(player, GameError.CAN_NOT_QUIT_PARTY_CASE_CP.getCode(), QuitPartyRs.ext,
                        QuitPartyRs.EXT_FIELD_NUMBER, builder.build());
            } else if (type == 2) {
                CleanMemberRs.Builder builder = CleanMemberRs.newBuilder();
                handler.sendMsgToPlayer(player, GameError.CAN_NOT_QUIT_PARTY_CASE_CP.getCode(), CleanMemberRs.ext,
                        CleanMemberRs.EXT_FIELD_NUMBER, builder.build());
            }

        } else {
            if (type == 1) {
                QuitPartyRs.Builder builder = QuitPartyRs.newBuilder();
                int partyId = member.getPartyId();

                partyDataManager.quitParty(partyId, member);

                partyDataManager.addPartyTrend(partyId, 2, String.valueOf(roleId));

                handler.sendMsgToPlayer(player, QuitPartyRs.ext, QuitPartyRs.EXT_FIELD_NUMBER, builder.build());

                worldService.retreatAllGuard(player);

                chatService.sendPartyChat(chatService.createSysChat(SysChatId.QUIT_PARTY, player.lord.getNick()), partyId);

                altarBossService.resetBossAutoFight(partyId, roleId);// 重置祭坛BOSS自动战斗状态

                airshipService.afterQuitParty(player, partyDataManager.getParty(partyId));

            } else if (type == 2) {
                long cleanRoleId = rq.getCleanRoleId();

                Member cleanMember = partyDataManager.getMemberById(cleanRoleId);
                int partyId = member.getPartyId();
                Player cleanPlayer = playerDataManager.getPlayer(cleanMember.getLordId());
                partyDataManager.quitParty(partyId, cleanMember);

                String lordId1 = String.valueOf(cleanRoleId);
                String lordIdJ = String.valueOf(roleId);
                partyDataManager.addPartyTrend(partyId, 3, lordId1, lordIdJ);

                playerDataManager.sendNormalMail(cleanPlayer, MailType.MOLD_CLEAN_MEMBER, TimeHelper.getCurrentSecond(),
                        player.lord.getNick());
                playerDataManager.synPartyOutToPlayer(cleanPlayer, partyId);

                CleanMemberRs.Builder builder = CleanMemberRs.newBuilder();
                handler.sendMsgToPlayer(player, CleanMemberRs.ext, CleanMemberRs.EXT_FIELD_NUMBER, builder.build());

                worldService.retreatAllGuard(cleanPlayer);

                chatService.sendPartyChat(
                        chatService.createSysChat(SysChatId.PARTY_TICK, cleanPlayer.lord.getNick(), player.lord.getNick()), partyId);

                altarBossService.resetBossAutoFight(partyId, roleId);// 重置祭坛BOSS自动战斗状态

                airshipService.afterQuitParty(cleanPlayer, partyDataManager.getParty(partyId));
            }
            // 更新玩家最强实力
            playerEventService.calcStrongestFormAndFight(player);
        }
    }

    /**
     * GM设置军团建筑等级
     *
     * @param partyName
     * @param buildingId
     * @param buildingLv void
     */
    public void gmPartyBuildLv(String partyName, int buildingId, int buildingLv) {
        // 设置XXX军团的军团大厅等级 XXX军团科技大厅等级 XXX军团福利院等级
        if (buildingId != PartyType.HALL_ID && buildingId != PartyType.SCIENCE_ID && buildingId != PartyType.WEAL_ID
                && buildingId != PartyType.ALTAR_ID) {
            return;
        }

        PartyRank partyRank = partyDataManager.getPartyRankByName(partyName);
        if (partyRank == null) {
            return;
        }

        PartyData partyData = partyDataManager.getParty(partyRank.getPartyId());
        if (null == partyData) {
            return;
        }

        StaticPartyBuildLevel buildLevel = staticPartyDataMgr.getBuildLevel(buildingId, buildingLv);
        if (buildLevel == null) {
            return;
        }

        if (buildingId == PartyType.HALL_ID) {
            partyData.setPartyLv(buildingLv);
        } else if (buildingId == PartyType.SCIENCE_ID) {
            partyData.setScienceLv(buildingLv);
        } else if (buildingId == PartyType.WEAL_ID) {
            partyData.setWealLv(buildingLv);
        } else if (buildingId == PartyType.ALTAR_ID) {
            partyData.setAltarLv(buildingLv);
        } else {
            buildingLv -= 1;
        }

        activityDataManager.updatePartyLvRank(partyData);
    }

    /**
     * 添加军团战事福利
     *
     * @param partyName
     * @param propId
     * @param count     void
     */
    public void gmAddPartyProp(String partyName, int propId, int count) {
        // 添加军团战事福利
        PartyRank partyRank = partyDataManager.getPartyRankByName(partyName);
        if (partyRank == null) {
            return;
        }

        PartyData partyData = partyDataManager.getParty(partyRank.getPartyId());
        if (null == partyData) {
            return;
        }

        StaticProp staticProp = staticPropDataMgr.getStaticProp(propId);
        if (staticProp == null) {
            return;
        }

        Map<Integer, Prop> amyProps = partyData.getAmyProps();
        Prop prop = amyProps.get(propId);
        if (prop == null) {
            prop = new Prop(propId, count);
            amyProps.put(propId, prop);
        } else {
            prop.setCount(prop.getCount() + count);
        }
    }

    /**
     * 增加军团所有成员的贡献
     *
     * @param partyName
     * @param count     void
     */
    public void gmAddPartyAllMemberDonate(String partyName, int count) {
        // 增加军团所有成员的贡献
        PartyRank partyRank = partyDataManager.getPartyRankByName(partyName);
        if (partyRank == null) {
            return;
        }

        PartyData partyData = partyDataManager.getParty(partyRank.getPartyId());
        if (null == partyData) {
            return;
        }

        List<Member> list = partyDataManager.getMemberList(partyData.getPartyId());
        if (null != list) {
            for (Member member : list) {
                Player player = playerDataManager.getPlayer(member.getLordId());
                if (player == null) {
                    continue;
                }
                Lord lord = player.lord;
                if (lord == null) {
                    continue;
                }
                member.setDonate(member.getDonate() + count);
                if (count > 0) {
                    LogLordHelper.contribution(AwardFrom.GM_ADD_PARTY_PROP, player.account, player.lord, member.getDonate(),
                            member.getWeekAllDonate(), count);
                } else {
                    LogLordHelper.subContribution(AwardFrom.GM_ADD_PARTY_PROP, player.account, player.lord, member.getDonate(),
                            member.getWeekAllDonate(), count);
                }

                // LogLordHelper.contribution( , player.account, player.lord, member.getDonate(),
                // member.getWeekAllDonate(), count);
            }
        }
    }

    /**
     * 增加军团所有成员的贡献
     *
     * @param partyName
     * @param count     void
     */
    public void gmAddPartyBuild(String partyName, int count) {
        // 增加军团所有成员的贡献
        PartyRank partyRank = partyDataManager.getPartyRankByName(partyName);
        if (partyRank == null) {
            return;
        }

        PartyData partyData = partyDataManager.getParty(partyRank.getPartyId());
        if (null == partyData) {
            return;
        }

        partyData.setBuild(count);

    }
}
