package com.game.common;

import java.util.Hashtable;
import java.util.List;
import java.util.Map;

import javax.annotation.PostConstruct;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import com.game.dao.impl.p.StaticParamDao;
import com.game.domain.p.Account;
import com.game.domain.p.StaticParam;
import com.game.util.LogUtil;

/**
 * @author
 * @ClassName: ServerSetting
 * @Description: 游戏服配置项  对应表s_server_setting
 */
@Component
public class ServerSetting {
    public static final String CONFIG_MODE = "configMode";

    @Autowired
    private StaticParamDao staticParamDao;

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

    //向管理后台发送玩家登录信息的地址
    private String recordRoleURL;

    //热更模式1-自动,2-后台指定
    private int hotfixMold = 2;

    private boolean openSentry;

    //服务器维护结束后对外开放时间获取地址
    private String mainteURL;
    private int publisherId;

//    //服务器维护对外时间请求所需参数(一个帐号服体系对应一个publisherId)
//    private int publisherId;

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

    public void setStaticParamDao(StaticParamDao staticParamDao) {
        this.staticParamDao = staticParamDao;
    }

    public StaticParamDao getStaticParamDao() {
        return staticParamDao;
    }

    /**
     * @Title: init
     * @Description: 从 s_server_setting表中取出CONFIG_MODE参数  如果值为DB 则从此表读出所有配置参数
     * void
     */
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
//		LogHelper.ERROR_LOGGER.error("game server config initWithDb!!!");
        LogUtil.start("game server config initWithDb!!!");
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
        recordRoleURL = params.get("recordRoleURL");
        setServerID(Integer.valueOf(serverId));
        setActMoldId(Integer.valueOf(params.get("actMold")));
        String hotfixMoldStr = params.get("hotfixMold");
        if (null != hotfixMoldStr && !hotfixMoldStr.isEmpty()) {
            hotfixMold = Integer.parseInt(hotfixMoldStr);
        }
        String openSentryParam = params.get("openSentry");
        openSentry = openSentryParam != null && "1".equals(openSentryParam);
        mainteURL = params.get("mainteURL");
        String publisherIdStr = params.get("publisherId");
        if (null != publisherIdStr && !publisherIdStr.isEmpty()) {
            publisherId = Integer.parseInt(publisherIdStr);
        }

        LogUtil.start("clientPort:" + clientPort);
    }

    public boolean forbidByWhiteName(Account account) {
        if (isOpenWhiteName() && account.getWhiteName() == 0) {
            return true;
        }

        return false;
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

    public String getRecordRoleURL() {
        return recordRoleURL;
    }

    public int getHotfixMold() {
        return hotfixMold;
    }

    public void setHotfixMold(int hotfixMold) {
        this.hotfixMold = hotfixMold;
    }

    public boolean isOpenSentry() {
        return openSentry;
    }

    public String getMainteURL() {
        return mainteURL;
    }

    public void setMainteURL(String mainteURL) {
        this.mainteURL = mainteURL;
    }

    public int getPublisherId() {
        return publisherId;
    }

    public void setPublisherId(int publisherId) {
        this.publisherId = publisherId;
    }
}
