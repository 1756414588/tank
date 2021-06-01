package com.game.persistence;

import com.game.constant.Constant;
import com.game.domain.Member;
import com.game.domain.Player;
import com.game.domain.Role;
import com.game.domain.p.Arena;
import com.game.domain.p.BossFight;
import com.game.manager.ArenaDataManager;
import com.game.manager.BossDataManager;
import com.game.manager.PartyDataManager;
import com.game.manager.PlayerDataManager;
import com.game.server.GameServer;
import com.game.util.LogUtil;
import com.game.util.TimeHelper;
import com.hundredcent.game.aop.domain.IPlayerSave;
import com.hundredcent.game.aop.persistence.player.AbstractSavePlayerTask;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.Collection;
import java.util.Iterator;

/**
 * 保存优化任务
 *
 * @author Tandonghai
 * @date 2018-03-17 10:54
 */
@Component
public class SavePlayerOptimizeTask extends AbstractSavePlayerTask {
    @Autowired
    PlayerDataManager playerDataManager;

    @Autowired
    private BossDataManager bossDataManager;

    @Autowired
    private PartyDataManager partyDataManager;

    @Autowired
    private ArenaDataManager arenaDataManager;

    @Override
    protected boolean playerHaveUnfinishedQueue(IPlayerSave iPlayer) {
        if (iPlayer instanceof Player) {
            Player player = (Player) iPlayer;
            return !(player.buildQue.isEmpty() || player.propQue.isEmpty() || player.refitQue.isEmpty() || player.scienceQue.isEmpty() || player.tankQue_1.isEmpty() || player.tankQue_2.isEmpty());
        }
        return false;
    }

    @Override
    protected Collection<? extends IPlayerSave> getOnlinePlayers() {
        return playerDataManager.getAllOnlinePlayer().values();
    }

    @Override
    protected Collection<? extends IPlayerSave> getAllPlayers() {
        return playerDataManager.getPlayers().values();
    }

    @Override
    protected IPlayerSave getPlayerById(long roleId) {
        return playerDataManager.getPlayer(roleId);
    }

    @Override
    public void saveTimerLogic(int now) {

        try {
            // 检查保存优化功能开放，如果功能关闭，使用原来的保存方式
            if (Constant.SAVE_OPTIMIZE_SWITCH == 0) {
                // 关闭保存优化
                setMainSwith(false);

                oldSavePlayerTimerLogic(now);
            } else {
                setMainSwith(true);
                super.saveTimerLogic(now);
            }
        } catch (Exception e) {
            LogUtil.error("玩家数据保存定时任务出错", e);
        }
    }

    @Override
    protected void saveData(IPlayerSave iPlayer) {
        if (iPlayer instanceof Player) {
            Player player = (Player) iPlayer;
            Arena arena = null;
            Member member = null;
            BossFight bossFight = null;

            int lv = player.lord.getLevel();
            if (lv >= 10) {
                member = partyDataManager.getMemberById(player.roleId);
            }

            if (lv >= 15) {
                arena = arenaDataManager.getArena(player.roleId);
            }

            if (lv >= 30) {
                bossFight = bossDataManager.getBossFight(player.roleId);
            }

            BossFight altarBossFight = bossDataManager.getAltarBossFight(player.roleId);

            GameServer.getInstance().savePlayerServer.saveData(new Role(player, arena, member, bossFight, altarBossFight));
            if (player.immediateSave) {
                player.immediateSave = false;
            }
            player.idelSaveTime = TimeHelper.getCurrentSecond();
        }
    }

    /**
     * 保存优化前的Player相关数据定时保存逻辑
     *
     * @param now
     */
    private void oldSavePlayerTimerLogic(int now) {
        Iterator<Player> iterator = playerDataManager.getPlayers().values().iterator();
        int saveCount = 0;
        int lv = 1;
        while (iterator.hasNext()) {
            Player player = iterator.next();
            if (player.immediateSave || (now - player.lastSaveTime) >= 300) {
                try {
                    if (saveCount >= 500) {
                        break;
                    }

                    saveCount++;
                    player.lastSaveTime = now;
                    Arena arena = null;
                    Member member = null;
                    BossFight bossFight = null;

                    lv = player.lord.getLevel();
                    if (lv >= 10) {
                        member = partyDataManager.getMemberById(player.roleId);
                    }

                    if (lv >= 15) {
                        arena = arenaDataManager.getArena(player.roleId);
                    }

                    if (lv >= 30) {
                        bossFight = bossDataManager.getBossFight(player.roleId);
                    }

                    BossFight altarBossFight = bossDataManager.getAltarBossFight(player.roleId);

                    GameServer.getInstance().savePlayerServer.saveData(new Role(player, arena, member, bossFight, altarBossFight));
                    if (player.immediateSave) {
                        player.immediateSave = false;
                    }
                } catch (Exception e) {
                    LogUtil.error("save player {" + player.roleId + "} data error", e);
                }
            }
        }

        if (saveCount != 0) {
            LogUtil.save("save player count:" + saveCount);
        }
    }
}
