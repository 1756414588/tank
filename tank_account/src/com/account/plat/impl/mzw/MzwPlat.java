package com.account.plat.impl.mzw;

import java.util.Date;
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

//class UcAccount {
//	public int ucid;
//	public String nickName;
//}

@Component
public class MzwPlat extends PlatBase {
    // sdk server的接口地址
    private static String serverUrl = "";

    // 游戏编号
    private static String APP_KEY;

    // 分配给游戏合作商的接入密钥,请做好安全保密
    private static String SECRET_KEY = "";

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/mzw/", "plat.properties");
        APP_KEY = properties.getProperty("APP_KEY");
        SECRET_KEY = properties.getProperty("SECRET_KEY");
        serverUrl = properties.getProperty("VERIRY_URL");
    }

    @Override
    public GameError doLogin(DoLoginRq req, DoLoginRs.Builder response) {
        // TODO Auto-generated method stub
        if (!req.hasSid() || !req.hasBaseVersion() || !req.hasVersion() || !req.hasDeviceNo()) {
            return GameError.PARAM_ERROR;
        }

        String sid = req.getSid();
        String baseVersion = req.getBaseVersion();
        String versionNo = req.getVersion();
        String deviceNo = req.getDeviceNo();

        String[] vParam = sid.split("_");
        if (vParam.length < 1) {
            return GameError.PARAM_ERROR;
        }

        String accessToken = vParam[0];
        // String uid = vParam[1];
        JSONObject rets = verifyAccount(accessToken);
        if (rets == null || !rets.containsKey("uid")) {
            return GameError.SDK_LOGIN;
        }

        String uid = rets.getString("uid");
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
        LOG.error("pay mzw");
        LOG.error("[接收到的参数]" + content);
        try {
            String appkey = request.getParameter("appkey");
            String orderID = request.getParameter("orderID");
            String productName = request.getParameter("productName");
            String productDesc = request.getParameter("productDesc");
            String productID = request.getParameter("productID");
            String money = request.getParameter("money");
            String uid = request.getParameter("uid");
            String extern = request.getParameter("extern");
            String sign = request.getParameter("sign");

            String signNation = appkey + orderID + productName + productDesc + productID + money + uid + extern + SECRET_KEY;
            String toSign = MD5.md5Digest(signNation);
            LOG.error("[签名原文]" + signNation);
            LOG.error("[签名结果]" + sign + "|" + toSign);

            if (!sign.equals(toSign)) {
                LOG.error("签名不正确");
                return "FAIL";
            }

            if (sign.equals(toSign)) {
                String[] infos = extern.split("_");
                if (infos.length != 3) {
                    LOG.error("自有参数不正确");
                    // return packResponse(1).toString();
                }

                int serverid = Integer.valueOf(infos[0]);
                Long lordId = Long.valueOf(infos[1]);
                // int rechargeId = Integer.valueOf(infos[2]);
                // String exorderno = infos[3];

                PayInfo payInfo = new PayInfo();
                payInfo.platNo = getPlatNo();
                payInfo.platId = uid;
                payInfo.orderId = orderID;

                payInfo.serialId = extern;
                payInfo.serverId = serverid;
                payInfo.roleId = lordId;
                payInfo.realAmount = Double.valueOf(money);
                payInfo.amount = (int) (payInfo.realAmount / 1);
                int code = payToGameServer(payInfo);

                if (code != 0) {
                    LOG.error("mzw 充值发货失败！！ " + code);
                } else {
                    LOG.error("mzw 充值发货成功！！ " + code);
                }
                return "SUCCESS";
            } else {
                // return packResponse(0).toString();
            }
        } catch (Exception e) {
            e.printStackTrace();
            return "SUCCESS";
        }
        return "SUCCESS";
    }

    private JSONObject verifyAccount(String accessToken) {
        LOG.error("mzw 开始调用sidInfo接口");

        String body = "token=" + accessToken + "&appkey=" + APP_KEY;
        LOG.error("[请求URL]" + serverUrl);
        LOG.error("[请求参数]" + body);

        String result = HttpUtils.sentPost(serverUrl, body);
        // post方式调用服务器接口,请求的body内容是参数json格式字符串
        LOG.error("[响应结果]" + result);

        int code = 0;
        String msg;
        try {
            JSONObject rsp = JSONObject.fromObject(result);
            code = rsp.getInt("code");
            msg = rsp.getString("msg");
            LOG.error("调用sidInfo接口结束");
            if (code == 1) {
                LOG.error("mzw登陆成功:" + accessToken);
                return rsp.getJSONObject("user");
                // return true;
            } else {
                LOG.error("mzw登陆失败:" + code + " 原因:" + msg);
                return null;
            }
        } catch (Exception e) {
            // TODO: handle exception
            LOG.error("接口返回异常");
            e.printStackTrace();
            return null;
        }

    }

    @Override
    public GameError doLogin(JSONObject param, JSONObject response) {
        return GameError.OK;
    }
}
