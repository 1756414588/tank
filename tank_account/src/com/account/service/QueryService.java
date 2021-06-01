package com.account.service;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import com.account.common.ServerSetting;
import com.account.dao.impl.AccountDao;
import com.account.domain.Account;
import com.account.util.HttpHelper;

public class QueryService {

    public Logger LOG = LoggerFactory.getLogger(QueryService.class);

    @Autowired
    protected ServerSetting serverSetting;

    @Autowired
    private AccountDao accountDao;

    private String packErrorResponse(int state) {
        JSONObject response = new JSONObject();
        response.put("state", state);
        return response.toString();
    }

    public String twQueryRoleInfo(String platId, int serverId) {

        String url = serverSetting.getServerUrl(serverId);
        if (url == null) {
            return packErrorResponse(1);
        }

        Account account = accountDao.selectByPlatId(12, platId);
        if (account == null) {
            return packErrorResponse(2);
        }

        JSONArray packets = new JSONArray();
        JSONObject packet = new JSONObject();
        packet.put("request", "queryRoleInfo");
        JSONObject param = new JSONObject();
        param.put("accountKey", account.getKeyId());
        param.put("serverId", serverId);
        packet.put("param", param);
        packets.add(packet);
        try {
            LOG.error("url " + url + "|packets " + packets.toString());
            String response = HttpHelper.doPost(url, packets.toString());
            if (response != null && response.startsWith("[") && response.endsWith("]")) {
                JSONArray jsonArray = JSONArray.fromObject(response);
                for (int i = 0; i < jsonArray.size(); i++) {
                    JSONObject entity = jsonArray.getJSONObject(i);
                    if (entity.getString("cmd").equals("queryRoleInfo")) {
                        int code = entity.getInt("code");
                        LOG.error(response);
                        if (code == 200) {//
                            return entity.getJSONObject("response").toString();
                        }
                    }
                }
            }
            LOG.error(response);
        } catch (Exception e) {
            e.printStackTrace();
            return packErrorResponse(4);
        }

        return packErrorResponse(3);
    }
}
