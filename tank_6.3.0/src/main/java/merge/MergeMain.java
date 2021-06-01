package merge;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.alibaba.fastjson.serializer.SerializerFeature;
import com.game.constant.ActivityConst;
import com.game.dao.impl.p.*;
import com.game.dao.impl.s.StaticDataDao;
import com.game.domain.ActivityBase;
import com.game.domain.Member;
import com.game.domain.p.*;
import com.game.domain.s.StaticActivity;
import com.game.domain.s.StaticActivityPlan;
import com.game.pb.CommonPb;
import com.game.pb.CommonPb.TwoInt;
import com.game.pb.SerializePb.SerData;
import com.game.server.util.FileUtil;
import com.game.util.DateHelper;
import com.game.util.HttpUtils;
import com.game.util.LogUtil;
import com.game.util.TimeHelper;
import merge.MergeGame.PartyIdRelation;
import merge.v2.MergeDataMgr;
import merge.v2.MergeUtil;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.channels.FileChannel;
import java.util.*;
import java.util.Map.Entry;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.atomic.AtomicInteger;

public class MergeMain {

    public static boolean isDebug = false;


    public static void main(String[] args) {
        try {
            //使用本地配置生成合服列表文件
            if (args.length > 0) {
                if ("g".equalsIgnoreCase(args[0])) {
                    generateMergeServerList();
                }
                return;
            }
            runMerge(args);
        } catch (Exception e) {
            LogUtil.error(e, e);
            System.exit(-1);
        }
    }

    private static void generateMergeServerList() throws Exception {
        //获取生成目录
        String gPathStr = null;
        String iPathStr = System.getProperty("user.dir");
        gPathStr = iPathStr + File.separatorChar + TimeHelper.getCurrentDay() + File.separatorChar;
        File gPath = new File(gPathStr);
        if (gPath.exists()) {
            LogUtil.error("生成目录已经存在!" + gPathStr);
            return;
        }
        gPath.mkdir();

        List<String> serverList = new ArrayList<>();
        String serversStr = FileUtil.readFile(iPathStr + File.separatorChar + "severs.txt");
        for (String servers : serversStr.split("\n")) {
            serverList.add(servers.replace(" ", "").trim());
        }

        for (String serverNames : serverList) {
            JSONObject serverJson = MServerListReader.readServerList();
            String httpMServerUrl = serverJson.getString("httpMServerUrl");
            LogUtil.error("请求合服配置文件:" + httpMServerUrl + "&nameArr=" + serverNames);

            Map<String, String> parameter = new HashMap<>();
            parameter.put("nameArr", serverNames);
            String serverStr = HttpUtils.sendGet(httpMServerUrl, parameter);
            LogUtil.error("请求合服列表:" + serverStr);

            JSONObject sj = JSONObject.parseObject(serverStr);
            List<MServer> oldServers = JSONArray.parseArray(sj.getJSONArray("list").toString(), MServer.class);

            //根据返回服务器列表id排序,从小到大排序,确保合服完成后,serversetting表内 服务器id字段为合服最小id
            Collections.sort(oldServers, new Comparator<MServer>() {
                @Override
                public int compare(MServer o1, MServer o2) {
                    return o1.getServerId() - o2.getServerId();
                }
            });
            if (oldServers.size() < 2) {
                LogUtil.error("请求合服列表少于2");
                return;
            }

            String pPathStr = gPathStr + serverNames;
            File pPath = new File(pPathStr);
            if (!pPath.exists()) {
                pPath.mkdir();
            }
            String projectName = serverJson.getString("projectName");
            String[] files = new String[]{"m.sh", projectName + "_game.jar"};
            for (int i = 0; i < files.length; i++) {
                copyFileUsingFileChannels(new File(iPathStr + File.separatorChar + files[i]), new File(pPathStr + File.separatorChar + files[i]));
            }
            //lib目录
            File libFile = new File(iPathStr + File.separatorChar + projectName + "_game_lib");
            for (File f : libFile.listFiles()) {
                File destPath = new File(pPathStr + File.separatorChar + projectName + "_game_lib");
                if (!destPath.exists()) {
                    destPath.mkdirs();
                }
                copyFileUsingFileChannels(f, new File(destPath.getAbsolutePath() + File.separatorChar + f.getName()));
            }

            //新的配置文件
            serverJson.getJSONArray("list").clear();
            JSONArray list = JSONArray.parseArray(JSON.toJSONString(oldServers));
            serverJson.getJSONArray("list").addAll(list);

            String jsonString = JSON.toJSONString(serverJson, SerializerFeature.PrettyFormat);

            File configFile = new File(pPathStr + File.separatorChar + "mergeServerList.json");
            configFile.createNewFile();
            FileOutputStream fot = new FileOutputStream(configFile);
            fot.write(jsonString.getBytes());
            fot.flush();
            fot.close();

            //记录合服信息
            File descFile = new File(gPathStr + "合服信息.txt");
            String fileText = null;
            if (!descFile.exists()) {
                descFile.createNewFile();
                fileText = getFormatStr("合服列表", 30) + getFormatStr("参照服务器id配置", 20) + getFormatStr("服务器地址", 20) + getFormatStr("新建目录指向新数据库名字", 30) + getFormatStr("移走目录", 30) + getFormatStr("后台修改数据", 30);
            } else {
                fileText = FileUtil.readFile(descFile.getAbsolutePath());
            }

            //移走目录
            String movePath = "";
            JSONObject new_directory = sj.getJSONObject("new_directory");
            movePath = getFormatStr(new_directory.getString("dbname") + " [" + new_directory.getString("socketurl") + "]", 30) + " ";
            JSONArray used_directory = sj.getJSONArray("used_directory");
            for (int i = 0; i < used_directory.size(); i++) {
                movePath += getFormatStr(used_directory.getJSONObject(i).getString("dbname") + " [" + used_directory.getJSONObject(i).getString("socketurl") + "]", 30) + " ";
            }
            //后台数据
            String midfyDb = sj.getString("db");
            //
            //追加文本
            //合服列表  参照服务器id配置 新数据库名字
            JSONObject server = JSONArray.parseArray(sj.getJSONArray("list").toString()).getJSONObject(0);
            fileText += "\n";
            fileText += getFormatStr(serverNames, 30) + getFormatStr(oldServers.get(0).getServerId() + "", 20) + getFormatStr(server.getString("socketurl"), 20) + getFormatStr("查看合服日志或数据库", 30) + getFormatStr(movePath, 30) + getFormatStr(midfyDb, 30);

            fot = new FileOutputStream(descFile);
            fot.write(fileText.getBytes());
            fot.flush();
            fot.close();
        }

        LogUtil.error("合服文件在：" + gPathStr);
    }

    private static String getFormatStr(String str, int maxLen) {
        int len = maxLen - str.getBytes().length;
        for (int i = 0; i < len; i++) {
            str += " ";
        }
        return str;
    }

    private static void copyFileUsingFileChannels(File source, File dest) throws IOException {
        FileChannel inputChannel = null;
        FileChannel outputChannel = null;
        try {
            inputChannel = new FileInputStream(source).getChannel();
            outputChannel = new FileOutputStream(dest).getChannel();
            outputChannel.transferFrom(inputChannel, 0, inputChannel.size());
        } finally {
            inputChannel.close();
            outputChannel.close();
        }
    }

    @SuppressWarnings("unused")
    private static void repairVipGift() throws Exception {
        LogUtil.error("开始运行修复VIP礼包活动");
        long startTime = System.currentTimeMillis();

        Class.forName("com.mysql.jdbc.Driver");

        JSONObject serverJson = MServerListReader.readServerList();
        String projectName = serverJson.getString("projectName");
//		String httpMServerUrl = serverJson.getString("httpMServerUrl");
        MServer iniDb = JSONObject.toJavaObject(serverJson.getJSONObject("iniDb"), MServer.class);

        List<MServer> oldServers = null;
        if (serverJson.containsKey("list")) {
            LogUtil.error("本地存在合服列表，从本地读取列表。");
            oldServers = JSONArray.parseArray(serverJson.getJSONArray("list").toString(), MServer.class);
        } else {
//			LogUtil.error("本地不存在合服列表，从http地址读取合服列表。");
//			oldServers = findMergeServers(httpMServerUrl, serverNames);
        }

        if (oldServers == null || oldServers.size() < 2) {
            LogUtil.error("合服数量必须大于1");
            System.exit(-1);
        }
        List<Integer> mergeServerIdList = new ArrayList<>();
        //昵称后缀集合
        Set<String> nickSuffixs = new HashSet<>();
        //数据库连接集合
        Set<String> dbUrlSet = new HashSet<>();
        //服务器serverId集合
        Set<Integer> serverIdSet = new HashSet<>();
        //检查配置文件中的serverId和数据库中配置的是否一致
        for (MServer mServer : oldServers) {
            MyBatisM myBatisGame = new MyBatisM(mServer.getDbUrl(), mServer.getUser(), mServer.getPwd());
            mServer.myBatisM = myBatisGame;
            Object[] serverInfo = getServerInfo(myBatisGame);
            int dbServerId = (int) serverInfo[1];
            //判断serverId是否一致
            if (dbServerId != mServer.getServerId()) {
                LogUtil.error("配置serverId和数据库中读取的不一致，服:[" + mServer.getServerId() + "!=" + dbServerId + "]" + " dbUrl:" + mServer.getDbUrl());
                System.exit(-1);
                return;
            }
            //
            mergeServerIdList.addAll(getMergeServerIdList(myBatisGame));
            myBatisGame = null;
            serverInfo = null;
            //昵称重复
            mServer.setNickSuffix(mServer.getNickSuffix().trim());
            if (nickSuffixs.contains(mServer.getNickSuffix())) {
                LogUtil.error("昵称后缀重复，会导致昵称不唯一。");
                System.exit(-1);
            }
            nickSuffixs.add(mServer.getNickSuffix());
            //db重复，存在合服，只需要合服中第一个
            if (dbUrlSet.contains(mServer.getDbUrl())) {
                LogUtil.error("合服列表中存在已合服，删除被合服的服务器重新合服，留合服中最终那服");
                System.exit(-1);
            }
            dbUrlSet.add(mServer.getDbUrl());
            //serverId重复
            if (serverIdSet.contains(mServer.getServerId())) {
                LogUtil.error("合服列表存在重复serverId服务器");
                System.exit(-1);
            }
            serverIdSet.add(mServer.getServerId());
        }
        nickSuffixs.clear();
        nickSuffixs = null;
        dbUrlSet.clear();
        dbUrlSet = null;
        serverIdSet.clear();
        serverIdSet = null;
        //查询并生成数据库名
        String dbName = createNewDbName(projectName, mergeServerIdList);
        LogUtil.error("合成数据库名:" + dbName);

        MServer oldDatamServer = oldServers.get(0);
        //jdbc:mysql://localhost:3306/tank_1
        String dbUrl = oldDatamServer.getDbUrl();
        int index = dbUrl.lastIndexOf("/");
        dbUrl = dbUrl.substring(0, index + 1) + dbName;

        MServer newServer = new MServer();
        newServer.setServerId(oldDatamServer.getServerId());
        newServer.setUser(oldDatamServer.getUser());
        newServer.setPwd(oldDatamServer.getPwd());
        newServer.setDbUrl(dbUrl);

        newServer.myBatisM = new MyBatisM(newServer.getDbUrl(), newServer.getUser(), newServer.getPwd());

        MyBatisM myBatisInit = new MyBatisM(iniDb.getDbUrl(), iniDb.getUser(), iniDb.getPwd());

        repairVipGift(oldServers, newServer.myBatisM, myBatisInit);

        long endTime = System.currentTimeMillis();
        LogUtil.error("修复VIP礼包活动完成:" + (endTime - startTime) / 1000 + "s");
    }

    private static void repairVipGift(List<MServer> oldServers, MyBatisM myBatisMain, MyBatisM myBatisInit) throws Exception {
        int actBegin = getActBegin(myBatisMain, myBatisInit, ActivityConst.ACT_VIP_GIFT);
        if (actBegin == 0) {
            LogUtil.error(ActivityConst.ACT_VIP_GIFT + "活动未开启");
            System.exit(-1);
            return;
        }
        LogUtil.error(ActivityConst.ACT_VIP_GIFT + "活动开启时间：" + actBegin);

        Map<Integer, MServer> serverMap = new HashMap<>();
        for (MServer mServer : oldServers) {
            serverMap.put(mServer.getServerId(), mServer);
        }

        LordRelationDao lordRelationDao = new LordRelationDao();
        lordRelationDao.setSqlSessionFactory(myBatisMain.getSqlSessionFactory());

        //对应服务器 旧角色id 值新角色id
        LogUtil.error("查询合服后玩家总数");
        int lordNum = 0;
        Map<Integer, Map<Long, Long>> serverOld2newIdMap = new HashMap<>();
        for (LordRelation lordRelation : lordRelationDao.selectAllLordRelation()) {
            Map<Long, Long> old2newIdMap = serverOld2newIdMap.get(lordRelation.getOldServerId());
            if (old2newIdMap == null) {
                old2newIdMap = new HashMap<>();
                serverOld2newIdMap.put(lordRelation.getOldServerId(), old2newIdMap);
            }
            old2newIdMap.put(lordRelation.getOldLordId(), lordRelation.getNewLordId());
            lordNum++;
        }
        LogUtil.error("合服后玩家总数" + lordNum);

        if (lordNum == 0) {
            return;
        }
        float curNum = 0;

        DataNewDao newDataNewDao = new DataNewDao();
        newDataNewDao.setSqlSessionFactory(myBatisMain.getSqlSessionFactory());

        for (Entry<Integer, Map<Long, Long>> entry : serverOld2newIdMap.entrySet()) {
            int serverId = entry.getKey();

            MServer mServer = serverMap.get(serverId);

            DataNewDao oldDataNewDao = new DataNewDao();
            oldDataNewDao.setSqlSessionFactory(mServer.myBatisM.getSqlSessionFactory());

            Map<Long, Long> playeroldId2newIdMap = entry.getValue();
            for (Entry<Long, Long> oldId2newIdE : playeroldId2newIdMap.entrySet()) {
                curNum++;

                long oldId = oldId2newIdE.getKey();
                long newId = oldId2newIdE.getValue();

                boolean isReseted = false;

                //查询新数据库角色 和 旧数据库角色 进行修复
                Set<Integer> oldRecvStatus = new HashSet<>();//旧数据玩家已经领取奖励id
                DataNew olddataNew = oldDataNewDao.selectData(oldId);

                SerData oldSer = SerData.parseFrom(olddataNew.getRoleData());
                List<CommonPb.DbActivity> oldActivityList = oldSer.getActivityList();
                for (CommonPb.DbActivity e : oldActivityList) {
                    if (e.getActivityId() == ActivityConst.ACT_VIP_GIFT) {
                        if (actBegin == e.getBeginTime()) {
                            break;
                        }
                        isReseted = true;
                        for (TwoInt twoInt : e.getTowIntList()) {
                            oldRecvStatus.add(twoInt.getV1());
                        }
                        break;
                    }
                }
                if (!isReseted) {//存在活动且开启时间不一致，表示合服之后会重置
                    int r = (int) (curNum / lordNum * 100.0F);
                    LogUtil.error("进度 " + r + "% " + serverId + " [" + oldId + "->" + newId + "] 未重置 ");
                    continue;
                }

                Set<Integer> newRecvStatus = new HashSet<>();//新数据玩家已经领取奖励id
                DataNew newdataNew = newDataNewDao.selectData(newId);

                SerData.Builder newSer = SerData.parseFrom(newdataNew.getRoleData()).toBuilder();
                List<CommonPb.DbActivity.Builder> newActivityList = newSer.getActivityBuilderList();
                for (CommonPb.DbActivity.Builder e : newActivityList) {
                    if (e.getActivityId() == ActivityConst.ACT_VIP_GIFT) {
                        for (TwoInt twoInt : e.getTowIntList()) {
                            newRecvStatus.add(twoInt.getV1());
                        }
                        //修复过程  新的覆盖旧数据
                        e.setBeginTime(actBegin);//修改成合并服的开启时间
                        e.clearTowInt();

                        Set<Integer> oRecvStatus = new HashSet<>(oldRecvStatus);
                        Set<Integer> nRecvStatus = new HashSet<>(newRecvStatus);

                        oldRecvStatus.removeAll(newRecvStatus);
                        newRecvStatus.addAll(oldRecvStatus);
                        for (Integer vip : newRecvStatus) {
                            TwoInt.Builder twoInt = TwoInt.newBuilder();
                            twoInt.setV1(vip);
                            twoInt.setV2(1);
                            e.addTowInt(twoInt);
                        }

                        Set<Integer> finalRecvStatus = new HashSet<>();
                        for (TwoInt twoInt : e.getTowIntList()) {
                            finalRecvStatus.add(twoInt.getV1());
                        }
                        newdataNew.setRoleData(newSer.build().toByteArray());

                        newDataNewDao.updateData(newdataNew);

                        int r = (int) (curNum / lordNum * 100.0F);

                        LogUtil.error("进度 " + r + "% " + serverId + " [" + oldId + "->" + newId + "] 已重置 " + JSONObject.toJSONString(oRecvStatus) + "  " + JSONObject.toJSONString(nRecvStatus) + "  " + JSONObject.toJSONString(finalRecvStatus));
                        break;
                    }
                }

//				LogUtil.error(serverId+ " [" +oldId + "->" + newId+ "] 已重置 " + JSONObject.toJSONString(oldRecvStatus) + "  " + JSONObject.toJSONString(newRecvStatus) + " " +newSer.build());
            }
        }
    }

    public static void runMerge(String[] serverNames) throws Exception {
        LogUtil.error("开始运行合服");
        long startTime = System.currentTimeMillis();

        Class.forName("com.mysql.jdbc.Driver");

        JSONObject serverJson = MServerListReader.readServerList();
        String projectName = serverJson.getString("projectName");
        int smallLordLv = serverJson.getIntValue("smallLordLv");
        MServer iniDb = JSONObject.toJavaObject(serverJson.getJSONObject("iniDb"), MServer.class);

        List<MServer> oldServers = null;
        if (serverJson.containsKey("list")) {
            LogUtil.error("本地存在合服列表，从本地读取列表。");
            oldServers = JSONArray.parseArray(serverJson.getJSONArray("list").toString(), MServer.class);
        }

        if (oldServers == null || oldServers.size() < 2) {
            LogUtil.error("合服数量必须大于1");
            System.exit(-1);
        }
        List<Integer> mergeServerIdList = new ArrayList<>();
        //昵称后缀集合
        Set<String> nickSuffixs = new HashSet<>();
        //数据库连接集合
        Set<String> dbUrlSet = new HashSet<>();
        //服务器serverId集合
        Set<Integer> serverIdSet = new HashSet<>();
        //检查配置文件中的serverId和数据库中配置的是否一致
        for (MServer mServer : oldServers) {
            MyBatisM myBatisGame = new MyBatisM(mServer.getDbUrl(), mServer.getUser(), mServer.getPwd());
            mServer.myBatisM = myBatisGame;
            Object[] serverInfo = getServerInfo(myBatisGame);
            mServer.setServerName((String) serverInfo[0]);
            int dbServerId = (int) serverInfo[1];
            //判断serverId是否一致
            if (dbServerId != mServer.getServerId()) {
                LogUtil.error("配置serverId和数据库中读取的不一致，服:[" + mServer.getServerId() + "!=" + dbServerId + "]" + " dbUrl:" + mServer.getDbUrl());
                System.exit(-1);
                return;
            }
            //
            List<Integer> msil = getMergeServerIdList(myBatisGame);
            mServer.hasMerge = msil.size() > 1;
            mergeServerIdList.addAll(msil);
            myBatisGame = null;
            serverInfo = null;
            //昵称重复
            mServer.setNickSuffix(mServer.getNickSuffix().trim());
            if (nickSuffixs.contains(mServer.getNickSuffix())) {
                LogUtil.error("昵称后缀重复，会导致昵称不唯一。");
                System.exit(-1);
            }
            nickSuffixs.add(mServer.getNickSuffix());
            //db重复，存在合服，只需要合服中第一个
            if (dbUrlSet.contains(mServer.getDbUrl())) {
                LogUtil.error("合服列表中存在已合服，删除被合服的服务器重新合服，留合服中最终那服");
                System.exit(-1);
            }
            dbUrlSet.add(mServer.getDbUrl());
            //serverId重复
            if (serverIdSet.contains(mServer.getServerId())) {
                LogUtil.error("合服列表存在重复serverId服务器");
                System.exit(-1);
            }
            serverIdSet.add(mServer.getServerId());
        }
        nickSuffixs.clear();
        nickSuffixs = null;
        dbUrlSet.clear();
        dbUrlSet = null;
        serverIdSet.clear();
        serverIdSet = null;
        //查询并生成数据库名
        String dbName = createNewDbName(projectName, mergeServerIdList);

        LogUtil.error("新数据库名:" + dbName);
        //判断是否存在数据库并创建
        MServer master = createNewMServer(dbName, oldServers.get(0));
        MyBatisM myBatisMain = master.myBatisM;
        String mainServerName = (String) MergeMain.getServerInfo(myBatisMain)[0];

        if (isDataNotNull(myBatisMain)) {
            LogUtil.error("最终合成服(" + mainServerName + " dbUrl=" + master.getDbUrl() + ")数据库数据不为空！！！");
            System.exit(-1);
        }
        //如果不存在，则创建合服关系表p_lord_relation
        if (!pLordRelationHasData(myBatisMain)) {
            LogUtil.error("最终合成服(" + mainServerName + " dbUrl=" + master.getDbUrl() + ") p_lord_relation 不为空");
            System.exit(-1);
        }

        LogUtil.error("此次清除小号规则：已取名-VIP0-最后登录小于30天-角色等级小于等于" + smallLordLv);
        MergeDataMgr dataMgr = new MergeDataMgr(iniDb, master);
        MergeDataMgr.SMALL_LORD_LEVEL = smallLordLv;

        LogUtil.error("将合成新服:" + mainServerName + "[" + master.getServerId() + "] dbUrl:" + master.getDbUrl());

        int timer = 10;
        LogUtil.error(timer + "后开始合服");
        for (int j = timer; j > 0; j--) {
            LogUtil.error("倒计时:" + j);
            Thread.sleep(1000);
        }
        LogUtil.error("正在进行合服");
        MergeUtil.mergeSlaveInThread(dataMgr, oldServers);

        printServerInfo(myBatisMain, dbName, smallLordLv);

        long endTime = System.currentTimeMillis();
        LogUtil.error("已合成新服:" + mainServerName + "[" + master.getServerId() + "],本次合服消耗：" + (endTime - startTime) / 1000 + "s");
    }

    private static void copyOldPlordRelation(String projectName, MServer mServer, MyBatisM myBatisMain) {
        MyBatisM myBatis = mServer.myBatisM;
        LordRelationDao lordRelationDao = new LordRelationDao();
        lordRelationDao.setSqlSessionFactory(myBatis.getSqlSessionFactory());

        List<String> tabList = new ArrayList<>();
        Set<String> tabSet = new HashSet<>();
        for (String tabelName : lordRelationDao.showTables()) {
            if (tabelName.startsWith("p_lord_relation")) {
                tabList.add(tabelName);
            }
            tabSet.add(tabelName);
        }

        if (tabList.size() == 0) {
            return;
        }

        //历史id对应关系
        LordRelationDao newDblordRelationDao = new LordRelationDao();
        newDblordRelationDao.setSqlSessionFactory(myBatisMain.getSqlSessionFactory());
        List<Integer> mergeServerIdList = getMergeServerIdList(myBatis);
        String dbName = createNewDbName(projectName, mergeServerIdList);

        for (String tabName : tabList) {
            String oldTab = tabName;
            if (tabName.equals("p_lord_relation")) {
                tabName += "_" + dbName;
            }
            List<LordRelation> list = lordRelationDao.selectAllLordRelationByTab(oldTab);
            if (list.size() == 0) {
                continue;
            }
            String createTableSql = lordRelationDao.showCreateTable(oldTab).replace(oldTab, tabName);
            newDblordRelationDao.createTable(createTableSql);
            for (LordRelation lordRelation : list) {
                newDblordRelationDao.insertLordRelationByTab(lordRelation, tabName);
            }
        }
    }

    /**
     * 补偿竞技场积分
     */
    private static void repairArenaScore(List<MServer> oldServers, MyBatisM myBatisMain) throws Exception {
        //第一次合服竞技场数据清空了，但是后来需要把以前的积分给玩家还原。
        ArenaDao arenaDaoMain = new ArenaDao();
        arenaDaoMain.setSqlSessionFactory(myBatisMain.getSqlSessionFactory());

        LordRelationDao lordRelationDao = new LordRelationDao();
        lordRelationDao.setSqlSessionFactory(myBatisMain.getSqlSessionFactory());

        //对应服务器 旧角色id 值新角色id
        LogUtil.error("查询需要补偿分数玩家数");
        int lordNum = 0;
        Map<Integer, Map<Long, Long>> serverOld2newIdMap = new HashMap<>();
        for (LordRelation lordRelation : lordRelationDao.selectAllLordRelation()) {
            Map<Long, Long> old2newIdMap = serverOld2newIdMap.get(lordRelation.getOldServerId());
            if (old2newIdMap == null) {
                old2newIdMap = new HashMap<>();
                serverOld2newIdMap.put(lordRelation.getOldServerId(), old2newIdMap);
            }
            old2newIdMap.put(lordRelation.getOldLordId(), lordRelation.getNewLordId());
            lordNum++;
        }
        LogUtil.error("要补偿分数玩家数:" + lordNum);

        if (lordNum == 0) {
            return;
        }

        //所有旧服上且已经合服到新服玩家竞技场数据 ,已替换成新角色id
        Map<Long, Arena> lordIdArenaMap = new HashMap<>();

        for (MServer mServer : oldServers) {
            MergeGame mergeGame = mServer.mergeGame;
            LogUtil.error("查询竞技场:" + mergeGame.serverName + "[" + mergeGame.serverId + "]");

            ArenaDao arenaDaoGame = new ArenaDao();
            arenaDaoGame.setSqlSessionFactory(mergeGame.myBatisGame.getSqlSessionFactory());

            Map<Long, Long> old2newIdMap = serverOld2newIdMap.get(mServer.getServerId());
            if (old2newIdMap == null) {
                continue;
            }

            List<Arena> arenasGame = arenaDaoGame.load();
            for (Arena arena : arenasGame) {
                Long newLordId = old2newIdMap.get(arena.getLordId());
                if (newLordId == null) {
                    continue;
                }
                arena.setLordId(newLordId);
                lordIdArenaMap.put(newLordId, arena);
            }

            arenaDaoGame = null;
        }

        //竞技场当前最大排名
        int rank = 0;
        //如果新服上存在旧玩家 更新积分
        List<Arena> arenasMain = arenaDaoMain.load();
        for (Arena arena : arenasMain) {
            if (arena.getRank() > rank) {
                rank = arena.getRank();
            }
            Arena oldArena = lordIdArenaMap.remove(arena.getLordId());
            if (oldArena != null) {//更新积分
                int oldScore = arena.getScore();
                arena.setScore(arena.getScore() + oldArena.getScore());
                arenaDaoMain.updateArena(arena);
                LogUtil.error("更新积分[lordId=" + arena.getLordId() + ":rank=" + arena.getRank() + "]:" + oldScore + " + " + oldArena.getScore() + " = " + arena.getScore());
            }
        }
        //旧服且已经合到新服且当前未进入竞技场  补全竞技场数据
        List<Arena> remainArenaList = new ArrayList<>(lordIdArenaMap.values());
        //将剩余数据排序后追加到排行榜
        Collections.sort(remainArenaList, new Comparator<Arena>() {

            @Override
            public int compare(Arena o1, Arena o2) {
                if (o1.getRank() != o2.getRank()) {
                    return o1.getRank() - o2.getRank();
                }
                if (o1.getFight() != o2.getFight()) {
                    long l = o2.getFight() - o1.getFight();
                    if (l > 0) {
                        return 1;
                    } else {
                        return -1;
                    }

                }
                if (o1.getScore() != o2.getScore()) {
                    return o2.getScore() - o1.getScore();
                }
                return (int) (o1.getLordId() - o2.getLordId());
            }
        });

        for (Arena arena : remainArenaList) {
            arena.setRank(++rank);
            arenaDaoMain.insertArena(arena);
            arenaDaoMain.updateArena(arena);

            LogUtil.error("加入竞技场[lordId=" + arena.getLordId() + ":rank=" + arena.getRank() + "]:" + arena.getScore());
        }
    }

    private static void startMerge(List<MServer> oldServers, MyBatisM myBatisMain) throws Exception {
        for (MServer mServer : oldServers) {
            Map<String, PartyIdRelation> partyIdRelationMap = new HashMap<>();
            Map<Long, Long> lordIdMap = new ConcurrentHashMap<>();
            Map<Long, Member> memberMap = new HashMap<>();
            AtomicInteger times = new AtomicInteger(0);

            MergeGame mergeGame = mServer.mergeGame;
            mergeGame.nickSuffix = mServer.getNickSuffix();
            //新统计小号
            mergeGame.joinSmailId();
            //工会处理
            mergeGame.uionParty(partyIdRelationMap, memberMap);

            List<Long> lordIds = mergeGame.getPlayerIds();
            List<Long> saveLordIds = new ArrayList<>(lordIds);
            //分线程合并
            int threadNum = 10;
            int saveNum = lordIds.size() / threadNum;
            if (saveNum == 0) {
                mergeGame.unionPlayer(partyIdRelationMap, memberMap, lordIdMap, saveLordIds, lordIds, times);
            } else {
                List<MSavePlayerThread> ts = new ArrayList<>();
                Iterator<Long> it = saveLordIds.iterator();
                List<Long> curSaveLordIds = new ArrayList<>();
                while (it.hasNext()) {
                    curSaveLordIds.add(it.next());
                    it.remove();
                    if (curSaveLordIds.size() >= saveNum) {
                        //开线程curSaveLordIds
                        ts.add(new MSavePlayerThread(mergeGame, partyIdRelationMap, memberMap, lordIdMap, curSaveLordIds, lordIds, times));
                        curSaveLordIds = new ArrayList<>();
                    }
                }
                if (!curSaveLordIds.isEmpty()) {//最后记录
                    ts.add(new MSavePlayerThread(mergeGame, partyIdRelationMap, memberMap, lordIdMap, curSaveLordIds, lordIds, times));
                }
                CountDownLatch countDownLatch = new CountDownLatch(ts.size());

                for (MSavePlayerThread t : ts) {
                    t.countDownLatch = countDownLatch;
                    t.start();
                }

                countDownLatch.await();
            }
        }
        repairArenaScore(oldServers, myBatisMain);
    }

    private static class MSavePlayerThread extends Thread {
        MergeGame mergeGame;
        Map<String, PartyIdRelation> partyIdRelationMap;
        Map<Long, Member> memberMap;
        Map<Long, Long> lordIdMap;
        List<Long> curSaveLordIds;
        List<Long> totalLordIds;
        AtomicInteger times;
        CountDownLatch countDownLatch;

        public MSavePlayerThread(MergeGame mergeGame, Map<String, PartyIdRelation> partyIdRelationMap, Map<Long, Member> memberMap, Map<Long, Long> lordIdMap, List<Long> curSaveLordIds, List<Long> totalLordIds, AtomicInteger times) {
            this.partyIdRelationMap = partyIdRelationMap;
            this.memberMap = memberMap;
            this.lordIdMap = lordIdMap;
            this.curSaveLordIds = curSaveLordIds;
            this.totalLordIds = totalLordIds;
            this.times = times;
            this.mergeGame = mergeGame;
        }

        @Override
        public void run() {
            try {
                mergeGame.unionPlayer(partyIdRelationMap, memberMap, lordIdMap, curSaveLordIds, totalLordIds, times);
            } catch (Exception e) {
                LogUtil.error(e);
                System.exit(-3);
            }
            countDownLatch.countDown();
        }
    }


    private static Object[] getServerInfo(MyBatisM myBatis) {
        String serverName = null;
        int serverId = -1;
        StaticParamDao staticParamDao = new StaticParamDao();
        staticParamDao.setSqlSessionFactory(myBatis.getSqlSessionFactory());

        List<StaticParam> params = staticParamDao.selectStaticParams();
        for (int i = 0; i < params.size(); i++) {
            StaticParam param = (StaticParam) params.get(i);
            if (param.getParamName().equals("serverName")) {
                serverName = param.getParamValue();
            } else if ("serverId".equals(param.getParamName())) {
                serverId = Integer.parseInt(param.getParamValue());
            }
        }
        staticParamDao = null;
        return new Object[]{serverName, serverId};
    }

    private static boolean isDataNotNull(MyBatisM myBatis) {
        LordDao lordDao = new LordDao();
        lordDao.setSqlSessionFactory(myBatis.getSqlSessionFactory());
        List<Long> lordIds = lordDao.selectLordNotSmallIds();
        lordDao = null;
        if (lordIds.size() != 0) {
            return true;
        }
        PartyDao partyDao = new PartyDao();
        partyDao.setSqlSessionFactory(myBatis.getSqlSessionFactory());
        List<Party> partyList = partyDao.selectParyList();
        return partyList.size() != 0;
    }

    private static boolean pLordRelationHasData(MyBatisM myBatis) {
        LordRelationDao lordRelationDao = new LordRelationDao();
        lordRelationDao.setSqlSessionFactory(myBatis.getSqlSessionFactory());

        boolean hasTable = false;
        for (String tabelName : lordRelationDao.showTables()) {
            if ("p_lord_relation".equals(tabelName)) {
                hasTable = true;
                break;
            }
        }

        if (!hasTable) {
            lordRelationDao.createLordRelationTable();
        }

        boolean hasData = lordRelationDao.selectAllLordRelation().size() > 0;
        if (hasData) {
            return false;
        }
        return true;
    }

    /**
     * 根据合服列表生成新数据库名
     */
    public static String createNewDbName(String projectName, List<Integer> oldServers) {
        List<Integer> servers = new ArrayList<>(oldServers);
        Collections.sort(servers);

        StringBuilder dbName = new StringBuilder(projectName + "_");
        int lastServerId = 0;
        Boolean isContinue = null;
        for (int i = 0; i < servers.size(); i++) {
            Integer mServerId = servers.get(i);
            if (lastServerId == 0) {
                lastServerId = mServerId;
                dbName.append(lastServerId);
                continue;
            }
            int oldlastServerId = lastServerId;
            lastServerId = mServerId;
            //连续使用1_3-5-8
            if (oldlastServerId + 1 == mServerId) {//连续
                isContinue = true;
            } else {//断续
                if (isContinue == null) {
                    dbName.append("_").append(lastServerId);
                } else if (isContinue) {
                    dbName.append("-").append(oldlastServerId);
                    dbName.append("_").append(lastServerId);
                } else {
                    dbName.append("_").append(lastServerId);
                }
                isContinue = false;
            }
        }
        if (isContinue == null) {
            //这种情况不可能  前面判断必须合服数量>=2
        } else if (isContinue) {
            dbName.append("-").append(lastServerId);
        } else {

        }
        return dbName.toString();
    }

    private static MServer createNewMServer(String dbName, MServer oldDatamServer) throws Exception {
        MyBatisM myBatis = new MyBatisM(oldDatamServer.getDbUrl(), oldDatamServer.getUser(), oldDatamServer.getPwd());

        LordRelationDao lordRelationDao = new LordRelationDao();
        lordRelationDao.setSqlSessionFactory(myBatis.getSqlSessionFactory());

        boolean hasDb = false;
        List<String> databaseList = lordRelationDao.showDatabases();
        for (String dataBaseName : databaseList) {
            if (dbName.equals(dataBaseName)) {
                hasDb = true;
                break;
            }
        }
        //jdbc:mysql://localhost:3306/tank_1
        String dbUrl = oldDatamServer.getDbUrl();
        int index = dbUrl.lastIndexOf("/");
        dbUrl = dbUrl.substring(0, index + 1) + dbName;

        MServer newServer = new MServer();
        newServer.setServerId(oldDatamServer.getServerId());
        newServer.setUser(oldDatamServer.getUser());
        newServer.setPwd(oldDatamServer.getPwd());
        newServer.setDbUrl(dbUrl);

        //创建db 并导入所有p_表结构
        if (!hasDb) {
            LogUtil.error("创建合成数据库" + dbName);
            lordRelationDao.createGameDb(dbName);

            MyBatisM myBatisMain = new MyBatisM(newServer.getDbUrl(), newServer.getUser(), newServer.getPwd());
            newServer.myBatisM = myBatisMain;

            LordRelationDao newDblordRelationDao = new LordRelationDao();
            newDblordRelationDao.setSqlSessionFactory(myBatisMain.getSqlSessionFactory());

            for (String tableName : lordRelationDao.showTables()) {
                if (tableName.startsWith("p_lord_relation")) {
                    continue;
                }
                String createTableSql = lordRelationDao.showCreateTable(tableName);
                newDblordRelationDao.createTable(createTableSql);
                if (!tableName.startsWith("p_")) {
                    LogUtil.error("复制表结构和数据" + tableName);
                    lordRelationDao.tableToOtherDb(dbName, tableName);
                } else {
                    LogUtil.error("复制表结构" + tableName);
                    newDblordRelationDao.truncateTable(tableName);
                }
            }
        } else {
            MyBatisM myBatisMain = new MyBatisM(newServer.getDbUrl(), newServer.getUser(), newServer.getPwd());
            newServer.myBatisM = myBatisMain;
        }
        return newServer;
    }

    public static List<Integer> getMergeServerIdList(MyBatisM myBatis) {
        LordRelationDao lordRelationDao = new LordRelationDao();
        lordRelationDao.setSqlSessionFactory(myBatis.getSqlSessionFactory());
        return lordRelationDao.selectMergeServerIds();
    }

    /**
     * 打印下全服人数，修改游戏启动脚本的最大内存上限
     */
    private static void printServerInfo(final MyBatisM myBatis, String dbName, int smallLordLv) {
        LordDao lordDao = new LordDao();
        lordDao.setSqlSessionFactory(myBatis.getSqlSessionFactory());

        int lordCount = lordDao.selectLordCount();
        LogUtil.error("-------------------------------------------------");
        LogUtil.error("此次清除小号规则：已取名-VIP0-最后登录小于30天-角色等级小于等于" + smallLordLv);
        LogUtil.error("新的数据库名: " + dbName);
        LogUtil.error("合服后总人数: " + lordCount + ",请适当调整游戏启动脚本最大内存");
        LogUtil.error("-------------------------------------------------");
    }

    private static int getActBegin(MyBatisM myBatisMain, MyBatisM myBatisInit, int actId) {
        StaticParamDao staticParamDao = new StaticParamDao();
        StaticDataDao staticDataDao = new StaticDataDao();
        staticParamDao.setSqlSessionFactory(myBatisMain.getSqlSessionFactory());
        staticDataDao.setSqlSessionFactory(myBatisInit.getSqlSessionFactory());

        String openTimeStr = null;
        int activityMoldId = -1;
        List<StaticParam> params = staticParamDao.selectStaticParams();
        for (int i = 0; i < params.size(); i++) {
            StaticParam param = (StaticParam) params.get(i);
            if (param.getParamName().equals("openTime")) {
                openTimeStr = param.getParamValue();
            } else if (param.getParamName().equals("actMold")) {
                activityMoldId = Integer.valueOf(param.getParamValue());
            }
        }

        Map<Integer, StaticActivity> activityMap = staticDataDao.selectStaticActivity();
        List<StaticActivityPlan> planList = staticDataDao.selectStaticActivityPlan();
        Date openTime = DateHelper.parseDate(openTimeStr);
        List<ActivityBase> activityList = new ArrayList<ActivityBase>();
        for (StaticActivityPlan e : planList) {
            int activityId = e.getActivityId();
            StaticActivity staticActivity = activityMap.get(activityId);
            if (staticActivity == null) {
                continue;
            }
            int moldId = e.getMoldId();
            if (activityMoldId != moldId) {
                continue;
            }
            ActivityBase activityBase = new ActivityBase();
            activityBase.setOpenTime(openTime);
            activityBase.setPlan(e);
            activityBase.setStaticActivity(staticActivity);
            boolean flag = activityBase.initData();
            if (flag) {
                activityList.add(activityBase);
            }
        }

        for (ActivityBase base : activityList) {
            if (actId == base.getActivityId()) {
                return TimeHelper.getDay(base.getBeginTime());
            }
        }

        return 0;
    }

}
