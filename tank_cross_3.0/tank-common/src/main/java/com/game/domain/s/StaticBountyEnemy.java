package com.game.domain.s;

import java.util.List;

/**
 * @author: LiFeng
 * @date: 4.19
 * @description:赏金活动关卡怪物配置
 */
public class StaticBountyEnemy {

    private int id;
    private int stageId;
    private int wave;
    private int serverBegin;
    private int serverEnd;
    private List<List<Integer>> enemy;
    private List<List<Integer>> attr;
    private List<Integer> skillId;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getStageId() {
        return stageId;
    }

    public void setStageId(int stageId) {
        this.stageId = stageId;
    }

    public int getWave() {
        return wave;
    }

    public void setWave(int wave) {
        this.wave = wave;
    }

    public List<List<Integer>> getEnemy() {
        return enemy;
    }

    public void setEnemy(List<List<Integer>> enemy) {
        this.enemy = enemy;
    }

    public List<List<Integer>> getAttr() {
        return attr;
    }

    public void setAttr(List<List<Integer>> attr) {
        this.attr = attr;
    }

    public List<Integer> getSkillId() {
        return skillId;
    }

    public void setSkillId(List<Integer> skillId) {
        this.skillId = skillId;
    }

    public int getServerBegin() {
        return serverBegin;
    }

    public void setServerBegin(int serverBegin) {
        this.serverBegin = serverBegin;
    }

    public int getServerEnd() {
        if( serverEnd ==0 ){
            return 999999;
        }
        return serverEnd;
    }

    public void setServerEnd(int serverEnd) {
        this.serverEnd = serverEnd;
    }
}
