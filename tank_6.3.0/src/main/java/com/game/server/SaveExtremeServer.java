/**
 * @Title: MainLogicServer.java
 * @Package com.game.server
 * @Description:
 * @author ZhangJun
 * @date 2015年7月29日 下午7:24:35
 * @version V1.0
 */
package com.game.server;

import com.game.domain.p.DbExtreme;
import com.game.domain.p.Extreme;
import com.game.manager.ExtremeDataManager;
import com.game.server.thread.SaveExtremeThread;
import com.game.server.thread.SaveThread;
import com.game.util.LogUtil;

import java.util.Iterator;
import java.util.Map;

/**
 * @author
 * @ClassName: SaveExtremeServer
 * @Description: 极限探险数据保存服务器
 * @date 2017年11月18日 下午5:19:19
 */
public class SaveExtremeServer extends SaveServer {

    public SaveExtremeServer() {
        super("SAVE_EXTREME_SERVER", 5);
    }

    @Override
    public SaveThread createThread(String name) {
        return new SaveExtremeThread(name);
    }

    @Override
    public void saveData(Object object) {
        DbExtreme data = (DbExtreme) object;
        SaveThread thread = threadPool.get((data.getExtremeId() % threadNum));
        thread.add(object);
    }

    /**
     * @Title: saveAllExtreme
     * @Description: 保存极限探险数据入口 void
     */
    public void saveAllExtreme() {
        ExtremeDataManager extremeDataManager = GameServer.ac.getBean(ExtremeDataManager.class);
        Iterator<Integer> it = extremeDataManager.saveSet.iterator();
        Map<Integer, Extreme> map = extremeDataManager.recordMap;
        int saveCount = 0;
        while (it.hasNext()) {
            Integer id = (Integer) it.next();
            Extreme extreme = map.get(id);
            if (extreme != null) {
                saveCount++;
                // extremeDataManager.update(extremeDataManager.serExtreme(extreme));
                try {
                    saveData(extremeDataManager.serExtreme(extreme));
                } catch (Exception e) {
                    // LogHelper.ERROR_LOGGER.error(e, e);
                    LogUtil.error("Save Exteme Exception, extremeId:" + extreme.getExtremeId(), e);
                }

            }
        }

        extremeDataManager.saveSet.clear();
        LogUtil.save(name + " ser data count:" + saveCount);
    }
}
