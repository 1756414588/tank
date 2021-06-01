package com.game.service.crossmin;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ConcurrentHashMap;

/**
 * @author ：Liu Gui Jie
 * @date ：Created in 2019/4/18 14:05
 * @description：
 */
public class SessionManager {

    private static final ConcurrentHashMap<Integer, Session> sessionMap = new ConcurrentHashMap<>(50);

    public static Session getSession(int serverId) {
        return sessionMap.get(serverId);
    }

    public static void addSession(Session session) {
        SessionManager.sessionMap.put(session.getServerId(), session);
    }

    public static List<Session> getSessionMap() {
        return new ArrayList<>(sessionMap.values());
    }

    public static void removeSession(Session session) {
        SessionManager.sessionMap.remove(session.getServerId());
    }

    public static void removeSession(int serverId) {
        SessionManager.sessionMap.remove(serverId);
    }
}
