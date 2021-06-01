package com.game.domain.p;

import java.util.HashMap;
import java.util.Map;

/**
 * @author GuiJie
 * @description 描述
 * @created 2018/05/28 15:41
 */
public class TeamTask {

    private boolean isOpen;

    private Map<Integer,Long> taskInfo = new HashMap<>();

    public Map<Integer, Long> getTaskInfo() {
        return taskInfo;
    }

    public void setTaskInfo(Map<Integer, Long> taskInfo) {
        this.taskInfo = taskInfo;
    }

    public boolean isOpen() {
        return isOpen;
    }

    public void setOpen(boolean open) {
        isOpen = open;
    }
}
