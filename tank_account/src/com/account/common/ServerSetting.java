package com.account.common;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Hashtable;
import java.util.List;
import java.util.Map;

import javax.annotation.PostConstruct;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.Resource;
import org.springframework.stereotype.Component;

import com.account.dao.impl.StaticParamDao;
import com.account.domain.Account;
import com.account.domain.StaticParam;
import com.account.util.CheckNull;
import com.account.util.PrintHelper;
import com.account.util.ServerListHelper;

@Component
public class ServerSetting {

    public Logger LOG = LoggerFactory.getLogger(this.getClass());

    public static final String CONFIG_MODE = "configMode";

    @Autowired
    private StaticParamDao staticParamDao;

    @Value("${openWhiteName}")
    private String openWhiteName;

    @Value("${baseVersion}")
    private String baseVersion;

    public boolean isOpenWhiteName() {
        return "yes".equals(openWhiteName);
    }

    @Value("${cryptMsg}")
    private String cryptMsg;

    @Value("${msgCryptCode}")
    private String msgCryptCode;

    @Value("${needActive}")
    private String needActive;

    @Value("${publicPort}")
    private String publicPort;

    public String getPublicPort() {
        return publicPort;
    }

    public void setPublicPort(String publicPort) {
        this.publicPort = publicPort;
    }

    public String getMsgCryptCode() {
        return msgCryptCode;
    }

    public void setMsgCryptCode(String msgCryptCode) {
        this.msgCryptCode = msgCryptCode;
    }

    @PostConstruct
    public void init() {
        List<StaticParam> params = staticParamDao.selectStaticParams();
        Map<String, String> paramMap = new Hashtable<>();
        for (int i = 0; i < params.size(); i++) {
            StaticParam param = params.get(i);
            paramMap.put(param.getParamName(), param.getParamValue());
        }

        String configMode = paramMap.get(CONFIG_MODE);
        if (configMode != null && "db".equals(configMode)) {
            this.initWithDb(paramMap);
        }
    }

    private void initWithDb(Map<String, String> params) {
        PrintHelper.println("account server config initWithDb");
        openWhiteName = params.get("openWhiteName");
        setBaseVersion(params.get("baseVersion"));
        cryptMsg = params.get("cryptMsg");
        msgCryptCode = params.get("msgCryptCode");
        needActive = params.get("needActive");
        if (params.containsKey("publicPort")) {
            publicPort = params.get("publicPort");
        }
    }

    public boolean forbidByWhiteName(Account account) {
        if (isOpenWhiteName() && account.getWhite() == 0) {
            return true;
        }

        return false;
    }

    public String getBaseVersion() {
        return baseVersion;
    }

    public void setBaseVersion(String baseVersion) {
        this.baseVersion = baseVersion;
    }

    public boolean isCryptMsg() {
        return "yes".equals(cryptMsg);
    }

    public String getServerUrl(int serverId) {
        Map<Integer, String> serverUrlMap = getServerList();
        return serverUrlMap.get(serverId);
    }

    public boolean isNeedActive() {
        return "yes".equals(needActive);
    }

    public Map<Integer, String> getServerList() {
        Map<Integer, String> serverUrlMap = new HashMap<>();
        JSONObject jsonObject = JSONObject.fromObject(readTxtFile());
        JSONArray array = jsonObject.getJSONArray("list");
        JSONObject server;
        for (int i = 0; i < array.size(); i++) {
            server = array.getJSONObject(i);
            String url = server.getString("url");
            if (!url.startsWith("http")) {
                url = "http://" + url;
            }
            serverUrlMap.put(server.getInt("id"), url);
        }
        return serverUrlMap;
    }

    public List<JSONObject> getServerList(String plat) {
        JSONObject json;
        String serverListJsonStr = readTxtFile();
        List<JSONObject> serverList = new ArrayList<>();
        JSONObject jsonObject = JSONObject.fromObject(serverListJsonStr);
        List<Integer> serverlist = new ArrayList<>();
        if (serverListJsonStr.contains("control")) {
            JSONArray allow = null;
            JSONArray control = jsonObject.getJSONArray("control");
            for (int i = 0; i < control.size(); i++) {
                json = control.getJSONObject(i);
                JSONArray plats = json.getJSONArray("plat");
                for (int j = 0; j < plats.size(); j++) {
                    String platName = plats.getString(j);
                    if (platName.equals(plat)) {
                        allow = json.getJSONArray("allow");
                        break;
                    }
                }
            }
            for (int i = 0; i < allow.size(); i++) {
                serverlist.add(allow.getInt(i));
            }
        }

        JSONArray array = jsonObject.getJSONArray("list");
        for (int i = 0; i < array.size(); i++) {
            json = array.getJSONObject(i);
            int id = json.getInt("id");
            if (!serverlist.contains(id)) {
                continue;
            }
            serverList.add(json);
        }
        return serverList;
    }

    public Map<Integer, JSONObject> getMailServerList() {
        Map<Integer, JSONObject> serverMap = new HashMap<Integer, JSONObject>();
        JSONObject jsonObject = JSONObject.fromObject(readTxtFile());
        LOG.error(jsonObject.toString());
        JSONArray array = jsonObject.getJSONArray("list");
        JSONObject server;
        for (int i = 0; i < array.size(); i++) {
            JSONObject s1 = new JSONObject();
            server = array.getJSONObject(i);
            if (server.containsKey("stop") && !server.getString("stop").trim().equals("0")) {
                LOG.error("[维护状态]" + server.getString("name"));
                continue;
            }
            String url = server.getString("url");
            if (!url.startsWith("http")) {
                url = "http://" + url;
            }
            int id = server.getInt("id");
            s1.put("id", id);
            s1.put("url", url);
            s1.put("name", server.getString("name"));
            LOG.error("id" + id + "|" + server.getString("name") + "|" + url);
            serverMap.put(id, s1);
        }
        return serverMap;
    }

    public String getCurVersion() {
        String path = "/var/ftp/client_tank/tank_1.0.1/ver.manifest";
        Resource resource = new FileSystemResource(path);
        String content = new String();
        if (resource.isReadable()) {
            try {
                String encoding = "UTF-8";
                InputStream is = resource.getInputStream();
                InputStreamReader read = new InputStreamReader(is, encoding);// 考虑到汉子编码格式
                BufferedReader bufferedReader = new BufferedReader(read);
                String lineTxt = null;
                while ((lineTxt = bufferedReader.readLine()) != null) {
                    content += lineTxt;
                }

                if (is != null) {
                    is.close();
                }
                if (bufferedReader != null) {
                    bufferedReader.close();
                }

                return content.trim();
            } catch (Exception e) {
                LOG.error("读取文件内容出错:" + path);
                e.printStackTrace();
            }
        }

        return null;
    }

    /**
     * 读取配置
     *
     * @return
     */
    public String readTxtFile() {

        // 优先从URL读取，读取不到时从本地文件读取
        String serverListJson = readServerList();
        if (!CheckNull.isNullTrim(serverListJson)) {
            return serverListJson;
        }
        LOG.error("未能从URL读取到 serverlist,开始本地读取 /var/ftp/client_tank/serverlist_tank.json");

        String path = "/var/ftp/client_tank/serverlist_tank.json";
        Resource resource = new FileSystemResource(path);
        String content = new String();
        if (resource.isReadable()) {
            try {
                String encoding = "UTF-8";
                InputStream is = resource.getInputStream();
                InputStreamReader read = new InputStreamReader(is, encoding);// 考虑到汉子编码格式
                BufferedReader bufferedReader = new BufferedReader(read);
                String lineTxt = null;
                while ((lineTxt = bufferedReader.readLine()) != null) {
                    content += lineTxt;
                }

                if (is != null) {
                    is.close();
                }
                if (bufferedReader != null) {
                    bufferedReader.close();
                }

            } catch (Exception e) {
                LOG.error("读取文件内容出错:{}", path, e);

            }

        } else {
            path = "web/serverlist.json";
            try {
                String encoding = "UTF-8";
                InputStream inputStream = this.getClass().getClassLoader().getResourceAsStream(path);

                InputStreamReader read = new InputStreamReader(inputStream, encoding);// 考虑到汉子编码格式
                BufferedReader bufferedReader = new BufferedReader(read);
                String lineTxt = null;
                while ((lineTxt = bufferedReader.readLine()) != null) {
                    content += lineTxt;
                }

                if (inputStream != null) {
                    inputStream.close();
                }
                if (bufferedReader != null) {
                    bufferedReader.close();
                }
            } catch (Exception e) {
                LOG.error("读取文件内容出错:{}", path);
                LOG.error("", e);
            }

            PrintHelper.println(" server config resource can not read from out directory");
        }

        return content;
    }

    public String readServerList() {
        return ServerListHelper.readServerListJson();
    }
}
