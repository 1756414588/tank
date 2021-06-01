package merge;

import com.game.constant.*;
import com.game.dao.impl.p.*;
import com.game.domain.Member;
import com.game.domain.PartyData;
import com.game.domain.Player;
import com.game.domain.p.*;
import com.game.util.LogLordHelper;
import com.game.util.LogUtil;
import com.game.util.TimeHelper;
import com.google.protobuf.InvalidProtocolBufferException;

import java.util.*;
import java.util.concurrent.atomic.AtomicInteger;

public class MergeGame {
    MergeGameManager gameManager;
    MyBatisM myBatisMain;
    MyBatisM myBatisGame;

    class LordIdRelation {
        public int serverId;
        public long oldLordId;
        public long newLordId;

        LordIdRelation() {
        }
    }

    public MergeGame(MergeGameManager gameManager, MyBatisM myBatisMain,
                     MyBatisM myBatisGame, int serverId, String serverName, boolean hasMerge) {
        this.gameManager = gameManager;
        this.myBatisMain = myBatisMain;
        this.myBatisGame = myBatisGame;
        this.serverId = serverId;
        this.serverName = serverName;
        this.hasMerge = hasMerge;
    }

    int serverId = 0;
    String serverName = "";
    String nickSuffix;
    private boolean hasMerge;

    public int getServerId() {
        return serverId;
    }

    public String getServerName() {
        return serverName;
    }

    public String getNickSuffix() {
        return nickSuffix;
    }

    class PartyIdRelation {
        public int serverId;

        public int oldPartyId;
        public int newPartyId;

        PartyIdRelation() {
        }
    }

    public void joinSmailId() {
        SmallIdDao smallIdDao = new SmallIdDao();
        smallIdDao.setSqlSessionFactory(myBatisGame.getSqlSessionFactory());
        smallIdDao.insertAllNewSmallId(gameManager.getSmallLordLv());
        smallIdDao = null;
    }

    private String getNick(String nick) {
        if (hasMerge) {
            return nick;
        }
        return nick + nickSuffix;
    }

    /**
     * 工会合并
     *
     * @param partyIdRelationMap
     * @param memberMap
     */
    public void uionParty(Map<String, PartyIdRelation> partyIdRelationMap, Map<Long, Member> memberMap) {
        SmallIdDao smallIdDao = new SmallIdDao();
        smallIdDao.setSqlSessionFactory(myBatisGame.getSqlSessionFactory());

        PartyDao partyDao = new PartyDao();
        partyDao.setSqlSessionFactory(myBatisGame.getSqlSessionFactory());

        PartyDao savepartyDao = new PartyDao();
        savepartyDao.setSqlSessionFactory(myBatisMain.getSqlSessionFactory());

        Set<Long> smallLordIds = new HashSet<>();
        for (SmallId smallId : smallIdDao.load()) {
            smallLordIds.add(smallId.getLordId());
        }
        log("小号数量:" + smallLordIds.size());

        //有小号的工会列表
        Set<Integer> smallIdPartys = new HashSet<>();
        //工会成员中的小号列表
        List<PartyMember> smallIdPartyMembers = new ArrayList<>();

        //KEY:工会ID, VALUE: 工会成员列表
        Map<Integer, List<Member>> partyMembers = new HashMap<>();

        //查询数据库中工会列表
        List<Party> partyList = partyDao.selectParyList();

        //查询数据库中工会成员列表
        List<PartyMember> partyMemberList = partyDao.selectParyMemberList();

        int partyId;
        for (PartyMember e : partyMemberList) {
            if (e != null) {
                if (smallLordIds.contains(e.getLordId())) {
                    smallIdPartyMembers.add(e);
                    smallIdPartys.add(e.getPartyId());
                } else {
                    Member member = new Member();
                    try {
                        member.loadMember(e);
                    } catch (InvalidProtocolBufferException e1) {
                        LogUtil.error(e1);
                    }

                    memberMap.put(e.getLordId(), member);

                    partyId = e.getPartyId();
                    if (partyId != 0) {
                        List<Member> list = partyMembers.get(partyId);
                        if (list == null) {
                            list = new ArrayList<>();
                            partyMembers.put(partyId, list);
                        }
                        list.add(member);
                    }
                }
            }
        }

        //有小号的工会处理
        dealSmallIdPartyMember(smallIdPartyMembers, partyMembers);

        log("总军团数:" + partyList.size());
        int smallPartyIdNum = 0;
        float i = 0.0F;

        Map<Integer, PartyData> partyMap = new HashMap<>();
        for (Party e : partyList) {
            i += 1.0F;
            List<Member> list = partyMembers.get(e.getPartyId());

            if ((!smallIdPartys.contains(e.getPartyId())) || ((list != null) && (list.size() != 0))) {
                if (list == null || list.isEmpty()){
                    smallPartyIdNum++;
                    continue;
                }
                long legatusLordId = 0;
                for (Member member : list) {
                    if (member.getJob() == PartyType.LEGATUS) {
                        legatusLordId = member.getLordId();
                        break;
                    }
                }

                PartyData party = new PartyData(e);

                int oldPartyId = party.getPartyId();
                int newPartyId = this.gameManager.getPartyId();
                party.setPartyId(newPartyId);
                party.setLegatusName(takeNick(legatusLordId, party.getLegatusName()));
                party.setPartyName(takePartyNick(party.getPartyName()));

                //清除军事矿区积分
                party.setScore(0);
                //清除申请记录
                party.getApplys().clear();
                //百团混战
                party.getWarRecords().clear();
                party.setRegLv(0);
                party.setRegFight(0);
                party.setWarRank(0);
                //军情、民情 里面有些有玩家id
                party.getTrends().clear();
                //捐赠id里面也有玩家id
                if (party.getDonates(1) != null) {
                    party.getDonates(1).clear();
                }
                if (party.getDonates(2) != null) {
                    party.getDonates(2).clear();
                }

                party.getAirshipTeamMap().clear();
                party.getAirshipGuardMap().clear();
                party.getAirshipLeaderMap().clear();
                party.getFreeMap().clear();

                boolean suc = savepartyDao.insertFullParty(party.copyData()) > 0;
                if (suc) {
                    partyMap.put(e.getPartyId(), party);
                    PartyIdRelation relation = new PartyIdRelation();
                    relation.serverId = this.serverId;
                    relation.oldPartyId = oldPartyId;
                    relation.newPartyId = party.getPartyId();

                    partyIdRelationMap.put(relation.serverId + "_" + relation.oldPartyId, relation);
                }

                int r = (int) (i / partyList.size() * 100.0F);

                log("保存军团：" + oldPartyId + " --> " + newPartyId + " " + party.getPartyName() + " " + suc + " 进度:" + r + "%(" + (int) i + "/" + partyList.size() + ")");
            } else {
                smallPartyIdNum++;
            }
        }

        log("总军团数:" + partyList.size() + " 小号军团数:" + smallPartyIdNum + " 当前军团数:" + partyMap.size());

        smallIdDao = null;
        partyDao = null;
        savepartyDao = null;
    }

    private void log(String msg) {
        msg = "server:" + this.serverName + "[" + serverId + "]:" + msg;

        LogUtil.error(msg);
    }

    /**
     * 工会成员中小号处理,转移会长信息
     *
     * @param smallIdPartyMembers
     * @param partyMembers
     */
    private void dealSmallIdPartyMember(List<PartyMember> smallIdPartyMembers, Map<Integer, List<Member>> partyMembers) {
        for (PartyMember partyMember : smallIdPartyMembers) {
            // 若是军团长
            if (partyMember.getJob() == PartyType.LEGATUS) {
                // 获取军团人数
                List<Member> list = partyMembers.get(partyMember.getPartyId());
                if (list != null && list.size() > 0) {
                    // 移交给军团长自动移交至副军团长中贡献最高的，若没副军团长则移交至贡献最高的成员
                    Collections.sort(list, new Comparator<Member>() {
                        public int compare(Member o1, Member o2) {
                            if (o1.getJob() > o2.getJob()) {
                                return 1;
                            } else if (o1.getJob() == o2.getJob()) {
                                return o1.getDonate() - o2.getDonate();
                            } else {
                                return -1;
                            }
                        }
                    });

                    Member m = list.get(list.size() - 1);
                    m.setJob(PartyType.LEGATUS);
                }
            }
        }
    }

    public List<Long> getPlayerIds() {
        LordDao lordDao = new LordDao();
        lordDao.setSqlSessionFactory(this.myBatisGame.getSqlSessionFactory());
        List<Long> lordIds = lordDao.selectLordNotSmallIds();

        log("需要合并玩家 :" + lordIds.size());

        return lordIds;
    }

    private Long takeLordId(Long lordId, Map<Long, Long> lordIdMap) {
        Long newLordId = null;
        synchronized (gameManager) {
            newLordId = lordIdMap.get(lordId);
            if (newLordId == null) {
                newLordId = gameManager.getLordId();
            }
            lordIdMap.put(lordId, newLordId);
        }
        return newLordId;
    }

    /**
     * 更改玩家名字--->如果以前没有合服过则加上后缀
     *
     * @param lordId
     * @param oldNick
     * @return
     */
    private String takeNick(long lordId, String oldNick) {
        //未合服时名字后面加上区服标记
        oldNick = getNick(oldNick);
        String newNick = oldNick;
        synchronized (gameManager.usedNick) {
            //军团里的玩家名字 需要提前预定
            Map<Long, String> mapLordNick = gameManager.usedNickLord.get(serverId);
            if (mapLordNick != null) {
                String haveNick = mapLordNick.get(lordId);//必须是旧角色id
                if (haveNick != null) {
                    return haveNick;//之前已经存在名字，则使用此名字
                }
            } else {
                mapLordNick = new HashMap<Long, String>();
                gameManager.usedNickLord.put(serverId, mapLordNick);
            }
            //然后检查名字是否重复
            int i = 1;
            while (true) {
                if (gameManager.usedNick.contains(newNick)) {
                    newNick = oldNick + i;
                } else {
                    break;
                }
                i++;
            }
            gameManager.usedNick.add(newNick);
            mapLordNick.put(lordId, newNick);
        }
        return newNick;
    }

    private String takePartyNick(String oldNick) {
        //未合服时名字后面加上区服标记
        oldNick = getNick(oldNick);
        String newNick = oldNick;
        synchronized (gameManager.usedPartyNick) {
            //然后检查名字是否重复
            int i = 1;
            while (true) {
                if (gameManager.usedPartyNick.contains(newNick)) {
                    newNick = oldNick + i;
                } else {
                    break;
                }
                i++;
            }
            gameManager.usedPartyNick.add(newNick);
        }
        return newNick;
    }

    /**
     * 合并玩家信息
     *
     * @param partyIdRelationMap
     * @param memberMap
     * @param lordIdMap
     * @param lordIds
     * @param totalLordIds
     * @param times
     */
    public void unionPlayer(Map<String, PartyIdRelation> partyIdRelationMap,
                            Map<Long, Member> memberMap, Map<Long, Long> lordIdMap,
                            List<Long> lordIds, List<Long> totalLordIds, AtomicInteger times) {
        LordDao lordDao = new LordDao();
        AccountDao accountDao = new AccountDao();
        BuildingDao buildingDao = new BuildingDao();
        ResourceDao resourceDao = new ResourceDao();
        TipGuyDao tipGuyDao = new TipGuyDao();
        DataNewDao dataNewDao = new DataNewDao();
        PayDao payDao = new PayDao();
        AdvertisementDao advertisementDao = new AdvertisementDao();
        MailDao mailDao = new MailDao();

        lordDao.setSqlSessionFactory(myBatisGame.getSqlSessionFactory());
        accountDao.setSqlSessionFactory(myBatisGame.getSqlSessionFactory());
        buildingDao.setSqlSessionFactory(myBatisGame.getSqlSessionFactory());
        resourceDao.setSqlSessionFactory(myBatisGame.getSqlSessionFactory());
        tipGuyDao.setSqlSessionFactory(myBatisGame.getSqlSessionFactory());
        dataNewDao.setSqlSessionFactory(myBatisGame.getSqlSessionFactory());
        payDao.setSqlSessionFactory(myBatisGame.getSqlSessionFactory());
        advertisementDao.setSqlSessionFactory(myBatisGame.getSqlSessionFactory());
        mailDao.setSqlSessionFactory(myBatisGame.getSqlSessionFactory());

        LordDao savelordDao = new LordDao();
        AccountDao saveaccountDao = new AccountDao();
        BuildingDao savebuildingDao = new BuildingDao();
        ResourceDao saveresourceDao = new ResourceDao();
        TipGuyDao savetipGuyDao = new TipGuyDao();
        DataNewDao savedataNewDao = new DataNewDao();
        LordRelationDao savelordRelationDao = new LordRelationDao();
        PartyDao savepartyDao = new PartyDao();
        PayDao savepayDao = new PayDao();
        AdvertisementDao saveadvertisementDao = new AdvertisementDao();
        MailDao saveMailDao = new MailDao();
        
        savelordDao.setSqlSessionFactory(myBatisMain.getSqlSessionFactory());
        saveaccountDao.setSqlSessionFactory(myBatisMain.getSqlSessionFactory());
        savebuildingDao.setSqlSessionFactory(myBatisMain.getSqlSessionFactory());
        saveresourceDao.setSqlSessionFactory(myBatisMain.getSqlSessionFactory());
        savetipGuyDao.setSqlSessionFactory(myBatisMain.getSqlSessionFactory());
        savedataNewDao.setSqlSessionFactory(myBatisMain.getSqlSessionFactory());
        savelordRelationDao.setSqlSessionFactory(myBatisMain.getSqlSessionFactory());
        savepartyDao.setSqlSessionFactory(myBatisMain.getSqlSessionFactory());
        savepayDao.setSqlSessionFactory(myBatisMain.getSqlSessionFactory());
        saveadvertisementDao.setSqlSessionFactory(myBatisGame.getSqlSessionFactory());
        saveMailDao.setSqlSessionFactory(myBatisMain.getSqlSessionFactory());
        
        log("分配合并玩家:" + lordIds.size());

        for (Long lordId : lordIds) {
            times.incrementAndGet();
            Lord lord = lordDao.selectLordById(lordId);
            if (lord.getNick() != null) {
                Account account = accountDao.selectAccountByLordId(lordId);
                if (account == null) {
                    log("没有帐号:" + lordId);
                } else {
                    int now = TimeHelper.getCurrentSecond();
                    //新id
                    Long newLordId = takeLordId(lordId, lordIdMap);
                    lord.setLordId(newLordId);
                    //改名
                    lord.setNick(takeNick(lordId, lord.getNick()));
                    Player player = new Player(lord, now);

                    account.setLordId(newLordId);
                    player.account = account;

                    Building building = buildingDao.selectBuilding(lordId);
                    building.setLordId(newLordId);
                    player.building = building;
                    
                    Advertisement advertisement = advertisementDao.selectAdvertisement(lordId);
                    if (null != advertisement) {
                        advertisement.setLordId(newLordId);
                        player.advertisement = advertisement;
                    }

                    Resource resource = resourceDao.selectResource(lordId);
                    resource.setLordId(newLordId);
                    player.resource = resource;

                    DataNew dataNew = dataNewDao.selectData(lordId);
                    dataNew.setLordId(newLordId);
                    try {
                        player.dserNewData(dataNew);
                        addProp(player, PropId.CHANGE_NAME, 1);
                    } catch (InvalidProtocolBufferException e) {
                        LogUtil.error(e);
                        continue;
                    }

                    List<NewMail> mails = mailDao.selectByLordId(lordId);
                    player.loadMail(mails);
                    
                    List<Pay> pays = payDao.selectRolePay(account.getServerId(), lordId);

                    //处理好友
                    for (Friend friend : player.friends.values()) {
                        Long fId = takeLordId(friend.getLordId(), lordIdMap);
                        friend.setLordId(fId);
                    }

                    TipGuy tipGuy = tipGuyDao.selectTipGuyByLordId(lordId);
                    if (tipGuy != null) {
                        tipGuy.setLordId(newLordId);
                    }

                    Member member = (Member) memberMap.get(lordId);
                    if (member != null) {
                        member.setLordId(lord.getLordId());
                        member.setRegParty(0);
                        member.setRegLv(0);
                        member.setRegTime(0);
                        member.setRegFight(0);
                        member.getWarRecords().clear();

                        if (member.getPartyId() != 0) {
                            PartyIdRelation pRelation = partyIdRelationMap.get(this.serverId + "_" + member.getPartyId());
                            if (pRelation == null) {
//								log("没有找到玩家爱partyId关联信息，跳过玩家, serverId:"+ this.serverId + ", lordId:"+ lord.getLordId() + ", partyId:" + member.getPartyId());
                                member.setPartyId(0);
                            } else {
                                member.setPartyId(pRelation.newPartyId);
                                if (member.getJob() == PartyType.LEGATUS) {
                                    addProp(player, PropId.PARTY_RENAME_CARD, 1);
                                }
                            }
                        }
                        if (member.getRegParty() != 0) {
                            PartyIdRelation pRelation = (PartyIdRelation) partyIdRelationMap.get(this.serverId + "_" + member.getRegParty());
                            if (pRelation == null) {
                                member.setRegParty(0);
                            } else {
                                member.setRegParty(pRelation.newPartyId);
                            }
                        }
                        //清除申请记录
                        member.setApplyList("|");
                    }

                    if (player.lord.getPos() != -1) {
                        gameManager.addNewPlayer(player);
                    }

                    retreatEnd(player);

                    //清除叛军积分击杀数据
                    if (player.rebelData != null) {
                        player.rebelData.setLordId(newLordId);
                        player.rebelData.setNick(lord.getNick());
                        player.rebelData.setKillGuard(0);
                        player.rebelData.setKillLeader(0);
                        player.rebelData.setKillNum(0);
                        player.rebelData.setKillUnit(0);
                        player.rebelData.setLastRank(0);
                        player.rebelData.setScore(0);
                        player.rebelData.setTotalGuard(0);
                        player.rebelData.setTotalLeader(0);
                        player.rebelData.setTotalScore(0);
                        player.rebelData.setTotalUnit(0);
                    }
                    //军事矿区清空
                    player.seniorScore = 0;
                    //竞技场邮件全部删掉
                    Iterator<Mail> it = player.getMails().values().iterator();
                    while (it.hasNext()) {
                        Mail mail = it.next();
                        if (mail.getType() == MailType.ARENA_MAIL || mail.getType() == MailType.ARENA_GLOBAL_MAIL) {
                            it.remove();
                        }
                    }
                    //军事演习
                    if (player.drillFightData != null) {
                        player.drillFightData.setLordId(newLordId);
                    }
                    //
                    if (player.blesses != null) {
                        Iterator<Bless> itr = player.blesses.values().iterator();
                        while (itr.hasNext()) {
                            Bless bless = itr.next();
                            Long fId = takeLordId(bless.getLordId(), lordIdMap);
                            bless.setLordId(fId);
                        }
                    }
                    //处理废墟
                    if (player.ruins != null) {
                        if (player.ruins.isRuins() && !"".equals(player.ruins.getAttackerName())) {
                            player.ruins.setAttackerName(takeNick(player.ruins.getLordId(), player.ruins.getAttackerName()));
                            Long fId = takeLordId(player.ruins.getLordId(), lordIdMap);
                            player.ruins.setLordId(fId);
                        }
                    }
                    //处理43活动，不重置(根据开服时间算的活动1，15，18在合服之前已经写死，其他53，1001可以重置)
                    if (gameManager.getAct43begin() != 0) {//活动开启
                        Activity actVipGift = player.activitys.get(ActivityConst.ACT_VIP_GIFT);
                        if (actVipGift != null) {
                            actVipGift.setBeginTime(gameManager.getAct43begin());
                        }
                    }
                    //合服添加防护罩
                    addEffect(player, EffectType.ATTACK_FREE, gameManager.getBuffFreeTime());

                    for (Army army : player.armys) {
                        army.player = player;
                    }

                    LordRelation lr = new LordRelation();
                    lr.setOldServerId(this.serverId);
                    lr.setOldLordId(lordId);
                    lr.setNewServerId(this.gameManager.getNewServerId());
                    lr.setNewLordId(newLordId);

                    boolean allSuccess = false;
                    try {
                        if (saveaccountDao.insertFullAccount(account) > 0) {
                            if (savebuildingDao.insertBuilding(building) > 0) {
                                if (savedataNewDao.insertFullData(player.serNewData()) > 0) {
                                    if (savelordDao.insertFullLord(lord) > 0) {
                                        if (saveMail(saveMailDao, player.getNewMails())) {
                                            if ((member == null) || (savepartyDao.insertFullPartyMember(member.copyData()) > 0)) {
                                                if (saveresourceDao.insertFullResource(resource) > 0) {
                                                    if ((tipGuy == null) || ((tipGuy != null)
                                                            && (savetipGuyDao.insertTipGuy(tipGuy) > 0))) {
                                                        if (savelordRelationDao.insertLordRelation(lr) > 0) {
                                                            if (pays != null) {
                                                                for (Pay pay : pays) {
                                                                    pay.setRoleId(newLordId);
                                                                    savepayDao.createPay(pay);
                                                                }
                                                            }
                                                            allSuccess = true;
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    } catch (Throwable t) {
                        LogUtil.error("保存玩家数据出错:" + lr.getOldLordId(), t);
                        System.exit(-2);
                    }
                    float i = times.get();
                    int r = (int) (i / totalLordIds.size() * 100.0F);
                    log("保存玩家数据 " + lordId + "-->" + newLordId + " " + allSuccess + " 进度:" + r + "%(" + (int) i + "/" + totalLordIds.size() + ")");
                }
            } else {
                log("没有角色名" + lordId);
            }
        }
        lordDao = null;
        accountDao = null;
        buildingDao = null;
        resourceDao = null;
        tipGuyDao = null;
        dataNewDao = null;
        payDao = null;
        advertisementDao=null;

        savelordDao = null;
        saveaccountDao = null;
        savebuildingDao = null;
        saveresourceDao = null;
        savetipGuyDao = null;
        savedataNewDao = null;
        savelordRelationDao = null;
        savepartyDao = null;
        savepayDao = null;
        saveadvertisementDao=null;
    }

    /**
     * 邮件存入数据库
     * @param saveMailDao
     * @param list
     * @return
     */
    private boolean saveMail(MailDao saveMailDao, List<NewMail> list) {
        if(list.size() == 0) return true;
        int count = 0;
        for(NewMail mail : list) {
            count += saveMailDao.insertMail(mail);
        }
        return count > 0;
    }
    
    private void addProp(Player player, int propId, int count) {
        Prop prop = player.props.get(propId);
        if (prop != null) {
            prop.setCount(count + prop.getCount());
        } else {
            prop = new Prop(propId, count);
            player.props.put(propId, prop);
        }
    }

    /**
     * 部队全部返还
     **/
    private void retreatEnd(Player player) {
        Iterator<Army> it = player.armys.iterator();
        while (it.hasNext()) {
            Army army = it.next();
            int state = army.getState();
            if (state == ArmyState.WAR || state == ArmyState.FortessBattle) {
                retreat(player, army);
                it.remove();
                continue;
            }
            if (state == ArmyState.RETREAT || state == ArmyState.MARCH || state == ArmyState.AID) {
                retreat(player, army);
                it.remove();
                continue;
            }
            if (state == ArmyState.COLLECT) {
                retreat(player, army);
                it.remove();
            } else if (state == ArmyState.GUARD || state == ArmyState.WAIT) {// 召回驻防
                retreat(player, army);
                it.remove();
            } else if (army.getState() == ArmyState.AIRSHIP_BEGAIN
                    || army.getState() == ArmyState.AIRSHIP_MARCH
                    || army.getState() == ArmyState.AIRSHIP_GUARD
                    || army.getState() == ArmyState.AIRSHIP_GUARD_MARCH) {
                retreat(player, army);
                it.remove();
            }
        }
    }

    private void retreat(Player player, Army army) {
        // 部队返回
        int[] p = army.getForm().p;
        int[] c = army.getForm().c;
        for (int i = 0; i < p.length; i++) {
            if (p[i] > 0 && c[i] > 0) {
                addTank(player, p[i], c[i], AwardFrom.RETREAT_END);
            }
        }
        // 将领返回
        if (army.getForm().getAwakenHero() != null) {
            AwakenHero awakenHero = player.awakenHeros.get(army.getForm().getAwakenHero().getKeyId());
            awakenHero.setUsed(false);
            LogLordHelper.awakenHero(AwardFrom.RETREAT_END, player.account, player.lord, awakenHero, 0);
        } else {
            int heroId = army.getForm().getCommander();
            if (heroId > 0) {
                addHero(player, heroId, 1, AwardFrom.RETREAT_END);
            }
        }

        // 加资源
        Grab grab = army.getGrab();
        if (grab != null) {
            gainGrab(player, grab);
        }
    }

    public Hero addHero(Player player, int heroId, int count, AwardFrom from) {
        Hero hero = player.heros.get(heroId);
        if (hero != null) {
            hero.setCount(hero.getCount() + count);
            if (count < 0 && hero.getCount() <= 0) {
                player.heros.remove(heroId);
            }
        } else {
            hero = new Hero(heroId, heroId, count);
            player.heros.put(hero.getHeroId(), hero);
        }
        if(player.herosExpiredTime.containsKey(heroId)){
            hero.setEndTime(player.herosExpiredTime.get(heroId));
        }
        return hero;
    }

    public Tank addTank(Player player, int tankId, int count, AwardFrom from) {
        Tank tank = player.tanks.get(tankId);
        if (tank != null) {
            tank.setCount(count + tank.getCount());
        } else {
            tank = new Tank(tankId, count, 0);
            player.tanks.put(tankId, tank);
        }
        return tank;
    }

    public void gainGrab(Player target, Grab grab) {
        modifyIron(target, grab.rs[0], AwardFrom.GAIN_GRAB);
        modifyOil(target, grab.rs[1], AwardFrom.GAIN_GRAB);
        modifyCopper(target, grab.rs[2], AwardFrom.GAIN_GRAB);
        modifySilicon(target, grab.rs[3], AwardFrom.GAIN_GRAB);
        modifyStone(target, grab.rs[4], AwardFrom.GAIN_GRAB);
    }

    public void modifyIron(Player player, long add, AwardFrom from) {
        Resource resource = player.resource;
        if (add > 0) {
            resource.settIron(resource.gettIron() + add);
        }
        resource.setIron(resource.getIron() + add);
    }

    public void modifyOil(Player player, long add, AwardFrom from) {
        Resource resource = player.resource;
        if (add > 0) {
            resource.settOil(resource.gettOil() + add);
        }
        resource.setOil(resource.getOil() + add);
    }

    public void modifyCopper(Player player, long add, AwardFrom from) {
        Resource resource = player.resource;
        if (add > 0) {
            resource.settCopper(resource.gettCopper() + add);
        }
        resource.setCopper(resource.getCopper() + add);
    }

    public void modifySilicon(Player player, long add, AwardFrom from) {
        Resource resource = player.resource;
        if (add > 0) {
            resource.settSilicon(resource.gettSilicon() + add);
        }
        resource.setSilicon(resource.getSilicon() + add);
    }

    public void modifyStone(Player player, long add, AwardFrom from) {
        Resource resource = player.resource;
        if (add > 0) {
            resource.settStone(resource.gettStone() + add);
        }
        resource.setStone(resource.getStone() + add);
    }

    public Effect addEffect(Player player, int id, int time) {
        Effect effect = player.effects.get(id);
        if (effect != null) {
            effect.setEndTime(effect.getEndTime() + time);
        } else {
            int now = TimeHelper.getCurrentSecond();
            effect = new Effect(id, now + time);
            player.effects.put(id, effect);
        }
        return effect;
    }
}