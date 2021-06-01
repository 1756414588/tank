package com.game.domain.p;


import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * @author GuiJie
 * @description 描述
 * @created 2018/03/20 14:27
 */
public class RedPlanInfo {

    /**
     * 燃料
     */
    private int fuel;
    /**
     * 燃料定时
     */
    private int fuelTime;
    /**
     * 燃料购买次数
     */
    private int fuelCount;
    /**
     * 购买时间用于每天重置
     */
    private int buyTime;
    /**
     * 通关记录
     */
    private Map<Integer, List<Integer>> pointInfo = new HashMap<>();

    /**
     * 当前打到哪一关
     */
    private int nowAreaId;
    /**
     * 当前打到那个小关卡
     */
    private int nowPointId;

    /**
     * 宝箱领取的区域id
     */
    private List<Integer> rewardInfo = new ArrayList<>();
    /**
     * 兑换物品次数
     */
    private Map<Integer, Integer> shopInfo = new HashMap<>();
    /**
     * 每次通关的走动线路
     */
    private Map<Integer, List<Integer>> linePointInfo = new HashMap<>();

    /**
     * 版本号 用于重置活动
     */
    private String version = "";

    /**
     * 清空
     */
    public void clear(int fuelTime) {
        this.buyTime = 0;
        this.pointInfo.clear();
        this.nowAreaId = 0;
        this.nowPointId = 0;
        this.rewardInfo.clear();
        this.shopInfo.clear();
        this.linePointInfo.clear();
        this.fuel = 0;
        this.fuelTime = fuelTime;
        ;

    }

    /**
     * 新活动开启重置以前数据
     *
     * @param version
     * @param fuelValue 默认燃料
     * @param fuelTime  燃料下次回复时间
     */
    public void reset(String version, int fuelValue, int fuelTime) {
        this.version = version;
        this.buyTime = (int) (System.currentTimeMillis() / 1000);
        this.pointInfo.clear();
        this.nowAreaId = 0;
        this.nowPointId = 0;
        this.fuelCount = 0;
        this.rewardInfo.clear();
        this.shopInfo.clear();
        this.linePointInfo.clear();
        this.fuel = fuelValue;
        this.fuelTime = fuelTime;
    }

    public int getFuel() {
        return fuel;
    }

    public void setFuel(int fuel) {
        this.fuel = fuel;
    }

    public Map<Integer, List<Integer>> getPointInfo() {
        return pointInfo;
    }

    public void setPointInfo(Map<Integer, List<Integer>> pointInfo) {
        this.pointInfo = pointInfo;
    }

    public List<Integer> getRewardInfo() {
        return rewardInfo;
    }

    public void setRewardInfo(List<Integer> rewardInfo) {
        this.rewardInfo = rewardInfo;
    }


    public Map<Integer, Integer> getShopInfo() {
        return shopInfo;
    }

    public void setShopInfo(Map<Integer, Integer> shopInfo) {
        this.shopInfo = shopInfo;
    }

    public String getVersion() {
        return version;
    }

    public void setVersion(String version) {
        this.version = version;
    }

    public int getFuelCount() {
        return fuelCount;
    }

    public void setFuelCount(int fuelCount) {
        this.fuelCount = fuelCount;
    }

    public int getNowAreaId() {
        return nowAreaId;
    }

    public void setNowAreaId(int nowAreaId) {
        this.nowAreaId = nowAreaId;
    }

    public int getNowPointId() {
        return nowPointId;
    }

    public void setNowPointId(int nowPointId) {
        this.nowPointId = nowPointId;
    }

    public int getBuyTime() {
        return buyTime;
    }

    public void setBuyTime(int buyTime) {
        this.buyTime = buyTime;
    }

    public Map<Integer, List<Integer>> getLinePointInfo() {
        return linePointInfo;
    }

    public void setLinePointInfo(Map<Integer, List<Integer>> linePointInfo) {
        this.linePointInfo = linePointInfo;
    }

    public int getFuelTime() {
        return fuelTime;
    }

    public void setFuelTime(int fuelTime) {
        this.fuelTime = fuelTime;
    }
}
