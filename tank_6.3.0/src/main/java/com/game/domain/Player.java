package com.game.domain;

import com.alibaba.fastjson.JSON;
import com.game.constant.ArmyState;
import com.game.constant.AwardFrom;
import com.game.constant.Constant;
import com.game.domain.p.*;
import com.game.domain.p.Activity;
import com.game.domain.p.Army;
import com.game.domain.p.AwakenHero;
import com.game.domain.p.Award;
import com.game.domain.p.Bless;
import com.game.domain.p.BuildQue;
import com.game.domain.p.Cash;
import com.game.domain.p.Chip;
import com.game.domain.p.Combat;
import com.game.domain.p.Day7Act;
import com.game.domain.p.DialDailyGoalInfo;
import com.game.domain.p.Effect;
import com.game.domain.p.EnergyStoneInlay;
import com.game.domain.p.Equip;
import com.game.domain.p.FailNum;
import com.game.domain.p.FestivalInfo;
import com.game.domain.p.Form;
import com.game.domain.p.Friend;
import com.game.domain.p.Hero;
import com.game.domain.p.KingRankRewardInfo;
import com.game.domain.p.LeqScheme;
import com.game.domain.p.LotteryEquip;
import com.game.domain.p.LuckyInfo;
import com.game.domain.p.Mail;
import com.game.domain.p.Medal;
import com.game.domain.p.MedalChip;
import com.game.domain.p.MilitaryMaterial;
import com.game.domain.p.MilitaryScience;
import com.game.domain.p.MilitaryScienceGrid;
import com.game.domain.p.Mill;
import com.game.domain.p.Part;
import com.game.domain.p.Pendant;
import com.game.domain.p.Portrait;
import com.game.domain.p.Prop;
import com.game.domain.p.PropQue;
import com.game.domain.p.PushComment;
import com.game.domain.p.QuinnPanel;
import com.game.domain.p.RedPlanInfo;
import com.game.domain.p.RefitQue;
import com.game.domain.p.Ruins;
import com.game.domain.p.Science;
import com.game.domain.p.ScienceQue;
import com.game.domain.p.SecretWeapon;
import com.game.domain.p.Shop;
import com.game.domain.p.ShopBuy;
import com.game.domain.p.Store;
import com.game.domain.p.Tactics;
import com.game.domain.p.TacticsInfo;
import com.game.domain.p.Tank;
import com.game.domain.p.TankQue;
import com.game.domain.p.Task;
import com.game.domain.p.TeamInstanceInfo;
import com.game.domain.p.TreasureShopBuy;
import com.game.domain.p.WarActivityInfo;
import com.game.domain.p.WipeInfo;
import com.game.domain.p.friend.FriendGive;
import com.game.domain.p.friend.Friendliness;
import com.game.domain.p.friend.GetGiveProp;
import com.game.domain.p.lordequip.LordEquipInfo;
import com.game.drill.domain.DrillFightData;
import com.game.drill.domain.DrillShopBuy;
import com.game.honour.domain.HonourRoleScore;
import com.game.pb.CommonPb;
import com.game.pb.CommonPb.*;
import com.game.pb.SerializePb.SerData;
import com.game.pb.SerializePb.SerData.Builder;
import com.game.pb.SerializePb.SerMail;
import com.game.rebel.domain.RoleRebelData;
import com.game.util.*;
import com.google.protobuf.InvalidProtocolBufferException;
import com.hundredcent.game.aop.annotation.SaveOptimize;
import com.hundredcent.game.aop.domain.IPlayerSave;
import com.hundredcent.game.aop.persistence.player.SavePlayerOptimizeUtil;
import io.netty.channel.ChannelHandlerContext;

import java.text.SimpleDateFormat;
import java.util.*;
import java.util.Map.Entry;

/**
 * @author ZhangJun
 * @ClassName: Player
 * @Description:
 * @date 2015年8月4日 下午4:25:43
 */
@SaveOptimize
public class Player implements IPlayerSave, Cloneable {

    @Override
    public Object clone() throws CloneNotSupportedException {
        return super.clone();
    }

    // 角色基础数据
    public Lord lord;

    // 角色账号
    public Account account;

    // 角色坦克列表
    public Map<Integer, Tank> tanks = new HashMap<>();

    // 角色资源数据
    public Resource resource;

    // 角色基地建筑数据
    public Building building;

    // 阵型数据 [1]阵型模板 [2]防守阵型
    public Map<Integer, Form> forms = new HashMap<>();

    // 建筑队列
    public LinkedList<BuildQue> buildQue = new LinkedList<>();

    // 出征部队
    public LinkedList<Army> armys = new LinkedList<>();

    // 失败的次数 [1]操作keyId [2]失败
    public Map<Integer, FailNum> failNums = new HashMap<>();

    // 废墟信息
    public Ruins ruins = new Ruins();

    // 推送评论界面
    public PushComment pushComment = new PushComment();

    // 坦克生产队列
    public LinkedList<TankQue> tankQue_1 = new LinkedList<>();

    // 坦克生产队列
    public LinkedList<TankQue> tankQue_2 = new LinkedList<>();

    // 道具数据
    public Map<Integer, Prop> props = new HashMap<>();

    // 制造车间生产队列
    public LinkedList<PropQue> propQue = new LinkedList<>();

    // 改装队列
    public LinkedList<RefitQue> refitQue = new LinkedList<>();

    // 角色装备数据(此装备为坦克阵形上的装备) <pos,<equipId, equip>>
    public Map<Integer, Map<Integer, Equip>> equips = new HashMap<>();

    // 配件数据
    public Map<Integer, Map<Integer, Part>> parts = new HashMap<>();

    // 碎片数据
    public Map<Integer, Chip> chips = new HashMap<>();

    public Map<Integer, Integer> skills = new HashMap<>();

    // 科技馆数据
    public Map<Integer, Science> sciences = new HashMap<>();

    // 科技生产队列
    public LinkedList<ScienceQue> scienceQue = new LinkedList<>();

    // 普通副本
    public Map<Integer, Combat> combats = new HashMap<>();

    // 探险副本（装备、配件、限时）
    public Map<Integer, Combat> explores = new HashMap<>();

    // 章节(宝箱领取状态)
    public Map<Integer, Integer> sections = new HashMap<>();

    // 城外工厂
    public Map<Integer, Mill> mills = new HashMap<>();

    // 加成效果
    public Map<Integer, Effect> effects = new HashMap<>();

    public Map<Integer, Effect> getEffects() {
        return effects;
    }

    public List<Integer> signs = new ArrayList<>();

    // 每月签到
    public MonthSign monthSign = new MonthSign();

    // 军工材料
    public Map<Integer, MilitaryMaterial> militaryMaterials = new HashMap<>();

    // 军工科技 (科技id,科技信息)
    public Map<Integer, MilitaryScience> militarySciences = new HashMap<>();

    // 军工科技格子状态(tankId,pos,状态)
    public Map<Integer, Map<Integer, MilitaryScienceGrid>> militaryScienceGrids = new HashMap<>();

    // 跨服战积分
    public int crossJiFen;

    // 普通副本进度
    public int combatId;

    // 装备副本进度
    public int equipEplrId;

    // 配件副本进度
    public int partEplrId;

    // 军工副本进度
    public int militaryEplrId;

    // 极限副本进度
    public int extrEplrId = 300;

    // 极限历史最高层数
    public int extrMark;

    // 扫荡极限副本开始时间
    public int wipeTime;

    // 限时副本进度
    public int timePrlrId;

    // 签到登录奖励
    public int signLogin;

    // 军事矿区时间(刷新掠夺次数，购买次数)
    public int seniorDay;

    // // 参加军事矿区时间(刷新积分)
    // public int seniorWeek;

    // 军事矿区次数
    public int seniorCount;

    // 军事矿区积分
    public int seniorScore;

    // 军事矿区军团积分奖励是否领取了 0.无资格 1.有资格 2.已领取
    public int seniorAward;

    // 军事矿区掠夺购买次数
    public int seniorBuy;

    // // 配件淬炼上次重置日期
    // public int smeltDay;

    // // 配件今日淬炼次数
    // public int smeltTimes;

    // 勋章副本进度
    public int medalEplrId;

    // 将领集合
    public Map<Integer, Hero> heros = new HashMap<>();
    //过期时间
    public Map<Integer, Long> herosExpiredTime = new HashMap<>();
    public Map<Integer, Long> herosCdTime = new HashMap<>();

    // 已锁将领集合
    public Set<Integer> lockHeros = new HashSet<>();

    // 将领觉醒集合
    public Map<Integer, AwakenHero> awakenHeros = new HashMap<>();

    // 好友列表
    public Map<Long, Friend> friends = new HashMap<>();

    // 祝福列表
    public Map<Long, Bless> blesses = new HashMap<>();

    // 收藏坐标
    public LinkedList<Store> coords = new LinkedList<>();

    // 邮件列表
    public Map<Integer, Mail> mails = new HashMap<>();

    // 新邮件
    private List<Mail> newMails = new LinkedList<>();

    // 更新的邮件<keyId, state>;如果在写入数据库之前有多次更新，则只保存最后一次更新，因此用map保存
    private Map<Integer, Integer> updMails = new HashMap<>();
    private Map<Integer, Integer> updMailsCollections = new HashMap<>();

    // 删除邮件
    private List<Mail> delMails = new LinkedList<>();

    // 抽装备信息
    public Map<Integer, LotteryEquip> lotteryEquips = new HashMap<>();

    // 主线,日常,活跃任务
    public Map<Integer, Task> majorTasks = new HashMap<>();
    public List<Task> dayiyTask = new ArrayList<>();
    public Map<Integer, Task> liveTask = new HashMap<>();
    public Map<Integer, Integer> liveTaskAward = new HashMap<>();

    // 回归信息
    public Map<Integer, Integer> backAward = new TreeMap<>();

    // 任务信息
    public Map<Integer, Activity> activitys = new HashMap<>();

    // 兑换(装备,配件)
    public Map<Integer, Cash> cashs = new HashMap<>();

    // 挂件
    public List<Pendant> pendants = new ArrayList<>();

    // 肖像
    public List<Portrait> portraits = new ArrayList<>();

    // 能晶副本进度
    public int energyStoneEplrId;

    // 能晶仓库
    public Map<Integer, Prop> energyStone = new HashMap<>();

    // 能晶镶嵌信息
    public Map<Integer, Map<Integer, EnergyStoneInlay>> energyInlay = new HashMap<>();

    /**
     * * 宝物商店购买次数记录
     */
    public Map<Integer, TreasureShopBuy> treasureShopBuy = new HashMap<>();

    // 军事演习（红蓝大战）中玩家拥有的坦克
    public Map<Integer, Tank> drillTanks = new HashMap<>();

    // 玩家关于红蓝大战的战斗信息
    public DrillFightData drillFightData;

    // 红蓝大战军演商店购买记录
    public Map<Integer, DrillShopBuy> drillShopBuy = new HashMap<>();

    // 军事演习（红蓝大战）中玩家击毁的坦克和数量
    public Map<Integer, Integer> drillKillTank = new HashMap<>();

    // 勋章数据
    public Map<Integer, Map<Integer, Medal>> medals = new HashMap<>();

    // 勋章碎片数据
    public Map<Integer, MedalChip> medalChips = new HashMap<>();

    // 勋章展示数据
    public Map<Integer, Map<Integer, MedalBouns>> medalBounss = new HashMap<>();

    // 10以后的配件材料--以后加材料就不用改代码
    public Map<Integer, Integer> partMatrial = new TreeMap<>();

    // 7日活动
    public Day7Act day7Act = new Day7Act();

    // 叛军入侵玩家数据
    public RoleRebelData rebelData;

    private int maxKey;

    // 发布军团招募消息的时间
    public int recruitTime = 0;

    // 上次发送聊天时间
    public int chatTime = 0;

    // 玩家商店信息
    public Map<Integer, Shop> shopMap = new HashMap<>();

    // 玩家军备信息
    public LordEquipInfo leqInfo = new LordEquipInfo();

    // 广告
    public Advertisement advertisement;

    // 皮肤
    public Map<Integer, Effect> surfaceSkins = new HashMap<>();

    // 超时空财团商品面板
    public Map<Integer, QuinnPanel> quinnPanels = new HashMap<>();

    // 除外观以外的皮肤map.键为皮肤类型 (2 铭牌 3 聊天气泡);值的键为skinId
    private Map<Integer, Map<Integer, Skin>> skinMap = new HashMap<>();

    // 除外观以外的正在使用的皮肤.键为皮肤类型 (2 铭牌 3 聊天气泡);值的键为skinId
    private Map<Integer, Map<Integer, Effect>> usedSkinMap = new HashMap<>();

    // 当前使用皮肤<皮肤类型（2 铭牌 3 气泡）, 当前皮肤id>
    public Map<Integer, Integer> currentSkin = new HashMap<>();

    // 秘密武器信息
    public TreeMap<Integer, SecretWeapon> secretWeaponMap = new TreeMap<>();

    // 攻击特效
    public Map<Integer, AttackEffect> atkEffects = new HashMap<>();

    // 作战研究研究
    public LabInfo labInfo = new LabInfo();

    // 红色方案
    public RedPlanInfo redPlanInfo = new RedPlanInfo();

    // 玩家外挂行为监控
    public PlugInCheck plugInCheck = new PlugInCheck();

    // 点击宝箱获得奖励次数
    public int giftRewardCount = 0;
    // 点击宝箱获得奖励领取时间
    public int giftRewardTime = 0;

    // 新手引导奖励
    private List<Integer> guideRewardInfo = new ArrayList<>();

    // 假日碎片活动
    private FestivalInfo festivalInfo = new FestivalInfo();
    // 幸运奖池
    private LuckyInfo luckyInfo = new LuckyInfo();
    // 组队副本信息
    private TeamInstanceInfo teamInstanceInfo = new TeamInstanceInfo();

    // 叛军礼盒领取次数
    public List<Integer> rebelBoxCount = new LinkedList<>();
    // 叛军礼盒领取时间
    public int rebelBoxTime = 0;
    // 叛军红包领取次数
    public List<Integer> rebelRedBagCount = new LinkedList<>();
    // 叛军红包领取时间
    public int rebelRedBagTime = 0;
    // 叛军活动周结算时玩家最后所在军团id
    public int rebelEndPartyId;
    // 幸运转盘每日活动信息
    public DialDailyGoalInfo fortuneDialDayInfo = new DialDailyGoalInfo();
    // 能晶转盘每日活动信息
    public DialDailyGoalInfo energyDialDayInfo = new DialDailyGoalInfo();
    // 装备转盘每日活动信息
    public DialDailyGoalInfo equipDialDayInfo = new DialDailyGoalInfo();
    //战术转盘每日活动信息
    public DialDailyGoalInfo ticDialDayInfo = new DialDailyGoalInfo();
    // 新首冲是否是第一次
    public String newPayVersion = "";

    public List<Integer> newPayInfo = new LinkedList<>();

    // 新首冲是否是第一次
    public String new2PayVersion = "";
    public List<Integer> new2PayInfo = new LinkedList<>();

    // id count每周每日礼包领取次数
    public Map<Integer, Integer> dayBoxinfo = new HashMap<>();

    // 每周每日礼包领取次数 领取时间
    public long dayBoxTime;

    // 荣耀玩法玩家积分
    public HonourRoleScore honourScore;
    // 荣耀玩法是否已通知玩家标记
    public boolean honourNotify = false;
    // 荣耀玩法玩家一次玩法期间掠夺金币数量
    private int honourGrabGold;
    // 荣耀玩法结束时所在军团id
    private int honourPartyId;
    // 荣耀玩法积分金币奖励领取状态，0不可领，1可领，2已领
    private int honourScoreGoldStatus;


    // 活跃宝箱刷新失败次数
    public int activeBoxFail;
    // 活跃宝箱每日成功刷新次数
    public int activeBoxSuc;
    // 活跃宝箱
    public List<Integer> activeBox = new LinkedList<>();

    public long scoutFreeTime;// 侦查cd时间
    public int scoutFreeTimeCount;// 侦查失败次数
    public int scoutRewardCount;// 侦查成功领取奖励次数
    public long scoutRewardTime;// 侦查成功领取奖励时间
    public int scoutBanCount;// 侦查禁止次数
    public int isVerificationState;
    public int isVerification;// 验证码是否验证成功
    public int scoutRefreshCount;// 验证码刷新次数

    public int newHeroAddGold; // 新英雄掠夺的金币数量总和
    public long newHeroAddGoldTime;// 新英雄掠夺的金币时间

    // 军备方案 key: 方案type
    public Map<Integer, LeqScheme> leqScheme = new HashMap<>();
    // 扫矿验证正确图片,key:时间戳，value:图片keyId，不存库，只允许包含一个元素
    private Map<Integer, List<Integer>> scoutImg = new HashMap<>();

    public int newHeroAddCount;//破罩将领每天重置次数
    public Map<Integer, Integer> heroClearCdCount = new HashMap<>();//破罩将领每天重置次数
    public long newHeroAddClearCdTime;//破罩将领每天重置时间

    // 最后世界发言
    public LinkedList<String> lastChats = new LinkedList<>();

    //玩家贡献的世界编制经验
    public long contributionWorldStaffing;

    public int VCODE_SCOUT_COUNT = 0;


    //工会活动
    public WarActivityInfo warActivityInfo = new WarActivityInfo();


    //祭坛Boss捐献的类型和次数
    private Map<Integer, Integer> contributeCount = new HashMap<Integer, Integer>();

    /**
     * 战术大师
     */
    public TacticsInfo tacticsInfo = new TacticsInfo();


    /**
     * 服务端存储 最强王者 奖励领取信息
     */
    public KingRankRewardInfo kingRankRewardInfo = new KingRankRewardInfo();

    /**
     * 扫荡信息
     */
    public Map<Integer, WipeInfo> wipeInfo = new HashMap<>();

    /**
     * 好友赠送：key:好友ID
     */
    private Map<Long, FriendGive> giveMap = new HashMap<>();

    /**
     * 好友赠送给我的道具列表
     */
    private List<GetGiveProp> getGivePropList = new ArrayList<>();

    private Map<Long, Friendliness> blessFriendlinesses = new HashMap<>();

    /**
     * 能源核心信息
     */
    public PEnergyCore energyCore = new PEnergyCore();

    /**
     * 跨服军矿积分
     */
    private int crossMineScore;

    /**
     * 1.未领取 2.已领取
     */
    private int crossMineGet;

    /**
     * 巅峰等级树解锁 key :skillid value:1.未激活 2.已激活
     */
    private Map<Integer, Integer> peakMap = new HashMap<>();


    public int maxKey() {
        return ++maxKey;
    }

    public int getMaxKey() {
        return maxKey;
    }

    public void setMaxKey(int maxKey) {
        this.maxKey = maxKey;
    }

    {
        equips.put(0, new HashMap<Integer, Equip>());
        equips.put(1, new HashMap<Integer, Equip>());
        equips.put(2, new HashMap<Integer, Equip>());
        equips.put(3, new HashMap<Integer, Equip>());
        equips.put(4, new HashMap<Integer, Equip>());
        equips.put(5, new HashMap<Integer, Equip>());
        equips.put(6, new HashMap<Integer, Equip>());

        parts.put(0, new HashMap<Integer, Part>());
        parts.put(1, new HashMap<Integer, Part>());
        parts.put(2, new HashMap<Integer, Part>());
        parts.put(3, new HashMap<Integer, Part>());
        parts.put(4, new HashMap<Integer, Part>());

        medals.put(0, new HashMap<Integer, Medal>());
        medals.put(1, new HashMap<Integer, Medal>());

        medalBounss.put(0, new HashMap<Integer, MedalBouns>());
        medalBounss.put(1, new HashMap<Integer, MedalBouns>());

    }

    // ///////////////////////////////////////////////////////////////////////////////////////////
    // 角色id，一个物理区上唯一
    public Long roleId;

    public int surface;

    public int lastSaveTime;

    public boolean isLogin = false;

    public boolean immediateSave = false;

    // public boolean connected = false;

    public ChannelHandlerContext ctx;

    public SaveFlag saveFlag = new SaveFlag();

    public Player(long lordId) {
        this.roleId = lordId;
        lastSaveTime = TimeHelper.getCurrentSecond() + 180 + (int) (roleId % 300);
    }

    public Player(Lord lord, int nowTime) {
        this.roleId = lord.getLordId();
        this.lord = lord;
        lastSaveTime = nowTime + 180 + (int) (roleId % 300);
//        SimpleDateFormat dateFormat1 = new SimpleDateFormat(DateHelper.format1);
//        LogUtil.error("初始化下次保存时间 roleId={},roleName={}, {}",roleId,lord.getNick(),dateFormat1.format(new Date(lastSaveTime*1000L)) );
    }

    public void setLogin(boolean isLogin) {
        this.isLogin = isLogin;
    }

    public void logOut() {
        isLogin = false;
        ctx = null;
        immediateSave = true;
        int now = TimeHelper.getCurrentSecond();
        lord.setOffTime(now);
        lord.setOlTime(onLineTime());
        LogHelper.logOltime(lord);
    }

    public void tickOut() {
        if (isLogin) {
            int now = TimeHelper.getCurrentSecond();
            lord.setOffTime(now);
            lord.setOlTime(onLineTime());
        }

        isLogin = false;
        ctx = null;
        immediateSave = true;
    }

    public void logIn() {
        int now = TimeHelper.getCurrentSecond();
        int nowDay = TimeHelper.getCurrentDay();

        int lastDay = TimeHelper.getDay(lord.getOnTime());
        if (nowDay != lastDay) {
            // 重置每月登录天数
            int monthAndDay = TimeHelper.getMonthAndDay(new Date());
            if ((lord.getOlMonth() / 10000) != monthAndDay / 10000) {// 月份不一样
                lord.setOlMonth(monthAndDay + 1);
            } else {// 月份一样
                if (lord.getOlMonth() / 100 != monthAndDay / 100) {
                    lord.setOlMonth(monthAndDay + lord.getOlMonth() % 100 + 1);
                }
            }

            int ctTime = lord.getCtTime();
            if (TimeHelper.getDay(ctTime) != TimeHelper.getDay(now)) {
                lord.setCtTime(now);
                lord.setOlAward(0);
            }

            // 重置前一次的登录时长
            int offTime = TimeHelper.getDay(lord.getOffTime());
            if (offTime != nowDay) {
                lord.setOlTime(0);
                //lord.setOffTime(nowDay);
            }
        }

        lord.setOnTime(now);
    }

    /**
     * 在线时长
     *
     * @return
     */
    public int onLineTime() {
        int now = TimeHelper.getCurrentSecond();
        int nowDay = TimeHelper.getCurrentDay();

        int lastDay = TimeHelper.getDay(lord.getOnTime());
        if (nowDay != lastDay) {// 登录时间不为当天,则取0点到当前时间
            int noTime = TimeHelper.getTodayZone(now);
            int ctDay = TimeHelper.getDay(lord.getCtTime());
            if (ctDay != nowDay) {
                lord.setCtTime(noTime);
                lord.setOlAward(0);
            }
            return now - noTime;
        } else {// 登录时间为当天,则取累积时长
            int onlineTime = lord.getOlTime() + now - lord.getOnTime();
            onlineTime = onlineTime > 86400 ? 86400 : onlineTime;
            return onlineTime;
        }
    }


    @Override
    public boolean isActive() {
        // account == null 说明lord存在，但account不存在其不在smallid表中。
        // 出现这种情况是因为手动关联了lord产生的多余数据没有处理将其加入到smallId中即可
        return account != null && account.getCreated() == 1 && lord.getLevel() >= 2;
    }

    public int getSignLogin() {
        return signLogin;
    }

    public void setSignLogin(int signLogin) {
        this.signLogin = signLogin;
    }

    private void dserMail(byte[] data) throws InvalidProtocolBufferException {
        if (data == null) {
            return;
        }
        SerMail serMail = SerMail.parseFrom(data);
        List<CommonPb.Mail> list = serMail.getMailList();
        for (CommonPb.Mail e : list) {
            Mail mail = new Mail();
            mail.setKeyId(e.getKeyId());

            if (e.hasTitle()) {
                mail.setTitle(e.getTitle());
            }

            if (e.hasContont()) {
                mail.setContont(e.getContont());
            }

            if (e.hasSendName()) {
                mail.setSendName(e.getSendName());
            }

            if (e.hasMoldId()) {
                mail.setMoldId(e.getMoldId());
            }

            mail.setState(e.getState());
            mail.setTime(e.getTime());
            mail.setType(e.getType());
            mail.setToName(e.getToNameList());
            mail.setAward(e.getAwardList());

            List<String> paramList = e.getParamList();
            if (paramList != null && paramList.size() > 0) {
                String[] param = new String[paramList.size()];
                for (int i = 0; i < param.length; i++) {
                    param[i] = paramList.get(i);
                }
                mail.setParam(param);
            }

            if (e.hasReport()) {
                mail.setReport(e.getReport());
            }

            // mails.put(mail.getKeyId(), mail);
            this.addNewMail(mail);
        }
    }

    // private byte[] serMail() {
    // SerMail.Builder ser = SerMail.newBuilder();
    // Iterator<Mail> it = mails.values().iterator();
    // while (it.hasNext()) {
    // ser.addMail(PbHelper.createMailPb(it.next()));
    // }
    // return ser.build().toByteArray();
    // }

    private byte[] serRoleData() {
        SerData.Builder ser = SerData.newBuilder();
        serProp(ser);
        serTank(ser);
        serForm(ser);
        serEquip(ser);
        serPart(ser);
        serChip(ser);
        serSkill(ser);
        serCombat(ser);
        serExplore(ser);
        serSection(ser);
        serMill(ser);
        serScience(ser);
        serHero(ser);
        serFriend(ser);
        serBless(ser);
        serLotteryEquip(ser);
        serTankQue(ser);
        serPropQue(ser);
        serRefitQue(ser);
        serBuildQue(ser);
        serScienceQue(ser);
        serArmy(ser);
        serFailNum(ser);
        serRuins(ser);
        serEffect(ser);
        serSkin(ser);
        serSign(ser);
        serMajorTask(ser);
        serDayiyTask(ser);
        serLiveTask(ser);
        serLiveTaskAward(ser);
        serBackAward(ser);
        serActivity(ser);
        serQuinnPanel(ser);
        serCash(ser);
        serPendant(ser);
        serMilitarySciences(ser);
        serMilitaryScienceGrid(ser);
        serMilitaryMaterials(ser);
        serEnergyStone(ser);
        serEnergyStoneInlay(ser);
        serTreasureShopBuy(ser);
        serPushCommnet(ser);
        serDrillTank(ser);
        serDrillFightData(ser);
        serDrillShopBuy(ser);
        serDrillKillTank(ser);
        serRebelData(ser);
        serPortrait(ser);
        serCrossJiFen(ser);
        serMedal(ser);
        serMedalChip(ser);
        serMedalBouns(ser);
        serPartMatrial(ser);
        serLockHero(ser);
        serDay7Act(ser);
        serAwakenHero(ser);
        serShop(ser);
        serMonthSign(ser);
        serLabInfo(ser);
        serGuideInfo(ser);
        serFestivalInfo(ser);
        serLuckyInfo(ser);
        serTeamInstanceInfo(ser);
        serRedPlanInfo(ser);
        serGiftCount(ser);
        serNewPayVersion(ser);
        serGiftTime(ser);
        serRebelBoxTime(ser);
        serRebelBoxCount(ser);
        serRebelRedBagCount(ser);
        serRebelRedBagTime(ser);
        serFortuneDialDayInfo(ser);
        serEnergyDialDayInfo(ser);
        serEquipDialDayInfo(ser);
        serDayBoxInfo(ser);
        serActiveBoxFail(ser);
        serActiveBoxSuc(ser);
        serActiveBox(ser);
        serHonourNotify(ser);
        serHonourGrabGold(ser);
        serHonourRoleScore(ser);
        serHonourPartyId(ser);
        serLeqScheme(ser);
        serHonourScoreGoldStatus(ser);
        serRebelEndPartyId(ser);
        serWarActivityInfo(ser);
        sercontributeCount(ser);
        serTacticsInfo(ser);
        serKingRankRewardInfo(ser);
        serWipeInfo(ser);
        serFriendGive(ser);
        serGetGiveProp(ser);
        serBlessFriendlinesses(ser);
        SerPbHelper.serLordEquipInfo(this, ser);
        SerPbHelper.serSecretWeapon(ser, secretWeaponMap);
        SerPbHelper.serAttackEffect(this, ser);
        serEnergyCore(ser);
        serTicDialDayInfo(ser);
        return ser.build().toByteArray();
    }

    private void serShop(SerData.Builder ser) {
        for (Entry<Integer, Shop> entry : shopMap.entrySet()) {
            Shop shop = entry.getValue();
            ser.addShop(PbHelper.createShopPb(shop));
        }
    }

    private void serAwakenHero(SerData.Builder ser) {
        Iterator<AwakenHero> it = awakenHeros.values().iterator();
        while (it.hasNext()) {
            ser.addAwakenHeros(PbHelper.createAwakenHeroPb(it.next()));
        }
    }

    private void serDay7Act(Builder ser) {
        ser.setDbDay7Act(PbHelper.createDbDay7ActPb(day7Act));
    }

    private void serLockHero(Builder ser) {
        Iterator<Integer> it = lockHeros.iterator();
        while (it.hasNext()) {
            ser.addLockHero(it.next());
        }
    }

    private void serPartMatrial(Builder ser) {
        Iterator<Entry<Integer, Integer>> it = partMatrial.entrySet().iterator();
        while (it.hasNext()) {
            Entry<Integer, Integer> entry = it.next();
            ser.addPartMatrial(PbHelper.createTwoIntPb(entry.getKey(), entry.getValue()));
        }
    }

    private void serRebelData(Builder ser) {
        if (null != rebelData) {
            ser.setRebelData(PbHelper.createRoleRebelDataPb(rebelData));
        }
    }

    private void serDrillKillTank(Builder ser) {
        for (Entry<Integer, Integer> entry : drillKillTank.entrySet()) {
            ser.addDrillKillTank(PbHelper.createTwoIntPb(entry.getKey(), entry.getValue()));
        }
    }

    private void serDrillShopBuy(Builder ser) {
        for (DrillShopBuy buy : drillShopBuy.values()) {
            ser.addDrillShopBuy(PbHelper.createDrillShopBuyPb(buy, buy.getRestNum()));
        }
    }

    private void serDrillFightData(Builder ser) {
        if (null != drillFightData) {
            ser.setDrillFightData(PbHelper.createDrillFightDataPb(drillFightData));
        }
    }

    private void serDrillTank(SerData.Builder ser) {
        Iterator<Tank> it = drillTanks.values().iterator();
        while (it.hasNext()) {
            ser.addDrillTanks(PbHelper.createTankPb(it.next()));
        }
    }

    private void serPushCommnet(Builder ser) {
        ser.setPushComment(PbHelper.createPushComment(pushComment));
    }

    /**
     * 宝物商店购买记录
     *
     * @param ser
     */
    private void serTreasureShopBuy(Builder ser) {
        for (TreasureShopBuy buy : treasureShopBuy.values()) {
            ser.addTreasureShopBuy(PbHelper.createTreasureShopBuyPb(buy));
        }
    }

    /**
     * 能晶镶嵌信息处理
     *
     * @param ser
     */
    private void serEnergyStoneInlay(Builder ser) {
        for (Map<Integer, EnergyStoneInlay> map : energyInlay.values()) {
            if (!CheckNull.isEmpty(map)) {
                for (EnergyStoneInlay inlay : map.values()) {
                    ser.addEnergyInlay(PbHelper.createEnergyStoneInlayPb(inlay));
                }
            }
        }
    }

    /**
     * 能晶仓库信息处理
     *
     * @param ser
     */
    private void serEnergyStone(Builder ser) {
        for (Prop stone : energyStone.values()) {
            ser.addEnergyStone(PbHelper.createPropPb(stone));
        }
    }

    private void serCrossJiFen(Builder ser) {
        ser.setCrossJiFen(crossJiFen);
    }

    /**
     * Method: serMilitaryMaterials @param ser @return void @throws
     */
    private void serMilitaryMaterials(Builder ser) {
        Iterator<MilitaryMaterial> it = militaryMaterials.values().iterator();
        while (it.hasNext()) {
            ser.addMilitaryMaterial(PbHelper.createMilitaryMaterialPb(it.next()));
        }
    }

    /**
     * Method: serMilitaryScienceGrid @Description: 军工科技格子状态 @param ser @return void @throws
     */
    private void serMilitaryScienceGrid(Builder ser) {
        Collection<Map<Integer, MilitaryScienceGrid>> c = militaryScienceGrids.values();
        for (Map<Integer, MilitaryScienceGrid> hashMap : c) {
            try {
                if (hashMap != null) {
                    for (MilitaryScienceGrid grid : hashMap.values()) {
                        // ser.addMilitaryScienceGrid(PbHelper.createMilitaryScieneceGridPb(grid));

                        if (grid != null) {
                            ser.addMilitaryScienceGrid(PbHelper.createMilitaryScieneceGridPb(grid));
                        } else {
                            LogUtil.error(String.format("lord id: %d", lord.getLordId()));
                        }
                    }
                } else {
                    LogUtil.error(String.format("lord id: %d, hashMap is null", lord.getLordId()));
                }
            } catch (Throwable e) {
                LogUtil.error(String.format("lord id: %d, hashMap :%s", lord.getLordId(), hashMap), e);
                e.printStackTrace();
            }
        }

    }

    /**
     * Method: serMilitarySciences @Description: 军工科技信息 @param ser @return void @throws
     */
    private void serMilitarySciences(Builder ser) {
        Iterator<MilitaryScience> it = militarySciences.values().iterator();
        while (it.hasNext()) {
            MilitaryScience next = it.next();
            ser.addMilitaryScience(PbHelper.createMilitaryScienecePb(next));
        }
    }

    private void serMedal(Builder ser) {
        for (Map<Integer, Medal> map : medals.values()) {
            for (Medal medal : map.values()) {
                ser.addMedal(PbHelper.createMedalPb(medal));
            }
        }
    }

    private void serMedalBouns(Builder ser) {
        for (Map<Integer, MedalBouns> map : medalBounss.values()) {
            for (MedalBouns medalBouns : map.values()) {
                ser.addMedalBouns(PbHelper.createMedalBounsPb(medalBouns));
            }
        }
    }

    private void serMedalChip(SerData.Builder ser) {
        Iterator<MedalChip> it = medalChips.values().iterator();
        while (it.hasNext()) {
            ser.addMedalChip(PbHelper.createMedalChipPb(it.next()));
        }
    }

    private void dserRoleData(SerData ser) {
        dserChip(ser);
        dserSkill(ser);
        dserEquip(ser);
        dserPart(ser);
        dserProp(ser);
        dserForm(ser);
        dserTank(ser);
        dserScience(ser);
        dserActivity(ser);
        dserQuinnPanel(ser);
        dserCombat(ser);
        dserExplore(ser);
        dserSection(ser);
        dserMill(ser);
        dserEffect(ser);
        dserSkin(ser);
        dserHero(ser);
        dserFriend(ser);
        dserBless(ser);
        dserSign(ser);
        dserMajorTask(ser);
        dserDayiyTask(ser);
        dserLiveTask(ser);
        dserLiveTaskAward(ser);
        dserBackAward(ser);
        dserLotteryEquip(ser);
        dserTankQue(ser);
        dserRefitQue(ser);
        dserPropQue(ser);
        dserBuildQue(ser);
        dserScienceQue(ser);
        dserArmy(ser);
        dserFailNum(ser);
        dserCash(ser);
        dserPendant(ser);
        dserRuins(ser);
        dserMilitarySciences(ser);
        dserMilitaryScienceGrids(ser);
        dserMilitaryMaterials(ser);
        dserEnergyStone(ser);
        dserEnergyStoneInlay(ser);
        dserTreasureShopBuy(ser);
        dserPushComment(ser);
        dserDrillTank(ser);
        dserDrillFightData(ser);
        dserDrillShopBuy(ser);
        dserDrillKillTank(ser);
        dserRebelData(ser);
        dserPortrait(ser);
        dserCrossJiFen(ser);
        dserMedal(ser);
        dserMedalChip(ser);
        dserMedalBouns(ser);
        dserPartMatrial(ser);
        dserLockHero(ser);
        dserDay7Act(ser);
        dserAwakenHero(ser);
        dserShop(ser);
        dserMonthSign(ser);
        dserLabInfo(ser);
        derGuideInfo(ser);
        derFestivalInfo(ser);
        derLuckyInfo(ser);
        derTeamInstanceInfo(ser);
        dserRedPlanInfo(ser);
        dserGiftCount(ser);
        dserNewPayVersion(ser);
        dserGiftTime(ser);
        dserRebelBoxTime(ser);
        dserRebelBoxCount(ser);
        dserRebelRedBagTime(ser);
        dserRebelRedBagCount(ser);
        dserFortuneDialDayInfo(ser);
        dserEnergyDialDayInfo(ser);
        dserEquipDialDayInfo(ser);
        dserDayBoxInfo(ser);
        dserActiveBoxFail(ser);
        dserActiveBoxSuc(ser);
        dserActiveBox(ser);
        dserHonourNotify(ser);
        dserHonourGrabGold(ser);
        dserHonourRoleScore(ser);
        dserHonourPartyId(ser);
        dserLeqScheme(ser);
        dserHonourScoreGoldStatus(ser);
        dserRebelEndPartyId(ser);
        dserWarActivityInfo(ser);
        dsercontributeCount(ser);
        dserTacticsInfo(ser);
        derKingRankRewardInfo(ser);
        derWipeInfo(ser);
        dserFriendGive(ser);
        dserGetGiveProp(ser);
        dserBlessFriendlinesses(ser);
        SerPbHelper.deserLordEquipInfo(this, ser);
        SerPbHelper.dserSecretWeapon(this, ser);
        SerPbHelper.dserAttackEffect(this, ser);
        dserEnergyCore(ser);
        dserTicDialDayInfo(ser);

    }

    private void dserShop(SerData ser) {
        shopMap.clear();
        List<CommonPb.Shop> list = ser.getShopList();
        if (list != null && !list.isEmpty()) {
            for (CommonPb.Shop pbShop : list) {
                Shop shop = new Shop(pbShop.getSty(), pbShop.getRefreashTime());
                List<CommonPb.ShopBuy> buyList = pbShop.getBuyList();
                for (CommonPb.ShopBuy pbBuy : buyList) {
                    ShopBuy buy = new ShopBuy(pbBuy.getGid(), pbBuy.getBuyCount());
                    shop.getBuyMap().put(buy.getGid(), buy);
                }
                shopMap.put(shop.getSty(), shop);
            }
        }
    }

    private void dserAwakenHero(SerData ser) {
        List<CommonPb.AwakenHero> list = ser.getAwakenHerosList();
        for (CommonPb.AwakenHero e : list) {
            AwakenHero hero = new AwakenHero(e);
            awakenHeros.put(hero.getKeyId(), hero);
        }
    }

    private void dserDay7Act(SerData ser) {
        CommonPb.DbDay7Act dbDay7Act = ser.getDbDay7Act();
        for (Integer v : dbDay7Act.getRecvAwardIdsList()) {
            day7Act.getRecvAwardIds().add(v);
        }
        for (TwoInt v : dbDay7Act.getStatusList()) {
            day7Act.getStatus().put(v.getV1(), v.getV2());
        }
        for (TwoInt v : dbDay7Act.getTankTypesList()) {
            day7Act.getTankTypes().put(v.getV1(), v.getV2());
        }
        day7Act.setLvUpDay(dbDay7Act.getLvUpDay());
        for (TwoInt v : dbDay7Act.getEquipsList()) {
            day7Act.getEquips().add(new int[]{v.getV1(), v.getV2()});
        }
    }

    private void dserLockHero(SerData ser) {
        for (Integer heroId : ser.getLockHeroList()) {
            lockHeros.add(heroId);
        }
    }

    private void dserPartMatrial(SerData ser) {
        for (TwoInt twoInt : ser.getPartMatrialList()) {
            partMatrial.put(twoInt.getV1(), twoInt.getV2());
        }
    }

    private void dserRebelData(SerData ser) {
        if (ser.hasRebelData()) {
            rebelData = new RoleRebelData(ser.getRebelData());
        }
    }

    private void dserDrillKillTank(SerData ser) {
        List<CommonPb.TwoInt> tankList = ser.getDrillKillTankList();
        for (TwoInt tank : tankList) {
            drillKillTank.put(tank.getV1(), tank.getV2());
        }
    }

    /**
     * 解析宝物商店购买记录
     *
     * @param ser
     */
    private void dserTreasureShopBuy(SerData ser) {
        List<com.game.pb.CommonPb.TreasureShopBuy> list = ser.getTreasureShopBuyList();
        for (com.game.pb.CommonPb.TreasureShopBuy buy : list) {
            treasureShopBuy.put(buy.getTreasureId(), new TreasureShopBuy(buy.getTreasureId(), buy.getBuyNum(), buy.getBuyWeek()));
        }
        dserPushComment(ser);
    }

    /**
     * 解析推送评论消息
     *
     * @param ser
     */
    private void dserPushComment(SerData ser) {
        CommonPb.PushComment p = ser.getPushComment();
        if (p != null) {
            pushComment.setState(p.getState());
            pushComment.setLastCommentTime(p.getLastCommentTime());
        } else {
            pushComment.setState(0);
            pushComment.setLastCommentTime(0);
        }
    }

    private void dserDrillShopBuy(SerData ser) {
        for (com.game.pb.CommonPb.DrillShopBuy buy : ser.getDrillShopBuyList()) {
            drillShopBuy.put(buy.getShopId(), new DrillShopBuy(buy));
        }
    }

    private void dserDrillFightData(SerData ser) {
        if (ser.hasDrillFightData()) {
            drillFightData = new DrillFightData(ser.getDrillFightData());
        }
    }

    /**
     * 解析能晶镶嵌信息
     *
     * @param ser
     */
    private void dserEnergyStoneInlay(SerData ser) {
        List<CommonPb.EnergyStoneInlay> list = ser.getEnergyInlayList();
        for (com.game.pb.CommonPb.EnergyStoneInlay inlay : list) {
            Map<Integer, EnergyStoneInlay> map = energyInlay.get(inlay.getPos());
            if (null == map) {
                map = new HashMap<>();
                energyInlay.put(inlay.getPos(), map);
            }
            map.put(inlay.getHole(), new EnergyStoneInlay(inlay.getPos(), inlay.getHole(), inlay.getStoneId()));
        }
    }

    /**
     * 解析能晶仓库信息
     *
     * @param ser
     */
    private void dserEnergyStone(SerData ser) {
        List<CommonPb.Prop> list = ser.getEnergyStoneList();
        for (com.game.pb.CommonPb.Prop stone : list) {
            energyStone.put(stone.getPropId(), new Prop(stone.getPropId(), stone.getCount()));
        }
    }

    private void dserCrossJiFen(SerData ser) {
        if (ser.hasCrossJiFen()) {
            crossJiFen = ser.getCrossJiFen();
        }
    }

    /**
     * Method: dserMilitaryMaterials @Description: void @throws
     */
    private void dserMilitaryMaterials(SerData ser) {
        List<CommonPb.MilitaryMaterial> list = ser.getMilitaryMaterialList();
        for (CommonPb.MilitaryMaterial m : list) {
            militaryMaterials.put(m.getId(), new MilitaryMaterial(m.getId(), m.getCount()));
        }
    }

    /**
     * Method: dserMilitaryScienceGrids @Description: 解析军工科技格子信息 @param ser @return void @throws
     */
    private void dserMilitaryScienceGrids(SerData ser) {
        List<CommonPb.MilitaryScienceGrid> list = ser.getMilitaryScienceGridList();
        for (CommonPb.MilitaryScienceGrid grid : list) {
            Map<Integer, MilitaryScienceGrid> map = militaryScienceGrids.get(grid.getTankId());
            if (map == null) {
                map = new HashMap<>();
                militaryScienceGrids.put(grid.getTankId(), map);
            }
            map.put(grid.getPos(), new MilitaryScienceGrid(grid.getTankId(), grid.getPos(), grid.getStatus(), grid.getMilitaryScienceId()));
        }
    }

    /**
     * Method: dserMilitarySciences @Description: 解析军工科技信息 @return void @throws
     */
    private void dserMilitarySciences(SerData ser) {
        List<CommonPb.MilitaryScience> list = ser.getMilitaryScienceList();
        for (CommonPb.MilitaryScience tankMilitaryScience : list) {
            militarySciences.put(tankMilitaryScience.getMilitaryScienceId(), new MilitaryScience(tankMilitaryScience.getMilitaryScienceId(),
                    tankMilitaryScience.getLevel(), tankMilitaryScience.getFitTankId(), tankMilitaryScience.getFitPos()));
        }
    }

    private void dserDrillTank(SerData ser) {
        List<CommonPb.Tank> tankList = ser.getDrillTanksList();
        for (CommonPb.Tank tank : tankList) {
            drillTanks.put(tank.getTankId(), new Tank(tank.getTankId(), tank.getCount(), tank.getRest()));
        }
    }

    public DataNew serNewData() {
        DataNew dataNew = new DataNew();
        dataNew.setLordId(roleId);
        dataNew.setRoleData(serRoleData());
        // dataNew.setMail(serMail());

        dataNew.setMaxKey(maxKey);
        dataNew.setCombatId(combatId);
        dataNew.setEquipEplrId(equipEplrId);
        dataNew.setPartEplrId(partEplrId);
        dataNew.setMilitaryEplrId(militaryEplrId);
        dataNew.setExtrEplrId(extrEplrId);
        dataNew.setExtrMark(extrMark);
        dataNew.setWipeTime(wipeTime);
        dataNew.setTimePrlrId(timePrlrId);
        dataNew.setEnergyStoneEplrId(energyStoneEplrId);
        dataNew.setSignLogin(signLogin);
        // dataNew.setSeniorWeek(seniorWeek);
        dataNew.setSeniorDay(seniorDay);
        dataNew.setSeniorCount(seniorCount);
        dataNew.setSeniorScore(seniorScore);
        dataNew.setSeniorAward(seniorAward);
        dataNew.setSeniorBuy(seniorBuy);

        dataNew.setCrossMineScore(this.crossMineScore);
        dataNew.setCrossMineAward(this.crossMineGet);
        // dataNew.setSmeltDay(smeltDay);
        // dataNew.setSmeltTimes(smeltTimes);
        dataNew.setMedalEplrId(medalEplrId);
        return dataNew;
    }

    public void dserNewData(DataNew data) throws InvalidProtocolBufferException {
        roleId = data.getLordId();
        if (data.getRoleData() != null) {
            SerData ser = SerData.parseFrom(data.getRoleData());
            dserRoleData(ser);
        }

        dserMail(data.getMail());
        combatId = data.getCombatId();
        equipEplrId = data.getEquipEplrId();
        partEplrId = data.getPartEplrId();
        militaryEplrId = data.getMilitaryEplrId();
        extrEplrId = data.getExtrEplrId();
        extrMark = data.getExtrMark();
        wipeTime = data.getWipeTime();
        timePrlrId = data.getTimePrlrId();
        energyStoneEplrId = data.getEnergyStoneEplrId();
        signLogin = data.getSignLogin();
        maxKey = data.getMaxKey();
        // seniorWeek = data.getSeniorWeek();
        seniorDay = data.getSeniorDay();
        seniorCount = data.getSeniorCount();
        seniorScore = data.getSeniorScore();
        seniorAward = data.getSeniorAward();
        seniorBuy = data.getSeniorBuy();
        // smeltDay = data.getSmeltDay();
        // smeltTimes = data.getSmeltTimes();
        medalEplrId = data.getMedalEplrId();

        this.crossMineScore = data.getCrossMineScore();
        this.crossMineGet = data.getCrossMineAward();

    }

    // ///////////////////////////////////////////////////////////////////////////////////////////////////////////////

    private void serTank(SerData.Builder ser) {
        Iterator<Tank> it = tanks.values().iterator();
        while (it.hasNext()) {

            Tank next = it.next();
            // LogUtil.error("tankBBB "+lord.getNick() +" tankId = "+next.getTankId()+" tankCount = "+next.getCount());
            ser.addTank(PbHelper.createTankPb(next));
        }
    }

    private void serForm(SerData.Builder ser) {
        Iterator<Form> it = forms.values().iterator();
        while (it.hasNext()) {
            ser.addForm(PbHelper.createFormPb(it.next()));
        }
    }

    private void serChip(SerData.Builder ser) {
        Iterator<Chip> it = chips.values().iterator();
        while (it.hasNext()) {
            ser.addChip(PbHelper.createChipPb(it.next()));
        }
    }

    private void serHero(SerData.Builder ser) {
        Iterator<Hero> it = heros.values().iterator();
        while (it.hasNext()) {
            ser.addHero(PbHelper.createHeroPb(it.next()));
        }

        Set<Entry<Integer, Long>> entries = herosExpiredTime.entrySet();
        for (Entry<Integer, Long> e : entries) {
            CommonPb.KvLong.Builder builder = CommonPb.KvLong.newBuilder();
            builder.setKey(e.getKey());
            builder.setValue(e.getValue());
            ser.addNewHeroExpiredTime(builder.build());
        }
        Set<Entry<Integer, Long>> entries2 = herosCdTime.entrySet();
        for (Entry<Integer, Long> e : entries2) {
            CommonPb.KvLong.Builder builder = CommonPb.KvLong.newBuilder();
            builder.setKey(e.getKey());
            builder.setValue(e.getValue());
            ser.addNewHeroACd(builder.build());
        }

    }

    private void serFriend(SerData.Builder ser) {
        Iterator<Friend> it = friends.values().iterator();
        while (it.hasNext()) {
            ser.addFriend(PbHelper.createDbFriendPb(it.next()));
        }
    }

    private void serBless(SerData.Builder ser) {
        Iterator<Bless> it = blesses.values().iterator();
        while (it.hasNext()) {
            ser.addBless(PbHelper.createDbBlessPb(it.next()));
        }
    }

    private void serSign(SerData.Builder ser) {
        ser.addAllSign(signs);
    }

    private void serMajorTask(SerData.Builder ser) {
        Iterator<Task> it = majorTasks.values().iterator();
        while (it.hasNext()) {
            ser.addMajorTask(PbHelper.createTaskPb(it.next()));
        }
    }

    private void serDayiyTask(SerData.Builder ser) {
        Iterator<Task> it = dayiyTask.iterator();
        while (it.hasNext()) {
            ser.addDayiyTask(PbHelper.createTaskPb(it.next()));
        }
    }

    private void serLiveTask(SerData.Builder ser) {
        Iterator<Task> it = liveTask.values().iterator();
        while (it.hasNext()) {
            ser.addLiveTask(PbHelper.createTaskPb(it.next()));
        }
    }

    private void serLiveTaskAward(SerData.Builder ser) {
        Iterator<Entry<Integer, Integer>> it = liveTaskAward.entrySet().iterator();
        while (it.hasNext()) {
            Entry<Integer, Integer> entry = it.next();
            ser.addLiveTaskAward(PbHelper.createTwoIntPb(entry.getKey(), entry.getValue()));
        }
    }

    private void serBackAward(SerData.Builder ser) {
        Iterator<Entry<Integer, Integer>> it = backAward.entrySet().iterator();
        while (it.hasNext()) {
            Entry<Integer, Integer> entry = it.next();
            ser.addBackAward(PbHelper.createTwoIntPb(entry.getKey(), entry.getValue()));
        }
    }

    private void serLotteryEquip(SerData.Builder ser) {
        Iterator<LotteryEquip> it = lotteryEquips.values().iterator();
        while (it.hasNext()) {
            ser.addLotteryEquip(PbHelper.createDbLotteryEquipPb(it.next()));
        }
    }

    private void serCombat(SerData.Builder ser) {
        Iterator<Combat> it = combats.values().iterator();
        while (it.hasNext()) {
            ser.addCombat(PbHelper.createCombatPb(it.next()));
        }
    }

    private void serExplore(SerData.Builder ser) {
        Iterator<Combat> it = explores.values().iterator();
        while (it.hasNext()) {
            ser.addExplore(PbHelper.createCombatPb(it.next()));
        }
    }

    private void serSection(SerData.Builder ser) {
        for (Map.Entry<Integer, Integer> entry : sections.entrySet()) {
            ser.addSection(PbHelper.createSectionPb(entry.getKey(), entry.getValue()));
        }
    }

    private void serSkill(SerData.Builder ser) {
        for (Map.Entry<Integer, Integer> entry : skills.entrySet()) {
            ser.addSkill(PbHelper.createSkillPb(entry.getKey(), entry.getValue()));
        }
    }

    private void serMill(SerData.Builder ser) {
        Iterator<Mill> it = mills.values().iterator();
        while (it.hasNext()) {
            ser.addMill(PbHelper.createMillPb(it.next()));
        }
    }

    private void serEffect(SerData.Builder ser) {
        Iterator<Effect> it = effects.values().iterator();
        while (it.hasNext()) {
            ser.addEffect(PbHelper.createEffectPb(it.next()));
        }
    }

    private void serSkin(SerData.Builder ser) {
        Iterator<Effect> it = surfaceSkins.values().iterator();
        while (it.hasNext()) {
            ser.addSkin(PbHelper.createEffectPb(it.next()));
        }

        for (Entry<Integer, Map<Integer, Skin>> entry : skinMap.entrySet()) {
            for (Skin skin : entry.getValue().values()) {
                ser.addSkinMap(PbHelper.createTwoIntPb(skin.getSkinId(), skin.getCount()));
            }
        }

        for (Entry<Integer, Map<Integer, Effect>> entry : usedSkinMap.entrySet()) {
            for (Entry<Integer, Effect> usedEntry : entry.getValue().entrySet()) {
                Effect effect = usedEntry.getValue();
                ser.addUsedSkinMap(PbHelper.createThreePb(usedEntry.getKey(), effect.getEffectId(), effect.getEndTime()));
            }
        }

        for (Entry<Integer, Integer> entry : currentSkin.entrySet()) {
            ser.addCurrentSkin(PbHelper.createTwoIntPb(entry.getKey(), entry.getValue()));
        }
    }

    private void serEquip(SerData.Builder ser) {
        for (int i = 0; i < 7; i++) {
            Map<Integer, Equip> map = equips.get(i);
            Iterator<Equip> it = map.values().iterator();
            while (it.hasNext()) {
                ser.addEquip(PbHelper.createEquipPb(it.next()));
            }
        }
    }

    private void serPart(SerData.Builder ser) {
        for (int i = 0; i < 5; i++) {
            Map<Integer, Part> map = parts.get(i);
            Iterator<Part> it = map.values().iterator();
            while (it.hasNext()) {
                ser.addPart(PbHelper.createPartPb(it.next()));
            }
        }
    }

    private void serProp(SerData.Builder ser) {
        Iterator<Prop> it = props.values().iterator();
        while (it.hasNext()) {
            ser.addProp(PbHelper.createPropPb(it.next()));
        }
    }

    private void serScience(SerData.Builder ser) {
        Iterator<Science> it = sciences.values().iterator();
        while (it.hasNext()) {
            ser.addScience(PbHelper.createSciencePb(it.next()));
        }
    }

    private void serTankQue(SerData.Builder ser) {
        for (TankQue e : tankQue_1) {
            ser.addTankQue1(PbHelper.createTankQuePb(e));
        }

        for (TankQue e : tankQue_2) {
            ser.addTankQue2(PbHelper.createTankQuePb(e));
        }
    }

    private void serRefitQue(SerData.Builder ser) {
        for (RefitQue e : refitQue) {
            ser.addRefitQue(PbHelper.createRefitQuePb(e));
        }
    }

    private void serBuildQue(SerData.Builder ser) {
        for (BuildQue e : buildQue) {
            ser.addBuildQue(PbHelper.createBuildQuePb(e));
        }
    }

    private void serScienceQue(SerData.Builder ser) {
        for (ScienceQue e : scienceQue) {
            ser.addScienceQue(PbHelper.createScienceQuePb(e));
        }
    }

    private void serPropQue(SerData.Builder ser) {
        for (PropQue e : propQue) {
            ser.addPropQue(PbHelper.createPropQuePb(e));
        }
    }

    private void serArmy(SerData.Builder ser) {
        for (Army e : armys) {
            ser.addArmy(PbHelper.createArmyPb(e));
        }
    }

    private void serFailNum(SerData.Builder ser) {
        Iterator<FailNum> it = failNums.values().iterator();
        while (it.hasNext()) {
            ser.addFailNum(PbHelper.createFailNumPb(it.next()));
        }
    }

    private void serRuins(SerData.Builder ser) {
        ser.setRunis(PbHelper.createRuinsPb(ruins));
    }

    private void serActivity(SerData.Builder ser) {
        Iterator<Activity> it = activitys.values().iterator();
        while (it.hasNext()) {
            Activity next = it.next();
            ser.addActivity(PbHelper.createDbActivityPb(next));
        }
    }

    private void serQuinnPanel(SerData.Builder ser) {
        Iterator<QuinnPanel> it = quinnPanels.values().iterator();
        while (it.hasNext()) {
            QuinnPanel next = it.next();
            ser.addQuinnPanel(PbHelper.createQuinnPanel(next));
        }
    }

    private void serCash(SerData.Builder ser) {
        Iterator<Cash> it = cashs.values().iterator();
        while (it.hasNext()) {
            Cash next = it.next();
            ser.addCash(PbHelper.createCashPb(next));
        }
    }

    private void serPendant(SerData.Builder ser) {
        Iterator<Pendant> it = pendants.iterator();
        while (it.hasNext()) {
            Pendant next = it.next();
            ser.addPendant(PbHelper.createPendantPb(next));
        }
    }

    private void serPortrait(SerData.Builder ser) {
        Iterator<Portrait> it = portraits.iterator();
        while (it.hasNext()) {
            Portrait next = it.next();
            ser.addPortrait(PbHelper.createPortraitPb(next));
        }
    }

    // ////////////////////////////////////////////////////////////////////////////
    private void dserTankQue(SerData ser) {
        List<CommonPb.TankQue> list1 = ser.getTankQue1List();
        for (CommonPb.TankQue e : list1) {
            TankQue tankQue = new TankQue(e.getKeyId(), e.getTankId(), e.getCount(), e.getState(), e.getPeriod(), e.getEndTime());
            tankQue_1.add(tankQue);
        }

        List<CommonPb.TankQue> list2 = ser.getTankQue2List();
        for (CommonPb.TankQue e : list2) {
            TankQue tankQue = new TankQue(e.getKeyId(), e.getTankId(), e.getCount(), e.getState(), e.getPeriod(), e.getEndTime());
            tankQue_2.add(tankQue);
        }
    }

    private void dserRefitQue(SerData ser) {
        List<CommonPb.RefitQue> list = ser.getRefitQueList();
        for (CommonPb.RefitQue e : list) {
            RefitQue q = new RefitQue(e.getKeyId(), e.getTankId(), e.getRefitId(), e.getCount(), e.getState(), e.getPeriod(),
                    e.getEndTime());
            refitQue.add(q);
        }
    }

    private void dserBuildQue(SerData ser) {
        List<CommonPb.BuildQue> list = ser.getBuildQueList();
        for (CommonPb.BuildQue e : list) {
            BuildQue q = new BuildQue(e.getKeyId(), e.getBuildingId(), e.getPos(), e.getPeriod(), e.getEndTime());
            // long ironCost, long oilCost, long copperCost, long siliconCost
            q.saveCost(e.getIronCost(), e.getOilCost(), e.getCopperCost(), e.getSiliconCost());
            q.setGoldCost(e.getGoldCost());
            buildQue.add(q);
        }
    }

    private void dserPropQue(SerData ser) {
        List<CommonPb.PropQue> list = ser.getPropQueList();
        for (CommonPb.PropQue e : list) {
            PropQue q = new PropQue(e.getKeyId(), e.getPropId(), e.getCount(), e.getState(), e.getPeriod(), e.getEndTime());
            propQue.add(q);
        }
    }

    private void dserArmy(SerData ser) {
        List<CommonPb.Army> list = ser.getArmyList();
        for (CommonPb.Army e : list) {
            Army q = new Army(e);
            armys.add(q);
        }
    }

    private void dserFailNum(SerData ser) {
        List<CommonPb.FailNum> list = ser.getFailNumList();
        for (CommonPb.FailNum e : list) {
            FailNum f = new FailNum(e.getOperType(), e.getNum());
            failNums.put(f.getOperType(), f);
        }
    }

    private void dserRuins(SerData ser) {
        CommonPb.Ruins r = ser.getRunis();
        if (r != null) {
            ruins.setRuins(r.getIsRuins());
            ruins.setLordId(r.getLordId());
            ruins.setAttackerName(r.getAttackerName());
        } else {
            ruins.setRuins(false);
            ruins.setLordId(0);
            ruins.setAttackerName("");
        }
    }

    private void dserCash(SerData ser) {
        List<CommonPb.Cash> list = ser.getCashList();
        for (CommonPb.Cash e : list) {
            Cash q = new Cash(e);
            cashs.put(e.getCashId(), q);
        }
    }

    private void dserPendant(SerData ser) {
        List<CommonPb.Pendant> list = ser.getPendantList();
        for (CommonPb.Pendant e : list) {
            Pendant q = new Pendant(e);
            pendants.add(q);
        }
    }

    private void dserPortrait(SerData ser) {
        List<CommonPb.Portrait> list = ser.getPortraitList();
        for (CommonPb.Portrait e : list) {
            Portrait q = new Portrait(e);
            portraits.add(q);
        }
    }

    private void dserScienceQue(SerData ser) {
        List<CommonPb.ScienceQue> list = ser.getScienceQueList();
        for (CommonPb.ScienceQue e : list) {
            ScienceQue que = new ScienceQue(e.getKeyId(), e.getScienceId(), e.getPeriod(), e.getState(), e.getEndTime());
            que.saveCost(e.getStoneCost(), e.getIronCost(), e.getCopperCost(), e.getOilCost(), e.getSilionCost());
            scienceQue.add(que);
        }
    }

    private void dserChip(SerData ser) {
        List<CommonPb.Chip> chipList = ser.getChipList();
        for (CommonPb.Chip e : chipList) {
            Chip chip = new Chip(e.getChipId(), e.getCount());
            chips.put(chip.getChipId(), chip);
        }
    }

    private void dserHero(SerData ser) {
        List<CommonPb.Hero> list = ser.getHeroList();
        for (CommonPb.Hero e : list) {
            Hero hero = new Hero(e.getKeyId(), e.getHeroId(), e.getCount());
            hero.setEndTime(e.getEndTime());

//			if(e.getCd() >0 ){
//				LogUtil.info("BBBBB "+e.getHeroId()+" "+e.getCd());
//			}

            hero.setCd(e.getCd());
            heros.put(hero.getHeroId(), hero);
        }

        List<CommonPb.KvLong> newHeroExpiredTimeList = ser.getNewHeroExpiredTimeList();
        for (CommonPb.KvLong e : newHeroExpiredTimeList) {
            herosExpiredTime.put(e.getKey(), e.getValue());
        }

        List<CommonPb.KvLong> newHeroACdList = ser.getNewHeroACdList();
        for (CommonPb.KvLong e : newHeroACdList) {
            herosCdTime.put(e.getKey(), e.getValue());
        }


    }

    private void dserFriend(SerData ser) {
        List<CommonPb.DbFriend> list = ser.getFriendList();
        for (CommonPb.DbFriend e : list) {
            Friend friend = new Friend(e.getLordId(), e.getBless(), e.getBlessTime());
            friend.setFriendliness(e.getFriendliness());
            friends.put(e.getLordId(), friend);
        }
    }

    private void dserBless(SerData ser) {
        List<CommonPb.DbBless> list = ser.getBlessList();
        for (CommonPb.DbBless e : list) {
            Bless bless = new Bless();
            bless.setLordId(e.getLordId());
            bless.setState(e.getState());
            bless.setBlessTime(e.getBlessTime());
            blesses.put(e.getLordId(), bless);
        }
    }

    private void dserSign(SerData ser) {
        signs.addAll(ser.getSignList());
    }

    private void dserMajorTask(SerData ser) {
        List<CommonPb.Task> list = ser.getMajorTaskList();
        for (CommonPb.Task e : list) {
            Task task = new Task(e.getTaskId());
            task.setAccept(e.getAccept());
            task.setSchedule(e.getSchedule());
            task.setStatus(e.getStatus());
            majorTasks.put(e.getTaskId(), task);
        }
    }

    private void dserDayiyTask(SerData ser) {
        List<CommonPb.Task> list = ser.getDayiyTaskList();
        for (CommonPb.Task e : list) {
            Task task = new Task(e.getTaskId());
            task.setAccept(e.getAccept());
            task.setSchedule(e.getSchedule());
            task.setStatus(e.getStatus());
            dayiyTask.add(task);
        }
    }

    private void dserLiveTask(SerData ser) {
        List<CommonPb.Task> list = ser.getLiveTaskList();
        for (CommonPb.Task e : list) {
            Task task = new Task(e.getTaskId());
            task.setAccept(e.getAccept());
            task.setSchedule(e.getSchedule());
            task.setStatus(e.getStatus());
            liveTask.put(e.getTaskId(), task);
        }
    }

    private void dserLiveTaskAward(SerData ser) {
        List<CommonPb.TwoInt> liveTaskAwardList = ser.getLiveTaskAwardList();
        for (TwoInt award : liveTaskAwardList) {
            liveTaskAward.put(award.getV1(), award.getV2());
        }
    }

    private void dserBackAward(SerData ser) {
        List<CommonPb.TwoInt> backAwardList = ser.getBackAwardList();
        for (TwoInt award : backAwardList) {
            backAward.put(award.getV1(), award.getV2());
        }
    }

    private void dserLotteryEquip(SerData ser) {
        List<CommonPb.LotteryEquip> list = ser.getLotteryEquipList();
        for (CommonPb.LotteryEquip e : list) {
            LotteryEquip lottery = new LotteryEquip();
            lottery.setLotteryId(e.getLotteryId());
            lottery.setCd(e.getCd());
            lottery.setFreetimes(e.getFreetimes());
            lottery.setTime(e.getTime());
            lottery.setPurple(e.getPurple());
            lotteryEquips.put(e.getLotteryId(), lottery);
        }
    }

    private void dserCombat(SerData ser) {
        List<CommonPb.Combat> list = ser.getCombatList();
        for (CommonPb.Combat e : list) {
            Combat combat = new Combat(e.getCombatId(), e.getStar());
            combats.put(combat.getCombatId(), combat);
        }
    }

    private void dserExplore(SerData ser) {
        List<CommonPb.Combat> list = ser.getExploreList();
        for (CommonPb.Combat e : list) {
            Combat combat = new Combat(e.getCombatId(), e.getStar());
            explores.put(combat.getCombatId(), combat);
        }
    }

    private void dserSection(SerData ser) {
        List<CommonPb.Section> list = ser.getSectionList();
        for (CommonPb.Section e : list) {
            sections.put(e.getSectionId(), e.getBox());
        }
    }

    private void dserSkill(SerData ser) {
        List<CommonPb.Skill> list = ser.getSkillList();
        for (CommonPb.Skill e : list) {
            skills.put(e.getId(), e.getLv());
        }
    }

    private void dserMill(SerData ser) {
        List<CommonPb.Mill> list = ser.getMillList();
        for (CommonPb.Mill e : list) {
            Mill mill = new Mill(e.getPos(), e.getId(), e.getLv());
            mills.put(mill.getPos(), mill);
        }
    }

    private void dserEffect(SerData ser) {
        List<CommonPb.Effect> list = ser.getEffectList();
        for (CommonPb.Effect e : list) {
            Effect effect = new Effect(e.getId(), e.getEndTime());
            effects.put(effect.getEffectId(), effect);
        }
    }

    private void dserSkin(SerData ser) {
        List<CommonPb.Effect> list = ser.getSkinList();
        for (CommonPb.Effect e : list) {
            Effect effect = new Effect(e.getId(), e.getEndTime());
            surfaceSkins.put(effect.getEffectId(), effect);
        }

        List<TwoInt> skinList = ser.getSkinMapList();
        for (TwoInt value : skinList) {
            int skinId = value.getV1();
            Map<Integer, Skin> skinMap = getSkin(skinId / 1000);
            Skin skin = new Skin(skinId, value.getV2());
            skinMap.put(skin.getSkinId(), skin);
        }

        List<ThreeInt> usedSkinList = ser.getUsedSkinMapList();
        for (ThreeInt value : usedSkinList) {
            int skinId = value.getV1();
            Map<Integer, Effect> usedMap = getUsedSkin(skinId / 1000);
            Effect effect = new Effect(value.getV2(), value.getV3());
            usedMap.put(skinId, effect);
        }

        List<TwoInt> currentList = ser.getCurrentSkinList();
        for (TwoInt value : currentList) {
            currentSkin.put(value.getV1(), value.getV2());
        }
    }

    private void dserEquip(SerData ser) {
        List<CommonPb.Equip> equipList = ser.getEquipList();
        for (CommonPb.Equip e : equipList) {
            Equip equip = new Equip(e.getKeyId(), e.getEquipId(), e.getLv(), e.getExp(), e.getPos());
            equip.setStarlv(e.getStarLv());
            equips.get(equip.getPos()).put(equip.getKeyId(), equip);
        }
    }

    private void dserPart(SerData ser) {
        List<CommonPb.Part> partList = ser.getPartList();
        for (CommonPb.Part e : partList) {
            boolean locked = false;
            if (e.hasLocked()) {
                locked = e.getLocked();
            }
            Map<Integer, Integer[]> mapAttr = new HashMap<>();
            for (PartSmeltAttr attr : e.getAttrList()) {
                Integer[] a = new Integer[]{attr.getVal(), attr.getNewVal()};
                mapAttr.put(attr.getId(), a);
            }

            Part part = new Part(e.getKeyId(), e.getPartId(), e.getUpLv(), e.getRefitLv(), e.getPos(), locked, e.getSmeltLv(),
                    e.getSmeltExp(), mapAttr, e.getSaved());
            parts.get(part.getPos()).put(part.getKeyId(), part);
        }
    }

    private void dserProp(SerData ser) {
        List<CommonPb.Prop> propList = ser.getPropList();
        for (CommonPb.Prop e : propList) {
            Prop prop = new Prop(e.getPropId(), e.getCount());
            props.put(prop.getPropId(), prop);
        }
    }

    private void dserForm(SerData ser) {
        List<CommonPb.Form> formList = ser.getFormList();
        for (CommonPb.Form form : formList) {
            CommonPb.TwoInt p1 = form.getP1();
            CommonPb.TwoInt p2 = form.getP2();
            CommonPb.TwoInt p3 = form.getP3();
            CommonPb.TwoInt p4 = form.getP4();
            CommonPb.TwoInt p5 = form.getP5();
            CommonPb.TwoInt p6 = form.getP6();
            Form e = new Form();
            e.setType(form.getType());
            if (form.hasAwakenHero()) {
                e.setAwakenHero(new AwakenHero(form.getAwakenHero()));
            }
            e.setCommander(form.getCommander());
            e.p[0] = p1.getV1();
            e.c[0] = p1.getV2();

            e.p[1] = p2.getV1();
            e.c[1] = p2.getV2();

            e.p[2] = p3.getV1();
            e.c[2] = p3.getV2();

            e.p[3] = p4.getV1();
            e.c[3] = p4.getV2();

            e.p[4] = p5.getV1();
            e.c[4] = p5.getV2();

            e.p[5] = p6.getV1();
            e.c[5] = p6.getV2();

            if (form.hasFormName()) {
                e.setFormName(form.getFormName());
            }

            List<Integer> tacticsKeyIdList = form.getTacticsKeyIdList();
            e.setTactics(new ArrayList<Integer>(tacticsKeyIdList));

            List<TwoInt> tacticsList = form.getTacticsList();
            for (TwoInt t : tacticsList) {
                e.getTacticsList().add(new TowInt(t.getV1(), t.getV2()));
            }

            forms.put(e.getType(), e);
        }
    }

    private void dserTank(SerData ser) {
        List<CommonPb.Tank> tankList = ser.getTankList();
        for (CommonPb.Tank tank : tankList) {

            // LogUtil.error("tankAAAA " + lord.getNick() + " tankId = " + tank.getTankId() + " tankCount = " +
            // tank.getCount());
            tanks.put(tank.getTankId(), new Tank(tank.getTankId(), tank.getCount(), tank.getRest()));
        }
    }

    private void dserScience(SerData ser) {
        List<CommonPb.Science> scienceList = ser.getScienceList();
        for (CommonPb.Science e : scienceList) {
            Science science = new Science(e.getScienceId(), e.getScienceLv());
            sciences.put(science.getScienceId(), science);
        }
    }

    private void dserActivity(SerData ser) {
        List<CommonPb.DbActivity> activityList = ser.getActivityList();
        for (CommonPb.DbActivity e : activityList) {
            Activity activity = new Activity();
            activity.setActivityId(e.getActivityId());
            activity.setBeginTime(e.getBeginTime());
            activity.setEndTime(e.getEndTime());
            activity.setOpen(e.getOpen());
            List<Long> statusList = new ArrayList<>();
            if (e.getStatusList() != null) {
                for (Long status : e.getStatusList()) {
                    statusList.add(status);
                }
            }
            activity.setStatusList(statusList);
            Map<Integer, Integer> statusMap = new HashMap<>();
            if (e.getTowIntList() != null) {
                for (CommonPb.TwoInt towInt : e.getTowIntList()) {
                    statusMap.put(towInt.getV1(), towInt.getV2());
                }
            }
            activity.setStatusMap(statusMap);

            Map<Integer, Integer> propMap = new HashMap<>();
            if (e.getPropList() != null) {
                for (CommonPb.TwoInt towInt : e.getPropList()) {
                    propMap.put(towInt.getV1(), towInt.getV2());
                }
            }
            activity.setPropMap(propMap);

            Map<Integer, Integer> saveMap = new HashMap<>();
            if (e.getSaveList() != null) {
                for (CommonPb.TwoInt towInt : e.getSaveList()) {
                    saveMap.put(towInt.getV1(), towInt.getV2());
                }
            }
            activity.setSaveMap(saveMap);

            activitys.put(e.getActivityId(), activity);
        }
    }

    private void dserQuinnPanel(SerData ser) {
        List<CommonPb.QuinnPanel> quinnPanelsdb = ser.getQuinnPanelList();
        for (CommonPb.QuinnPanel e : quinnPanelsdb) {
            QuinnPanel quinnPanel = new QuinnPanel();
            quinnPanel.setType(e.getType());
            quinnPanel.setQuinns(new ArrayList<Quinn>());
            quinnPanel.getQuinns().addAll(e.getQuinnList());
            quinnPanel.setGetType(e.getGetType());
            quinnPanel.setGetNumber(e.getGetNumber());
            quinnPanel.setGetSum(e.getGetSum());
            quinnPanel.setFreshedDate(e.getRefreshTime());
            if (e.getAwardList() != null) {
                quinnPanel.setAwards(e.getAwardList());
            }
            quinnPanel.setEggId(e.getEggId());
            quinnPanels.put(e.getType(), quinnPanel);
        }
    }

    private void dserMedal(SerData ser) {
        List<CommonPb.Medal> medalList = ser.getMedalList();
        for (CommonPb.Medal e : medalList) {
            Medal medal = new Medal(e.getKeyId(), e.getMedalId(), e.getUpLv(), e.getRefitLv(), e.getPos(), e.getUpExp(), e.getLocked());
            medals.get(medal.getPos()).put(medal.getKeyId(), medal);
        }
    }

    private void dserMedalBouns(SerData ser) {
        List<CommonPb.MedalBouns> medalBounsList = ser.getMedalBounsList();
        for (CommonPb.MedalBouns e : medalBounsList) {
            MedalBouns medalBouns = new MedalBouns(e.getMedalId(), e.getState());
            medalBounss.get(e.getState()).put(e.getMedalId(), medalBouns);
        }
    }

    private void dserMedalChip(SerData ser) {
        List<CommonPb.MedalChip> medalChipList = ser.getMedalChipList();
        for (CommonPb.MedalChip e : medalChipList) {
            MedalChip chip = new MedalChip(e.getChipId(), e.getCount());
            medalChips.put(chip.getChipId(), chip);
        }
    }

    /**
     * gm返回要塞战防守军团
     */
    public void gmRmoveFortressArmy() {
        LinkedList<Army> armys = this.armys;
        Army army = null;
        for (Army i : armys) {
            if (i.getState() == ArmyState.FortessBattle) {
                army = i;
                break;
            }
        }

        if (army == null) {
            return;
        }

        Form form = army.getForm();
        for (int i = 0; i < form.p.length; i++) {
            int tankId = form.p[i];
            int count = form.c[i];
            Tank tank = tanks.get(tankId);
            if (tank != null) {
                tank.setCount(count + tank.getCount());
            } else {
                tank = new Tank(tankId, count, 0);
                tanks.put(tankId, tank);
            }
            LogLordHelper.tank(AwardFrom.GM_REMOVE_FORTRESS_ARMY, this.account, this.lord, tankId, tank.getCount(), count, 0, 0);
        }

        if (form.getAwakenHero() != null) {
            AwakenHero awakenHero = awakenHeros.get(form.getAwakenHero().getKeyId());
            awakenHero.setUsed(false);
            LogLordHelper.awakenHero(AwardFrom.GM_REMOVE_FORTRESS_ARMY, this.account, this.lord, awakenHero, 0);
        } else if (form.getCommander() > 0) {
            int heroId = form.getCommander();
            int count = 1;
            Hero hero = heros.get(heroId);
            if (hero != null) {
                hero.setCount(hero.getCount() + count);
                if (hero.getCount() <= 0) {
                    heros.remove(heroId);
                }
            } else {
                hero = new Hero(heroId, heroId, count);
                heros.put(hero.getHeroId(), hero);
            }

            if (herosExpiredTime.containsKey(heroId)) {
                hero.setEndTime(herosExpiredTime.get(heroId));
            }

            LogLordHelper.hero(AwardFrom.GM_REMOVE_FORTRESS_ARMY, this.account, this.lord, heroId, hero.getCount(), count, hero.getEndTime(), hero.getCd());
        }

        armys.remove(army);
    }

    /**
     * 是否要塞军队中
     *
     * @return
     */
    public boolean isExistFortressArmy() {
        LinkedList<Army> armys = this.armys;
        for (Army i : armys) {
            if (i.getState() == ArmyState.FortessBattle) {
                return true;
            }
        }
        return false;
    }

    public void gmRmoveWarArmy() {
        LinkedList<Army> armys = this.armys;
        Army army = null;
        for (Army i : armys) {
            if (i.getState() == ArmyState.WAR) {
                army = i;
                break;
            }
        }

        if (army == null) {
            return;
        }

        Form form = army.getForm();
        for (int i = 0; i < form.p.length; i++) {
            int tankId = form.p[i];
            int count = form.c[i];
            Tank tank = tanks.get(tankId);
            if (tank != null) {
                tank.setCount(count + tank.getCount());
            } else {
                tank = new Tank(tankId, count, 0);
                tanks.put(tankId, tank);
            }
            LogLordHelper.tank(AwardFrom.GM_REMOVE_WAR_ARMY, this.account, this.lord, tankId, tank.getCount(), count, 0, 0);
        }
        if (form.getAwakenHero() != null) {
            AwakenHero awakenHero = awakenHeros.get(form.getAwakenHero().getKeyId());
            awakenHero.setUsed(false);
            LogLordHelper.awakenHero(AwardFrom.GM_REMOVE_WAR_ARMY, this.account, this.lord, awakenHero, 0);
        } else if (form.getCommander() > 0) {
            int heroId = form.getCommander();
            int count = 1;
            Hero hero = heros.get(heroId);
            if (hero != null) {
                hero.setCount(hero.getCount() + count);
                if (hero.getCount() <= 0) {
                    heros.remove(heroId);
                }
            } else {
                hero = new Hero(heroId, heroId, count);
                heros.put(hero.getHeroId(), hero);
            }

            if (herosExpiredTime.containsKey(heroId)) {
                hero.setEndTime(herosExpiredTime.get(heroId));
            }
            LogLordHelper.hero(AwardFrom.GM_REMOVE_WAR_ARMY, this.account, this.lord, heroId, hero.getCount(), count, hero.getEndTime(), hero.getCd());
        }

        armys.remove(army);
    }

    public boolean hasHero(int heroId) {
        if (heros.containsKey(heroId)) {
            return true;
        }
        for (AwakenHero awakenHero : awakenHeros.values()) {
            if (awakenHero.getHeroId() == heroId) {
                return true;
            }
        }
        return false;
    }

    public void serMonthSign(SerData.Builder serData) {
        serData.setMonthSign(SerPbHelper.serMonthSign(monthSign));
    }

    public void serLabInfo(SerData.Builder serData) {
        serData.setLabInfo(SerPbHelper.serLabInfoPb(labInfo));
    }

    public void serRedPlanInfo(SerData.Builder serData) {
        serData.setRedPlanInfo(SerPbHelper.serRedPlanInfo(redPlanInfo));
    }

    public void serGuideInfo(SerData.Builder serData) {
        SerPbHelper.serGuideInfo(serData, guideRewardInfo);
    }

    public void dserMonthSign(SerData data) {
        monthSign = SerPbHelper.deserMonthSign(data);
    }

    public void dserLabInfo(SerData data) {
        labInfo = SerPbHelper.deserLabInfo(data);
    }

    public void derGuideInfo(SerData data) {
        guideRewardInfo = SerPbHelper.dserLabInfo(data);
    }

    public void dserRedPlanInfo(SerData data) {
        redPlanInfo = SerPbHelper.deserRedPlanInfo(data);
    }

    public void dserGiftCount(SerData data) {
        giftRewardCount = data.getGiftRewardCount();
    }

    public void dserNewPayVersion(SerData data) {
        newPayVersion = data.getNewPayVersion();
        List<Integer> newPayInfoList = data.getNewPayInfoList();
        if (newPayInfoList != null && !newPayInfoList.isEmpty()) {
            newPayInfo = new LinkedList<>(newPayInfoList);
        }

        new2PayVersion = data.getNew2PayVersion();
        List<Integer> new2PayInfoList = data.getNew2PayInfoList();
        if (new2PayInfoList != null && !new2PayInfoList.isEmpty()) {
            new2PayInfo = new LinkedList<>(new2PayInfoList);
        }

    }

    public void dserGiftTime(SerData data) {
        giftRewardTime = data.getGiftRewardTime();
    }

    public void serGiftCount(SerData.Builder serData) {
        serData.setGiftRewardCount(giftRewardCount);
    }

    public void serNewPayVersion(SerData.Builder serData) {
        serData.setNewPayVersion(newPayVersion);
        for (Integer payId : newPayInfo) {
            serData.addNewPayInfo(payId);
        }
        serData.setNew2PayVersion(new2PayVersion);
        for (Integer payId : new2PayInfo) {
            serData.addNew2PayInfo(payId);
        }

    }

    public void serGiftTime(SerData.Builder serData) {
        serData.setGiftRewardTime(giftRewardTime);
    }

    public boolean hasTank(int tankId) {
        return tanks.containsKey(tankId);
    }

    /**
     * 判断heroId是否在入驻列表里
     *
     * @param heroId
     * @return
     */
    public boolean isHeroPut(int heroId) {
        for (List<Integer> list : lord.getHeroPut().values()) {
            if (list.contains(heroId)) {
                return true;
            }
        }
        return false;
    }

    /**
     * 判断入驻的heroId文官数
     *
     * @param id
     * @return
     */
    public int heroPutNum(int id) {
        int count = 0;
        for (List<Integer> list : lord.getHeroPut().values()) {
            for (int i = 1; i < list.size(); i++) {
                if (list.get(i) == id) {
                    count++;
                }
            }
        }
        return count;
    }

    /**
     * 返回指定类型的皮肤map
     *
     * @param type
     * @return
     */
    public Map<Integer, Skin> getSkin(int type) {
        Map<Integer, Skin> returnValue = skinMap.get(type);
        if (returnValue == null) {
            returnValue = new HashMap<>();
            skinMap.put(type, returnValue);
        }
        return returnValue;
    }

    /**
     * 返回指定类型的正使用皮肤map
     *
     * @param type
     * @return
     */
    public Map<Integer, Effect> getUsedSkin(int type) {
        Map<Integer, Effect> returnValue = usedSkinMap.get(type);
        if (returnValue == null || returnValue.isEmpty()) {
            returnValue = new HashMap<>();
            // 初始化为默认皮肤
            int skinId = type * 1000 + 1;
            returnValue.put(skinId, new Effect(0, 0));
            usedSkinMap.put(type, returnValue);
        }

        // 给相应VIP等级返回特殊皮肤
        int vip = lord.getVip();
        int startSkinId = type * 1000;

        if (vip >= 15) {
            int skinId = startSkinId + 7;
            if (!usedSkinMap.containsKey(skinId)) {
                returnValue.put(skinId, new Effect(0, 0));
            }
        }

        if (vip >= 12) {
            int skinId = startSkinId + 4;
            if (!usedSkinMap.containsKey(skinId)) {
                returnValue.put(skinId, new Effect(0, 0));
            }
        }
        if (vip >= 9) {
            int skinId = startSkinId + 3;
            if (!usedSkinMap.containsKey(skinId)) {
                returnValue.put(skinId, new Effect(0, 0));
            }
        }
        if (vip >= 3) {
            int skinId = startSkinId + 2;
            if (!usedSkinMap.containsKey(skinId)) {
                returnValue.put(skinId, new Effect(0, 0));
            }
        }

        return returnValue;
    }

    /**
     * @return
     */
    public Map<Integer, Map<Integer, Effect>> getUsedSkin() {
        return usedSkinMap;
    }

    /**
     * 获取当前使用皮肤
     */
    public int getCurrentSkin(int type) {
        Integer skinId = currentSkin.get(type);
        if (skinId == null) {
            skinId = type * 1000 + 1;
            currentSkin.put(type, skinId);
        }
        return skinId;
    }

    public void setCurrentSkin(int type, int skinId) {
        currentSkin.put(type, skinId);
    }

    /**
     * 删除邮件
     *
     * @param mail
     */
    public void delMail(Mail mail) {
        delMails.add(mail);
        mails.remove(mail.getKeyId());
    }

    public Mail delMail(int keyId) {
        Mail mail = mails.remove(keyId);
        delMails.add(mail);
        return mail;
    }

    // 兼容旧功能代码
    public void delMail(Iterator<Mail> it, Mail mail) {
        it.remove();
        delMails.add(mail);
    }

    /**
     * 添加新邮件
     *
     * @param mail
     */
    public void addNewMail(Mail mail) {
        newMails.add(mail);
        mails.put(mail.getKeyId(), mail);
    }

    /**
     * 更改邮件状态
     *
     * @param mail
     * @param state
     */
    public void updMailState(Mail mail, int state) {
        mail.setState(state);
        updMails.put(mail.getKeyId(), state);
        updMailsCollections.put(mail.getKeyId(), mail.getCollections());
    }

    /**
     * @return
     */
    public Map<Integer, Mail> getMails() {
        return mails;
    }

    /**
     * @param keyId
     * @return
     */
    public Mail getMail(int keyId) {
        return mails.get(keyId);
    }

    /**
     * 清空邮件
     */
    public void clearMails() {
        for (Mail mail : mails.values()) {
            delMails.add(mail);
        }
        mails.clear();
    }

    public int getNewMailsSize() {
        return newMails.size();
    }

    /**
     * 拷贝新邮件列表供入库线程存入邮件表
     *
     * @return
     */
    public List<Mail> copyNewMails() {
        List<Mail> list = new LinkedList<>();

        // mail除了状态会改变，其他不会改变，浅拷贝即可
        for (Mail mail : newMails) {
            list.add((Mail) mail.clone());
        }

        newMails.clear();

        return list;
    }

    public int getUpdMailsSize() {
        return updMails.size();
    }

    /**
     * 拷贝更新列表供入库线程更新邮件数据
     *
     * @return
     */
    public List<List<Integer>> copyUpdMails() {
        List<List<Integer>> list = new LinkedList<>();

        for (Entry<Integer, Integer> entry : updMails.entrySet()) {
            List<Integer> upd = new ArrayList<>(3);
            upd.add(entry.getKey());
            upd.add(entry.getValue());
            upd.add(updMailsCollections.get(entry.getKey()));

            list.add(upd);
        }

        updMails.clear();

        return list;
    }

    public int getDelMailsSize() {
        return delMails.size();
    }

    /**
     * 拷贝已删除邮件，供入库线程删除库中数据
     *
     * @return
     */
    public List<Integer> copyDelMails() {
        List<Integer> list = new LinkedList<>();

        for (Mail mail : delMails) {
            list.add(mail.getKeyId());
        }

        delMails.clear();

        return list;
    }

    /**
     * 从数据库载入邮件数据
     *
     * @param newMailList
     */
    public void loadMail(List<NewMail> newMailList) {
        if (newMailList == null || newMailList.isEmpty())
            return;
        for (NewMail newMail : newMailList) {
            Mail mail = new Mail();
            mail.setKeyId(newMail.getKeyId());
            mail.setType(newMail.getType());
            mail.setMoldId(newMail.getMoldId());
            mail.setTitle(newMail.getTitle());
            mail.setSendName(newMail.getSendName());
            mail.setToName(newMail.getToName());
            mail.setState(newMail.getState());
            mail.setContont(newMail.getContont());
            mail.setTime(newMail.getTime());
            mail.setLv(newMail.getLv());
            mail.setVipLv(newMail.getVipLv());
            mail.setCollections(newMail.getCollections());
            if (newMail.getParam() != null && !newMail.getParam().isEmpty()) {
                mail.setParam((String[]) newMail.getParam().toArray(new String[0]));
            }

            String awards = newMail.getAward();
            if (awards != null && !awards.isEmpty()) {
                List<Award> list = JSON.parseArray(awards, Award.class);
                List<CommonPb.Award> awardList = new ArrayList<>(list.size());
                for (Award award : list) {
                    CommonPb.Award.Builder builder = CommonPb.Award.newBuilder();
                    builder.setId(award.getId());
                    builder.setType(award.getType());
                    builder.setCount(award.getCount());
                    if (award.getParam() != null) {
                        builder.addAllParam(award.getParam());
                    }
                    awardList.add(builder.build());
                }
                mail.setAward(awardList);
            }

            if (newMail.getReport() != null) {
                try {
                    mail.setReport(Report.parseFrom(newMail.getReport()));
                } catch (InvalidProtocolBufferException e) {
                    e.printStackTrace();
                }
            }
            mails.put(mail.getKeyId(), mail);
        }
    }

    /**
     * 以NewMail返回邮件列表
     *
     * @return
     */
    public List<NewMail> getNewMails() {
        List<NewMail> newMailList = new LinkedList<>();
        for (Mail mail : mails.values()) {
            NewMail newMail = MailHelper.createNewMail(roleId, mail);
            newMailList.add(newMail);
        }
        return newMailList;
    }

    /**
     * 获取玩家开启的最高级秘密武器
     *
     * @return
     */
    public int getHighestOpenSecretWeapon() {
        int size = secretWeaponMap.size();
        if (size != 0) {
            SecretWeapon weapon = secretWeaponMap.lastEntry().getValue();
            if (!weapon.getBars().isEmpty()) {
                return weapon.getId();
            } else {
                if (size > 1) {
                    Entry<Integer, SecretWeapon> lessEntry = secretWeaponMap.lowerEntry(weapon.getId());
                    return lessEntry != null ? lessEntry.getKey() : 0;
                }
            }
        }
        return 0;
    }

    public List<Integer> getGuideRewardInfo() {
        return guideRewardInfo;
    }

    public void serFestivalInfo(SerData.Builder serData) {
        SerPbHelper.serFestivalInfo(serData, festivalInfo);
    }

    public void derFestivalInfo(SerData data) {
        festivalInfo = SerPbHelper.derFestivalInfo(data);
    }

    public FestivalInfo getFestivalInfo() {
        return festivalInfo;
    }

    public void serLuckyInfo(SerData.Builder serData) {
        SerPbHelper.serLuckyInfo(serData, luckyInfo);
    }

    public void derLuckyInfo(SerData data) {
        luckyInfo = SerPbHelper.derLuckyInfo(data);
    }

    public LuckyInfo getLuckyInfo() {
        return luckyInfo;
    }

    public TeamInstanceInfo getTeamInstanceInfo() {
        return teamInstanceInfo;
    }

    public DialDailyGoalInfo getFortuneDialDayInfo() {
        return fortuneDialDayInfo;
    }

    public DialDailyGoalInfo getEnergyDialDayInfo() {
        return energyDialDayInfo;
    }

    public DialDailyGoalInfo getEquipDialDayInfo() {
        return equipDialDayInfo;
    }

    public void serFortuneDialDayInfo(SerData.Builder serData) {
        SerPbHelper.serFortuneDialDayInfo(serData, fortuneDialDayInfo);
    }

    public void dserFortuneDialDayInfo(SerData data) {
        fortuneDialDayInfo = SerPbHelper.dserFortuneDialDayInfo(data);
    }

    public void serEnergyDialDayInfo(SerData.Builder serData) {
        SerPbHelper.serEnergyDialDayInfo(serData, energyDialDayInfo);
    }

    public void dserEnergyDialDayInfo(SerData data) {
        energyDialDayInfo = SerPbHelper.dserEnergyDialDayInfo(data);
    }

    public void serTeamInstanceInfo(SerData.Builder serData) {
        SerPbHelper.serTeamInstanceInfo(serData, teamInstanceInfo);
    }

    public void derTeamInstanceInfo(SerData data) {
        teamInstanceInfo = SerPbHelper.derTeamInstanceInfo(data);
    }

    public void serRebelBoxTime(SerData.Builder serData) {
        serData.setRebelBoxTime(rebelBoxTime);
    }

    public void serRebelBoxCount(SerData.Builder serData) {
        serData.addAllRebelBoxCount(rebelBoxCount);
    }

    public void serRebelRedBagTime(SerData.Builder serData) {
        serData.setRebelRedBagTime(rebelRedBagTime);
    }

    public void serRebelRedBagCount(SerData.Builder serData) {
        serData.addAllRebelRedBagCount(rebelRedBagCount);
    }

    public void dserRebelBoxTime(SerData serData) {
        rebelBoxTime = serData.getRebelBoxTime();
    }

    public void dserRebelBoxCount(SerData serData) {
        rebelBoxCount.addAll(serData.getRebelBoxCountList());
    }

    public void dserRebelRedBagTime(SerData serData) {
        rebelRedBagTime = serData.getRebelRedBagTime();
    }

    public void dserRebelRedBagCount(SerData serData) {
        rebelRedBagCount.addAll(serData.getRebelRedBagCountList());
    }

    public void dserEquipDialDayInfo(SerData serData) {
        equipDialDayInfo = SerPbHelper.dserEquipDialDayInfo(serData);
    }

    public void serEquipDialDayInfo(SerData.Builder serData) {
        SerPbHelper.serEquipDialDayInfo(serData, equipDialDayInfo);
    }

    public void dserTicDialDayInfo(SerData serData) {
        ticDialDayInfo = SerPbHelper.dserTicDialDayInfo(serData);
    }

    public void serTicDialDayInfo(SerData.Builder serData) {
        SerPbHelper.serTicDialDayInfo(serData, ticDialDayInfo);
    }

    public void dserDayBoxInfo(SerData serData) {

        List<TwoInt> dayBoxinfoList = serData.getDayBoxinfoList();

        if (dayBoxinfoList != null && !dayBoxinfoList.isEmpty()) {
            for (TwoInt t : dayBoxinfoList) {
                dayBoxinfo.put(t.getV1(), t.getV2());
            }
        }
        dayBoxTime = serData.getDayBoxTime();
        scoutFreeTime = serData.getScoutFreeTime();
        scoutFreeTimeCount = serData.getScoutFreeTimeCount();
        scoutRewardCount = serData.getScoutRewardCount();
        scoutRewardTime = serData.getScoutRewardTime();
        scoutBanCount = serData.getScoutBanCount();
        newHeroAddGold = serData.getNewHeroAddGold();
        newHeroAddGoldTime = serData.getNewHeroAddGoldTime();
        newHeroAddCount = serData.getNewHeroAddCount();
        newHeroAddClearCdTime = serData.getNewHeroAddClearCdTime();
        isVerification = serData.getIsVerification();
        contributionWorldStaffing = serData.getContributionWorldStaffing();
        List<TwoInt> heroClearCdCountList = serData.getHeroClearCdCountList();
        for (TwoInt t : heroClearCdCountList) {
            heroClearCdCount.put(t.getV1(), t.getV2());
        }

    }

    public void serDayBoxInfo(SerData.Builder serData) {

        Set<Entry<Integer, Integer>> entries = dayBoxinfo.entrySet();
        for (Entry<Integer, Integer> e : entries) {
            serData.addDayBoxinfo(PbHelper.createTwoIntPb(e.getKey(), e.getValue()));
        }
        serData.setDayBoxTime(dayBoxTime);

        serData.setScoutFreeTime(scoutFreeTime);
        serData.setScoutFreeTimeCount(scoutFreeTimeCount);
        serData.setScoutRewardCount(scoutRewardCount);
        serData.setScoutRewardTime(scoutRewardTime);
        serData.setScoutBanCount(scoutBanCount);
        serData.setNewHeroAddGold(newHeroAddGold);
        serData.setNewHeroAddGoldTime(newHeroAddGoldTime);
        serData.setNewHeroAddCount(newHeroAddCount);
        serData.setNewHeroAddClearCdTime(newHeroAddClearCdTime);
        serData.setIsVerification(isVerification);
        serData.setContributionWorldStaffing(contributionWorldStaffing);
        for (Entry<Integer, Integer> e : this.heroClearCdCount.entrySet()) {
            serData.addHeroClearCdCount(PbHelper.createTwoIntPb(e.getKey(), e.getValue()));
        }
    }

    public void dserActiveBoxSuc(SerData serData) {
        activeBoxSuc = serData.getActiveSuc();
    }

    public void serActiveBoxSuc(SerData.Builder serData) {
        serData.setActiveSuc(activeBoxSuc);
    }

    public void serActiveBoxFail(SerData.Builder serData) {
        serData.setActiveFail(activeBoxFail);
    }

    public void dserActiveBoxFail(SerData serData) {
        activeBoxFail = serData.getActiveFail();
    }

    public void serActiveBox(SerData.Builder serData) {
        serData.addAllActiveBox(activeBox);
    }

    public void dserActiveBox(SerData serData) {
        activeBox = new LinkedList<Integer>(serData.getActiveBoxList());
    }

    public void dserHonourNotify(SerData ser) {
        this.honourNotify = ser.getHonourNotify();
    }

    public void serHonourNotify(SerData.Builder serData) {
        serData.setHonourNotify(honourNotify);
    }

    public void dserHonourGrabGold(SerData serData) {
        honourGrabGold = serData.getHonourGrabGold();
    }

    public void serHonourGrabGold(SerData.Builder serData) {
        serData.setHonourGrabGold(honourGrabGold);
    }

    public void dserHonourRoleScore(SerData serData) {
        if (serData.hasHonourRoleScore()) {
            honourScore = new HonourRoleScore(serData.getHonourRoleScore());
        }
    }

    public void serHonourRoleScore(SerData.Builder serData) {
        if (honourScore != null) {
            serData.setHonourRoleScore(honourScore.toPb());
        }
    }

    public int getHonourGrabGold() {
        return honourGrabGold;
    }

    public void setHonourGrabGold(int honourGrabGold) {
        this.honourGrabGold = honourGrabGold;
    }

    public int getHonourPartyId() {
        return honourPartyId;
    }

    public void setHonourPartyId(int honourPartyId) {
        this.honourPartyId = honourPartyId;
    }

    public void dserHonourPartyId(SerData serData) {
        honourPartyId = serData.getHonourPartyId();
    }

    public void serHonourPartyId(SerData.Builder serData) {
        serData.setHonourPartyId(honourPartyId);
    }

    public void dserRebelEndPartyId(SerData serData) {
        rebelEndPartyId = serData.getRebelEndPartyId();
    }

    public void serRebelEndPartyId(SerData.Builder serData) {
        serData.setRebelEndPartyId(rebelEndPartyId);
    }

    public void serLeqScheme(SerData.Builder serData) {
        for (LeqScheme scheme : leqScheme.values()) {
            serData.addLeqScheme(scheme.toPb());
        }
    }

    public void dserLeqScheme(SerData serData) {
        leqScheme.clear();
        for (com.game.pb.CommonPb.LeqScheme scheme : serData.getLeqSchemeList()) {
            leqScheme.put(scheme.getType(), new LeqScheme(scheme));
        }
    }

    public int getHonourScoreGoldStatus() {
        return honourScoreGoldStatus;
    }

    public void setHonourScoreGoldStatus(int honourScoreGoldStatus) {
        this.honourScoreGoldStatus = honourScoreGoldStatus;
    }

    public void dserHonourScoreGoldStatus(SerData serData) {
        honourScoreGoldStatus = serData.getHonourScoreGoldStatus();
    }

    public void serHonourScoreGoldStatus(SerData.Builder serData) {
        serData.setHonourScoreGoldStatus(honourScoreGoldStatus);
    }

    public Map<Integer, List<Integer>> getScoutImg() {
        return scoutImg;
    }

    public void setScoutImg(Map<Integer, List<Integer>> scoutImg) {
        this.scoutImg = scoutImg;
    }

    public void serWarActivityInfo(SerData.Builder serData) {

        CommonPb.WarActivityInfo.Builder builder = CommonPb.WarActivityInfo.newBuilder();
        builder.setVersion(this.warActivityInfo.getVersion());
        Map<Integer, Integer> info = this.warActivityInfo.getInfo();
        for (Entry<Integer, Integer> e : info.entrySet()) {
            builder.addInfo(PbHelper.createTwoIntPb(e.getKey(), e.getValue()));
        }
        Map<Integer, Integer> rewardState = this.warActivityInfo.getRewardState();
        for (Entry<Integer, Integer> e : rewardState.entrySet()) {
            builder.addRewardState(PbHelper.createTwoIntPb(e.getKey(), e.getValue()));
        }
        serData.setWarActivityInfo(builder.build());
    }

    public void dserWarActivityInfo(SerData serData) {

        CommonPb.WarActivityInfo w = serData.getWarActivityInfo();
        this.warActivityInfo.setVersion(w.getVersion());

        List<TwoInt> infoList = w.getInfoList();
        for (TwoInt t : infoList) {
            this.warActivityInfo.getInfo().put(t.getV1(), t.getV2());
        }

        List<TwoInt> stateList = w.getRewardStateList();
        for (TwoInt t : stateList) {
            this.warActivityInfo.getRewardState().put(t.getV1(), t.getV2());
        }

    }

    public void sercontributeCount(SerData.Builder serData) {

        for (Entry<Integer, Integer> e : this.contributeCount.entrySet()) {
            serData.addContributeCount(PbHelper.createTwoIntPb(e.getKey(), e.getValue()));
        }
    }

    public void dsercontributeCount(SerData serData) {

        List<TwoInt> contributeCountList = serData.getContributeCountList();
        for (TwoInt t : contributeCountList) {
            this.contributeCount.put(t.getV1(), t.getV2());
        }
    }

    public Map<Integer, Integer> getContributeCount() {
        return contributeCount;
    }


    public void serTacticsInfo(SerData.Builder serData) {
        CommonPb.TacticsInfo.Builder builder = CommonPb.TacticsInfo.newBuilder();
        Map<Integer, Tactics> tacticsMap = tacticsInfo.getTacticsMap();
        for (Tactics t : tacticsMap.values()) {
            builder.addInfo(PbHelper.createTactics(t));
        }
        Set<Map.Entry<Integer, Integer>> entries = tacticsInfo.getTacticsSliceMap().entrySet();
        for (Map.Entry<Integer, Integer> e : entries) {
            builder.addTacticsSlice(PbHelper.createTwoIntPb(e.getKey(), e.getValue()));
        }

        Set<Map.Entry<Integer, Integer>> items = tacticsInfo.getTacticsItemMap().entrySet();
        for (Map.Entry<Integer, Integer> e : items) {
            builder.addTacticsItem(PbHelper.createTwoIntPb(e.getKey(), e.getValue()));
        }

        builder.setKeyId(tacticsInfo.getKeyid());
        builder.setCombatId(tacticsInfo.getCombatId());

        Map<Integer, List<Integer>> tacticsForm = tacticsInfo.getTacticsForm();

        for (Integer index : tacticsForm.keySet()) {
            TacticsForm.Builder builder1 = TacticsForm.newBuilder();
            builder1.setIndex(index);
            builder1.addAllKeyId(new ArrayList<>(tacticsForm.get(index)));
            builder.addTacticsForm(builder1.build());
        }

        serData.setTacticInfo(builder.build());
    }

    public void dserTacticsInfo(SerData serData) {

        CommonPb.TacticsInfo tinfo = serData.getTacticInfo();
        List<CommonPb.Tactics> infoList = tinfo.getInfoList();


        tacticsInfo.setKeyid(tinfo.getKeyId());
        tacticsInfo.setCombatId(tinfo.getCombatId());

        for (CommonPb.Tactics t : infoList) {
            Tactics tactics = new Tactics();
            tactics.setKeyId(t.getKeyId());
            tactics.setTacticsId(t.getTacticsId());
            tactics.setLv(t.getLv());
            tactics.setExp(t.getExp());
            tactics.setUse(0);
            tactics.setState(t.getState());
            tactics.setBind(t.getBind());
            tacticsInfo.getTacticsMap().put(tactics.getKeyId(), tactics);
        }

        List<TwoInt> tacticsSliceList = tinfo.getTacticsSliceList();
        for (TwoInt t : tacticsSliceList) {
            tacticsInfo.getTacticsSliceMap().put(t.getV1(), t.getV2());
        }


        List<TwoInt> tacticsItemList = tinfo.getTacticsItemList();
        for (TwoInt t : tacticsItemList) {
            tacticsInfo.getTacticsItemMap().put(t.getV1(), t.getV2());
        }

        List<TacticsForm> tacticsFormList = tinfo.getTacticsFormList();

        for (TacticsForm f : tacticsFormList) {
            if (!tacticsInfo.getTacticsForm().containsKey(f.getIndex())) {
                List<Integer> keyIdList = f.getKeyIdList();
                tacticsInfo.getTacticsForm().put(f.getIndex(), new ArrayList<>(keyIdList));
            }

        }

    }

    public void serKingRankRewardInfo(SerData.Builder serData) {
        CommonPb.KingRankRewardInfo.Builder builder = CommonPb.KingRankRewardInfo.newBuilder();
        Set<Map.Entry<Integer, Integer>> point = kingRankRewardInfo.getPointsStatus().entrySet();
        for (Map.Entry<Integer, Integer> e : point) {
            builder.addPointsStatus(PbHelper.createTwoIntPb(e.getKey(), e.getValue()));
        }

        Set<Map.Entry<Integer, Integer>> rank = kingRankRewardInfo.getRankStatus().entrySet();
        for (Map.Entry<Integer, Integer> e : rank) {
            builder.addRankStatus(PbHelper.createTwoIntPb(e.getKey(), e.getValue()));
        }

        builder.setVersion(kingRankRewardInfo.getVersion());

        serData.setKingRankRewardInfo(builder.build());
    }

    public void derKingRankRewardInfo(SerData serData) {
        CommonPb.KingRankRewardInfo info = serData.getKingRankRewardInfo();

        List<TwoInt> pointsStatusList = info.getPointsStatusList();
        for (TwoInt t : pointsStatusList) {
            kingRankRewardInfo.getPointsStatus().put(t.getV1(), t.getV2());
        }

        List<TwoInt> rankStatusList = info.getRankStatusList();
        for (TwoInt t : rankStatusList) {
            kingRankRewardInfo.getRankStatus().put(t.getV1(), t.getV2());
        }

        kingRankRewardInfo.setVersion(info.getVersion());
    }

    /**
     * 扫荡副本
     *
     * @param serData
     */
    public void serWipeInfo(SerData.Builder serData) {

        for (WipeInfo info : wipeInfo.values()) {
            serData.addWipeInfo(PbHelper.createWipeInfo(info));
        }


    }

    /**
     * 扫荡副本
     *
     * @param serData
     */
    public void derWipeInfo(SerData serData) {

        List<CommonPb.WipeInfo> wipeInfoList = serData.getWipeInfoList();
        for (CommonPb.WipeInfo winfo : wipeInfoList) {
            wipeInfo.put(winfo.getExploreType(), new WipeInfo(winfo));
        }

    }

    public Map<Long, FriendGive> getGiveMap() {
        return giveMap;
    }

    public void setGiveMap(Map<Long, FriendGive> giveMap) {
        this.giveMap = giveMap;
    }

    public List<GetGiveProp> getGetGivePropList() {
        return getGivePropList;
    }

    public void setGetGivePropList(List<GetGiveProp> getGivePropList) {
        this.getGivePropList = getGivePropList;
    }

    private void serFriendGive(SerData.Builder ser) {
        Iterator<FriendGive> it = giveMap.values().iterator();
        while (it.hasNext()) {
            ser.addFriendGive(PbHelper.createFriendGivePb(it.next()));
        }
    }

    private void dserFriendGive(SerData ser) {
        List<CommonPb.FriendGive> list = ser.getFriendGiveList();
        for (CommonPb.FriendGive e : list) {
            FriendGive friendGive = new FriendGive(e.getLordId(), e.getCount(), e.getGiveTime());
            giveMap.put(e.getLordId(), friendGive);
        }
    }

    private void serGetGiveProp(SerData.Builder ser) {
        Iterator<GetGiveProp> it = getGivePropList.iterator();
        while (it.hasNext()) {
            ser.addGetGiveProp(PbHelper.createGetGivePropPb(it.next()));
        }
    }

    private void dserGetGiveProp(SerData ser) {
        List<CommonPb.GetGiveProp> givePropList = ser.getGetGivePropList();
        for (CommonPb.GetGiveProp e : givePropList) {
            getGivePropList.add(new GetGiveProp(e.getType(), e.getPropId(), e.getNum(), e.getLastGiveTime()));
        }
    }

    public Map<Long, Friendliness> getBlessFriendlinesses() {
        return blessFriendlinesses;
    }

    public void setBlessFriendlinesses(Map<Long, Friendliness> blessFriendlinesses) {
        this.blessFriendlinesses = blessFriendlinesses;
    }

    private void serBlessFriendlinesses(SerData.Builder ser) {
        Iterator<Friendliness> it = blessFriendlinesses.values().iterator();
        while (it.hasNext()) {
            ser.addFriendliness(PbHelper.createDbFriendlinessPb(it.next()));
        }
    }

    private void dserBlessFriendlinesses(SerData ser) {
        List<DBFriendliness> friendlinessList = ser.getFriendlinessList();
        for (DBFriendliness dbFriendliness : friendlinessList) {
            Friendliness friendliness = new Friendliness(dbFriendliness.getLordId(), dbFriendliness.getState(), dbFriendliness.getCreateTime());
            blessFriendlinesses.put(dbFriendliness.getLordId(), friendliness);
        }
    }

    /**
     * 编译能源核心
     *
     * @param ser
     */
    private void serEnergyCore(SerData.Builder ser) {
        ser.setEnergyCore(energyCore.codeEnergy());
    }

    /**
     * 反译能源核心
     *
     * @param ser
     */
    private void dserEnergyCore(SerData ser) {
        CommonPb.EnergyCore energyCore = ser.getEnergyCore();
        if (energyCore != null) {
            this.energyCore = new PEnergyCore(energyCore);
        }
    }


    /**
     * 保存数据时间
     */
    public int idelSaveTime;

    @Override
    public boolean canIdelSave() {
        int now = TimeHelper.getCurrentSecond();
        int offTime = now - getOfflineTime();
        return now - idelSaveTime > (offTime / Constant.OFFLINE_SAVE_CHANGE_PERIOD) * Constant.OFFLINE_SAVE_CHANGE_TIME;
    }

    @Override
    public boolean isOnline() {
        return isLogin;
    }

    @Override
    public int getOfflineTime() {
        return lord.getOffTime();
    }

    @Override
    public void playerLogin(int now) {
        SavePlayerOptimizeUtil.playerLogin(roleId, now);
    }

    @Override
    public void playerLogout() {
        SavePlayerOptimizeUtil.playerLogout(roleId);
    }

    @Override
    public long objectId() {
        return roleId;
    }

    @Override
    public boolean refreshImportant() {
        return false;
    }

    @Override
    public int getNextSaveTime() {
        return lastSaveTime;
    }

    @Override
    public void nextSaveTime(int nextSaveTime) {
        this.lastSaveTime = nextSaveTime;
    }


    @Override
    public boolean isImmediateSave() {
        return false;
    }

    /**
     * 启服判断三个月内登陆过的人
     *
     * @return
     */
    public boolean isThreeLogin() {
        if (account == null || account.getCreated() != 1) {
            return true;
        }
        if (lord != null && lord.getOnTime() > 0) {
            int now = TimeHelper.getCurrentSecond();
            int offTime = now - lord.getOnTime();
            return offTime > 3 * 30 * 24 * 60 * 60;
        }
        return false;
    }

    public int getCrossMineScore() {
        return crossMineScore;
    }

    public void setCrossMineScore(int crossMineScore) {
        this.crossMineScore = crossMineScore;
    }

    public int getCrossMineGet() {
        return crossMineGet;
    }

    public void setCrossMineGet(int crossMineGet) {
        this.crossMineGet = crossMineGet;
    }

    public Map<Integer, Integer> getPeakMap() {
        return peakMap;
    }

    public void setPeakMap(Map<Integer, Integer> peakMap) {
        this.peakMap = peakMap;
    }
}
