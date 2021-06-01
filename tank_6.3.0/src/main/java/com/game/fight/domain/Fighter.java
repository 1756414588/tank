/**
 * @Title: Fighter.java
 * @Package com.game.fight.domain
 * @Description:
 * @author ZhangJun
 * @date 2015年8月28日 下午4:40:26
 * @version V1.0
 */
package com.game.fight.domain;

import java.util.*;

import com.game.domain.Player;
import com.game.domain.p.Form;
import com.game.domain.s.StaticBountyEnemy;
import com.game.domain.s.StaticBountySkill;
import com.game.domain.s.StaticBuff;
import com.game.fight.FightLogic;

/**
 * @author ZhangJun
 * @ClassName: Fighter
 * @Description: 战斗单位
 * @date 2015年8月28日 下午4:40:26
 */
public class Fighter {
    // public Map<Integer, Effect> effect;
    public Force[] forces = new Force[6];
    public Fighter oppoFighter;//对方
    public int totalTank = 0;//
    public boolean isAttacker = false;
	public AttrData[] auraData = new AttrData[8];//坦克光环属性
    public Map<Integer, LinkedList<StaticBuff>> aura = new HashMap<>();
    public FightLogic fightLogic;
    public int firstValue = 0;//先手值
    public boolean boss = false;
    public long hurt = 0;
    public Map<Integer, String> awakenHeroSkill = new HashMap<>();//觉醒将领技能信息

    //战术
    public List<Integer> tactics = new ArrayList<>();

    public int immuneId = 0;

    public boolean isAltarBoss;// 记录是否是祭坛BOSS，在添加玩家伤害时做判断用

    public long fightNum;// 战力值，用于红蓝大战，判断先手

    private Map<Integer, Force> rebornforces = new HashMap<>();//重生部队


    public boolean isReborn = false;//是否已经复活

    public int type;//战斗类型

    public boolean isFighted = false;//是否已经战斗过

    public Player player; //此值不为NULL表示是Fighter对象为一个玩家的战斗对象

    public StaticBountyEnemy staticBountyEnemy;
    public StaticBountySkill staticBountySkill;


    private Form teamFrom;

    public boolean isAnxin = false;

    public int loopCounter = 0;

    public Fighter() {
        super();
    }

    public void addForce(Force force, int i) {
        forces[i - 1] = force;
        if (force != null) {
            force.fighter = this;
            totalTank += force.count;
            int type = force.staticTank.getType();
            if (auraData[type - 1] == null) {
                auraData[type - 1] = new AttrData();
            }
        }
    }

    public void addEffectAura(StaticBuff buff) {
        LinkedList<StaticBuff> group = aura.get(buff.getGroupId());
        if (group == null) {
            group = new LinkedList<>();//buff从高到低排序List
            aura.put(buff.getGroupId(), group);
        }

        int i = 0;
        boolean add = false;
        int value = Math.abs(buff.getEffectValue());
        Iterator<StaticBuff> it = group.iterator();
        //判断此buff是否至少大于加成最小的光环buff, 成立则将此buff加入buff列表
        while (it.hasNext()) {
            StaticBuff staticBuff = (StaticBuff) it.next();
            if (value > Math.abs(staticBuff.getEffectValue())) {
                group.add(i, buff);
                add = true;
                break;
            }
            i++;
        }
        if (!add) {
            group.addLast(buff);
        }
        if (i == 0) {//更新buff
            if (group.size() > 1) {
                subAuraAttr(group.get(1));
            }
            addAuraAttr(group.peekFirst());
        }
    }

    public void delEffectAura(StaticBuff buff) {
        LinkedList<StaticBuff> group = aura.get(buff.getGroupId());
        if (group == null || group.isEmpty()) return;
        int i = 0;
        boolean isDel = false;
        Iterator<StaticBuff> it = group.iterator();
        while (it.hasNext()) {
            StaticBuff staticBuff = (StaticBuff) it.next();
            if (buff.getBuffId() == staticBuff.getBuffId()) {
                it.remove();
                isDel = true;
                break;
            }
            i++;
        }
        if (isDel && i == 0) {//更新buff
            group.pollFirst();
            subAuraAttr(buff);

            StaticBuff next = group.peekFirst();
            if (next != null) {
                addAuraAttr(next);
            }
        }
    }

    public void effectAura() {
        Iterator<LinkedList<StaticBuff>> it = aura.values().iterator();
        while (it.hasNext()) {
            LinkedList<StaticBuff> list = it.next();
            // LogUtil.info("effectAura list size:" + list.size());
            addAuraAttr(list.peekFirst());
        }
    }

    public void addAura(StaticBuff buff) {
        LinkedList<StaticBuff> group = aura.get(buff.getGroupId());
        if (group == null) {
            group = new LinkedList<>();//buff从高到低排序List
            aura.put(buff.getGroupId(), group);
        }

        int i = 0;
        boolean add = false;
        int value = Math.abs(buff.getEffectValue());
        Iterator<StaticBuff> it = group.iterator();
        while (it.hasNext()) {
            StaticBuff staticBuff = (StaticBuff) it.next();
            if (value > Math.abs(staticBuff.getEffectValue())) {
                group.add(i, buff);
                add = true;
                break;
            }
            i++;
        }

        if (!add) {
            group.addLast(buff);
        }
    }

    public void removeAura(StaticBuff buff) {
        delEffectAura(buff);
    }

    private void addAuraData(int type, StaticBuff buff) {
        if (auraData[type - 1] != null) {
            auraData[type - 1].addValue(buff.getEffectType(), buff.getEffectValue());
        }
    }

    private void subAuraData(int type, StaticBuff buff) {
        if (auraData[type - 1] != null) {
            auraData[type - 1].addValue(buff.getEffectType(), -buff.getEffectValue());
        }
    }

    public void addAuraAttr(StaticBuff buff) {
        int target = buff.getTarget();
        if (target == 0) {
            addAuraData(1, buff);
            addAuraData(2, buff);
            addAuraData(3, buff);
            addAuraData(4, buff);
        } else {
            addAuraData(target, buff);
        }
    }

    private void subAuraAttr(StaticBuff buff) {
        int target = buff.getTarget();
        if (target == 0) {
            subAuraData(1, buff);
            subAuraData(2, buff);
            subAuraData(3, buff);
            subAuraData(4, buff);
        } else {
            subAuraData(target, buff);
        }
    }

    public void changeGod() {
        for (Force force : forces) {
            if (force != null) {
                if (force.alive()) {
                    force.god = false;
                    break;
                }
            }
        }
    }

    public boolean alive() {
        for (Force force : forces) {
            if (force != null) {
                if (force.alive()) {
                    return true;
                }
            }
        }
        return false;
    }

    public boolean isPlayerFigher() {
        return player != null;
    }

    public StaticBountyEnemy getStaticBountyEnemy() {
        return staticBountyEnemy;
    }

    public void setStaticBountyEnemy(StaticBountyEnemy staticBountyEnemy) {
        this.staticBountyEnemy = staticBountyEnemy;
    }

    public StaticBountySkill getStaticBountySkill() {
        return staticBountySkill;
    }

    public void setStaticBountySkill(StaticBountySkill staticBountySkill) {
        this.staticBountySkill = staticBountySkill;
    }

    public Map<Integer, Force> getRebornforces() {
        return rebornforces;
    }

    public void setRebornforces(Map<Integer, Force> rebornforces) {
        this.rebornforces = rebornforces;
    }

//    public Form getTeamFrom() {
//        Form form = new Form(teamFrom);
//        Force[] forces = this.forces;
//        for (Force f : forces) {
//            if (f != null) {
//
//                //损兵
//                if (f.killed > 0) {
//                    if (form.c[f.pos - 1] - f.killed >= 0) {
//                        form.c[f.pos - 1] = form.c[f.pos - 1] - f.killed;
//                    }
//                }
//
//            }
//        }
//        return form;
//    }
    public Form getTeamFrom() {
        return  teamFrom;
    }
    public void setTeamFrom(Form teamFrom) {
        this.teamFrom = teamFrom;
    }
}
