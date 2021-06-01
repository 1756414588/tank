package com.game.constant;

import com.alibaba.fastjson.JSONArray;
import com.game.server.GameServer;
import com.game.service.LoadService;
import com.game.service.LordEquipService;

import java.util.ArrayList;
import java.util.List;

/**
 * @author zhangdh
 * @ClassName: LordEquipConst
 * @Description: 军备相关的常量
 * @date 2017/4/25 13:49
 */
public final class LordEquipConst {
    /**
     * 军备最大的生产队列
     */
    public static final int LEQ_MAX_BUILD_SIZE = 1;

    /**
     * 默认解锁的工匠
     */
    public static final int UNLOCK_TECHNICAL_DEFAULT = 1001;

    /**
     * 军备材料生产默认队列长度
     */
    public static final int MATERIAL_QUEUE_SIZE_DEFAULT = 2;

    /***
     * 军备材料分为2种(1-材料,2-图纸)
     */
    public static final int TAG_1 = 1;//材料
    public static final int TAG_2 = 2;//图纸

    /**
     * 公式计算的因子
     */
    public static final long PRECISION = 10000;

    /**
     * 材料生产速度公式的计算因子
     */
    public static List<Integer> factor = new ArrayList<>();

    public static void loadSystem(LoadService loadService) {
        String s_server_list = loadService.getStringSystemValue(SystemId.LORD_EQUIP_MAT_FACTOR, "");
        if (s_server_list.equals("")) {
            return;
        } else {
            List<Integer> factor0 = new ArrayList<>();
            JSONArray arr = JSONArray.parseArray(s_server_list);
            for (int i = 0; i < arr.size(); i++) {
                factor0.add(arr.getIntValue(i));
            }
            factor = factor0;
            //生产速度计算因子发生变化
            GameServer.ac.getBean(LordEquipService.class).updateLembProductSpeed();
        }
    }
}
