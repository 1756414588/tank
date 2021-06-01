package com.hundredcent.game.aop.persistence;

import com.hundredcent.game.aop.AopConstant;
import com.hundredcent.game.aop.annotation.SaveOptimize;
import com.hundredcent.game.aop.domain.IPlayerSave;
import com.hundredcent.game.aop.domain.ISave;

import java.util.LinkedList;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;

/**
 * 数据保存任务基类，数据保存优化功能入口类
 * <p>
 * 该类已经实现了数据的保存，使用者可以通过继承该类，并实现该类的一些方法，来实现基础的数据保存优化。<br/>
 * 如果你想通过一些方法，实现更细粒度的优化，比如：<br/>
 * 监听某个类，某给方法，某个全局变量（必须有对应setter方法），对它们对应的实体（如玩家数据）做一些保存优先级的修改，可以使用{@link com.hundredcent.game.aop.annotation}包下的注解；
 * 将这些注解添加到你想监听的类、方法或全局变量上，系统会通过asm技术在类加载时注入对应的方法，在方法被调用，或全局变量的值被改变（对应的setter方法被调用）时执行相应的操作。
 * </p>
 * <p>
 * 关于数据保存优化的背景、原理和目标：<br/>
 * 游戏进程加载了所有有效玩家的数据，长期保留在内存中，且按固定周期（如5分钟一次）保存所有玩家的数据，这导致了大量的内存消耗与数据库更新请求；
 * 而SLG游戏单服同时在线人数较低，大量已流失或长期不登录的玩家占用着服务器资源和数据库资源（尤其是数据库QPS和CPU资源），这一度使得我们的云数据库报警，不得不升级数据库实例。<br/>
 * 这些玩家的数据，无论是变动的频率还是重要性都已大大降低，没有必要再执行频繁的定时更新操作；通过降低数据保存频率，可以极大的减轻数据库的压力。<br/>
 * 通过对玩家数据的计算，对不同的数据使用不同的更新频率，且通过算法使数据库写入操作尽可能的均匀分布，使保存操作在时间线上保持平稳，数据库QPS和CPU曲线趋于平直，最终降低数据库资源占用，降低mysql
 * binlog日志量，为系统的其他优化提供支持。
 * </p>
 * <p>
 * 注意：<br/>
 * 继承该类必须实现一些指定的接口，这些接口位于{@link com.hundredcent.game.aop.persistence.domain}包下，具体需要实现哪些接口，根据使用者需要用到的功能而定；<br/>
 * 比如：<br/>
 * 想要用该类优化玩家个人数据的保存，需显式的调用{@link #savePlayerTimerLogic(int)}，则必须实现{@link IPlayerSave}，该接口提供一些玩家的属性，用于计算玩家的保存优先级。<br/>
 * </p>
 *
 * @author Tandonghai
 * @date 2018-01-12 18:31
 * @see SaveOptimize
 * @see SaveImmediate
 * @see SaveIdle
 * @see SaveNever
 */
public abstract class AbstractSaveTask<T extends ISave> {
    public AbstractSaveTask() {
        registOptimizeUtil();
        initPersistenceConfig();
    }

    /**
     * 保存优化相关配置数据
     */
    private IPersistenceConfig persistenceConfig;

    /**
     * 记录需要提前保存的玩家
     */
    protected Map<Long, Boolean> advanceSaveIdMap = new ConcurrentHashMap<>();

    /**
     * 保存定时任务有空闲时优先保存的玩家<br/>
     * 添加闲时保存的目的是分流{@link #advanceSaveRoleIdSet}，避免太多玩家被加入及时保存队列，造成保存任务短时间内大量增加<br/>
     * 当前主要用于处理每天的邮件定时任务，邮件任务可能造成大量玩家的及时保存需求，且时间统一，当有多个进程同时执行时，将可能造成数据库压力过大，用闲时保存可有效分流
     */
    protected Map<Long, Boolean> idleSaveIdMap = new ConcurrentHashMap<>();

    /**
     * 记录一段时间内，每次执行保存定时任务，保存玩家数据的个数
     */
    protected LinkedList<Integer> saveCountList = new LinkedList<>();

    /**
     * 进程启动后总执行保存次数，用于偏移处理
     */
    protected int totalSaveCount;

    /**
     * 本地定时任务是否已启动
     */
    protected boolean localTimerFlag;

    /**
     * 保存优化功能是否开启，如果关闭，则本地的一些任务将会停止执行，默认开启
     */
    protected boolean open = true;

    protected ScheduledExecutorService localTimerExecutor = Executors.newScheduledThreadPool(1);

    /**
     * 配置接口实现类
     */
    protected abstract IPersistenceConfig persistenceConfig();

    /**
     * 启动时初始化所有玩家下次保存数据的时间
     */
    protected abstract void registOptimizeUtil();

    /**
     * 计算玩家下次保存数据的时间
     *
     * @param player
     * @param now
     * @return
     */
    protected abstract int calcNextSaveTime(T isave, int now);

    /**
     * 保存玩家数据定时任务
     *
     * @param now
     */
    public abstract void saveTimerLogic(int now);

    /**
     * 保存数据
     *
     * @param isave
     */
    protected abstract void saveData(T isave);

    /**
     * 检查并初始化本地任务
     */
    protected abstract void checkAndInitialize(int now);

    /**
     * 设置初始化配置
     */
    protected void initPersistenceConfig() {
        this.persistenceConfig = persistenceConfig();
    }

    /**
     * 添加需要立即保存或优先保存的玩家
     *
     * @param roleId
     */
    public void addAdvanceSave(long objectId) {
        advanceSaveIdMap.put(objectId, true);
    }

    /**
     * 添加闲时保存玩家<br/>
     * 注意：闲时保存是指，优先级不是特别高，但又需要在短时间内保存一次；<br/>
     * 处于闲时保存队列中的玩家，其保存优先级高于普通离线玩家，但是会受到当前定时任务的繁忙程度影响，而繁忙程度的计算，依赖于具体的算法和数值
     *
     * @param roleId
     * @return
     */
    public boolean addIdleSave(long objectId) {
        if (!advanceSaveIdMap.keySet().contains(objectId)) {
            idleSaveIdMap.put(objectId, true);
            return true;
        } else {
            return false;
        }

    }

    /**
     * 对保存时间做偏移处理，尽量让玩家的保存时间均匀分布，该方法可能导致离线玩家的数据保存时间周期不稳定，偏移量[0,3600)秒
     *
     * @param nextSaveTime
     * @return
     */
    protected int migrateSaveTime(int nextSaveTime) {
        totalSaveCount++;
        if (totalSaveCount <= 0) {
            // 防止数值溢出处理
            totalSaveCount = 1;
        }
        return nextSaveTime + (totalSaveCount % AopConstant.HOUR_SECONDS);
    }

    /**
     * 记录已执行保存次数
     *
     * @param saveCount
     */
    protected void recordSaveCount(int saveCount) {
        saveCountList.addLast(saveCount);
        if (saveCountList.size() > persistenceConfig.getIdleSaveSize()) {
            saveCountList.removeFirst();
        }
    }

    /**
     * 近一段时间内，数据保存任务是否空闲
     *
     * @return
     */
    protected boolean isSaveIdle() {
        if (saveCountList.isEmpty()) {
            return true;
        }

        int totalSave = 0;
        for (Integer save : saveCountList) {
            totalSave += save;
        }

        int size = saveCountList.size() < persistenceConfig.getIdleSaveSize() ?
                saveCountList.size() :
                persistenceConfig.getIdleSaveSize();
        return (totalSave / size) < persistenceConfig.getIdleSaveThreshold();
    }

    /**
     * 判断玩家是否需要立刻执行数据保存逻辑
     *
     * @param player
     * @param now
     * @return
     */
    protected boolean needImmediateSave(T isave, int now) {
        if (isave.isImmediateSave() || now >= isave.getNextSaveTime()) {
            return true;
        }
        return false;
    }
}
