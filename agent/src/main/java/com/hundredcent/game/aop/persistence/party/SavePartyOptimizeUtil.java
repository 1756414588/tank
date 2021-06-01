package com.hundredcent.game.aop.persistence.party;

import com.hundredcent.game.util.AgentLogUtil;

/**
 * 数据保存优化工具类，该类中的方法将被嵌入到指定的方法中
 * 
 * @author dwy
 */
public class SavePartyOptimizeUtil {

    private SavePartyOptimizeUtil() {
    }

    private static boolean inited;

    private static AbstractSavePartyTask saveTask;

    public static void setSaveTask(AbstractSavePartyTask task) {
        SavePartyOptimizeUtil.saveTask = task;
    }

    public static void gameInited() {
        inited = true;
    }

    public static boolean hasInited() {
        return inited;
    }

    public static boolean checkSaveTask() {
        if (null == saveTask) {
            AgentLogUtil.error("没有检测到 AbstractSaveTask 的具体实现类，必须在项目中实现该类");
            return false;
        }
        return true;
    }

    /**
     * 将军团添加到立即保存队列中
     *
     * @param roleId
     */
    public static void immediateSaveParty(int partyId) {
        if (checkSaveTask()) {
            saveTask.addAdvanceSave((long) partyId);
        }
    }

}
