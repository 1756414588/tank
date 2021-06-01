package com.hundredcent.game.aop.persistence.player;

/**
 * @author ：Liu Gui Jie
 * @date ：Created in 2019/5/21 15:47
 * @description：保存player状态
 */
public class SaveConfig {


    private int index;

    /**
     * 保存时间
     */
    private long time;



    public int getIndex() {
        return index;
    }

    public void setIndex(int index) {
        this.index = index;
    }

    public long getTime() {
        return time;
    }

    public void setTime(long time) {
        this.time = time;
    }

}
