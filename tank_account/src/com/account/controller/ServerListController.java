package com.account.controller;

import com.account.common.ServerListConfig;
import com.account.manager.ServerListManager;
import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.context.request.WebRequest;

import java.util.List;

/**
 * @author ：Liu Gui Jie
 * @date ：Created in 2019/3/28 19:00
 * @description：
 */
@Controller
public class ServerListController {

    @Autowired
    private ServerListManager serverListManager;

    @ResponseBody
    @RequestMapping(value = {"serverListConfig.do"}, produces = {"text/html;charset=UTF-8"})
    public String getServerListConfig(WebRequest request) {
        String serverId = request.getParameter("serverId");
        ServerListConfig serverListConfig = ServerListManager.getServerListConfig(Integer.valueOf(serverId));
        if (serverListConfig == null) {
            return new JSONObject().toJSONString();
        }
        return JSON.toJSONString(serverListConfig);
    }

    @ResponseBody
    @RequestMapping(value = {"serverListConfigs.do"}, produces = {"text/html;charset=UTF-8"})
    public String getServerListConfigs(WebRequest request) {
        String serverIds = request.getParameter("serverIds");
        if (serverIds == null) {
            return new JSONArray().toJSONString();
        }

        String[] serverIdArray = serverIds.split(",");
        JSONArray jsonArray = new JSONArray();
        for (String serverId : serverIdArray) {
            ServerListConfig serverListConfig = ServerListManager.getServerListConfig(Integer.valueOf(serverId));
            if (serverListConfig != null) {
                jsonArray.add(serverListConfig);
            }
        }
        return jsonArray.toJSONString();
    }

    @ResponseBody
    @RequestMapping(value = {"serverListConfigAll.do"}, produces = {"text/html;charset=UTF-8"})
    public String serverListConfigAll(WebRequest request) {
        List<ServerListConfig> serverListConfigList = ServerListManager.getServerListConfigs();
        if (serverListConfigList == null) {
            return new JSONArray().toJSONString();
        }
        return JSON.toJSONString(serverListConfigList);
    }

    @ResponseBody
    @RequestMapping(value = {"serverListConfigRefresh.do"}, produces = {"text/html;charset=UTF-8"})
    public String serverListConfigRefrehs(WebRequest request) {
        boolean refresh = serverListManager.refresh();
        return refresh ? "success" : "fail";
    }

    @ResponseBody
    @RequestMapping(value = {"gameList.do"}, produces = {"text/html;charset=UTF-8"})
    public String gameList(WebRequest request) {
        JSONObject gameList = serverListManager.getGameList();
        return gameList.toJSONString();
    }


}