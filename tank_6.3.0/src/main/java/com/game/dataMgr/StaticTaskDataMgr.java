package com.game.dataMgr;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import com.game.domain.s.StaticDaily;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.game.constant.TaskType;
import com.game.dao.impl.s.StaticDataDao;
import com.game.domain.s.StaticTask;
import com.game.domain.s.StaticTaskLive;
import com.game.domain.s.StaticTaskLiveActivity;
import com.game.util.RandomHelper;

/**
 * @author ChenKui
 * @version 创建时间：2015-9-16 上午10:04:42
 * @Description: 任务相关
 */
@Component
public class StaticTaskDataMgr extends BaseDataMgr {

    @Autowired
    private StaticDataDao staticDataDao;

    private Map<Integer, StaticTask> majorMap = new HashMap<>();
    private Map<Integer, StaticTask> dayiyMap = new HashMap<>();
    private Map<Integer, StaticTask> liveMap = new HashMap<>();
    private Map<Integer, StaticTask> newLiveMap = new HashMap<>();
    private Map<Integer, List<StaticTask>> triggerMap = new HashMap<>();
    private List<StaticTask> dayiyList = new ArrayList<StaticTask>();
    private List<StaticTask> liveList = new ArrayList<StaticTask>();
    private List<StaticTask> newLiveList = new ArrayList<StaticTask>();
    private List<StaticTaskLive> taskLiveList = new ArrayList<StaticTaskLive>();
    private List<StaticTaskLiveActivity> newTaskLiveList = new ArrayList<StaticTaskLiveActivity>();


    private List<StaticDaily> configStaticDaily = new ArrayList<>();

    @Override
    public void init() {
        List<StaticTask> list = staticDataDao.selectTask();
        List<StaticTask> newList = staticDataDao.selectTaskActivity();
        Map<Integer, StaticTask> majorMap = new HashMap<>();
        Map<Integer, StaticTask> dayiyMap = new HashMap<>();
        Map<Integer, StaticTask> liveMap = new HashMap<>();
        Map<Integer, StaticTask> newLiveMap = new HashMap<>();
        Map<Integer, List<StaticTask>> triggerMap = new HashMap<>();
        List<StaticTask> dayiyList = new ArrayList<StaticTask>();
        List<StaticTask> liveList = new ArrayList<StaticTask>();
        List<StaticTask> newliveList = new ArrayList<StaticTask>();
        for (StaticTask e : list) {
            int triggerId = e.getTriggerId();
            if (e.getType() == TaskType.TYPE_MAIN) {
                majorMap.put(e.getTaskId(), e);
                List<StaticTask> ttlist = triggerMap.get(triggerId);
                if (ttlist == null) {
                    ttlist = new ArrayList<StaticTask>();
                    triggerMap.put(triggerId, ttlist);
                }
                ttlist.add(e);
            } else if (e.getType() == TaskType.TYPE_DAYIY) {
                dayiyMap.put(e.getTaskId(), e);
                dayiyList.add(e);
            } else if (e.getType() == TaskType.TYPE_LIVE) {
                liveMap.put(e.getTaskId(), e);
                liveList.add(e);
            }
        }
        for (StaticTask e : newList) {
            newLiveMap.put(e.getTaskId(), e);
            newliveList.add(e);
        }
        this.majorMap = majorMap;
        this.triggerMap = triggerMap;
        this.dayiyMap = dayiyMap;
        this.dayiyList = dayiyList;
        this.liveMap = liveMap;
        this.liveList = liveList;
        this.newLiveList = newliveList;
        this.newLiveMap = newLiveMap;
        List<StaticTaskLive> taskLiveList = staticDataDao.selectLiveTask();
        this.taskLiveList = taskLiveList;
        List<StaticTaskLiveActivity> newTaskLiveList = staticDataDao.selectLiveTaskActivity();
        this.newTaskLiveList = newTaskLiveList;



        configStaticDaily.clear();
        List<StaticDaily> staticDailies = staticDataDao.selectStaticDaily();
        for (StaticDaily c: staticDailies){
            configStaticDaily.add(c);
        }

    }

    public StaticDaily getConfigStaticDaily(int level) {

        for (StaticDaily c: configStaticDaily){
            if(level >= c.getBeginLv() && level<=c.getEndLv()){
                return c;
            }
        }

        return null;
    }

    public Map<Integer, StaticTask> getMajorMap() {
        return majorMap;
    }

    public Map<Integer, StaticTask> getDayiyMap() {
        return dayiyMap;
    }

    public Map<Integer, StaticTask> getLiveMap() {
        return liveMap;
    }
    
    public Map<Integer, StaticTask> getNewLiveMap() {
        return newLiveMap;
    }

    public StaticTask getTaskById(int taskId) {
        if (majorMap.containsKey(taskId)) {
            return majorMap.get(taskId);
        } else if (dayiyMap.containsKey(taskId)) {
            return dayiyMap.get(taskId);
        } else if (liveMap.containsKey(taskId)) {
            return liveMap.get(taskId);
        }
        return null;
    }
    
    public StaticTask getTaskActivityById(int taskId){
        return newLiveMap.get(taskId);
    }

    public List<StaticTask> getInitMajorTask() {
        return triggerMap.get(0);
    }

    public List<StaticTask> getLiveList() {
        return liveList;
    }
    
    public List<StaticTask> getNewLiveList() {
        return newLiveList;
    }

    public List<Integer> getRadomDayiyTask() {// 随机五个任务
        List<Integer> rs = new ArrayList<Integer>();
        List<Integer> tempList = new ArrayList<Integer>();
        List<Integer> probabilityList = new ArrayList<Integer>();
        int seed = 0;
        for (StaticTask ee : dayiyList) {
            tempList.add(ee.getTaskId());
            probabilityList.add(ee.getProbability());
            seed += ee.getProbability();
        }
        for (int i = 0; i < 5; i++) {
            int total = 0;
            int goal = RandomHelper.randomInSize(seed);
            for (int j = 0; j < probabilityList.size(); j++) {
                int probability = probabilityList.get(j);
                total += probability;
                if (goal <= total) {
                    seed -= probability;
                    rs.add(tempList.remove(j));
                    probabilityList.remove(j);
                    break;
                }
            }
        }
        return rs;
    }

    public int getOneDayiyTask(Set<Integer> curTaskIds) {
        List<StaticTask> dayTasks = new ArrayList<>();
        int seeds[] = { 0, 0 };
        for (StaticTask ee : dayiyList) {
            if (curTaskIds.contains(ee.getTaskId())) {
                continue;
            }
            seeds[0] += ee.getProbability();
            dayTasks.add(ee);
        }
        seeds[0] = RandomHelper.randomInSize(seeds[0]);
        for (StaticTask ee : dayTasks) {
            seeds[1] += ee.getProbability();
            if (seeds[0] <= seeds[1]) {
                return ee.getTaskId();
            }
        }
        return 0;
    }
    /**
     * 
    * @Title: getTriggerTask 
    * @Description: 获得该任务触发的任务
    * @param taskId  该任务编号
    * @return List<StaticTask>   

     */
    public List<StaticTask> getTriggerTask(int taskId) {
        return triggerMap.get(taskId);
    }

    public List<StaticTaskLive> getTaskLive() {
        return taskLiveList;
    }
    
    public List<StaticTaskLiveActivity> getNewTaskLive() {
        return newTaskLiveList;
    }

    public StaticTaskLive getTaskLive(int awardId) {
        for (StaticTaskLive e : taskLiveList) {
            if (e.getLive() == awardId) {
                return e;
            }
        }
        return null;
    }
    
    public StaticTaskLiveActivity getNewTaskLive(int awardId) {
        for (StaticTaskLiveActivity e : newTaskLiveList) {
            if (e.getLive() == awardId) {
                return e;
            }
        }
        return null;
    }

    public StaticTaskLive getTaskLive(int liveAd, int totalLive) {
        for (StaticTaskLive e : taskLiveList) {
            if (e.getLive() > liveAd && e.getLive() <= totalLive) {
                return e;
            }
        }
        return null;
    }
    
    public StaticTaskLiveActivity getNewTaskLive(int liveAd, int totalLive) {
        for (StaticTaskLiveActivity e : newTaskLiveList) {
            if (e.getLive() > liveAd && e.getLive() <= totalLive) {
                return e;
            }
        }
        return null;
    }

    public static void main(String[] args) {

    }
}
