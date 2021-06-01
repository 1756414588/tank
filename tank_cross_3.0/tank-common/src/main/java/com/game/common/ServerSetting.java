package com.game.common;

import com.game.dao.table.fight.StaticServerSettingDao;
import com.game.domain.table.StaticServerSetting;
import com.game.util.LogUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.annotation.PostConstruct;
import java.util.Hashtable;
import java.util.List;
import java.util.Map;

@Component
public class ServerSetting {
    public static final String CONFIG_MODE = "configMode";

    @Autowired
    private StaticServerSettingDao staticParamDao;

    @Value("${accountServerUrl}")
    private String accountServerUrl;

    @Value("${testMode}")
    private String testMode;

    @Value("${openWhiteName}")
    private String openWhiteName;

    @Value("${cryptMsg}")
    private String cryptMsg;

    @Value("${msgCryptCode}")
    private String msgCryptCode;

    @Value("${convertUrl}")
    private String convertUrl;

    @Value("${pay}")
    private String pay;

    @Value("${serverId}")
    private String serverId;

    private String clientPort;

    private String httpPort;

    private String openTime;

    private String serverName;

    private int serverID = 1;

    private int actMoldId = 1;

    private String accountRecordLogin;

    private String crossBeginTime;
    private String crossServerIp;
    private String crossType;

    //#是否远程获取serverIds true是远程获取 需要在s_server_setting 表配置一个地址serverIdsHttpUrl
    private boolean serverIdsHttp;

    private String serverIdsHttpUrl;


    public String getCryptMsg() {
        return cryptMsg;
    }

    public void setCryptMsg(String cryptMsg) {
        this.cryptMsg = cryptMsg;
    }

    public String getMsgCryptCode() {
        return msgCryptCode;
    }

    public void setMsgCryptCode(String msgCryptCode) {
        this.msgCryptCode = msgCryptCode;
    }

    public void setConvertUrl(String convertUrl) {
        this.convertUrl = convertUrl;
    }

    public String getConvertUrl() {
        return convertUrl;
    }

    public String getAccountServerUrl() {
        return accountServerUrl;
    }

    public String getClientPort() {
        return clientPort;
    }

    public void setClientPort(String clientPort) {
        this.clientPort = clientPort;
    }

    public String getHttpPort() {
        return httpPort;
    }

    public void setHttpPort(String httpPort) {
        this.httpPort = httpPort;
    }

    public String getOpenTime() {
        return openTime;
    }

    public void setOpenTime(String openTime) {
        this.openTime = openTime;
    }

    public String getServerName() {
        return serverName;
    }

    public void setServerName(String serverName) {
        this.serverName = serverName;
    }

    public boolean isTestMode() {
        return "yes".equals(testMode);
    }

    public boolean isOpenWhiteName() {
        return "yes".equals(openWhiteName);
    }

    public boolean isCryptMsg() {
        return "yes".equals(cryptMsg);
    }

    public boolean isOpenPay() {
        return "yes".equals(pay);
    }

    public String getCrossBeginTime() {
        return crossBeginTime;
    }

    public void setCrossBeginTime(String crossBeginTime) {
        this.crossBeginTime = crossBeginTime;
    }

    public String getCrossServerIp() {
        return crossServerIp;
    }

    public void setCrossServerIp(String crossServerIp) {
        this.crossServerIp = crossServerIp;
    }

    @PostConstruct
    public void init() {

        List<StaticServerSetting> staticServerSettings = staticParamDao.findAll();

        Map<String, String> paramMap = new Hashtable<>();
        for (int i = 0; i < staticServerSettings.size(); i++) {
            StaticServerSetting param = staticServerSettings.get(i);
            paramMap.put(param.getParamName(), param.getParamValue());
        }

        String configMode = paramMap.get(CONFIG_MODE);
        if (configMode != null && "db".equals(configMode)) {
            this.initWithDb(paramMap);
        }
    }

    private void initWithDb(Map<String, String> params) {
        LogUtil.info("game server config initWithDb!!!");
        accountServerUrl = params.get("accountServerUrl");
        testMode = params.get("testMode");
        openWhiteName = params.get("openWhiteName");
        cryptMsg = params.get("cryptMsg");
        msgCryptCode = params.get("msgCryptCode");
        convertUrl = params.get("convertUrl");
        pay = params.get("pay");
        serverId = params.get("serverId");
        clientPort = params.get("clientPort");
        httpPort = params.get("httpPort");
        openTime = params.get("openTime");
        serverName = params.get("serverName");
        setServerID(Integer.valueOf(serverId));
        setActMoldId(Integer.valueOf(params.get("actMold")));
        crossBeginTime = params.get("crossBeginTime");
        crossServerIp = params.get("crossServerIp");
        crossType = params.get("crossType");
        if (null != accountServerUrl) {
            accountRecordLogin = accountServerUrl.replace("inner", "recordRoleLogin");
        }

        if (params.containsKey("serverIdsHttp")) {
            serverIdsHttp = params.get("serverIdsHttp").equals("1") || params.get("serverIdsHttp").equals("true");
        }
        if (params.containsKey("serverIdsHttpUrl")) {
            serverIdsHttpUrl = params.get("serverIdsHttpUrl");
        }

    }

    public int getServerID() {
        return serverID;
    }

    public void setServerID(int serverID) {
        this.serverID = serverID;
    }

    public int getActMoldId() {
        return actMoldId;
    }

    public void setActMoldId(int actMoldId) {
        this.actMoldId = actMoldId;
    }

    public String getAccountRecordLogin() {
        return accountRecordLogin;
    }

    public String getCrossType() {
        return crossType;
    }

    public void setCrossType(String crossType) {
        this.crossType = crossType;
    }

    public boolean isServerIdsHttp() {
        return serverIdsHttp;
    }

    public void setServerIdsHttp(boolean serverIdsHttp) {
        this.serverIdsHttp = serverIdsHttp;
    }

    public String getServerIdsHttpUrl() {
        return serverIdsHttpUrl;
    }

    public void setServerIdsHttpUrl(String serverIdsHttpUrl) {
        this.serverIdsHttpUrl = serverIdsHttpUrl;
    }
}
