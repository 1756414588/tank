package com.game.fight.domain;

import com.game.constant.AttrId;
import com.game.domain.s.StaticTank;

import java.util.List;

public class AttrData {
    public long hp;
    public int attack;
    public int hit;
    public int dodge;
    public int crit;
    public int critDef;
    public int impale; // 穿刺
    public int defend; // 防护
    public int hpF;
    public int attackF;
    public int injuredF; // 减伤
    public int demageF; // 增伤
    public int tenacityF; // 坚韧万分比
    public int burstF; // 爆裂万分比
    public int frighten; // 震慑
    public int fortitude; // 刚毅

    public AttrData() {
    }

    public AttrData copy() {
        AttrData att = new AttrData();
        att.hp = hp;
        att.attack = attack;
        att.hit = hit;
        att.dodge = dodge;
        att.crit = crit;
        att.critDef = critDef;
        att.impale = impale; // 穿刺
        att.defend = defend; // 防护
        att.hpF = hpF;
        att.attackF = attackF;
        att.injuredF = injuredF; // 减伤
        att.demageF = demageF; // 增伤
        att.tenacityF = tenacityF; // 坚韧万分比
        att.burstF = burstF; // 爆裂万分比
        att.frighten = frighten; // 震慑
        att.fortitude = fortitude; // 刚毅
        return att;
    }

    public AttrData(StaticTank staticTank) {
        hp = staticTank.getHp();
        attack = staticTank.getAttack();
        hit = staticTank.getHit();
        dodge = staticTank.getDodge();
        crit = staticTank.getCrit();
        critDef = staticTank.getCritDef();
        impale = staticTank.getImpale();
        defend = staticTank.getDefend();
        tenacityF = 0;
        burstF = 0;
    }

    public AttrData(List<Integer> attrs) {
        hp = attrs.get(0);
        attack = attrs.get(1);
        hit = attrs.get(2) * 10;
        dodge = attrs.get(3) * 10;
        crit = attrs.get(4) * 10;
        critDef = attrs.get(5) * 10;
        impale = attrs.get(6) * 1000;
        defend = attrs.get(7) * 1000;
        attackF = attrs.get(8);
        injuredF = attrs.get(9);
        tenacityF = 0;
        burstF = 0;
    }

    public void setAttr(List<Integer> attrs) {
        hp = attrs.get(0);
        if (hp <= 0) {
            hp = 1;
        }
        attack = attrs.get(1);
        hit = attrs.get(2) * 10;
        dodge = attrs.get(3) * 10;
        crit = attrs.get(4) * 10;
        critDef = attrs.get(5) * 10;
        impale = attrs.get(6) * 1000;
        defend = attrs.get(7) * 1000;
        attackF = attrs.get(8);
        injuredF = attrs.get(9);
        frighten = attrs.get(10);
        fortitude = attrs.get(11);
        if (attrs.size() >= 13) {
            tenacityF = attrs.get(12);
            burstF = attrs.get(13);
        }
    }

    public void addValue(int attrId, int value) {
        switch (attrId) {
            case AttrId.HP: // origin
                hp += value;
                break;
            case AttrId.HP_F: // 10000
                hpF += value;
                break;
            case AttrId.ATTACK: // orgin
                attack += value;
                break;
            case AttrId.ATTACK_F: // 10000
                attackF += value;
                break;
            case AttrId.HIT: // 1000
                hit += value;
                break;
            // case AttrId.HIT_F:// 10000
            // hitF += value;
            // break;
            case AttrId.DODGE: // 1000
                dodge += value;
                break;
            // case AttrId.DODGE_F:
            // dodgeF += value;
            // break;
            case AttrId.CRIT: // 1000
                crit += value;
                break;
            // case AttrId.CRIT_F:
            // critF += value;
            // break;
            case AttrId.CRITDEF: // 1000
                critDef += value;
                break;
            // case AttrId.CRITDEF_F:
            // critDefF += value;
            // break;
            case AttrId.IMPALE: // 1000
                impale += value;
                break;
            // case AttrId.IMPALE_F:
            // impaleF += value;
            // break;
            case AttrId.DEFEND: // 1000
                defend += value;
                break;
            // case AttrId.DEFEND_F:
            // defendF += value;
            // break;
            // case AttrId.INJURED:
            // injured += value;
            // break;
            case AttrId.INJURED_F: // 10000
                injuredF += value;
                break;
            case AttrId.TENACITY_F:
                tenacityF += value;
                break;
            case AttrId.BURST_F:
                burstF += value;
                break;
            case AttrId.CritAndCritDef_F:
                crit += value;
                critDef += value;
                break;
            case AttrId.HitAndDodge_F:
                hit += value;
                dodge += value;
                break;
            case AttrId.DEMAGE_F:
                demageF += value;
                break;
            case AttrId.ImpaAndDefend:
                impale += value;
                defend += value;
                break;
            case AttrId.FORTITUDE: // 1000
                fortitude += value;
                break;
            case AttrId.FRIGHTEN: // 1000
                frighten += value;
                break;
            default:
                break;
        }
    }

    /**
     * 是否百分比属性
     */
    public static boolean isF(int attrId) {
        boolean isF = false;
        switch (attrId) {
            case AttrId.HP: // origin
                isF = false;
                break;
            case AttrId.HP_F: // 10000
                isF = true;
                break;
            case AttrId.ATTACK: // orgin
                isF = false;
                break;
            case AttrId.ATTACK_F: // 10000
                isF = true;
                break;
            case AttrId.HIT: // 1000
                isF = false;
                break;
            // case AttrId.HIT_F:// 10000
            // isF = true;
            // break;
            case AttrId.DODGE: // 1000
                isF = false;
                break;
            // case AttrId.DODGE_F:
            // isF = true;
            // break;
            case AttrId.CRIT: // 1000
                isF = false;
                break;
            // case AttrId.CRIT_F:
            // isF = true;
            // break;
            case AttrId.CRITDEF: // 1000
                isF = false;
                break;
            // case AttrId.CRITDEF_F:
            // isF = true;
            // break;
            case AttrId.IMPALE: // 1000
                isF = false;
                break;
            // case AttrId.IMPALE_F:
            // isF = true;
            // break;
            case AttrId.DEFEND: // 1000
                isF = false;
                break;
            // case AttrId.DEFEND_F:
            // isF = true;
            // break;
            // case AttrId.INJURED:
            // isF = false;
            // break;
            case AttrId.INJURED_F: // 10000
                isF = true;
                break;
            case AttrId.TENACITY_F:
                isF = true;
                break;
            case AttrId.BURST_F:
                isF = true;
                break;
            case AttrId.CritAndCritDef_F:
                isF = true;
                break;
            case AttrId.HitAndDodge_F:
                isF = true;
                break;
            case AttrId.DEMAGE_F:
                isF = true;
                break;
            case AttrId.ImpaAndDefend:
                isF = false;
                break;
            case AttrId.FORTITUDE: // 1000
                isF = false;
                break;
            case AttrId.FRIGHTEN: // 1000
                isF = false;
                break;
            default:
                break;
        }
        return isF;
    }

    public long getValue(int attrId) {
        switch (attrId) {
            case AttrId.HP: // origin
                return hp;
            case AttrId.HP_F: // 10000
                return hpF;
            case AttrId.ATTACK: // orgin
                return attack;
            case AttrId.ATTACK_F: // 10000
                return attackF;
            case AttrId.HIT: // 1000
                return hit;
            case AttrId.DODGE: // 1000
                return dodge;
            case AttrId.CRIT: // 1000
                return crit;
            case AttrId.CRITDEF: // 1000
                return critDef;
            case AttrId.IMPALE: // 1000
                return impale;
            case AttrId.DEFEND: // 1000
                return defend;
            case AttrId.INJURED_F: // 10000
                return injuredF;
            case AttrId.TENACITY_F:
                return tenacityF;
            case AttrId.BURST_F:
                return burstF;
            case AttrId.DEMAGE_F:
                return demageF;
            case AttrId.FORTITUDE: // 1000
                return fortitude;
            case AttrId.FRIGHTEN: // 1000
                return frighten;
            default:
                break;
        }
        return 0;
    }

    public void delValue(int attrId, int value) {
        switch (attrId) {
            case AttrId.HP: // origin
                hp -= value;
                hp = hp > 0 ? hp : 0;
                break;
            case AttrId.HP_F: // 10000
                hpF -= value;
                hpF = hpF > 0 ? hpF : 0;
                break;
            case AttrId.ATTACK: // orgin
                attack -= value;
                attack = attack > 0 ? attack : 0;
                break;
            case AttrId.ATTACK_F: // 10000
                attackF -= value;
                attackF = attackF > 0 ? attackF : 0;
                break;
            case AttrId.HIT: // 1000
                hit -= value;
                hit = hit > 0 ? hit : 0;
                break;
            // case AttrId.HIT_F:// 10000
            // hitF -= value;
            // break;
            case AttrId.DODGE: // 1000
                dodge -= value;
                dodge = dodge > 0 ? dodge : 0;
                break;
            // case AttrId.DODGE_F:
            // dodgeF -= value;
            // break;
            case AttrId.CRIT: // 1000
                crit -= value;
                crit = crit > 0 ? crit : 0;
                break;
            // case AttrId.CRIT_F:
            // critF -= value;
            // break;
            case AttrId.CRITDEF: // 1000
                critDef -= value;
                critDef = critDef > 0 ? critDef : 0;
                break;
            // case AttrId.CRITDEF_F:
            // critDefF-= value;
            // break;
            case AttrId.IMPALE: // 1000
                impale -= value;
                impale = impale > 0 ? impale : 0;
                break;
            // case AttrId.IMPALE_F:
            // impaleF -= value;
            // break;
            case AttrId.DEFEND: // 1000
                defend -= value;
                defend = defend > 0 ? defend : 0;
                break;
            // case AttrId.DEFEND_F:
            // defendF -= value;
            // break;
            // case AttrId.INJURED:
            // injured -= value;
            // break;
            case AttrId.INJURED_F: // 10000
                injuredF -= value;
                injuredF = injuredF > 0 ? injuredF : 0;
                break;
            case AttrId.TENACITY_F:
                tenacityF -= value;
                tenacityF = tenacityF > 0 ? tenacityF : 0;
                break;
            case AttrId.BURST_F:
                burstF -= value;
                burstF = burstF > 0 ? burstF : 0;
                break;
            case AttrId.CritAndCritDef_F:
                crit -= value;
                crit = crit > 0 ? crit : 0;
                critDef -= value;
                critDef = critDef > 0 ? critDef : 0;
                break;
            case AttrId.HitAndDodge_F:
                hit -= value;
                hit = hit > 0 ? hit : 0;
                dodge -= value;
                dodge = dodge > 0 ? dodge : 0;
                break;
            case AttrId.DEMAGE_F:
                demageF -= value;
                demageF = demageF > 0 ? demageF : 0;
                break;
            case AttrId.ImpaAndDefend:
                impale -= value;
                impale = impale > 0 ? impale : 0;
                defend -= value;
                defend = defend > 0 ? defend : 0;
                break;
            case AttrId.FORTITUDE: // 1000
                fortitude -= value;
                fortitude = fortitude > 0 ? fortitude : 0;
                break;
            case AttrId.FRIGHTEN: // 1000
                frighten -= value;
                frighten = frighten > 0 ? frighten : 0;
                break;
            default:
                break;
        }
    }
}