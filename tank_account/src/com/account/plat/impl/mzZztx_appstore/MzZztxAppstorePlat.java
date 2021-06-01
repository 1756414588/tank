package com.account.plat.impl.mzZztx_appstore;

import com.account.constant.GameError;
import com.account.domain.Account;
import com.account.plat.PayInfo;
import com.account.plat.PlatBase;
import com.account.util.RandomHelper;
import com.game.pb.AccountPb.DoLoginRq;
import com.game.pb.AccountPb.DoLoginRs;
import net.sf.json.JSONObject;
import org.springframework.stereotype.Component;
import org.springframework.web.context.request.WebRequest;

import javax.annotation.PostConstruct;
import javax.servlet.http.HttpServletResponse;
import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.Date;
import java.util.Properties;
/**
 * @author yeding
 * @create 2019/4/16 16:16
 * @decs
 */
@Component
public class MzZztxAppstorePlat extends PlatBase{

    // 游戏编号
    private static String AppID;

    private static String AppKey;

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/mzZztx_appstore/", "plat.properties");
        AppID = properties.getProperty("AppID");
        AppKey = properties.getProperty("AppKey");
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

        String userId = null;
        String userName = null;
        String sign = null;
        String timestamp = null;
        if (vParam.length == 3) {

            userId = vParam[0];
            userName = vParam[1];
            sign = vParam[2];
        }

        if (vParam.length == 4) {
            userId = vParam[1];
            userName = vParam[2];
            sign = vParam[3];
            timestamp = vParam[0];
        }


        if (!verifyAccount(userId, userName, sign, timestamp)) {
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
        LOG.error("pay mzZztx_appstore(战争突袭)");
        LOG.error("mzZztx_appstore 接收到的参数" + content);
        try {
            String contentParam = request.getParameter("content");
            String sign = request.getParameter("sign");
            contentParam = new String(Base64.decode(contentParam));
            LOG.error("mzZztx_appstore 订单参数" + contentParam);

            String mysign = Rsa.getMD5(contentParam + "&key=" + AppKey);
            if (mysign.equals(sign)) {// 签名正确,做业务逻辑处理
                String pay_no;
                String cp_order_id;
                int amount;
                int payStatus;
                String user_id;

                JSONObject json = JSONObject.fromObject(contentParam);
                pay_no = json.getString("pay_no");
                cp_order_id = json.getString("cp_order_id");
                amount = json.getInt("amount");
                payStatus = json.getInt("payStatus");
                user_id = json.getString("user_id");

                if (payStatus == 0) {
                    // 1.下发游戏币,玩家实际付费以本通知的amount为准，不能使用订单生成的金额。
                    // 2.成功与否都返回success，SDK服务器只关心是否有通知到CP服务器

                    String[] v = cp_order_id.split("_");

                    PayInfo payInfo = new PayInfo();
                    payInfo.platNo = getPlatNo();
                    payInfo.platId = user_id;
                    payInfo.orderId = pay_no;
                    payInfo.childNo = super.getPlatNo();
                    payInfo.serialId = cp_order_id;
                    payInfo.serverId = Integer.valueOf(v[0]);
                    payInfo.roleId = Long.valueOf(v[1]);
                    payInfo.realAmount = Double.valueOf(amount) / 100;
                    payInfo.amount = (int) payInfo.realAmount;
                    int code = payToGameServer(payInfo);
                    if (code != 0) {
                        LOG.error("mzZztx_appstore(战争突袭) 充值发货失败！！ " + code);
                    } else {
                        LOG.error("mzZztx_appstore(战争突袭) 充值发货成功");
                    }
                } else {
                    LOG.error("mzZztx_appstore (战争突袭) 充值失败，跳过");
                }
            } else {
                LOG.error("mzZztx_appstore (战争突袭) 签名验证失败");
            }
        } catch (Exception e) {
            LOG.error("mzZztx_appstore (战争突袭) 充值异常！！ " + e.getMessage());
            e.printStackTrace();
        }

        return "success";
    }

    private boolean verifyAccount(String userid, String usename, String sign, String timestamp) {
        LOG.error("mzZztx_appstore (战争突袭) 开始调用sidInfo接口");

        try {
            String signSource = null;
            if (timestamp != null) {
                signSource = userid + AppKey + timestamp;
            } else {
                signSource = usename + AppKey;
            }

            signSource = URLEncoder.encode(signSource, "utf-8");
            String signGenerate = Rsa.getMD5(signSource).toLowerCase();

            LOG.error("mzZztx_appstore 签名原文" + signSource);
            LOG.error("mzZztx_appstore 签名结果" + signGenerate);
            LOG.error("mzZztx_appstore 签名传入" + sign);

            if (sign.equals(signGenerate)) {
                return true;
            }
        } catch (UnsupportedEncodingException e) {
            LOG.error("mzZztx_appstore (战争突袭) 签名异常" + e.getMessage());
            e.printStackTrace();
        }

        return false;
    }

}
