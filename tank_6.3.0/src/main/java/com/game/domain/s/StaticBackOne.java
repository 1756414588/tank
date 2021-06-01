/**   
 * @Title: StaticBackOne.java    
 * @Package com.game.domain.s    
 * @Description:   
 * @author LiuYiFan   
 * @date 2017年6月17日16:01:55    
 * @version V1.0   
 */
package com.game.domain.s;

import java.util.List;
/**
* @ClassName: StaticBackOne 
* @Description: 玩家回归充值返利
* @author
 */
public class StaticBackOne {
    private int keyId;
    private int backTime;
    private int day;
    private List<List<Integer>> awardList;
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
    public List<List<Integer>> getAwardList() {
        return awardList;
    }
    public void setAwardList(List<List<Integer>> awardList) {
        this.awardList = awardList;
    }
    
    
}
