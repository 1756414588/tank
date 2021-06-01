package com.game.constant;

import java.util.HashSet;
import java.util.Set;

import com.alibaba.fastjson.JSONArray;
import com.game.service.LoadService;

/**
 * @author zhangdh
 * @ClassName: MineConst
 * @Description: 资源品质
 * @date 2017-3-25 下午4:29:26
 */
public class MineConst {

    public static final int WHITE = 1;// 白
    public static final int GREEN = 2;// 绿
    public static final int BLUE = 3;// 蓝
    public static final int PURPLE = 4;// 紫
    public static final int ORANGE = 5;// 橙

    public static final Set<Integer> openServerList = new HashSet<>();

    public static void loadSystem(LoadService loadService) {
        String s_server_list = loadService.getStringSystemValue(SystemId.WORLD_MINE_OPEN_SERVERS, "");
        if (s_server_list.equals("")) {
            return;
        } else {
            JSONArray arr = JSONArray.parseArray(s_server_list);
            for (int i = 0; i < arr.size(); i++) {
                openServerList.add(arr.getIntValue(i));
            }
        }
    }
}
