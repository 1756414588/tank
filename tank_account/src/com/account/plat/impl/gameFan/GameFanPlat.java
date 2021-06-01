package com.account.plat.impl.gameFan;

import java.net.URLDecoder;
import java.util.Arrays;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Properties;

import javax.annotation.PostConstruct;
import javax.servlet.http.HttpServletResponse;

import net.sf.json.JSONObject;

import org.springframework.stereotype.Component;
import org.springframework.web.context.request.WebRequest;

import com.account.constant.GameError;
import com.account.domain.Account;
import com.account.plat.PayInfo;
import com.account.plat.PlatBase;
import com.account.plat.impl.self.util.MD5;
import com.account.util.RandomHelper;
import com.game.pb.AccountPb.DoLoginRq;
import com.game.pb.AccountPb.DoLoginRs;

@Component
public class GameFanPlat extends PlatBase {


    private static String AppId;
    private static String AppKey;

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/gameFan/", "plat.properties");
        AppId = properties.getProperty("AppId");
        AppKey = properties.getProperty("AppKey");
    }

    public GameError doLogin(DoLoginRq req, DoLoginRs.Builder response) {

        if (!req.hasSid() || !req.hasBaseVersion() || !req.hasVersion() || !req.hasDeviceNo()) {
            return GameError.PARAM_ERROR;
        }

        String sid = req.getSid();
        String baseVersion = req.getBaseVersion();
        String versionNo = req.getVersion();
        String deviceNo = req.getDeviceNo();

        String[] vParam = sid.split("_");
        if (vParam.length < 3) {
            return GameError.PARAM_ERROR;
        }
        String uid = vParam[0];

        if (!verifyAccount(vParam[0], vParam[1], vParam[2])) {
            return GameError.SDK_LOGIN;
        }

        Account account = accountDao.selectByPlatId(getPlatNo(), uid);
        if (account == null) {
            String token = RandomHelper.generateToken();
            account = new Account();
            account.setPlatNo(this.getPlatNo());
            account.setPlatId(uid);
            account.setAccount(getPlatNo() + "_" + uid);
            account.setPasswd(uid);
            account.setBaseVersion(baseVersion);
            account.setVersionNo(versionNo);
            account.setToken(token);
            account.setDeviceNo(deviceNo);
            Date now = new Date();
            account.setLoginDate(now);
            account.setCreateDate(now);
            accountDao.insertWithAccount(account);
            response.setUserInfo("1");
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

    private boolean verifyAccount(String username, String sign, String logintime) {
        LOG.error("gameFan开始调用sidInfo接口");
        String checkSign = "username=" + username + "&appkey=" + AppKey + "&logintime=" + logintime;
        LOG.error("[待签名参数]" + checkSign);
        checkSign = MD5.md5Digest(checkSign);

        if (!checkSign.equals(sign)) {
            LOG.error("gameFan 登陆签名验证失败, checkSign:" + checkSign);
            return false;
        } else {
            LOG.error("gameFan 登陆签名验证成功");
            return true;
        }
    }

    public static String getSignStr(Map<String, String> params) {
        Object[] keys = params.keySet().toArray();
        Arrays.sort(keys);
        String k, v;

        String str = "";
        for (int i = 0; i < keys.length; i++) {
            k = (String) keys[i];
            if (k.equals("sign") || k.equals("plat")) {
                continue;
            }

            if (params.get(k) == null || params.get(k).equals("")) {
                continue;
            }
            v = (String) params.get(k);

            if (str.equals("")) {
                str = k + "=" + v;
            } else {
                str = str + "&" + k + "=" + v;
            }
        }
        return str;
    }

    @Override
    public String payBack(WebRequest request, String content, HttpServletResponse response) {
        Iterator<String> iterator = request.getParameterNames();
        LOG.error("pay gameFan");
        LOG.error("pay gameFan content:" + content);
        Map<String, String> params = new HashMap<String, String>();
        try {
            while (iterator.hasNext()) {
                String paramName = iterator.next();
                LOG.error(paramName + ":" + URLDecoder.decode(request.getParameter(paramName), "UTF-8"));
                params.put(paramName, URLDecoder.decode(request.getParameter(paramName), "UTF-8"));
            }
            LOG.error("[参数结束]");


            String orderid = request.getParameter("orderid");
            String username = request.getParameter("username");
            String gameid = request.getParameter("gameid");
            String roleid = request.getParameter("roleid");
            String serverid = request.getParameter("serverid");
            String paytype = request.getParameter("paytype");
            String amount = request.getParameter("amount");
            String paytime = request.getParameter("paytime");
            String attach = request.getParameter("attach");
            String sign = request.getParameter("sign");


            //sign=MD5(  orderid=100000 & username=zhangsan & gameid=6 & roleid=zhangsanfeng & serverid=1 & paytype=1 & amount=1 & paytime=20130101125612 & attach=test & appkey=12312312321)
            StringBuffer sb = new StringBuffer();
            sb.append("orderid=").append(orderid);
            sb.append("&username=").append(username);
            sb.append("&gameid=").append(gameid);
            sb.append("&roleid=").append(roleid);
            sb.append("&serverid=").append(serverid);
            sb.append("&paytype=").append(paytype);
            sb.append("&amount=").append(amount);
            sb.append("&paytime=").append(paytime);
            sb.append("&attach=").append(attach);
            sb.append("&appkey=").append(AppKey);

            String signStr = sb.toString();
            LOG.error("代签名字符串:" + signStr);
            String checkSign = MD5.md5Digest(signStr);

            if (!checkSign.equals(sign)) {
                LOG.error("gameFan 签名验证失败, checkSign:" + checkSign);
                return "errorSign";
            }

            String[] v = attach.split("_");

            PayInfo payInfo = new PayInfo();
            payInfo.platNo = getPlatNo();
            payInfo.platId = username;
            payInfo.orderId = orderid;
            payInfo.serialId = attach;
            payInfo.serverId = Integer.valueOf(v[0]);
            payInfo.roleId = Long.valueOf(v[1]);

            payInfo.realAmount = Double.valueOf(amount);
            payInfo.amount = (int) (payInfo.realAmount / 1);
            int code = payToGameServer(payInfo);
            if (code != 0) {
                LOG.error("gameFan 充值发货失败！！ " + code);
                return "error";
            } else {
                LOG.error("gameFan 充值发货成功！！ " + code);
                return "success";
            }
        } catch (Exception e) {
            LOG.error("gameFan 充值异常！！:" + e.getMessage());
            e.printStackTrace();
            return "error";
        }
    }

    @Override
    public GameError doLogin(JSONObject param, JSONObject response) {
        // TODO Auto-generated method stub
        return null;
    }

}
