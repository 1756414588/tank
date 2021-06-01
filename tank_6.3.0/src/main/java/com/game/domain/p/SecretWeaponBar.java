package com.game.domain.p;

/**
 * @author zhangdh
 * @ClassName: SecretWeaponBar
 * @Description:秘密武器栏位
 * @date 2017-11-14 11:20
 */
public class SecretWeaponBar {
//    //技能栏位置[0,max]
//    private int idx;
    //技能ID
    private int sid;
    //锁定状态, true-锁定
    private boolean lock;

    public SecretWeaponBar(int sid){
        this.sid = sid;
    }

    public int getSid() {
        return sid;
    }

    public void setSid(int sid) {
        this.sid = sid;
    }

    public boolean isLock() {
        return lock;
    }

    public void setLock(boolean lock) {
        this.lock = lock;
    }
}
