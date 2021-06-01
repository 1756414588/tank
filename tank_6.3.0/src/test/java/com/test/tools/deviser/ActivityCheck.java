package com.test.tools.deviser;

import com.game.dao.impl.s.StaticDataDao;
import com.game.domain.s.StaticActivityPlan;
import com.game.util.LogUtil;
import merge.MyBatisM;
import merge.MyBatisS;

import java.util.*;

/**
 * @author zhangdh
 * @ClassName: ActivityCheck
 * @Description: 让策划用来检测活动正确性的
 * @date 2017-11-10 16:04
 */
public class ActivityCheck {
    //懒得写配置了，给策划随便用用
    private static String static_JdbcUrl = "jdbc:mysql://192.168.1.66:3306/tank_ini";
    private static String db_JdbcUrl = "jdbc:mysql://192.168.1.66:3306/tank_1";
    private static String user = "root";
    private static String password = "jeC02GfP";
    private static StaticDataDao staticDataDao;

    public static void main(String[] args) throws Exception {
        MyBatisS initDao = new MyBatisS(static_JdbcUrl, user, password);
        MyBatisM myBatisM = new MyBatisM(db_JdbcUrl, user, password);

        //初始化活动配置
        staticDataDao = initDao.getStaticDataDao();
        checkActivityPlan();

    }


    public static void checkActivityPlan() {
        try {
            List<StaticActivityPlan> planList = staticDataDao.selectStaticActivityPlan();
            if (planList == null || planList.isEmpty()) {
                LogUtil.error("s_activity_plan table is empty");
                return;
            }


            Date now = new Date();
            Map<Integer, Map<Integer, List<StaticActivityPlan>>> plans = new HashMap<>();
            for (StaticActivityPlan data : planList) {
                if (data.getOpenBegin() == 0 && data.getBeginTime() == null) {
                    LogUtil.error(String.format("keyId :%d, activityId :%d, 没有配置时间", data.getKeyId(), data.getActivityId()));
                    continue;
                }

                //检测活动与模版值
                if (data.getKeyId() / 10000 != data.getMoldId()) {
                    LogUtil.error(String.format("keyId :%d, activityId :%d, moldId :%d, 模版值与keyId之间对应不上", data.getKeyId(), data.getActivityId(), data.getMoldId()));
                    continue;
                }

                //不处理相对于开服时间开启的活动
                if (data.getBeginTime() == null) {
                    continue;
                }

                //不处理已经过期的活动
                if (data.getEndTime().before(now)) {
                    continue;
                }


                Map<Integer, List<StaticActivityPlan>> modMap = plans.get(data.getMoldId());
                if (modMap == null) {
                    plans.put(data.getMoldId(), modMap = new HashMap<Integer, List<StaticActivityPlan>>());
                }

                List<StaticActivityPlan> activityList = modMap.get(data.getActivityId());
                if (activityList == null) {
                    modMap.put(data.getActivityId(), activityList = new ArrayList<StaticActivityPlan>());
                }
                activityList.add(data);

            }

            for (Map.Entry<Integer, Map<Integer, List<StaticActivityPlan>>> entry : plans.entrySet()) {
                for (Map.Entry<Integer, List<StaticActivityPlan>> planEntry : entry.getValue().entrySet()) {
                    List<StaticActivityPlan> list = planEntry.getValue();
                    if (list.size() > 1) {
                        int activityId = entry.getKey();
                        Collections.sort(list, new Comparator<StaticActivityPlan>() {
                            @Override
                            public int compare(StaticActivityPlan o1, StaticActivityPlan o2) {
                                if (o1.getBeginTime().before(o2.getBeginTime())) {
                                    return -1;
                                } else if (o1.getBeginTime().after(o2.getBeginTime())) {
                                    return 1;
                                } else {
                                    if (o1.getKeyId() < o2.getKeyId()) {
                                        return -1;
                                    } else if (o1.getKeyId() > o2.getKeyId()) {
                                        return 1;
                                    } else {
                                        return 0;
                                    }
                                }
                            }
                        });

                        StaticActivityPlan lastPlan = null;
                        for (StaticActivityPlan data : list) {
                            if (lastPlan == null) {
                                lastPlan = data;
                            } else {
                                if (data.getBeginTime().before(lastPlan.getEndTime())) {
                                    LogUtil.error(String.format("activityId :%d, keyId :%d, keyId :%d 时间上有重叠请处理....", data.getActivityId(), lastPlan.getKeyId(), data.getKeyId()));
                                }
                                lastPlan = data;
                            }
                        }
                    }
                }
            }
        } catch (Exception e) {
            LogUtil.error("", e);
        }

    }


}
