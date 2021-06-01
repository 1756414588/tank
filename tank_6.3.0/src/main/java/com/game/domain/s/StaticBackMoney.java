/**   
 * @Title: StaticBackMoney.java    
 * @Package com.game.domain.s    
 * @Description:   
 * @author LiuYiFan   
 * @date 2017年6月17日16:01:55    
 * @version V1.0   
 */
package com.game.domain.s;
/**
* @ClassName: StaticBackMoney 
* @Description: 玩家回归充值返利
* @author
 */
public class StaticBackMoney {
    private int keyId;
    private int backTime;
    private int day;
    private int luckey;
    
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
    public int getLuckey() {
        return luckey;
    }
    public void setLuckey(int luckey) {
        this.luckey = luckey;
    }
    
    
}
