/**   
 * @Title: MainLogicServer.java    
 * @Package com.game.server    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年7月29日 下午7:24:35    
 * @version V1.0   
 */
package com.game.server;

import com.game.domain.UsualActivityData;
import com.game.domain.p.UsualActivity;
import com.game.manager.ActivityDataManager;
import com.game.server.thread.SaveActivityThread;
import com.game.server.thread.SaveThread;
import com.game.util.LogUtil;
import com.game.util.TimeHelper;

import java.util.Iterator;

/**
 * @ClassName: MainLogicServer
 * @Description: 一般活动数据保存服务器
 * @author ZhangJun
 * @date 2015年7月29日 下午7:24:35
 * 
 */
public class SaveUsualActivityServer extends SaveServer {

    /**
     * @param name 服务器名
     * @param threadNum 线程号
     */
    public SaveUsualActivityServer() {
        super("SAVE_ACTIVITY_SERVER", 2);
    }

    /**
     * 
     * <p>
     * Title: createThread
     * </p>
     * <p>
     * Description: 初始化 SaveActivityThread的线程
     * </p>
     * 
     * @param name 线程名
     * @return
     * @see com.game.server.SaveServer#createThread(java.lang.String)
     */
    public SaveThread createThread(String name) {
        // Auto-generated method stub

        return new SaveActivityThread(name);
    }

    /**
     * 
     * <p>
     * Title: saveData
     * </p>
     * <p>
     * Description: 保存数据方法 此方法会根据extremeId 选择一个线程来加入其保存队列
     * </p>
     * 
     * @param object
     * @see com.game.server.SaveServer#saveData(java.lang.Object)
     */
    public void saveData(Object object) {
        // Auto-generated method stub
        UsualActivity servActivity = (UsualActivity) object;
        SaveThread thread = threadPool.get((servActivity.getActivityId() % threadNum));
        thread.add(object);
    }

    /**
     * 
     * @Title: saveAllActivity
     * @Description: 保存数据入口 void

     */
    public void saveAllActivity() {
        ActivityDataManager activityDataManager = GameServer.ac.getBean(ActivityDataManager.class);
        // ActivityService activityService =
        // GameServer.ac.getBean(ActivityService.class);

        Iterator<UsualActivityData> iterator = activityDataManager.getActivityMap().values().iterator();
        int now = TimeHelper.getCurrentSecond();
        int saveCount = 0;
        while (iterator.hasNext()) {
            try {
                UsualActivityData servActivityData = iterator.next();
                saveCount++;
                servActivityData.setLastSaveTime(now);
                saveData(servActivityData.copyData());
            } catch (Exception e) {
                // LogHelper.ERROR_LOGGER.error(e, e);
                LogUtil.error("Save Activity Exception", e);
            }

        }

        // LogHelper.ERROR_LOGGER.error("stop server!!save activity count:" + saveCount);
        LogUtil.save("stop server!!save activity count:" + saveCount);
    }
}
