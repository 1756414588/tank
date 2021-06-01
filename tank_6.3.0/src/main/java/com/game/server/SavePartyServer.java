/**
 * @Title: MainLogicServer.java
 * @Package com.game.server
 * @Description:
 * @author ZhangJun
 * @date 2015年7月29日 下午7:24:35
 * @version V1.0
 */
package com.game.server;

import com.game.domain.PartyData;
import com.game.domain.p.Party;
import com.game.domain.p.PartyRank;
import com.game.manager.PartyDataManager;
import com.game.server.thread.SavePartyThread;
import com.game.server.thread.SaveThread;
import com.game.service.PartyService;
import com.game.util.LogUtil;
import com.game.util.TimeHelper;

import java.util.Iterator;

/**
 * @author ZhangJun
 * @ClassName: SavePartyServer
 * @Description: 军团数据保存服务器
 * @date 2015年7月29日 下午7:24:35
 */
public class SavePartyServer extends SaveServer {

    public SavePartyServer() {
        super("SAVE_PUBLIC_SERVER", 5);
    }

    @Override
    public SaveThread createThread(String name) {

        return new SavePartyThread(name);
    }

    @Override
    public void saveData(Object object) {
        Party party = (Party) object;
        SaveThread thread = threadPool.get((party.getPartyId() % threadNum));
        thread.add(object);
    }

    /**
     * @Title: saveAllParty
     * @Description: 保存数据入口 void
     */
    public void saveAllParty() {
        PartyDataManager partyDataManager = GameServer.ac.getBean(PartyDataManager.class);
        PartyService partyService = GameServer.ac.getBean(PartyService.class);

        Iterator<PartyData> iterator = partyDataManager.getPartyMap().values().iterator();
        int now = TimeHelper.getCurrentSecond();
        int saveCount = 0;
        long fight = 0;
        PartyRank partyRank;
        while (iterator.hasNext()) {
            PartyData partyData = iterator.next();
            try {
                saveCount++;
                partyData.nextSaveTime(now);
                fight = partyService.calcPartyFight(partyData);
                partyRank = partyDataManager.getPartyRank(partyData.getPartyId());
                partyRank.setFight(fight);
                saveData(partyData.copyData());
            } catch (Exception e) {
                LogUtil.error("Save Party Exception, partyId:" + partyData.getPartyId(), e);
            }
        }
        LogUtil.save(name + " ser data count:" + saveCount);
    }
}
