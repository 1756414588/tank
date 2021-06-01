package com.game.domain.pojo;

import com.game.constant.Constant;
import com.game.util.CheckNull;

import java.util.HashSet;
import java.util.Set;

/**
 * @Description 玩家设备（同一设备号的多个玩家累计）行为统计信息纪录类，用于记录一些运营关心的玩家操作相关信息
 * @author TanDonghai
 * @date 创建时间：2017年11月7日 下午2:51:05
 *
 */
public class DeviceOperationStatistics {
    /**
     * 玩家设备号
     */
    private String deviceNo;

    /**
     * 同一设备号的玩家id
     */
    private Set<Long> roleIdSet = new HashSet<>();

    /**
     * 同一设备号的玩家IP
     */
    private Set<String> ipSet = new HashSet<>();

    /**
     * 侦查矿点次数
     */
    private int scoutMineCount;

    /**
     * 攻击矿点次数
     */
    private int attackMineCount;

    public DeviceOperationStatistics() {
    }

    public DeviceOperationStatistics(String deviceNo) {
        this();
        this.deviceNo = deviceNo;
    }

    public void addRoleId(long roleId) {
        roleIdSet.add(roleId);
    }

    public void addRoleIp(String ip) {
        if (!CheckNull.isNullTrim(ip)) {
            ipSet.add(ip.trim());
        }
    }

    /**
     * 增加一次侦察矿点记录
     * 
     * @return 返回增加后的次数
     */
    public int increaseScoutMine() {
        return ++scoutMineCount;
    }

    /**
     * 增加一次攻击矿点记录
     * 
     * @return 返回增加后的次数
     */
    public int increaseAttackMine() {
        return ++attackMineCount;
    }

    /**
     * 重置所有统计数据
     */
    public void resetAll() {
        scoutMineCount = 0;
        attackMineCount = 0;
    }

    /**
     * 根据统计数据判断是否需要打印记录
     * 
     * @return
     */
    public boolean isNeedPrint() {
        return scoutMineCount >= Constant.LOG_SCOUT_MINE_COUNT || attackMineCount >= Constant.LOG_SCOUT_MINE_COUNT;
    }

    /**
     * 返回日志格式的统计信息
     * 
     * @return
     */
    public String toLogString() {
        return "DeviceOperation|" + deviceNo + "|" + scoutMineCount + "|" + attackMineCount + "|" + roleIdSet + "|"
                + ipSet;
    }

    public String getDeviceNo() {
        return deviceNo;
    }

    public void setDeviceNo(String deviceNo) {
        this.deviceNo = deviceNo;
    }

    public Set<Long> getRoleIdSet() {
        return roleIdSet;
    }

    public void setRoleIdSet(Set<Long> roleIdSet) {
        this.roleIdSet = roleIdSet;
    }

    public Set<String> getIpSet() {
        return ipSet;
    }

    public void setIpSet(Set<String> ipSet) {
        this.ipSet = ipSet;
    }

    public int getScoutMineCount() {
        return scoutMineCount;
    }

    public void setScoutMineCount(int scoutMineCount) {
        this.scoutMineCount = scoutMineCount;
    }

    public int getAttackMineCount() {
        return attackMineCount;
    }

    public void setAttackMineCount(int attackMineCount) {
        this.attackMineCount = attackMineCount;
    }
}
