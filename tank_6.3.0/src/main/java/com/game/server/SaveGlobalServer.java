/**
 * @Title: MainLogicServer.java
 * @Package com.game.server
 * @Description:
 * @author ZhangJun
 * @date 2015年7月29日 下午7:24:35
 * @version V1.0
 */
package com.game.server;

import com.game.domain.GameGlobal;
import com.game.domain.p.DbGlobal;
import com.game.manager.GlobalDataManager;
import com.game.server.thread.SaveGlobalThread;
import com.game.server.thread.SaveThread;
import com.game.util.LogUtil;

/**
 * @author ZhangJun
 * @ClassName: MainLogicServer
 * @Description: 全局数据保存服务器
 * @date 2015年7月29日 下午7:24:35
 */
public class SaveGlobalServer extends SaveServer {

    /**
     *
     */
    public SaveGlobalServer() {
        super("SAVE_GLOBAL_SERVER", 1);
    }

    @Override
    public SaveThread createThread(String name) {
        return new SaveGlobalThread(name);
    }

    @Override
    public void saveData(Object object) {
        DbGlobal dbGlobal = (DbGlobal) object;
        SaveThread thread = threadPool.get((dbGlobal.getGlobalId() % threadNum));
        thread.add(object);
    }

    /**
     * @Title: saveAllGlobal
     * @Description: 保存全局数据入口
     * void
     */
    public void saveAllGlobal() {
        GlobalDataManager globalDataManager = GameServer.ac.getBean(GlobalDataManager.class);
        GameGlobal gameGlobal = globalDataManager.gameGlobal;
        int saveCount = 0;
        if (gameGlobal != null) {
            try {
                saveData(gameGlobal.ser());
                saveCount = 1;
            } catch (Exception e) {
                LogUtil.error("Save Global Exception", e);
            }
        }
        LogUtil.save(name + " ser data count:" + saveCount);
    }
}
