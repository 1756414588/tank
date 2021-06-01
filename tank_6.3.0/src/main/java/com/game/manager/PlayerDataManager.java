/**
 * @Title: PlayerDataManager.java
 * @Package com.game.manager
 * @author ZhangJun
 * @date 2015年8月4日 下午4:24:16
 * @version V1.0
 */
package com.game.manager;

import com.game.actor.role.PlayerEventService;
import com.game.constant.*;
import com.game.dao.impl.p.*;
import com.game.dataMgr.*;
import com.game.domain.*;
import com.game.domain.p.*;
import com.game.domain.p.friend.FriendGive;
import com.game.domain.p.friend.GetGiveProp;
import com.game.domain.p.lordequip.LordEquip;
import com.game.domain.pojo.LoadProcess;
import com.game.domain.s.*;
import com.game.drill.domain.DrillRank;
import com.game.pb.BasePb;
import com.game.pb.BasePb.Base;
import com.game.pb.CommonPb;
import com.game.pb.CommonPb.Award;
import com.game.pb.CommonPb.Report;
import com.game.pb.GamePb2.*;
import com.game.pb.GamePb3.*;
import com.game.pb.GamePb4.SynFortressBattleStateRq;
import com.game.pb.GamePb4.SynFortressSelfRq;
import com.game.pb.GamePb5.SynCrossStateRq;
import com.game.pb.GamePb5.SynDay7ActTipsRq;
import com.game.pb.GamePb5.SynInnerModPropsRq;
import com.game.pb.GamePb6.*;
import com.game.server.GameServer;
import com.game.service.*;
import com.game.util.*;
import com.google.protobuf.InvalidProtocolBufferException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.datasource.DataSourceTransactionManager;
import org.springframework.stereotype.Component;
import org.springframework.transaction.TransactionDefinition;
import org.springframework.transaction.TransactionStatus;
import org.springframework.transaction.support.DefaultTransactionDefinition;
import org.springframework.util.CollectionUtils;

import java.text.SimpleDateFormat;
import java.util.*;
import java.util.Map.Entry;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentSkipListMap;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.regex.Pattern;

/**
 * @author ZhangJun
 * @ClassName: PlayerDataManager
 * @Description: 玩家数据操作
 * @date 2015年8月4日 下午4:24:16
 */

@Component
public class PlayerDataManager implements PlayerDM {
    @Autowired
    private AccountDao accountDao;

    @Autowired
    private LordDao lordDao;

    @Autowired
    private TipGuyDao tipGuyDao;

    @Autowired
    private ResourceDao resourceDao;

    @Autowired
    private BuildingDao buildingDao;

    @Autowired
    private DataNewDao dataDao;

    @Autowired
    private ArenaDao arenaDao;

    @Autowired
    private PartyDao partyDao;

    @Autowired
    private BossDao bossDao;

    @Autowired
    private AdvertisementDao advertisementDao;

    @Autowired
    private MailDao mailDao;

    @Autowired
    private StaticIniDataMgr staticIniDataMgr;

    @Autowired
    private StaticLordDataMgr staticLordDataMgr;

    @Autowired
    private StaticTankDataMgr staticTankDataMgr;

    @Autowired
    private StaticBuildingDataMgr staticBuildingDataMgr;

    @Autowired
    private StaticRefineDataMgr staticRefineDataMgr;

    @Autowired
    private StaticTaskDataMgr staticTaskDataMgr;

    @Autowired
    private StaticMailDataMgr staticMailDataMgr;

    @Autowired
    private StaticHeroDataMgr staticHeroDataMgr;

    @Autowired
    private StaticPropDataMgr staticPropDataMgr;

    @Autowired
    private StaticVipDataMgr staticVipDataMgr;

    @Autowired
    private StaticStaffingDataMgr staticStaffingDataMgr;

    @Autowired
    private StaticWarAwardDataMgr staticWarAwardDataMgr;

    @Autowired
    private PartyDataManager partyDataManager;

    @Autowired
    private ActivityDataManager activityDataManager;

    @Autowired
    private WorldDataManager worldDataManager;

    @Autowired
    private RankDataManager rankDataManager;

    @Autowired
    private SeniorMineDataManager seniorMineDataManager;

    @Autowired
    private StaffingDataManager staffingDataManager;

    @Autowired
    private SmallIdManager smallIdManager;

    @Autowired
    private WorldService worldService;

    @Autowired
    private FightLabService fightLabService;

    @Autowired
    private PlayerEventService playerEventService;

    @Autowired
    private StaticCombatDataMgr staticCombatDataMgr;

    @Autowired
    private StaticBackDataMgr staticBackDataMgr;

    @Autowired
    private DrillDataManager drillDataManager;

    @Autowired
    private BossDataManager bossDataManager;

    @Autowired
    private LordEquipService lordEquipService;

    @Autowired
    private StaticEquipDataMgr staticEquipDataMgr;

    @Autowired
    private StaticFunctionPlanDataMgr staticFunctionPlanDataMgr;

    @Autowired
    private StaticActiveBoxDataMgr staticActiveBoxDataMgr;

    @Autowired
    private MailService mailService;

    @Autowired
    private DataRepairDM dataRepairDM;

    @Autowired
    private StaticFunctionPlanDataMgr functionPlanDataMgr;

    @Autowired
    private RewardService rewardService;

    @Autowired
    private HonourDataManager honourDataManager;

    @Autowired
    private StaticActivityDataMgr staticActivityDataMgr;
    @Autowired
    private ActivityKingService activityKingService;
    @Autowired
    private TacticsService tacticsService;

    @Autowired
    private StaticEnergyStoneDataMgr staticEnergyStoneDataMgr;

    public boolean inited = false;

    // 能量上限
    public static final int POWER_MAX = 20;

    // 恢复1点能量秒数
    public static final int POWER_BACK_SECOND = 30 * 60;

    // 恢复1点繁荣度秒数
    public static final int PROS_BACK_SECOND = 60;

    // // 装备最高等级
    // public static final int MAX_EQUIP_LV = 80;

    // 装备仓库最大上限容量
    public static final int EQUIP_STORE_LIMIT = 300;

    // 配件仓库最大上限容量
    public static final int PART_STORE_LIMIT = 300;

    // @PostConstruct
    public void init() {
        // for (int i = 0; i < 5000; i++) {
        // accountCache.put(i + 1, new ConcurrentHashMap<Integer, Account>());
        // }
        loadAllPlayer();
        staffingDataManager.initStaffingWorld();
        inited = true;
    }

    // MAP<serverid, MAP<accountKey, Player>>
    private ConcurrentHashMap<Integer, ConcurrentHashMap<Integer, Account>> accountCache = new ConcurrentHashMap<>();

    // MAP<roleId, Player>
    private ConcurrentHashMap<Long, Player> playerCache = new ConcurrentHashMap<>();

    /**
     * 在线玩家 key:角色昵称
     */
    private ConcurrentHashMap<String, Player> onlinePlayer = new ConcurrentHashMap<>();

    /**
     * key:昵称
     */
    private ConcurrentHashMap<String, Player> allPlayer = new ConcurrentHashMap<>();

    // 新建玩家
    private ConcurrentHashMap<Long, Player> newPlayerCache = new ConcurrentHashMap<>();

    // 新建玩家
    private Map<Long, Guy> guyMap = new HashMap<Long, Guy>();

    private final Set<String> usedNames = Collections.synchronizedSet(new HashSet<String>());

    // 存补充日期
    private Map<Long, Integer> rePayMap = new HashMap<>();

    private final Map<Integer, Map<Integer, AtomicInteger>> idMap = new ConcurrentSkipListMap<>();

    /**
     * 存放三个月内登陆玩家
     */
    private Map<Long, Player> recThreeMonOnlPlayer = new ConcurrentHashMap<>();

    public void setRePay(long lordId, int day) {
        rePayMap.put(lordId, day);
    }

    public Integer getRePay(long lordId) {
        return rePayMap.get(lordId);
    }

    public void removeRePay(long lordId) {
        rePayMap.remove(lordId);
    }

    // private void loadIds(){
    // List<CountAccount> list = accountDao.countAccountGroupByPlatAndServerId();
    // if (list != null && !list.isEmpty()) {
    // for (CountAccount cta : list) {
    // Map<Integer, AtomicInteger> srvMap = idMap.get(cta.getPlatNo());
    // if (srvMap == null) {
    // idMap.put(cta.getPlatNo(), srvMap = new ConcurrentHashMap<Integer, AtomicInteger>());
    // }
    // AtomicInteger atomic = srvMap.get(cta.getServerId());
    // if (atomic == null) {
    // srvMap.put(cta.getServerId(), atomic = new AtomicInteger(cta.getMaxLordId()));
    // } else {
    // if (atomic.get() < cta.getMaxLordId()) {
    // atomic.set(cta.getMaxLordId());
    // }
    // LogUtil.error(String.format("platNo :%d, serverId :%d, not unique", cta.getPlatNo(), cta.getServerId()));
    // }
    // }
    // }
    //
    // for (Map.Entry<Integer, Map<Integer, AtomicInteger>> entry : idMap.entrySet()) {
    // Map<Integer, AtomicInteger> srvMap = entry.getValue();
    // for (Map.Entry<Integer, AtomicInteger> srvEntry : srvMap.entrySet()) {
    // AtomicInteger atom = srvEntry.getValue();
    // LogUtil.start(String.format("platNo :%d, server id :%d, atom :%d", entry.getKey(), srvEntry.getKey(),
    // atom.get()));
    // }
    // }
    // }

    /**
     * 直接走数据库 SELECT platNo, serverId, MAX(lordId % 10000000) AS maxLordId FROM p_account GROUP BY platNo, serverId;<br>
     * 查询出来的角色ID会因为关联帐号导致异常
     *
     * @param lordId
     */
    private void loadIds(long lordId) {
        int ptId = (int) (lordId / 100000000000L);
        int sid = (int) ((lordId % 100000000000L) / 10000000L);
        int atomId = (int) (lordId % 10000000L);
        Map<Integer, AtomicInteger> srvMap = idMap.get(ptId);
        if (srvMap == null) {
            idMap.put(ptId, srvMap = new ConcurrentSkipListMap<Integer, AtomicInteger>());
        }
        AtomicInteger atomic = srvMap.get(sid);
        if (atomic == null) {
            srvMap.put(sid, atomic = new AtomicInteger(atomId));
        } else {
            if (atomic.get() < atomId) {
                atomic.set(atomId);
            }
        }
    }

    /**
     * 得到服务器的账号Map
     *
     * @param serverId
     * @return ConcurrentHashMap<Integer                                                                                                                               ,                                                                                                                               Account>
     */
    public ConcurrentHashMap<Integer, Account> getAccountMap(int serverId) {
        ConcurrentHashMap<Integer, Account> map = accountCache.get(serverId);
        if (null == map) {
            map = new ConcurrentHashMap<Integer, Account>();
            accountCache.put(serverId, map);
        }
        return map;
    }

    /**
     * <p>
     * Title: loadAllPlayer
     * </p>
     * <p>
     * Description: 加载所有玩家
     * </p>
     *
     * @see com.game.manager.PlayerDM#loadAllPlayer()
     */
    @Override
    public void loadAllPlayer() {
        new Load().load();
        // LogHelper.ERROR_LOGGER.error("load all players data!!");
        LogUtil.start("load all players data!!");
    }

    public Map<Long, Player> getPlayers() {
        return playerCache;
    }

    /**
     * 创建角色
     *
     * @param account
     * @return
     * @see com.game.manager.PlayerDM#createPlayer(com.game.domain.p.Account)
     */
    @Override
    public Player createPlayer(Account account) {
        return initPlayerData(account);
    }

    /**
     * Method: 剁小号后创建player
     *
     * @Description: @param account @return void @throws
     */
    public Player createPlayerAfterCutSmallId(Account account) {
        return initPlayerDataAfterCutSmallId(account);
    }

    /**
     * @param serverId   服务器id
     * @param accountKey 账号id
     * @return Account
     */
    public Account getAccount(int serverId, int accountKey) {
        return getAccountMap(serverId).get(accountKey);
    }

    /**
     * @param roleId 角色编号
     * @return
     * @see com.game.manager.PlayerDM#getPlayer(java.lang.Long)
     */
    @Override
    public Player getPlayer(Long roleId) {
        Player player = playerCache.get(roleId);

        if (player == null && roleId != 0) {
            LogUtil.error("Player is null roleId=" + roleId);
        }

        return player;
    }

    /**
     * @param nick 角色名
     * @return Player
     * @throws @Title: getPlayer
     * @Description: 根据角色名获得玩家对象
     */
    public Player getPlayer(String nick) {
        return allPlayer.get(nick);
    }

    /**
     * @param roleId 角色编号
     * @return Player
     * @throws @Title: getNewPlayer
     * @Description: 取得为新玩家预制的角色对象
     */
    public Player getNewPlayer(Long roleId) {
        return newPlayerCache.get(roleId);
    }

    /**
     * @param roleId 角色编号
     * @return Player
     * @throws @Title: getNewPlayer
     * @Description: 角色已创建时 预制角色列表中的元素
     */
    public Player removeNewPlayer(Long roleId) {
        return newPlayerCache.remove(roleId);
    }

    public void addPlayer(Player player) {
        playerCache.put(player.roleId, player);
        allPlayer.put(player.lord.getNick(), player);
    }

    /**
     * 玩家上线,加进上线列表和三个月内登陆列表
     *
     * @param player
     */
    public void addOnline(Player player) {
        onlinePlayer.put(player.lord.getNick(), player);
        Player player1 = recThreeMonOnlPlayer.get(player.roleId);
        if (player1 == null) {
            recThreeMonOnlPlayer.put(player.roleId, player);
        }
    }

    /**
     * 添加三个月内登陆的SaveTask
     *
     * @param player
     */
    public void addRecThreeMonthPlayer(Player player) {
        if (!player.isThreeLogin()) {
            recThreeMonOnlPlayer.put(player.roleId, player);
        }
    }

    public void removeOnline(Player player) {
        onlinePlayer.remove(player.lord.getNick());
    }

    public boolean isOnline(Player player) {
        return onlinePlayer.get(player.lord.getNick()) != null;
    }

    public Player getOnlinePlayer(String nick) {
        return onlinePlayer.get(nick);
    }

    public Map<String, Player> getAllOnlinePlayer() {
        return onlinePlayer;
    }

    public Map<Long, Guy> getGuyMap() {
        return guyMap;
    }

    public Map<Long, Player> getRecThreeMonOnlPlayer() {
        return recThreeMonOnlPlayer;
    }

    /**
     * 将账号与角色关联
     */
    private Account createAccount(Account account, Player player) {
        account.setLordId(player.roleId);
        accountDao.insertAccount(account);
        player.account = account;

        getAccountMap(account.getServerId()).put(account.getAccountKey(), account);
        return account;
    }

    /**
     * 刴小号后账号和角色关联
     *
     * @param account
     * @param player
     * @return Account
     */
    private Account createAccountAfterCutSmallId(Account account, Player player) {
        account.setLordId(player.roleId);
        player.account = account;
        account.setCreated(0);
        accountDao.updateIordId(account);
        getAccountMap(account.getServerId()).put(account.getAccountKey(), account);
        return account;
    }

    /**
     * 记录登陆时间
     *
     * @param account void
     */
    public void recordLogin(Account account) {
        accountDao.recordLoginTime(account);
    }

    /**
     * 产生玩家编号
     *
     * @param platNo
     * @param serverId
     * @return long
     */
    private synchronized long createLordId(int platNo, int serverId) {
        Map<Integer, AtomicInteger> srvMap = idMap.get(platNo);
        if (srvMap == null)
            idMap.put(platNo, srvMap = new ConcurrentHashMap<Integer, AtomicInteger>());
        AtomicInteger atomic = srvMap.get(serverId);
        if (atomic == null)
            srvMap.put(serverId, atomic = new AtomicInteger());
        long lordId = platNo * 100000000000L + serverId * 10000000L + atomic.incrementAndGet();
        LogUtil.common(
                String.format("platNo :%d, serverId :%d, create lordId :%d, atomic value :%d", platNo, serverId, lordId, atomic.get()));
        return lordId;
    }

    // public boolean loadPlayerFromDb(Long roleId) {
    // return new Load().loadPlayer(roleId);
    // }

    /**
     * Method: initPlayerData
     *
     * @Description: 初始化玩家数据 @return @return Player @throws
     */
    private Player initPlayerData(Account account) {
        StaticIniLord staticIniLord = staticIniDataMgr.getLordIniData();
        long lordId = createLordId(account.getPlatNo(), account.getServerId());
        account.setLordId(lordId);
        Player player = new Player(lordId);
        createAccount(account, player);
        player.lord = createLord(lordId, staticIniLord);
        newPlayerCache.put(player.roleId, player);
        return player;
    }

    /**
     * Method: 剁小号后初始玩家数据
     *
     * @param account @return @return Player @throws
     */
    private Player initPlayerDataAfterCutSmallId(Account account) {
        StaticIniLord staticIniLord = staticIniDataMgr.getLordIniData();
        long lordId = createLordId(account.getPlatNo(), account.getServerId());
        Lord lord = createLord(lordId, staticIniLord);

        Player player = new Player(lord, TimeHelper.getCurrentSecond());

        createAccountAfterCutSmallId(account, player);
        newPlayerCache.put(player.roleId, player);
        return player;
    }

    /**
     * 创建角色Player(初始化数据)
     *
     * @param player
     * @return boolean
     */
    public boolean createFullPlayer(Player player) {
        StaticIniLord staticIniLord = staticIniDataMgr.getLordIniData();
        DefaultTransactionDefinition def = new DefaultTransactionDefinition();
        def.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRED);
        DataSourceTransactionManager txManager = (DataSourceTransactionManager) GameServer.ac.getBean("transactionManager");
        TransactionStatus status = txManager.getTransaction(def);
        try {
            createTanks(player, staticIniLord);
            createBuilding(player);
            createAD(player);
            createResource(player, staticIniLord);
            createForms(player);
            createBuildQue(player);
            createArmys(player);
            createTankQue(player);
            createRefitQue(player);
            createProps(player, staticIniLord);
            createPropQue(player);
            createEquip(player, staticIniLord);
            createPart(player);
            createChip(player);
            createCombat(player);
            createExplore(player);
            // createPartyMember(player);
            createData(player);

            lordDao.updateNickPortrait(player.lord);
            accountDao.updateCreateRole(player.account);
        } catch (Exception ex) {
            txManager.rollback(status);
            ex.printStackTrace();
            return false;
        }

        txManager.commit(status);

        return true;
    }

    /**
     * 创建角色Lord（初始化数据）
     *
     * @param lordId
     * @param staticIniLord
     * @return Lord
     */
    private Lord createLord(long lordId, StaticIniLord staticIniLord) {
        Lord lord = new Lord();
        int now = TimeHelper.getCurrentSecond();
        if (staticIniLord != null) {
            lord.setLevel(staticIniLord.getLevel());
            lord.setVip(staticIniLord.getVip());
            lord.setGold(staticIniLord.getGoldGive());
            lord.setGoldGive(staticIniLord.getGoldGive());
            lord.setHuangbao(0);
            lord.setRanks(staticIniLord.getRanks());
            lord.setCommand(staticIniLord.getCommand());
            lord.setFameLv(staticIniLord.getFameLv());
            lord.setHonour(staticIniLord.getHonour());
            lord.setPros(staticIniLord.getProsMax());
            lord.setProsMax(staticIniLord.getProsMax());
            lord.setProsTime(now);
            lord.setPower(staticIniLord.getPower());
            lord.setPowerTime(now);
            lord.setNewState(staticIniLord.getNewState());
        } else {
            lord.setLevel(1);
            lord.setVip(0);
            lord.setGold(1000);
            lord.setGoldGive(1000);
            lord.setHuangbao(0);
            lord.setRanks(1);
            lord.setCommand(0);
            lord.setFameLv(1);
            lord.setHonour(0);
            lord.setPros(0);
            lord.setProsMax(0);
            lord.setProsTime(now);
            lord.setPower(20);
            lord.setPowerTime(now);
            lord.setNewState(0);
        }

        lord.setLordId(lordId);
        lord.setPos(-1);
        lord.setEquip(100);
        lord.setEplrTime(TimeHelper.getCurrentDay());

        lordDao.insertLord(lord);
        return lord;
    }

    /**
     * 初始化玩家资源数据
     *
     * @param player
     * @param staticIniLord void
     */
    private void createResource(Player player, StaticIniLord staticIniLord) {
        Resource resource = new Resource();
        resource.setLordId(player.roleId);
        resource.setStone(staticIniLord.getStone());
        resource.setIron(staticIniLord.getIron());
        resource.setOil(staticIniLord.getOil());
        resource.setCopper(staticIniLord.getCopper());
        resource.setSilicon(staticIniLord.getSilicon());

        resource.settStone(staticIniLord.getStone());
        resource.settIron(staticIniLord.getIron());
        resource.settOil(staticIniLord.getOil());
        resource.settCopper(staticIniLord.getCopper());
        resource.settSilicon(staticIniLord.getSilicon());
        resource.setStoreTime(TimeHelper.getCurrentMinute());

        StaticBuildingLv staticCommand = staticBuildingDataMgr.getStaticBuildingLevel(BuildingId.COMMAND, 1);
        resource.setStoneOut(staticCommand.getStoneOut());
        resource.setIronOut(staticCommand.getIronOut());
        resource.setOilOut(staticCommand.getOilOut());
        resource.setCopperOut(staticCommand.getCopperOut());
        resource.setSiliconOut(staticCommand.getSiliconOut());

        resource.setStoneMax(staticCommand.getStoneMax());
        resource.setIronMax(staticCommand.getIronMax());
        resource.setOilMax(staticCommand.getOilMax());
        resource.setCopperMax(staticCommand.getCopperMax());
        resource.setSiliconMax(staticCommand.getSiliconMax());
        resourceDao.insertResource(resource);
        player.resource = resource;
    }

    /**
     * 初始化建筑数据
     *
     * @param player void
     */
    private void createBuilding(Player player) {
        Building building = new Building();
        building.setLordId(player.roleId);
        building.setCommand(1);
        building.setFactory1(1);
        buildingDao.insertBuilding(building);
        player.building = building;
    }

    /**
     * 初始化玩家广告播放数据
     *
     * @param player void
     */
    private void createAD(Player player) {
        if (advertisementDao.selectAdvertisement(player.roleId) == null) {
            Advertisement ad = new Advertisement();
            ad.setLordId(player.roleId);
            Date time = new Date(0);
            ad.setCommondTime(time);
            ad.setLastBuffTime(time);
            ad.setLastBuff2Time(time);
            ad.setLastFirstPayADTime(time);
            ad.setLastLoginTime(time);
            ad.setPowerTime(time);
            ad.setLvUpLastTime(time);
            advertisementDao.insertAdvertisement(ad);
            player.advertisement = ad;
        }
    }

    /**
     * 给新玩家发系统邮件 并持久化玩家数据
     *
     * @param player void
     */
    private void createData(Player player) {
        player.setMaxKey(0);

        StaticMail staticMail = staticMailDataMgr.getStaticMail(MailType.MOLD_WELCOME_MUZHI);
        if (staticMail == null) {
            return;
        }

        int type = staticMail.getType();
        Account account = player.account;

        if (account != null) {
            List<StaticMailPlat> platMailList = staticMailDataMgr.getPlatMail(account.getPlatNo());
            if (account.getChildNo() != 0 && account.getChildNo() != 50) {
                platMailList = staticMailDataMgr.getPlatMail(account.getChildNo());
            }
            if (platMailList != null) {
                for (StaticMailPlat e : platMailList) {
                    Mail mail = new Mail(player.maxKey(), type, e.getMailId(), MailType.STATE_UNREAD, TimeHelper.getCurrentSecond());
                    player.addNewMail(mail);
                }
            } else {
                Mail mail = new Mail(player.maxKey(), type, MailType.MOLD_WELCOME_MUZHI, MailType.STATE_UNREAD, TimeHelper.getCurrentSecond());
                player.addNewMail(mail);
            }

            List<StaticMailNew> newMail = staticMailDataMgr.getMailNew(account.getServerId());
            if (newMail != null) {
                for (StaticMailNew staticMailNew : newMail) {
                    StaticMail smail = staticMailDataMgr.getStaticMail(staticMailNew.getMailId());
                    if (smail != null) {
                        Mail mail = new Mail(player.maxKey(), smail.getType(), smail.getMoldId(), MailType.STATE_UNREAD, TimeHelper.getCurrentSecond());
                        player.addNewMail(mail);
                    }
                }
            }
        } else {
            Mail mail = new Mail(player.maxKey(), type, MailType.MOLD_WELCOME_MUZHI, MailType.STATE_UNREAD, TimeHelper.getCurrentSecond());
            player.addNewMail(mail);
        }
        Mail mail = new Mail(player.maxKey(), type, MailType.MOLD_WELCOME_FANGPIAN, MailType.STATE_UNREAD, TimeHelper.getCurrentSecond());
        player.addNewMail(mail);

        dataDao.insertData(player.serNewData());
    }

    // private void createPartyMember(Player player) {
    // int day = TimeHelper.getCurrentDay();
    // partyDataManager.createMember(player.lord, PartyType.COMMON, day);
    // }

    private void createForms(Player player) {

    }

    /**
     * 初始化新玩家坦克
     *
     * @param player
     * @param staticIniLord void
     */
    private void createTanks(Player player, StaticIniLord staticIniLord) {
        Map<Integer, Integer> staticTanks = staticIniLord.getTanks();
        if (staticTanks == null) {
            return;
        }

        Map<Integer, Tank> map = player.tanks;
        for (Map.Entry<Integer, Integer> entry : staticTanks.entrySet()) {
            Tank tank = new Tank(entry.getKey(), entry.getValue(), 0);
            map.put(tank.getTankId(), tank);
        }
    }

    private void createBuildQue(Player player) {

    }

    private void createArmys(Player player) {

    }

    private void createTankQue(Player player) {

    }

    private void createRefitQue(Player player) {

    }

    /**
     * 初始化新玩家道具
     *
     * @param player
     * @param staticIniLord void
     */
    private void createProps(Player player, StaticIniLord staticIniLord) {
        Map<Integer, Integer> staticProps = staticIniLord.getProps();
        if (staticProps == null) {
            return;
        }

        Map<Integer, Prop> map = player.props;
        for (Map.Entry<Integer, Integer> entry : staticProps.entrySet()) {
            Prop prop = new Prop(entry.getKey(), entry.getValue());
            map.put(prop.getPropId(), prop);
        }
    }

    /**
     * 初始化新玩家装备
     *
     * @param player
     * @param staticIniLord void
     */
    private void createEquip(Player player, StaticIniLord staticIniLord) {
        Map<Integer, Integer> staticEquips = staticIniLord.getEquips();
        if (staticEquips == null) {
            return;
        }

        Map<Integer, Equip> map = player.equips.get(0);
        for (Map.Entry<Integer, Integer> entry : staticEquips.entrySet()) {
            Equip equip = new Equip(player.maxKey(), entry.getKey(), entry.getValue(), 0, 0);
            map.put(equip.getKeyId(), equip);
        }
    }

    private void createPropQue(Player player) {

    }

    private void createPart(Player player) {

    }

    private void createChip(Player player) {

    }

    private void createCombat(Player player) {

    }

    private void createExplore(Player player) {

    }

    /**
     * 增加玩家活动道具
     *
     * @param player
     * @param propId
     * @param count
     * @param from   void
     * @throws @Title: addActivityProp
     * @Description: 增加玩家活动道具
     */
    public void addActivityProp(Player player, int propId, int count, AwardFrom from) {
        rewardService.addActivityProp(player, propId, count, from);
    }

    /**
     * 扣除玩家活动道具
     *
     * @param player
     * @param count
     * @param from
     * @return
     */
    public int subActivityProp(Player player, int propId, int count, AwardFrom from) {
        return rewardService.subActivityProp(player, propId, count, from);
    }

    /**
     * Method: addEffect
     *
     * @param player
     * @param id
     * @param time   buff持续时间增加time
     * @Description: 添加加成效果
     */
    public Effect addEffect(Player player, int id, int time) {
        if (time < 0) {
            return null;
        }

        // 皮肤加成相关
        if ((id >= EffectType.CHANGE_SURFACE_1 && id <= EffectType.CHANGE_SURFACE_7) || (id > 1000 && id < 3000)) {
            // 皮肤功能打开
            if (functionPlanDataMgr.isSkinOpen()) {
                Effect effect;
                if (player.surface != 0) {
                    effect = player.effects.remove(player.surface + 10);
                    // 删除的effect存入skins供皮肤累计时间
                    player.surfaceSkins.put(effect.getEffectId(), effect);
                    vaildEffect(player, player.surface + 10, -1);
                }
                // 如果已经使用过该皮肤且皮肤没有过期，则把时间累加
                effect = player.surfaceSkins.get(id);
                if (effect != null) {
                    effect.setEndTime(effect.getEndTime() + time);
                } else {
                    int now = TimeHelper.getCurrentSecond();
                    effect = new Effect(id, now + time);
                }
                player.effects.put(id, effect);
                player.surfaceSkins.put(id, effect);
                vaildEffect(player, id, 1);
                return effect;
            }
            // 没有打开皮肤管理功能
            if (player.surface != 0) {
                player.effects.remove(player.surface + 10);
                vaildEffect(player, player.surface + 10, -1);
            }
        }
        // 超级增伤减伤以及世界加速
        else if (id >= EffectType.ADD_HURT_SUPUR && id <= EffectType.MARCH_SPEED_SUPER) {
            if (player.effects.containsKey(id - 12)) {
                player.effects.remove(id - 12);
            }
        }

        // 增伤减伤以及世界加速
        else if (id >= EffectType.ADD_HURT && id <= EffectType.MARCH_SPEED) {
            if (player.effects.containsKey(id + 12)) {
                return null;
            }
        }

        Effect effect = player.effects.get(id);
        if (effect != null) {

            int oldEndTime = effect.getEndTime();

            effect.setEndTime(effect.getEndTime() + time);

            if (id == EffectType.ATTACK_FREE) {
                LogLordHelper.attackFreeBuff(AwardFrom.DO_SOME, player, 1, oldEndTime, effect.getEndTime(), 0);
            }

        } else {
            int now = TimeHelper.getCurrentSecond();
            effect = new Effect(id, now + time);
            // 永久性BUFF
            if (time == 0) {
                effect.setEndTime(0);
            }
            player.effects.put(id, effect);
            vaildEffect(player, id, 1);

            if (id == EffectType.MARCH_SPEED || id == EffectType.MARCH_SPEED_SUPER) {
                worldService.recalcArmyMarch(player);
            }

            if (id == EffectType.ATTACK_FREE) {
                LogLordHelper.attackFreeBuff(AwardFrom.DO_SOME, player, 1, 0, effect.getEndTime(), 0);
            }
        }

        return effect;
    }

    /**
     * @param player
     * @param id
     * @param factor void
     * @throws @Title: vaildEffect
     * @Description: 使增益效果生效，或移除增益效果(factor == -1)
     */
    public void vaildEffect(Player player, int id, int factor) {
        Resource resource = player.resource;
        if (id == EffectType.ALL_PRODUCT) {
            int v = factor * 50;
            resource.setStoneOutF(resource.getStoneOutF() + v);
            resource.setSiliconOutF(resource.getSiliconOutF() + v);
            resource.setIronOutF(resource.getIronOutF() + v);
            resource.setCopperOutF(resource.getCopperOutF() + v);
            resource.setOilOutF(resource.getOilOutF() + v);
        } else if (id == EffectType.BACK_ALL_PRODUCT) {
            int v = factor * 50;
            resource.setStoneOutF(resource.getStoneOutF() + v);
            resource.setSiliconOutF(resource.getSiliconOutF() + v);
            resource.setIronOutF(resource.getIronOutF() + v);
            resource.setCopperOutF(resource.getCopperOutF() + v);
            resource.setOilOutF(resource.getOilOutF() + v);
        } else if (id == EffectType.STONE_PRODUCT) {
            int v = factor * 50;
            resource.setStoneOutF(resource.getStoneOutF() + v);
        } else if (id == EffectType.IRON_PRODUCT) {
            int v = factor * 50;
            resource.setIronOutF(resource.getIronOutF() + v);
        } else if (id == EffectType.OIL_PRODUCT) {
            int v = factor * 50;
            resource.setOilOutF(resource.getOilOutF() + v);
        } else if (id == EffectType.COPPER_PRODUCT) {
            int v = factor * 50;
            resource.setCopperOutF(resource.getCopperOutF() + v);
        } else if (id == EffectType.SILICON_PRODUCT) {
            int v = factor * 50;
            resource.setSiliconOutF(resource.getSiliconOutF() + v);
        } else if (id == EffectType.CHANGE_SURFACE_2) {
            int v = factor * 25;
            resource.setStoneOutF(resource.getStoneOutF() + v);
            resource.setSiliconOutF(resource.getSiliconOutF() + v);
            resource.setIronOutF(resource.getIronOutF() + v);
            resource.setCopperOutF(resource.getCopperOutF() + v);
            resource.setOilOutF(resource.getOilOutF() + v);
            if (factor > 0) {
                player.surface = 2;
            } else {
                player.surface = 0;
            }
        } else if (id == EffectType.CHANGE_SURFACE_992) {
            int v = factor * 60;
            resource.setStoneOutF(resource.getStoneOutF() + v);
            resource.setSiliconOutF(resource.getSiliconOutF() + v);
            resource.setIronOutF(resource.getIronOutF() + v);
            resource.setCopperOutF(resource.getCopperOutF() + v);
            resource.setOilOutF(resource.getOilOutF() + v);
            if (factor > 0) {
                player.surface = 992;
            } else {
                player.surface = 0;
            }
        } else if (id == EffectType.CHANGE_SURFACE_2005) {
            int v = factor * 100;
            resource.setStoneOutF(resource.getStoneOutF() + v);
            resource.setSiliconOutF(resource.getSiliconOutF() + v);
            resource.setIronOutF(resource.getIronOutF() + v);
            resource.setCopperOutF(resource.getCopperOutF() + v);
            resource.setOilOutF(resource.getOilOutF() + v);
            if (factor > 0) {
                player.surface = 2005;
            } else {
                player.surface = 0;
            }
        } else if ((id >= EffectType.CHANGE_SURFACE_1 && id <= EffectType.CHANGE_SURFACE_7) || (id > 1000 && id < 3000)) {
            if (factor > 0) {
                player.surface = id - 10;
            } else {
                player.surface = 0;
            }
        } else if (id == EffectType.WAR_CHAMPION) {
            int v = factor * 50;
            resource.setStoneOutF(resource.getStoneOutF() + v);
            resource.setSiliconOutF(resource.getSiliconOutF() + v);
            resource.setIronOutF(resource.getIronOutF() + v);
            resource.setCopperOutF(resource.getCopperOutF() + v);
            resource.setOilOutF(resource.getOilOutF() + v);
        }

        if (id == EffectType.ADD_RESOURCE_SPEED_PS) {
            int v = factor * 5;
            resource.setStoneOutF(resource.getStoneOutF() + v);
            resource.setSiliconOutF(resource.getSiliconOutF() + v);
            resource.setIronOutF(resource.getIronOutF() + v);
            resource.setCopperOutF(resource.getCopperOutF() + v);
            resource.setOilOutF(resource.getOilOutF() + v);
        }

        if (id == EffectType.SUB_RESOURCE_SPEED_PS) {
            int v = factor * (-10);
            resource.setStoneOutF((resource.getStoneOutF() + v) < 0 ? 0 : (resource.getStoneOutF() + v));
            resource.setSiliconOutF((resource.getSiliconOutF() + v) < 0 ? 0 : (resource.getSiliconOutF() + v));
            resource.setIronOutF((resource.getIronOutF() + v) < 0 ? 0 : (resource.getIronOutF() + v));
            resource.setCopperOutF((resource.getCopperOutF() + v) < 0 ? 0 : (resource.getCopperOutF() + v));
            resource.setOilOutF((resource.getOilOutF() + v) < 0 ? 0 : (resource.getOilOutF() + v));
        }

        if (id == EffectType.ACTIVITY_RESOURCE_ADD_SPEED) {
            int v = factor * 100;
            resource.setStoneOutF(resource.getStoneOutF() + v);
            resource.setSiliconOutF(resource.getSiliconOutF() + v);
            resource.setIronOutF(resource.getIronOutF() + v);
            resource.setCopperOutF(resource.getCopperOutF() + v);
            resource.setOilOutF(resource.getOilOutF() + v);
        }
    }

    /**
     * @param player void
     * @throws @Title: clearAttackFree
     * @Description: 清除免战状态
     */
    public void clearAttackFree(Player player) {
        player.effects.remove(EffectType.ATTACK_FREE);
    }

    // public boolean addResourceOutAndMax(int buildingId, int buildingLv,
    // Resource resource) {
    // StaticBuildingLv staticBuildingLevel =
    // staticBuildingDataMgr.getStaticBuildingLevel(buildingId, buildingLv);
    // resource.setStoneMax(staticBuildingLevel.getStoneMaxAdd() +
    // resource.getStoneMax());
    // resource.setIronMax(staticBuildingLevel.getIronMaxAdd() +
    // resource.getIronMax());
    // resource.setOilMax(staticBuildingLevel.getOilMaxAdd() +
    // resource.getOilMax());
    // resource.setCopperMax(staticBuildingLevel.getCopperMaxAdd() +
    // resource.getCopperMax());
    // resource.setSiliconMax(staticBuildingLevel.getSiliconMaxAdd() +
    // resource.getSiliconMax());
    //
    // resource.setStoneOut(staticBuildingLevel.getStoneOutAdd() +
    // resource.getStoneOut());
    // resource.setIronOut(staticBuildingLevel.getIronOutAdd() +
    // resource.getIronOut());
    // resource.setOilOut(staticBuildingLevel.getOilOutAdd() +
    // resource.getOilOut());
    // resource.setCopperOut(staticBuildingLevel.getCopperOutAdd() +
    // resource.getCopperOut());
    // resource.setSiliconOut(staticBuildingLevel.getSiliconOutAdd() +
    // resource.getSiliconOut());
    //
    // return true;
    // }
    //
    // public void subResourceOutAndMax(int buildingId, int buildingLv, Resource
    // resource) {
    // StaticBuildingLv staticBuildingLevel =
    // staticBuildingDataMgr.getStaticBuildingLevel(buildingId, buildingLv);
    // resource.setStoneMax(resource.getStoneMax() -
    // staticBuildingLevel.getStoneMaxAdd());
    // resource.setIronMax(resource.getIronMax() -
    // staticBuildingLevel.getIronMaxAdd());
    // resource.setOilMax(resource.getOilMax() -
    // staticBuildingLevel.getOilMaxAdd());
    // resource.setCopperMax(resource.getCopperMax() -
    // staticBuildingLevel.getCopperMaxAdd());
    // resource.setSiliconMax(resource.getSiliconMax() -
    // staticBuildingLevel.getSiliconMaxAdd());
    //
    // resource.setStoneOut(resource.getStoneOut() -
    // staticBuildingLevel.getStoneOutAdd());
    // resource.setIronOut(resource.getIronOut() -
    // staticBuildingLevel.getIronOutAdd());
    // resource.setOilOut(resource.getOilOut() -
    // staticBuildingLevel.getOilOutAdd());
    // resource.setCopperOut(resource.getCopperOut() -
    // staticBuildingLevel.getCopperOutAdd());
    // resource.setSiliconOut(resource.getSiliconOut() -
    // staticBuildingLevel.getSiliconOutAdd());
    // }

    /**
     * 升建筑后增加玩家资源产量和最大存量
     *
     * @param buildingId
     * @param buildingLv
     * @param resource
     * @return boolean
     */
    public boolean addResourceOutAndMax(int buildingId, int buildingLv, Resource resource) {

        if (buildingLv == 0)
            return true;
        StaticBuildingLv staticBuildingLevel = staticBuildingDataMgr.getStaticBuildingLevel(buildingId, buildingLv);
        resource.setStoneMax(staticBuildingLevel.getStoneMaxAdd() + resource.getStoneMax());
        resource.setIronMax(staticBuildingLevel.getIronMaxAdd() + resource.getIronMax());
        resource.setOilMax(staticBuildingLevel.getOilMaxAdd() + resource.getOilMax());
        resource.setCopperMax(staticBuildingLevel.getCopperMaxAdd() + resource.getCopperMax());
        resource.setSiliconMax(staticBuildingLevel.getSiliconMaxAdd() + resource.getSiliconMax());

        resource.setStoneOut(staticBuildingLevel.getStoneOutAdd() + resource.getStoneOut());
        resource.setIronOut(staticBuildingLevel.getIronOutAdd() + resource.getIronOut());
        resource.setOilOut(staticBuildingLevel.getOilOutAdd() + resource.getOilOut());
        resource.setCopperOut(staticBuildingLevel.getCopperOutAdd() + resource.getCopperOut());
        resource.setSiliconOut(staticBuildingLevel.getSiliconOutAdd() + resource.getSiliconOut());

        return true;
    }

    /**
     * 拆除工厂后减少玩家最大资源存量和产量
     *
     * @param buildingId
     * @param buildingLv
     * @param resource   void
     */
    public void subResourceOutAndMax(int buildingId, int buildingLv, Resource resource) {
        StaticBuildingLv staticBuildingLevel = staticBuildingDataMgr.getStaticBuildingLevel(buildingId, buildingLv);
        resource.setStoneMax(resource.getStoneMax() - staticBuildingLevel.getStoneMax());
        resource.setIronMax(resource.getIronMax() - staticBuildingLevel.getIronMax());
        resource.setOilMax(resource.getOilMax() - staticBuildingLevel.getOilMax());
        resource.setCopperMax(resource.getCopperMax() - staticBuildingLevel.getCopperMax());
        resource.setSiliconMax(resource.getSiliconMax() - staticBuildingLevel.getSiliconMax());

        resource.setStoneOut(resource.getStoneOut() - staticBuildingLevel.getStoneOut());
        resource.setIronOut(resource.getIronOut() - staticBuildingLevel.getIronOut());
        resource.setOilOut(resource.getOilOut() - staticBuildingLevel.getOilOut());
        resource.setCopperOut(resource.getCopperOut() - staticBuildingLevel.getCopperOut());
        resource.setSiliconOut(resource.getSiliconOut() - staticBuildingLevel.getSiliconOut());
    }

    /**
     * 得到玩家建筑等级
     *
     * @param buildingId
     * @param building
     * @return int
     */
    public static int getBuildingLv(int buildingId, Building building) {
        switch (buildingId) {
            case BuildingId.COMMAND:
                return building.getCommand();
            case BuildingId.WARE_1:
                return building.getWare1();
            case BuildingId.REFIT:
                return building.getRefit();
            case BuildingId.WORKSHOP:
                return building.getWorkShop();
            case BuildingId.TECH:
                return building.getTech();
            case BuildingId.FACTORY_1:
                return building.getFactory1();
            case BuildingId.FACTORY_2:
                return building.getFactory2();
            case BuildingId.STONE:
                return 0;
            case BuildingId.SILICON:
                return 0;
            case BuildingId.IRON:
                return 0;
            case BuildingId.COPPER:
                return 0;
            case BuildingId.OIL:
                return 0;
            case BuildingId.WARE_2:
                return building.getWare2();
            case BuildingId.MATERIAL:
                return building.getLeqm();
            default:
                return 0;
        }
    }

    /**
     * 工厂最大等级
     *
     * @param player
     * @param millId
     * @return int
     */
    public int getMillTopLv(Player player, int millId) {
        int lv = 0;
        Iterator<Mill> it = player.mills.values().iterator();
        while (it.hasNext()) {
            Mill mill = it.next();
            if (mill.getId() == millId && mill.getLv() > lv) {
                lv = mill.getLv();
            }
        }
        return lv;
    }

    /**
     * 工厂数量
     *
     * @param player
     * @param millId
     * @param lv
     * @return int
     */
    public int getMillCount(Player player, int millId, int lv) {
        int count = 0;
        Iterator<Mill> it = player.mills.values().iterator();
        while (it.hasNext()) {
            Mill mill = it.next();
            if (mill.getId() == millId && mill.getLv() >= lv) {
                count++;
            }
        }
        return count;
    }

    /**
     * 计算受保护资源量
     *
     * @param player
     * @return long
     */
    public long calcProtect(Player player) {
        int lv1 = getBuildingLv(BuildingId.WARE_1, player.building);
        int lv2 = getBuildingLv(BuildingId.WARE_2, player.building);
        long protect = 0;
        if (lv1 != 0) {
            protect += staticBuildingDataMgr.getStaticBuildingLevel(BuildingId.WARE_1, lv1).getStoneMax();
        }

        if (lv2 != 0) {
            protect += staticBuildingDataMgr.getStaticBuildingLevel(BuildingId.WARE_2, lv2).getStoneMax();
        }

        int storeF = player.resource.getStoreF();
        Map<Integer, PartyScience> sciences = partyDataManager.getScience(player);
        if (sciences != null) {
            PartyScience science = sciences.get(ScienceId.PARTY_STORAGE);
            if (science != null) {
                storeF += science.getScienceLv();
            }
        }

        protect = (long) (protect * (storeF + NumberHelper.HUNDRED_INT) / NumberHelper.HUNDRED_INT);
        return protect;
    }

    /**
     * 计算部队载重
     *
     * @param player
     * @param form
     * @param isRuins
     * @return long
     */
    public long calcLoad(Player player, Form form, boolean isRuins) {
        long load = 0L;
        int[] p = form.p;
        int[] c = form.c;

        // 载重技术
        int scienceLv = 0;

        float scienceLv215 = 0.0f;

        Map<Integer, PartyScience> sciences = partyDataManager.getScience(player);
        if (sciences != null) {
            PartyScience science = sciences.get(ScienceId.PAY_LOAD);
            if (science != null) {
                scienceLv = science.getScienceLv();
            }

            PartyScience science215 = sciences.get(ScienceId.PAY_LOAD_215);
            if (science215 != null) {
                scienceLv215 = science215.getScienceLv();
            }
        }

        // 荣耀生存玩法buff
        int honourAdd = 0;
        StaticHonourBuff honourBuff = honourDataManager.getHonourBuff(player.lord.getPos());
        if (honourBuff != null) {
            Map<Integer, Integer> attrBuff = honourBuff.getAttrBuff();
            if (attrBuff.containsKey(AttrId.LOAD_CAPACITY_ALL)) {
                honourAdd = honourBuff.getAttrBuff().get(AttrId.LOAD_CAPACITY_ALL);
                if (honourBuff.getType() == -1) {
                    honourAdd = -honourAdd;
                }
            }
        }

        for (int i = 0; i < p.length; i++) {
            if (p[i] != 0) {
                StaticTank staticTank = staticTankDataMgr.getStaticTank(p[i]);
                // 作战实验室单兵种载重加成
                int labAdd = fightLabService.getSpecilAttrAdd(player, AttrId.LOAD_CAPACITY_ALL + staticTank.getType());
                int labAddAll = fightLabService.getSpecilAttrAdd(player, AttrId.LOAD_CAPACITY_ALL);

                int heroAtio = 0;

                // 英雄觉醒被动技能增加载重百分百

                AwakenHero awakenHero = form.getAwakenHero();
                if (awakenHero != null) {
                    for (Map.Entry<Integer, Integer> entry : awakenHero.getSkillLv().entrySet()) {
                        if (entry.getValue() <= 0) {
                            continue;
                        }
                        StaticHeroAwakenSkill staticHeroAwakenSkill = staticHeroDataMgr.getHeroAwakenSkill(entry.getKey(),
                                entry.getValue());
                        if (staticHeroAwakenSkill == null) {
                            LogUtil.error("觉醒将领技能未配置:" + entry.getKey() + " 等级:" + entry.getValue());
                            continue;
                        }
                        if (staticHeroAwakenSkill.getEffectType() == HeroConst.HERO_ADD_LOAD) {
                            String val = staticHeroAwakenSkill.getEffectVal();
                            if (val != null && !val.isEmpty()) {
                                heroAtio += Float.valueOf(val);
                            }
                        }
                    }
                }
                float addtion = labAdd + labAddAll + heroAtio + scienceLv + honourAdd + NumberHelper.HUNDRED_INT;

                //大于等于4品质以上的才载重
                if (staticTank.getGrade() == 4) {
                    addtion = addtion + scienceLv215 * 0.5f;
                }
                if (staticTank.getGrade() >= 5) {
                    addtion = addtion + scienceLv215;
                }
                load += (staticTank.getPayload() * (long) c[i]) * ((addtion * 1.0f) / NumberHelper.HUNDRED_INT);

            }
        }

        // 废墟载重减半
        if (isRuins) {
            load = (long) ((load * Constant.RUINS_LOAD_REDUCE * 1.0f) / NumberHelper.TEN_THOUSAND);
        }

        return load;
    }

    /**
     * Method: takeNick
     *
     * @Description: 占用一个名字 @param nick @return @return boolean @throws
     */
    public boolean takeNick(String nick) {
        synchronized (usedNames) {
            if (usedNames.contains(nick)) {
                return false;
            }

            usedNames.add(nick);
            return true;
        }
    }

    /**
     * 改名
     *
     * @param player
     * @param newNick void
     */
    public void rename(Player player, String newNick) {
        String nick = player.lord.getNick();
        usedNames.remove(nick);
        onlinePlayer.remove(nick);
        onlinePlayer.put(newNick, player);
        allPlayer.remove(nick);
        allPlayer.put(newNick, player);
        player.lord.setNick(newNick);
    }

    /**
     * 名字是否可用
     *
     * @param nick
     * @return boolean
     */
    public boolean canUseName(String nick) {
        return !usedNames.contains(nick);
    }

    // public boolean subGoldWithCommit(Lord lord, int cost, GoldCost type) {
    // if (subGold(lord, cost, type)) {
    // lordDao.updateGold(lord);
    // return true;
    // }
    //
    // return false;
    // }

    /**
     * Method: modifyMetal
     *
     * @Description: 修改记忆金属 @param lord @param add @param commit @return void @throws
     */
    public int modifyMetal(Lord lord, int add) {
        return rewardService.modifyMetal(lord, add);
    }

    /**
     * Method: modifyFitting
     *
     * @Description: 修改零件数量 @param lord @param add @param commit @return void @throws
     */
    public int modifyFitting(Lord lord, int add) {
        return rewardService.modifyFitting(lord, add);
    }

    /**
     * Method: modifyDraw
     *
     * @Description: 修改改造图纸数量 @param lord @param add @param commit @return void @throws
     */
    public int modifyDraw(Lord lord, int add) {
        return rewardService.modifyDraw(lord, add);
    }

    /**
     * Method: addEquipCapacity
     *
     * @Description: 增加装备仓库容量，扣除金币 @param lord @param cost @param add @return @return boolean @throws
     */
    public boolean addEquipCapacity(Player player, int cost, int add) {
        if (subGold(player, cost, AwardFrom.UP_CAPACITY)) {
            Lord lord = player.lord;
            lord.setEquip(lord.getEquip() + add);
            return true;
        }

        return false;
    }

    /**
     * Method: subGold
     *
     * @Description: 扣除玩家金币，不写数据库 @param lord @param sub @param type @return @return boolean @throws
     */
    public boolean subGold(Player player, int sub, AwardFrom from) {
        return rewardService.subGold(player, sub, from);
    }

    /**
     * 跨服活动中扣除金币
     *
     * @param player
     * @param sub
     * @param from
     * @return boolean
     */
    public boolean subGoldCross(Player player, int sub, AwardFrom from) {
        return rewardService.subGoldCross(player, sub, from);
    }

    /**
     * Method: addGold
     *
     * @Description: 非充值增加玩家金币 @param lord @param add @param type @return @return boolean @throws
     */
    public boolean addGold(Player player, int add, AwardFrom from) {
        return rewardService.addGold(player, add, from);
    }

    /**
     * Method: subHuangbao
     *
     * @Description: 扣除荒宝碎片 @param lord @param sub @return void @throws
     */
    public void subHuangbao(Player player, int sub, AwardFrom from) {
        rewardService.subHuangbao(player, sub, from);
    }

    /**
     * Method: fullPower
     *
     * @Description: 能量是否达到上限 @param lord @return @return boolean @throws
     */
    public boolean fullPower(Lord lord) {
        return lord.getPower() >= POWER_MAX;
    }

    /**
     * Method: backPower
     *
     * @Description: 恢复能量 @param lord @param now @return void @throws
     */
    public void backPower(Lord lord, int now) {
        int period = now - lord.getPowerTime();
        int back = period / POWER_BACK_SECOND;
        if (back > 0) {
            int old = lord.getPower();
            int power = lord.getPower() + back;
            power = (power > POWER_MAX) ? POWER_MAX : power;
            lord.setPowerTime(lord.getPowerTime() + (power - lord.getPower()) * POWER_BACK_SECOND);
            int add = (power - old) < 0 ? 0 : (power - old);
            addPower(lord, add);
        }
    }

    /**
     * Method: subPower
     *
     * @Description: 扣除能量 @param lord @param sub @return @return boolean @throws
     */
    public boolean subPower(Lord lord, int sub) {
        if (lord.getPower() < sub) {
            return false;
        }

        if (fullPower(lord)) {
            lord.setPowerTime(TimeHelper.getCurrentSecond());
        }

        lord.setPower(lord.getPower() - sub);
        return true;
    }

    /**
     * Method: addPower
     *
     * @Description: 增加能量 @param lord @param add @return void @throws
     */
    public void addPower(Lord lord, int add) {
        rewardService.addPower(lord, add);
    }

    /**
     * Method: leftBackPowerTime
     *
     * @Description: 下次恢复能量的剩余时间秒数 @param lord @return @return int @throws
     */
    public int leftBackPowerTime(Lord lord) {
        if (!fullPower(lord)) {
            return lord.getPowerTime() + POWER_BACK_SECOND - TimeHelper.getCurrentSecond();
        }
        return 0;
    }

    /**
     * Method: fullPros
     *
     * @Description: 繁荣度是否达到上限 @param lord @return @return boolean @throws
     */
    public boolean fullPros(Lord lord) {
        return lord.getPros() >= lord.getProsMax();
    }

    /**
     * Method: backProsWith
     *
     * @Description: 1分钟恢复一点繁荣度, 并写数据库 @param lord @param now @return void @throws
     */
    public void backPros(Player player, int now) {
        Lord lord = player.lord;
        int period = now - lord.getProsTime();
        int restoreUnit = PROS_BACK_SECOND;
        // 若是废墟,2分钟恢复一点
        if (isRuins(player)) {
            restoreUnit *= 2;
        }

        int back = period / restoreUnit;
        if (back > 0) {
            int max = lord.getProsMax();
            back = lord.getPros() + back;
            back = (back > max) ? max : back;
            lord.setProsTime(lord.getProsTime() + (back - lord.getPros()) * restoreUnit);
            lord.setPros(back);

            outOfRuins(player);
        }
    }

    // public boolean isRuins(Lord lord) {
    // if (lord.getProsMax() < 600) {
    // if (lord.getPros() == 0) {
    // return true;
    // }
    // } else {
    // if (lord.getPros() < 600) {
    // return true;
    // }
    // }
    //
    // return false;
    // }

    /**
     * 是否是废墟
     *
     * @param player
     * @return boolean
     */
    public boolean isRuins(Player player) {
        return (player.ruins.isRuins());
    }

    /**
     * 成为废墟 Method: becomeRuins
     *
     * @return void @throws
     */
    public void becomeRuins(Player defencer, Player attacker) {
        // 不是废墟才需要判断会不会成为废墟
        if (!isRuins(defencer)) {
            // 1.玩家繁荣度最大值低于600时，遭到攻击后繁荣度被打为0才变为废墟，直至恢复满繁荣度脱离废墟
            // 2.玩家繁荣度最大值不低于600时，遭到攻击后繁荣度被打下600变为废墟，直至恢复到不低于600脱离废墟
            if ((defencer.lord.getProsMax() < 600 && defencer.lord.getPros() == 0)
                    || (defencer.lord.getProsMax() >= 600 && defencer.lord.getPros() < 600)) {
                Ruins r = defencer.ruins;
                r.setRuins(true);
                r.setLordId(attacker.lord.getLordId());
                r.setAttackerName(attacker.lord.getNick());
            }
        }
    }

    /**
     * 脱离废墟 Method: outOfRuins
     *
     * @param player @return void @throws
     */
    public void outOfRuins(Player player) {
        // 判断是否是废墟,若是才需要脱离
        if (isRuins(player)) {
            if ((player.lord.getProsMax() < 600 && player.lord.getPros() >= player.lord.getProsMax())
                    || (player.lord.getProsMax() >= 600 && player.lord.getPros() >= 600)) {
                Ruins r = player.ruins;
                r.setRuins(false);
                r.setLordId(0);
                r.setAttackerName("");
            }
        }
    }

    /**
     * Method: addPros
     *
     * @Description: 增加繁荣度上限, 不写数据库 @param lord @param add @return @return boolean @throws
     */
    public boolean addProsMax(Player player, int add) {
        if (add <= 0) {
            return false;
        }
        int oldPros = player.lord.getPros();
        player.lord.setProsMax(player.lord.getProsMax() + add);
        player.lord.setPros(player.lord.getPros() + add);

        outOfRuins(player);
        updDay7ActSchedule(player, 11, player.lord.getProsMax());
        afterAddPros(player, oldPros, player.lord.getPros());
        return true;
    }

    /**
     * 扣除最大繁荣度
     *
     * @param player
     * @param sub
     */
    public void subProsMax(Player player, int sub) {
        int pros = player.lord.getProsMax() - sub;
        if (pros < 0) {
            pros = 0;
        }
        player.lord.setProsMax(pros);

        if (player.lord.getPros() > player.lord.getProsMax()) {
            player.lord.setPros(player.lord.getProsMax());
        }
        // 更新材料生产速度
        lordEquipService.updateLembProductSpeed(player);
        // 更新玩家最强实力
        playerEventService.calcStrongestFormAndFight(player);
    }

    /**
     * Method: subPros
     *
     * @Description: 扣除繁荣度 @param player @param sub @return @return boolean @throws
     */
    public void subPros(Player player, int sub) {
        int pros = player.lord.getPros() - sub;
        if (pros < 0) {
            pros = 0;
        }

        if (fullPros(player.lord)) {
            player.lord.setProsTime(TimeHelper.getCurrentSecond());
        }
        int oldPros = player.lord.getPros();
        player.lord.setPros(pros);
        if (oldPros != player.lord.getPros()) {
            // 更新材料生产速度
            lordEquipService.updateLembProductSpeed(player);
            // 更新玩家最强实力
            playerEventService.calcStrongestFormAndFight(player);
        }
    }

    /**
     * 被攻击扣除繁荣度
     *
     * @param defencer @param sub @param attacker @return void @throws
     */
    public void subProsByAttack(Player defencer, int sub, Player attacker) {
        subPros(defencer, sub);
        becomeRuins(defencer, attacker);
    }

    /**
     * 增加繁荣度
     *
     * @param player
     * @param add    void
     */
    public void addPros(Player player, int add) {
        rewardService.addPros(player, add);
    }

    /**
     * 增加繁荣度之后处理
     *
     * @param player
     * @param oldPros
     * @param curPros void
     */
    public void afterAddPros(Player player, int oldPros, int curPros) {
        if (curPros != oldPros) {
            int oldLv = staticLordDataMgr.getStaticProsLv(oldPros).getProsLv();
            int curLv = staticLordDataMgr.getStaticProsLv(curPros).getProsLv();
            if (oldLv < curLv) {
                lordEquipService.checkAndUnlockLordEquipTechnical(player, curLv);
            }
            // 更新玩家材料生产速度
            lordEquipService.updateLembProductSpeed(player);
            // 更新玩家最强实力
            playerEventService.calcStrongestFormAndFight(player);
        }
    }

    // public boolean subProsWithCommit(Lord lord, int sub) {
    // if (!subPros(lord, sub)) {
    // return false;
    // }
    //
    // lordDao.updatePros(lord);
    // return true;
    // }

    /**
     * Method: leftBackProsTime
     *
     * @Description: 下次恢复繁荣度的剩余时间秒数 @param lord @return @return int @throws
     */
    public int leftBackProsTime(Lord lord) {
        if (!fullPros(lord)) {
            return lord.getProsTime() + PROS_BACK_SECOND - TimeHelper.getCurrentSecond();
        }
        return 0;
    }

    /**
     * Method: modifyStone
     *
     * @Description: 修改宝石数量 @param resource @param add @param commit @return void @throws
     */
    public CommonPb.Atom2 modifyStone(Player player, long add, AwardFrom from) {
        return rewardService.modifyStone(player, add, from);
    }

    /**
     * 修改水晶数量
     *
     * @param resource
     * @param add      void
     */
    public void modifyStone(Resource resource, long add) {
        if (add > 0) {
            resource.settStone(resource.gettStone() + add);
        }
        resource.setStone(resource.getStone() + add);
    }

    /**
     * Method: modifyIron
     *
     * @Description: 修改铁资源数量 @param resource @param add @param commit @return void @throws
     */
    public void modifyIron(Player player, long add, AwardFrom from) {
        rewardService.modifyIron(player, add, from);
    }

    /**
     * 更新铁数量
     *
     * @param resource
     * @param add      void
     */
    public void modifyIron(Resource resource, long add) {
        if (add > 0) {
            resource.settIron(resource.gettIron() + add);
        }
        resource.setIron(resource.getIron() + add);
    }

    /**
     * Method: modifyOil
     *
     * @Description: 修改石油资源数量 @param resource @param add @param commit @return void @throws
     */
    public void modifyOil(Player player, long add, AwardFrom from) {
        rewardService.modifyOil(player, add, from);
    }

    /**
     * 修改石油数量
     *
     * @param resource
     * @param add      void
     */
    public void modifyOil(Resource resource, long add) {
        if (add > 0) {
            resource.settOil(resource.gettOil() + add);
        }
        resource.setOil(resource.getOil() + add);
    }

    /**
     * Method: modifyCopper
     *
     * @Description: 修改铜资源数量 @param resource @param add @param commit @return void @throws
     */
    public void modifyCopper(Player player, long add, AwardFrom from) {
        rewardService.modifyCopper(player, add, from);
    }

    /**
     * 修改铜数量
     *
     * @param resource
     * @param add      void
     */
    public void modifyCopper(Resource resource, long add) {
        if (add > 0) {
            resource.settCopper(resource.gettCopper() + add);
        }
        resource.setCopper(resource.getCopper() + add);
    }

    /**
     * Method: modifySilicon
     *
     * @Description: 修改硅资源数量 @param resource @param add @param commit @return void @throws
     */
    public void modifySilicon(Player player, long add, AwardFrom from) {
        rewardService.modifySilicon(player, add, from);
    }

    /**
     * 修改钛数量
     *
     * @param resource
     * @param add      void
     */
    public void modifySilicon(Resource resource, long add) {
        if (add > 0) {
            resource.settSilicon(resource.gettSilicon() + add);
        }
        resource.setSilicon(resource.getSilicon() + add);
    }

    /**
     * Method: undergoGrab
     *
     * @Description: 被掠夺资源 @param target @param grab @return void @throws
     */
    public void undergoGrab(Player target, Grab grab) {
        modifyIron(target, -grab.rs[0], AwardFrom.UNDERGO_GRAB);
        modifyOil(target, -grab.rs[1], AwardFrom.UNDERGO_GRAB);
        modifyCopper(target, -grab.rs[2], AwardFrom.UNDERGO_GRAB);
        modifySilicon(target, -grab.rs[3], AwardFrom.UNDERGO_GRAB);
        modifyStone(target, -grab.rs[4], AwardFrom.UNDERGO_GRAB);
    }

    /**
     * 获得掠夺的资源
     *
     * @param target
     * @param grab   void
     */
    public void gainGrab(Player target, Grab grab) {
        modifyIron(target, grab.rs[0], AwardFrom.GAIN_GRAB);
        modifyOil(target, grab.rs[1], AwardFrom.GAIN_GRAB);
        modifyCopper(target, grab.rs[2], AwardFrom.GAIN_GRAB);
        modifySilicon(target, grab.rs[3], AwardFrom.GAIN_GRAB);
        modifyStone(target, grab.rs[4], AwardFrom.GAIN_GRAB);
    }

    /**
     * 检测配件材料够不够
     *
     * @param lord
     * @param id
     * @param count
     * @return
     */
    public boolean checkPartMaterialIsEnougth(Player player, int id, long count) {
        return rewardService.checkPartMaterialIsEnougth(player, id, count);
    }

    /**
     * @param player
     * @param type   物品类型
     * @param id
     * @param count
     * @return boolean
     * @throws @Title: checkPropIsEnougth
     * @Description: 判断物品是否够
     */
    public boolean checkPropIsEnougth(Player player, int type, int id, long count) {
        return rewardService.checkPropIsEnougth(player, type, id, count);
    }

    /**
     * @param player
     * @param propId
     * @param count
     * @param from
     * @return Prop
     * @throws @Title: addProp
     * @Description: 增加玩家道具 这里指的是对应s_prop表的道具
     */
    public Prop addProp(Player player, int propId, int count, AwardFrom from) {
        return rewardService.addProp(player, propId, count, from);
    }

    /**
     * Method: subProp
     *
     * @Description: 扣除道具 @param prop @param count @return void @throws
     */
    public void subProp(Player player, Prop prop, int count, AwardFrom from) {
        rewardService.subProp(player, prop, count, from);
    }

    /**
     * Method: addTank
     *
     * @Description: 增加坦克 @param player @param tankId @param count @return @return Tank @throws
     */
    public Tank addTank(Player player, int tankId, int count, AwardFrom from) {
        return rewardService.addTank(player, tankId, count, from);
    }

    /**
     * Method: addScience
     *
     * @Description: 增加科技 @param player @param scienceId @param level @return @return Science @throws
     */
    public Science addScience(Player player, int scienceId) {
        Science science = player.sciences.get(scienceId);
        if (science != null) {
            science.setScienceLv(science.getScienceLv() + 1);
        } else {
            science = new Science(scienceId, 1);
            player.sciences.put(scienceId, science);
        }
        LogLordHelper.science(AwardFrom.UP_SCIENCE, player.account, player.lord, scienceId, science.getScienceLv());
        StaticRefine staticRefine = staticRefineDataMgr.getStaticRefine(scienceId);
        if (staticRefine != null) {
            Resource resource = player.resource;
            int percent = staticRefine.getAddtion();
            if (staticRefine.getBuildId() == 8) {// 宝石
                resource.setStoneOutF(resource.getStoneOutF() + percent);
            } else if (staticRefine.getBuildId() == 9) {// 硅石
                resource.setSiliconOutF(resource.getSiliconOutF() + percent);
            } else if (staticRefine.getBuildId() == 10) {// 铁矿
                resource.setIronOutF(resource.getIronOutF() + percent);
            } else if (staticRefine.getBuildId() == 11) {// 铜矿
                resource.setCopperOutF(resource.getCopperOutF() + percent);
            } else if (staticRefine.getBuildId() == 12) {// 石油
                resource.setOilOutF(resource.getOilOutF() + percent);
            }

            if (staticRefine.getCapacity() == 1) {
                resource.setStoreF(resource.getStoreF() + percent);
            }
        }

        if (scienceId == ScienceId.ENGINE) {
            worldService.recalcArmyMarch(player);
        }

        updTask(player, TaskType.COND_SCIENCE_LV_UP, 1);
        updDay7ActSchedule(player, 9);
        return science;
    }

    /**
     * Method: addHero
     *
     * @Description: 增加武将 @param player @param heroId @param count @return @return Hero @throws
     */
    public Hero addHero(Player player, int heroId, int count, AwardFrom from) {
        return rewardService.addHero(player, heroId, count, from);
    }

    /**
     * 增加觉醒将领
     *
     * @param player
     * @param heroId
     * @param from
     * @return AwakenHero
     */
    public AwakenHero addAwakenHero(Player player, int heroId, AwardFrom from) {
        return rewardService.addAwakenHero(player, heroId, from);
    }

    /**
     * 获取某些操作失败的次数
     *
     * @param operType
     * @return
     */
    public FailNum getFailNumByOperType(Player player, int operType) {
        FailNum f = player.failNums.get(operType);
        if (f == null) {
            f = new FailNum(operType, 0);
            player.failNums.put(operType, f);
        }
        return f;
    }

    /**
     * Method: addExp
     *
     * @Description: 增加经验 @param player @param add @return void @throws
     */
    public boolean addExp(Player player, long add) {
        return rewardService.addExp(player, add);
    }

    /**
     * Method: realExp
     *
     * @Description: 算上buff的经验 @param player @param add @return void @throws
     */
    public int realExp(Player player, int exp) {
        int realExp = exp;
        if (player.effects.containsKey(EffectType.ADD_STAFFING_ADEXP1)) {
            realExp += exp * 0.004;
        }
        if (player.effects.containsKey(EffectType.ADD_STAFFING_ADEXP2)) {
            realExp += exp * 0.008;
        }
        if (player.effects.containsKey(EffectType.ADD_STAFFING_ADEXP3)) {
            realExp += exp * 0.012;
        }
        if (player.effects.containsKey(EffectType.ADD_STAFFING_ADEXP4)) {
            realExp += exp * 0.016;
        }
        if (player.effects.containsKey(EffectType.ADD_STAFFING_ADEXP5)) {
            realExp += exp * 0.02;
        }
        if (player.effects.containsKey(EffectType.ADD_BACK_EXP)) {
            realExp += exp * 0.02;
        }
        if (player.effects.containsKey(EffectType.LEVEL_EXP_UP)) {
            List<List<Float>> buff = Constant.LEVEL_EXP_BUFF;
            for (List<Float> level : buff) {
                if (player.lord.getLevel() <= level.get(1) && player.lord.getLevel() >= level.get(0)) {
                    realExp += exp * level.get(2);
                    break;
                }
            }
        }
        return realExp;
    }

    /**
     * 判断装备经验是否超过超过升级经验
     *
     * @param player void
     */
    public void checkEquipExpOverflow(Player player) {
        int lordLevel = player.lord.getLevel();
        for (Map.Entry<Integer, Map<Integer, Equip>> entry : player.equips.entrySet()) {
            for (Map.Entry<Integer, Equip> equipEntry : entry.getValue().entrySet()) {
                Equip equip = equipEntry.getValue();
                if (equip.getLv() >= lordLevel)
                    continue;
                boolean lvup = staticEquipDataMgr.checkEquipExpOverflow(lordLevel, equip);
                if (lvup) {
                    if (equip != null && equip.getEquipId() / 100 == 1) {
                        rankDataManager.setAttack(player.lord, equip);
                    } else if (equip != null && equip.getEquipId() / 100 == 5) {
                        rankDataManager.setCrit(player.lord, equip);
                    } else if (equip != null && equip.getEquipId() / 100 == 4) {
                        rankDataManager.setDodge(player.lord, equip);
                    }
                }
            }
        }
    }

    /**
     * Method: addFame
     *
     * @Description: 加声望 @param lord @param add @return @return boolean @throws
     */
    public boolean addFame(Player player, int add, AwardFrom from) {
        return rewardService.addFame(player, add, from);
    }

    /**
     * 加装备
     *
     * @param player
     * @param equipId
     * @param lv
     * @param pos
     * @param from
     * @return
     */
    public Equip addEquip(Player player, int equipId, int lv, int pos, AwardFrom from) {
        return rewardService.addEquip(player, equipId, lv, pos, from);
    }

    /**
     * 加指挥官装备
     *
     * @param player
     * @param equipId
     * @param from
     * @return
     */
    public LordEquip addLordEquip(Player player, int equipId, AwardFrom from) {
        return rewardService.addLordEquip(player, equipId, from);
    }

    // public Equip addEquip(Player player, int equipId, int pos) {
    // Equip equip = new Equip(player.maxKey(), equipId, 1, 0, pos);
    // player.equips.get(pos).put(equip.getKeyId(), equip);
    // return equip;
    // }

    /**
     * 加配件
     *
     * @param player
     * @param partId
     * @param pos
     * @param strengthLv
     * @param refitLv
     * @param from
     * @return
     */
    public Part addPart(Player player, int partId, int pos, int strengthLv, int refitLv, AwardFrom from) {
        return rewardService.addPart(player, partId, pos, strengthLv, refitLv, from);
    }

    /**
     * 增加勋章
     */
    public Medal addMedal(Player player, int medalId, int pos, int strengthLv, int refitLv, AwardFrom from) {
        return rewardService.addMedal(player, medalId, pos, strengthLv, refitLv, from);
    }

    /**
     * 扣除配件碎片
     *
     * @param player
     * @param chip
     * @param count
     * @param from
     * @return
     */
    public boolean subChip(Player player, Chip chip, int count, AwardFrom from) {
        return rewardService.subChip(player, chip, count, from);
    }

    /**
     * 扣勋章碎片
     */
    public boolean subMedalChip(Player player, MedalChip chip, int count, AwardFrom from) {
        if (chip != null && chip.getCount() >= count) {
            chip.setCount(chip.getCount() - count);
            LogLordHelper.medalChip(from, player.account, player.lord, chip.getChipId(), chip.getCount(), -count);
            return true;
        }
        return false;
    }

    /**
     * Method: addPartMaterial
     *
     * @Description: 增加配件材料 @param player @param id @param count @return void @throws
     */
    public CommonPb.Atom2 addPartMaterial(Player player, int id, int count, AwardFrom from) {
        return rewardService.addPartMaterial(player, id, count, from);
    }

    /**
     * Method: getResourceOut
     *
     * @Description: 获取玩家每小时资源产量 @param player @param resourceId @throws
     */
    public int getResourceOut(Player player, int resourceId) {
        Resource resource = player.resource;
        switch (resourceId) {
            case PartyType.RESOURCE_IRON://
                return (int) (resource.getIronOut() * (100 + resource.getIronOutF()) / 100);
            case PartyType.RESOURCE_OIL:
                return (int) (resource.getOilOut() * (100 + resource.getOilOutF()) / 100);
            case PartyType.RESOURCE_COPPER:
                return (int) (resource.getCopperOut() * (100 + resource.getCopperOutF()) / 100);
            case PartyType.RESOURCE_SILICON:
                return (int) (resource.getSiliconOut() * (100 + resource.getSiliconOutF()) / 100);
            case PartyType.RESOURCE_STONE:
                return (int) (resource.getStoneOut() * (100 + resource.getStoneOutF()) / 100);
            default:
                break;
        }
        return 0;
    }

    /**
     * 获取玩家每分钟的资源产量
     *
     * @param player
     * @param resourceId 资源编号
     * @return
     */
    public int getResourceOutMinutes(Player player, int resourceId) {
        Resource resource = player.resource;
        int reduce = 0;
        if (isRuins(player)) {
            reduce = 100;
        }
        switch (resourceId) {
            case PartyType.RESOURCE_IRON://
                return (int) (resource.getIronOut() * (100 + resource.getIronOutF() - reduce) / 6000);
            case PartyType.RESOURCE_OIL:
                return (int) (resource.getOilOut() * (100 + resource.getOilOutF() - reduce) / 6000);
            case PartyType.RESOURCE_COPPER:
                return (int) (resource.getCopperOut() * (100 + resource.getCopperOutF() - reduce) / 6000);
            case PartyType.RESOURCE_SILICON:
                return (int) (resource.getSiliconOut() * (100 + resource.getSiliconOutF() - reduce) / 6000);
            case PartyType.RESOURCE_STONE:
                return (int) (resource.getStoneOut() * (100 + resource.getStoneOutF() - reduce) / 6000);
            default:
                break;
        }
        return 0;
    }

    /**
     * Method: addAward
     *
     * @Description: 通用加属性、物品、数据 @param player @param type @param id @param count @param from @return void @throws
     */
    public int addAward(Player player, int type, int id, long count, AwardFrom from) {
        return rewardService.addAward(player, type, id, count, from);
    }

    /**
     * 今天获得的军工
     *
     * @param lord
     * @param currentDay
     * @return int
     */
    public int getMpltGetToday(Lord lord, int currentDay) {
        return lord.getLastMpltDay() == currentDay ? lord.getMpltGetToday() : 0;
    }

    /**
     * 今天获得的军工
     *
     * @param lord
     * @return int
     */
    public int getMpltGetToday(Lord lord) {
        return getMpltGetToday(lord, TimeHelper.getCurrentDay());
    }

    /**
     * 根据战损列表计算军功
     *
     * @param attackHaust    攻击方战损
     * @param defencerkHaust 防守方战损
     * @return [0]-进攻方军功, [1]-防守方军功, null :表示功能未开启
     */
    public long[] calcMilitaryExploit(Map<Integer, RptTank> attackHaust, Map<Integer, RptTank> defencerkHaust) {
        double aEplt = 0L, dEplt = 0L;// 进攻方获得军功,防守方获得军功
        if (attackHaust != null && !attackHaust.isEmpty()) {
            double[] mplt = getMilitaryExploit(attackHaust);
            aEplt += mplt[0];// 进攻方获得的军功
            dEplt += mplt[1];// 防守方获得的军功
        }
        if (defencerkHaust != null && !defencerkHaust.isEmpty()) {
            double[] mplt = getMilitaryExploit(defencerkHaust);
            aEplt += mplt[1];// 进攻方获得的军功
            dEplt += mplt[0];// 防守方获得的军功
        }
        return new long[]{(long) aEplt, (long) dEplt};
    }

    /**
     * 根据战损 双方获得的军工
     *
     * @param haust key :tank编号
     * @return double[]
     */
    private double[] getMilitaryExploit(Map<Integer, RptTank> haust) {
        double[] mplt = new double[2]; // 0-己方获得军功,1-敌方获得军功
        for (Map.Entry<Integer, RptTank> entry : haust.entrySet()) {
            StaticTank tankData = staticTankDataMgr.getTankMap().get(entry.getKey());
            if (tankData == null)
                continue;
            mplt[0] += tankData.getLostMilitary() * entry.getValue().getCount() / NumberHelper.TEN_THOUSAND;
            mplt[1] += tankData.getDestroyMilitary() * entry.getValue().getCount() / NumberHelper.TEN_THOUSAND;
        }
        return mplt;
    }

    /**
     * 更新玩家的功勋值
     *
     * @param player
     * @param count
     * @param from
     * @return
     */
    public boolean updateExploit(Player player, int count, AwardFrom from) {
        return rewardService.updateExploit(player, count, from);
    }

    /**
     * 增加能晶
     *
     * @param player
     * @param stoneId 能晶id，须保证传入的能晶id是有配置的
     * @param count   增加的数量，正数
     * @param from
     */
    public void addEnergyStone(Player player, int stoneId, int count, AwardFrom from) {
        rewardService.addEnergyStone(player, stoneId, count, from);
    }

    /**
     * 扣除玩家一定数量的能晶
     *
     * @param player
     * @param stoneId 能晶id，须保证传入的能晶id是有配置的
     * @param count   扣除的数量，正数，须保证扣除的数量不大于玩家当前剩余的数量
     */
    public void subEnergyStone(Player player, int stoneId, int count, AwardFrom from) {
        rewardService.subEnergyStone(player, stoneId, count, from);
    }

    /**
     * Method: subProp
     *
     * @Description: 消耗物品 @return void @throws
     */
    public CommonPb.Atom2 subProp(Player player, int type, int id, long count, AwardFrom from) {
        return rewardService.subProp(player, type, id, count, from);
    }

    /**
     * 打开红包获得金币
     *
     * @param player
     * @param propId
     * @param count
     * @return int
     */
    public int giveRedPacketGold(Player player, int propId, int count) {
        StaticProp staticProp = staticPropDataMgr.getStaticProp(propId);
        if (staticProp == null || staticProp.getEffectType() != 6) {
            return 0;
        }

        List<List<Integer>> effectValue = staticProp.getEffectValue();
        if (effectValue == null || effectValue.isEmpty()) {
            return 0;
        }

        List<Integer> one = effectValue.get(0);
        if (one.size() != 1) {
            return 0;
        }

        int gold = one.get(0) * count;

        addGold(player, gold, AwardFrom.RED_PACKET);
        return gold;
    }

    /**
     * Method: addAwardList
     *
     * @Description: 加一组物品 @param player @param awards @param from @return void @throws
     */
    public void addAwardList(Player player, List<List<Integer>> awards, AwardFrom from) {
        rewardService.addAwardList(player, awards, from);
    }

    /**
     * 给玩家增加奖励并返回奖励对象
     *
     * @param player
     * @param award
     * @param from
     * @return CommonPb.Award
     */
    public CommonPb.Award addAwardBackPb(Player player, List<Integer> award, AwardFrom from) {
        return rewardService.addAwardBackPb(player, award, from);
    }

    /**
     * Method: addAwardAndBack
     *
     * @Description: 加一组物品, 并返回pb数据 @param player @param drop @param from @return @return List<Award> @throws
     */
    public List<CommonPb.Award> addAwardsBackPb(Player player, List<List<Integer>> drop, AwardFrom from) {
        return rewardService.addAwardsBackPb(player, drop, from);
    }

    /**
     * Method: addArenaScore
     *
     * @Description: 加竞技场积分 @param player @param count @return void @throws
     */
    public void addArenaScore(Player player, int count, AwardFrom from) {
        rewardService.addArenaScore(player, count, from);
    }

    /**
     * Method: checkTank
     *
     * @Description: 检查阵型中的坦克是否足够 @param player @param form @param tankCount @return @return boolean @throws
     */
    public boolean checkTank(Player player, Form form, int tankCount) {
        return rewardService.checkTank(player, form, tankCount);
    }

    /**
     * Method: createHomeDefendForm
     *
     * @Description: 创建基地防守阵型，拿走坦克数量，战斗完返还 @param player @return @return Form @throws
     */
    public Form createHomeDefendForm(Player player) {
        Form formTemplate = player.forms.get(FormType.HOME_DEFEND);
        if (formTemplate == null) {
            return null;
        }

        Form form = new Form();
        StaticHero staticHero = null;
        AwakenHero awakenHero = null;
        if (formTemplate.getAwakenHero() != null) {
            // 觉醒将领是否在使用，如没有，才能加入阵形
            awakenHero = player.awakenHeros.get(formTemplate.getAwakenHero().getKeyId());
            if (awakenHero != null && !awakenHero.isUsed()) {
                form.setAwakenHero(formTemplate.getAwakenHero().clone());
                staticHero = staticHeroDataMgr.getStaticHero(form.getAwakenHero().getHeroId());
            }
        } else {
            if (formTemplate.getCommander() > 0) {
                Hero hero = player.heros.get(formTemplate.getCommander());
                if (hero != null && hero.getCount() > 0) {
                    form.setCommander(formTemplate.getCommander());
                    staticHero = staticHeroDataMgr.getStaticHero(form.getCommander());
                }
            }
        }


        //战术
        if (!formTemplate.getTactics().isEmpty()) {
            form.setTactics(new ArrayList<Integer>(formTemplate.getTactics()));
            form.setTacticsList(new ArrayList<TowInt>(formTemplate.getTacticsList()));
        }

        int totalTank = 0;
        int count = 0;
        Map<Integer, Integer> formTanks = new HashMap<>();
        Map<Integer, Tank> tanks = player.tanks;
        int maxTankCount = formTankCount(player, staticHero, awakenHero);

        int[] p = formTemplate.p;
        int[] c = formTemplate.c;
        for (int i = 0; i < p.length; i++) {
            if (p[i] > 0) {
                count = rewardService.addTankMapCount(formTanks, p[i], c[i], maxTankCount);
                if (count > 0) {
                    Tank tank = tanks.get(p[i]);
                    if (tank != null) {
                        if (tank.getCount() < count) {
                            count = tank.getCount();
                        }

                        tank.setCount(tank.getCount() - count);
                        LogLordHelper.tank(AwardFrom.HOME_DEFEND, player.account, player.lord, p[i], tank.getCount(), -count, 0, 0);
                        if (count > 0) {
                            form.p[i] = p[i];
                            form.c[i] = count;
                            totalTank += count;
                        }
                    }
                }
            }
        }

        if (totalTank == 0) {
            return null;
        }

        return form;
    }

    /**
     * Method: getHomeDefendForm
     *
     * @Description: 获取基地防守阵型, 不扣除坦克 @param player @return @return Form @throws
     */
    public Form getHomeDefendForm(Player player) {
        Form formTemplate = player.forms.get(FormType.HOME_DEFEND);
        if (formTemplate == null) {
            return null;
        }

        Form form = new Form();
        StaticHero staticHero = null;
        AwakenHero awakenHero = null;
        if (formTemplate.getAwakenHero() != null) {
            awakenHero = player.awakenHeros.get(formTemplate.getAwakenHero().getKeyId());
            if (awakenHero != null && !awakenHero.isUsed()) {
                form.setAwakenHero(awakenHero.clone());
                staticHero = staticHeroDataMgr.getStaticHero(formTemplate.getAwakenHero().getHeroId());
            }
        } else {
            if (formTemplate.getCommander() > 0) {
                Hero hero = player.heros.get(formTemplate.getCommander());
                if (hero != null && hero.getCount() > 0) {
                    form.setCommander(formTemplate.getCommander());
                    staticHero = staticHeroDataMgr.getStaticHero(form.getCommander());
                }
            }
        }
        //战术
        if (!formTemplate.getTactics().isEmpty()) {
            form.setTactics(new ArrayList<Integer>(formTemplate.getTactics()));
            form.setTacticsList(new ArrayList<TowInt>(formTemplate.getTacticsList()));
        }
        int totalTank = 0;
        int count = 0;
        Map<Integer, Integer> formTanks = new HashMap<Integer, Integer>();
        Map<Integer, Tank> tanks = player.tanks;
        Map<Integer, RptTank> hadTank = new HashMap<>();
        int maxTankCount = formTankCount(player, staticHero, awakenHero);

        int[] p = formTemplate.p;
        int[] c = formTemplate.c;
        for (int i = 0; i < p.length; i++) {
            if (p[i] > 0) {
                count = rewardService.addTankMapCount(formTanks, p[i], c[i], maxTankCount);
                if (count > 0) {
                    RptTank had = hadTank.get(p[i]);
                    if (had == null) {
                        Tank tank = tanks.get(p[i]);
                        if (tank == null) {
                            had = new RptTank(p[i], 0);
                        } else {
                            had = new RptTank(p[i], tank.getCount());
                        }
                        hadTank.put(p[i], had);
                    }

                    if (had.getCount() < count) {
                        count = had.getCount();
                    }

                    had.setCount(had.getCount() - count);
                    if (count > 0) {
                        form.p[i] = p[i];
                        form.c[i] = count;
                        totalTank += count;
                    }
                }
            }
        }

        if (totalTank == 0) {
            return null;
        }

        return form;
    }

    /**
     * Method: calcHonorScore
     *
     * @Description: 计算战损的荣誉点 @param map1 @param map2 @param ratio @return @return int @throws
     */
    public int calcHonor(Map<Integer, RptTank> map1, Map<Integer, RptTank> map2, double ratio) {
        int score1 = calcHonorScore(map1, ratio);
        int score2 = calcHonorScore(map2, ratio);
        int score = score1 + score2;
        if (score <= 0) {
            return 0;
        } else if (score < 101) {
            return 2;
        } else if (score < 501) {
            return 3;
        } else if (score < 2001) {
            return 4;
        } else if (score < 5001) {
            return 5;
        } else if (score < 10001) {
            return 7;
        } else if (score < 16001) {
            return 10;
        } else if (score < 25001) {
            return 15;
        } else {
            return 20;
        }
    }

    /**
     * Method: calcStaffingExp
     *
     * @Description: 计算战损产生的编制经验 @param map @param ratio @return @return int @throws
     */
    public int calcStaffingExp(Map<Integer, RptTank> map, double ratio) {
        if (!TimeHelper.isStaffingOpen()) {
            return 0;
        }

        int exp = 0;
        int killed = 0;
        int lost = 0;
        StaticTank staticTank = null;
        Iterator<RptTank> it = map.values().iterator();
        while (it.hasNext()) {
            RptTank rptTank = (RptTank) it.next();
            killed = rptTank.getCount();
            lost = killed - (int) Math.ceil(ratio * killed);
            staticTank = staticTankDataMgr.getStaticTank(rptTank.getTankId());
            if (staticTank != null)
                exp += staticTank.getStaffingExp() * lost;
        }

        return exp;
    }

    /**
     * 计算荣耀点数
     *
     * @param map   key 坦克编号 RptTank 损失的坦克
     * @param ratio
     * @return int
     */
    private int calcHonorScore(Map<Integer, RptTank> map, double ratio) {
        Iterator<RptTank> it = map.values().iterator();
        int score = 0;

        int killed = 0;
        int lost = 0;
        StaticTank staticTank = null;

        while (it.hasNext()) {
            RptTank rptTank = (RptTank) it.next();
            killed = rptTank.getCount();
            lost = killed - (int) Math.ceil(ratio * killed);
            staticTank = staticTankDataMgr.getStaticTank(rptTank.getTankId());
            if (staticTank != null)
                score += staticTank.getHonorScore() * lost;
        }

        return score;
    }

    /**
     * 玩家pK后获得荣耀
     *
     * @param winner
     * @param loser
     * @param honor
     * @return int
     */
    public int giveHonor(Player winner, Player loser, int honor) {
        int give = 0;
        if (loser.lord.getHonour() < honor) {
            give = loser.lord.getHonour();
        } else {
            give = honor;
        }

        winner.lord.setHonour(winner.lord.getHonour() + give);
        loser.lord.setHonour(loser.lord.getHonour() - give);

        if (give != 0) {
            rankDataManager.setHonour(winner.lord);
            rankDataManager.setHonour(loser.lord);
        }

        return give;
    }

    /**
     * 玩家pk后获得编制经验
     *
     * @param winner
     * @param loser
     * @param exp
     * @return int
     */
    public int giveStaffingExp(Player winner, Player loser, int exp, Army army) {
        int loserExp = staticStaffingDataMgr.getTotalExp(loser.lord);
        if (loserExp < exp) {
            exp = loserExp;
        }

        if (exp != 0) {
            // 计算编制经验加速buff增加的比例
            int winnerExp = exp;
            if (winner.effects.containsKey(EffectType.ADD_STAFFING_FIGHT)) {
                winnerExp += exp * 0.1;
            }
            if (winner.effects.containsKey(EffectType.ADD_STAFFING_ALL)) {
                winnerExp += exp * 0.1;
            }

            if (winner.effects.containsKey(EffectType.ADD_STAFFING_AD1)) {
                winnerExp += exp * 0.01;
            }
            if (winner.effects.containsKey(EffectType.ADD_STAFFING_AD2)) {
                winnerExp += exp * 0.02;
            }
            if (winner.effects.containsKey(EffectType.ADD_STAFFING_AD3)) {
                winnerExp += exp * 0.03;
            }
            if (winner.effects.containsKey(EffectType.ADD_STAFFING_AD4)) {
                winnerExp += exp * 0.04;
            }
            if (winner.effects.containsKey(EffectType.ADD_STAFFING_AD5)) {
                winnerExp += exp * 0.05;
            }
            if (winner.effects.containsKey(EffectType.ADD_STAFFING_ALL2)) {
                winnerExp += exp * 0.2;
            }

            Form form = army.getForm();
            if (form != null) {
                AwakenHero awakenHero = form.getAwakenHero();
                if (awakenHero != null) {
                    for (Map.Entry<Integer, Integer> entry : awakenHero.getSkillLv().entrySet()) {
                        if (entry.getValue() <= 0) {
                            continue;
                        }
                        StaticHeroAwakenSkill staticHeroAwakenSkill = staticHeroDataMgr.getHeroAwakenSkill(entry.getKey(),
                                entry.getValue());
                        if (staticHeroAwakenSkill == null) {
                            LogUtil.error("觉醒将领技能未配置ccx:" + entry.getKey() + " 等级:" + entry.getValue());
                            continue;
                        }
                        if (staticHeroAwakenSkill.getEffectType() == HeroConst.HERO_STAFFING_EXP) {
                            String val = staticHeroAwakenSkill.getEffectVal();
                            if (val != null && !val.isEmpty()) {
                                winnerExp += exp * (Float.valueOf(val) / 100.0f);
                            }
                        }
                    }
                }
            }

            staticStaffingDataMgr.addStaffingExp(winner.lord, winnerExp);
            staticStaffingDataMgr.subStaffingExp(loser.lord, exp);

            rankDataManager.setStaffing(winner.lord);
            rankDataManager.setStaffing(loser.lord);

            winner.lord.setStaffing(calcStaffing(winner));
            loser.lord.setStaffing(calcStaffing(loser));

            synStaffingToPlayer(winner);
            synStaffingToPlayer(loser);
        }

        return exp;
    }

    /**
     * 增加玩家编制经验
     *
     * @param player
     * @param exp    void
     */
    public void addStaffingExp(Player player, int exp) {
        if (!TimeHelper.isStaffingOpen()) { // 未开启编制 经验预存
            player.lord.setStaffingSaveExp(player.lord.getStaffingSaveExp() + exp);
            return;
        }
        staticStaffingDataMgr.addStaffingExp(player.lord, exp);

        rankDataManager.setStaffing(player.lord);

        player.lord.setStaffing(calcStaffing(player));

        synStaffingToPlayer(player);
    }

    /**
     * 根据玩家当前编制等级 得到编制类型
     *
     * @param player
     * @return int
     */
    public int calcStaffing(Player player) {
        return rewardService.calcStaffing(player);
    }

    /**
     * 得到玩家挂件
     *
     * @param player
     * @return List<Pendant>
     */
    public List<Pendant> getPendants(Player player) {
        checkPendant(player);
        return player.pendants;
    }

    /**
     * 得到玩家挂件
     *
     * @param player
     * @param id     挂件编号
     * @return Pendant
     */
    public Pendant getPendant(Player player, int id) {
        checkPendant(player);
        for (Pendant pendant : player.pendants) {
            if (pendant.getPendantId() == id) {
                return pendant;
            }
        }
        return null;
    }

    /**
     * 给玩家增加挂件
     *
     * @param player
     * @param staticPendant
     * @return Pendant
     */
    public Pendant addPendant(Player player, StaticPendant staticPendant) {
        // 添加并使用
        if (getPendant(player, staticPendant.getPendantId()) != null) {
            return null;
        }
        Pendant pendant = new Pendant();
        pendant.setPendantId(staticPendant.getPendantId());
        pendant.setEndTime(TimeHelper.getCurrentSecond() + staticPendant.getDuration() * TimeHelper.DAY_S);
        pendant.setForeverHold(staticPendant.getDuration() == 0);

        player.pendants.add(pendant);
        return pendant;
    }

    /**
     * 玩家挂件到期 给没收回来
     *
     * @param player
     * @param id     void
     */
    public void setPendant(Player player, int id) {
        int pendentId = player.lord.getPortrait() / 100;
        int base = player.lord.getPortrait() - pendentId * 100;

        int newPortrait = id * 100 + base;// 到期改成默认0挂件
        player.lord.setPortrait(newPortrait);
    }

    /**
     * 玩家挂件是否到期 到期给没收
     *
     * @param player void
     */
    public void checkPendant(Player player) {
        int pendentId = player.lord.getPortrait() / 100;

        int now = TimeHelper.getCurrentSecond();
        Iterator<Pendant> it = player.pendants.iterator();

        while (it.hasNext()) {
            Pendant pendant = it.next();
            if (!pendant.isForeverHold() && now >= pendant.getEndTime()) {// 挂件到期
                if (pendant.getPendantId() == pendentId) {
                    setPendant(player, 0);
                }
                it.remove();
            }
        }
    }

    /**
     * 获得玩家头像列表
     *
     * @param player
     * @return List<Portrait>
     */
    public List<Portrait> getPortraits(Player player) {
        checkPortrait(player);
        return player.portraits;
    }

    /**
     * 获得玩家头像
     *
     * @param player
     * @param id     头像id
     * @return Portrait
     */
    public Portrait getPortrait(Player player, int id) {
        checkPortrait(player);
        for (Portrait portrait : player.portraits) {
            if (portrait.getId() == id) {
                return portrait;
            }
        }
        return null;
    }

    /**
     * 添加头像
     *
     * @param player
     * @param staticPortrait
     * @return Portrait
     */
    public Portrait addPortrait(Player player, StaticPortrait staticPortrait) {
        // 添加并使用
        if (getPortrait(player, staticPortrait.getId()) != null) {
            return null;
        }
        Portrait portrait = new Portrait();
        portrait.setId(staticPortrait.getId());
        portrait.setEndTime(TimeHelper.getCurrentSecond() + staticPortrait.getDuration() * TimeHelper.DAY_S);
        portrait.setForeverHold(staticPortrait.getDuration() == 0);

        player.portraits.add(portrait);
        return portrait;
    }

    /**
     * 没收头像
     *
     * @param player
     * @param id     void
     */
    public void setPortrait(Player player, int id) {
        int pendentId = player.lord.getPortrait() / 100;
        // int base = player.lord.getPortrait() - pendentId * 100;

        int newPortrait = pendentId * 100 + id;// 到期改成默认0
        player.lord.setPortrait(newPortrait);
    }

    /**
     * 头像到期没有 到期了没收头像
     *
     * @param player void
     */
    public void checkPortrait(Player player) {
        int pendentId = player.lord.getPortrait() / 100;
        int id = player.lord.getPortrait() - pendentId * 100;

        int now = TimeHelper.getCurrentSecond();
        Iterator<Portrait> it = player.portraits.iterator();

        while (it.hasNext()) {
            Portrait portrait = it.next();
            if (!portrait.isForeverHold() && now >= portrait.getEndTime()) {// 挂件到期
                if (portrait.getId() == id) {
                    setPortrait(player, 1);
                }
                it.remove();
            }
        }
    }

    /**
     * 添加战报邮件,不能包含奖励道具
     *
     * @param player
     * @param moldId 查询MailType中的mold值
     * @param param  没有时则传null
     * @return
     */
    public Mail sendReportMail(Player player, Report report, int moldId, int now, String... param) {
        StaticMail staticMail = staticMailDataMgr.getStaticMail(moldId);
        if (staticMail == null) {
            return null;
        }
        int type = staticMail.getType();
        Mail mail = new Mail(player.maxKey(), type, moldId, MailType.STATE_UNREAD, now);
        if (param != null && param.length != 0) {
            mail.setParam(param);
        }

        // if (moldId == MailType.MOLD_ATTACK_PLAYER || moldId ==
        // MailType.MOLD_ATTACK_MINE) {
        // mail.setState(MailType.STATE_READ);
        // }

        mail.setReport(report);

        player.addNewMail(mail);
        tidyMail(player, type, mail.getKeyId());
        synMailToPlayer(player, mail);
        return mail;
    }

    /**
     * @param player
     * @param report
     * @param moldId
     * @param now
     * @param param  void
     * @throws @Title: sendArenaReportMail
     * @Description: 发送竞技场战报邮件
     */
    public void sendArenaReportMail(Player player, Report report, int moldId, int now, String... param) {
        StaticMail staticMail = staticMailDataMgr.getStaticMail(moldId);
        if (staticMail == null) {
            return;
        }
        int type = staticMail.getType();
        Mail mail = new Mail(player.maxKey(), type, moldId, MailType.STATE_UNREAD, now);
        if (param != null && param.length != 0) {
            mail.setParam(param);
        }
        if (moldId == MailType.MOLD_ARENA_3 || moldId == MailType.MOLD_ARENA_4) {
            mail.setState(MailType.STATE_READ);
        }
        mail.setReport(report);

        player.addNewMail(mail);
        tidyMail(player, type, mail.getKeyId());
        synMailToPlayer(player, mail);
    }

    /**
     * 获得战报邮件
     *
     * @param player
     * @param report
     * @param moldId
     * @param now
     * @param param  void
     */
    public void sendWarReportMail(Player player, Report report, int moldId, int now, String... param) {
        StaticMail staticMail = staticMailDataMgr.getStaticMail(moldId);
        if (staticMail == null) {
            return;
        }
        int type = staticMail.getType();
        Mail mail = new Mail(player.maxKey(), type, moldId, MailType.STATE_UNREAD, now);
        if (param != null && param.length != 0) {
            mail.setParam(param);
        }

        mail.setReport(report);

        player.addNewMail(mail);
        tidyMail(player, type, mail.getKeyId());
        synMailToPlayer(player, mail);
    }

    /**
     * @param player
     * @param report
     * @param moldId
     * @param now
     * @param param
     * @return Mail
     * @throws @Title: createReportMail
     * @Description: 发送战报邮件并返回邮件对象
     */
    public Mail createReportMail(Player player, Report report, int moldId, int now, String... param) {
        StaticMail staticMail = staticMailDataMgr.getStaticMail(moldId);
        if (staticMail == null) {
            return null;
        }
        int type = staticMail.getType();
        Mail mail = new Mail(player.maxKey(), type, moldId, MailType.STATE_READ, now);
        if (param != null && param.length != 0) {
            mail.setParam(param);
        }

        mail.setReport(report);

        player.addNewMail(mail);
        tidyMail(player, type, mail.getKeyId());
        synMailToPlayer(player, mail);
        return mail;
    }

    /**
     * @param player
     * @param moldId
     * @param now
     * @param param  void
     * @throws @Title: sendNormalMail
     * @Description: 发送普通邮件
     */
    public void sendNormalMail(Player player, int moldId, int now, String... param) {
        StaticMail staticMail = staticMailDataMgr.getStaticMail(moldId);
        if (staticMail == null) {
            return;
        }
        int type = staticMail.getType();
        Mail mail = new Mail(player.maxKey(), type, moldId, MailType.STATE_UNREAD, now);
        if (param != null && param.length != 0) {
            mail.setParam(param);
        }
        player.addNewMail(mail);
        tidyMail(player, type, mail.getKeyId());
        synMailToPlayer(player, mail);
    }

    /**
     * @param from
     * @param player
     * @param awards
     * @param moldId
     * @param now
     * @param param  void
     * @throws @Title: sendAttachMail
     * @Description: 发送带奖励的邮件
     */
    public void sendAttachMail(AwardFrom from, Player player, List<CommonPb.Award> awards, int moldId, int now, String... param) {
        StaticMail staticMail = staticMailDataMgr.getStaticMail(moldId);
        if (staticMail == null) {
            return;
        }
        int type = staticMail.getType();
        Mail mail = new Mail(player.maxKey(), type, moldId, MailType.STATE_UNREAD_ITEM, now);
        if (param != null && param.length != 0) {
            mail.setParam(param);
        }

        if (!awards.isEmpty()) {
            mail.setAward(awards);
            if (from != AwardFrom.GM_SEND) {
                LogLordHelper.mail(from, player.account, player.lord, mail);
            }
        }

        player.addNewMail(mail);

        tidyMail(player, type, mail.getKeyId());
        synMailToPlayer(player, mail);
    }

    /**
     * 根据邮件类型获取邮箱上限
     *
     * @return
     */
    private int getMailLimit(int type) {
        switch (type) {
            case MailType.NORMAL_MAIL:
                return MailType.MAIL_COUNT_MAX_1;
            case MailType.SEND_MAIL:
                return MailType.MAIL_COUNT_MAX_2;
            case MailType.REPORT_MAIL:
                return MailType.MAIL_COUNT_MAX_3;
            case MailType.SYSTEM_MAIL:
                return MailType.MAIL_COUNT_MAX_4;
            case 11:
                return MailType.MAIL_COUNT_MAX_3;
        }
        return MailType.MAIL_COUNT_MAX_2;
    }

    /**
     * @param target
     * @param mail
     * @throws @Title: tidyMail
     * @Description: 同步邮件到玩家客户端
     */
    public void synMailToPlayer(Player target, Mail mail) {
        if (target != null && target.isLogin) {
            SynMailRq.Builder builder = SynMailRq.newBuilder();
            builder.setShow(PbHelper.createMailShowPb(mail));
            Base.Builder msg = PbHelper.createSynBase(SynMailRq.EXT_FIELD_NUMBER, SynMailRq.ext, builder.build());
            GameServer.getInstance().synMsgToPlayer(target.ctx, msg);
        }
    }

    /**
     * 整理邮件
     *
     * @param player
     * @param type
     * @param keyId  void
     */
    public void tidyMail(Player player, int type, int keyId) {
        if (type == MailType.ARENA_GLOBAL_MAIL) {
            return;
        }

        int count = getMailLimit(type);

        Map<Integer, Mail> mails = player.getMails();

        if (mails.size() < count) {
            return;
        }

        int total = 0;
        Iterator<Mail> it = mails.values().iterator();
        while (it.hasNext()) {
            Mail mail = it.next();

            if (type == 3 || type == 11) {
                if ((mail.getType() == 3 || mail.getType() == 11) && mail.getCollections() != 1) {
                    if (mail.getKeyId() < keyId) {
                        keyId = mail.getKeyId();
                    }
                    total++;
                }
            } else {
                if (mail.getType() == type && mail.getCollections() != 1) {
                    if (mail.getKeyId() < keyId) {
                        keyId = mail.getKeyId();
                    }
                    total++;
                }
            }

        }

        if (total > count) {// 超过数量的邮件删除
            Mail mail = player.delMail(keyId);
            List<Award> list = mailService.getDelRewardMail(player, mail);

            if (list == null) {
                list = new ArrayList<>();
            } else if (list.size() > 0) {
                // 有附件，则记录日志
                LogLordHelper.autoDelMail(AwardFrom.AUTO_DEL_MAIL, player, mail);
            }

            StcHelper.syncMail2Player(player, list);
        }
    }

    /**
     * @param target
     * @param march  void
     * @throws @Title: synInvasionToPlayer
     * @Description: 发送玩家被攻击的邮件
     */
    public void synInvasionToPlayer(Player target, March march) {
        if (target != null && target.isLogin) {
            SynInvasionRq.Builder builder = SynInvasionRq.newBuilder();
            builder.setInvasion(PbHelper.createInvasionPb(march));
            Base.Builder msg = PbHelper.createSynBase(SynInvasionRq.EXT_FIELD_NUMBER, SynInvasionRq.ext, builder.build());
            GameServer.getInstance().synMsgToPlayer(target.ctx, msg);
        }
    }

    /**
     * 将被攻击的状态同步给玩家
     *
     * @param target
     * @param armyStatu void
     */
    public void synArmyToPlayer(Player target, ArmyStatu armyStatu) {
        if (target != null && target.isLogin) {
            SynArmyRq.Builder builder = SynArmyRq.newBuilder();
            builder.setArmyStatu(PbHelper.createArmyStatuPb(armyStatu));
            Base.Builder msg = PbHelper.createSynBase(SynArmyRq.EXT_FIELD_NUMBER, SynArmyRq.ext, builder.build());
            GameServer.getInstance().synMsgToPlayer(target.ctx, msg);
        }
    }

    /**
     * 通知玩家被踢出军团了
     *
     * @param target
     * @param partyId void
     */
    public void synPartyOutToPlayer(Player target, int partyId) {
        if (target != null && target.isLogin) {
            SynPartyOutRq.Builder builder = SynPartyOutRq.newBuilder();
            builder.setPartyId(partyId);
            Base.Builder msg = PbHelper.createSynBase(SynPartyOutRq.EXT_FIELD_NUMBER, SynPartyOutRq.ext, builder.build());
            GameServer.getInstance().synMsgToPlayer(target.ctx, msg);
        }
    }

    /**
     * 通知玩家同意加入军团
     *
     * @param target
     * @param partyId
     * @param accept  void
     */
    public void synPartyAcceptToPlayer(Player target, int partyId, int accept) {
        if (target != null && target.isLogin) {
            SynPartyAcceptRq.Builder builder = SynPartyAcceptRq.newBuilder();
            builder.setPartyId(partyId);
            builder.setAccept(accept);
            Base.Builder msg = PbHelper.createSynBase(SynPartyAcceptRq.EXT_FIELD_NUMBER, SynPartyAcceptRq.ext, builder.build());
            GameServer.getInstance().synMsgToPlayer(target.ctx, msg);
        }
    }

    /**
     * 通知玩家获得了好友祝福
     *
     * @param target
     * @param lord   void
     */
    public void synBlessToPlayer(Player target, Lord lord) {
        if (target != null && target.isLogin) {
            SynBlessRq.Builder builder = SynBlessRq.newBuilder();

            long lordId = lord.getLordId();
            int sex = lord.getSex();
            String nick = lord.getNick();
            int icon = lord.getPortrait();
            int level = lord.getLevel();
            Man man = new Man(lordId, sex, nick, icon, level);
            builder.setMan(PbHelper.createManPb(man));
            Base.Builder msg = PbHelper.createSynBase(SynBlessRq.EXT_FIELD_NUMBER, SynBlessRq.ext, builder.build());
            GameServer.getInstance().synMsgToPlayer(target.ctx, msg);
        }
    }

    /**
     * 通知军团长有人申请
     *
     * @param partyId
     * @param count   void
     */
    public void synApplyPartyToPlayer(int partyId, int count) {
        List<Member> members = partyDataManager.getMemberList(partyId);
        Iterator<Member> it = members.iterator();
        while (it.hasNext()) {
            Member member = it.next();
            if (member != null && member.getJob() >= PartyType.LEGATUS_CP) {
                Player target = getPlayer(member.getLordId());
                SynApplyRq.Builder builder = SynApplyRq.newBuilder();
                builder.setApplyCount(count);
                if (target != null && target.isLogin) {
                    Base.Builder msg = PbHelper.createSynBase(SynApplyRq.EXT_FIELD_NUMBER, SynApplyRq.ext, builder.build());
                    GameServer.getInstance().synMsgToPlayer(target.ctx, msg);
                }
            }
        }
    }

    /**
     * 通知玩家跨服战状态
     *
     * @param target
     * @param req    void
     */
    public void synCrossStateToPlayer(Player target, SynCrossStateRq req) {
        if (target != null && target.isLogin) {

            Base.Builder msg = PbHelper.createSynBase(SynCrossStateRq.EXT_FIELD_NUMBER, SynCrossStateRq.ext, req);
            GameServer.getInstance().synMsgToPlayer(target.ctx, msg);
        }
    }

    /**
     * 通知玩家跨服军团战状态
     *
     * @param target
     * @param req    void
     */
    public void synCPStateToPlayer(Player target, SynCrossPartyStateRq req) {
        if (target != null && target.isLogin) {

            Base.Builder msg = PbHelper.createSynBase(SynCrossPartyStateRq.EXT_FIELD_NUMBER, SynCrossPartyStateRq.ext, req);
            GameServer.getInstance().synMsgToPlayer(target.ctx, msg);
        }
    }

    /**
     * 通知玩家跨服军团战战况
     *
     * @param target
     * @param req    void
     */
    public void synCPSisutionToPlayer(Player target, SynCPSituationRq req) {
        if (target != null && target.isLogin) {

            Base.Builder msg = PbHelper.createSynBase(SynCPSituationRq.EXT_FIELD_NUMBER, SynCPSituationRq.ext, req);
            GameServer.getInstance().synMsgToPlayer(target.ctx, msg);
        }
    }

    /**
     * 同步百团战斗记录给玩家
     *
     * @param target
     * @param req    void
     */
    public void synWarRecordToPlayer(Player target, SynWarRecordRq req) {
        if (target != null && target.isLogin) {

            Base.Builder msg = PbHelper.createSynBase(SynWarRecordRq.EXT_FIELD_NUMBER, SynWarRecordRq.ext, req);
            GameServer.getInstance().synMsgToPlayer(target.ctx, msg);
        }
    }

    /**
     * 同步要塞战战况给防守玩家
     *
     * @param target
     * @param req    void
     */
    public void synFortressSelfToPlayer(Player target, SynFortressSelfRq req) {
        if (target != null && target.isLogin) {
            Base.Builder msg = PbHelper.createSynBase(SynFortressSelfRq.EXT_FIELD_NUMBER, SynFortressSelfRq.ext, req);
            GameServer.getInstance().synMsgToPlayer(target.ctx, msg);
        }
    }

    /**
     * 同步百团战状态到玩家
     *
     * @param target
     * @param req    void
     */
    public void synWarStateToPlayer(Player target, SynWarStateRq req) {
        if (target != null && target.isLogin) {
            Base.Builder msg = PbHelper.createSynBase(SynWarStateRq.EXT_FIELD_NUMBER, SynWarStateRq.ext, req);
            GameServer.getInstance().synMsgToPlayer(target.ctx, msg);
        }
    }

    /**
     * 同步要塞战状态到攻击方玩家
     *
     * @param target
     * @param req    void
     */
    public void synFortressStateToPlayer(Player target, SynFortressBattleStateRq req) {
        if (target != null && target.isLogin) {
            Base.Builder msg = PbHelper.createSynBase(SynFortressBattleStateRq.EXT_FIELD_NUMBER, SynFortressBattleStateRq.ext, req);
            GameServer.getInstance().synMsgToPlayer(target.ctx, msg);
        }
    }

    /**
     * 资源增加同步到玩家
     *
     * @param target
     * @param type
     * @param count  void
     */
    public void synResourceToPlayer(Player target, int type, int count) {
        rewardService.synResourceToPlayer(target, type, count);
    }

    public void synResourceToPlayer(Player target, long r1, long r2, long r3, long r4, long r5) {
        rewardService.synResourceToPlayer(target, r1, r2, r3, r4, r5);
    }

    public void synBuildToPlayer(Player target, BuildQue buildQue, int state) {
        if (target != null && target.isLogin) {
            SynBuildRq.Builder builder = SynBuildRq.newBuilder();
            builder.setQueue(PbHelper.createBuildQuePb(buildQue));
            builder.setState(state);

            Base.Builder msg = PbHelper.createSynBase(SynBuildRq.EXT_FIELD_NUMBER, SynBuildRq.ext, builder.build());
            GameServer.getInstance().synMsgToPlayer(target.ctx, msg);
        }
    }

    /**
     * 同步编制变更到玩家
     *
     * @param target void
     */
    public void synStaffingToPlayer(Player target) {
        if (target != null && target.isLogin) {
            SynStaffingRq.Builder builder = SynStaffingRq.newBuilder();
            builder.setStaffingLv(target.lord.getStaffingLv());
            builder.setStaffingExp(target.lord.getStaffingExp());
            builder.setStaffing(target.lord.getStaffing());

            try {
                Base.Builder msg = PbHelper.createSynBase(SynStaffingRq.EXT_FIELD_NUMBER, SynStaffingRq.ext, builder.build());
                GameServer.getInstance().synMsgToPlayer(target.ctx, msg);
            } catch (Exception e) {
                LogUtil.error(e);
            }
        }
    }

    /**
     * 后台修改玩家道具数量推送
     *
     * @param target
     * @param type
     * @param listList
     */
    public void synInnerModPropsToPlayer(Player target, int type, List<List<Integer>> listList) {
        if (target != null && target.isLogin) {
            SynInnerModPropsRq.Builder builder = SynInnerModPropsRq.newBuilder();
            builder.setType(type);
            for (List<Integer> list : listList) {
                builder.addProps(PbHelper.createAtom2Pb(list.get(0), list.get(1), list.get(2)));
            }

            Base.Builder msg = PbHelper.createSynBase(SynInnerModPropsRq.EXT_FIELD_NUMBER, SynInnerModPropsRq.ext, builder.build());
            GameServer.getInstance().synMsgToPlayer(target.ctx, msg);
        }
    }

    // public void synPayRebateToPlayer(Player target, List<Long> statusList, int addGold){
    // if (target != null && target.isLogin) {
    // SynActPayRebateRq.Builder builder = SynActPayRebateRq.newBuilder();
    // builder.setPayRebate(PbHelper.createPayRebatePb(statusList, ActivityConst.COUNT_FOR_PAY_REBATE));
    // builder.setAddGold(addGold);
    //
    // Base.Builder msg = PbHelper.createSynBase(SynActPayRebateRq.EXT_FIELD_NUMBER, SynActPayRebateRq.ext,
    // builder.build());
    // GameServer.getInstance().synMsgToPlayer(target.ctx, msg);
    // }
    // }

    // public Mail addMail(Player player, int moldId, String... param) {
    // StaticMail staticMail = staticMailDataMgr.getStaticMail(moldId);
    // if (staticMail == null) {
    // return null;
    // }
    //
    // int type = staticMail.getType();
    // Mail mail = new Mail(player.maxKey(), type, moldId,
    // MailType.STATE_UNREAD, TimeHelper.getCurrentSecond());
    // if (param != null) {
    // mail.setParam(param);
    // }
    // player.mails.put(mail.getKeyId(), mail);
    // return mail;
    // }

    /**
     * Function:给邮件添加附件award里面必须包含keyId
     *
     * @param mail
     * @param award
     * @return
     */
    // public Mail addMailAward(Mail mail, Award award) {
    // List<Award> awardList = mail.getAward();
    // if (awardList == null) {
    // awardList = new ArrayList<Award>();
    // }
    // awardList.add(award);
    // return mail;
    // }

    /**
     * 发送系统模板邮件给帮派
     *
     * @param partyId 帮派ID
     * @param moldId  查询MailType中的mold值
     * @param param   没有时则传null
     * @return
     */
    public void sendMailToParty(int partyId, int moldId, String... param) {
        List<Member> memberList = partyDataManager.getMemberList(partyId);
        Iterator<Member> it = memberList.iterator();
        int now = TimeHelper.getCurrentSecond();
        while (it.hasNext()) {
            Member next = it.next();
            Player player = getPlayer(next.getLordId());
            if (player == null) {
                continue;
            }
            sendNormalMail(player, moldId, now, param);
        }
    }

    /**
     * 更新玩家任务
     *
     * @param player
     * @param cond     参见TaskType类
     * @param schedule 增加进度值
     * @param param
     */
    public void updTask(Player player, int cond, int schedule, int... param) {
        refreshTask(player);
        activityDataManager.activityTaskUpdata(player, cond, schedule); // 活动影响

        // 主线任务
        Iterator<Task> it1 = player.majorTasks.values().iterator();
        while (it1.hasNext()) {
            Task next = it1.next();
            StaticTask stask = staticTaskDataMgr.getTaskById(next.getTaskId());
            if (stask == null || stask.getCond() != cond) {
                continue;
            }
            modifyTaskSchedule(next, stask, schedule, param);
        }

        // 日常任务
        Iterator<Task> it2 = player.dayiyTask.iterator();
        while (it2.hasNext()) {
            Task next = it2.next();
            if (next.getAccept() != 1) {
                continue;
            }
            StaticTask stask = staticTaskDataMgr.getTaskById(next.getTaskId());
            if (stask == null || stask.getCond() != cond) {
                continue;
            }
            modifyTaskSchedule(next, stask, schedule, param);
        }

        // 活跃任务
        if (!staticFunctionPlanDataMgr.isLiveTaskOpen()) {// 通过新活跃度是否开启来判断刷新哪种活跃度任务
            updLiveTask(player, cond, schedule, param);// 没开启刷新老活跃度任务
        } else {
            updNewLiveTask(player, cond, schedule, param);// 开启了刷新新活跃度任务
        }

    }

    /**
     * 更新玩家老版活跃度任务
     *
     * @param player
     * @param cond     参见TaskType类
     * @param schedule 增加进度值
     * @param param
     */
    private void updLiveTask(Player player, int cond, int schedule, int... param) {
        Iterator<Task> it3 = player.liveTask.values().iterator();
        while (it3.hasNext()) {
            Task next = it3.next();
            StaticTask stask = staticTaskDataMgr.getTaskById(next.getTaskId());
            if (stask == null || stask.getCond() != cond) {
                continue;
            }

            if (next.getSchedule() >= stask.getSchedule()) {
                continue;
            }

            boolean flag = modifyTaskSchedule(next, stask, schedule, param);
            if (flag && next.getSchedule() >= stask.getSchedule()) {// 整个任务完成之后再加活跃值
                player.lord.setTaskLive(player.lord.getTaskLive() + stask.getLive());
            }
        }
    }

    /**
     * 更新玩家新版活跃度任务
     *
     * @param player
     * @param cond     参见TaskType类
     * @param schedule 增加进度值
     * @param param
     */
    private void updNewLiveTask(Player player, int cond, int schedule, int... param) {
        if (TimeHelper.getCNDayOfWeek() == 1 && !(TimeHelper.isMoreThan1300() || TimeHelper.isLessThan1200())) {// 判断时间是否为结算时间
            return;
        } else {
            Iterator<Task> it3 = player.liveTask.values().iterator();
            while (it3.hasNext()) {
                Task next = it3.next();
                StaticTask stask = staticTaskDataMgr.getTaskActivityById(next.getTaskId());
                if (stask == null || stask.getCond() != cond) {
                    continue;
                }
                if (stask.getCond() == TaskType.COND_USE_STONE) {// 单独处理水晶消耗任务
                    long sch = next.getSchedule();
                    boolean flag = modifyTaskSchedule(next, stask, schedule, param);
                    if (flag) {
                        if (next.getSchedule() > stask.getSchedule()) {
                            next.setSchedule(stask.getSchedule());
                        }
                        player.lord.setTaskLive((int) (player.lord.getTaskLive() + next.getSchedule() / 1000000 - sch / 1000000));
                    }
                    continue;
                }
                long sch = next.getSchedule();
                boolean flag = modifyTaskSchedule(next, stask, schedule, param);
                if (stask.getCond() == TaskType.COND_PAY_LIVE || stask.getCond() == TaskType.COND_HERO_LOTTERY2
                        || stask.getCond() == TaskType.COND_COST_GOLD2) {// 单独处理会无限完成的任务（极限任务）
                    if (flag) {
                        player.lord.setTaskLive(player.lord.getTaskLive()
                                + ((int) (next.getSchedule() / stask.getSchedule() - sch / stask.getSchedule()) * stask.getLive()));
                    }
                    continue;
                }
                if (next.getStatus() == 1) {
                    continue;
                }
                if (flag && next.getSchedule() >= stask.getSchedule()) {// 整个任务完成之后再加活跃值
                    player.lord.setTaskLive(player.lord.getTaskLive() + stask.getLive());
                    player.liveTask.get(stask.getTaskId()).setStatus(1);
                }
            }
            Set<Integer> set = player.liveTaskAward.keySet();// 如果活跃值达到标准刷新可领取的活跃度奖励状态
            for (Integer key : set) {
                if (player.liveTaskAward.get(key) == 0 && player.lord.getTaskLive() >= key) {
                    player.liveTaskAward.put(key, 1);
                }

            }
        }
    }

    /**
     * 更新任务状态玩家
     *
     * @param lordId
     * @param cond
     * @param schedule
     * @param param    void
     */
    public void updTask(long lordId, int cond, int schedule, int... param) {
        Player player = getPlayer(lordId);
        if (player != null) {
            updTask(player, cond, schedule, param);
        }
    }

    /**
     * 任务按类型单独处理,便于后期修改维护
     *
     * @param task
     * @param stask
     * @param schedule
     * @param param
     * @return
     */
    public boolean modifyTaskSchedule(Task task, StaticTask stask, int schedule, int... param) {
        if (task == null) {
            return false;
        }
        if (task.getSchedule() >= stask.getSchedule() && stask.getCond() != TaskType.COND_PAY_LIVE
                && stask.getCond() != TaskType.COND_HERO_LOTTERY2 && stask.getCond() != TaskType.COND_COST_GOLD2) {// 除了能无限完成的任务其余任务进度值大于目标值则返回false
            return false;
        }
        int cond = stask.getCond();
        switch (cond) {
            case TaskType.COND_TANK_PRODUCT: {// 生产坦克,炮车,火炮,火箭
                List<Integer> sparam = stask.getParam();
                if (sparam.size() == 1 && param.length == 1) {
                    int stankId = sparam.get(0);
                    int tankId = param[0];
                    if (stankId == 0 || tankId == stankId) {
                        task.setSchedule(task.getSchedule() + schedule);
                        return true;
                    }
                } else {
                    task.setSchedule(task.getSchedule() + schedule);
                    return true;
                }
                break;
            }
            case TaskType.COND_COMBAT: {// 攻打关卡
                List<Integer> sparam = stask.getParam();
                if (sparam.size() != 1 || param.length != 1) {
                    return false;
                }
                int scombatId = sparam.get(0);
                int combatId = param[0];
                if (scombatId == 0 || scombatId == combatId) {
                    task.setSchedule(task.getSchedule() + schedule);
                    return true;
                }
                break;
            }
            case TaskType.COND_ATTACK_PLAYER: {// 攻击玩家
                task.setSchedule(task.getSchedule() + schedule);
                return true;
            }
            case TaskType.COND_WIN_PLAYER: {// 攻击玩家
                task.setSchedule(task.getSchedule() + schedule);
                return true;
            }
            case TaskType.COND_ATTACK_COMBAT: {// 攻击关卡
                task.setSchedule(task.getSchedule() + schedule);
                return true;
            }
            case TaskType.COND_WIN_RESOURCE: { // 攻击世界资源胜利
                if (param.length != 1) {
                    return false;
                }
                int finishCount = stask.getParam().get(0);
                if (param[0] >= finishCount) {
                    task.setSchedule(task.getSchedule() + schedule);
                }
                return true;
            }
            case TaskType.COND_ATTACK_RESOURCE: {// 攻击世界资源
                if (param.length != 1) {
                    return false;
                }
                int finishCount = stask.getParam().get(0);
                if (finishCount == 0 || param[0] >= finishCount) {
                    task.setSchedule(task.getSchedule() + schedule);
                }
                return true;
            }
            case TaskType.COND_LIVE_COMBAT: {// 攻打关卡
                List<Integer> sparam = stask.getParam();
                int scombatId = sparam.get(0);
                if (scombatId == 2) {
                    task.setSchedule(task.getSchedule() + schedule);
                    return true;
                }
                break;
            }
            case TaskType.COND_BUILDING_LV_UP:// 任意建筑升级
            case TaskType.COND_EQUIP_LV_UP: // 装备升级
            case TaskType.COND_COST_GOLD: // 消费任意笔金币次数
            case TaskType.COND_SCIENCE_LV_UP: // 科技升级
            case TaskType.COND_ARENA: // 竞技场决斗
            case TaskType.COND_PART_EPR: // 碎片探险
            case TaskType.COND_EXTR_EPR: // 极限探险
            case TaskType.COND_EQUIP_EPR: // 极限探险
            case TaskType.COND_PARTY_COMBAT: // 军团试炼
            case TaskType.COND_LIMIT_COMBAT: // 废墟寻宝(限时副本)
            case TaskType.COND_PARTY_PROP: // 兑换军团道具
            case TaskType.COND_PARTY_DONATE: // 军团捐献
            case TaskType.COND_HERO_UP: // 武将进阶
            case TaskType.COND_HERO_LOTTERY: // 招募武将
            case TaskType.COND_HERO_LOTTERY2: // 招募武将
            case TaskType.COND_PARTY_BOX: // 军团试炼宝箱
            case TaskType.COND_PARTY_GUARD: // 军团驻军
            case TaskType.COND_UP_EQUIP: // 升级装备
            case TaskType.COND_UP_PART: // 强化配件
            case TaskType.COND_COST_GOLD2: // 累积消费金币
            case TaskType.COND_DAYIY_TASK_STARS: // 日常任务星级
            case TaskType.COND_FORTRESS_BATTLE: // 要塞战
            case TaskType.COND_WAR_PARTY: // 百团大战报名
            case TaskType.COND_FIGHT_REBEL: // 攻打叛军
            case TaskType.COND_DRILL_FIGHT: // 军事演习
            case TaskType.COND_WORLD_BOSS: // 攻打世界boss
            case TaskType.COND_PAY_LIVE: // 充值活跃
            case TaskType.COND_USE_STONE: // 消耗水晶
                task.setSchedule(task.getSchedule() + schedule);
                return true;
            default:
                break;
        }
        return false;
    }

    /**
     * 重置任务状态
     *
     * @param player
     * @return boolean
     */
    public boolean refreshTask(Player player) {
        int today = TimeHelper.getCurrentDay();
        Lord lord = player.lord;
        boolean flag = false;
        if (lord.getTaskLiveTime() != TimeHelper.getThisWeekMonday() && staticFunctionPlanDataMgr.isLiveTaskOpen()) {
            if (TimeHelper.getCNDayOfWeek() == 1 && !TimeHelper.isMoreThan1300()) {// 如果现在时间不等于这周一并且处于13点后则刷新活跃度
                if (TimeHelper.isLessThan1200() && lord.getTaskLiveTime() != TimeHelper.getLastMonday(new Date())) {// 如果今天是周一并且处于十二点前刷新
                    lord.setTaskLive(0);
                    lord.setTaskLiveAd(0);
                    lord.setTaskLiveTime(TimeHelper.getLastMonday(new Date()));
                    // 重置新活跃任务
                    refreshTask(player, 3);
                    flag = true;
                } else if (lord.getTaskLiveTime() != TimeHelper.getLastMonday(new Date())) {// 如果今天是周一且处于12-13点之间但是上次刷新时间不等于上周一则刷新（主要针对于周一12-13点间创的新号）
                    lord.setTaskLive(0);
                    lord.setTaskLiveAd(0);
                    lord.setTaskLiveTime(TimeHelper.getLastMonday(new Date()));
                    // 重置新活跃任务
                    refreshTask(player, 3);
                    flag = true;
                }
            } else {
                lord.setTaskLive(0);
                lord.setTaskLiveAd(0);
                lord.setTaskLiveTime(TimeHelper.getThisWeekMonday());
                // 重置新活跃任务
                refreshTask(player, 3);
                flag = true;
            }
        }
        if (today != lord.getTaskTime()) {
            if ((TimeHelper.getCNDayOfWeek() == 3 || TimeHelper.getCNDayOfWeek() == 6) && player.liveTask.size() != 0
                    && staticFunctionPlanDataMgr.isLiveTaskOpen()) {// 如果是星期三或者星期六刷新百团大战报名任务
                refreshTask(player, 4);
            }
            lord.setDayiyCount(0);
            lord.setTaskDayiy(0);
            lord.setTaskTime(today);

            // 重置日常任务
            refreshTask(player, 1);
            if (!staticFunctionPlanDataMgr.isLiveTaskOpen()) {// 使用老版活跃度
                lord.setTaskLive(0);
                lord.setTaskLiveAd(0);
                refreshTask(player, 2);
            }
            flag = true;
        }
        if (staticFunctionPlanDataMgr.isLiveTaskOpen()) {// 使用新版活跃度
            flag = true;
        }
        return flag;
    }

    /**
     * 重置任务状态
     *
     * @param player
     * @param type   任务类型 void
     */
    public void refreshTask(Player player, int type) {
        if (type == 1) {// 重置日常任务和活跃任务
            List<Integer> staskList = staticTaskDataMgr.getRadomDayiyTask();
            List<Task> dayiyList = player.dayiyTask;
            if (dayiyList.size() != 5) {// 由于一次线上等级表问题导致玩家任务删除后未同时增加一个BUG，此写法兼容新创建角色玩家
                dayiyList.clear();
                for (Integer taskId : staskList) {
                    Task task = new Task(taskId);
                    dayiyList.add(task);
                }
            } else {
                int i = 0;
                Iterator<Task> it = dayiyList.iterator();
                while (it.hasNext()) {
                    Task next = it.next();
                    int taskId = staskList.get(i++);
                    next.setTaskId(taskId);
                    next.setSchedule(0);
                    next.setAccept(0);
                    next.setStatus(0);
                }
            }
        } else if (type == 2) {// 日常活跃任务
            Map<Integer, Task> liveTaskMap = player.liveTask;
            if (liveTaskMap.size() == 0) {
                List<StaticTask> liveList = staticTaskDataMgr.getLiveList();
                for (StaticTask ee : liveList) {
                    Task task = new Task(ee.getTaskId());
                    liveTaskMap.put(ee.getTaskId(), task);
                }
            } else {
                Iterator<Task> it = liveTaskMap.values().iterator();
                while (it.hasNext()) {
                    Task task = it.next();
                    task.setSchedule(0);
                }
            }
        } else if (type == 3) {// 重置新版活跃度任务
            Map<Integer, Task> liveTaskMap = player.liveTask;
            player.liveTaskAward = new HashMap<Integer, Integer>();
            List<StaticTaskLiveActivity> getLiveList = staticTaskDataMgr.getNewTaskLive();
            for (StaticTaskLiveActivity staticTaskLive : getLiveList) {
                player.liveTaskAward.put(staticTaskLive.getLive(), 0);
            }
            List<StaticTask> liveList = staticTaskDataMgr.getNewLiveList();
            for (StaticTask ee : liveList) {
                Task task = new Task(ee.getTaskId());
                liveTaskMap.put(ee.getTaskId(), task);
            }
        } else if (type == 4) {// 活跃度百团大战报名3.6刷新
            Iterator<Task> it = player.liveTask.values().iterator();
            while (it.hasNext()) {
                Task next = it.next();
                StaticTask stask = staticTaskDataMgr.getTaskActivityById(next.getTaskId());
                if (stask != null) {
                    if (stask.getCond() == TaskType.COND_WAR_PARTY) {
                        player.liveTask.get(stask.getTaskId()).setStatus(0);
                        player.liveTask.get(stask.getTaskId()).setSchedule(0);
                    }
                }
            }
        }
    }

    // public void subKilledTank(Player player, Map<Integer, RptTank> tanks){
    // if (tanks == null || tanks.isEmpty()) {
    // return;
    // }
    //
    // Iterator<RptTank> it = tanks.values().iterator();
    // while (it.hasNext()) {
    // RptTank rptTank = (RptTank) it.next();
    // Tank tank = player.tanks.get(rptTank.getTankId());
    // subTank(tank, rptTank.getCount());
    // }
    // }

    /**
     * 判断坦克是否足够并扣除坦克
     *
     * @param player
     * @param form
     * @param tankCount
     * @param from
     * @return boolean
     */
    public boolean checkAndSubTank(Player player, Form form, int tankCount, AwardFrom from) {
        int totalTank = 0;
        int count = 0;
        Map<Integer, Integer> formTanks = new HashMap<Integer, Integer>();
        int[] p = form.p;
        int[] c = form.c;
        for (int i = 0; i < p.length; i++) {
            if (p[i] > 0) {
                count = rewardService.addTankMapCount(formTanks, p[i], c[i], tankCount);
                totalTank += count;
                c[i] = count;
            }
        }

        Map<Integer, Tank> tanks = player.tanks;
        for (Map.Entry<Integer, Integer> entry : formTanks.entrySet()) {
            Tank tank = tanks.get(entry.getKey());
            if (tank == null || tank.getCount() < entry.getValue()) {
                return false;
            }
        }

        if (totalTank == 0) {
            return false;
        }

        for (Map.Entry<Integer, Integer> entry : formTanks.entrySet()) {
            Tank tank = tanks.get(entry.getKey());
            subTank(player, tank, entry.getValue(), from);
        }

        return true;
    }

    /**
     * Method: subTank
     *
     * @Description: 扣除坦克 @param player @param tank @param count @param from @return void @throws
     */
    public Tank subTank(Player player, Tank tank, int count, AwardFrom from) {
        return rewardService.subTank(player, tank, count, from);
    }

    public void updateFight(Player player) {
        // int fight = calcFight(player);
        // player.lord.setFight(fight);
    }

    /**
     * Method: formSlotCount
     *
     * @Description: 阵容开启格子数量 @param lordLv @return @return int @throws
     */
    public int formSlotCount(int lordLv) {
        if (lordLv < 5) {
            return 2;
        } else if (lordLv < 6) {
            return 3;
        } else if (lordLv < 10) {
            return 4;
        } else if (lordLv < 15) {
            return 5;
        } else {
            return 6;
        }
    }

    /**
     * Method: formTankCount
     *
     * @param awakenHero
     * @Description: 阵型中一个格子的带兵量上限 @param player @param staticHero @return @return int @throws
     */
    public int formTankCount(Player player, StaticHero staticHero, AwakenHero awakenHero) {
        int tankCount = 0;
        Lord lord = player.lord;
        // 等级兵力
        StaticLordLv staticLordLv = staticLordDataMgr.getStaticLordLv(lord.getLevel());
        tankCount += staticLordLv.getTankCount();

        // 繁荣度兵力
        if (lord.getPros() != 0) {
            StaticLordPros staticProsLv = staticLordDataMgr.getStaticProsLv(lord.getPros());
            tankCount += staticProsLv.getTankCount();
        }

        // 统帅等级兵力
        if (lord.getCommand() != 0) {
            StaticLordCommand staticCommandLv = staticLordDataMgr.getStaticCommandLv(lord.getCommand());
            tankCount += staticCommandLv.getTankCount();
        }

        // 将领带兵量
        if (staticHero != null) {
            tankCount += staticHero.getTankCount();
        }

        // 觉醒将领effect增加带兵量
        if (awakenHero != null && !awakenHero.isUsed()) {
            for (Entry<Integer, Integer> entry : awakenHero.getSkillLv().entrySet()) {
                if (entry.getValue() <= 0) {
                    continue;
                }
                StaticHeroAwakenSkill staticHeroAwakenSkill = staticHeroDataMgr.getHeroAwakenSkill(entry.getKey(), entry.getValue());
                if (staticHeroAwakenSkill == null) {
                    LogUtil.error("觉醒将领技能未配置:" + entry.getKey() + " 等级:" + entry.getValue());
                    continue;
                }
                if (staticHeroAwakenSkill.getEffectType() == HeroConst.EFFECT_TYPE_TANK_COUNT) {
                    String val = staticHeroAwakenSkill.getEffectVal();
                    if (val != null && !val.isEmpty()) {
                        tankCount += Integer.parseInt(val);
                    }
                }
            }
        }

        // effect影响带兵量
        Effect effect = player.effects.get(EffectType.ADD_LEAD_SOLIDER_NUM);
        if (effect != null) {
            tankCount += 10;
        }

        effect = player.effects.get(EffectType.SUB_LEAD_SOLIDER_NUM);
        if (effect != null) {
            tankCount -= 10;
        }

        // 军备影响的带兵量
        int leqAdd = calcLordEquipoAddTankCount(player);
        if (leqAdd > 0)
            tankCount += leqAdd;

        // 作战实验室增加带兵量
        int labAdd = fightLabService.getSpecilAttrAdd(player, AttrId.SOLDER);
        if (labAdd > 0) {
            tankCount += labAdd;
        }

        // 荣耀生存buff更改带兵量
        int pos = player.lord.getPos();
        StaticHonourBuff honourBuff = honourDataManager.getHonourBuff(pos);
        if (honourBuff != null) {
            Map<Integer, Integer> attrBuff = honourBuff.getAttrBuff();
            if (attrBuff.containsKey(AttrId.SOLDER)) {
                int honourAdd = honourBuff.getAttrBuff().get(AttrId.SOLDER);
                if (honourBuff.getType() == -1) {
                    tankCount -= honourAdd;
                } else {
                    tankCount += honourAdd;
                }
            }
        }

        tankCount = tankCount >= 0 ? tankCount : 0;
        return tankCount;
    }

    /**
     * 计算军备增加坦克数量
     *
     * @param player
     * @return int
     */
    private int calcLordEquipoAddTankCount(Player player) {
        // 军备增加带兵量
        int tankCount = 0;
        Map<Integer, LordEquip> leqPuton = player.leqInfo.getPutonLordEquips();
        if (!leqPuton.isEmpty()) {
            for (Map.Entry<Integer, LordEquip> entry : leqPuton.entrySet()) {
                LordEquip leq = entry.getValue();
                StaticLordEquip staticData = staticEquipDataMgr.getStaticLordEquip(leq.getEquipId());
                if (staticData != null && staticData.getTankCount() > 0) {
                    tankCount += staticData.getTankCount();
                }
                // 洗练增加带兵量
                List<List<Integer>> lst = leq.getLordEquipSkillList();

                if (leq.getLordEquipSaveType() == 1) {
                    lst = leq.getLordEquipSkillSecondList();
                }

                if (!lst.isEmpty()) {
                    for (List<Integer> skill : lst) {
                        StaticLordEquipSkill sles = staticEquipDataMgr.getLordEquipSkillMap().get(skill.get(0));
                        if (sles != null && sles.getTankCount() > 0) {
                            tankCount += sles.getTankCount();
                        }
                    }
                }
            }
        }
        return tankCount;
    }

    /**
     * 同步金币到玩家
     *
     * @param target
     * @param addGold
     * @param addTopup
     * @param serialId void
     */
    public void synGoldToPlayer(Player target, int addGold, int addTopup, String serialId) {
        if (target != null && target.isLogin) {
            SynGoldRq.Builder builder = SynGoldRq.newBuilder();
            builder.setGold(target.lord.getGold());
            builder.setAddGold(addGold);
            builder.setAddTopup(addTopup);
            builder.setVip(target.lord.getVip());
            builder.setSerialId(serialId);
            Base.Builder msg = PbHelper.createSynBase(SynGoldRq.EXT_FIELD_NUMBER, SynGoldRq.ext, builder.build());
            GameServer.getInstance().synMsgToPlayer(target.ctx, msg);
        }
    }

    /**
     * 获取玩家的某种类型军备
     *
     * @param player
     * @param equipId
     * @return List<Equip>
     */
    public List<Equip> getMinLvEquipById(Player player, int equipId) {
        List<Equip> rets = new ArrayList<Equip>();
        Map<Integer, Equip> equipMap = player.equips.get(0);
        Iterator<Equip> it = equipMap.values().iterator();
        while (it.hasNext()) {
            Equip next = it.next();
            if (next.getEquipId() == equipId) {
                rets.add(next);
            }
        }
        return rets;
    }

    /**
     * 玩家的指定配件
     *
     * @param player
     * @param partId
     * @return Part
     */
    public Part getMinLvPartById(Player player, int partId) {
        Part part = null;
        Map<Integer, Part> partMap = player.parts.get(0);
        Iterator<Part> it = partMap.values().iterator();
        while (it.hasNext()) {
            Part next = it.next();
            if (next.getPartId() == partId) {
                if (part == null) {
                    part = next;
                } else if (next.getRefitLv() < part.getRefitLv()) {// 改造等级低的优先
                    part = next;
                } else {
                    if (next.getUpLv() < part.getUpLv()) {// 同改造等级,等级低的优先
                        part = next;
                    }
                }
            }
        }
        return part;
    }

    /**
     * 作弊玩家
     *
     * @param lordId
     * @return Guy
     */
    public Guy getGuy(long lordId) {
        Guy guy = guyMap.get(lordId);
        if (guy == null) {
            guy = new Guy(lordId);
            guyMap.put(lordId, guy);
        }
        return guy;
    }

    private class Load {
        LoadProcess process = new LoadProcess();

        /**
         * Method: load
         *
         * @Description: 从数据库加载所有玩家数据 @return void @throws
         */
        public void load() {
            LogUtil.start("begin load all players data, waiting!!!");
            int now = TimeHelper.getCurrentSecond();
            List<Lord> list = lordDao.load();
            process.setTotalLord(list.size());
            Player player = null;
            int loaded = 0;
            for (Lord lord : list) {
                this.checkOffTime(lord);
                process.setLoadedLord(++loaded);
                if (smallIdManager.isSmallId(lord.getLordId())) {
                    // 小号不加载
                    if (lord.getNick() != null) {
                        usedNames.add(lord.getNick());
                    }
                    continue;
                }

                if (lord.getNick() != null) {
                    player = new Player(lord, now);
                    addPlayer(player);
                    if (lord.getPos() != -1) {
                        worldDataManager.putPlayer(player);
                    }
                    usedNames.add(lord.getNick());

                    // if (lord.getLevel() >= 18) {// 20151201
                    // 18级以上经验表修改了，重新计算等级
                    // addExp(lord, 0);
                    // }
                } else {
                    newPlayerCache.put(lord.getLordId(), new Player(lord, now));
                }
            }
            LogUtil.start(String.format("p_lord数据加载完成，开始从数据库读取 p_account 数据"));
            loadAccount();
            LogUtil.start(String.format("p_account数据加载完成,开始从数据库读取 p_building 数据"));
            loadBuilding();
            LogUtil.start(String.format("p_building数据加载完成,开始从数据库读取 p_resource 数据"));
            loadResource();
            LogUtil.start(String.format("p_resource数据加载完成,开始从数据库读取 p_data 数据"));
            loadData();
            LogUtil.start(String.format("p_resource数据加载完成,开始从数据库读取其他数据"));
            loadGuy();
            loadAD();
            // 计算空余的位置集合
            // worldDataManager.caluFreePostList();
            // worldDataManager.randomNewPos();//错误玩家pos重新随机
            // repairPlayerNameRepeatBug();

            // LogHelper.ERROR_LOGGER.error("done load all players data!!!");
            LogUtil.start("done load all players data!!!");
        }

        /**
         * 检测如果下线时间为yyyymmdd格式,则将offtime改为ontime
         *
         * @param lord
         */
        public void checkOffTime(Lord lord) {
            Pattern p = Pattern.compile("^2\\d{7}$");
            boolean flag = p.matcher(String.valueOf(lord.getOffTime())).find();
            if (flag) {
                lord.setOffTime(lord.getOnTime());
            }
        }

        /**
         * Method: loadAccount
         *
         * @Description: 加载账号数据 @return void @throws
         */
        private void loadAccount() {
            List<Account> list = accountDao.load();
            process.setTotalAccount(list.size());
            Player player = null;
            int loaded = 0;
            for (Account account : list) {
                process.setLoadedAccount(++loaded);

                // 若是小号，直接添加到accountCache中
                if (!smallIdManager.isSmallId(account.getLordId())) {
                    if (account.getCreated() == 1) {
                        player = playerCache.get(account.getLordId());
                        if (player != null) {
                            player.account = account;
                        }

                    } else {
                        player = newPlayerCache.get(account.getLordId());
                        if (player != null) {
                            player.account = account;
                        }
                    }
                    if (player != null) {
                        addRecThreeMonthPlayer(player);
                    }
                }
                if (account.getLordId() > 0) {
                    loadIds(account.getLordId());
                }
                getAccountMap(account.getServerId()).put(account.getAccountKey(), account);
            }

            // //启动时打印
            // for (Map.Entry<Integer, Map<Integer, AtomicInteger>> entry : idMap.entrySet()) {
            // for (Map.Entry<Integer, AtomicInteger> srvEntry : entry.getValue().entrySet()) {
            // AtomicInteger atom = srvEntry.getValue();
            // LogUtil.start(String.format("platNo :%d, server id :%d, atom :%d", entry.getKey(), srvEntry.getKey(),
            // atom.get()));
            // }
            // }
        }

        /**
         * Method: loadResource
         *
         * @Description: 加载资源数据 @return void @throws
         */
        private void loadResource() {
            List<Resource> list = resourceDao.load();
            Player player = null;
            for (Resource resource : list) {
                if (!smallIdManager.isSmallId(resource.getLordId())) {
                    player = playerCache.get(resource.getLordId());
                    if (player != null) {
                        player.resource = resource;
                    }
                }
            }
        }

        /**
         * Method: loadBuilding
         *
         * @Description: 加载建筑数据 @return void @throws
         */
        private void loadBuilding() {
            List<Building> list = buildingDao.load();
            Player player = null;
            for (Building building : list) {
                if (!smallIdManager.isSmallId(building.getLordId())) {
                    player = playerCache.get(building.getLordId());
                    if (player != null) {
                        player.building = building;
                    }
                }
            }
        }

        /**
         * Method: loadBuilding
         *
         * @Description: 加载广告数据 @return void @throws
         */
        private void loadAD() {
            List<Advertisement> list = advertisementDao.load();
            Player player = null;
            for (Advertisement advertisement : list) {
                if (!smallIdManager.isSmallId(advertisement.getLordId())) {
                    player = playerCache.get(advertisement.getLordId());
                    if (player != null) {
                        player.advertisement = advertisement;
                    }
                }
            }
        }

        /**
         * 服务器加载数据时调用 如果队伍在行军或者矿点采集 则在地图上增加此玩家行为
         *
         * @param player void
         */
        private void fillGuardAndMarch(Player player) {
            int state;
            List<Army> armys = player.armys;
            for (Army army : armys) {
                state = army.getState();
                if (state == ArmyState.COLLECT || state == ArmyState.GUARD || state == ArmyState.WAIT) {
                    if (!army.isCrossMine()) {
                        if (army.getSenior()) {
                            seniorMineDataManager.setGuard(new Guard(player, army));
                        } else {
                            worldDataManager.setGuard(new Guard(player, army));
                        }
                    }
                } else if (state == ArmyState.MARCH || state == ArmyState.AID) {
                    worldDataManager.addMarch(new March(player, army));
                }
            }
        }

        /**
         * 加载基地外观
         *
         * @param player void
         */
        private void setSurface(Player player) {
            if (player.effects.containsKey(EffectType.CHANGE_SURFACE_1)) {
                player.surface = 1;
            } else if (player.effects.containsKey(EffectType.CHANGE_SURFACE_2)) {
                player.surface = 2;
            } else if (player.effects.containsKey(EffectType.CHANGE_SURFACE_3)) {
                player.surface = 3;
            } else if (player.effects.containsKey(EffectType.CHANGE_SURFACE_4)) {
                player.surface = 4;
            } else if (player.effects.containsKey(EffectType.CHANGE_SURFACE_5)) {
                player.surface = 5;
            } else if (player.effects.containsKey(EffectType.CHANGE_SURFACE_6)) {
                player.surface = 6;
            } else if (player.effects.containsKey(EffectType.CHANGE_SURFACE_7)) {
                player.surface = 7;
            } else if (player.effects.containsKey(EffectType.CHANGE_SURFACE_991)) {
                player.surface = 991;
            } else if (player.effects.containsKey(EffectType.CHANGE_SURFACE_992)) {
                player.surface = 992;
            } else if (player.effects.containsKey(EffectType.CHANGE_SURFACE_993)) {
                player.surface = 993;
            } else if (player.effects.containsKey(EffectType.CHANGE_SURFACE_2001)) {
                player.surface = 2001;
            } else if (player.effects.containsKey(EffectType.CHANGE_SURFACE_2002)) {
                player.surface = 2002;
            } else if (player.effects.containsKey(EffectType.NEW_YEAR_2003)) {
                player.surface = 2003;
            } else if (player.effects.containsKey(EffectType.CHANGE_SURFACE_2005)) {
                player.surface = 2005;
            }
        }

        /**
         * 加载玩家数据 void
         */
        private void loadData() {
            List<DataNew> list = dataDao.loadData();
            Map<Long, List<NewMail>> mailList = mailDao.loadMail();
            Map<Long, Long> ids = new ConcurrentSkipListMap<>();
            process.setTotalData(list.size());
            Player player = null;
            int loaded = 0;
            for (DataNew data : list) {
                process.setLoadedData(++loaded);

                // 小号不load
                if (!smallIdManager.isSmallId(data.getLordId())) {
                    player = playerCache.get(data.getLordId());
                    if (player != null) {
                        try {
                            player.dserNewData(data);
                            fillGuardAndMarch(player);
                            checkPendant(player);
                            checkPortrait(player);
                            if (player.lord.getPos() != -1) {
                                setSurface(player);
                                // rankDataManager.load(player);
                                ids.put(dataRepairDM.getOldLordId(data.getLordId()), data.getLordId());
                                staffingDataManager.addStaffingPlayer(player);
                            }
                            repairCombatStar(player);

                            // 设置邮件
                            player.loadMail(mailList.get(data.getLordId()));
                        } catch (InvalidProtocolBufferException e) {
                            // LogHelper.ERROR_LOGGER.error(e, e);
                            GameServer.getInstance().startSuccess = false;
                            LogUtil.error("load player data exception, lordId:" + data.getLordId(), e);
                            System.exit(1);// 数据初始化错误

                        }
                    }
                }
            }

            for (Map.Entry<Long, Long> entry : ids.entrySet()) {
                Player player0 = playerCache.get(entry.getValue());
                rankDataManager.load(player0);
                // LogUtil.common(String.format("rank data mgr add player :%d, nick :%s, old lord Id :%d",
                // entry.getValue(), player0.lord.getNick(), entry.getKey()));
            }

            rankDataManager.sort();
            staffingDataManager.sortStaffing();
        }

        /**
         * Method: loadResource
         *
         * @Description: 加载举报数据 @return void @throws
         */
        private void loadGuy() {
            List<TipGuy> tipGuyList = tipGuyDao.loadTipGuy();
            for (TipGuy tipGuy : tipGuyList) {
                Guy guy = new Guy(tipGuy);
                guyMap.put(guy.getLordId(), guy);
            }
        }
    }

    /**
     * 保存玩家数据
     *
     * @param role void
     */
    public void updateRole(Role role) {
        lordDao.updateLord(role.getLord());
        buildingDao.updateBuilding(role.getBuilding());
        resourceDao.updateResource(role.getResource());
        dataDao.updateData(role.getData());
        if (role.getArena() != null) {
            if (arenaDao.updateArena(role.getArena()) == 0) {
                arenaDao.insertArena(role.getArena());
            }
        }

        if (role.getPartyMember() != null) {
            if (partyDao.updateParyMember(role.getPartyMember()) == 0) {
                partyDao.insertParyMember(role.getPartyMember());
            }
        }

        if (role.getBossFight() != null) {
            if (bossDao.updateData(role.getBossFight()) == 0) {
                bossDao.insertData(role.getBossFight());
            }
        }

        if (role.getAltarBossFight() != null) {
            if (bossDao.updateData(role.getAltarBossFight()) == 0) {
                bossDao.insertData(role.getAltarBossFight());
            }
        }

        // 如果有新邮件，则插入数据库
        saveMail(role.getRoleId(), role.getSaveMails());

        // 如果有更改状态的邮件，则更新数据库
        updMail(role.getRoleId(), role.getUpdateMails());

        // 如果有删除的邮件，则更新数据库删除标志
        delMail(role.getRoleId(), role.getDelMails());
    }

    /**
     * 数据库 删除邮件
     *
     * @param lordId
     * @param delMails
     */
    private void delMail(long lordId, List<Integer> delMails) {
        if (delMails == null)
            return;
        for (Integer keyId : delMails) {
            NewMail newMail = new NewMail();
            newMail.setLordId(lordId);
            newMail.setKeyId(keyId);
            mailDao.delMail(newMail);
        }
    }

    /**
     * 数据库更新邮件状态
     *
     * @param lordId
     * @param updateMails
     */
    private void updMail(long lordId, List<List<Integer>> updateMails) {
        if (updateMails == null)
            return;
        for (List<Integer> list : updateMails) {
            NewMail newMail = new NewMail();
            newMail.setLordId(lordId);
            newMail.setKeyId(list.get(0));
            newMail.setState(list.get(1));
            newMail.setCollections(list.get(2));
            mailDao.updateState(newMail);
        }
    }

    /**
     * 新邮件入库
     *
     * @param lordId
     * @param list
     */
    private void saveMail(long lordId, List<Mail> list) {
        if (list == null)
            return;
        for (Mail mail : list) {
            NewMail newMail = MailHelper.createNewMail(lordId, mail);
            try {
                mailDao.insertMail(newMail);
            } catch (Exception e) {
                LogUtil.error("", e);
            }
        }
    }

    /**
     * 保存玩家举报到数据库
     *
     * @param tipGuy void
     */
    public void updatGuy(TipGuy tipGuy) {
        if (tipGuyDao.updateTipGuy(tipGuy) == 0) {
            tipGuyDao.insertTipGuy(tipGuy);
        }
    }

    /**
     * Method: calcCollect
     *
     * @Description: 计算当前部队携带的资源量 @param player @param army @param now @param staticMine @param collect @return @return
     * long @throws
     */
    public long calcCollect(Player player, Army army, int now, StaticMine staticMine, int collect) {
        long get = 0;
        if (army.getGrab() != null) {
            get = army.getGrab().rs[staticMine.getType() - 1];
        }

        long payload = 0;
        Collect c = army.getCollect();
        if (c != null) {
            collect = (int) (collect * (1 + c.speed / NumberHelper.HUNDRED_FLOAT));
            payload = c.load;
        } else {
            payload = calcLoad(player, army.getForm(), army.isRuins());
        }

        get = get + (long) ((now - (army.getEndTime() - army.getPeriod())) / ((double) TimeHelper.HOUR_S) * collect);

        if (get > payload) {
            get = payload;
        }

        return get;
    }

    /**
     * Method: retreatEnd
     *
     * @Description: 军事矿区部队召回 @param player @param army @return void @throws
     */
    public void retreatEnd(Player player, Army army) {
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
            if (awakenHero != null) {
                awakenHero.setUsed(false);
                LogLordHelper.awakenHero(AwardFrom.RETREAT_END, player.account, player.lord, awakenHero, 0);
            }

        } else {
            int heroId = army.getForm().getCommander();
            if (heroId > 0) {
                addHero(player, heroId, 1, AwardFrom.RETREAT_END);
                worldService.removeExpireHero(player, heroId);
            }
        }

        if (!army.getForm().getTactics().isEmpty()) {
            tacticsService.cancelUseTactics(player, army.getForm().getTactics());
        }

        // 加资源
        Grab grab = army.getGrab();
        if (grab != null) {
            gainGrab(player, grab);
            StaticMine staticMine = null;
            if (army.isCrossMine()) {
                staticMine = seniorMineDataManager.getCrossSeniorMine(army.getTarget());
            } else if (army.getSenior()) {
                staticMine = seniorMineDataManager.evaluatePos(army.getTarget());
            }
            if (staticMine != null) {
                partyDataManager.collectMine(player.roleId, grab);
                activityDataManager.resourceCollect(player, ActivityConst.ACT_COLLECT_RESOURCE, grab);// 资源采集活动
                activityDataManager.beeCollect(player, ActivityConst.ACT_BEE_ID, grab);// 勤劳致富
                activityDataManager.beeCollect(player, ActivityConst.ACT_BEE_NEW_ID, grab);// 勤劳致富（新）
                activityDataManager.amyRebate(player, 0, grab.rs, ActivityConst.ACT_AMY_ID);// 建军节欢庆
                activityDataManager.amyRebate(player, 0, grab.rs, ActivityConst.ACT_AMY_ID2);// 建军节欢庆(新)
                activityKingService.updataResourceData(player, grab.rs);//最强王者
            }
        }
    }

    public int armyCount(Player player) {
        StaticVip staticVip = staticVipDataMgr.getStaticVip(player.lord.getVip());
        if (staticVip != null) {
            return staticVip.getArmyCount();
        }
        return 3;
    }


    public int getPlayArmyCount(Player player, int maxCount) {
        int armyCount = player.armys.size();

        boolean warbin = false;
        boolean aidbin = false;
        for (Army army : player.armys) {
            if (army.getState() == ArmyState.WAR) {
                warbin = true;
            }
            if (army.getIsZhuJun() == 1) {
                aidbin = true;
            }
        }

        if (warbin) {
            armyCount = armyCount - 1;
        }

        if (aidbin) {
            if (armyCount < (maxCount + 1)) {
                armyCount = armyCount - 1;
            }
        }
        return armyCount;
    }


    /**
     * 记录资源产量 void
     */
    public void logResourceHour() {
        for (Player player : recThreeMonOnlPlayer.values()) {
            Resource resource = player.resource;
            int reduce = 0;
            if (isRuins(player)) {
                reduce = 100;
            }
            int ironOut = (int) (resource.getIronOut() * (100 + resource.getIronOutF() - reduce) / 6000.0f);
            int oilOut = (int) (resource.getOilOut() * (100 + resource.getOilOutF() - reduce) / 6000.0f);
            int copperOut = (int) (resource.getCopperOut() * (100 + resource.getCopperOutF() - reduce) / 6000.0f);
            int siliconOut = (int) (resource.getSiliconOut() * (100 + resource.getSiliconOutF() - reduce) / 6000.0f);
            int stoneOut = (int) (resource.getStoneOut() * (100 + resource.getStoneOutF() - reduce) / 6000.0f);

            long[] resources = {ironOut, oilOut, copperOut, siliconOut, stoneOut};
            LogLordHelper.resourceTimeAdd(player.account, player.lord, player.resource, resources);
        }
    }

    /**
     * 在线玩家记录日志 void
     */
    public void logOnlinePlayer() {
        LogLordHelper.onlineNum(-1, onlinePlayer.size());
        Map<Integer, Integer> channelNumMap = new HashMap<>();
        for (Player player : onlinePlayer.values()) {
            int channel = player.account.getPlatNo();
            Integer num = channelNumMap.get(channel);
            if (num == null) {
                channelNumMap.put(channel, 1);
            } else {
                channelNumMap.put(channel, num + 1);
            }
        }
        for (Integer id : channelNumMap.keySet()) {
            LogLordHelper.onlineNum(id, channelNumMap.get(id));
        }
    }

    /**
     * 替换废墟名字 玩家已经改名
     */
    public void replaceRuinsName(Player player) {
        Ruins r = player.ruins;
        if (r.isRuins()) {
            Player p = getPlayer(r.getLordId());
            if (p == null) {
                r.setRuins(false);
                r.setLordId(0);
                r.setAttackerName("");
                return;
            }
            r.setAttackerName(p.lord.getNick());
        }
    }

    /**
     * 修复以前通关后关卡总星数问题858！=861
     */
    private void repairCombatStar(Player player) {
        if (player.combats.size() == staticCombatDataMgr.getStaticCombatSize()) {
            int stars = 0;
            for (Combat c : player.combats.values()) {
                stars += c.getStar();
            }
            player.lord.setStars(stars);
        }
    }

    /**
     * 改名后替换其他地方记录的玩家名
     *
     * @param player
     * @param newName void
     */
    public void replaceName(Player player, String newName) {
        long lordId = player.lord.getLordId();
        // 军团长名字
        Member m = partyDataManager.getMemberById(lordId);
        if (m != null && m.getJob() == PartyType.LEGATUS) {
            PartyData partyData = partyDataManager.getParty(m.getPartyId());
            if (partyData != null) {
                partyData.setLegatusName(newName);
            }
        }
        // 红蓝大战排名 ---
        for (LinkedHashMap<Long, DrillRank> rankDataMap : drillDataManager.getDrillShowRank().values()) {
            DrillRank rank = rankDataMap.get(lordId);
            if (rank != null) {
                rank.setName(newName);
            }
        }
        // 叛军集合数据 ---
        if (player.rebelData != null) {
            player.rebelData.setNick(newName);
        }
        // BOSS击杀
        String killer = bossDataManager.getKiller();
        if (killer != null && killer.equals(player.lord.getNick())) {
            bossDataManager.setKiller(newName);
        }
    }

    /**
     * 修复以前玩家重名，修正
     */
    public void repairPlayerNameRepeatBug() {
        Set<String> existName = new HashSet<>();
        Iterator<Player> iterator = getPlayers().values().iterator();
        while (iterator.hasNext()) {
            Player player = iterator.next();
            String nick = player.lord.getNick();
            if (!existName.add(nick)) {
                // 修改玩家名字 并发送改名卡
                String newNick = null;
                int i = 0;
                while (newNick == null) {
                    if (canUseName(nick + i)) {
                        newNick = nick + i;
                    }
                    i++;
                }
                usedNames.add(newNick);
                replaceName(player, newNick);
                player.lord.setNick(newNick);
                allPlayer.put(player.lord.getNick(), player);
                addProp(player, PropId.CHANGE_NAME, 1, AwardFrom.REPAIR_NAME);
                LogUtil.error(player.lord.getLordId() + ",存在玩家重名,修复名字 " + nick + "-->" + newNick);
            }
        }
    }

    /**
     * 获取7日活动小红点
     */
    public List<Integer> getActDayTaskTips(Player player) {
        Date now = new Date();
        Date beginTime = TimeHelper.getDateZeroTime(player.account.getCreateDate());
        int dayiy = DateHelper.dayiy(beginTime, now);

        List<Integer> listTips = new ArrayList<Integer>(7);
        for (int i = 1; i <= 7; i++) {
            listTips.add(0);
            List<StaticDay7Act> list = staticWarAwardDataMgr.getDay7ActList(i);
            if (list == null) {
                continue;
            }
            Day7Act day7Act = player.day7Act;
            int tips = 0;
            for (StaticDay7Act e : list) {
                // if(e.getType() == 18){//半价限购不需要小红点
                // continue;
                // } 坦克版本需要
                if (day7Act.getRecvAwardIds().contains(e.getKeyId())) {
                    continue;
                }
                if (e.getDay() > dayiy) {
                    continue;
                }
                long status = getDay7ActStatus(player, e);
                if (e.getType() != 8) {
                    if (status >= e.getCond()) {
                        day7Act.getCanRecvKeyId().add(e.getKeyId());
                        tips++;
                    }
                } else {
                    if (status <= e.getCond()) {
                        tips++;
                    }
                }
            }
            listTips.set(i - 1, tips);
        }
        return listTips;
    }

    /**
     * 取当前奖励状态
     */
    public int getDay7ActStatus(Player player, StaticDay7Act staticDay7Act) {
        int lvMax = 0;
        switch (staticDay7Act.getType()) {
            case 1:// 指挥中心等级达到5
            case 2:// 副本总星数累计达到30
            case 3:// 兵工厂等级达到4
            case 5:// 科研中心等级达到6
            case 7:// 任意资源建筑等级达到8
            case 9:// 所有科技总等级累计达到5
            case 10:// 资源采集量累计达到300K
            case 11:// 繁荣度达到400
            case 12:// 统率等级达到10
            case 13:// 战力值达到10000
            case 14:// 技能总等级累计达到50
            case 16:// 主角等级等级奖励1
            case 17:// 累计充值奖励1
                if (player.day7Act.getStatus().containsKey(staticDay7Act.getType())) {
                    lvMax += player.day7Act.getStatus().get(staticDay7Act.getType());
                }
                break;
            case 4:// 5级白色及以上装备累计2件
                for (int[] e : player.day7Act.getEquips()) {
                    if (e[0] >= staticDay7Act.getParam().get(0) && e[1] >= staticDay7Act.getParam().get(1)) {
                        lvMax++;
                    }
                }
                break;
            case 6:// 制造完成绿色或以上战车累计50个
                int tankType = staticDay7Act.getParam().get(0);
                if (player.day7Act.getTankTypes().containsKey(tankType)) {
                    lvMax += player.day7Act.getTankTypes().get(tankType);
                }
                break;
            case 8:// 竞技场排名当前达到20
                if (player.day7Act.getStatus().containsKey(staticDay7Act.getType())) {
                    lvMax += player.day7Act.getStatus().get(staticDay7Act.getType());
                } else {
                    lvMax = 501;
                }
                break;
            case 15:// 免费赠送1
                break;
            case 18:// 半价限购1
                break;
            default:
                break;
        }
        return lvMax;
    }

    /**
     * 更新7天活动状态
     *
     * @param player
     * @param type
     * @param params void
     */
    public void updDay7ActSchedule(Player player, int type, Object... params) {
        try {
            Day7Act day7Act = player.day7Act;
            // 加个临时变量-使判断速度加快
            if (day7Act.isExpired()) {
                return;
            }
            long time = TimeHelper.getDateZeroTime(player.account.getCreateDate()).getTime() + (7) * TimeHelper.DAY_S * 1000;
            if (System.currentTimeMillis() > time) {
                day7Act.setExpired(true);
                return;
            }

            long status = 0;
            int param = 0;

            switch (type) {
                case 1:// 指挥中心等级达到5
                case 2:// 副本总星数累计达到30
                case 3:// 兵工厂等级达到4
                case 5:// 科研中心等级达到6
                case 7:// 任意资源建筑等级达到8
                case 11:// 繁荣度达到400
                case 12:// 统率等级达到10
                case 13:// 战力值达到10000
                case 16:// 主角等级等级奖励1
                    param = Long.valueOf(params[0] + "").intValue();
                    if (day7Act.getStatus().containsKey(type)) {
                        status = day7Act.getStatus().get(type);
                    }
                    if (param > status) {
                        day7Act.getStatus().put(type, param);
                    }
                    break;
                case 4:// 5级白色及以上装备累计2件
                    day7Act.getEquips().clear();
                    for (int i = 0; i < 7; i++) {
                        Map<Integer, Equip> map = player.equips.get(i);
                        if (map != null) {
                            Iterator<Equip> it = map.values().iterator();
                            while (it.hasNext()) {
                                Equip equip = it.next();

                                if (equip.getEquipId() >= 701) {
                                    continue;
                                }
                                day7Act.getEquips().add(new int[]{equip.getLv(), equip.getEquipId() % 10});
                            }
                        }
                    }
                    break;
                case 6:// 制造完成绿色或以上战车累计50个
                    int tankId = (int) params[0];
                    int count = (int) params[1];
                    StaticTank staticTank = staticTankDataMgr.getStaticTank(tankId);
                    if (staticTank == null) {
                        return;
                    }
                    if (staticTank.getGrade() < 2) {
                        return;
                    }
                    int tankType = staticTank.getType();
                    status += count;
                    if (day7Act.getTankTypes().containsKey(tankType)) {
                        status += day7Act.getTankTypes().get(tankType);
                    }
                    day7Act.getTankTypes().put(tankType, (int) status);
                    break;
                case 8:// 竞技场排名当前达到20
                    param = Long.valueOf(params[0] + "").intValue();
                    day7Act.getStatus().put(type, param);
                    break;
                case 9:// 所有科技总等级累计达到5
                    for (Science science : player.sciences.values()) {
                        status += science.getScienceLv();
                    }
                    day7Act.getStatus().put(type, (int) status);
                    break;
                case 10:// 资源采集量累计达到300K
                    Grab grab = (Grab) params[0];
                    status += grab.rs[0];
                    status += grab.rs[1];
                    status += grab.rs[2];
                    status += grab.rs[3];
                    status += grab.rs[4];
                    if (day7Act.getStatus().containsKey(type)) {
                        status += day7Act.getStatus().get(type);
                    }
                    if (status >= Integer.MAX_VALUE) {
                        status = Integer.MAX_VALUE;
                    }
                    day7Act.getStatus().put(type, (int) status);
                    break;
                case 14:// 技能总等级累计达到50
                    for (Integer val : player.skills.values()) {
                        status += val;
                    }
                    day7Act.getStatus().put(type, (int) status);
                    break;
                case 17:// 累计充值奖励1
                    status = (Integer) params[0];
                    if (day7Act.getStatus().containsKey(type)) {
                        status += day7Act.getStatus().get(type);
                    }
                    day7Act.getStatus().put(type, (int) status);
                    break;
                default:
                    return;
            }

            List<StaticDay7Act> list = staticWarAwardDataMgr.getDay7ActTypeList(type);
            if (list == null) {
                return;
            }

            Date now = new Date();
            Date beginTime = TimeHelper.getDateZeroTime(player.account.getCreateDate());
            int dayiy = DateHelper.dayiy(beginTime, now);

            int tips = 0;
            if (type != 8) {
                for (StaticDay7Act e : list) {
                    if (day7Act.getCanRecvKeyId().contains(e.getKeyId())) {
                        continue;
                    }
                    if (day7Act.getRecvAwardIds().contains(e.getKeyId())) {
                        continue;
                    }
                    if (e.getDay() > dayiy) {
                        continue;
                    }
                    status = getDay7ActStatus(player, e);
                    if (status >= e.getCond()) {
                        day7Act.getCanRecvKeyId().add(e.getKeyId());
                        tips++;
                    }
                }
            } else {
                tips = 1;
            }
            if (tips > 0) {
                synDay7ActToPlayer(player);
            }
        } catch (NumberFormatException e) {
            LogUtil.error(e);
        }
    }

    /**
     * 同步7天活动到玩家
     *
     * @param target void
     */
    public void synDay7ActToPlayer(Player target) {
        if (target != null && target.isLogin) {
            SynDay7ActTipsRq.Builder builder = SynDay7ActTipsRq.newBuilder();

            Base.Builder msg = PbHelper.createSynBase(SynDay7ActTipsRq.EXT_FIELD_NUMBER, SynDay7ActTipsRq.ext, builder.build());
            GameServer.getInstance().synMsgToPlayer(target.ctx, msg);
        }
    }

    /**
     * 修复线上由于等级表未传，导致获取经验报错，导致每日任务领奖后不增加一个任务BUG，数据修正从<5改为5
     */
    public void repairPlayerDayiyTaskBug() {
        Iterator<Player> iterator = getPlayers().values().iterator();
        while (iterator.hasNext()) {
            Player player = iterator.next();
            List<Task> dayiyList = player.dayiyTask;
            if (player.lord.getTaskTime() != 0 && dayiyList.size() != 5) {
                Set<Integer> curTaskIds = new HashSet<>();
                Iterator<Task> it = dayiyList.iterator();
                while (it.hasNext()) {
                    Task next = it.next();
                    curTaskIds.add(next.getTaskId());
                    // LogUtil.error("3修复线上由于等级表未传，导致获取经验报错，导致每日任务领奖后不增加一个任务BUG，数据修正从<5改为5");

                }
                while (dayiyList.size() < 5) {
                    // 随机出一个新的且不在当前存在任务集合中的一个id
                    int ntaskId = staticTaskDataMgr.getOneDayiyTask(curTaskIds);
                    Task ntask = new Task(ntaskId);
                    dayiyList.add(ntask);
                    curTaskIds.add(ntaskId);
                    LogUtil.error("2修复线上由于等级表未" + player.lord.getNick());

                }
                LogUtil.error("修正日常任务->" + player.lord.getLordId() + "," + player.lord.getNick() + "," + player.lord.getLevel());
            }
        }

        // LogUtil.error("1修复线上由于等级表未传，导致获取经验报错，导致每日任务领奖后不增加一个任务BUG，数据修正从<5改为5");
    }

    /**
     * 老玩家回归奖励buff
     */
    public void playerBackBuff(Player player, int state, int day, int subtime) {
        List<StaticBackBuff> list = staticBackDataMgr.getBuff(state, player);// 获取该回归等级的buff列表
        for (int i = 0; i < list.size(); i++) {
            StaticBackBuff staticBackBuff = list.get(i);
            int keep = TimeHelper.DAY_S * (staticBackBuff.getBuffTime() - 1 + staticBackBuff.getDay() - day) + subtime;// 计算buff的持续时间
            if (player.lord.getLevel() >= 30 && player.account.getBackState() != 0 && staticBackBuff != null
                    && !player.effects.containsKey(staticBackBuff.getBuffId()) && day >= staticBackBuff.getDay() && keep > 0) {// 如果玩家符合赋予buff的条件
                addEffect(player, staticBackBuff.getBuffId(), keep);// 添加buff
            }
        }
    }

    /**
     * 老玩家回归奖励领取状态
     */
    public void playerBackAwardStatus(Player player) {
        Date now = new Date();
        long endTime = player.account.getBackEndTime().getTime();
        int day = 10;
        if (endTime > now.getTime()) {// 计算当前是回归的第几天
            int time = (int) ((player.account.getBackEndTime().getTime() - now.getTime()) / 1000);
            while (time > TimeHelper.DAY_S) {// 距离第二个回归点的秒数
                time = time - TimeHelper.DAY_S;
                day -= 1;
            }
            Map<Integer, StaticBackOne> backMap = staticBackDataMgr.getBackOneList(player.account.getBackState());// 根据回归状态的等级获取回归奖励的列表
            if (backMap != null) {
                for (Map.Entry<Integer, StaticBackOne> entry : backMap.entrySet()) {
                    StaticBackOne staticBackOne = entry.getValue();
                    int keyId = staticBackOne.getKeyId();
                    Integer status = player.backAward.get(keyId);
                    if (status == null) {
                        player.backAward.put(keyId, -1);
                    } else {
                        if (status == -1) {
                            int backDay = staticBackOne.getDay();
                            if (day > backDay) {// 如果之前断签未登录将礼物状态修改为补签
                                player.backAward.put(keyId, 2);
                            } else if (day == backDay) {// 如果当天登陆了则将礼物状态修改为可领取
                                player.backAward.put(keyId, 0);
                            }
                        }
                    }
                }
            }
        }
    }

    public Account getAccountByKeyId(int keyId) {
        Account account = accountDao.selectAccountByKeyId(keyId);
        return account;
    }

    /**
     * 更新账号的lordid和登陆时间到数据库
     *
     * @param account void
     */
    public void updatePlatNo(Account account) {
        accountDao.updatePlatNo(account);
    }

    // 根据角色id获得账号
    public Account getAccountByLordId(long LordId) {
        Account account = accountDao.selectAccountByLordId(LordId);
        return account;
    }

    /**
     * 给所有玩家加一个指定有效时间的保护罩
     *
     * @param vaildSec
     */
    public void addAllPlayerFree(int vaildSec, boolean bMail) {
        Iterator<Player> iterator = getPlayers().values().iterator();
        Player player;
        Effect effect;
        int nowSec = TimeHelper.getCurrentSecond();
        int endTime = nowSec + vaildSec;
        while (iterator.hasNext()) {
            player = iterator.next();
            effect = player.effects.get(EffectType.ATTACK_FREE);
            if (effect != null) {
                int oldEndTime = effect.getEndTime();
                effect.setEndTime(Math.max(effect.getEndTime(), nowSec) + vaildSec);
                LogLordHelper.attackFreeBuff(AwardFrom.DO_SOME, player, 1, oldEndTime, effect.getEndTime(), 0);
            } else {
                effect = new Effect(EffectType.ATTACK_FREE, endTime);
                player.effects.put(EffectType.ATTACK_FREE, effect);
                LogLordHelper.attackFreeBuff(AwardFrom.DO_SOME, player, 1, 0, effect.getEndTime(), 0);
            }
            if (bMail) {
                // sendMail
                sendNormalMail(player, MailType.MOLD_ATTACK_FREE_MAINTAIN, nowSec, String.valueOf(vaildSec));
            }
        }
    }

    /**
     * 发觉醒将领头像邮件
     *
     * @param heroId
     * @param heroName
     * @param player   void
     */
    public void sendAwakenHeroIconMail(int heroId, String heroName, Player player) {
        // 发觉醒将领头像邮件
        int propId = 0;// 物品id
        int icon = 0;// 头像
        if (heroId >= 340 && heroId <= 345) { // 鲷哥头像
            propId = 458;
            icon = 32;
        } else if (heroId >= 346 && heroId <= 351) { // 幽影头像
            propId = 459;
            icon = 33;
        } else if (heroId >= 352 && heroId <= 357) { // 风行者头像
            propId = 460;
            icon = 34;
        } else if (heroId >= 370 && heroId <= 375) { // 安兴
            propId = 651;
            icon = 45;
        } else if (heroId >= 358 && heroId <= 363) { // 雷迪
            propId = 652;
            icon = 46;
        } else if (heroId >= 364 && heroId <= 369) { // 雷迪
            propId = 664;
            icon = 47;
        }

        // 是否已经拥有将领的头像
        boolean hasAwakenHeroProtrait = false;
        for (Portrait p : player.portraits) {
            if (p.getId() == icon) {
                hasAwakenHeroProtrait = true;
                break;
            }
        }
        // 如果拥有该觉醒将领头像则不发邮件
        if (!hasAwakenHeroProtrait) {
            Award.Builder award = Award.newBuilder();
            award.setType(AwardType.PROP);
            award.setId(propId);
            award.setCount(1L);
            List<Award> list = new ArrayList<>();
            list.add(award.build());
            // 通过"[觉]鲷哥+1"这样的全名获取"鲷哥"这样的觉醒将领名字
            String name = StringHelper.getAwakenHeroName(heroName);
            sendAttachMail(AwardFrom.HERO_AWAKEN_SKILL_LV, player, list, MailType.MOLD_AWAKEN_HERO_ICON, TimeHelper.getCurrentSecond(),
                    name);
        }
    }

    /**
     * 同步同一个军团内的所有玩家兄弟同心活动中升级buff消息
     *
     * @param lordId
     * @param buffId
     * @param nick
     */
    public void synUpActBrotherBuff(long lordId, int buffId, String nick) {
        Player target = getPlayer(lordId);
        if (target != null && target.isLogin) {
            SynBrotherRq.Builder builder = SynBrotherRq.newBuilder();
            builder.setId(buffId);
            builder.setNick(nick);
            Base.Builder msg = PbHelper.createSynBase(SynBrotherRq.EXT_FIELD_NUMBER, SynBrotherRq.ext, builder.build());
            GameServer.getInstance().synMsgToPlayer(target.ctx, msg);
        }
    }

    /**
     * 打完飞艇或者占领飞艇广播信息
     *
     * @param target
     * @param type   void
     */
    public void synUpActBrotherTask(Player target, int type) {
        if (target != null && target.isLogin) {
            SynAirShipFightTaskRq.Builder builder = SynAirShipFightTaskRq.newBuilder();
            builder.setTaskType(type);
            Base.Builder msg = PbHelper.createSynBase(SynAirShipFightTaskRq.EXT_FIELD_NUMBER, SynAirShipFightTaskRq.ext, builder.build());
            GameServer.getInstance().synMsgToPlayer(target.ctx, msg);
        }
    }

    /**
     * 加入购买铭牌、气泡列表
     *
     * @param player
     * @param skinId
     * @param count
     * @param
     * @param type   buyNameplate
     */
    public void addSkin(Player player, int skinId, int count, int type) {
        Map<Integer, Skin> map = player.getSkin(type);

        AwardFrom awardFrom;
        if (type == SkinType.NAMEPLATE) {
            awardFrom = AwardFrom.BUY_NAMEPLATE;
        } else if (type == SkinType.BUBBLE) {
            awardFrom = AwardFrom.BUY_BUBBLE;
        } else {
            return;
        }

        Skin skin = map.get(skinId);
        // 第一次购买
        if (skin == null) {
            skin = new Skin(skinId, 0);
            map.put(skinId, skin);
        }

        // 增加购买数量
        skin.setCount(skin.getCount() + count);

        LogLordHelper.skin(awardFrom, player.account, player.lord, skinId, skin.getCount(), count);
    }

    /**
     * Method: subHuangbao
     *
     * @param player
     * @param sub
     * @param from
     * @Description: 扣除赏金碎片
     */
    public void subBounty(Player player, int sub, AwardFrom from) {
        rewardService.subBounty(player, sub, from);
    }

    /**
     * 新活跃宝箱掉落
     *
     * @param player
     */
    public void activeBoxDrop(Player player) {
        StaticActiveBoxConfig activeBoxCfg = staticActiveBoxDataMgr.getActiveBoxCfg();

        if (player == null || player.ctx == null || !player.isLogin) {
            return;
        }

        if (activeBoxCfg.getOpenlevel() != 0 && player.lord.getLevel() < activeBoxCfg.getOpenlevel()) {
            return;
        }

        if (player.activeBoxSuc >= activeBoxCfg.getRefreshCap()) {
            return;
        }

        if (player.activeBox.size() >= activeBoxCfg.getRestoreCap()) {
            return;
        }

        int prob = activeBoxCfg.getProb();
        if (player.activeBoxFail >= activeBoxCfg.getMinCap()) {
            prob = 100;
        }

        if (RandomHelper.isHitRangeIn100(prob)) {

            int boxId = RandomHelper.randomInSize(100);
            player.activeBox.add(boxId);
            player.activeBoxFail = 0;
            player.activeBoxSuc++;

            SynActiveBoxDropRq.Builder builder = SynActiveBoxDropRq.newBuilder();
            builder.addAllBoxId(player.activeBox);
            BasePb.Base.Builder msg = PbHelper.createSynBase(SynActiveBoxDropRq.EXT_FIELD_NUMBER, SynActiveBoxDropRq.ext, builder.build());

            GameServer.getInstance().synMsgToPlayer(player.ctx, msg);

        } else {
            player.activeBoxFail++;
        }
    }

    public void clearActiveBox() {
        for (Player player : getRecThreeMonOnlPlayer().values()) {
            player.activeBoxSuc = 0;
        }
    }

    /**
     * 是否拥有唯一主键的奖励类型
     */
    public boolean isKeyIdAward(int type) {
        return type == AwardType.EQUIP || type == AwardType.PART || type == AwardType.HERO || type == AwardType.MEDAL
                || type == AwardType.AWARK_HERO || type == AwardType.LORD_EQUIP;
    }

    /**
     * 计算战损获得的荣耀积分
     *
     * @return
     */
    public int calcHonourScore(Map<Integer, RptTank> haust) {
        int score = 0;
        for (RptTank tank : haust.values()) {
            StaticTank staticTank = staticTankDataMgr.getStaticTank(tank.getTankId());
            score += Math.ceil((staticTank.getHonourLiveScore() * tank.getCount()));
        }
        return score;
    }

    /**
     * 设置登陆福利活动的状态
     *
     * @param player
     */
    public void loginWelfare(Player player) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_LOGIN_WELFARE);
        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_LOGIN_WELFARE);
        if (activityBase != null && activity != null) {
            try {
                List<Long> statusList = activity.getStatusList();
                if (statusList == null || statusList.size() == 0) {
                    LogUtil.error("登陆福利活动初始化statusList为空，可能是策划配置的奖励表奖励条数不对");
                    return;
                }

                Date parse = new SimpleDateFormat("yyyyMMdd").parse(activity.getBeginTime() + "");
                int today = TimeHelper.daysOfTwo(System.currentTimeMillis(), parse.getTime()) - 1;
                if (statusList.get(today) != 0) {
                    return;
                }
                if (today < statusList.size() - 1 && statusList.get(today) == 0) {
                    statusList.set(today, 1L);
                }
                boolean flag = true;
                for (int i = 0; i < statusList.size() - 1; i++) {
                    if (statusList.get(i) == 0) {
                        flag = false;
                    }
                }
                if (flag && statusList.get(statusList.size() - 1) == 0) {
                    statusList.set(statusList.size() - 1, 1L);
                }
            } catch (Exception e) {
                LogUtil.error("登陆福利活动设置登陆状态报错", e);
            }
        }
    }

    /**
     * 检查双方是否互为好友
     *
     * @param playerId 玩家ID
     * @param friendId 好友ID
     * @return
     */
    public boolean checkMutualFriend(Long playerId, long friendId) {
        Player player = getPlayer(playerId);
        Player fPlayer = getPlayer(friendId);

        if (player == null || fPlayer == null) {
            return false;
        }

        if (player.friends.containsKey(friendId) && fPlayer.friends.containsKey(playerId)) {
            return true;
        }

        return false;
    }

    /**
     * 获取玩家给指定好友当月赠送的次数
     *
     * @param player
     * @param friendId
     * @return
     */
    public int getCurMonthFriendCount(Player player, long friendId) {

        int curMonthFriendCount = 0;
        Map<Long, FriendGive> friendGiveMap = player.getGiveMap();
        if (friendGiveMap.isEmpty()) {
            return curMonthFriendCount;
        }

        FriendGive friendGive = friendGiveMap.get(friendId);
        if (friendGive == null) {
            return curMonthFriendCount;
        }

        if (TimeHelper.isSameMonth(friendGive.getGiveTime())) {
            curMonthFriendCount += friendGive.getCount();
        }
        return curMonthFriendCount;
    }

    /**
     * 同步友好度给玩家
     *
     * @param player 当前玩家
     * @param target 目标玩家
     */
    public void synFriendlinessToPlayer(Player player, Player target) {
        if (target != null && target.isLogin) {
            SynFriendlinessRq.Builder builder = SynFriendlinessRq.newBuilder();

            boolean mutualFriend = checkMutualFriend(target.roleId, player.roleId);
            //获取玩家在目标玩家好友列表中的好友信息
            Friend friend = target.friends.get(player.roleId);
            if (friend == null) {
                friend = new Friend(player.roleId, 0, 0);
                friend.setFriendliness(0);
            }
            int giveCount = getCurMonthFriendCount(target, player.roleId);
            String partyName = partyDataManager.getPartyNameByLordId(player.roleId);
            Man man = new Man();
            man.setLordId(player.roleId);
            man.setIcon(player.lord.getPortrait());
            man.setLevel(player.lord.getLevel());
            man.setNick(player.lord.getNick());
            man.setSex(player.lord.getSex());
            man.setPros(player.lord.getPros());
            man.setFight(player.lord.getFight());
            man.setProsMax(player.lord.getProsMax());
            man.setPartyName(partyName);

            builder.setFriend(PbHelper.createFriendPb(man, friend, mutualFriend, giveCount));
            Base.Builder msg = PbHelper.createSynBase(SynFriendlinessRq.EXT_FIELD_NUMBER, SynFriendlinessRq.ext, builder.build());
            GameServer.getInstance().synMsgToPlayer(target.ctx, msg);
        }
    }

    /**
     * 检查是否为好友
     *
     * @param player
     * @param friendId
     * @return
     */
    public boolean checkFriend(Player player, long friendId) {
        if (player.friends.containsKey(friendId)) {
            return true;
        }
        return false;
    }

    /**
     * 增加玩家获赠道具信息
     *
     * @param player
     * @param type    道具类型
     * @param propId  道具id
     * @param count   获赠数量
     * @param curTime 获赠时间
     */
    public void addGetGivePropList(Player player, int type, int propId, int count, long curTime) {
        boolean flag = false;
        for (GetGiveProp getGiveProp : player.getGetGivePropList()) {
            //判断玩家是否已经获赠该道具
            if (type == getGiveProp.getType() && propId == getGiveProp.getPropId()) {
                //判断获赠时间是否为当月
                if (TimeHelper.isSameMonth(getGiveProp.getLastGiveTime())) {
                    getGiveProp.setNum(count + getGiveProp.getNum());
                } else {
                    getGiveProp.setNum(count);
                }
                getGiveProp.setLastGiveTime(curTime);
                flag = true;
            }
        }

        if (!flag) {
            // flag 为false表示玩家还未获赠该道具，将该道具获赠信息添加到玩家获赠道具信息列表中
            player.getGetGivePropList().add(new GetGiveProp(type, propId, count, curTime));
        }
    }

    /**
     * 获取玩家当月获赠指定道具的数量
     *
     * @param player
     * @param type
     * @param propId
     * @return
     */
    public int getCurrentMonthGetPropCount(Player player, int type, int propId) {
        int curPropNum = 0;
        if (!CollectionUtils.isEmpty(player.getGetGivePropList())) {
            for (GetGiveProp getGiveProp : player.getGetGivePropList()) {
                if (type == getGiveProp.getType() && propId == getGiveProp.getPropId() && TimeHelper.isSameMonth(getGiveProp.getLastGiveTime())) {
                    return getGiveProp.getNum();
                }
            }
        }
        return curPropNum;
    }

    public boolean checkEnergyCodeCond(Player player, int type, int cond) {
        return rewardService.checkEnergyCoreCondition(player, type, cond);
    }


}
