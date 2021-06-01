package com.game.domain.s;

import java.util.List;
import java.util.Map;

/**
 * @author zhangdh
 * @ClassName: StaticSecretWeaponSkill
 * @Description: 秘密武器栏位属性配置
 * @date 2017-11-13 18:56
 */
public class StaticSecretWeaponSkill {
    private int sid;
    private int pos;
    private List<Integer> attr;
    private Map<Integer, Integer> weight;

    public int getSid() {
        return sid;
    }

    public void setSid(int sid) {
        this.sid = sid;
    }

    public int getPos() {
        return pos;
    }

    public void setPos(int pos) {
        this.pos = pos;
    }

    public List<Integer> getAttr() {
        return attr;
    }

    public void setAttr(List<Integer> attr) {
        this.attr = attr;
    }

    public Map<Integer, Integer> getWeight() {
        return weight;
    }

    public void setWeight(Map<Integer, Integer> weight) {
        this.weight = weight;
    }
}
