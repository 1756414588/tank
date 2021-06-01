package com.game.domain.s;

import java.util.List;

/**
 * @author zhangdh
 * @ClassName: StaticActMedalofhonor
 * @Description: 荣誉勋章活动
 * @date 2017-10-30 13:44
 */
public class StaticActMedalofhonor {
    //唯一ID
    private int id;
    //活动奖励ID
    private int acitivityId;
    //坦克品质
    private int quality;
    //刷新出来的坦克是单个还是集群 [0,单个坦克 1,坦克集群]
    private int type;
    //每种坦克或集群刷出来的概率权重
    private int probability;
    //特殊掉落奖励[大类,小类,数量,权重]
    private List<List<Integer>> especialprobability;
    //掉落多少勋章
    private int medalawards;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getAcitivityId() {
        return acitivityId;
    }

    public void setAcitivityId(int acitivityId) {
        this.acitivityId = acitivityId;
    }

    public int getQuality() {
        return quality;
    }

    public void setQuality(int quality) {
        this.quality = quality;
    }

    public int getType() {
        return type;
    }

    public void setType(int type) {
        this.type = type;
    }

    public int getProbability() {
        return probability;
    }

    public void setProbability(int probability) {
        this.probability = probability;
    }

    public List<List<Integer>> getEspecialprobability() {
        return especialprobability;
    }

    public void setEspecialprobability(List<List<Integer>> especialprobability) {
        this.especialprobability = especialprobability;
    }

    public int getMedalawards() {
        return medalawards;
    }

    public void setMedalawards(int medalawards) {
        this.medalawards = medalawards;
    }
}
