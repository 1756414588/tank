package com.hundredcent.game.aop.persistence.party;

import java.util.Collection;
import java.util.Iterator;
import java.util.concurrent.TimeUnit;

import com.hundredcent.game.aop.AopConstant;
import com.hundredcent.game.aop.domain.IPartySave;
import com.hundredcent.game.aop.persistence.AbstractSaveTask;
import com.hundredcent.game.aop.persistence.IPersistenceConfig;
import com.hundredcent.game.util.AgentLogUtil;

/**
 * 军团数据保存任务基类，数据保存优化功能入口类
 */
public abstract class AbstractSavePartyTask extends AbstractSaveTask<IPartySave> {
    protected PartyPersistenceConfig config;

    /**
     * 获取所有军团
     *
     * @return
     */
    protected abstract Collection<? extends IPartySave> getAllParty();

    /**
     * 保存数据
     *
     * @param player
     */
    @Override
    protected abstract void saveData(IPartySave player);

    protected abstract IPartySave getPartyById(int partyId);

    @Override
    protected void registOptimizeUtil() {
        SavePartyOptimizeUtil.setSaveTask(this);
    }

    /**
     * 添加需要立即保存或优先保存的军团
     *
     * @param objectId
     */
    @Override
    public void addAdvanceSave(long objectId) {
        if (!advanceSaveIdMap.keySet().contains(objectId)) {
            super.addAdvanceSave(objectId);
        }

    }

    /**
     * 计算军团下次保存数据的时间
     *
     * @param party
     * @param now
     * @return
     */
    @Override
    protected int calcNextSaveTime(IPartySave party, int now) {
        return now + config.getPartySavePeriod();
    }

    @Override
    protected IPersistenceConfig persistenceConfig() {
        if (config == null) {
            config = new PartyPersistenceConfig();
        }
        return config;
    }

    @Override
    public void saveTimerLogic(int now) {
        checkAndInitialize(now);
        Iterator<Long> iterator = advanceSaveIdMap.keySet().iterator();
        int saveCount = 0;
        long startNano = System.currentTimeMillis();
        IPartySave party;
        /** 定时处理保存的军团 */
        while (iterator.hasNext()) {
            party = getPartyById(iterator.next().intValue());
            if (needImmediateSave(party, now)) {
                // 到这个军团保存时间了
                try {
                    party.nextSaveTime(calcNextSaveTime(party, now));
                    saveData(party);
                    iterator.remove();
                } catch (Exception e) {
                    AgentLogUtil.error("save party {" + party.objectId() + "} data error", e);
                }
                saveCount++;
                if (saveCount >= config.getMaxSaveCount()) {
                    break;
                }
            }
        }
        long thisNano = System.currentTimeMillis();
        if (saveCount > 0) {
            AgentLogUtil.saveInfo("保存军团数据 save count:{}, 耗时:{} ms", saveCount, (thisNano - startNano));
        }

    }

    @Override
    protected void checkAndInitialize(final int now) {
        if (!SavePartyOptimizeUtil.hasInited()) {
            Collection<? extends IPartySave> allPartys = getAllParty();
            Iterator<? extends IPartySave> iterator = allPartys.iterator();
            IPartySave party;
            while (iterator.hasNext()) {
                party = iterator.next();
                party.nextSaveTime(calcNextSaveTime(party, now));
            }
            SavePartyOptimizeUtil.gameInited();
        }
    }

    public void flushPartyAllSave(int now) {

        long t = System.currentTimeMillis();
        int count = 0;

        Collection<? extends IPartySave> allPartys = getAllParty();
        if (allPartys == null || allPartys.isEmpty()) {
            return;
        }
        Iterator<? extends IPartySave> iterator = allPartys.iterator();
        while (iterator.hasNext()) {
            IPartySave next = iterator.next();

            if (next.isActive() && now > next.getNextSaveTime()) {
                addAdvanceSave(next.objectId());
                count++;
            }
        }
        AgentLogUtil.saveInfo("遍历所有军团完成 耗时 {} ms ,共有 {} 个需要保存", (System.currentTimeMillis() - t), count);

    }

}
