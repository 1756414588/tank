package merge.v2;

import com.game.constant.SystemId;
import com.game.dao.impl.s.StaticDataDao;
import com.game.domain.Player;
import com.game.domain.p.*;
import com.game.domain.s.StaticAirship;
import com.game.domain.s.StaticMine;
import com.game.domain.s.StaticSlot;
import com.game.domain.s.StaticSystem;
import com.game.manager.WorldDataManager;
import com.game.util.*;
import merge.MServer;
import merge.MyBatisM;

import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentSkipListSet;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * @author zhangdh
 * @ClassName: MergeDataMgr
 * @Description: 合服主服的数据管理器
 * @date 2017-08-05 16:26
 */
public class MergeDataMgr {
    private final Set<String> usedLordNames = new ConcurrentSkipListSet<>();
    //已经被使用过的名字KEY:玩家名字, lordId列表
    public final AtomicInteger lidAtomic = new AtomicInteger();

    //已经使用过的军团名字
    private final Set<String> usedPartysNames = new ConcurrentSkipListSet<>();
    private final AtomicInteger pidAtomic = new AtomicInteger();

    //在处理军团时记录所有的军团长
    private final Set<Long> legatus = new ConcurrentSkipListSet<>();

    //记录服务器中竞技场数据KEY:服务器ID,VALUE服务器中竞技场玩家列表
    private final Map<Integer, List<Arena>> arenaMap = new ConcurrentHashMap<>();

    // 世界地图上的玩家
    private Map<Integer, Long> posMap = new HashMap<>();
    // 空余的位置信息
    private final Set<Integer> freePostSet = new HashSet<>();
    //区块信息
    private List<StaticSlot> slots;
    //世界地图矿点信息
    private Map<Integer, StaticMine> mineMap;
    //世界地图飞艇信息
    private Map<Integer, StaticAirship> airshipMap;
    //无效的地图位置
    static final Set<Integer> invalidPos = new HashSet<>();
    //合服给玩家一个8小时候的罩子
    public static int BUFF_FREE_TIME_BY_MERGE = TimeHelper.HOUR_S * 8;
    //小号玩家的等级
    public static int SMALL_LORD_LEVEL = 10;

    //合服服务器的DAO
    private MyBatisM masterDao;

    public MergeDataMgr(MServer iniDb, MServer master) {
        try {
            this.masterDao = master.myBatisM;
            MyBatisM initDao = null;

            initDao = new MyBatisM(iniDb.getDbUrl(), iniDb.getUser(), iniDb.getPwd());

            StaticDataDao staticDataDao = new StaticDataDao();
            staticDataDao.setSqlSessionFactory(initDao.getSqlSessionFactory());

            this.airshipMap = staticDataDao.selectStaticAirshipMap();
            LogUtil.error("Airship Map size :" + airshipMap.size());
            this.mineMap = staticDataDao.selectMine();
            LogUtil.error("Mine Map size :" + mineMap.size());
            this.slots = staticDataDao.selectSlot();
            LogUtil.error("Slots size :" + slots.size());

            Map<Integer, StaticSystem> staticSystemMap = staticDataDao.selectSystemMap();
            BUFF_FREE_TIME_BY_MERGE = Integer.valueOf(staticSystemMap.get(SystemId.MERGE_GAME_BUFF_FREE_TIME).getValue());

            caluFreePostList();
        } catch (Exception e) {
            LogUtil.error(e);
            System.exit(-1);
        }
    }

    static {
        invalidPos.add(298 + 298 * 600);
        invalidPos.add(299 + 298 * 600);
        invalidPos.add(300 + 298 * 600);

        invalidPos.add(298 + 299 * 600);
        invalidPos.add(299 + 299 * 600);
        invalidPos.add(300 + 299 * 600);

        invalidPos.add(298 + 300 * 600);
        invalidPos.add(299 + 300 * 600);
        invalidPos.add(300 + 300 * 600);
    }

    /**
     * 计算空余位置list后并混乱
     */
    public void caluFreePostList() {
        //将飞艇坐标添加到无效坐标中
        Set<Integer> airshipPos = calcAirshipPos();
        if (!airshipPos.isEmpty()) {
            invalidPos.addAll(airshipPos);
        }
        List<Integer> freePostList = new ArrayList<>();
        for (int pos = 1; pos < 360000; pos++) {
            if (!posMap.containsKey(pos)//没有玩家
                    && evaluatePos(pos) == null//不是矿点坐标
                    && isValidPos(pos)) {//不是无效坐标
                freePostList.add(pos);
            }
        }

        //混乱坐标
        Collections.shuffle(freePostList);
        freePostSet.addAll(freePostList);
        LogUtil.error(String.format("world free post size :%d", freePostSet.size()));
    }

    /**
     * 计算飞艇坐标
     *
     * @return
     */
    private Set<Integer> calcAirshipPos() {
        Set<Integer> posSet = new HashSet<>();
        //飞艇的删除
        for (StaticAirship sap : airshipMap.values()) {
            Tuple<Integer, Integer> t = MapHelper.reducePos(sap.getPos());
            int[] xy = new int[]{t.getA(), t.getB()};
            int x = 0;
            int y = 0;
            //一个飞艇占用四个点
            for (int i = 1; i <= 4; i++) {
                switch (i) {
                    case 1:
                        x = xy[0];
                        y = xy[1];
                        break;
                    case 2:
                        x = xy[0] + 1;
                        y = xy[1];
                        break;
                    case 3:
                        x = xy[0];
                        y = xy[1] + 1;
                        break;
                    case 4:
                        x = xy[0] + 1;
                        y = xy[1] + 1;
                        break;
                }
                Integer pos = WorldDataManager.pos(x, y);
                posSet.add(pos);
            }
        }
        return posSet;
    }

    public void putPlayer(Player player) {
        int pos = player.lord.getPos();
        if (pos != -1) {
            posMap.put(pos, player.lord.getLordId());
            freePostSet.remove(pos);
        }
    }

    public int area(int pos) {
        Tuple<Integer, Integer> xy = reducePos(pos);
        return xy.getA() / 15 + xy.getB() / 15 * 40;
    }

    static public Tuple<Integer, Integer> reducePos(int pos) {
        return new Tuple<>(pos % 600, pos / 600);
    }

    public StaticMine evaluatePos(int pos) {
        Tuple<Integer, Integer> xy = reducePos(pos);
        int x = xy.getA();
        int y = xy.getB();
        int index = x / 40 + y / 40 * 15;
        int reflection = (x % 40 + y % 40 * 40 + 13 * index) % 1600;
        return getMine(reflection);
    }

    public StaticMine getMine(int pos) {
        return mineMap.get(pos);
    }

    public int getSlot(int playerNumber) {
        int index = playerNumber / 400;
        if (index > 199) {
            return RandomHelper.randomInSize(400);
        } else {
            StaticSlot staticSlot = slots.get(index);
            if (playerNumber % 2 == 0) {
                return staticSlot.getSlotA();
            } else {
                return staticSlot.getSlotB();
            }
        }
    }

    public boolean isValidPos(int pos) {
        return pos >= 1 && pos < 360000 && !invalidPos.contains(pos);
    }

    public void addNewPlayer(Player player) {
        synchronized (freePostSet) {
            int pos = 0;
            int slot = getSlot(posMap.size());
            int xBegin = slot % 20 * 30;
            int yBegin = slot / 20 * 30;
            for (int i = 0; i < 100; i++) {
                pos = (RandomHelper.randomInSize(30) + xBegin) + (RandomHelper.randomInSize(30) + yBegin) * 600;
                if (!posMap.containsKey(pos) && evaluatePos(pos) == null && isValidPos(pos)) {
                    break;
                }
            }
            //随机100次都没有找到有效位置则直接取第一个可用的位置给玩家
            if (pos == 0) {
                pos = freePostSet.iterator().next();
            }
            player.lord.setPos(pos);
            putPlayer(player);
            if (freePostSet.size() < 10000) {
                LogUtil.error("空闲位置不够了,请注意, 剩余:" + freePostSet.size() + ", 已分配:" + posMap.size());
            }
        }
    }

//    public void addNewPlayer(Player player) {
//        synchronized (freePostSet) {
//            int pos, slot, xBegin, yBegin;
//            int times = 0;
//            while (true) {
//                slot = getSlot(posMap.size());
//                xBegin = slot % 20 * 30;
//                yBegin = slot / 20 * 30;
//                pos = (RandomHelper.randomInSize(30) + xBegin) + (RandomHelper.randomInSize(30) + yBegin) * 600;
//                if (posMap.containsKey(pos) || evaluatePos(pos) != null || !isValidPos(pos)) {
//                    times++;
//
//                    if (times >= 100) {
//                        pos = freePostSet.iterator().next();
//
//                        if (freePostSet.size() < 10000) {
////							LogHelper.ERROR_LOGGER.error("位置不够了,请注意, 剩余:" + freePostList.size() + ", 已分配:" + posMap.size());
//                            LogUtil.error("空闲位置不够了,请注意, 剩余:" + freePostSet.size() + ", 已分配:" + posMap.size());
//                        }
//                        break;
//                    }
//                    continue;
//                }
//                break;
//            }
//
//            player.lord.setPos(pos);
//            putPlayer(player);
//        }
//    }

    /**
     * 获取玩家单服唯一名字
     *
     * @param lordName
     * @param lordId
     * @param nickSuffix
     * @param bMerge
     * @return
     */
    public String getLordUniqueName(String lordName, String nickSuffix, boolean bMerge) {
        //如果本服(Master)中到目前为止此名字未被使用过则加入已使用列表后返回
        if (usedLordNames.add(lordName)) {
            return lordName;//该名字未被使用过
        } else {
            //如果包含了服务器后缀则直接处理成本服唯一
            if (lordName.contains(nickSuffix)) {
                int nickSuffixNumber = lidAtomic.incrementAndGet();
                if (bMerge) {
                    return lordName + nickSuffixNumber;
                } else {
                    //如果未合过服则带上后缀以及后缀唯一数
                    return lordName + nickSuffix + nickSuffixNumber;
                }
            } else {
                //如果名字没有服务器后缀那么也许加上服务器后缀后全服唯一了
                return getLordUniqueName(lordName + nickSuffix, nickSuffix, bMerge);
            }
        }
    }

    /**
     * 获取本服唯一的军团名字
     *
     * @param lordName
     * @param lordId
     * @param nickSuffix
     * @param bMerge
     * @return
     */
    public String getPartyUniqueName(String partyName, String nickSuffix, boolean bMerge) {
        //如果本服(Master)中到目前为止此名字未被使用过则加入已使用列表后返回
        if (usedPartysNames.add(partyName)) {
            return partyName;//该名字未被使用过
        } else {
            //如果包含了服务器后缀则直接处理成本服唯一
            if (partyName.contains(nickSuffix)) {
                int nickSuffixNumber = pidAtomic.incrementAndGet();
                if (bMerge) {
                    return partyName + nickSuffixNumber;
                } else {
                    //如果未合过服则带上后缀以及后缀唯一数
                    return partyName + nickSuffix + nickSuffixNumber;
                }
            } else {
                //如果名字没有服务器后缀那么也许加上服务器后缀后全服唯一了
                return getPartyUniqueName(partyName + nickSuffix, nickSuffix, bMerge);
            }
        }
    }

    /**
     * 记录军团长
     *
     * @param lordId
     */
    public void addLegatus(long lordId) {
        legatus.add(lordId);
    }

    /**
     * 判断玩家是否军团长
     *
     * @param lordId
     * @return
     */
    public boolean isLegatus(long lordId) {
        return legatus.contains(lordId);
    }

    /**
     * 将Slave中的有效竞技场数据保存起来
     *
     * @param serverId
     * @param arenas
     */
    public void addArena(int serverId, List<Arena> arenas) {
        arenaMap.put(serverId, arenas);
    }

    public Map<Integer, List<Arena>> getArenaMap() {
        return arenaMap;
    }

    /**
     * 将玩家数据保存到合服数据库中
     *
     * @param sid    玩家原来服务器ID
     * @param sname  服务器名字
     * @param player 玩家数据
     */
    public void saveMergePlayer(int sid, String sname, Player player, Advertisement ad, TipGuy tipGuy, List<Pay> pays, List<NewMail> newMails) {
        try {
            //此5项必须不为null
            masterDao.getLordDao().insertFullLord(player.lord);
            masterDao.getDataNewDao().insertFullData(player.serNewData());
            masterDao.getAccountDao().insertFullAccount(player.account);
            masterDao.getBuildingDao().insertBuilding(player.building);
            masterDao.getResourceDao().insertFullResource(player.resource);

            //玩家广告信息
            if (ad != null) {
                masterDao.getAdDao().insertAdvertisement(ad);
            }

            //保存举报信息
            if (tipGuy != null) {
                masterDao.getTipGuyDao().insertTipGuy(tipGuy);
            }

            //保存充值信息
            if (pays != null && !pays.isEmpty()) {
                for (Pay pay : pays) {
                    masterDao.getPayDao().createPay(pay);
                }
            }

            if (newMails != null && !newMails.isEmpty()) {
                for (NewMail newMail : newMails) {
                    masterDao.getMailDao().insertMail(newMail);
                }
            }

        } catch (Exception e) {
            LogUtil.error(String.format("save sid :%d, sname :%s,  lordId :%d, error", sid, sname, player.lord.getLordId()), e);
            LogUtil.error("================== 合服失败!!! ======================");
            System.exit(-1);
        }
    }

    public int saveParty(Party party) {
        return masterDao.getPartyDao().insertFullParty(party);
    }

    public int savePartyMember(PartyMember partyMember) {
        return masterDao.getPartyDao().insertFullPartyMember(partyMember);
    }

    public void saveArena(Arena arena) {
        masterDao.getArenaDao().insertArena(arena);
        masterDao.getArenaDao().updateArena(arena);
    }

    /**
     * 在玩家数据全部更新结束后更新军团长名字
     */
    public void updatePartyLegatusName() {
        masterDao.getPartyDao().updatePartyLegatusName();
    }

    /**
     * 清理合服需要清除的军团数据
     */
    public void clearPartyDataWithMerge() {
        masterDao.getPartyDao().clearPartyDataWithMerge();
    }

    /**
     * 统计Master服中玩家总数量
     *
     * @return
     */
    public int selectMasterLordCount() {
        return masterDao.getLordDao().selectLordCount();
    }

    public void logMergeInfo() {

    }


    public static void main(String[] args) throws InterruptedException {
        final Random random = new Random();
        final Map<String, List<String>> lordNameMap = new ConcurrentHashMap<>();
        int thread_count = 500;
        final CountDownLatch countDownLatch = new CountDownLatch(thread_count);
        for (int i = 0; i < thread_count; i++) {
            Thread thread = new Thread(new Runnable() {
                @Override
                public void run() {
                    for (int i = 1; i < 100; i++) {
                        String lordName = "lordName" + i % 10;
                        List<String> list = lordNameMap.get(lordName);
                        if (list == null) {
                            synchronized (lordNameMap) {
                                list = lordNameMap.get(lordName);
                                if (list == null) {
                                    lordNameMap.put(lordName, list = new CopyOnWriteArrayList<>());
                                } else {
                                    LogUtil.info("+++++++++++++++++++++++++++++");
                                }
                            }
                        }
                        list.add(Thread.currentThread().getName());
                    }
                    countDownLatch.countDown();
                }
            });
            thread.setName(String.valueOf(i));
            thread.start();
        }
        countDownLatch.await();
        for (Map.Entry<String, List<String>> entry : lordNameMap.entrySet()) {
            StringBuilder sb = new StringBuilder();
            System.out.print("name : " + entry.getKey() + " --->");
            LogUtil.info(Arrays.toString(entry.getValue().toArray()));
        }
    }

    public MyBatisM getMasterDao() {
        return masterDao;
    }
}
