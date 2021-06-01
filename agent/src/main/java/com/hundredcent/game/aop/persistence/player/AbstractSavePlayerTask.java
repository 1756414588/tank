package com.hundredcent.game.aop.persistence.player;

import com.hundredcent.game.aop.AopConstant;
import com.hundredcent.game.aop.domain.IPlayerSave;
import com.hundredcent.game.aop.persistence.AbstractSaveTask;
import com.hundredcent.game.aop.persistence.IPersistenceConfig;
import com.hundredcent.game.util.AgentLogUtil;

import java.util.*;
import java.util.concurrent.ConcurrentHashMap;

/**
* @Author :GuiJie Liu
* @date :Create in 2019/5/21 16:53
* @Description :java类作用描述
*/
public abstract class AbstractSavePlayerTask extends AbstractSaveTask<IPlayerSave> {
    /**
     * 保存优化相关配置数据
     */
    protected PlayerPersistenceConfig config;

    /**
     * 玩家是否有未完成的队列，包括建筑队列、科技队列、生产队列等等
     *
     * @param player
     * @return
     */
    protected abstract boolean playerHaveUnfinishedQueue(IPlayerSave player);

    /**
     * 获取所有在线玩家
     *
     * @return
     */
    protected abstract Collection<? extends IPlayerSave> getOnlinePlayers();

    /**
     * 获取所有玩家
     *
     * @return
     */
    protected abstract Collection<? extends IPlayerSave> getAllPlayers();

    /**
     * 24小时内有登陆的活跃玩家，或玩家还有未完成的队列，8分钟保存一次
     */
    private Map<Long, IPlayerSave> _24HourPlayer = new ConcurrentHashMap<>();
    /**
     * 一天到3天不登陆的玩家 12分钟保存一次
     */
    private Map<Long, IPlayerSave> _1_3DayPlayer = new ConcurrentHashMap<>();
    /**
     * 3天到一周不登陆的玩家 半小时
     */
    private Map<Long, IPlayerSave> _3_7DayPlayer = new ConcurrentHashMap<>();
    /**
     * 一周到2周不登陆的玩家 1小时保存一次
     */
    private Map<Long, IPlayerSave> _7_15DayPlayer = new ConcurrentHashMap<>();
    /**
     * 2周到一月不登陆的玩家 24小时保存一次
     */
    private Map<Long, IPlayerSave> _15_30DayPlayer = new ConcurrentHashMap<>();
    /**
     * 离线30天的玩家
     */
    private Map<Long, IPlayerSave> _30_999DayPlayer = new ConcurrentHashMap<>();

    private SaveConfig saveConfig = new SaveConfig();


    /**
     * 根据id获取玩家对象
     *
     * @param roleId
     * @return
     */
    protected abstract IPlayerSave getPlayerById(long roleId);

    @Override
    protected void registOptimizeUtil() {
        SavePlayerOptimizeUtil.setSaveTask(this);
    }

    @Override
    protected IPersistenceConfig persistenceConfig() {
        if (config == null) {
            config = new PlayerPersistenceConfig();
        }
        return config;
    }

    /**
     * 启动时初始化所有玩家下次保存数据的时间
     */
    public void initAllSaveTime(int now) {
        Collection<? extends IPlayerSave> allPlayers = getAllPlayers();
        Iterator<? extends IPlayerSave> iterator = allPlayers.iterator();
        IPlayerSave player;
        while (iterator.hasNext()) {
            player = iterator.next();
            player.nextSaveTime(calcNextSaveTime(player, now));
        }
        SavePlayerOptimizeUtil.gameInited();
    }

    /**
     * 计算玩家下次保存数据的时间
     *
     * @param player
     * @param now
     * @return
     */
    @Override
    protected int calcNextSaveTime(IPlayerSave player, int now) {
        if (player.isOnline()) {
            // 在线玩家，默认5分钟保存一次数据，并且不进行偏移处理，避免保存量过多导致偏移量太大，影响在线玩家数据的及时保存
            return now + (5 * AopConstant.MINUTE_SECONDS);
        }
        int offlineTime = now - player.getOfflineTime();
        int nextSaveTime = now;
        if (!player.isActive()) {
            // 死号，一个月保存一次，基本相当于不做定时保存
            nextSaveTime = now + AopConstant.MONTH_SECONDS;
        } else {
            // 24小时内有登陆的活跃玩家，或玩家还有未完成的队列，10分钟保存一次
            if (offlineTime <= AopConstant.DAY_SECONDS || playerHaveUnfinishedQueue(player)) {
                nextSaveTime = now + (5 * AopConstant.MINUTE_SECONDS);
            } else if (offlineTime <= AopConstant.THREE_SECONDS) {
                //一天到3天不登陆的玩家
                nextSaveTime = now + (12 * AopConstant.MINUTE_SECONDS);
            } else if (offlineTime <= AopConstant.WEEK_SECONDS) {
                //3天到一周不登陆的玩家 半小时
                nextSaveTime = now + (30 * AopConstant.MINUTE_SECONDS);
            } else if (offlineTime <= (AopConstant.WEEK_SECONDS * 2)) {
                //1周到2周不登陆的玩家60分钟保存一次
                nextSaveTime = now + (120 * AopConstant.MINUTE_SECONDS);
            } else if (offlineTime <= AopConstant.MONTH_SECONDS) {
                //一周到一月不登陆的玩家
                nextSaveTime = now + config.getWeekInactiveDataSavePeriod();
            } else {
                //一月以上不登陆的玩家
                nextSaveTime = now + config.getMonthInactiveDataSavePeriod();
            }
        }
        return migrateSaveTime(nextSaveTime);
    }


    /**
     * 保存玩家数据定时任务
     *
     * @param now
     */
    @Override
    public void saveTimerLogic(int now) {
        //初始化保存时间
        checkAndInitialize(now);


        int consumeTime = 0;
        int saveCount = 0;

        int[] consumeTimeOnline = saveOnline(now);
        consumeTime += consumeTimeOnline[0];
        saveCount += consumeTimeOnline[1];

        if (consumeTimeOnline[0] > 200) {
            AgentLogUtil.saveInfo("保存在线玩家数据耗时 > 200ms consumeTimeOnline={} ms ,consumeTime={},saveCount={}", consumeTimeOnline[0], consumeTime, saveCount);
            return;
        }


        int[] saveAdvanceConsumeTime = saveAdvance(now);
        consumeTime += saveAdvanceConsumeTime[0];
        saveCount += saveAdvanceConsumeTime[1];
        if (saveAdvanceConsumeTime[0] > 200) {
            AgentLogUtil.saveInfo("没有在线玩家的数据需要立即保存时，优先保存添加到待处理集合中的玩家 耗时 > 200ms  saveAdvanceConsumeTime={} ms ,consumeTime={},saveCount={} ", saveAdvanceConsumeTime[0], consumeTime, saveCount);
            return;
        }


        int[] saveIdleSaveIdConsumeTime = saveIdleSaveId(now);
        consumeTime += saveIdleSaveIdConsumeTime[0];
        saveCount += saveIdleSaveIdConsumeTime[1];
        if (saveIdleSaveIdConsumeTime[0] > 200) {
            AgentLogUtil.saveInfo("如果当前定时保存任务处于空闲，优先处理记录在闲时保存集合中的玩家数据 耗时 > 200ms  saveIdleSaveIdConsumeTime={} ms ,consumeTime={},saveCount={}", saveIdleSaveIdConsumeTime[0], consumeTime, saveCount);
            return;
        }

        float f = 0.0f;
        if (saveCount > 0) {
            f = consumeTime / (saveCount * 1.0f);
        }
        AgentLogUtil.saveInfo(" 保存一次玩家信息，共保存 {} 个玩家数据 共耗时 {} ms ,平均耗时 {} ms ", saveCount, consumeTime, f);

    }


    /**
     * 如果当前定时保存任务处于空闲，优先处理记录在闲时保存集合中的玩家数据
     *
     * @param now
     * @return
     */
    private int[] saveIdleSaveId(int now) {
        long startTime = System.currentTimeMillis();
        int saveCount = 0;
        IPlayerSave player;
        if (isSaveIdle() && !idleSaveIdMap.isEmpty()) {
            // 如果当前定时保存任务处于空闲，优先处理记录在闲时保存集合中的玩家数据
            Iterator<Long> its = idleSaveIdMap.keySet().iterator();
            while (its.hasNext()) {
                if (saveCount >= config.getIdleSaveCount()) {
                    break;
                }
                Long next = its.next();
                player = getPlayerById(next);
                if (player == null) {
                    AgentLogUtil.error("error player is null roleIf =" + next);
                }
                if (!player.isOnline()) {
                    // 只处理不在线玩家，在线玩家按正常逻辑保存
                    saveCount++;
                    try {
                        saveData(player);
                        player.nextSaveTime(calcNextSaveTime(player, now));
                    } catch (Exception e) {
                        AgentLogUtil.error("save player {" + player.objectId() + "} data error", e);
                    }
                }
                its.remove();
            }
        }
        long endTime = System.currentTimeMillis();
        int result = (int) (endTime - startTime);
        if (saveCount > 0) {
            this.recordSaveCount(saveCount);
            AgentLogUtil.saveInfo("3 闲时保存玩家数据数:{}, 总耗时:{} ms", saveCount, result);
        }
        return new int[]{result, saveCount};
    }

    /**
     * 没有在线玩家的数据需要立即保存时，优先保存添加到待处理集合中的玩家
     *
     * @param now
     * @return
     */
    private int[] saveAdvance(int now) {
        long startTime = System.currentTimeMillis();
        int saveCount = 0;
        IPlayerSave player;
        if (!advanceSaveIdMap.isEmpty()) {
            // 没有在线玩家的数据需要立即保存时，优先保存添加到待处理集合中的玩家
            Iterator<Long> its = advanceSaveIdMap.keySet().iterator();
            while (its.hasNext()) {
                if (saveCount >= config.getCycleSaveCount()) {
                    break;
                }
                player = getPlayerById(its.next());
                if (!player.isOnline()) {
                    // 只处理不在线玩家，在线玩家按正常逻辑保存
                    saveCount++;
                    try {
                        saveData(player);
                        player.nextSaveTime(calcNextSaveTime(player, now));
                    } catch (Exception e) {
                        AgentLogUtil.error("到时间需要立即保存时 save player {" + player.objectId() + "} data error", e);
                    }
                }
                its.remove();
            }
        }
        long endTime = System.currentTimeMillis();
        int result = (int) (endTime - startTime);
        if (saveCount > 0) {
            this.recordSaveCount(saveCount);
            AgentLogUtil.saveInfo("2 提升了优先级的玩家数据保存数:{}, 总耗时:{} ms", saveCount, result);
        }
        return new int[]{result, saveCount};
    }

    /**
     * 保存在线玩家
     *
     * @param now
     * @return
     */
    private int[] saveOnline(int now) {
        Collection<? extends IPlayerSave> onlinePlayers = getOnlinePlayers();
        Iterator<? extends IPlayerSave> iterator;
        long startTime = System.currentTimeMillis();
        int saveCount = 0;
        IPlayerSave player;
        if (null != onlinePlayers && !onlinePlayers.isEmpty()) {
            // 优先保存在线玩家的数据
            iterator = getOnlinePlayers().iterator();
            while (iterator.hasNext()) {
                player = iterator.next();
                if (needImmediateSave(player, now)) {
                    try {
                        if (saveCount >= config.getImmediateSaveCount()) {
                            break;
                        }
                        saveCount++;
                        player.nextSaveTime(calcNextSaveTime(player, now));
                        saveData(player);
                    } catch (Exception e) {
                        AgentLogUtil.error("save player {" + player.objectId() + "} data error", e);
                    }
                }
            }
        }
        long endTime = System.currentTimeMillis();
        int result = (int) (endTime - startTime);
        if (saveCount > 0) {
            this.recordSaveCount(saveCount);
            AgentLogUtil.saveInfo("1 保存在线玩家数据 save count:{}, 耗时:{} ms", saveCount, result);
        }
        return new int[]{result, saveCount};
    }

    /**
     * 检查并初始化本地任务
     */
    @Override
    protected void checkAndInitialize(final int now) {
        if (!SavePlayerOptimizeUtil.hasInited()) {
            initAllSaveTime(now);
            refreshOfflineCountPlayer(now);
        }
        if (!localTimerFlag && config.isOfflinePlayerQueueRefresh()) {
            localTimerFlag = true;
        }
    }


    private void refreshPlayerAddIdleSave(int now, String type, Collection<IPlayerSave> saves) {
        int saveCount = 0;
        for (Iterator<IPlayerSave> iterator = saves.iterator(); iterator.hasNext(); ) {
            IPlayerSave next = iterator.next();
            if (now > next.getNextSaveTime()) {
                saveCount++;
                addAdvanceSave(next.objectId());
            }
        }
        AgentLogUtil.saveInfo("定时遍历玩家,检测是否需要保存玩家数据 type={},count={}, saveCount={}", type, saves.size(), saveCount);
    }


    /**
     * 没有监听到数据改变的玩家 到时见也需要进行保存
     *
     * @param now
     */
    public void flushPlayerAddIdleSave(int now) {
        refreshPlayerAddIdleSave(now, "24hour", _24HourPlayer.values());
        refreshPlayerAddIdleSave(now, "1-3Day", _1_3DayPlayer.values());
        refreshPlayerAddIdleSave(now, "3-7Day", _3_7DayPlayer.values());
        refreshPlayerAddIdleSave(now, "7-15Day", _7_15DayPlayer.values());
        refreshPlayerAddIdleSave(now, "15-30Day", _15_30DayPlayer.values());
    }


    /**
     * 计算玩家离线集合
     *
     * @param now
     */
    public void refreshOfflineCountPlayer(int now) {
        long t = System.currentTimeMillis();
        AgentLogUtil.saveInfo("开始计算玩家离线时间集合");
        /**
         * 24小时内有登陆的活跃玩家，或玩家还有未完成的队列，8分钟保存一次
         */
        Map<Long, IPlayerSave> _24Hour = new ConcurrentHashMap<>();
        /**
         * 一天到3天不登陆的玩家 12分钟保存一次
         */
        Map<Long, IPlayerSave> _1_3Day = new ConcurrentHashMap<>();
        /**
         * 3天到一周不登陆的玩家 半小时
         */
        Map<Long, IPlayerSave> _3_7Day = new ConcurrentHashMap<>();
        /**
         * 一周到2周不登陆的玩家 1小时保存一次
         */
        Map<Long, IPlayerSave> _7_15Day = new ConcurrentHashMap<>();
        /**
         * 2周到一月不登陆的玩家 24小时保存一次
         */
        Map<Long, IPlayerSave> _15_30Day = new ConcurrentHashMap<>();
        Map<Long, IPlayerSave> _30_999Day = new ConcurrentHashMap<>();
        Collection<? extends IPlayerSave> allPlayers = getAllPlayers();
        if (null != allPlayers && !allPlayers.isEmpty()) {
            for (IPlayerSave player : allPlayers) {
                if (player.isOnline() || !player.isActive()) {
                    continue;
                }
                int offlineTime = now - player.getOfflineTime();
                // 24小时内有登陆的活跃玩家，或玩家还有未完成的队列，10分钟保存一次
                if (offlineTime <= AopConstant.DAY_SECONDS || playerHaveUnfinishedQueue(player)) {
                    _24Hour.put(player.objectId(), player);
                } else if (offlineTime <= AopConstant.THREE_SECONDS) {
                    //一天到3天不登陆的玩家
                    _1_3Day.put(player.objectId(), player);
                } else if (offlineTime <= AopConstant.WEEK_SECONDS) {
                    //3天到一周不登陆的玩家 半小时
                    _3_7Day.put(player.objectId(), player);
                } else if (offlineTime <= (AopConstant.WEEK_SECONDS * 2)) {
                    //1周到2周不登陆的玩家60分钟保存一次
                    _7_15Day.put(player.objectId(), player);
                } else if (offlineTime <= AopConstant.MONTH_SECONDS) {
                    //一周到一月不登陆的玩家
                    _15_30Day.put(player.objectId(), player);
                } else {
                    _30_999Day.put(player.objectId(), player);
                }
            }
        }
        _24HourPlayer.clear();
        _1_3DayPlayer.clear();
        _3_7DayPlayer.clear();
        _7_15DayPlayer.clear();
        _15_30DayPlayer.clear();
        _30_999DayPlayer.clear();
        _24HourPlayer.putAll(_24Hour);
        _1_3DayPlayer.putAll(_1_3Day);
        _3_7DayPlayer.putAll(_3_7Day);
        _7_15DayPlayer.putAll(_7_15Day);
        _15_30DayPlayer.putAll(_15_30Day);
        _30_999DayPlayer.putAll(_30_999Day);
        AgentLogUtil.saveInfo("24小时内有登陆的活跃玩家 5 分钟保存一次共 {} 人", _24HourPlayer.size());
        AgentLogUtil.saveInfo("1天到3天不登陆的玩家 12 分钟保存一次共 {} 人", _1_3DayPlayer.size());
        AgentLogUtil.saveInfo("3天到1周不登陆的玩家 30 分钟保存一次共 {} 人", _3_7DayPlayer.size());
        AgentLogUtil.saveInfo("1周到2周不登陆的玩家 120 分钟保存一次共 {} 人", _7_15DayPlayer.size());
        AgentLogUtil.saveInfo("1周到1月不登陆的玩家 24 小时保存一次共 {} 人", _15_30DayPlayer.size());
        AgentLogUtil.saveInfo("大于30天未登录共 {} 人", _30_999DayPlayer.size());
        AgentLogUtil.saveInfo("开始计算玩家离线时间集合完成 耗时 {} ms", (System.currentTimeMillis() - t));
    }

    /**
     * 添加需要立即保存或优先保存的玩家
     *
     * @param objectId
     */
    @Override
    public void addAdvanceSave(long objectId) {
        IPlayerSave player = getPlayerById(objectId);
        if (null == player || player.isOnline()) {
            return;
        }
        super.addAdvanceSave(player.objectId());
    }

    /**
     * 添加闲时保存玩家<br/>
     * 注意：闲时保存是指，优先级不是特别高，但又需要在短时间内保存一次；<br/>
     * 处于闲时保存队列中的玩家，其保存优先级高于普通离线玩家，但是会受到当前定时任务的繁忙程度影响，而繁忙程度的计算，依赖于具体的算法和数值
     *
     * @param objectId
     */
    @Override
    public boolean addIdleSave(long objectId) {
        IPlayerSave player = getPlayerById(objectId);
        if (null == player || !player.canIdelSave() || player.isOnline()) {
            return false;
        }
        return super.addIdleSave(player.objectId());
    }

    /**
     * 玩家登录后，重置数据保存时间
     *
     * @param roleId
     * @param now
     */
    public void updateSaveTimeOnLogin(long roleId, int now) {
        IPlayerSave player = getPlayerById(roleId);
        if (null == player || !player.canIdelSave() || player.isOnline()) {
            return;
        }
        player.nextSaveTime(now + config.getOnlinePlayerSavePeriod());
    }

    protected void setMainSwith(boolean open) {
        SavePlayerOptimizeUtil.setMainSwith(open);
    }


    /**
     * 如果本次没有需要优先保存的玩家信息，执行所有玩家的遍历
     *
     * @param now
     * @return
     */
    public void saveAllPlayer(int now) {


        long time = saveConfig.getTime();
        Calendar calendar = Calendar.getInstance();
        calendar.setTimeInMillis(time);
        if (!isSameDay(Calendar.getInstance(), calendar)) {
            saveConfig.setIndex(0);
            saveConfig.setTime(System.currentTimeMillis());
        }

        long startTime = System.currentTimeMillis();
        // 如果本次没有需要优先保存的玩家信息，执行所有玩家的遍历
        Collection<? extends IPlayerSave> allPlayers = getAllPlayers();

        if (allPlayers == null || allPlayers.isEmpty()) {
            return;
        }
        int index = saveConfig.getIndex();
        if (index >= (allPlayers.size() - 1)) {
            return;
        }

        ArrayList<IPlayerSave> arrayList = new ArrayList<>(allPlayers);

        int startIndex = index;

        int endIndex = index + 8000;
        if (endIndex > (allPlayers.size() - 1)) {
            endIndex = allPlayers.size() - 1;
        }

        List<IPlayerSave> playerSaveList = arrayList.subList(startIndex, endIndex);

        int a = 0;

        int saveCount = 0;
        for (IPlayerSave playerSave : playerSaveList) {

            a++;
            if (saveCount > 300) {
                break;
            }

            if (needImmediateSave(playerSave, now)) {
                saveCount++;
                try {
                    playerSave.nextSaveTime(calcNextSaveTime(playerSave, now));
                    saveData(playerSave);
                } catch (Exception e) {
                    AgentLogUtil.error("save player {" + playerSave.objectId() + "} data error", e);
                }
            }
        }
        saveConfig.setIndex(index + a);
        saveConfig.setTime(System.currentTimeMillis());

        long endTime = System.currentTimeMillis();
        int result = (int) (endTime - startTime);
        if (saveCount > 0) {
            this.recordSaveCount(saveCount);
        }

        AgentLogUtil.saveInfo("全量遍历玩家数据保存 allPlayers={},saveCount={},startIndex={},endIndex={}, 总耗时:{} ms", allPlayers.size(), saveCount, startIndex, endIndex, result);
    }


    public static boolean isSameDay(Calendar cal1, Calendar cal2) {
        if (cal1 != null && cal2 != null) {
            return cal1.get(0) == cal2.get(0) && cal1.get(1) == cal2.get(1) && cal1.get(6) == cal2.get(6);
        } else {
            throw new IllegalArgumentException("The date must not be null");
        }
    }
}