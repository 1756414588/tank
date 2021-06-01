package com.game.persistence;

import com.game.constant.Constant;
import com.game.domain.PartyData;
import com.game.domain.p.PartyRank;
import com.game.manager.PartyDataManager;
import com.game.server.GameServer;
import com.game.service.PartyService;
import com.game.util.LogUtil;
import com.hundredcent.game.aop.domain.IPartySave;
import com.hundredcent.game.aop.persistence.party.AbstractSavePartyTask;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.Collection;
import java.util.Iterator;

@Component
public class SavePartyOptimizeTask extends AbstractSavePartyTask {
    @Autowired
    PartyDataManager partyDataManager;
    @Autowired
    PartyService partyService;

    @Override
    protected Collection<? extends IPartySave> getAllParty() {
        return partyDataManager.getPartyMap().values();
    }

    @Override
    protected void saveData(IPartySave party) {
        if (party instanceof PartyData) {
            PartyData partyData = (PartyData) party;
            long fight = partyService.calcPartyFight(partyData);
            PartyRank partyRank = partyDataManager.getPartyRank(partyData.getPartyId());
            partyRank.setFight(fight);
            partyData.setFight(fight);
            GameServer.getInstance().savePartyServer.saveData(partyData.copyData());
        }

    }

    @Override
    protected IPartySave getPartyById(int partyId) {
        return partyDataManager.getPartyMap().get(partyId);
    }

    private void oldSavePartyTimerLogic(int now) {
        Iterator<PartyData> iterator = partyDataManager.getPartyMap().values().iterator();
        int saveCount = 0;
        long fight = 0;
        PartyRank partyRank;
        while (iterator.hasNext()) {
            PartyData partyData = iterator.next();
            if (now - partyData.getNextSaveTime() >= 180) {
                saveCount++;
                try {
                    partyData.nextSaveTime(now);
                    fight = partyService.calcPartyFight(partyData);
                    partyRank = partyDataManager.getPartyRank(partyData.getPartyId());
                    partyRank.setFight(fight);
                    partyData.setFight(fight);
                    GameServer.getInstance().savePartyServer.saveData(partyData.copyData());
                } catch (Exception e) {
                    LogUtil.error("save party {" + partyData.getPartyId() + "} data error", e);
                }

            }
        }

        if (saveCount != 0) {
            LogUtil.save("save party count:" + saveCount);
        }
    }


    @Override
    public void saveTimerLogic(int now) {
        // 检查保存优化功能开放，如果功能关闭，使用原来的保存方式
        if (Constant.SAVE_OPTIMIZE_SWITCH == 0) {
            oldSavePartyTimerLogic(now);
        } else {
            // 每次检查配置信息，并重新设置，保证当前配置信息是最新的
            super.saveTimerLogic(now);
        }
    }


}
