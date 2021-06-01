package com.account.manager;

import java.io.*;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

import com.account.common.ServerListConfig;
import com.account.util.HttpHelper;
import com.account.util.ServerListHelper;
import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;

/**
 * @author ：Liu Gui Jie
 * @date ：Created in 2019/3/28 17:48
 * @description：server List manager
 */
@Component
public class ServerListManager {

    protected static Logger logger = LoggerFactory.getLogger(ServerListManager.class);

    private static final ConcurrentHashMap<Integer, ServerListConfig> serverListMap = new ConcurrentHashMap<>(1000);

    private final ScheduledExecutorService scheduledExecutorService = Executors.newSingleThreadScheduledExecutor(new ServerListThreadFactory("serverList-refresh"));

    private static boolean state = false;

    public void initServerList() {

        if (state) {
            return;
        }

        refresh();

        this.scheduledExecutorService.scheduleWithFixedDelay(new Runnable() {
            @Override
            public void run() {
                try {
                    refresh();
                } catch (Exception e) {
                    logger.error("ServerListManager refresh error", e);
                }
            }
        }, 90, 90, TimeUnit.SECONDS);
        state = true;
    }

    public synchronized boolean refresh() {
        logger.info("ServerListManager refresh 开始读取server list url={} ,fileUrl={}", ServerListHelper.getServerConfig().getServerListUrl(), ServerListHelper.getServerConfig().getServerListFile());

        if (ServerListHelper.getServerConfig().getServerListUrl() == null && ServerListHelper.getServerConfig().getServerListFile() == null) {
            return false;
        }

        long time1 = System.currentTimeMillis();

        String requestServerListJson = ServerListHelper.readServerListJson();
        if (requestServerListJson == null) {
            logger.info("ServerListManager refresh 读取server list为null url={} ,fileUrl={}", ServerListHelper.getServerConfig().getServerListUrl(), ServerListHelper.getServerConfig().getServerListFile());
            return false;
        }
        logger.info("ServerListManager refresh http 远程下载完成 耗时 {} ms", (System.currentTimeMillis() - time1));
        long time2 = System.currentTimeMillis();

        try {
            JSONObject jsonObject = JSONObject.parseObject(requestServerListJson);
            JSONArray jsonArray = jsonObject.getJSONArray("list");
            Map<Integer, ServerListConfig> map = new HashMap<>(1000);
            for (Object obj : jsonArray) {
                ServerListConfig serverListConfig = JSON.toJavaObject(JSONObject.parseObject(obj.toString()), ServerListConfig.class);
                map.put(serverListConfig.getId(), serverListConfig);
            }
            serverListMap.clear();
            serverListMap.putAll(map);
        } catch (Exception e) {
            logger.error("解析server List 出错", e);
        }

        long now = System.currentTimeMillis();
        logger.info("ServerListManager refresh cache 完成 共 {} 个,解析json耗时 {} ms,下载解析共耗时 {} ms", serverListMap.size(), (now - time2), (now - time1));
        return true;

    }

    /**
     * 根据serverid 获取配置
     *
     * @param serverId
     * @return
     */
    public static ServerListConfig getServerListConfig(int serverId) {
        return serverListMap.get(serverId);
    }

    /**
     * 获取所有配置
     *
     * @return
     */
    public static List<ServerListConfig> getServerListConfigs() {
        return new ArrayList<>(serverListMap.values());
    }


    public JSONObject getGameList() {
        JSONObject result = new JSONObject();
        Map<String, String> maps = new HashMap<>();
        maps.put("混服", "http://119.29.12.143/serverlist_tank.json");
        maps.put("硬核", "http://119.29.231.94/serverlist_tank.json");
        maps.put("联运", "http://119.29.163.21/serverlist_tank.json");
        for (Map.Entry<String, String> stringStringEntry : maps.entrySet()) {
            decodeGameList(result, stringStringEntry.getKey(), stringStringEntry.getValue());
        }
        return result;
    }

    private void decodeGameList(JSONObject all, String type, String listUrl) {
        String str = HttpHelper.requestRemoteFileData(listUrl, "", 5000);
        JSONObject result = new JSONObject();
        Map<String, Map<String, ServerListConfig>> map = new HashMap<>(1000);
        JSONObject jsonObject = JSONObject.parseObject(str);
        JSONArray jsonArray = jsonObject.getJSONArray("list");
        for (Object obj : jsonArray) {
            ServerListConfig serverListConfig = JSON.toJavaObject(JSONObject.parseObject(obj.toString()), ServerListConfig.class);
            if (serverListConfig.getId() == 9999 || serverListConfig.getId() == 99999) {
                continue;
            }
            String url = serverListConfig.getUrl();
            if (!map.containsKey(url)) {
                map.put(url, new HashMap<String, ServerListConfig>());
            }
            Map<String, ServerListConfig> listConfigMap = map.get(url);
            listConfigMap.put(serverListConfig.getName(), serverListConfig);
            serverListConfig.setType(type);
        }
        result.put("total", map.size());
        List<Object> serverInfo = new ArrayList<>();
        int index = 1;
        for (Map<String, ServerListConfig> c : map.values()) {
            JSONObject info = new JSONObject();
            List<Integer> ids = new ArrayList<>();
            List<String> names = new ArrayList<>();
            for (ServerListConfig cf : c.values()) {
                ids.add(cf.getId());
                names.add(cf.getName() + "(serverId" + cf.getId() + ")");
                info.put("httpUrl", cf.getUrl());
                info.put("stop", cf.getStop());
                info.put("socketIp", cf.getSocketURL());
                info.put("socketPort", cf.getPort());
                info.put("type", cf.getType());
            }
            //Collections.sort(ids);
            Collections.sort(names);
            info.put("serverIds", ids);
            info.put("serverName", names);
            info.put("server-between", (ids.get(0) + "-" + ids.get(ids.size() - 1)));
            info.put("index", index++);
            info.put("主服serverId", ids.get(0));
            serverInfo.add(info);
        }
        result.put("server", serverInfo);
        all.put(type, result);
    }


    public static void main(String[] args) {
        Map<Integer, List<Integer>> gets = flushCrossServrIds();
        File file = new File("D:\\merge\\cross.txt");
        try {
            if (!file.exists()) {
                file.createNewFile();
            }
            FileOutputStream os = new FileOutputStream(file);
            for (Map.Entry<Integer, List<Integer>> integerListEntry : gets.entrySet()) {
                os.write((integerListEntry.toString() + "\r\n").getBytes());
            }
            os.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static Map<Integer, List<Integer>> flushCrossServrIds() {
        String pathname = "d:\\merge\\crossName.txt"; // 绝对路径或相对路径都可以，写入文件时演示相对路径,读取以上路径的input.txt文件
        List<String> list = new ArrayList<>();
        try (FileReader reader = new FileReader(pathname); BufferedReader br = new BufferedReader(reader)) {
            String line;
            while ((line = br.readLine()) != null) {
                list.add(line);
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        Map<Integer, List<String>> map = new LinkedHashMap<>();
        for (String string : list) {
            if (null != string && !"".equals(string)) {
                //string.replace("[","");
                string = string.replace("]", "");
                String[] str = string.split("\\[");
                if (!map.containsKey(Integer.parseInt((str[0].trim())))) {
                    map.put(Integer.parseInt((str[0].trim())), new ArrayList<String>());
                }
                List<String> l = map.get(Integer.parseInt((str[0].trim())));
                String[] str2 = str[1].split(", ");
                for (String s : str2) {
                    if (!s.equals("") && !s.equals("]")) {
                        l.add(s);
                    }
                }
            }
        }
        Map<Integer, String> urlMap = new HashMap<>();
        Map<String, ServerListConfig> sMap = new HashMap<>();
        urlMap.put(1, "http://119.29.12.143/serverlist_tank.json");
        urlMap.put(2, "http://119.29.231.94/serverlist_tank.json");
        for (String s : urlMap.values()) {
            flushMap(s, sMap);
        }
        Map<Integer, List<Integer>> newm = new LinkedHashMap<>();
        for (Map.Entry<Integer, List<String>> string : map.entrySet()) {
            Map<String, List<Integer>> m = new HashMap<>();
            newm.put(string.getKey(), new ArrayList<Integer>());
            List<String> nList = string.getValue();
            if (nList != null) {
                List<Integer> l;
                for (String sName : nList) {
                    ServerListConfig config = sMap.get(sName.trim());
                    if (config == null) {
                        continue;
                    }
                    if (!m.containsKey(config.getUrl())) {
                        m.put(config.getUrl(), new ArrayList<Integer>());
                    }
                    l = m.get(config.getUrl());
                    l.add(config.getId());
                }
            }
            List<Integer> newI = newm.get(string.getKey());
            for (List<Integer> string2 : m.values()) {
                Collections.sort(string2);
                newI.add(string2.get(0));
            }
        }
        for (Map.Entry<Integer, List<Integer>> object : newm.entrySet()) {
            Collections.sort(object.getValue());
        }
        return newm;
    }

    public static void flushMap(String url, Map<String, ServerListConfig> sMap) {
        String str = HttpHelper.requestRemoteFileData(url, "", 5000);
        JSONObject jsonObject = JSONObject.parseObject(str);
        JSONArray jsonArray = jsonObject.getJSONArray("list");
        for (Object obj : jsonArray) {
            ServerListConfig serverListConfig = JSON.toJavaObject(JSONObject.parseObject(obj.toString()), ServerListConfig.class);
            sMap.put(serverListConfig.getName().split(" ")[0].trim(), serverListConfig);
        }
    }
}
