package com.account.plat.impl.mzTkbtdz_appstore;

import com.account.constant.GameError;
import com.account.domain.Account;
import com.account.plat.PayInfo;
import com.account.plat.PlatBase;
import com.account.plat.impl.kaopu.MD5Util;
import com.account.plat.impl.self.util.MD5;
import com.account.util.RandomHelper;
import com.game.pb.AccountPb.DoLoginRq;
import com.game.pb.AccountPb.DoLoginRs;
import net.sf.json.JSONObject;
import org.springframework.stereotype.Component;
import org.springframework.web.context.request.WebRequest;

import javax.annotation.PostConstruct;
import javax.servlet.http.HttpServletResponse;
import java.net.URLDecoder;
import java.util.*;

@Component
public class MzTkbtdzAppstorePlat extends PlatBase {

    private static String AppID;

    private static String AppKey;

    private static String GAME_ID;

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/mzTkbtdz_appstore/", "plat.properties");
        AppID = properties.getProperty("AppID");
        AppKey = properties.getProperty("AppKey");
        GAME_ID = properties.getProperty("GAME_ID");
    }

    @Override
    public int getPlatNo() {
        return 501;
    }

    @Override
    public GameError doLogin(JSONObject param, JSONObject response) {
        return GameError.OK;
    }

    @Override
    public GameError doLogin(DoLoginRq req, DoLoginRs.Builder response) {

        if (!req.hasSid() || !req.hasBaseVersion() || !req.hasVersion() || !req.hasDeviceNo()) {
            LOG.error("GameError.PARAM_ERROR");
            return GameError.PARAM_ERROR;
        }

        String sid = req.getSid();
        String baseVersion = req.getBaseVersion();
        String versionNo = req.getVersion();
        String deviceNo = req.getDeviceNo();

        String[] vParam = sid.split("_");
        String userid = vParam[0];
        String sign = vParam[1];
        String timestamp = vParam[2];

        if (!verifyAccount(userid, timestamp, sign)) {
            return GameError.SDK_LOGIN;
        }

        Account account = accountDao.selectByPlatId(getPlatNo(), userid);

        if (account == null) {
            String token = RandomHelper.generateToken();
            account = new Account();

            account.setPlatNo(this.getPlatNo());
            account.setPlatId(userid);
            account.setAccount(getPlatNo() + "_" + userid);
            account.setPasswd(userid);
            account.setBaseVersion(baseVersion);
            account.setVersionNo(versionNo);
            account.setToken(token);
            account.setDeviceNo(deviceNo);
            Date now = new Date();
            account.setLoginDate(now);
            account.setCreateDate(now);
            account.setChildNo(super.getPlatNo());
            accountDao.insertWithAccount(account);

        } else {
            String token = RandomHelper.generateToken();
            account.setToken(token);
            account.setBaseVersion(baseVersion);
            account.setVersionNo(versionNo);
            account.setDeviceNo(deviceNo);
            account.setLoginDate(new Date());
            accountDao.updateTokenAndVersion(account);
        }

        GameError authorityRs = super.checkAuthority(account);
        if (authorityRs != GameError.OK) {
            LOG.error("authorityRs:" + authorityRs);
            return authorityRs;
        }

        response.addAllRecent(super.getRecentServers(account));
        response.setKeyId(account.getKeyId());
        response.setToken(account.getToken());

        if (isActive(account)) {
            response.setActive(1);
        } else {
            response.setActive(0);

        }
        return GameError.OK;
    }

    private boolean verifyAccount(String userid, String timestamp, String sign) {
        String str = userid + AppKey + timestamp;
        LOG.error("mzTkbtdz_appstore md5str =" + str);
        return MD5Util.toMD5(str).equals(sign);
    }

    @Override
    public String payBack(WebRequest request, String content, HttpServletResponse response) {

        LOG.error("mzTkbtdz_appstore payBack 开始 " + content);


        try {
            Iterator<String> iterator = request.getParameterNames();
            Map<String, String> params = new HashMap<String, String>();
            while (iterator.hasNext()) {
                String paramName = iterator.next();
                String val = URLDecoder.decode(request.getParameter(paramName), "UTF-8");
                LOG.error("mzTkbtdz_appstore param " + paramName + ":" + val);
                params.put(paramName, val);
            }

            String contentStr = params.get("content");
            String sign = request.getParameter("sign");
            contentStr = new String(com.account.plat.impl.muzhi.Base64.decode(contentStr));

            String md5str = contentStr + "&key=" + AppKey;
            String myMd5Str = MD5Util.toMD5(md5str);

            if (!sign.equals(myMd5Str)) {
                LOG.error("mzTkbtdz_appstore payBack contentStr:" + contentStr);
                LOG.error("mzTkbtdz_appstore payBack signstr:" + myMd5Str);
                LOG.error("mzTkbtdz_appstore payBack sign:" + sign);
                LOG.error("mzTkbtdz_appstore payBack sign:md5验证失败");
                return "failure";
            }


            JSONObject json = JSONObject.fromObject(contentStr);
            LOG.error("mzTkbtdz_appstore payBack json= " + json);


            if (json.getInt("payStatus") != 0) {
                return "success";
            }

            String cp_order_id = json.getString("cp_order_id");

            PayInfo payInfo = new PayInfo();
            // 游戏内部渠道号
            payInfo.platNo = getPlatNo();
            payInfo.childNo = super.getPlatNo();
            // 渠道订单号
            payInfo.orderId = json.getString("pay_no");
            // 付费金额
            payInfo.amount = json.getInt("amount") / 100;
            payInfo.realAmount = payInfo.amount;

            String[] param = cp_order_id.split("_");
            String serverid = param[0];
            String roleid = param[1];
            // 游戏内部订单号
            payInfo.serialId = cp_order_id;
            // 渠道id
            payInfo.platId = json.getString("user_id");
            // 游戏区号
            payInfo.serverId = Integer.valueOf(serverid);
            // 玩家角色id
            payInfo.roleId = Long.valueOf(roleid);

            int code = payToGameServer(payInfo);

            if (code == 0 || code == 1) {
                LOG.error("mzTkbtdz_appstore 充值发货成功 " + code);
                return "success";
            }
            LOG.error("mzTkbtdz_appstore 充值发货失败" + code);
            return "failure3";

        } catch (Exception e) {
            LOG.error("mzTkbtdz_appstore 充值异常" + e.getMessage());
            e.printStackTrace();
            return "failure4";
        }
    }


}
