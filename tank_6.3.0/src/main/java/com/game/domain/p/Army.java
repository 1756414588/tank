package com.game.domain.p;

import com.game.constant.ScienceId;
import com.game.domain.Player;
import com.game.pb.CommonPb;
import com.game.util.PbHelper;

import java.util.HashMap;
import java.util.Map;

/**
 * @author
 * @ClassName: Army
 * @Description: 处于任务或战斗中的一个编队
 */
public class Army {
    private int keyId;
    private int target;
    private int state;
    private Form form;
    private int period;
    private int endTime;
    private Grab grab;
    private Collect collect;
    private int staffingTime;
    private int staffingExp;
    private boolean senior;
    private boolean occupy;
    private boolean isRuins;
    private int type;
    private int tarQua = 1;
    private int honourScore; // 获得的荣耀积分
    private int honourGold; // 获得的荣耀金币
    private int collectBeginTime; // 开始采集的时间点
    private long fight;
    private int newHeroAddGold;//新英雄采集增加金币数量
    private long caiJiStartTime;//采集开始时间 只是采集 不带行军的
    private long caiJiEndTime;//采集结束时间  只是采集 不带行军的
    private int newHeroSubGold;//新英雄采集增加金币 被掠夺数量

    /**
     * 采集后有一定时间的免战（包括军矿，时间叠加） 免战时间
     */
    private long freeWarTime;
    private long startFreeWarTime;
    private int isZhuJun;//是否是驻军的Army


    private long load;
    private boolean crossMine;

    private Map<Integer, Integer> partyScience = new HashMap<>();
    private Map<Integer, Map<Integer, Integer>> graduateInfo = new HashMap<>();


    /**
     * 判断部队中是否还有坦克
     *
     * @return
     */
    public boolean hasTank() {
        return form != null && form.hasTank();
    }

    public int getTarget() {
        return target;
    }

    public void setTarget(int target) {
        this.target = target;
    }

    public int getState() {
        return state;
    }

    public void setState(int state) {
        this.state = state;
    }

    public int getKeyId() {
        return keyId;
    }

    public void setKeyId(int keyId) {
        this.keyId = keyId;
    }

    public int getPeriod() {
        return period;
    }

    public void setPeriod(int period) {
        this.period = period;
    }

    public int getEndTime() {
        return endTime;
    }

    public void setEndTime(int endTime) {
        this.endTime = endTime;
    }

    public Form getForm() {
        return form;
    }

    public void setForm(Form form) {
        this.form = form;
    }

    public boolean isRuins() {
        return isRuins;
    }

    public void setRuins(boolean isRuins) {
        this.isRuins = isRuins;
    }

    public int getHero() {
        return form.getHero();
    }

    public int getHonourScore() {
        return honourScore;
    }

    public void setHonourScore(int honourScore) {
        this.honourScore = honourScore;
    }

    public int getNewHeroAddGold() {
        return newHeroAddGold;
    }

    public void setNewHeroAddGold(int newHeroAddGold) {
        this.newHeroAddGold = newHeroAddGold;
    }

    /**
     * @param armyPb
     */
    public Army(CommonPb.Army armyPb) {
        super();
        this.keyId = armyPb.getKeyId();
        this.target = armyPb.getTarget();
        this.state = armyPb.getState();
        this.period = armyPb.getPeriod();
        this.endTime = armyPb.getEndTime();
        this.form = PbHelper.createForm(armyPb.getForm());
        this.isRuins = armyPb.getIsRuins();
        this.tarQua = armyPb.getTarQua();
        this.type = armyPb.getType();
        this.fight = armyPb.getFight();
        this.honourScore = armyPb.getHonourScore();
        this.honourGold = armyPb.getHonourGold();
        this.collectBeginTime = armyPb.getCollectBeginTime();
        this.newHeroAddGold = armyPb.getNewHeroAddGold();
        this.caiJiStartTime = armyPb.getCaiJiStartTime();
        this.caiJiEndTime = armyPb.getCaiJiEndTime();
        this.newHeroSubGold = armyPb.getNewHeroSubGold();
        this.staffingExp = armyPb.getStaffingExp();
        this.isZhuJun = armyPb.getIsZhuJun();

        if (armyPb.hasGrab()) {
            this.grab = PbHelper.createGrab(armyPb.getGrab());
        }

        if (armyPb.hasCollect()) {
            this.collect = PbHelper.createCollect(armyPb.getCollect());
        }

        if (armyPb.hasStaffingTime()) {
            this.staffingTime = armyPb.getStaffingTime();
        }

        if (armyPb.hasSenior()) {
            this.senior = armyPb.getSenior();
        }

        if (armyPb.hasOccupy()) {
            this.occupy = armyPb.getOccupy();
        }

        this.freeWarTime = armyPb.getFreeWarTime();
        this.startFreeWarTime = armyPb.getStartFreeWarTime();

        this.load = armyPb.getLoad();
        this.crossMine = armyPb.getCrossMine();


    }

    /**
     * @param keyId
     * @param target
     * @param state
     * @param form
     * @param period
     * @param endTime
     */
    public Army(int keyId, int target, int state, Form form, int period, int endTime, boolean isRuins) {
        super();
        this.keyId = keyId;
        this.target = target;
        this.state = state;
        this.form = form;
        this.period = period;
        this.endTime = endTime;
        this.isRuins = isRuins;
    }

    public Grab getGrab() {
        return grab;
    }

    public void setGrab(Grab grab) {
        this.grab = grab;
    }

    public Collect getCollect() {
        return collect;
    }

    public void setCollect(Collect collect) {
        this.collect = collect;
    }

    public int getStaffingTime() {
        return staffingTime;
    }

    public void setStaffingTime(int staffingTime) {
        this.staffingTime = staffingTime;
    }

    public boolean getSenior() {
        return senior;
    }

    public void setSenior(boolean senior) {
        this.senior = senior;
    }

    public boolean getOccupy() {
        return occupy;
    }

    public void setOccupy(boolean occupy) {
        this.occupy = occupy;
    }

    public int getType() {
        return type;
    }

    public void setType(int type) {
        this.type = type;
    }

    public int getTarQua() {
        return tarQua;
    }

    public void setTarQua(int tarQua) {
        this.tarQua = tarQua;
    }

    public long getFight() {
        return fight;
    }

    public void setFight(long fight) {
        this.fight = fight;
    }

    public long getFreeWarTime() {
        return freeWarTime;
    }

    public void setFreeWarTime(long freeWarTime) {
        this.freeWarTime = freeWarTime;
    }

    public long getStartFreeWarTime() {
        return startFreeWarTime;
    }

    public void setStartFreeWarTime(long startFreeWarTime) {
        this.startFreeWarTime = startFreeWarTime;
    }

    public int getCollectBeginTime() {
        return collectBeginTime;
    }

    public void setCollectBeginTime(int collectBeginTime) {
        this.collectBeginTime = collectBeginTime;
    }

    public int getHonourGold() {
        return honourGold;
    }

    public void setHonourGold(int honourGold) {
        this.honourGold = honourGold;
    }

    public long getCaiJiStartTime() {
        return caiJiStartTime;
    }

    public void setCaiJiStartTime(long caiJiStartTime) {

//		LogUtil.info("采集开始时间 "+DateHelper.formatDateTime(new Date(caiJiStartTime),"yyyy-MM-dd HH:mm:ss"));

        this.caiJiStartTime = caiJiStartTime;
    }

    public long getCaiJiEndTime() {
        return caiJiEndTime;
    }

    public void setCaiJiEndTime(long caiJiEndTime) {

//		LogUtil.info("采集结束时间 "+DateHelper.formatDateTime(new Date(caiJiEndTime),"yyyy-MM-dd HH:mm:ss"));

        this.caiJiEndTime = caiJiEndTime;
    }

    public int getNewHeroSubGold() {
        return newHeroSubGold;
    }

    public void setNewHeroSubGold(int newHeroSubGold) {
        this.newHeroSubGold = newHeroSubGold;
    }

    public int getStaffingExp() {
        return staffingExp;
    }

    public void setStaffingExp(int staffingExp) {
        this.staffingExp = staffingExp;
    }

    public int getIsZhuJun() {
        return isZhuJun;
    }

    public void setIsZhuJun(int isZhuJun) {
        this.isZhuJun = isZhuJun;
    }

    public Player player;


    public long getLoad() {
        return load;
    }

    public void setLoad(long load) {
        this.load = load;
    }

    public boolean isCrossMine() {
        return crossMine;
    }

    public void setCrossMine(boolean crossMine) {
        this.crossMine = crossMine;
    }

    public Map<Integer, Integer> getPartyScience() {
        return partyScience;
    }

    public void setPartyScience(Map<Integer, Integer> partyScience) {
        this.partyScience = partyScience;
    }

    public Map<Integer, Map<Integer, Integer>> getGraduateInfo() {
        return graduateInfo;
    }

    public void setGraduateInfo(Map<Integer, Map<Integer, Integer>> graduateInfo) {
        this.graduateInfo = graduateInfo;
    }

    /**
     * 只有跨服军矿会用到,主要用于算载重
     */
    public void flushPartySenc(Map<Integer, PartyScience> sciences, Map<Integer, Map<Integer, Integer>> graduateInfo) {
        if (sciences != null) {
            PartyScience science = sciences.get(ScienceId.PAY_LOAD);
            if (science != null) {
                this.partyScience.put(ScienceId.PAY_LOAD, science.getScienceLv());
            }
            PartyScience science215 = sciences.get(ScienceId.PAY_LOAD_215);
            if (science215 != null) {
                this.partyScience.put(ScienceId.PAY_LOAD_215, science215.getScienceLv());
            }
        }
        if (graduateInfo != null) {
            for (Map.Entry<Integer, Map<Integer, Integer>> integerMapEntry : graduateInfo.entrySet()) {
                Map<Integer, Integer> integerIntegerMap1 = this.graduateInfo.get(integerMapEntry.getKey());
                if (integerIntegerMap1 == null) {
                    integerIntegerMap1 = new HashMap<>();
                    this.graduateInfo.put(integerMapEntry.getKey(), integerIntegerMap1);
                }
                Map<Integer, Integer> value = integerMapEntry.getValue();
                for (Map.Entry<Integer, Integer> integerIntegerEntry : value.entrySet()) {
                    integerIntegerMap1.put(integerIntegerEntry.getKey(), integerIntegerEntry.getValue());
                }
            }
        }
    }
}
