package com.account.plat.impl.ifeng;

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
public class IfengPlat extends PlatBase {

    private static String partner_id;
    private static String partner_key;
    private static String game_id;
    private static String server_id;
    private static String channel_id;
    private static String VERIRY_URL;

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/ifeng/", "plat.properties");
        partner_id = properties.getProperty("partner_id");
        partner_key = properties.getProperty("partner_key");
        game_id = properties.getProperty("game_id");
        server_id = properties.getProperty("server_id");
        channel_id = properties.getProperty("channel_id");
        VERIRY_URL = properties.getProperty("VERIRY_URL");
    }

    public GameError doLogin(DoLoginRq req, DoLoginRs.Builder response) {

        if (!req.hasSid() || !req.hasBaseVersion() || !req.hasVersion() || !req.hasDeviceNo()) {
            return GameError.PARAM_ERROR;
        }

        String sid = req.getSid();
        String baseVersion = req.getBaseVersion();
        String versionNo = req.getVersion();
        String deviceNo = req.getDeviceNo();

        String uid = verifyAccount(sid);
        if (uid == null) {
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

    private String verifyAccount(String token) {
        LOG.error("ifeng开始调用sidInfo接口");
        StringBuffer sb = new StringBuffer();
        sb.append(partner_id).append(game_id).append(server_id).append(token)
                .append(partner_key);
        String sign = MD5.md5Digest(sb.toString()).toUpperCase();
        Map<String, String> parameter = new HashMap<String, String>();
        parameter.put("service", "user.validate");
        parameter.put("partner_id", partner_id);
        parameter.put("game_id", game_id);
        parameter.put("server_id", server_id);
        parameter.put("ticket", token);
        parameter.put("sign", sign);
        LOG.error("[请求参数]" + parameter.toString());

        String result = HttpUtils.sendGet(VERIRY_URL, parameter);
        LOG.error("[响应结果]" + result);
        try {
            if (result != null) {
                JSONObject rsp = JSONObject.fromObject(result);
                int code = rsp.getInt("code");
                if (code == 1) {
                    JSONObject data = rsp.getJSONObject("data");
                    return data.getString("user_id");
                }
            }
            return null;
        } catch (Exception e) {
            LOG.error("接口返回异常");
            e.printStackTrace();
            return null;
        }
    }

    @Override
    public String payBack(WebRequest request, String content,
                          HttpServletResponse response) {
        Iterator<String> iterator = request.getParameterNames();
        LOG.error("pay ifeng");
        LOG.error("pay ifeng content:" + content);
        while (iterator.hasNext()) {
            String paramName = iterator.next();
            LOG.error(paramName + ":" + request.getParameter(paramName));
        }
        LOG.error("[参数结束]");

        try {
            String partner_id = request.getParameter("partner_id");
            String game_id = request.getParameter("game_id");
            String server_id = request.getParameter("server_id");
            String bill_no = request.getParameter("bill_no");
            String price = request.getParameter("price");
            String user_id = request.getParameter("user_id");
            String trade_status = request.getParameter("trade_status");
            String partner_bill_no = request.getParameter("partner_bill_no");
            String extra = request.getParameter("extra");
            String sign = request.getParameter("sign");


            // Upper(MD5( partner_id + game_id + server_id + user_id + bill_no + price + trade_status + partner_key))
            String signstr = partner_id + game_id + server_id + user_id + bill_no + price + trade_status + partner_key;
            LOG.error("代签名字符串:" + signstr);

            String checkSign = MD5.md5Digest(signstr).toUpperCase();
            if (!checkSign.equals(sign)) {
                LOG.error("签名验证失败, checkSign:" + checkSign);
                return "FAILURE";
            }

            String[] v = extra.split("_");

            PayInfo payInfo = new PayInfo();
            payInfo.platNo = getPlatNo();
            payInfo.platId = user_id;
            payInfo.orderId = bill_no;
            payInfo.serialId = extra;
            payInfo.serverId = Integer.valueOf(v[0]);
            payInfo.roleId = Long.valueOf(v[1]);

            payInfo.realAmount = Double.valueOf(price);
            payInfo.amount = (int) (payInfo.realAmount / 1);
            int code = payToGameServer(payInfo);
            if (code != 0) {
                if (code == 2) {
                    return "FAILURE";
                }
                LOG.error("ch v2.5 充值发货失败！！ " + code);
            } else {
                LOG.error("ch v2.5 充值发货成功！！ " + code);
            }
            return "SUCCESS";
        } catch (Exception e) {
            LOG.error("ifeng 充值异常！！:" + e.getMessage());
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
