package com.account.plat.impl.chQzZzzhgGionee;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.Iterator;
import java.util.List;
import java.util.Properties;

import javax.annotation.PostConstruct;
import javax.servlet.http.HttpServletResponse;

import org.springframework.stereotype.Component;
import org.springframework.web.context.request.WebRequest;

import com.account.constant.GameError;
import com.account.domain.Account;
import com.account.plat.PayInfo;
import com.account.plat.PlatBase;
import com.account.plat.impl.chQzZzzhgGionee.util.GioneeUtils;
import com.account.plat.impl.chQzZzzhgGionee.util.StringUtil;
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
public class ChQzZzzhgGioneePlat extends PlatBase {
    private static String ServerUrl = "";
    private static String Sceret = "";
    private static String AppKey = "";
    private static String public_key = "";
    private static String port = "443";
    private static String host = "id.gionee.com";
    private static String url = "/account/verify.do";
    private static String method = "POST";

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/chQzZzzhgGionee/", "plat.properties");
        ServerUrl = properties.getProperty("ServerUrl");
        Sceret = properties.getProperty("Secret");
        AppKey = properties.getProperty("AppKey");
        public_key = properties.getProperty("public_key");
    }

    @Override
    public GameError doLogin(JSONObject param, JSONObject response) {
        return GameError.OK; // GameError.INVALID_PARAM
    }

    public GameError doLogin(DoLoginRq req, DoLoginRs.Builder response) {

        if (!req.hasSid() || !req.hasBaseVersion() || !req.hasVersion() || !req.hasDeviceNo()) {
            LOG.error("ChQzZzzhg_gioneePlat GameError.PARAM_ERROR");
            return GameError.PARAM_ERROR;
        }

        String sid = req.getSid();
        String baseVersion = req.getBaseVersion();
        String versionNo = req.getVersion();
        String deviceNo = req.getDeviceNo();

        String[] params = sid.split("_");
        if (params.length < 2) {
            LOG.error("ChQzZzzhg_gioneePlat sid拆分错误  " + params.length);
            return GameError.PARAM_ERROR;
        }

        String pid = params[0];
        String amigoToken = params[1];


        Boolean back = verifyAccount(amigoToken);
        if (!back) {
            LOG.error("GameError.SDK_LOGIN:" + GameError.SDK_LOGIN);
            return GameError.SDK_LOGIN;
        }

        Account account = accountDao.selectByPlatId(getPlatNo(), pid);

        if (account == null) {
            String token = RandomHelper.generateToken();
            account = new Account();

            account.setPlatNo(this.getPlatNo());
            account.setPlatId(pid);
            account.setAccount(getPlatNo() + "_" + sid);
            account.setPasswd(pid);
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

    private Boolean verifyAccount(String token) {
        try {
            LOG.error("ChQzZzzhg_gioneePlat 开始调用sidInfo接口");

            String verify_url = ServerUrl;
            LOG.error("ChQzZzzhg_gioneePlat 请求url " + verify_url);

            String ts = String.valueOf(System.currentTimeMillis() / 1000);

            String nonce = StringUtil.randomStr();
            LOG.error("ChQzZzzhg_gioneePlat 请求参数中生成的随机字符串为  " + nonce);

            String mac = GioneeUtils.macSig(host, port, Sceret, ts, nonce, method, url);
            LOG.error("ChQzZzzhg_gioneePlat 请求参数组装后的签名内容为  " + mac);

            String authorization = GioneeUtils.builderAuthorization(AppKey, ts, nonce, mac);
            LOG.error("ChQzZzzhg_gioneePlat 拼接后的请求头Authorization内容为   " + authorization);

            String result = GioneeUtils.sendJsonPost(verify_url, authorization, token);
            LOG.error("ChQzZzzhg_gioneePlat 响应结果" + result);

            com.alibaba.fastjson.JSONObject jsonObject = com.alibaba.fastjson.JSONObject.parseObject(result);

            if (!jsonObject.containsKey("r") || "0".equals(jsonObject.getString("r"))) {
                LOG.error("ChQzZzzhg_gioneePlat 登陆成功");
                return true;
            } else {
                LOG.error("ChQzZzzhg_gioneePlat 登陆失败 " + result);
                return false;
            }
        } catch (Exception e) {
            LOG.error("ChQzZzzhg_gioneePlat 接口返回异常 " + e.getMessage());
            e.printStackTrace();
            return null;
        }
    }

    @Override
    public String payBack(WebRequest request, String content, HttpServletResponse response) {
        LOG.error("ChQzZzzhg_gioneePlat payBack开始 content=" + content);

        try {
            List<String> paramNames = new ArrayList<>();
            Iterator<String> it = request.getParameterNames();
            LOG.error("ChQzZzzhg_gioneePlat payBack 支付回调请求参数信息打印开始");
            while (it.hasNext()) {
                String paramName = it.next();
                LOG.error("ChQzZzzhg_gioneePlat payBack param " + paramName + "=" + request.getParameter(paramName));
                if ("sign".equals(paramName) || "plat".equals(paramName) || "msg".equals(paramName)) {
                    continue;
                }
                paramNames.add(paramName);
            }
            LOG.error("ChQzZzzhg_gioneePlat payBack 支付回调请求参数信息打印结束");

            Collections.sort(paramNames);
            StringBuilder sb = new StringBuilder();
            for (String paramName : paramNames) {
                sb.append(paramName + "=" + request.getParameter(paramName) + "&");
            }

            sb.deleteCharAt(sb.length() - 1);
            LOG.error("ChQzZzzhg_gioneePlat payBack 参与签名的字符串 " + sb.toString());

            String sign = request.getParameter("sign");
            LOG.error("ChQzZzzhg_gioneePlat payBack 接收到的签名串 " + sign);

            if (!GioneeUtils.doCheck(sb.toString(), sign, public_key)) {
                LOG.error("ChQzZzzhg_gioneePlat payBack  签名验证不通过！！ ");
                return "failure";
            }

            PayInfo payInfo = new PayInfo();
            // 游戏内部渠道号
            payInfo.platNo = getPlatNo();
            // 渠道订单号
            payInfo.orderId = request.getParameter("out_order_no");
            // 付费金额
            payInfo.amount = Float.valueOf(request.getParameter("deal_price")).intValue();
            payInfo.realAmount = payInfo.amount;

            String[] param = request.getParameter("out_order_no").split("_");
            String serverid = param[0];
            String roleid = param[1];

            // 游戏内部订单号
            payInfo.serialId = request.getParameter("out_order_no");
            // 渠道id
            payInfo.platId = roleid;
            // 游戏区号
            payInfo.serverId = Integer.valueOf(serverid);
            // 玩家角色id
            payInfo.roleId = Long.valueOf(roleid);

            int code = payToGameServer(payInfo);
            if (code == 0 || code == 1) {
                LOG.error("ChQzZzzhg_gioneePlat payBack 充值发货成功！！ " + code);
                return "success";
            } else {
                LOG.error("ChQzZzzhg_gioneePlat payBack 充值发货失败！！ " + code);
                return "failure";
            }

        } catch (Exception e) {
            LOG.error("ChQzZzzhg_gioneePlat payBack 充值异常！！ " + e.getMessage());
            e.printStackTrace();
            return "failure";
        }
    }

}
