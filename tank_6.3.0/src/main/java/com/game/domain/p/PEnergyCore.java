package com.game.domain.p;

import com.game.pb.CommonPb;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * @author yeding
 * @create 2019/3/25 14:51
 */
public class PEnergyCore {

    /**
     * 当前处于等级
     */
    private int level;

    /**
     * 当前处于阶段
     */
    private int section;

    /**
     * 当前经验
     */
    private int exp;

    /**
     * 判断处于当前等级的第五个阶段是否完成(0.未完成 1.完成)
     */
    private int state;

    private Map<Integer, Integer> attMap = new HashMap<>();

    /**
     * 冗余经验
     */
    private int redExp;

    public PEnergyCore() {
        level = 1;
        section = 1;
        exp = 0;
        state = 0;
        redExp = 0;
    }

    public void resetCore() {
        this.level++;
        this.exp = 0;
        this.state = 0;
        this.section = 1;
    }

    public PEnergyCore(CommonPb.EnergyCore energy) {
        this.level = energy.getLevel();
        this.section = energy.getSection();
        this.exp = energy.getExp();
        this.state = energy.getState();
        List<CommonPb.TwoInt> list = energy.getAttMapList();
        if (list != null) {
            for (CommonPb.TwoInt twoInt : list) {
                attMap.put(twoInt.getV1(), twoInt.getV2());
            }
        }
        this.redExp = energy.getRedExp();
        if (level == 0) {
            level = 1;
            section = 1;
        }
    }

    public CommonPb.EnergyCore codeEnergy() {
        CommonPb.EnergyCore.Builder energy = CommonPb.EnergyCore.newBuilder();
        energy.setLevel(level);
        energy.setSection(section);
        energy.setExp(exp);
        energy.setState(state);
        for (Map.Entry<Integer, Integer> entry : attMap.entrySet()) {
            CommonPb.TwoInt.Builder newInt = CommonPb.TwoInt.newBuilder();
            newInt.setV1(entry.getKey());
            newInt.setV2(entry.getValue());
            energy.addAttMap(newInt);
        }
        energy.setRedExp(redExp);
        return energy.build();
    }

    public int getLevel() {
        return level;
    }

    public void setLevel(int level) {
        this.level = level;
    }

    public int getSection() {
        return section;
    }

    public void setSection(int section) {
        this.section = section;
    }

    public int getExp() {
        return exp;
    }

    public void setExp(int exp) {
        this.exp = exp;
    }

    public int getState() {
        return state;
    }

    public void setState(int state) {
        this.state = state;
    }

    public Map<Integer, Integer> getAttMap() {
        return attMap;
    }

    public void setAttMap(Map<Integer, Integer> attMap) {
        this.attMap = attMap;
    }

    public int getRedExp() {
        return redExp;
    }

    public void setRedExp(int redExp) {
        this.redExp = redExp;
    }

    public void addAttr(int type, int count) {
        Integer to = attMap.get(type);
        if (to == null) {
            attMap.put(type, count);
        } else {
            attMap.put(type, to + count);
        }
    }

    @Override
    public String toString() {
        return "EnergyCore{" +
                "level=" + level +
                ", section=" + section +
                ", exp=" + exp +
                '}';
    }
}
