/**   
 * @Title: MainLogicServer.java    
 * @Package com.game.server    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年7月29日 下午7:24:35    
 * @version V1.0   
 */
package com.game.server;

import com.game.domain.Guy;
import com.game.domain.p.TipGuy;
import com.game.manager.PlayerDataManager;
import com.game.server.thread.SaveGuyThread;
import com.game.server.thread.SaveThread;
import com.game.util.LogUtil;
import com.game.util.TimeHelper;

import java.util.Iterator;

/**
 * @ClassName: SaveGuyServer
 * @Description: 新建玩家数据保存服务器
 * @author ZhangJun
 * @date 2015年7月29日 下午7:24:35
 * 
 */
public class SaveGuyServer extends SaveServer {

    /**
     * @param name 服务器名
     * @param threadNum 线程号
     */
    public SaveGuyServer() {
        super("SAVE_GUY_SERVER", 2);
    }

    /**
     * 
     * <p>
     * Title: createThread
     * </p>
     * <p>
     * Description: 初始化 SaveGuyThread的线程
     * </p>
     * 
     * @param name 线程名
     * @return
     * @see com.game.server.SaveServer#createThread(java.lang.String)
     */
    public SaveThread createThread(String name) {
        return new SaveGuyThread(name);
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
        TipGuy tipGuy = (TipGuy) object;
        int id = (int) (tipGuy.getLordId() % threadNum);
        SaveThread thread = threadPool.get(id);
        thread.add(object);
    }

    /**
     * 
     * @Title: saveAllGuy
     * @Description: 保存数据入口 void

     */
    public void saveAllGuy() {
        PlayerDataManager playerDataManager = GameServer.ac.getBean(PlayerDataManager.class);

        Iterator<Guy> iterator = playerDataManager.getGuyMap().values().iterator();
        int now = TimeHelper.getCurrentSecond();
        int saveCount = 0;
        while (iterator.hasNext()) {
            try {
                Guy guy = iterator.next();
                saveCount++;
                guy.setLastSaveTime(now);
                saveData(guy.copyData());
            } catch (Exception e) {
                // LogHelper.ERROR_LOGGER.error(e, e);
                LogUtil.error("Save Guy Exception", e);
            }

        }

        // LogHelper.ERROR_LOGGER.error("stop server!!save activity count:" + saveCount);
        LogUtil.save("stop server!!save activity count:" + saveCount);
    }
}
