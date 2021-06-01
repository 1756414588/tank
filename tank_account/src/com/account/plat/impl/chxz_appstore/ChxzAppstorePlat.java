package com.account.plat.impl.chxz_appstore;

import java.util.*;

import javax.annotation.PostConstruct;
import javax.servlet.http.HttpServletResponse;

import org.springframework.stereotype.Component;
import org.springframework.web.context.request.WebRequest;

import com.account.constant.GameError;
import com.account.domain.Account;
import com.account.plat.PayInfo;
import com.account.plat.PlatBase;
import com.account.plat.impl.mzTkhslx_appstore.Rsa;
import com.account.plat.impl.self.util.HttpUtils;
import com.account.util.RandomHelper;
import com.alibaba.fastjson.JSON;
import com.game.pb.AccountPb.DoLoginRq;
import com.game.pb.AccountPb.DoLoginRs;

import net.sf.json.JSONObject;

@Component
public class ChxzAppstorePlat extends PlatBase {

    // 游戏编号
    private static String AppID;

    private static String AppKey;

    private static String ServerKey;

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/chxz_appstore/", "plat.properties");
        AppID = properties.getProperty("AppID");
        AppKey = properties.getProperty("AppKey");
        ServerKey = properties.getProperty("ServerKey");
    }

    @Override
    public int getPlatNo() {
        return 94;
    }

    @Override
    public GameError doLogin(JSONObject param, JSONObject response) {
        return GameError.OK;
    }

    public GameError doLogin(DoLoginRq req, DoLoginRs.Builder response) {

        if (!req.hasSid() || !req.hasBaseVersion() || !req.hasVersion() || !req.hasDeviceNo()) {
            return GameError.PARAM_ERROR;
        }

        String sid = req.getSid();
        String baseVersion = req.getBaseVersion();
        String versionNo = req.getVersion();
        String deviceNo = req.getDeviceNo();
        //userid__userName__token

        String[] vParam = sid.split("__");
        if (vParam.length < 3) {
            return GameError.PARAM_ERROR;
        }

        String userId = vParam[0];
        String userName = vParam[1];
        String tokenStr = vParam[2];
//        String timestamp = vParam[3];

        if (!verifyAccount(userId, tokenStr, "")) {
            return GameError.SDK_LOGIN;
        }

        Account account = accountDao.selectByPlatId(getPlatNo(), userId);
        if (account == null) {
            String token = RandomHelper.generateToken();
            account = new Account();
            account.setPlatNo(this.getPlatNo());
            account.setChildNo(super.getPlatNo());
            account.setPlatId(userId);
            account.setAccount(getPlatNo() + "_" + userId);
            account.setPasswd(userName);
            account.setBaseVersion(baseVersion);
            account.setVersionNo(versionNo);
            account.setToken(token);
            account.setDeviceNo(deviceNo);

            Date now = new Date();
            account.setLoginDate(now);
            account.setCreateDate(now);
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

    @Override
    public String payBack(WebRequest request, String content, HttpServletResponse response) {

        // string 32 草花唯一订单号
        //orderno_cp string 64 游戏订单号
        //userid int 10 草花唯一用户
        //ID order_amt int 10 订单金额（单位：分）
        //pay_amt int 10 充值金额（单位：分）
        //pay_time int 10 充值完成时间戳
        //extra string 64 游戏透传字段 s
        //ign string 32 签名（见附录一）
        JSONObject result = new JSONObject();

        LOG.error("pay chxz_appstore ");
        LOG.error("chxz_appstore 接收到的参数" + content);
        try {
            Map<String, String> params = new TreeMap<String, String>();

            Iterator<String> iterator = request.getParameterNames();
            while (iterator.hasNext()) {
                String paramName = iterator.next();

                if ("plat".equals(paramName)) {
                    continue;
                }

                params.put(paramName, request.getParameter(paramName));
                LOG.error("chxz_appstore " + paramName + ":" + request.getParameter(paramName));
            }
            LOG.error("chxz_appstore 结束参数");


            String orderno = request.getParameter("orderno");
            String orderno_cp = request.getParameter("orderno_cp");
            String userid = request.getParameter("userid");
            String order_amt = request.getParameter("order_amt");
            String pay_amt = request.getParameter("pay_amt");
            String pay_time = request.getParameter("pay_time");
            String extra = request.getParameter("extra");
            String sign = request.getParameter("sign");


            List<String> param = new ArrayList();
            for (String patam : params.keySet()) {
                param.add(patam);
            }
            Collections.sort(param);

            LOG.error("chxz_appstore  param  " + JSON.toJSONString(params));

            StringBuilder sb = new StringBuilder();
            for (String str : param) {

                if (str.equals("sign")) {
                    continue;
                }

                sb.append(str);
                sb.append("=");
                sb.append(params.get(str));
                sb.append("&");
            }
            String md5str = sb.substring(0, sb.length() - 1) + ServerKey;
            String mysign = Rsa.getMD5(md5str).toUpperCase();


            if (!mysign.equals(sign)) {// 签名正确,做业务逻辑处理
                LOG.error("chxz_appstore  md5str=" + md5str);
                result.put("code", 202);
                result.put("msg", "签名错误");
                return result.toString();

            }

            String[] v = orderno_cp.split("_");

            PayInfo payInfo = new PayInfo();
            payInfo.platNo = getPlatNo();
            payInfo.platId = userid;
            payInfo.orderId = orderno;
            payInfo.childNo = super.getPlatNo();
            payInfo.serialId = orderno_cp;
            payInfo.serverId = Integer.valueOf(v[0]);
            payInfo.roleId = Long.valueOf(v[1]);
            payInfo.realAmount = Double.valueOf(pay_amt) / 100;
            payInfo.amount = (int) payInfo.realAmount;
            int code = payToGameServer(payInfo);
            if (code != 0) {
                LOG.error("chxz_appstore  " + code);
            } else {
                LOG.error("chxz_appstore  充值发货成功");
            }

            result.put("code", 200);
            result.put("msg", "成功");
            return result.toString();

        } catch (Exception e) {
            LOG.error("chxz_appstore " + e.getMessage());
            e.printStackTrace();
            result.put("code", 203);
            result.put("msg", "系统错误");
            return result.toString();
        }
    }

    private boolean verifyAccount(String userid, String token, String times) {
        try {

            times = System.currentTimeMillis() / 1000 + "";

            LOG.error("chxz_appstore 战争指挥官");

            String body = "appid=" + AppID + "&times=" + times + "&token=" + token + "&userid=" + userid;
            LOG.error("chxz_appstore md5 md5str=" + body + AppKey);
            String sign = Rsa.getMD5(body + AppKey).toUpperCase();
            body = "appid=" + AppID + "&times=" + times + "&token=" + token + "&userid=" + userid + "&sign=" + sign;
            LOG.error("chxz_appstore 请求参数 body=" + body);

            String result = HttpUtils.sentPost("http://passport.ios.caohua.com/api/verifyToken", body);

            if (result.equals("") || result == null) {
                return false;
            }

            LOG.error("chxz_appstore  响应结果 " + result);
            JSONObject rsp = JSONObject.fromObject(result);
            String code = rsp.getString("code");
            if (!"200".equals(code)) {
                return false;
            }
            return true;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

}
