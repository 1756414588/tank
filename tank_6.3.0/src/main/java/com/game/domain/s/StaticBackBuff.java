/**   
 * @Title: StaticBackBuff.java    
 * @Package com.game.domain.s    
 * @Description:   
 * @author LiuYiFan   
 * @date 2017年6月17日16:01:55    
 * @version V1.0   
 */
package com.game.domain.s;
/**
* @ClassName: StaticBackBuff 
* @Description: 玩家回归buff
* @author
 */
public class StaticBackBuff {
    private int keyId;
    private int backTime;
    private int day;
    private int buffId;
    private int buffTime;
    
    public int getKeyId() {
        return keyId;
    }
    public void setKeyId(int keyId) {
        this.keyId = keyId;
    }
    public int getBackTime() {
        return backTime;
    }
    public void setBackTime(int backTime) {
        this.backTime = backTime;
    }
    public int getDay() {
        return day;
    }
    public void setDay(int day) {
        this.day = day;
    }
    public int getBuffId() {
        return buffId;
    }
    public void setBuffId(int buffId) {
        this.buffId = buffId;
    }
    public int getBuffTime() {
        return buffTime;
    }
    public void setBuffTime(int buffTime) {
        this.buffTime = buffTime;
    }
    
}
