package com.game.util;

import com.game.domain.p.RptTank;
import com.game.pb.CommonPb;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class MapUtil {


    /**
     * 把attr 扩大 odds 倍放入targetMap中
     *
     * @param targetMap
     * @param odds
     * @param attr
     */

    public static void multipleAttribute(Map<Integer, Integer> targetMap, int odds, List<List<Integer>> attr) {

        if (attr == null || attr.isEmpty()) {
            return;
        }

        for (List<Integer> integers : attr) {
            int key = integers.get(0);
            int value = integers.get(1) * odds;
            addMapValue(targetMap, key, value);
        }
    }

    /**
     * 把attName,attValue加入targetMap
     */
    public static void addMapValue(Map<Integer, Integer> targetMap, List<List<Integer>> attr) {
        if (attr == null || attr.isEmpty()) {
            return;
        }
        for (List<Integer> integers : attr) {
            if (integers.size() < 2) {
                continue;
            }
            addMapValue(targetMap, integers.get(0), integers.get(1));
        }

    }

    /**
     * 把attName,attValue加入targetMap
     */
    public static void addMapValue(Map<Integer, Integer> targetMap, Integer key, Integer attValue) {
        Integer value = targetMap.get(key);
        if (value == null) {
            targetMap.put(key, attValue);
        } else {
            targetMap.put(key, value + attValue);
        }
    }


    /**
     * 判断Map是否为空
     */
    public static <K, V> boolean isEmpty(Map<K, V> map) {
        return map == null || map.isEmpty();
    }


    /**
     * 把srcMap中的值扩大odds倍放入targetMap中
     *
     * @param srcMap
     * @param targetMap
     */
    public static void multipleAttribute(Map<Integer, Integer> srcMap, float odds, Map<Integer, Integer> targetMap) {
        if (srcMap == null || srcMap.size() == 0 || odds == 0) {
            return;
        }

        for (Integer attributeKey : srcMap.keySet()) {
            Integer value = srcMap.get(attributeKey);
            value = value == null ? 0 : value;
            addMapValue(targetMap, attributeKey, (int) (value * odds));
        }
    }


    /**
     * 把srcMap的值加入targetMap
     *
     * @param targetMap 目标Map
     * @param srcMap    源Map
     */
    public static void addMapValue(Map<Integer, Integer> targetMap, Map<Integer, Integer> srcMap) {
        if (srcMap == null || srcMap.size() == 0)
            return;

        for (Integer attName : srcMap.keySet()) {
            Integer srcValue = srcMap.get(attName);
            if (srcValue == null) continue;

            Integer targetValue = targetMap.get(attName);

            if (targetValue == null) {
                targetMap.put(attName, srcValue);
            } else {
                targetMap.put(attName, targetValue + srcValue);
            }
        }
    }

    /**
     * 组装map
     *
     * @param map
     * @param list
     */
    public static void assembleMap(Map<Integer, Map<Integer, Integer>> map, List<Integer> list) {
        Map<Integer, Integer> prop = map.get(list.get(0));
        if (prop == null) {
            prop = new HashMap<>();
            map.put(list.get(0), prop);
        }
        Integer count = prop.get(list.get(1));
        if (count == null) {
            count = 0;
        }
        count += list.get(2);
        prop.put(list.get(1), count);
    }

    public static void crossMap(Map<Integer, RptTank> am, List<CommonPb.TwoInt> attackTankList) {
        for (CommonPb.TwoInt twoInt : attackTankList) {
            RptTank ta = am.get(twoInt.getV1());
            if (ta == null) {
                ta = new RptTank(twoInt.getV1(), 0);
                am.put(ta.getTankId(), ta);
            }
            ta.setCount(ta.getCount() + twoInt.getV2());
        }
    }


}
