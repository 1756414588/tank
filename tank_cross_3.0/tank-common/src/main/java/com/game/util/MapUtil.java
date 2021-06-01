package com.game.util;

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
  public static void multipleAttribute(
      Map<Integer, Integer> targetMap, int odds, List<List<Integer>> attr) {

    if (attr == null || attr.isEmpty()) {
      return;
    }

    for (List<Integer> integers : attr) {
      int key = integers.get(0);
      int value = integers.get(1) * odds;
      addMapValue(targetMap, key, value);
    }
  }

  /** 把attName,attValue加入targetMap */
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

  /** 把attName,attValue加入targetMap */
  public static void addMapValue(Map<Integer, Integer> targetMap, Integer key, Integer attValue) {
    Integer value = targetMap.get(key);
    if (value == null) {
      targetMap.put(key, attValue);
    } else {
      targetMap.put(key, value + attValue);
    }
  }

  /** 判断Map是否为空 */
  public static <K, V> boolean isEmpty(Map<K, V> map) {
    return map == null || map.isEmpty();
  }

  /**
   * 把srcMap中的值扩大odds倍放入targetMap中
   *
   * @param srcMap
   * @param targetMap
   */
  public static void multipleAttribute(
      Map<Integer, Integer> srcMap, float odds, Map<Integer, Integer> targetMap) {
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
   * @param srcMap 源Map
   */
  public static void addMapValue(Map<Integer, Integer> targetMap, Map<Integer, Integer> srcMap) {
    if (srcMap == null || srcMap.size() == 0) return;

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
}
