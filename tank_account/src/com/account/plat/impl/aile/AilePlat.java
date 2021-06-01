package com.account.plat.impl.aile;

import java.net.URLDecoder;
import java.net.URLEncoder;
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
import com.account.plat.impl.self.util.HttpUtils;
import com.account.plat.impl.self.util.MD5;
import com.account.util.RandomHelper;
import com.game.pb.AccountPb.DoLoginRq;
import com.game.pb.AccountPb.DoLoginRs;

@Component
public class AilePlat extends PlatBase {


    private static String VERIFY_URL;
    private static String APP_ID;
    private static String APP_KEY;

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/aile/", "plat.properties");
        VERIFY_URL = properties.getProperty("VERIFY_URL");
        APP_ID = properties.getProperty("APP_ID");
        APP_KEY = properties.getProperty("APP_KEY");
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
        if (vParam.length < 2) {
            return GameError.PARAM_ERROR;
        }
        String uid = vParam[0];

        if (!verifyAccount(vParam[0], vParam[1])) {
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

    private boolean verifyAccount(String uid, String token) {
        LOG.error("aile开始调用sidInfo接口");
        // sign 的签名规则：md5(app_id=...&mem_id=...&user_token=...&app_key=...)
        String signStr = "app_id=" + APP_ID + "&mem_id=" + uid + "&user_token=" + token + "&app_key=" + APP_KEY;
        LOG.error("[待签名参数]" + signStr);
        String sign = MD5.md5Digest(signStr);
        LOG.error("[签名参数]" + sign);
        String body = "app_id=" + APP_ID + "&mem_id=" + uid + "&user_token=" + token + "&sign=" + sign;
        LOG.error("[请求参数]" + body);
        String result = HttpUtils.sentPost(VERIFY_URL, body);
        LOG.error("[响应结果]" + result);
        try {
            if (result != null) {
                JSONObject rsp = JSONObject.fromObject(result);
                String status = rsp.getString("status");
                if (status.equals("1")) {
                    return true;
                }
            }
            return false;
        } catch (Exception e) {
            LOG.error("接口返回异常");
            e.printStackTrace();
            return false;
        }
    }


    @Override
    public String payBack(WebRequest request, String content,
                          HttpServletResponse response) {
        Iterator<String> iterator = request.getParameterNames();
        try {
            content = URLDecoder.decode(content, "utf-8");
            LOG.error("pay aile");
            LOG.error("pay aile content:" + content);
            LOG.error("[接收参数]");
            Map<String, String> params = new HashMap<String, String>();
            while (iterator.hasNext()) {
                String paramName = iterator.next();
                LOG.error(paramName + ":" + request.getParameter(paramName));
                params.put(paramName, request.getParameter(paramName));
            }
            LOG.error("[参数结束]");

            String app_id = params.get("app_id");
            String cp_order_id = params.get("cp_order_id");
            String mem_id = params.get("mem_id");
            String order_id = params.get("order_id");
            String order_status = params.get("order_status");
            String pay_time = params.get("pay_time");
            String product_id = params.get("product_id");
            String product_name = params.get("product_name");
            String product_price = params.get("product_price");
            String sign = params.get("sign");
            String ext = params.get("ext");


            if (!order_status.equals("2")) {
                LOG.error("aile 未支付成功, order_status:" + order_status);
                return "FAILURE";
            }

            // sign 的签名规则：md5(app_id...&cp_order_id...&mem_id...&order_id...&order_status...&pay_time...&product_id...&product_name...&product_price...&app_key=...)
            StringBuffer sb = new StringBuffer();
            sb.append("app_id=").append(APP_ID);
            sb.append("&cp_order_id=").append(cp_order_id);
            sb.append("&mem_id=").append(mem_id);
            sb.append("&order_id=").append(order_id);
            sb.append("&order_status=").append(order_status);
            sb.append("&pay_time=").append(pay_time);
            sb.append("&product_id=").append(product_id);
            sb.append("&product_name=").append(URLEncoder.encode(product_name));
            sb.append("&product_price=").append(product_price);
            sb.append("&app_key=").append(APP_KEY);

            String signStr = sb.toString();
            LOG.error("代签名字符串:" + signStr);
            String checkSign = MD5.md5Digest(signStr);

            if (!checkSign.equals(sign)) {
                LOG.error("aile 签名验证失败, checkSign:" + checkSign);
                return "FAILURE";
            }

            String[] v = ext.split("_");

            PayInfo payInfo = new PayInfo();
            payInfo.platNo = getPlatNo();
            payInfo.platId = mem_id;
            payInfo.orderId = order_id;
            payInfo.serialId = ext;
            payInfo.serverId = Integer.valueOf(v[0]);
            payInfo.roleId = Long.valueOf(v[1]);

            payInfo.realAmount = Double.valueOf(product_price);
            payInfo.amount = (int) (payInfo.realAmount / 1);
            int code = payToGameServer(payInfo);
            if (code != 0) {
                if (code == 1) {
                    LOG.error("aile 重复的订单信息！！ " + code);
                    return "FAILURE";
                }
                LOG.error("aile 充值发货失败！！ " + code);
                return "FAILURE";
            } else {
                LOG.error("aile 充值发货成功！！ " + code);
                return "SUCCESS";
            }
        } catch (Exception e) {
            LOG.error("aile 充值异常！！:" + e.getMessage());
            e.printStackTrace();
            return "FAILURE";
        }
    }

    @Override
    public GameError doLogin(JSONObject param, JSONObject response) {
        // TODO Auto-generated method stub
        return null;
    }

}
