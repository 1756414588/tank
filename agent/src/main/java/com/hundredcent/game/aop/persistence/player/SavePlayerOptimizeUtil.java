package com.hundredcent.game.aop.persistence.player;

import com.hundredcent.game.aop.GameClassFileTransformer;
import com.hundredcent.game.util.AgentLogUtil;

/**
 * 数据保存优化工具类，该类中的方法将被嵌入到指定的方法中
 */
public class SavePlayerOptimizeUtil {

    private SavePlayerOptimizeUtil() {
    }

    private static boolean inited;

    private static AbstractSavePlayerTask saveTask;

    /**
     * ClassFileTransformer的总入口，放在这里操作不合适，这里作首次线上测试的开关功能，测试通过后可以删除
     */
    private static GameClassFileTransformer mainTransformer;

    public static void setMainTransformer(GameClassFileTransformer mainTransformer) {
        SavePlayerOptimizeUtil.mainTransformer = mainTransformer;
    }

    public static void setMainSwith(boolean open) {

        if( mainTransformer != null ){
            mainTransformer.setMainSwitch(open);
        }

    }

    public static void setSaveTask(AbstractSavePlayerTask task) {
        SavePlayerOptimizeUtil.saveTask = task;
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
     * 将玩家添加到立即保存队列中
     *
     * @param roleId
     */
    public static void immediateSavePlayer(Long roleId) {
        if (null != roleId && checkSaveTask()) {
            saveTask.addAdvanceSave(roleId.longValue());
        }
    }

    /**
     * 将玩家添加到立即保存队列中
     *
     * @param roleId
     */
    public static void immediateSavePlayer(long roleId) {
        if (checkSaveTask()) {
            saveTask.addAdvanceSave(roleId);
        }
    }

    /**
     * 将玩家添加到闲时保存队列中
     *
     * @param roleId
     */
    public static void idleSavePlayer(Long roleId, String methodName) {
        if (null != roleId && checkSaveTask()) {
           if( saveTask.addIdleSave(roleId.longValue())){
             //  AgentLogUtil.agent(methodName);
           }
        }
    }

    /**
     * 将玩家添加到闲时保存队列中
     *
     * @param roleId
     */
    public static void idleSavePlayer(long roleId, String methodName) {
        if (inited &&checkSaveTask()) {
            if(saveTask.addIdleSave(roleId)){
              //  AgentLogUtil.agent(methodName);
            }
        }
    }

    public static void playerLogin(long roleId, int now) {
        if ( checkSaveTask()) {
            saveTask.updateSaveTimeOnLogin(roleId, now);
        }
    }

    /**
     * 玩家离线处理
     *
     * @param roleId
     */
    public static void playerLogout(long roleId) {
        if ( checkSaveTask()) {
            saveTask.addAdvanceSave(roleId);
        }
    }
}
