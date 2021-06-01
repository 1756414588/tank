package com.game.service.crossmin;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.game.common.ServerSetting;
import com.game.server.GameContext;
import com.game.server.config.gameServer.Server;
import com.game.util.HttpUtils;
import com.game.util.LogUtil;
import org.springframework.core.io.FileSystemResource;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;
import java.util.Properties;
import java.util.concurrent.ConcurrentHashMap;

/**
 * @author ：Liu Gui Jie
 * @date ：Created in 2019/4/18 11:59
 * @description：
 */
public class ServerListManager {

    private static final ConcurrentHashMap<Integer, ServerListConfig> serverListMap = new ConcurrentHashMap<>(50);

    private static List<Integer> serverIdList = new ArrayList<>();

    private static String accountHttpUrl;

    /**
     * 组队副本,跨服军矿ids配置
     *
     * @throws IOException
     */
    public static void refreshServerIds() throws IOException {
        ServerSetting serverSetting = GameContext.getAc().getBean(ServerSetting.class);
        String serverIds = null;
        if (serverSetting.isServerIdsHttp()) {
            LogUtil.info("远程读取 serverIds 连接配置");
            serverIds = getRemoteServerIds(serverSetting);
        } else {
            LogUtil.info("本地读取 serverIds 连接配置");
            serverIds = getSystemPathServerIds();
        }
        if (serverIds != null && !serverIds.equals("")) {
            serverIdList = new ArrayList<>();
            String[] serverIdArray = serverIds.split(",");
            for (int i = 0; i < serverIdArray.length; i++) {
                int serverId = Integer.valueOf(serverIdArray[i]);
                if (!serverIdList.contains(serverId)) {
                    serverIdList.add(serverId);
                }
            }
        }
        LogUtil.info(" serverIds 连接配置 {}", serverIdList);
    }


    /**
     * 远程读取配置
     *
     * @return
     * @throws IOException
     */
    private static String getRemoteServerIds(ServerSetting serverSetting) {
        String params = String.format("serverIds=%s", serverSetting.getServerID() + "");
        LogUtil.info("开始获取 RemoteServerIds  ,url={}?{}", serverSetting.getServerIdsHttpUrl(), params);
        long time1 = System.currentTimeMillis();
        String result = HttpUtils.sentPost(serverSetting.getServerIdsHttpUrl(), params);
        LogUtil.info("获取到 RemoteServerIds info 耗时 {} ms,{},", System.currentTimeMillis() - time1, result);
        return result;
    }

    /**
     * 本都读取配置
     *
     * @return
     * @throws IOException
     */
    private static String getSystemPathServerIds() throws IOException {
        LogUtil.info("开始本地读取 crossmin-game.properties 获取 serverids");
        String serverIds = null;
        InputStream inputStream = null;
        URL url = CrossMinService.class.getClassLoader().getResource("cross-config/crossmin-game.properties");
        if (url != null) {
            inputStream = new FileInputStream(url.getPath());
        }
        if (inputStream == null) {
            FileSystemResource fileSystemResource = new FileSystemResource("cross-config/crossmin-game.properties");
            inputStream = fileSystemResource.getInputStream();
        }
        if (inputStream != null) {
            Properties prop = new Properties();// 属性集合对象
            prop.load(inputStream);// 将属性文件流装载到Properties对象中
            inputStream.close();// 关闭流
            serverIds = prop.getProperty("serverIds");
        }
        LogUtil.info("crossmin-game.properties本地读取 serverids {} ", serverIds);
        return serverIds;
    }


    public static void refreshServerListConfig() {
        ServerSetting serverSetting = GameContext.getAc().getBean(ServerSetting.class);
        if (accountHttpUrl == null) {
            int lastIndexOf = serverSetting.getAccountServerUrl().lastIndexOf("/");
            String accountUrl = serverSetting.getAccountServerUrl().substring(0, lastIndexOf);
            accountHttpUrl = accountUrl + "/serverListConfigs.do";
        }
        if (serverIdList.isEmpty()) {
            return;
        }
        ConcurrentHashMap<Integer, ServerListConfig> server = new ConcurrentHashMap<>(50);
        StringBuilder stringBuilder = new StringBuilder();
        for (Integer serverId : serverIdList) {
            stringBuilder.append(serverId);
            stringBuilder.append(",");
        }
        String serverIds = stringBuilder.toString().substring(0, stringBuilder.length() - 1);
        String params = String.format("serverIds=%s", serverIds);
        LogUtil.info("开始获取 serverList info ,url={}?{}", accountHttpUrl, params);
        long time1 = System.currentTimeMillis();
        String result = HttpUtils.sentPost(accountHttpUrl, params);
        JSONArray serverListJson = result != null ? JSONArray.parseArray(result) : null;
        LogUtil.info("获取到 serverList info 耗时 {} ms,{},", System.currentTimeMillis() - time1, serverListJson);
        if (serverListJson != null) {
            for (Object conf : serverListJson) {
                ServerListConfig serverListConfig = JSON.toJavaObject(JSONObject.parseObject(conf.toString()), ServerListConfig.class);
                server.put(serverListConfig.getId(), serverListConfig);
                Session session = SessionManager.getSession(serverListConfig.getId());
                if (session != null) {
                    session.setServerName(serverListConfig.getName());
                }
            }
        }
        //验证重复配置
        List<String> checkList = new ArrayList<>();
        for (ServerListConfig config : server.values()) {
            String str = config.getSocketURL() + ":" + config.getPort();
            if (checkList.contains(str)) {
                LogUtil.error("删除重复的配置 serverId={}, ip={},port={}", config.getId(), config.getSocketURL(), config.getPort());
                server.remove(config.getId());
            } else {
                checkList.add(str);
            }
        }
        serverListMap.clear();
        serverListMap.putAll(server);
        LogUtil.info("配置刷新完成共 {} 个", serverListMap.size());
    }


    public static ConcurrentHashMap<Integer, ServerListConfig> getServerListMap() {
        return serverListMap;
    }

}
