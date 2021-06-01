package com.account.service;

import net.sf.json.JSONObject;

import org.springframework.beans.factory.annotation.Autowired;

import com.account.common.ServerSetting;
import com.account.constant.GameError;
import com.account.dao.impl.AccountDao;
import com.account.domain.Account;

@Deprecated
public class AuthorityService {

    @Autowired
    private AccountDao accountDao;

    @Autowired
    private ServerSetting serverSetting;

    public GameError verify(JSONObject param, JSONObject response) {
        // TODO Auto-generated method stub
        int keyId = param.getInt("keyId");
        String token = param.getString("token");
        int serverId = param.getInt("serverId");

        if (token == null) {
            return GameError.PARAM_ERROR;
        }

//		if (param.containsKey("curVersion")) {
//			String curVersion = param.getString("curVersion");
//			String versionSetting = serverSetting.getCurVersion();
//			if (versionSetting != null && !versionSetting.equals(curVersion)) {
//				return GameError.CUR_VERSION;
//			}
//		}

        Account account = accountDao.selectByKey(keyId);
        if (account == null) {
            return GameError.INVALID_TOKEN;
        }

        String tokenExist = account.getToken();
        if (tokenExist == null || !tokenExist.equals(token)) {
            return GameError.INVALID_TOKEN;
        }

        this.recordRecentServer(account, serverId);
        response.put("platId", account.getPlatId());
        response.put("platNo", account.getPlatNo());
        response.put("childNo", account.getChildNo());
        return GameError.OK;
    }

    private void recordRecentServer(Account account, int serverId) {
        int[] record = {account.getFirstSvr(), account.getSecondSvr(), account.getThirdSvr()};
        int temp = 0;
        if (record[0] != 0) {
            if (record[0] != serverId) {
                temp = record[2];
                record[2] = record[1];
                record[1] = record[0];
            }
        }

        record[0] = serverId;
        if (record[2] == serverId) {
            record[2] = temp;
        }
        account.setFirstSvr(record[0]);
        account.setSecondSvr(record[1]);
        account.setThirdSvr(record[2]);
        accountDao.updateRecentServer(account);
    }
}
