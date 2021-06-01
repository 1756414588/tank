package com.game.service;

import com.game.constant.*;
import com.game.dataMgr.StaticFunctionPlanDataMgr;
import com.game.dataMgr.StaticTaskDataMgr;
import com.game.dataMgr.StaticVipDataMgr;
import com.game.domain.Player;
import com.game.domain.p.Lord;
import com.game.domain.p.Task;
import com.game.domain.s.*;
import com.game.manager.PlayerDataManager;
import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb2.*;
import com.game.util.LogHelper;
import com.game.util.PbHelper;
import com.game.util.TimeHelper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.*;

/**
 * @author ChenKui
 * @version 创建时间：2015-9-15 下午4:22:26
 * @declare 任务相关
 */
@Service
public class TaskService {
    @Autowired
    private PlayerDataManager playerDataManager;

    @Autowired
    private StaticTaskDataMgr staticTaskDataMgr;

    @Autowired
    private StaticVipDataMgr staticVipDataMgr;

    @Autowired
    private StaticFunctionPlanDataMgr staticFunctionPlanDataMgr;

    /**
     * 主线任务列表
     *
     * @param handler void
     */
    public void getMajorTaskRq(ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }

        // 将主线任务添加到玩家身上
        Map<Integer, Task> taskMap = player.majorTasks;
        if (taskMap.size() == 0) {
            List<StaticTask> list = staticTaskDataMgr.getInitMajorTask();
            for (StaticTask e : list) {
                Task task = new Task(e.getTaskId());
                taskMap.put(e.getTaskId(), task);
            }
        }

        GetMajorTaskRs.Builder builder = GetMajorTaskRs.newBuilder();
        Iterator<Task> it = taskMap.values().iterator();
        while (it.hasNext()) {
            Task task = it.next();
            int taskId = task.getTaskId();
            StaticTask stask = staticTaskDataMgr.getTaskById(taskId);
            if (stask == null) {
                continue;
            }
            currentMajorTask(player, task, stask);
            if (task.getSchedule() >= stask.getSchedule() && task.getStatus() == 0) {
                task.setStatus(1);
            }
            if (task.getSchedule() < stask.getSchedule()) {
                task.setStatus(0);
            }
            builder.addTask(PbHelper.createTaskPb(task));
        }
        handler.sendMsgToPlayer(GetMajorTaskRs.ext, builder.build());
    }

    /**
     * 日常任务面板
     *
     * @param handler void
     */
    public void getDayiyTaskRq(ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }
        playerDataManager.refreshTask(player);
        List<Task> dayiyTaskList = player.dayiyTask;
        GetDayiyTaskRs.Builder builder = GetDayiyTaskRs.newBuilder();
        Iterator<Task> it = dayiyTaskList.iterator();
        while (it.hasNext()) {
            Task task = it.next();
            int taskId = task.getTaskId();
            StaticTask stask = staticTaskDataMgr.getTaskById(taskId);
            if (stask == null) {
                continue;
            }

            if (stask.getType() != TaskType.TYPE_DAYIY) {// 日常
                continue;
            }

            if (task.getAccept() == 1 && task.getSchedule() >= stask.getSchedule() && task.getStatus() == 0) {
                task.setStatus(1);
            }

            if (task.getSchedule() < stask.getSchedule()) {
                task.setStatus(0);
            }
            builder.addTask(PbHelper.createTaskPb(task));
        }
        builder.setTaskDayiy(PbHelper.createTaskDayiyPb(player.lord));
        handler.sendMsgToPlayer(GetDayiyTaskRs.ext, builder.build());
    }

    /**
     * 充值日常任务次数
     *
     * @param handler void
     */
    public void taskDaylyReset(ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }
        playerDataManager.refreshTask(player);
        Lord lord = player.lord;
        if (lord.getGold() < 25) {
            handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
            return;
        }
        StaticVip staticVip = staticVipDataMgr.getStaticVip(lord.getVip());
        if (staticVip == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }
        if (staticVip.getResetDaily() <= lord.getDayiyCount()) {
            handler.sendErrorMsgToPlayer(GameError.VIP_NOT_ENOUGH);
            return;
        }
        lord.setTaskDayiy(0);
        lord.setDayiyCount(lord.getDayiyCount() + 1);
        playerDataManager.subGold(player, 25, AwardFrom.TASK_DAYLY_RESET);
        TaskDaylyResetRs.Builder builder = TaskDaylyResetRs.newBuilder();
        handler.sendMsgToPlayer(TaskDaylyResetRs.ext, builder.build());
    }

    /**
     * 刷新日常任务
     *
     * @param handler void
     */
    public void refreshDayiyTask(ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }
        playerDataManager.refreshTask(player);
        Lord lord = player.lord;
        if (lord.getGold() < 5) {
            handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
            return;
        }
        List<Integer> refreshTaskList = staticTaskDataMgr.getRadomDayiyTask();
        List<Task> dayiyTaskList = player.dayiyTask;
        if (refreshTaskList.size() != 5 || dayiyTaskList.size() != 5) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }
        RefreshDayiyTaskRs.Builder builder = RefreshDayiyTaskRs.newBuilder();
        Iterator<Task> it = dayiyTaskList.iterator();
        int i = 0;
        while (it.hasNext()) {
            Task task = it.next();
            // if (task.getAccept() == 1) {
            // int dayiy = lord.getTaskDayiy();
            // dayiy = dayiy - 1 < 0 ? 0 : dayiy - 1;
            // lord.setTaskDayiy(dayiy);
            // }
            int ntaskId = refreshTaskList.get(i++);
            task.setAccept(0);
            task.setSchedule(0);
            task.setTaskId(ntaskId);
            task.setStatus(0);
            builder.addTask(PbHelper.createTaskPb(task));
        }
        builder.setTaskDayiy(PbHelper.createTaskDayiyPb(lord));
        playerDataManager.subGold(player, 5, AwardFrom.REFRESH_DAYIY_TASK);
        handler.sendMsgToPlayer(RefreshDayiyTaskRs.ext, builder.build());
    }

    /**
     * 新活跃任务面板
     *
     * @param handler void
     */
    public void getNewLiveTask(ClientHandler handler) {
        if (!staticFunctionPlanDataMgr.isLiveTaskOpen()) return;// 如果新活跃度任务未开启直接返回
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null) {// 判断玩家是否存在
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }
        playerDataManager.refreshTask(player);// 刷新任务
        Map<Integer, Task> taskMap = player.liveTask;// 获取玩家的活跃任务信息
        NewGetLiveTaskRs.Builder builder = NewGetLiveTaskRs.newBuilder();
        Iterator<Task> it = taskMap.values().iterator();
        while (it.hasNext()) {
            Task task = it.next();
            int taskId = task.getTaskId();
            StaticTask stask = staticTaskDataMgr.getTaskActivityById(taskId);

            if (stask == null) {// 配置的任务不存在则跳过
                continue;
            }
            if (stask.getType() != TaskType.TYPE_LIVE) {// 活跃任务
                continue;
            }

            builder.addTask(PbHelper.createTaskPb(task));
        }
        if (player.lord.getTaskLiveTime() == 0) {
            player.lord.setTaskLiveTime(TimeHelper.getLastMonday(new Date()));
        }
        Date time = TimeHelper.getDate(player.lord.getTaskLiveTime());// 玩家刷新活跃度任务的时间
        long end = (long) (time.getTime() / 1000 + TimeHelper.DAY_MS * (7.5) / 1000 + TimeHelper.DAY_MS / 24 / 1000);// 获取当前距离这期活跃度任务结束的时间
        List<StaticTaskLiveActivity> getLiveList = staticTaskDataMgr.getNewTaskLive();// 获取活跃度奖励列表
        if (player.liveTaskAward == null) {
            player.liveTaskAward = new HashMap<Integer, Integer>();
            for (StaticTaskLiveActivity staticTaskLive : getLiveList) {
                player.liveTaskAward.put(staticTaskLive.getLive(), 0);
            }
        }
        for (StaticTaskLiveActivity staticTaskLive : getLiveList) {
            builder.addStates(player.liveTaskAward.get(staticTaskLive.getLive()));
        }
        builder.setEndTime(end);// 返回结束时间
        builder.setTaskLive(PbHelper.createTaskLivePb(player.lord));// 返回玩家的当前的活跃度
        handler.sendMsgToPlayer(NewGetLiveTaskRs.ext, builder.build());
    }

    /**
     * 活跃任务面板
     *
     * @param handler void
     */
    public void getLiveTask(ClientHandler handler) {
        if (staticFunctionPlanDataMgr.isLiveTaskOpen()) return;
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }
        Map<Integer, Task> taskMap = player.liveTask;
        playerDataManager.refreshTask(player);
        GetLiveTaskRs.Builder builder = GetLiveTaskRs.newBuilder();
        Iterator<Task> it = taskMap.values().iterator();
        while (it.hasNext()) {
            Task task = it.next();
            int taskId = task.getTaskId();
            StaticTask stask = staticTaskDataMgr.getTaskById(taskId);
            if (stask == null) {
                continue;
            }
            if (stask.getType() != TaskType.TYPE_LIVE) {// 
                continue;
            }
            if (task.getSchedule() >= stask.getSchedule()) {
                continue;
            }
            if (stask.getTriggerId() != 0) {// 判断有没有前置任务
                continue;
            }
            builder.addTask(PbHelper.createTaskPb(task));
        }
        builder.setTaskLive(PbHelper.createTaskLivePb(player.lord));
        builder.setEndTime(0);
        handler.sendMsgToPlayer(GetLiveTaskRs.ext, builder.build());
    }

    /**
     * 领取任务奖励
     *
     * @param req
     * @param handler void
     */
    public void taskAwardRq(TaskAwardRq req, ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }
        Lord lord = player.lord;
        if (lord == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }
        int taskId = req.getTaskId();
        int awardType = req.getAwardType();
        if (awardType != 1 && awardType != 2) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }
        StaticTask staticTask = staticTaskDataMgr.getTaskById(taskId);
        if (staticTask == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }
        int finishValue = staticTask.getSchedule();
        if (awardType == 2) {
            if (player.lord.getGold() < 5) {
                handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
                return;
            }
            playerDataManager.subGold(player, 5, AwardFrom.TASK_DAYIY_AWARD);
//            playerDataManager.updTask(player, TaskType.COND_DAYIY_TASK_STARS, staticTask.getTaskStar());
            finishValue = 0;
        }
        long scheduleTank = 0;
        Task task = null;
        if (staticTask.getType() == TaskType.TYPE_MAIN) {
            task = player.majorTasks.get(taskId);
            if (task == null) {
                handler.sendErrorMsgToPlayer(GameError.TASK_NO_FINISH);
                return;
            }
            currentMajorTask(player, task, staticTask);
            if (task.getSchedule() < finishValue) {
                handler.sendErrorMsgToPlayer(GameError.TASK_NO_FINISH);
                return;
            }
            scheduleTank = task.getSchedule();
        } else if (staticTask.getType() == TaskType.TYPE_DAYIY) {
            Iterator<Task> it = player.dayiyTask.iterator();
            boolean flag = false;
            while (it.hasNext()) {
                Task next = it.next();
                if (next.getTaskId() == taskId && next.getSchedule() >= finishValue) {
                    playerDataManager.updTask(player, TaskType.COND_DAYIY_TASK_STARS, staticTask.getTaskStar());
                    task = next;
                    it.remove();
                    flag = true;
                    break;
                }
            }
            if (flag) {
                lord.setTaskDayiy(lord.getTaskDayiy() + 1);
            } else {
                handler.sendErrorMsgToPlayer(GameError.TASK_NO_FINISH);
                return;
            }
        }
        if (task == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_TASK);
            return;
        }

        TaskAwardRs.Builder builder = TaskAwardRs.newBuilder();
        List<List<Integer>> awardList = staticTask.getAwardList();
        for (List<Integer> ee : awardList) {
            int type = ee.get(0);
            int id = ee.get(1);
            int count = ee.get(2);
            int keyId = playerDataManager.addAward(player, type, id, count, AwardFrom.TASK_DAYIY_AWARD);
            builder.addAward(PbHelper.createAwardPb(type, id, count, keyId));
        }


        int exp = 0;

        if (staticTask.getType() == 2) {
            exp = exp(player.lord.getLevel(), staticTask.getTaskStar(), staticTask.getExp());
        } else {
            exp = staticTask.getExp();
        }

        int realExp = playerDataManager.realExp(player, exp);
        playerDataManager.addAward(player, AwardType.EXP, 0, exp, AwardFrom.TASK_DAYIY_AWARD);
        builder.addAward(PbHelper.createAwardPb(AwardType.EXP, 0, realExp, 0));
        // 触发下一个任务
        if (staticTask.getType() == TaskType.TYPE_MAIN) {
            player.majorTasks.remove(taskId);
            LogHelper.logMainTask(player, taskId);
            List<StaticTask> triggerList = staticTaskDataMgr.getTriggerTask(taskId);
            if (triggerList != null) {
                for (StaticTask ee : triggerList) {
                    Task etask = new Task(ee.getTaskId());
                    currentMajorTask(player, etask, ee);
                    if (staticTask.getCond() == TaskType.COND_TANK_PRODUCT && ee.getCond() == TaskType.COND_TANK_PRODUCT
                            && staticTask.getParam().size() > 0 && ee.getParam().size() > 0) {
                        int paramId = staticTask.getParam().get(0);
                        int eparamId = ee.getParam().get(0);
                        if (paramId == eparamId) {
                            etask.setSchedule(scheduleTank);
                            if (etask.getSchedule() >= ee.getSchedule()) {
                                etask.setStatus(1);
                            }
                        }
                    }
                    player.majorTasks.put(ee.getTaskId(), etask);
                    builder.addTask(PbHelper.createTaskPb(etask));
                }
            }
        } else if (staticTask.getType() == TaskType.TYPE_DAYIY) {
            // 任务优化：日常任务列表里不能有相同（同星级同任务名）的任务出现
            // 当前存在的日常任务id
            Set<Integer> curTaskIds = new HashSet<>();
            Iterator<Task> it = player.dayiyTask.iterator();
            while (it.hasNext()) {
                Task next = it.next();
                curTaskIds.add(next.getTaskId());
            }
            // 随机出一个新的且不在当前存在任务集合中的一个id
            int ntaskId = staticTaskDataMgr.getOneDayiyTask(curTaskIds);
            Task ntask = new Task(ntaskId);
            player.dayiyTask.add(ntask);
            builder.addTask(PbHelper.createTaskPb(ntask));
        }

        handler.sendMsgToPlayer(TaskAwardRs.ext, builder.build());
    }


    private int exp(int level, int startLv, int exp) {
        StaticDaily c = staticTaskDataMgr.getConfigStaticDaily(level);
        if (c == null) {
            return exp;
        }
        return (int) Math.round(((level * level * c.getA() + c.getB() - 50000) / (Math.pow((c.getC() / 100.0f), 5 - startLv))));
    }


    /*****
     *
     * 领取活跃任务奖励
     * @param req
     * @param handler
     * void
     */
    public void taskLiveAward(TaskLiveAwardRq req, ClientHandler handler) {
        if (staticFunctionPlanDataMgr.isLiveTaskOpen()) return;
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }
        Lord lord = player.lord;
        playerDataManager.refreshTask(player);
        int taskLive = lord.getTaskLive();// 当前总活跃
        int taskAd = lord.getTaskLiveAd();// 已领取活跃奖励的活跃值
        StaticTaskLive staticTaskLive = staticTaskDataMgr.getTaskLive(taskAd, taskLive);
        if (staticTaskLive == null) {
            handler.sendErrorMsgToPlayer(GameError.LIVE_NO_ENOUGH);
            return;
        }
        lord.setTaskLiveAd(staticTaskLive.getLive());
        TaskLiveAwardRs.Builder builder = TaskLiveAwardRs.newBuilder();
        for (List<Integer> e : staticTaskLive.getAwardList()) {
            if (e.size() != 3) {
                continue;
            }
            int type = e.get(0);
            int id = e.get(1);
            int count = e.get(2);
            int keyId = playerDataManager.addAward(player, type, id, count, AwardFrom.TASK_LIVILY_AWARD);
            builder.addAward(PbHelper.createAwardPb(type, id, count, keyId));
        }

        builder.setTaskLive(PbHelper.createTaskLivePb(lord));
        handler.sendMsgToPlayer(TaskLiveAwardRs.ext, builder.build());
    }

    /**
     * 新活跃度的奖励领取协议
     *
     * @param req
     * @param handler void
     */
    public void newTaskLiveAward(NewTaskLiveAwardRq req, ClientHandler handler) {
        if (!staticFunctionPlanDataMgr.isLiveTaskOpen()) return;// 若没开启直接返回
        int awardId = req.getAwardId();// 获取玩家要领取多少活跃度的活跃奖励
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null) {// 判断玩家是否存在
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }
        Lord lord = player.lord;// 玩家角色
        NewTaskLiveAwardRs.Builder builder = NewTaskLiveAwardRs.newBuilder();
        playerDataManager.refreshTask(player);// 刷新任务
        int taskLive = lord.getTaskLive();// 当前总活跃
        if (taskLive >= awardId) {// 如果玩家的活跃度大于玩家想领取的奖励要求活跃度
            if (player.liveTaskAward.containsKey(awardId) && player.liveTaskAward.get(awardId) == 1) {// 活跃度奖励中包含该活跃度的奖励内容并且处于未领取状态
                StaticTaskLiveActivity staticTaskLive = staticTaskDataMgr.getNewTaskLive(awardId);// 获取配置的奖励详细内容
                for (List<Integer> e : staticTaskLive.getAwardList()) {
                    if (e.size() != 3) {
                        continue;
                    }
                    int type = e.get(0);
                    int id = e.get(1);
                    int count = e.get(2);
                    int keyId = playerDataManager.addAward(player, type, id, count, AwardFrom.TASK_LIVILY_AWARD);// 给玩家发放奖励

                    builder.addAward(PbHelper.createAwardPb(type, id, count, keyId));
                }
                player.liveTaskAward.put(awardId, 2);// 修改玩家该奖励的状态为已领取
            }
        } else {// 返回活跃度不够不能领取
            handler.sendErrorMsgToPlayer(GameError.LIVE_NO_ENOUGH);
            return;
        }
        builder.setTaskLive(PbHelper.createTaskLivePb(lord));// 返回玩家的任务列表
        List<StaticTaskLiveActivity> getLiveList = staticTaskDataMgr.getNewTaskLive();// 返还活跃度奖励集合（领取状态）
        for (StaticTaskLiveActivity staticTaskLive : getLiveList) {
            builder.addStates(player.liveTaskAward.get(staticTaskLive.getLive()));
        }
        handler.sendMsgToPlayer(NewTaskLiveAwardRs.ext, builder.build());
    }

    /**
     * 接受日常任务
     *
     * @param req
     * @param handler void
     */
    public void acceptTaskRq(AcceptTaskRq req, ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }
        int taskId = req.getTaskId();
        StaticTask staticTask = staticTaskDataMgr.getTaskById(taskId);
        if (staticTask == null || staticTask.getType() != TaskType.TYPE_DAYIY) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }
        Lord lord = player.lord;
        playerDataManager.refreshTask(player);
        if (lord.getTaskDayiy() >= 5) {
            handler.sendErrorMsgToPlayer(GameError.TASK_DAYIY_FULL);
            return;
        }
        Task task = null;
        boolean flag = false;
        Iterator<Task> it = player.dayiyTask.iterator();
        while (it.hasNext()) {
            Task next = it.next();
            if (next.getAccept() == 1) {
                flag = true;
                break;
            }
            if (next.getTaskId() == taskId) {
                task = next;
            }
        }
        if (flag) {
            handler.sendErrorMsgToPlayer(GameError.HAD_ACCEPT);
            return;
        }
        if (task == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_TASK);
            return;
        }
        task.setAccept(1);
        // lord.setTaskDayiy(lord.getTaskDayiy() + 1);//在完成之后增加
        AcceptTaskRs.Builder builder = AcceptTaskRs.newBuilder();
        handler.sendMsgToPlayer(AcceptTaskRs.ext, builder.build());
    }

    /**
     * 放弃已接的日常任务
     *
     * @param handler void
     */
    public void acceptNoTaskRq(ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }
        playerDataManager.refreshTask(player);
        Iterator<Task> it = player.dayiyTask.iterator();
        while (it.hasNext()) {
            Task next = it.next();
            if (next.getAccept() == 1) {
                next.setAccept(0);
                next.setSchedule(0);
                next.setStatus(0);
                break;
            }
        }
        AcceptNoTaskRs.Builder builder = AcceptNoTaskRs.newBuilder();
        handler.sendMsgToPlayer(AcceptNoTaskRs.ext, builder.build());
    }

    /**
     * 主线任务进度检测并且更新
     *
     * @param player
     * @param task
     * @param stask
     * @return
     */
    public Task currentMajorTask(Player player, Task task, StaticTask stask) {
        if (task == null) {
            return task;
        }

        int cond = stask.getCond();
        long schedule = 0;
        switch (cond) {
            case TaskType.COND_IRON: {// 铁矿升级
                schedule = playerDataManager.getMillTopLv(player, BuildingId.IRON);
                break;
            }
            case TaskType.COND_OIL: {// 石油升级
                schedule = playerDataManager.getMillTopLv(player, BuildingId.OIL);
                break;
            }
            case TaskType.COND_COPPER: {
                schedule = playerDataManager.getMillTopLv(player, BuildingId.COPPER);
                break;
            }
            case TaskType.COND_SILICON: {
                schedule = playerDataManager.getMillTopLv(player, BuildingId.SILICON);
                break;
            }
            case TaskType.COND_STONE: {
                schedule = playerDataManager.getMillTopLv(player, BuildingId.STONE);
                break;
            }
            case TaskType.COND_COMMANDER: {
                schedule = PlayerDataManager.getBuildingLv(BuildingId.COMMAND, player.building);
                break;
            }
            case TaskType.COND_FACTORY: {// 战车工厂升级任务
                schedule = PlayerDataManager.getBuildingLv(BuildingId.FACTORY_1, player.building);
                int tempLv = PlayerDataManager.getBuildingLv(BuildingId.FACTORY_2, player.building);
                if (tempLv > schedule) {
                    schedule = tempLv;
                }
                break;
            }
            case TaskType.COND_REFIT: {
                schedule = PlayerDataManager.getBuildingLv(BuildingId.REFIT, player.building);
                break;
            }
            case TaskType.COND_SCIENCE: {
                schedule = PlayerDataManager.getBuildingLv(BuildingId.TECH, player.building);
                break;
            }
            case TaskType.COND_STORE: {
                schedule = PlayerDataManager.getBuildingLv(BuildingId.WARE_1, player.building);
                int tempLv = PlayerDataManager.getBuildingLv(BuildingId.WARE_2, player.building);
                if (tempLv > schedule) {
                    schedule = tempLv;
                }
                break;
            }
            case TaskType.COND_WORKSHOP: {
                schedule = PlayerDataManager.getBuildingLv(BuildingId.WORKSHOP, player.building);
                break;
            }
            case TaskType.COND_COMBAT: {
                if (stask.getParam().size() > 0) {
                    int combatId = stask.getParam().get(0);
                    if (player.combatId > combatId) {
                        schedule = 1;
                    }
                }
                break;
            }
            case TaskType.COND_FAME: {// 声望等级任务
                schedule = player.lord.getFameLv();
                break;
            }
            case TaskType.COND_MILITARY: {
                schedule = player.lord.getRanks();
                break;
            }
            case TaskType.COND_IRON_PDCT: {// 铁产量
                schedule = playerDataManager.getResourceOut(player, PartyType.RESOURCE_IRON);
                break;
            }
            case TaskType.COND_OIL_PDCT: {// 石油产量
                schedule = playerDataManager.getResourceOut(player, PartyType.RESOURCE_OIL);
                break;
            }
            case TaskType.COND_COPPER_PDCT: {// 铜产量
                schedule = playerDataManager.getResourceOut(player, PartyType.RESOURCE_COPPER);
                break;
            }
            case TaskType.COND_IRON_MADE: {
                schedule = playerDataManager.getMillCount(player, BuildingId.IRON, 1);
                break;
            }
            case TaskType.COND_OIL_MADE: {
                schedule = playerDataManager.getMillCount(player, BuildingId.OIL, 1);
                break;
            }
            case TaskType.COND_COPPER_MADE: {
                schedule = playerDataManager.getMillCount(player, BuildingId.COPPER, 1);
                break;
            }
            case TaskType.COND_SILICON_MADE: {
                schedule = playerDataManager.getMillCount(player, BuildingId.SILICON, 1);
                break;
            }
            case TaskType.COND_STONE_MADE: {
                schedule = playerDataManager.getMillCount(player, BuildingId.STONE, 1);
                break;
            }
            case TaskType.COND_FACTORY_2: {
                schedule = PlayerDataManager.getBuildingLv(BuildingId.FACTORY_2, player.building);
                if (schedule > 1) {
                    schedule = 1;
                }
                break;
            }
            case TaskType.COND_WARE_2: {
                int temp1 = PlayerDataManager.getBuildingLv(BuildingId.WARE_1, player.building);
                int temp2 = PlayerDataManager.getBuildingLv(BuildingId.WARE_2, player.building);
                if (temp1 > 0) {
                    schedule++;
                }
                if (temp2 > 0) {
                    schedule++;
                }
                break;
            }
            case TaskType.COND_BUILD_REFIT: {
                schedule = PlayerDataManager.getBuildingLv(BuildingId.REFIT, player.building);
                if (schedule > 1) {
                    schedule = 1;
                }
                break;
            }
            case TaskType.COND_BUILD_SCIENCE: {
                schedule = PlayerDataManager.getBuildingLv(BuildingId.TECH, player.building);
                if (schedule > 1) {
                    schedule = 1;
                }
                break;
            }
            case TaskType.COND_BUILD_WORKSHOP: {
                schedule = PlayerDataManager.getBuildingLv(BuildingId.WORKSHOP, player.building);
                if (schedule > 1) {
                    schedule = 1;
                }
                break;
            }
            default:
                break;
        }
        if (schedule > task.getSchedule()) {
            task.setSchedule(schedule);
        }
        if (schedule >= stask.getSchedule()) {
            task.setStatus(1);
        }
        return task;
    }

}
