package com.account.plat.impl.chQzZzzhgSogo;

import java.net.URLEncoder;
import java.util.*;

import javax.annotation.PostConstruct;
import javax.servlet.http.HttpServletResponse;

import com.account.plat.impl.kaopu.MD5Util;
import org.springframework.stereotype.Component;
import org.springframework.web.context.request.WebRequest;

import com.account.constant.GameError;
import com.account.domain.Account;
import com.account.plat.PayInfo;
import com.account.plat.PlatBase;
import com.account.plat.impl.self.util.HttpUtils;
import com.account.plat.impl.self.util.MD5;
import com.account.util.RandomHelper;
import com.game.pb.AccountPb.DoLoginRq;
import com.game.pb.AccountPb.DoLoginRs;

import net.sf.json.JSONObject;

/**
 * @author: LiFeng
 * @date:
 * @description:
 */
@Component
public class ChQzZzzhgSogoPlat extends PlatBase {

    private static String GameId = "";
    private static String Secret = "";
    private static String Verify_Url = "";
    private static String Pay_Key = "";

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/chQzZzzhgSogo/", "plat.properties");
        GameId = properties.getProperty("GameId");
        Secret = properties.getProperty("Secret");
        Verify_Url = properties.getProperty("Verify_Url");
        Pay_Key = properties.getProperty("Pay_Key");
    }

    @Override
    public GameError doLogin(JSONObject param, JSONObject response) {
        return GameError.OK;
    }

    public GameError doLogin(DoLoginRq req, DoLoginRs.Builder response) {

        if (!req.hasSid() || !req.hasBaseVersion() || !req.hasVersion() || !req.hasDeviceNo()) {
            LOG.error("ChQzZzzhgSogoPlat GameError.PARAM_ERROR");
            return GameError.PARAM_ERROR;
        }

        String sid = req.getSid();
        String baseVersion = req.getBaseVersion();
        String versionNo = req.getVersion();
        String deviceNo = req.getDeviceNo();
        String[] vParam = sid.split("_");
        if (vParam.length < 2) {
            LOG.error("ChQzZzzhgSogoPlat sid length " + vParam.length);
            return GameError.PARAM_ERROR;
        }

        String userId = vParam[0];
        String session = vParam[1];

        Boolean back = verifyAccount(userId, session);
        if (!back) {
            LOG.error("GameError.SDK_LOGIN:" + GameError.SDK_LOGIN);
            return GameError.SDK_LOGIN;
        }

        Account account = accountDao.selectByPlatId(getPlatNo(), userId);

        if (account == null) {
            String token = RandomHelper.generateToken();
            account = new Account();

            account.setPlatNo(this.getPlatNo());
            account.setPlatId(userId);
            account.setAccount(getPlatNo() + "_" + userId);
            account.setPasswd(userId);
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
            LOG.error("authorityRs" + authorityRs);
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

    private Boolean verifyAccount(String userId, String session) {
        try {
            LOG.error("ChQzZzzhgSogoPlat 开始调用sidInfo接口");
            String temp = "gid=" + GameId + "&sessionKey=" + session + "&userId=" + userId;
            String param = temp + "&" + Secret;
            String auth = MD5.md5Digest(param);
            LOG.error("ChQzZzzhgSogoPlat 登陆验证组装加密后的param " + param);
            String msg = temp + "&auth=" + auth;
            LOG.error("ChQzZzzhgSogoPlat 登陆验证待发送参数  " + msg);

            String result = HttpUtils.sentPost(Verify_Url, msg);
            LOG.error("ChQzZzzhgSogoPlat 登陆验证返回结果  " + result);

            JSONObject json = JSONObject.fromObject(result);
            if (!"0".equals(json.getString("code"))) {
                LOG.error("ChQzZzzhgSogoPlat 登陆验证失败  " + json.getString("msg"));
                return false;
            }
            return true;
        } catch (Exception e) {
            LOG.error("ChQzZzzhgSogoPlat 登陆验证接口返回异常 " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }


    @Override
    public String payBack(WebRequest request, String content, HttpServletResponse response) {
        LOG.error("ChQzZzzhgSogoPlat payBack开始 content=" + content);

        try {
            List<String> paramNames = new ArrayList<>();
            Iterator<String> it = request.getParameterNames();

            LOG.error("ChQzZzzhgSogoPlat 支付回调参数信息打印开始");
            while (it.hasNext()) {
                String paramName = it.next();
                LOG.error("ChQzZzzhgSogoPlat param " + paramName + "=" + request.getParameter(paramName));
                if ("auth".equals(paramName)) {
                    continue;
                }
                paramNames.add(paramName);
            }
            LOG.error("ChQzZzzhgSogoPlat 支付回调参数信息打印结束cc");

            Collections.sort(paramNames);

            StringBuilder sb = new StringBuilder();
            for (String paramName : paramNames) {
                String v = URLEncoder.encode(request.getParameter(paramName));
                sb.append(paramName + "=" + v + "&");
            }

            sb.append(Pay_Key);

            LOG.error("ChQzZzzhgSogoPlat 参与签名的字符串 " + sb.toString());

            String checkSign = MD5Util.toMD5(sb.toString());

            LOG.error("ChQzZzzhgSogoPlat 加密后的签名串 " + checkSign);

            String sign = request.getParameter("auth");
            LOG.error("ChQzZzzhgYxfPlat 接收到的签名串 " + sign);

            if (!checkSign.equalsIgnoreCase(sign)) {
                LOG.error("ChQzZzzhgSogoPlat 充值发货失败！！md5 验证不通过 ");
                return "ERR_200";
            }

            PayInfo payInfo = new PayInfo();
            // 游戏内部渠道号
            payInfo.platNo = getPlatNo();
            // 渠道订单号
            payInfo.orderId = request.getParameter("oid");
            // 付费金额
            payInfo.amount = Float.valueOf(request.getParameter("amount1")).intValue();
            payInfo.realAmount = payInfo.amount;

            String[] param = request.getParameter("appdata").split("_");
            String serverid = param[0];
            String roleid = param[1];

            // 游戏内部订单号
            payInfo.serialId = request.getParameter("appdata");
            // 渠道id
            payInfo.platId = request.getParameter("uid");
            // 游戏区号
            payInfo.serverId = Integer.valueOf(serverid);
            // 玩家角色id
            payInfo.roleId = Long.valueOf(roleid);

            int code = payToGameServer(payInfo);
            if (code == 0 || code == 1) {
                LOG.error("ChQzZzzhgSogoPlat 充值发货成功！！ " + code);
                return "OK";
            } else {
                LOG.error("ChQzZzzhgSogoPlat 充值发货失败！！ " + code);
                return "ERR_500";
            }

        } catch (Exception e) {
            LOG.error("ChQzZzzhgSogoPlat 充值异常！！ " + e.getMessage());
            e.printStackTrace();
            return "ERR_500";
        }

    }

}
