package com.game.domain.s;

import java.util.List;

/**
 * @author LiuYiFan
 * @version 创建时间：2017年9月9日15:05:31
 * @declare 新版活跃度任务（活动 
 */
public class StaticTaskLiveActivity {
    
    private int id;
    private int live;
    private List<List<Integer>> awardList;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getLive() {
        return live;
    }

    public void setLive(int live) {
        this.live = live;
    }

    public List<List<Integer>> getAwardList() {
        return awardList;
    }

    public void setAwardList(List<List<Integer>> awardList) {
        this.awardList = awardList;
    }

}
