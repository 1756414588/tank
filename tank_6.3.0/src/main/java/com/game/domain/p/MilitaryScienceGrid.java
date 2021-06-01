/**
 * @Title: MilitaryScienceGrid.java
 * @Package com.game.domain.p
 * @Description:
 * @author WanYi
 * @date 2016年5月10日 下午2:06:21
 * @version V1.0
 */
package com.game.domain.p;

/**
 * @ClassName: MilitaryScienceGrid
 * @Description: 军工科技格子状态
 * @author WanYi
 * @date 2016年5月10日 下午2:06:21
 *
 */
public class MilitaryScienceGrid {
    private int tankId;
    private int pos;
    private int status;
    private int militaryScienceId;

    public int getTankId() {
        return tankId;
    }

    public void setTankId(int tankId) {
        this.tankId = tankId;
    }

    public int getPos() {
        return pos;
    }

    public void setPos(int pos) {
        this.pos = pos;
    }

    public int getStatus() {
        return status;
    }

    public void setStatus(int status) {
        this.status = status;
    }

    public int getMilitaryScienceId() {
        return militaryScienceId;
    }

    public void setMilitaryScienceId(int militaryScienceId) {
        this.militaryScienceId = militaryScienceId;
    }

    /**
     * @param tankId
     * @param pos
     * @param status
     * @param militaryScienceId
     */
    public MilitaryScienceGrid(int tankId, int pos, int status, int militaryScienceId) {
        this.tankId = tankId;
        this.pos = pos;
        this.status = status;
        this.militaryScienceId = militaryScienceId;
    }

    @Override
    public String toString() {
        return String.format("tank id :%d, pos :%d, status :%d, militaryScienceId :%d", tankId, pos, status, militaryScienceId);
    }
}
