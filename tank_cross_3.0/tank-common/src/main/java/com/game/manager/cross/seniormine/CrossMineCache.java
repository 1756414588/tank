package com.game.manager.cross.seniormine;

import com.game.domain.CrossPlayer;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * @author yeding
 * @create 2019/6/18 11:13
 * @decs
 */
public class CrossMineCache {

    /**
     * 存放 玩家
     */
    public static Map<Long, CrossPlayer> playerMap = new ConcurrentHashMap<>();


    public static CrossPlayer getPlayer(long roleId) {
        return playerMap.get(roleId);
    }

    public static void addPlayer(CrossPlayer player) {
        playerMap.put(player.getRoleId(), player);
    }

    public static CrossPlayer getPalyer(String nick) {
        for (CrossPlayer player : playerMap.values()) {
            if (player.getNick().equals(nick)) {
                return player;
            }
        }
        return null;
    }

}
