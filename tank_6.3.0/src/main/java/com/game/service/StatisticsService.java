package com.game.service;

import com.game.actor.logplayer.LogPlayerService;
import com.game.dataMgr.StaticMilitaryDataMgr;
import com.game.domain.Player;
import com.game.domain.p.*;
import com.game.domain.p.lordequip.LordEquip;
import com.game.domain.p.saveplayerinfo.LogPlayer;
import com.game.domain.pojo.DeviceOperationStatistics;
import com.game.manager.PlayerDataManager;
import com.game.server.GameServer;
import com.game.server.util.ChannelUtil;
import com.game.util.LogUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.concurrent.ConcurrentHashMap;

/**
 * @ClassName:StatisticsService
 * @author zc
 * @Description:  定时统计玩家数据并计入日志
 * @date 2017年9月19日
 */
@Service
public class StatisticsService {
    @Autowired
    LogPlayerService logPlayerService;

    @Autowired
    private PlayerDataManager playerDataManager;

    /**
     * 设备操作统计信息,key:deviceNo, value:统计记录
     */
    private Map<String, DeviceOperationStatistics> operationStatMap = new ConcurrentHashMap<>();

    /**
     * 增加一次设备的侦查矿点记录
     * 
     * @param player
     * @return 返回增加后的次数
     */
    public int increaseScoutMineCount(Player player) {
        if (null == player) {
            return -1;
        }
        DeviceOperationStatistics stat = getOperationStatistics(player);
        return stat.increaseScoutMine();
    }

    /**
     * 增加一次设备的攻击矿点记录
     * 
     * @param player
     * @return 返回增加后的次数
     */
    public int increaseAttackMineCount(Player player) {
        if (null == player) {
            return -1;
        }
        DeviceOperationStatistics stat = getOperationStatistics(player);
        return stat.increaseAttackMine();
    }

    /**
     * 获取设备的操作统计记录对象，如果不存在，创建后返回，同时记录玩家的角色id和ip
     * 
     * @param player
     * @return 返回玩家设备对应的统计信息
     */
    private DeviceOperationStatistics getOperationStatistics(Player player) {
        String deviceNo = player.account.getDeviceNo();
        DeviceOperationStatistics stat = operationStatMap.get(deviceNo);
        if (null == stat) {
            stat = new DeviceOperationStatistics(deviceNo);
            operationStatMap.put(deviceNo, stat);
        }
        stat.addRoleId(player.roleId);
        stat.addRoleIp(ChannelUtil.getIp(player.ctx, player.roleId));
        return stat;
    }

    /**
     * 打印玩家操作统计记录的定时任务
     */
    public void logOperationStatisticsTimerLogic() {
        int count = 0;
        for (DeviceOperationStatistics stat : operationStatMap.values()) {
            if (stat.isNeedPrint()) {
                LogUtil.statistics(stat.toLogString());
                count++;
            }
        }
        LogUtil.statistics("打印设备操作统计信息，total:" + operationStatMap.size() + ", log:" + count);

        // 清空记录
        operationStatMap.clear();
    }

    private LogPlayer createLogPlayer(Player player) {
        LogPlayer log = new LogPlayer(player.lord.getLordId());
        log.setNick(player.lord.getNick());
        log.setGold(player.lord.getGold());
        log.setLv(player.lord.getLevel());
        log.setServerId(player.account.getServerId());
        log.setVip(player.lord.getVip());
        log.setFight(player.lord.getMaxFight());
        log.setLastLoginDay(player.account.getLoginDate());
        return log;
    }

    /**
     * 统计全服玩家信息
     */
    public void savePlayerData() {
        LogPlayer log = null;
        List<LogPlayer> logPlayers = new ArrayList<>(playerDataManager.getPlayers().size() / 6);

        long mem = 0;
        long start = System.nanoTime();

        StaticMilitaryDataMgr staticMilitaryDataMgr = GameServer.ac.getBean(StaticMilitaryDataMgr.class);
        
        for (Player player : playerDataManager.getPlayers().values()) {
            for (Medal medal : player.medals.get(1).values()) {
                if (log == null) {
                    log = createLogPlayer(player);
                }
                log.addMedal(medal.getMedalId(), medal.getUpLv(), medal.getRefitLv());
            }

            for (LordEquip lordEquip : player.leqInfo.getPutonLordEquips().values()) {
                if (log == null) {
                    log = createLogPlayer(player);
                }
                log.addLordEquip(lordEquip.getEquipId(), lordEquip.getLv(), lordEquip.getLordEquipSkillList());
            }

            for (Map<Integer, Equip> equips : player.equips.values()) {
                for (Equip equip : equips.values()) {
                    if (log == null) {
                        log = createLogPlayer(player);
                    }
                    log.addEquip(equip.getEquipId(), equip.getLv());
                }
            }
            
            for (Map<Integer, Part> parts : player.parts.values()) {
                for (Part part : parts.values()) {
                    if (log == null) {
                        log = createLogPlayer(player);
                    }
                    log.addPart(part.getPartId(), part.getUpLv(), part.getRefitLv(), part.getSmeltLv(), part.getPos());
                }
            }
            
            for (Prop energyStone : player.energyStone.values()) {
                log.addEnergyStone(energyStone.getPropId(), energyStone.getCount());
            }
            
            Map<Integer, Integer> map = new HashMap<>();
            for (MilitaryScience science : player.militarySciences.values()) {
                Integer tankId = staticMilitaryDataMgr.getTankIdByScienceId(science.getMilitaryScienceId());
                if (tankId != null) {
                    Integer value = map.get(tankId);
                    if (value == null) {
                        value = science.getLevel();
                    } else {
                        value += science.getLevel();
                    }
                    map.put(tankId, value);
                }
            }
            for (Entry<Integer, Integer> entry : map.entrySet()) {
                if (log == null) {
                    log = createLogPlayer(player);
                }
                log.addScience(entry.getKey(), entry.getValue());
            }
            
            for (MilitaryMaterial militaryMaterial : player.militaryMaterials.values()) {
                if (log == null) {
                    log = createLogPlayer(player);
                }
                log.addMilitaryMaterial(militaryMaterial.getId(), militaryMaterial.getCount());
            }
            
            if (log != null) {
                mem += log.getMem();
                logPlayers.add(log);
                log = null;
            }
        }
        LogUtil.error(
                "统计全服玩家信息时间消耗（毫秒）:" + (System.nanoTime() - start) / 1000000L + ", mem:" + (mem / 8) / 1024 + "KB");

        logPlayerService.logPlayers(logPlayers);
    }
}
