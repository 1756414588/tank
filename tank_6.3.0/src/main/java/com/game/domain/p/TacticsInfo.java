package com.game.domain.p;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class TacticsInfo {

    private Map<Integer, Tactics> tacticsMap = new HashMap<>();
    private Map<Integer, Integer> tacticsSliceMap = new HashMap<>();
    private Map<Integer, Integer> tacticsItemMap = new HashMap<>();


    private Map<Integer, List<Integer>> tacticsForm = new HashMap<>();



    /**
     * 每个玩家维护一个唯一的keyid  只增不减
     */
    private int keyid;
    /**
     * 战术大师副本进度
     */
    private int combatId;

    public Map<Integer, Tactics> getTacticsMap() {
        return tacticsMap;
    }

    public Tactics getTactics(int keyid) {
        return tacticsMap.get(keyid);
    }

    public Map<Integer, Integer> getTacticsSliceMap() {
        return tacticsSliceMap;
    }

    public Map<Integer, Integer> getTacticsItemMap() {
        return tacticsItemMap;
    }

    public int getKeyid() {
        return keyid;
    }

    public int nextKeyid() {
        return ++keyid;
    }

    public void setKeyid(int keyid) {
        this.keyid = keyid;
    }

    public int getCombatId() {
        return combatId;
    }

    public void setCombatId(int combatId) {
        this.combatId = combatId;
    }

    public Map<Integer, List<Integer>> getTacticsForm() {
        return tacticsForm;
    }

    public void setTacticsForm(Map<Integer, List<Integer>> tacticsForm) {
        this.tacticsForm = tacticsForm;
    }
}
