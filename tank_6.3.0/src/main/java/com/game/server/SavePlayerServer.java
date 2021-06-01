/**
 * @Title: MainLogicServer.java
 * @Package com.game.server
 * @Description:
 * @author ZhangJun
 * @date 2015年7月29日 下午7:24:35
 * @version V1.0
 */
package com.game.server;

import com.game.domain.Member;
import com.game.domain.Player;
import com.game.domain.Role;
import com.game.domain.p.Arena;
import com.game.domain.p.BossFight;
import com.game.manager.ArenaDataManager;
import com.game.manager.BossDataManager;
import com.game.manager.PartyDataManager;
import com.game.manager.PlayerDataManager;
import com.game.server.thread.SavePlayerThread;
import com.game.server.thread.SaveThread;
import com.game.util.DateHelper;
import com.game.util.LogUtil;
import com.game.util.TimeHelper;
import sun.rmi.runtime.Log;

import java.util.Iterator;

/**
 * @author ZhangJun
 * @ClassName: SavePlayerServer
 * @Description: 玩家数据保存服务器
 * @date 2015年7月29日 下午7:24:35
 */
public class SavePlayerServer extends SaveServer {

    public SavePlayerServer() {
        super("SAVE_PLAYER_SERVER", 50);
    }


    @Override
    public SaveThread createThread(String name) {
        return new SavePlayerThread(name);
    }


    @Override
    public void saveData(Object object) {
        Role role = (Role) object;
        SaveThread thread = threadPool.get((int) (role.getRoleId() % threadNum));
        thread.add(object);

//        LogUtil.error("开始保存玩家数据 roleId={},roleName={}",role.getRoleId(),role.getLord().getNick());

    }

    /**
     * @Title: saveAllPlayer
     * @Description: 保存数据入口 void
     */
    public void saveAllPlayer() {
        PlayerDataManager playerDataManager = GameServer.ac.getBean(PlayerDataManager.class);
        ArenaDataManager arenaDataManager = GameServer.ac.getBean(ArenaDataManager.class);
        PartyDataManager partyDataManager = GameServer.ac.getBean(PartyDataManager.class);
        BossDataManager bossDataManager = GameServer.ac.getBean(BossDataManager.class);

        Iterator<Player> iterator = playerDataManager.getPlayers().values().iterator();
        int now = TimeHelper.getCurrentSecond();
        int saveCount = 0, _3MonthCount = 0;
        int lv = 1;
        while (iterator.hasNext()) {
            Player player = iterator.next();
            try {

                player.lastSaveTime = now;
                player.tickOut();
                //三个月没有登录的玩家 每次关服时候不在保存数据
                if (player.lord != null && player.isThreeLogin()) {
                    _3MonthCount++;
                    continue;
                }
                saveCount++;

                Arena arena = null;
                Member member = null;
                BossFight bossFight = null;
                BossFight altarBossFight = null;

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

                altarBossFight = bossDataManager.getAltarBossFight(player.roleId);

                saveData(new Role(player, arena, member, bossFight, altarBossFight));
            } catch (Exception e) {
                LogUtil.error("Save player data Exception, lordId:" + player.roleId, e);
            }

        }

        LogUtil.save(name + " save player saveCount:{},_3MonthCount={}", saveCount, _3MonthCount);
    }
}
