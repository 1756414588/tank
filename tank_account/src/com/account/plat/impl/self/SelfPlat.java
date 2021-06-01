package com.account.plat.impl.self;

import java.util.Date;
import java.util.Iterator;

import javax.servlet.http.HttpServletResponse;

import net.sf.json.JSONObject;

import org.springframework.stereotype.Component;
import org.springframework.web.context.request.WebRequest;

import com.account.constant.GameError;
import com.account.domain.Account;
import com.account.domain.form.RoleLog;
import com.account.plat.PlatBase;
import com.account.plat.Register;
import com.account.plat.impl.self.util.CpTransSyncSignValid;
import com.account.plat.interfaces.LogRoleLogin2sdk;
import com.account.util.RandomHelper;
import com.game.pb.AccountPb.DoLoginRq;
import com.game.pb.AccountPb.DoLoginRs;
import com.game.pb.AccountPb.DoRegisterRq;
import com.game.pb.AccountPb.DoRegisterRs.Builder;

@Component
public class SelfPlat extends PlatBase implements Register, LogRoleLogin2sdk {
    public GameError doLogin(DoLoginRq req, DoLoginRs.Builder response) {

        if (!req.hasSid() || !req.hasBaseVersion() || !req.hasVersion() || !req.hasDeviceNo()) {
            return GameError.PARAM_ERROR;
        }

        String sid = req.getSid();
        String baseVersion = req.getBaseVersion();
        String versionNo = req.getVersion();
        String deviceNo = req.getDeviceNo();

        String[] vParam = sid.split("_");
        if (vParam.length < 2) {
            return GameError.PARAM_ERROR;
        }

        String accountId = vParam[0];
        String passwd = vParam[1];

        Account account = accountDao.selectByAccount(accountId, this.getPlatNo());
        if (account == null) {
            return GameError.NOT_EXIST_ACCOUNT;
        }

        if (!passwd.equals(account.getPasswd())) {
            return GameError.PWD_ERROR;
        }

        GameError authorityRs = super.checkAuthority(account);
        if (authorityRs != GameError.OK) {
            return authorityRs;
        }

        String token = RandomHelper.generateToken();
        account.setToken(token);
        account.setBaseVersion(baseVersion);
        account.setVersionNo(versionNo);
        account.setLoginDate(new Date());
        account.setDeviceNo(deviceNo);
        accountDao.updateTokenAndVersion(account);

        response.addAllRecent(super.getRecentServers(account));
        response.setKeyId(account.getKeyId());
        response.setToken(token);
        // response.put("recent", super.getRecentServers(account));
        // response.put("keyId", account.getKeyId());
        // response.put("token", token);

        if (isActive(account)) {
            // response.put("active", 1);
            response.setActive(1);
        } else {
            response.setActive(0);
            // response.put("active", 0);
        }

        return GameError.OK;
    }

    @Override
    public GameError doLogin(JSONObject param, JSONObject response) {
        // TODO Auto-generated method stub

        if (!param.containsKey("sid") || !param.containsKey("baseVersion") || !param.containsKey("version") || !param.containsKey("deviceNo")) {
            return GameError.PARAM_ERROR;
        }

        String sid = param.getString("sid");
        // String baseVersion = param.getString("baseVersion");
        String versionNo = param.getString("version");
        String deviceNo = param.getString("deviceNo");

        String[] vParam = sid.split("_");
        if (vParam.length < 2) {
            return GameError.PARAM_ERROR;
        }

        String accountId = vParam[0];
        String passwd = vParam[1];

        Account account = accountDao.selectByAccount(accountId, this.getPlatNo());
        if (account == null) {
            return GameError.NOT_EXIST_ACCOUNT;
        }

        if (!passwd.equals(account.getPasswd())) {
            return GameError.PWD_ERROR;
        }

        GameError authorityRs = super.checkAuthority(account);
        if (authorityRs != GameError.OK) {
            return authorityRs;
        }

        String token = RandomHelper.generateToken();
        account.setToken(token);
        account.setVersionNo(versionNo);
        account.setLoginDate(new Date());
        account.setDeviceNo(deviceNo);
        accountDao.updateTokenAndVersion(account);

        response.put("recent", super.getRecentServers(account));
        response.put("keyId", account.getKeyId());
        response.put("token", token);

        if (isActive(account)) {
            response.put("active", 1);
        } else {
            response.put("active", 0);
        }

        return GameError.OK;
    }

    @Override
    public GameError register(JSONObject param, JSONObject response) {
        // TODO Auto-generated method stub
        if (!param.containsKey("accountId") || !param.containsKey("passwd") || !param.containsKey("baseVersion") || !param.containsKey("version")
                || !param.containsKey("deviceNo")) {
            return GameError.PARAM_ERROR;
        }

        String accountId = param.getString("accountId");
        String passwd = param.getString("passwd");
        String versionNo = param.getString("version");
        String baseVersion = param.getString("baseVersion");
        String deviceNo = param.getString("deviceNo");

        Account account = accountDao.selectByAccount(accountId, this.getPlatNo());
        if (account != null) {
            return GameError.EXIST_ACCOUNT;
        }

        String token = RandomHelper.generateToken();
        account = new Account();
        account.setPlatNo(this.getPlatNo());
        account.setPlatId(token);
        account.setAccount(accountId);
        account.setPasswd(passwd);
        account.setBaseVersion(baseVersion);
        account.setVersionNo(versionNo);
        account.setToken(token);
        account.setDeviceNo(deviceNo);
        Date now = new Date();
        account.setLoginDate(now);
        account.setCreateDate(now);
        accountDao.insertWithAccount(account);

        GameError authorityRs = super.checkAuthority(account);
        if (authorityRs != GameError.OK) {
            return authorityRs;
        }

        response.put("keyId", account.getKeyId());
        response.put("token", token);

        if (isActive(account)) {
            response.put("active", 1);
        } else {
            response.put("active", 0);
        }
        return GameError.OK;
    }

    @Override
    public String payBack(WebRequest request, String content, HttpServletResponse response) {
        Iterator<String> iterator = request.getParameterNames();
        LOG.error("pay self");
        while (iterator.hasNext()) {
            String paramName = iterator.next();
            LOG.error(request.getParameter(paramName));
        }

        String transdata = request.getParameter("transdata");
        String sign = request.getParameter("sign");
        if (!CpTransSyncSignValid.validSign(transdata, sign, IAppPaySDKConfig.PLATP_KEY)) {
            LOG.error("sign fail");
            return "FAILURE";
        }

        LOG.error("sign success");
        JSONObject datas = JSONObject.fromObject(transdata);

        String transid = datas.getString("transid");
        String money = datas.getString("money");
        String cpprivate = datas.getString("cpprivate");
        Integer result = datas.getInt("result");
        if (result == null || result != 0) {
            LOG.error("支付结果失败");
            return "SUCCESS";
        }

        if (transid == null || money == null || cpprivate == null) {
            return "SUCCESS";
        }
        String[] infos = cpprivate.split(",");
        if (infos.length != 4) {
            return "SUCCESS";
        }
        // Long lordId = Long.valueOf(infos[0]);
        // int serverId = Integer.valueOf(infos[1]);
        // int rechargeId = Integer.valueOf(infos[2]);
        // String exorderno = infos[3];
        // payResult(lordId, serverId, Double.valueOf(money), rechargeId,
        // transid, exorderno);
        return "SUCCESS";
    }

    @Override
    public GameError register(DoRegisterRq req, Builder builder) {
        // TODO Auto-generated method stub
        if (!req.hasAccountId() || !req.hasPasswd() || !req.hasBaseVersion() || !req.hasVersion() || !req.hasDeviceNo()) {
            LOG.error("IselfBasePlat register not complete param");
            return GameError.PARAM_ERROR;
        }

        String accountId = req.getAccountId();
        String passwd = req.getPasswd();
        String versionNo = req.getVersion();
        String baseVersion = req.getBaseVersion();
        String deviceNo = req.getDeviceNo();

        Account account = accountDao.selectByAccount(accountId, this.getPlatNo());
        if (account != null) {
            return GameError.EXIST_ACCOUNT;
        }

        String token = RandomHelper.generateToken();
        account = new Account();
        account.setPlatNo(this.getPlatNo());
        account.setPlatId(token);
        account.setAccount(accountId);
        account.setPasswd(passwd);
        account.setBaseVersion(baseVersion);
        account.setVersionNo(versionNo);
        account.setToken(token);
        account.setDeviceNo(deviceNo);
        Date now = new Date();
        account.setLoginDate(now);
        account.setCreateDate(now);
        accountDao.insertWithAccount(account);

        builder.setKeyId(account.getKeyId());
        builder.setToken(token);

        if (isActive(account)) {
            builder.setActive(1);
        } else {
            builder.setActive(0);
        }
        return GameError.OK;
    }

    @Override
    public void logRoleLogin2sdk(RoleLog role) {
        // TODO Auto-generated method stub
        LOG.error("[roleLog]" + role);
    }
}
