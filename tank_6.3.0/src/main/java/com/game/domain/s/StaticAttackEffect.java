package com.game.domain.s;

import java.util.Set;

/**
 * @author zhangdh
 * @ClassName: StaticAttackEffect
 * @Description: 攻击特效
 * @date 2017-11-28 14:59
 */
public class StaticAttackEffect {
    //唯一标识
    private int id;
    //兵种类型
    private int type;
    //特效组ID
    private int eid;//特效组ID
    //兵种内作用范围(坦克ID列表)
    private String scope;
    //作用坦克ID列表,如果此ids不为空
    // 则只有ids中的坦克才有攻击特效
    private Set<Integer> ids;
    //是否是默认特效
    private int isDefault;
    //解锁需要的配件等级
    private int unLockLv;


    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getType() {
        return type;
    }

    public void setType(int type) {
        this.type = type;
    }

    public String getScope() {
        return scope;
    }

    public void setScope(String scope) {
        this.scope = scope;
    }

    public Set<Integer> getIds() {
        return ids;
    }

    public void setIds(Set<Integer> ids) {
        this.ids = ids;
    }

    public int getEid() {
        return eid;
    }

    public void setEid(int eid) {
        this.eid = eid;
    }

    public int getIsDefault() {
        return isDefault;
    }

    public void setIsDefault(int isDefault) {
        this.isDefault = isDefault;
    }

    public int getUnLockLv() {
        return unLockLv;
    }

    public void setUnLockLv(int unLockLv) {
        this.unLockLv = unLockLv;
    }
}
