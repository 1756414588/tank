package com.game.actor.system.lsn;

import com.alibaba.fastjson.JSONObject;
import com.game.actor.system.ServerEvent;
import com.game.common.ServerSetting;
import com.game.server.Actor.IMessage;
import com.game.server.Actor.IMessageListener;
import com.game.server.GameServer;
import com.game.util.HttpUtils;
import com.game.util.LogUtil;
import com.game.util.NumberHelper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

/**
 * @Author :GuiJie Liu
 * @date :Create in 2019/3/29 11:22
 * @Description :维护服务端对外状态
 */
@Service
public class ServerLsn implements IMessageListener {
    /**
     * 服务器对外开放信息返回状态：服务器维护中
     */
    public static final int SERVER_OPEN_STATE_CLOSE = 1;

    @Autowired
    private ServerSetting serverSetting;

    /**
     * 获取server list的连接
     */
    private static String accountServerListUrl = "";

    @Override
    public void onMessage(IMessage msg) {
        if (!msg.getSubject().equals(ServerEvent.UPDATE_SERVER_MAINTE)) {
            return;
        }

        if (accountServerListUrl.equals("")) {
            int lastIndexOf = serverSetting.getAccountServerUrl().lastIndexOf("/");
            String accountUrl = serverSetting.getAccountServerUrl().substring(0, lastIndexOf);
            accountServerListUrl = accountUrl + "/serverListConfig.do";
        }

        try {
            String params = String.format("serverId=%d", serverSetting.getServerID());
            LogUtil.flow("server open status 开始获取 serverList info ,url={}?{}", accountServerListUrl, params);
            long time1 = System.currentTimeMillis();
            String result = HttpUtils.sentPost(accountServerListUrl, params);
            JSONObject serverListJson = result != null ? JSONObject.parseObject(result) : null;
            LogUtil.flow("server open status 获取到 serverList info 耗时 {} ms,{},", System.currentTimeMillis() - time1, serverListJson);

            if (serverListJson != null) {
                //如果不包含就默认开放吧
                int state = 0;
                if (serverListJson.containsKey("stop")) {
                    state = serverListJson.getIntValue("stop");
                }
                GameServer.MAINTE_SERVER_OPEN = state != SERVER_OPEN_STATE_CLOSE;
                LogUtil.flow("server open status 服务器对外状态 ,state={},MAINTE_SERVER_OPEN={}", state, GameServer.MAINTE_SERVER_OPEN);
                return;
            }
        } catch (Exception e) {
            LogUtil.error("获取server list info 信息错误 ", e);
        }

        //如果获取不到 或者没有配置就默认对外开启
        GameServer.MAINTE_SERVER_OPEN = true;
    }

}
