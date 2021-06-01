package com.account.util;

import com.account.dao.impl.RolePointDao;
import com.alibaba.fastjson.JSON;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;

/**
 * @author GuiJie
 * @description 描述
 * @created 2018/03/09 17:50
 */
public class ActionPointUtil {


    private static List<String> tableNames = new ArrayList<>();

    private static List<RolePoint> data = new ArrayList<RolePoint>();

    private static Object lock = new Object();

    /**
     * 插入操作
     *
     * @param rolePointDao
     * @param actionPoint
     */
    public static void insert(RolePointDao rolePointDao, RolePoint actionPoint) {
        synchronized (lock) {
            data.add(actionPoint);
            if (data.size() >= 100) {
                ArrayList<RolePoint> actionPoints = new ArrayList<>(data);
                data.clear();
                _insert(rolePointDao, actionPoints);
            }
        }


    }

    /**
     * 插入操作
     *
     * @param rolePointDao
     * @param actionPoints
     */
    private static void _insert(RolePointDao rolePointDao, List<RolePoint> actionPoints) {
        String tableName = getTableName();

        if (tableNames.isEmpty()) {
            List<String> list = rolePointDao.showTables();
            tableNames.addAll(list);
            //LOG.error("u_role_point表"+ JSON.toJSONString(tableNames));
        }

        if (!tableNames.contains(tableName)) {
            //创建数据库表
            String creaTableSql = getCreaTableSql(tableName);
            //LOG.error("创建u_role_point表"+creaTableSql);
            tableNames.add(tableName);
            rolePointDao.createTable(creaTableSql);
        }

        //添加数据
        String sql = getinsterSql(tableName, actionPoints);
        rolePointDao.insert(sql);
    }


    /**
     * 获取insert sql
     *
     * @param tableName
     * @param actionPoints
     * @return
     */
    private static String getinsterSql(String tableName, List<RolePoint> actionPoints) {

        StringBuilder sb = new StringBuilder();
        sb.append("INSERT INTO `");
        sb.append(tableName);
        sb.append("` ( `platNo`, `deviceNo`,`serverId`, `userId`, `level`, `vip`, `point`, `logTime`) VALUES ");

        for (RolePoint a : actionPoints) {
            sb.append("(");
            sb.append("'" + a.getPlatNo() + "',");
            sb.append("'" + a.getDeviceNo() + "',");
            sb.append("'" + a.getServerId() + "',");
            sb.append("'" + a.getUserId() + "',");
            sb.append("'" + a.getLevel() + "',");
            sb.append("'" + a.getVip() + "',");
            sb.append("'" + a.getPoint() + "',");
            sb.append("'" + a.getLog_time() + "'");
            sb.append("),");
        }

        return sb.toString().substring(0, sb.toString().length() - 1) + ";";
    }

    /**
     * 获取创建表sql
     *
     * @param tableName
     * @return
     */
    private static String getCreaTableSql(String tableName) {
        String creaTableSql = "CREATE TABLE `" + tableName + "` (" +
                "  `id` int(11) NOT NULL AUTO_INCREMENT," +
                "  `platNo` varchar(30) DEFAULT NULL," +
                "  `deviceNo` varchar(256) DEFAULT NULL," +
                "  `serverId` int(11) DEFAULT NULL," +
                "  `userId` varchar(256) DEFAULT NULL," +
                "  `level` int(11) DEFAULT NULL," +
                "  `vip` int(11) DEFAULT NULL," +
                "  `point` int(11) DEFAULT NULL," +
                "  `logTime` varchar(40) DEFAULT NULL," +
                "  PRIMARY KEY (`id`)" +
                ") ENGINE=InnoDB DEFAULT CHARSET=utf8;";

        return creaTableSql;
    }

    /**
     * 获取表名
     *
     * @return
     */
    private static String getTableName() {
        Calendar calendar = Calendar.getInstance();
        int year = calendar.get(Calendar.YEAR);
        int month = calendar.get(Calendar.MONTH) + 1;
        int day_of_month = calendar.get(Calendar.DAY_OF_MONTH);
        return "u_role_point_" + year + "_" + (month < 10 ? "0" + month : month) + "_" + (day_of_month < 10 ? "0" + day_of_month : day_of_month);
    }


}
