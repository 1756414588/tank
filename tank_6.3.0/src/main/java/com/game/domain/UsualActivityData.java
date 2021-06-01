package com.game.domain;

import com.game.constant.ActivityConst;
import com.game.domain.p.*;
import com.game.domain.sort.ActRedBag;
import com.game.pb.CommonPb;
import com.game.pb.SerializePb.*;
import com.game.util.PbHelper;
import com.google.protobuf.InvalidProtocolBufferException;

import java.util.*;
import java.util.Map.Entry;

/**
 * @author ChenKui
 * @version 创建时间：2015-11-25 下午3:01:57
 * @declare 服务器活动
 */

public class UsualActivityData extends Activity {

    private int goal;// 全服活动值记录
    private String params;// 不定参数
    private int lastSaveTime;// 最终更新的时间
    private int sortord = ActivityConst.DESC;// 默认排序方式倒序
    private Object object = new Object();

    // 军团排名榜单
    private LinkedList<ActPartyRank> partyRanks = new LinkedList<>();
    private Map<Integer, Long> partyRankMap = new HashMap<>();

    // 玩家排行榜{类别:榜单}
    private Map<Integer, LinkedList<ActPlayerRank>> ranks = new HashMap<>();

    private ActBoss actBoss = new ActBoss();

    private ActRebel actRebel = new ActRebel();

    //玩家活动红包信息
    private TreeMap<Integer, ActRedBag> redBags = new TreeMap<>();

    //广播消息注意:此对象不存库 0-玩家昵称,1-道具type,2-道具ID,3-道具数量
    private List<String[]> broadcast = new LinkedList<>();

    public Map<Integer, LinkedList<ActPlayerRank>> getRanks() {
        return ranks;
    }

    public UsualActivityData(ActivityBase activityBase, int begin) {
        super(activityBase, begin);
    }

    public UsualActivityData(UsualActivity usualActivity) throws InvalidProtocolBufferException {
        this.setActivityId(usualActivity.getActivityId());
        this.setBeginTime(usualActivity.getActivityTime());
        this.setEndTime(usualActivity.getRecordTime());
        this.goal = usualActivity.getGoal();
        this.sortord = usualActivity.getSortord();
        this.params = usualActivity.getParams();
        this.setStatusMap(dserTwoIntMap(usualActivity.getStatusMap()));
        this.setSaveMap(dserTwoIntMap(usualActivity.getSaveMap()));
        this.setStatusList(new ArrayList<Long>());
        dserPlayerRank(usualActivity.getPlayerRank());
        dserPartyRank(usualActivity.getPartyRank());
        dserAddtion(usualActivity.getAddtion());
        dserActBoss(usualActivity.getActBoss());
        dserActRebel(usualActivity.getActRebel());
        dserUsualData(usualActivity.getUsualData());
    }

    public int getGoal() {
        return goal;
    }

    public void setGoal(int goal) {
        this.goal = goal;
    }

    public int getSortord() {
        return sortord;
    }

    public String getParams() {
        return params;
    }

    public void setParams(String params) {
        this.params = params;
    }

    public int getLastSaveTime() {
        return lastSaveTime;
    }

    public void setLastSaveTime(int lastSaveTime) {
        this.lastSaveTime = lastSaveTime;
    }

    public Map<Integer, Long> getPartyRankMap() {
        return partyRankMap;
    }

    public LinkedList<ActPlayerRank> getPlayerRanks(int type) {
        // 如果没有刷新则刷新数据
        LinkedList<ActPlayerRank> playerRanks = ranks.get(type);
        if (playerRanks == null) {
            synchronized (object) {
                playerRanks = new LinkedList<ActPlayerRank>();
                ranks.put(type, playerRanks);
            }
        }
        return playerRanks;
    }

    public Long getPartyScore(int partyId) {
        return this.partyRankMap.get(partyId);
    }

    public LinkedList<ActPartyRank> getPartyRanks() {
        return this.partyRanks;
    }

    public ActBoss getActBoss() {
        return actBoss;
    }

    public ActRebel getActRebel() {
        return actRebel;
    }

    public List<String[]> getBroadcast() {
        return broadcast;
    }

    public TreeMap<Integer, ActRedBag> getRedBags() {
        return redBags;
    }

    /**
     * 获取玩家排名
     *
     * @param type默认0
     * @param lordId
     * @return
     */
    public ActPlayerRank getPlayerRank(int type, long lordId) {
        LinkedList<ActPlayerRank> playerRanks = getPlayerRanks(type);
        if (playerRanks.size() == 0) {
            return null;
        }
        int rank = 1;
        Iterator<ActPlayerRank> it = playerRanks.iterator();
        while (it.hasNext()) {
            ActPlayerRank next = it.next();
            if (next.getLordId() == lordId) {
                next.setRank(rank);
                return next;
            }
            rank++;
        }
        return null;
    }

    /**
     * 取军团排名
     *
     * @param type默认0
     * @param lordId
     * @return
     */
    public ActPartyRank getPartyRank(int partyId) {
        if (this.partyRanks.size() == 0) {
            return null;
        }
        int rank = 1;
        Iterator<ActPartyRank> it = this.partyRanks.iterator();
        while (it.hasNext()) {
            ActPartyRank next = it.next();
            if (next.getPartyId() == partyId) {
                next.setRank(rank);
                return next;
            }
            rank++;
        }
        return null;
    }

    public LinkedList<ActPlayerRank> getPlayerRankList(int type, int page) {
        LinkedList<ActPlayerRank> rs = new LinkedList<ActPlayerRank>();
        LinkedList<ActPlayerRank> playerRanks = getPlayerRanks(type);
        if (playerRanks.size() == 0) {
            return rs;
        }
        int[] pages = {page * 20, (page + 1) * 20};
        Iterator<ActPlayerRank> it = playerRanks.iterator();
        int count = 0;
        while (it.hasNext()) {
            ActPlayerRank next = it.next();
            if (count >= pages[0]) {
                rs.add(next);
            }
            if (++count >= pages[1]) {
                break;
            }
        }
        return rs;
    }

    @Override
    public boolean isReset(int begin) {
        boolean flag = super.isReset(begin);
        if (flag) {
            this.goal = 0;
            this.partyRanks.clear();
            this.partyRankMap.clear();
            this.params = "";
            Iterator<LinkedList<ActPlayerRank>> it = this.ranks.values().iterator();
            while (it.hasNext()) {
                LinkedList<ActPlayerRank> next = it.next();
                next.clear();
            }
            this.actBoss = new ActBoss();
            this.actRebel = new ActRebel();
            this.broadcast.clear();
            this.redBags.clear();
        }
        return flag;
    }

    public byte[] serPlayerRank() {
        SerActPlayerRank.Builder ser = SerActPlayerRank.newBuilder();
        Iterator<LinkedList<ActPlayerRank>> it = this.ranks.values().iterator();
        while (it.hasNext()) {
            LinkedList<ActPlayerRank> playerRanks = it.next();
            for (ActPlayerRank playRank : playerRanks) {
                ser.addActPlayerRank(PbHelper.createActPlayerRank(playRank));
            }
        }
        return ser.build().toByteArray();
    }

    public void dserPlayerRank(byte[] data) throws InvalidProtocolBufferException {
        if (data == null) {
            return;
        }
        SerActPlayerRank ser = SerActPlayerRank.parseFrom(data);
        List<CommonPb.ActPlayerRank> list = ser.getActPlayerRankList();
        for (CommonPb.ActPlayerRank e : list) {
            long lordId = e.getLordId();
            int type = e.getRankType();
            long value = e.getRankValue();
            // ActPlayerRank playRank = new ActPlayerRank(lordId, type, value,
            // e.getRankTime());
            // playRank.setParam(e.getParam());
            LinkedList<ActPlayerRank> playerRanks = ranks.get(type);
            if (playerRanks == null) {
                playerRanks = new LinkedList<ActPlayerRank>();
                ranks.put(type, playerRanks);
            }
            addPlayerRank(playerRanks, lordId, type, value, 0, sortord, e.getRankTime());
        }
    }

    public byte[] serPartyRank() {
        SerActPartyRank.Builder ser = SerActPartyRank.newBuilder();
        for (ActPartyRank rank : this.partyRanks) {
            ser.addActPartyRank(PbHelper.createActPartyRank(rank));
        }
        return ser.build().toByteArray();
    }

    public byte[] serActBoss() {
        SerActBoss.Builder ser = SerActBoss.newBuilder();
        ser.setState(actBoss.getState());
        ser.setEndTime(actBoss.getEndTime());
        ser.setBossBagNum(actBoss.getBossBagNum());
        ser.setCallTimes(actBoss.getCallTimes());
        ser.setLordId(actBoss.getLordId());
        ser.setBossName(actBoss.getBossName());
        ser.setBossIcon(actBoss.getBossIcon());
        for (Long id : actBoss.getJoinLordIds()) {
            ser.addJoinLordIds(id);
        }
        return ser.build().toByteArray();
    }

    public byte[] serActRebel() {
        SerActRebel.Builder ser = SerActRebel.newBuilder();
        for (ActRebelRank actRebelRank : actRebel.getRebelRank()) {
            SerActRebelRank.Builder serRank = SerActRebelRank.newBuilder();
            serRank.setLordId(actRebelRank.getLordId());
            serRank.setKillNum(actRebelRank.getKillNum());
            serRank.setScore(actRebelRank.getScore());
            serRank.setLastUpdateTime(actRebelRank.getLastUpdateTime());
            ser.addRebelRank(serRank);
        }
        return ser.build().toByteArray();
    }

    public void dserPartyRank(byte[] data) throws InvalidProtocolBufferException {
        if (data == null) {
            return;
        }
        SerActPartyRank ser = SerActPartyRank.parseFrom(data);
        List<CommonPb.ActPartyRank> list = ser.getActPartyRankList();
        for (CommonPb.ActPartyRank e : list) {
            ActPartyRank rank = new ActPartyRank();
            rank.setPartyId(e.getPartyId());
            rank.setParam(e.getParam());
            rank.setRankType(e.getRankType());
            rank.setRankValue(e.getRankValue());
            rank.setRankTime(e.getRankTime());
            for (Long lordId : e.getLordIdList()) {
                rank.getLordIds().add(lordId);
            }
            partyRanks.add(rank);
            partyRankMap.put(e.getPartyId(), e.getRankValue());
        }
    }

    public byte[] serAddtion() {
        SerTwoValue.Builder ser = SerTwoValue.newBuilder();
        Iterator<Entry<Integer, Long>> it = partyRankMap.entrySet().iterator();
        while (it.hasNext()) {
            Entry<Integer, Long> next = it.next();
            ser.addTwoValue(PbHelper.createTwoValuePb(next.getKey(), next.getValue()));
        }
        return ser.build().toByteArray();
    }

    public void dserAddtion(byte[] data) throws InvalidProtocolBufferException {
        if (data == null) {
            return;
        }
        SerTwoValue ser = SerTwoValue.parseFrom(data);
        List<CommonPb.TwoValue> list = ser.getTwoValueList();
        for (CommonPb.TwoValue e : list) {
            partyRankMap.put(e.getV1(), e.getV2());
        }
    }

    public void dserActBoss(byte[] data) throws InvalidProtocolBufferException {
        if (data == null) {
            return;
        }
        SerActBoss ser = SerActBoss.parseFrom(data);
        actBoss.setState(ser.getState());
        actBoss.setEndTime(ser.getEndTime());
        actBoss.setBossBagNum(ser.getBossBagNum());
        actBoss.setCallTimes(ser.getCallTimes());
        actBoss.setLordId(ser.getLordId());
        actBoss.setBossName(ser.getBossName());
        actBoss.setBossIcon(ser.getBossIcon());
        Set<Long> joinLordIds = new HashSet<>();
        for (Long id : ser.getJoinLordIdsList()) {
            joinLordIds.add(id);
        }
        actBoss.setJoinLordIds(joinLordIds);
    }

    public void dserActRebel(byte[] data) throws InvalidProtocolBufferException {
        if (data == null) {
            return;
        }
        SerActRebel ser = SerActRebel.parseFrom(data);
        for (SerActRebelRank sarr : ser.getRebelRankList()) {
            ActRebelRank s = new ActRebelRank(sarr);
            if (actRebel.getRebelRankLordIdMap().containsKey(s.getLordId())) {
                continue;//以前产生了错误数据
            }
            actRebel.getRebelRankLordIdMap().put(s.getLordId(), s);
            actRebel.getRebelRank().add(s);
        }
    }

    public Map<Integer, Integer> dserTwoIntMap(byte[] data) throws InvalidProtocolBufferException {
        Map<Integer, Integer> twoIntMap = new HashMap<>();
        if (data != null && data.length > 0) {
            TwoIntMap map = TwoIntMap.parseFrom(data);
            for (CommonPb.TwoInt twoInt : map.getVList()) {
                twoIntMap.put(twoInt.getV1(), twoInt.getV2());
            }
        }
        return twoIntMap;
    }

    public byte[] serTwoIntMap(Map<Integer, Integer> map) {
        TwoIntMap.Builder builer = TwoIntMap.newBuilder();
        for (Entry<Integer, Integer> entry : map.entrySet()) {
            CommonPb.TwoInt.Builder pbTi = CommonPb.TwoInt.newBuilder();
            pbTi.setV1(entry.getKey());
            pbTi.setV2(entry.getValue());
            builer.addV(pbTi);
        }
        return builer.build().toByteArray();
    }

    public byte[] serUsualData(){
        SerUsualData.Builder builder = SerUsualData.newBuilder();
        if (!redBags.isEmpty()){
            for (Entry<Integer, ActRedBag> entry : redBags.entrySet()) {
                builder.addRedbag(entry.getValue().paserPb());
            }
        }
        return builder.build().toByteArray();
    }

    public void dserUsualData(byte[] data) throws InvalidProtocolBufferException {
        if (data == null || data.length == 0) return;
        SerUsualData pbUsual = SerUsualData.parseFrom(data);
        if (pbUsual.getRedbagList()!=null){
            for (SerActRedBag pb : pbUsual.getRedbagList()) {
                ActRedBag arb = new ActRedBag(pb);
                redBags.put(arb.getId(), arb);
            }
        }
    }

    /**
     * 默认添加
     *
     * @param lordId
     * @param value
     * @param maxRank {前十名：则为10}
     * @param order
     */
    public void addPlayerRank(long lordId, Long value, int maxRank, int order) {
        LinkedList<ActPlayerRank> playerRanks = getPlayerRanks(ActivityConst.TYPE_DEFAULT);
        addPlayerRank(playerRanks, lordId, ActivityConst.TYPE_DEFAULT, value, maxRank, order, 0);
    }

    /**
     * @param lordId
     * @param type排行榜类型
     * @param value玩家值
     * @param maxRank   {前十名：则为10}
     * @param order
     */
    public void addPlayerRank(long lordId, int type, Long value, int maxRank, int order) {
        LinkedList<ActPlayerRank> playerRanks = getPlayerRanks(type);
        addPlayerRank(playerRanks, lordId, type, value, maxRank, order, 0);
    }

    /**
     * @param lordId
     * @param type
     * @param value
     * @param maxRank最大排名值 {前十名：则为10}
     * @param order
     * @param rankTime     上榜时间，如果传入的该值<=0，默认为当前时间
     */
    public void addPlayerRank(LinkedList<ActPlayerRank> rankList, long lordId, int type, Long value, int maxRank, int order, long rankTime) {
        long time = rankTime;
        if (time <= 0) {
            time = System.currentTimeMillis();
        }

        int size = rankList.size();
        if (size == 0) {
            rankList.add(new ActPlayerRank(lordId, type, value, time));
            return;
        } else if (maxRank != 0 && size >= maxRank) {// 排名已满,则比较最末名
            ActPlayerRank actRank = rankList.getLast();
            if (order == ActivityConst.ASC) {
                if (actRank.getRankValue() < value) {// 升序比最末名大,则不进入排名
                    return;
                }
            } else if (order == ActivityConst.DESC) {
                if (actRank.getRankValue() > value) {// 降序比最末名小,则不进入排名
                    return;
                }
            }
        }
        boolean flag = false;
        Iterator<ActPlayerRank> it = rankList.iterator();
        while (it.hasNext()) {
            ActPlayerRank next = it.next();
            if (order == ActivityConst.ASC) {
                if (next.getLordId() == lordId) {
                    if (next.getRankValue() > value) {
                        next.setRankValue(value);
                        next.setRankTime(time);// 更新排行信息时，更新上榜时间，当排行数据相同时，将通过比较最后更新时间来排行
                    }
                    flag = true;
                    break;
                }
            } else if (order == ActivityConst.DESC) {
                if (next.getLordId() == lordId) {
                    if (next.getRankValue() < value) {
                        next.setRankValue(value);
                        next.setRankTime(time);
                    }
                    flag = true;
                    break;
                }
            }
        }

        if (!flag) {// 新晋排名玩家
            rankList.add(new ActPlayerRank(lordId, type, value, time));
        }

        if (order == ActivityConst.ASC) {// 升序排序
            Collections.sort(rankList, new PlayerRankAsc());
        } else if (order == ActivityConst.DESC) {// 降序
            Collections.sort(rankList, new PlayerRankDesc());
        }

        // 将超出排名的最末名删掉
        if (maxRank != 0 && rankList.size() > maxRank) {
            rankList.removeLast();
        }
    }

    /**
     * 添加排名记录
     *
     * @param partyId
     * @param value
     * @param maxRank
     * @param order
     */
    public void addPartyRank(int partyId, long value, int maxRank, int order) {
        long rankValue = 0;
        if (this.partyRankMap.containsKey(partyId)) {
            rankValue = this.partyRankMap.get(partyId);
        }
        rankValue += value;
        this.partyRankMap.put(partyId, rankValue);
        addPartyRank(this.partyRanks, partyId, rankValue, maxRank, order, 0);
    }

    /**
     * @param rankList
     * @param partyId
     * @param type
     * @param value
     * @param maxRank
     * @param order
     * @param rankTime 上榜时间，如果传入的该值<=0，默认为当前时间
     */
    public void addPartyRank(LinkedList<ActPartyRank> rankList, int partyId, long value, int maxRank, int order, long rankTime) {
        long time = rankTime;
        if (time <= 0) {
            time = System.currentTimeMillis();
        }

        int size = rankList.size();
        if (size == 0) {
            rankList.add(new ActPartyRank(partyId, 0, value, time));
            return;
        } else if (maxRank != 0 && size >= maxRank) {// 排名已满,则比较最末名
            ActPartyRank actRank = rankList.getLast();
            if (order == ActivityConst.ASC) {
                if (actRank.getRankValue() < value) {// 升序比最末名大,则不进入排名
                    return;
                }
            } else if (order == ActivityConst.DESC) {
                if (actRank.getRankValue() > value) {// 降序比最末名小,则不进入排名
                    return;
                }
            }
        }
        boolean flag = false;
        Iterator<ActPartyRank> it = rankList.iterator();
        while (it.hasNext()) {
            ActPartyRank next = it.next();
            int nextPartyId = next.getPartyId();
            long nextRankValue = next.getRankValue();
            if (order == ActivityConst.ASC) {
                if (nextPartyId == partyId && nextRankValue >= value) {
                    next.setRankValue(value);
                    next.setRankTime(time);// 更新排行信息时，更新上榜时间，当排行数据相同时，将通过比较最后更新时间来排行
                    flag = true;
                    break;
                }
            } else if (order == ActivityConst.DESC) {
                if (nextPartyId == partyId && nextRankValue <= value) {
                    next.setRankValue(value);
                    next.setRankTime(time);
                    flag = true;
                    break;
                }
            }
        }

        if (!flag) {
            rankList.add(new ActPartyRank(partyId, 0, value, time));
        }

        if (order == ActivityConst.ASC) {// 升序排序
            Collections.sort(rankList, new PartyRankAsc());
        } else if (order == ActivityConst.DESC) {// 降序
            Collections.sort(rankList, new PartyRankDesc());
        }

        // 将超出排名的最末名删掉
        if (maxRank != 0 && rankList.size() > maxRank) {
            rankList.removeLast();
        }
    }

    public UsualActivity copyData() {
        UsualActivity entity = new UsualActivity();
        entity.setActivityId(this.getActivityId());// 活动ID
        entity.setActivityTime(this.getBeginTime());// 该活动开启时间
        entity.setRecordTime(this.getEndTime());// 记录时间
        entity.setGoal(this.goal);
        entity.setSortord(this.sortord);
        entity.setParams(this.params);
        entity.setPartyRank(serPartyRank());
        entity.setPlayerRank(serPlayerRank());
        entity.setAddtion(serAddtion());
        entity.setActBoss(serActBoss());
        entity.setActRebel(serActRebel());
        entity.setStatusMap(serTwoIntMap(getStatusMap()));
        entity.setSaveMap(serTwoIntMap(getSaveMap()));
        entity.setUsualData(serUsualData());
        return entity;
    }
}

class PlayerRankDesc implements Comparator<ActPlayerRank> {
    @Override
    public int compare(ActPlayerRank o1, ActPlayerRank o2) {
        if (o1.getRankValue() < o2.getRankValue()) {
            return 1;
        } else if (o1.getRankValue() > o2.getRankValue()) {
            return -1;
        } else {
            // if (o1.getLordId() > o2.getLordId()) {
            // return 1;
            // } else if (o1.getLordId() < o2.getLordId()) {
            // return -1;
            // }
            // 数值相等的情况下，不再比较id，比较上榜时间，先上榜排在前面
            if (o1.getRankTime() > o2.getRankTime()) {
                return 1;
            } else if (o1.getRankTime() < o2.getRankTime()) {
                return -1;
            }
        }
        return 0;
    }
}

class PlayerRankAsc implements Comparator<ActPlayerRank> {
    @Override
    public int compare(ActPlayerRank o1, ActPlayerRank o2) {
        if (o1.getRankValue() > o2.getRankValue()) {
            return 1;
        } else if (o1.getRankValue() < o2.getRankValue()) {
            return -1;
        } else {
            // if (o1.getLordId() < o2.getLordId()) {
            // return -1;
            // }
            // 数值相等的情况下，不再比较id，比较上榜时间，先上榜排在前面
            if (o1.getRankTime() > o2.getRankTime()) {
                return 1;
            } else if (o1.getRankTime() < o2.getRankTime()) {
                return -1;
            }
        }
        return 0;
    }
}

class PartyRankDesc implements Comparator<ActPartyRank> {
    @Override
    public int compare(ActPartyRank o1, ActPartyRank o2) {
        if (o1.getRankValue() < o2.getRankValue()) {
            return 1;
        } else if (o1.getRankValue() > o2.getRankValue()) {
            return -1;
        } else {
            // if (o1.getPartyId() > o2.getPartyId()) {
            // return 1;
            // } else if (o1.getPartyId() < o2.getPartyId()) {
            // return -1;
            // }
            // 数值相等的情况下，不再比较id，比较上榜时间，先上榜排在前面
            if (o1.getRankTime() > o2.getRankTime()) {
                return 1;
            } else if (o1.getRankTime() < o2.getRankTime()) {
                return -1;
            }
        }
        return 0;
    }
}

class PartyRankAsc implements Comparator<ActPartyRank> {
    @Override
    public int compare(ActPartyRank o1, ActPartyRank o2) {
        if (o1.getRankValue() > o2.getRankValue()) {
            return 1;
        } else if (o1.getRankValue() < o2.getRankValue()) {
            return -1;
        } else {
            // if (o1.getPartyId() < o2.getPartyId()) {
            // return -1;
            // }
            // 数值相等的情况下，不再比较id，比较上榜时间，先上榜排在前面
            if (o1.getRankTime() > o2.getRankTime()) {
                return 1;
            } else if (o1.getRankTime() < o2.getRankTime()) {
                return -1;
            }
        }
        return 0;
    }
}