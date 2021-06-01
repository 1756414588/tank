package com.test.util;

import com.game.constant.ActivityConst;
import com.game.domain.p.Activity;
import com.game.pb.CommonPb;
import com.game.pb.SerializePb;
import com.game.util.LogUtil;
import com.google.protobuf.InvalidProtocolBufferException;

import java.lang.reflect.InvocationTargetException;
import java.sql.*;
import java.util.*;

/**
 * @author GuiJie
 * @description 描述
 * @created 2018/07/10 14:20
 */
public class JdbcTest {

    private static int activityId = 144;


    public static void main(String[] args) throws IllegalAccessException, InstantiationException, NoSuchMethodException, InvocationTargetException {

    }


    private static Map<Integer, String> getTankConfig(String url) {
        try {


            Statement statement = getConnection(url).createStatement();
            //要执行的SQL语句
            String sql = "SELECT tankId,`name` from s_tank;";
            ResultSet rs = statement.executeQuery(sql);

            Map<Integer, String> map = new HashMap<>();
            while (rs.next()) {
                map.put(rs.getInt("tankId"), rs.getString("name"));
            }
            rs.close();
            return map;
        } catch (SQLException e) {
            LogUtil.error(e.getMessage());
        }

        return null;
    }


    static HashMap<String, Connection> connectionMap = new HashMap<>();

    public static void closeConnection() {
        try {
            for (Connection c : connectionMap.values()) {
                c.close();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    private static Connection getConnection(String url) {

        try {
            if (connectionMap.containsKey(url)) {
                return connectionMap.get(url);
            }


            String user = "root";
            String password = "jeC02GfP";
            Class.forName("com.mysql.jdbc.Driver");
            //1.getConnection()方法，连接MySQL数据库！！
            Connection con = DriverManager.getConnection(url, user, password);

            if (!connectionMap.containsKey(url)) {
                connectionMap.put(url, con);
            }

            return connectionMap.get(url);
        } catch (ClassNotFoundException e) {
            LogUtil.error("测试报错  连接数据库 " + url, e);
        } catch (SQLException e) {
            LogUtil.error("测试报错  连接数据库 " + url, e);
        }
        return null;
    }


    private static byte[] getDataRole(String url, long lordId) {
        try {


            Statement statement = getConnection(url).createStatement();
            //要执行的SQL语句
            String sql = "select roleData from p_data WHERE lordId =" + lordId;
            ResultSet rs = statement.executeQuery(sql);

            byte[] roleData = null;

            while (rs.next()) {
                roleData = rs.getBytes("roleData");
            }
            rs.close();
            return roleData;
        } catch (SQLException e) {
            LogUtil.error(e.getMessage());
        }

        return null;
    }

    private static byte[] getData(String url) {
        try {

            Statement statement = getConnection(url).createStatement();
            //要执行的SQL语句
            String sql = "select playerRank from p_usual_activity WHERE activityId =" + activityId;
            ResultSet rs = statement.executeQuery(sql);

            byte[] playerRank = null;

            while (rs.next()) {
                playerRank = rs.getBytes("playerRank");
            }

            rs.close();
            return playerRank;
        } catch (SQLException e) {
            LogUtil.error(e.getMessage());
        }

        return null;
    }

    public static void print() {

        LogUtil.error("开始查询数据");


        printRankInfo("jdbc:mysql://10.66.152.51/tank_132-134");


        printRankInfo("jdbc:mysql://10.66.153.109/tank_135-140");


        printRankInfo("jdbc:mysql://10.66.157.207/tank_203-205");


        printRankInfo("jdbc:mysql://10.66.157.215/tank_206-211");


        printRankInfo("jdbc:mysql://10.66.159.240/tank_228-231");


        printRankInfo("jdbc:mysql://10.66.159.32/tank_232-235");


        printRankInfo("jdbc:mysql://10.66.164.237/tank_288-289");


        printRankInfo("jdbc:mysql://10.66.164.237/tank_290-293");


        printRankInfo("jdbc:mysql://10.66.168.23/tank_332-335");


        printRankInfo("jdbc:mysql://10.66.169.159/tank_336-338");


        printRankInfo("jdbc:mysql://10.66.176.6/tank_389-391");


        printRankInfo("jdbc:mysql://10.66.177.43/tank_392-395");


        printRankInfo("jdbc:mysql://10.66.142.41/tank_423-426");


        printRankInfo("jdbc:mysql://10.66.133.180/tank_427-430");


        printRankInfo("jdbc:mysql://10.66.140.31/tank_448");


        printRankInfo("jdbc:mysql://10.66.140.31/tank_449");


        printRankInfo("jdbc:mysql://10.66.140.31/tank_450");


        printRankInfo("jdbc:mysql://10.66.140.31/tank_451");


        printRankInfo("jdbc:mysql://10.66.166.97/tank_452");


        printRankInfo("jdbc:mysql://10.66.166.97/tank_453");


        printRankInfo("jdbc:mysql://10.66.166.97/tank_454");


        printRankInfo("jdbc:mysql://10.66.166.97/tank_455");


        printRankInfo("jdbc:mysql://10.66.166.97/tank_456");


        printRankInfo("jdbc:mysql://10.66.224.213/tank_457");


        printRankInfo("jdbc:mysql://10.66.224.213/tank_458");


        printRankInfo("jdbc:mysql://10.66.211.37/tank_733-740");


        printRankInfo("jdbc:mysql://10.66.211.44/tank_741-748");


        printRankInfo("jdbc:mysql://10.66.211.50/tank_773-776");


        printRankInfo("jdbc:mysql://10.66.211.53/tank_777-780");


        printRankInfo("jdbc:mysql://10.66.211.60/tank_797-800");


        printRankInfo("jdbc:mysql://10.66.211.61/tank_801-806");


        printRankInfo("jdbc:mysql://10.66.247.12/tank_862");


        printRankInfo("jdbc:mysql://10.66.226.40/tank_863");


        printRankInfo("jdbc:mysql://10.66.226.40/tank_864");


        printRankInfo("jdbc:mysql://10.66.226.40/tank_865");


        printRankInfo("jdbc:mysql://10.66.211.31/tank_866");


        printRankInfo("jdbc:mysql://10.66.211.31/tank_867");


        printRankInfo("jdbc:mysql://10.66.211.31/tank_868");


        printRankInfo("jdbc:mysql://10.66.211.31/tank_869");
        JdbcTest.closeConnection();

        LogUtil.error("开始查询数据 完成");

    }


    public static void printRankInfo(String jdbkUrl) {
        Map<Integer, List<RankInfo>> rank = getRank(jdbkUrl);
        if (rank == null) {
            LogUtil.error("dbName " + jdbkUrl + " is null");
            return;
        }

        for (Integer type : rank.keySet()) {
            List<RankInfo> rankInfos = rank.get(type);

            Collections.sort(rankInfos, new Comparator<RankInfo>() {
                @Override
                public int compare(RankInfo o1, RankInfo o2) {

                    if (o2.getValue() > o1.getValue()) {
                        return 1;
                    } else if (o2.getValue() < o1.getValue()) {
                        return -1;
                    } else {
                        return 0;
                    }

                }
            });

            for (RankInfo r : new ArrayList<>(rankInfos)) {
                int indexOf = rankInfos.indexOf(r);

                int serverId = GameUtil.getServerId(r.getLordId());
                int platNo = GameUtil.getPlatNo(r.getLordId());
                LogUtil.error("====\tserverId={},platNo={},type={},lordId={},value={},rank={},state={}", serverId, platNo, r.getType(), r.getLordId(), r.getValue(), (indexOf + 1), r.getState());

            }

        }


    }


    public static Map<Integer, List<RankInfo>> getRank(String jdbkUrl) {
        try {
            byte[] bytes = getData(jdbkUrl);


            if (bytes == null) {
                LogUtil.error("测试报错 error null 1 " + jdbkUrl);
                return null;
            }

            SerializePb.SerActPlayerRank ser = SerializePb.SerActPlayerRank.parseFrom(bytes);
            List<CommonPb.ActPlayerRank> list = ser.getActPlayerRankList();


            Map<Integer, List<RankInfo>> map = new HashMap<>();

            for (CommonPb.ActPlayerRank e : list) {
                long lordId = e.getLordId();
                int type = e.getRankType();
                long value = e.getRankValue();

                RankInfo rankInfo = new RankInfo();
                rankInfo.setLordId(lordId);
                rankInfo.setType(type);
                rankInfo.setValue(value);
                rankInfo.setRankTime(e.getRankTime());

                byte[] dataRole = getDataRole(jdbkUrl, lordId);
                SerializePb.SerData dataRoleSer = SerializePb.SerData.parseFrom(dataRole);
                Map<Integer, Activity> activitys = new HashMap<>();
                dserActivity(dataRoleSer, activitys);
                Activity activity = activitys.get(activityId);

                if (activity != null) {
                    boolean bln = activity.getStatusMap().containsKey(ActivityConst.TYPE_DEFAULT);
                    rankInfo.setState(bln ? 1 : 0);
                }


                if (!map.containsKey(rankInfo.getType())) {
                    map.put(rankInfo.getType(), new ArrayList<RankInfo>());
                }
                map.get(rankInfo.getType()).add(rankInfo);
            }

            return map;


        } catch (InvalidProtocolBufferException e) {
            LogUtil.error(e.getMessage());
        }
        LogUtil.error("error null 2 " + jdbkUrl);
        return null;
    }

    private static void dserActivity(SerializePb.SerData ser, Map<Integer, Activity> activitys) {
        List<CommonPb.DbActivity> activityList = ser.getActivityList();
        for (CommonPb.DbActivity e : activityList) {
            Activity activity = new Activity();
            activity.setActivityId(e.getActivityId());
            activity.setBeginTime(e.getBeginTime());
            activity.setEndTime(e.getEndTime());
            activity.setOpen(e.getOpen());
            List<Long> statusList = new ArrayList<>();
            if (e.getStatusList() != null) {
                for (Long status : e.getStatusList()) {
                    statusList.add(status);
                }
            }
            activity.setStatusList(statusList);
            Map<Integer, Integer> statusMap = new HashMap<>();
            if (e.getTowIntList() != null) {
                for (CommonPb.TwoInt towInt : e.getTowIntList()) {
                    statusMap.put(towInt.getV1(), towInt.getV2());
                }
            }
            activity.setStatusMap(statusMap);

            Map<Integer, Integer> propMap = new HashMap<>();
            if (e.getPropList() != null) {
                for (CommonPb.TwoInt towInt : e.getPropList()) {
                    propMap.put(towInt.getV1(), towInt.getV2());
                }
            }
            activity.setPropMap(propMap);

            Map<Integer, Integer> saveMap = new HashMap<>();
            if (e.getSaveList() != null) {
                for (CommonPb.TwoInt towInt : e.getSaveList()) {
                    saveMap.put(towInt.getV1(), towInt.getV2());
                }
            }
            activity.setSaveMap(saveMap);

            activitys.put(e.getActivityId(), activity);
        }
    }

}

class RankInfo {
    private long lordId;
    private int type;
    private long value;
    private int state;
    private long rankTime;

    public long getLordId() {
        return lordId;
    }

    public void setLordId(long lordId) {
        this.lordId = lordId;
    }

    public int getType() {
        return type;
    }

    public void setType(int type) {
        this.type = type;
    }

    public long getValue() {
        return value;
    }

    public void setValue(long value) {
        this.value = value;
    }

    public int getState() {
        return state;
    }

    public void setState(int state) {
        this.state = state;
    }

    public long getRankTime() {
        return rankTime;
    }

    public void setRankTime(long rankTime) {
        this.rankTime = rankTime;
    }
}
