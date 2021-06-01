package com.account.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.alibaba.fastjson.JSONObject;
import net.sf.json.JSONArray;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.context.ContextLoader;

import com.account.common.ServerConfig;
import com.account.domain.GameServerConfig;
import com.account.domain.Role;

/**
 * @author TanDonghai
 * @ClassName DBUtil.java
 * @Description TODO
 * @date 创建时间：2016年7月20日 下午4:46:28
 */
public class DBUtil {
    protected static Logger LOG = LoggerFactory.getLogger(DBUtil.class);

    /**
     * 记录最后一次刷新服务器列表的时间
     */
    private static long lastUpdateTime;

    /**
     * 记录服务器信息， key:serverId
     */
    private static Map<Integer, GameServerConfig> serverMap = new HashMap<Integer, GameServerConfig>();

    /**
     * 半小时刷新一次服务器列表
     */
    static final int REFRESH_DELAY = 30 * 60 * 1000;

    /**
     * 查找玩家的角色信息
     *
     * @param url
     * @param user
     * @param password
     * @param roleName
     * @return
     */
    public static Role selectRoleDataInfo(String url, String user, String password, String roleName) {


        if (CheckNull.isNullTrim(url) || CheckNull.isNullTrim(user) || CheckNull.isNullTrim(password)) {
            return null;
        }

        Connection conn = null;
        PreparedStatement pstmt = null;
        try {

            /**
             * 指定连接类型
             */
            Class.forName("com.mysql.jdbc.Driver");
            /**
             *  获取连接
             */
            conn = DriverManager.getConnection(url, user, password);
            String sql = "SELECT l.`lordId`,l.`nick`,l.`level` FROM p_account a INNER JOIN p_lord l ON a.`lordId`=l.`lordId` WHERE l.`nick`=?";
            pstmt = (PreparedStatement) conn.prepareStatement(sql);
            pstmt.setString(1, roleName);
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                Role role = new Role();
                role.setRole_id(rs.getString(1));
                role.setRole_name(rs.getString(2));
                role.setLevel(rs.getString(3));
                return role;
            }

        } catch (Exception e) {
            LOG.info("selectRoleDataInfo exception, url={}", url);
            LOG.error("", e);
        } finally {
            if (null != conn) {
                try {
                    conn.close();
                } catch (SQLException e1) {
                    LOG.error("", e1);
                }
            }
            if (null != pstmt) {
                try {
                    pstmt.close();
                } catch (SQLException e2) {
                    LOG.error("", e2);
                }
            }
        }
        return null;
    }

    /**
     * 查找玩家的角色信息
     *
     * @param url
     * @param user
     * @param password
     * @param accountKey
     * @return
     */
    public static Role selectRoleData(String url, String user, String password, int accountKey, int serverId) {
        if (CheckNull.isNullTrim(url) || CheckNull.isNullTrim(user) || CheckNull.isNullTrim(password)) {
            return null;
        }

        Connection conn = null;
        PreparedStatement pstmt = null;
        try {

            Class.forName("com.mysql.jdbc.Driver");
            conn = DriverManager.getConnection(url, user, password);
            String sql = "SELECT l.`lordId`,l.`nick`,l.`level` FROM p_account a INNER JOIN p_lord l ON a.`lordId`=l.`lordId` WHERE a.`accountKey`=? AND a.`serverId` =?";
            pstmt = (PreparedStatement) conn.prepareStatement(sql);
            pstmt.setInt(1, accountKey);
            pstmt.setInt(2, serverId);

            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                Role role = new Role();
                role.setRole_id(rs.getString(1));
                role.setRole_name(rs.getString(2));
                role.setLevel(rs.getString(3));
                return role;
            }

        } catch (Exception e) {
            LOG.info("selectRoleData exception, url={}", url);
            LOG.error("", e);
        } finally {
            if (null != conn) {
                try {
                    conn.close();
                } catch (SQLException e1) {
                    LOG.error("", e1);
                }
            }
            if (null != pstmt) {
                try {
                    pstmt.close();
                } catch (SQLException e2) {
                    LOG.error("", e2);
                }
            }
        }
        return null;
    }

    /**
     * 查询玩家渠道id
     *
     * @param url
     * @param user
     * @param password
     * @param roleId
     * @return
     */
    public static int selectRolePlanNo(String url, String user, String password, String roleId) {
        if (CheckNull.isNullTrim(url) || CheckNull.isNullTrim(user) || CheckNull.isNullTrim(password)) {
            return 0;
        }
        Connection conn = null;
        PreparedStatement pstmt = null;
        try {

            Class.forName("com.mysql.jdbc.Driver");
            conn = DriverManager.getConnection(url, user, password);

            String sql = "SELECT `platNo` FROM p_account WHERE `lordId`=?";
            pstmt = (PreparedStatement) conn.prepareStatement(sql);
            pstmt.setString(1, roleId);

            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                return rs.getInt(1);
            }

        } catch (Exception e) {
            LOG.info("selectRolePlanNo exception, url={}", url);
            LOG.error("", e);
        } finally {
            if (null != conn) {
                try {
                    conn.close();
                } catch (SQLException e1) {
                    LOG.error("", e1);
                }
            }
            if (null != pstmt) {
                try {
                    pstmt.close();
                } catch (SQLException e2) {
                    LOG.error("", e2);
                }
            }
        }
        return 0;
    }

    /**
     * 查找玩家的角色信息
     *
     * @param url
     * @param user
     * @param password
     * @param roleId
     * @return
     */
    public static Role selectRoleData(String url, String user, String password, String roleId) {
        if (CheckNull.isNullTrim(url) || CheckNull.isNullTrim(user) || CheckNull.isNullTrim(password)) {
            return null;
        }

        Connection conn = null;
        PreparedStatement pstmt = null;
        try {

            Class.forName("com.mysql.jdbc.Driver");
            conn = DriverManager.getConnection(url, user, password);

            String sql = "SELECT `nick`,`vip` FROM p_lord WHERE `lordId`=?";
            pstmt = (PreparedStatement) conn.prepareStatement(sql);
            pstmt.setString(1, roleId);

            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                Role role = new Role();
                role.setRole_name(rs.getString(1));
                role.setVip(rs.getString(2));
                return role;
            }

        } catch (Exception e) {
            LOG.info("selectRoleData 1 exception, url={}", url);
            LOG.error("", e);
        } finally {
            if (null != conn) {
                try {
                    conn.close();
                } catch (SQLException e1) {
                    LOG.error("", e1);
                }
            }
            if (null != pstmt) {
                try {
                    pstmt.close();
                } catch (SQLException e2) {
                    LOG.error("", e2);
                }
            }
        }
        return null;
    }

    /**
     * 查找当前现网所有服务器信息
     *
     * @return
     */
    public static List<GameServerConfig> getAllGameServerConfig() {
        long now = System.currentTimeMillis();

        //没到刷新时间，直接返回记录的服务器信息
        if (now < lastUpdateTime + REFRESH_DELAY) {
            return new ArrayList<GameServerConfig>(serverMap.values());
        }
        ServerConfig sc = ContextLoader.getCurrentWebApplicationContext().getBean(ServerConfig.class);
        List<GameServerConfig> list = new ArrayList<GameServerConfig>();


        if (sc.getGameServerInfo() != null) {
            com.alibaba.fastjson.JSONArray info = getGameServerInfo(sc.getGameServerInfo());
            if (info != null) {
                serverMap.clear();
                for (Object str : info) {
                    JSONObject jsonObject = JSONObject.parseObject(str.toString());
                    GameServerConfig server = new GameServerConfig();
                    server.setDbName(jsonObject.getString("dbName"));
                    server.setOs(jsonObject.getString("os"));
                    server.setPassword(jsonObject.getString("password"));
                    server.setRegion(jsonObject.getString("region"));
                    server.setServerId(jsonObject.getIntValue("serverId"));
                    server.setServerIp(jsonObject.getString("serverIp"));
                    server.setServerName(jsonObject.getString("serverName"));
                    server.setUserName(jsonObject.getString("userName"));
                    server.setGameDbIp(jsonObject.getString("dbIp"));
                    list.add(server);
                    serverMap.put(server.getServerId(), server);
                }
                return list;
            }


        }


        Connection conn = null;
        PreparedStatement pstmt = null;
        try {

            PrintHelper.println("开始查询所有服务器配置, ServerConfig:" + sc);
            Class.forName("com.mysql.jdbc.Driver");
            String gameJdbcUrl = sc.getGameJdbcUrl();
            String gameUser = sc.getGameUser();
            String gamePassword = sc.getGamePassword();
            String gameTable = sc.getGameTable();
            conn = DriverManager.getConnection(gameJdbcUrl, gameUser, gamePassword);

            String sql = "select region,os,serverId,serverName,serverIp,userName,password,dbName,dbIp from " + gameTable;
            pstmt = (PreparedStatement) conn.prepareStatement(sql);

            ResultSet rs = pstmt.executeQuery();

            serverMap.clear();
            while (rs.next()) {
                GameServerConfig server = new GameServerConfig();
                server.setDbName(rs.getString("dbName"));
                server.setOs(rs.getString("os"));
                server.setPassword(rs.getString("password"));
                server.setRegion(rs.getString("region"));
                server.setServerId(rs.getInt("serverId"));
                server.setServerIp(rs.getString("serverIp"));
                server.setServerName(rs.getString("serverName"));
                server.setUserName(rs.getString("userName"));
                server.setGameDbIp(rs.getString("dbIp"));
                // PrintHelper.println("server:" + server);
                list.add(server);
                serverMap.put(server.getServerId(), server);
            }
            lastUpdateTime = now;
            return list;
        } catch (Exception e) {
            LOG.error("", e);
        } finally {
            if (null != conn) {
                try {
                    conn.close();
                } catch (SQLException e1) {
                    LOG.error("", e1);
                }
            }
            if (null != pstmt) {
                try {
                    pstmt.close();
                } catch (SQLException e2) {
                    LOG.error("", e2);
                }
            }
        }
        return null;
    }


    public static com.alibaba.fastjson.JSONArray getGameServerInfo(String url) {
        String gameServerInfoJson = getGameServerInfoJson(url);
        if (gameServerInfoJson == null || "".equals(gameServerInfoJson)) {
            return null;
        }
        return (com.alibaba.fastjson.JSONArray) com.alibaba.fastjson.JSONArray.parse(gameServerInfoJson);
    }


    public static String getGameServerInfoJson(String url) {
        try {
            return HttpHelper.doPost(url, "");
        } catch (Exception e) {
            e.printStackTrace();
        }
        return "";
    }

    /**
     * 根据serverId获取服务器配置信息
     *
     * @param serverId
     * @return
     */
    public static GameServerConfig getServerById(int serverId) {
        getAllGameServerConfig();
        return serverMap.get(serverId);
    }


    /**
     * 到后台查询角色信息
     *
     * @return
     */
    public static List<Map<String, String>> getRoleInfo(List<Integer> platNos, String[] uids) {

        List<Map<String, String>> result = new ArrayList<>();

        Connection conn = null;
        PreparedStatement pstmt = null;
        try {

            StringBuffer sb = new StringBuffer();
            for (String uid : uids) {
                sb.append("'" + uid + "',");
            }

            StringBuffer plat = new StringBuffer();
            for (Integer p : platNos) {
                plat.append(p + ",");
            }

            String s = sb.substring(0, sb.length() - 1);
            String p = plat.substring(0, plat.length() - 1);
            String sql = "select serverId,lordId,nick,`level`,topup,vip,platId,platNo from r_role where platNo in (" + p + ") and platId in (" + s + ")";

            ServerConfig sc = ContextLoader.getCurrentWebApplicationContext().getBean(ServerConfig.class);
            LOG.info("开始查询所有服务器配置, ServerConfig:{}", sc);
            Class.forName("com.mysql.jdbc.Driver");
            String gameJdbcUrl = sc.getGameJdbcUrl();
            String gameUser = sc.getGameUser();
            String gamePassword = sc.getGamePassword();
            conn = DriverManager.getConnection(gameJdbcUrl, gameUser, gamePassword);
            pstmt = (PreparedStatement) conn.prepareStatement(sql);
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                Map<String, String> info = new HashMap<>();
                info.put("serverId", rs.getString("serverId"));
                info.put("lordId", rs.getString("lordId"));
                info.put("nick", rs.getString("nick"));
                info.put("level", rs.getString("level"));
                info.put("topup", rs.getString("topup"));
                info.put("vip", rs.getString("vip"));
                info.put("platNo", rs.getString("platNo"));
                info.put("platId", rs.getString("platId"));
                result.add(info);

            }
            return result;
        } catch (Exception e) {
            LOG.error("", e);
        } finally {
            if (null != conn) {
                try {
                    conn.close();
                } catch (SQLException e1) {
                    LOG.error("", e1);
                }
            }
            if (null != pstmt) {
                try {
                    pstmt.close();
                } catch (SQLException e2) {
                    LOG.error("", e2);
                }
            }
        }
        return null;
    }


    /**
     * 到后台查询角色信息
     *
     * @return
     */
    public static List<Map<String, String>> getRoleInfo(List<Integer> platNos, String userId) {

        List<Map<String, String>> result = new ArrayList<>();

        Connection conn = null;
        PreparedStatement pstmt = null;
        try {

            StringBuffer plat = new StringBuffer();
            for (Integer p : platNos) {
                plat.append(p + ",");
            }
            String p = plat.substring(0, plat.length() - 1);

            String sql = "select serverId,lordId,nick,`level`,topup,vip,platId,platNo from r_role where platNo in (" + p + ") and   platId ='" + userId + "';";

            ServerConfig sc = ContextLoader.getCurrentWebApplicationContext().getBean(ServerConfig.class);
            LOG.info("开始查询所有服务器配置, ServerConfig:{}", sc);
            Class.forName("com.mysql.jdbc.Driver");
            String gameJdbcUrl = sc.getGameJdbcUrl();
            String gameUser = sc.getGameUser();
            String gamePassword = sc.getGamePassword();
            conn = DriverManager.getConnection(gameJdbcUrl, gameUser, gamePassword);
            pstmt = (PreparedStatement) conn.prepareStatement(sql);
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                Map<String, String> info = new HashMap<>();
                info.put("serverId", rs.getString("serverId"));
                info.put("lordId", rs.getString("lordId"));
                info.put("nick", rs.getString("nick"));
                info.put("level", rs.getString("level"));
                info.put("topup", rs.getString("topup"));
                info.put("vip", rs.getString("vip"));
                info.put("platNo", rs.getString("platNo"));
                info.put("platId", rs.getString("platId"));
                result.add(info);

            }
            return result;
        } catch (Exception e) {
            LOG.error("", e);
        } finally {
            if (null != conn) {
                try {
                    conn.close();
                } catch (SQLException e1) {
                    LOG.error("", e1);
                }
            }
            if (null != pstmt) {
                try {
                    pstmt.close();
                } catch (SQLException e2) {
                    LOG.error("", e2);
                }
            }
        }
        return null;
    }
}
