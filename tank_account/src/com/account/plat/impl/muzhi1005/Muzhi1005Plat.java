package com.account.plat.impl.muzhi1005;

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


@Component
public class Muzhi1005Plat extends PlatBase {
    // sdk server的接口地址
    // private static String serverUrl = "";

    // 游戏编号
    private static String AppID;

    private static String AppKey;

    @Override
    public String getAppId() {
        return AppID;
    }

    @Override
    public int getPlatNo() {
        return 81;
    }
// 分配给游戏合作商的接入密钥,请做好安全保密
    // private static String SecretKey = "";

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/muzhi1005/", "plat.properties");
        AppID = properties.getProperty("AppID");
        AppKey = properties.getProperty("AppKey");
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

        String userId = vParam[0];
        String userName = vParam[1];
        String sign = vParam[2];
        String timestamp = vParam.length == 4 ? vParam[3] : null;

        if (!verifyAccount(userId, userName, sign, timestamp)) {
            return GameError.SDK_LOGIN;
        }

        Account account = accountDao.selectByPlatId(getPlatNo(), userId);
        if (account == null) {
            String token = RandomHelper.generateToken();
            account = new Account();
            account.setPlatNo(this.getPlatNo());
            account.setPlatId(userId);
            account.setAccount(getPlatNo() + "_" + userId);
            account.setPasswd(userName);
            account.setBaseVersion(baseVersion);
            account.setVersionNo(versionNo);
            account.setToken(token);
            account.setDeviceNo(deviceNo);
            account.setChildNo(203);
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
        LOG.error("pay muzhi1");
        LOG.error("pay muzhi1 [接收到的参数]" + content);
        try {
            String contentParam = request.getParameter("content");
            String sign = request.getParameter("sign");
            contentParam = new String(Base64.decode(contentParam));
            LOG.error("pay muzhi1 [content]" + contentParam);

            String mysign = Rsa.getMD5(contentParam + "&key=" + AppKey);
            if (mysign.equals(sign)) {// 签名正确,做业务逻辑处理
                String pay_no;
                // String username;
                // String device_id;
                String game_id;
                // int server_id;
                String cp_order_id;
                // String pay_type;
                // String thir_pay_id;
                int amount;
                int payStatus;
                String user_id;

                JSONObject json = JSONObject.fromObject(contentParam);
                LOG.error("pay muzhi1 [订单参数]" + json);
                pay_no = json.getString("pay_no");
                // username = json.getString("username");
                // device_id = json.getString("device_id");
                // server_id = json.getInt("server_id");
                game_id = json.getString("game_id");
                cp_order_id = json.getString("cp_order_id");
                // pay_type = json.getString("pay_type");
                amount = json.getInt("amount");
                payStatus = json.getInt("payStatus");
                user_id = json.getString("user_id");
                if (!AppID.equals(game_id)) {
                    LOG.error("pay muzhi1 充值回调错误！！gameid: " + game_id);
                    return "success";
                }

                if (payStatus == 0) {
                    // 1.下发游戏币,玩家实际付费以本通知的amount为准，不能使用订单生成的金额。
                    // 2.成功与否都返回success，SDK服务器只关心是否有通知到CP服务器

                    // serverId_roleId_timeStamp
                    String[] v = cp_order_id.split("_");

                    PayInfo payInfo = new PayInfo();
                    payInfo.platNo = getPlatNo();
                    payInfo.platId = user_id;
                    payInfo.orderId = pay_no;

                    payInfo.serialId = cp_order_id;
                    payInfo.serverId = Integer.valueOf(v[0]);
                    payInfo.roleId = Long.valueOf(v[1]);
                    payInfo.realAmount = Double.valueOf(amount) / 100.0;
                    payInfo.amount = amount / 100;
                    int code = payToGameServer(payInfo);
                    if (code != 0) {
                        LOG.error("pay muzhi1 充值发货失败！！ " + code);
                    } else {
                        LOG.error("pay muzhi1 充值,发货成功");
                    }
                } else {
                    LOG.error("pay muzhi1 充值,失败订单，跳过");
                }
            } else {
                LOG.error("pay muzhi1 充值,签名验证失败 ");
            }
        } catch (Exception e) {
            LOG.error("pay muzhi1 充值异常！！ ");
            LOG.error("pay muzhi1 充值异常:" + e.getMessage());
            e.printStackTrace();
        }

        return "success";
    }

    private boolean verifySgin(String signSource, String sign) {

        try {
            signSource = URLEncoder.encode(signSource, "utf-8");
            String signGenerate = Rsa.getMD5(signSource).toLowerCase();
            LOG.error("pay muzhi1[签名原文]" + signSource);
            LOG.error("pay muzhi1[签名结果]" + signGenerate);
            LOG.error("pay muzhi1[签名传入]" + sign);
            return sign.equals(signGenerate);
        } catch (UnsupportedEncodingException e) {
            LOG.error("pay muzhi1 用户验证异常:" + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }


    /**
     * 新的验证方式 兼容老方式
     *
     * @param userid
     * @param usename
     * @param sign
     * @param timestamp
     * @return boolean
     */
    private boolean verifyAccount(String userid, String usename, String sign, String timestamp) {
        if (timestamp == null) {
            return verifyAccount(userid, usename, sign);
        }
        LOG.error("pay muzhi1 开始调用新的sidInfo接口");
        return verifySgin(userid + AppKey + timestamp, sign);
    }


    /**
     * 老验证方式
     *
     * @param userid
     * @param usename
     * @param sign
     * @return boolean
     */
    private boolean verifyAccount(String userid, String usename, String sign) {
        LOG.error("pay muzhi1 开始调用老的sidInfo接口");
        return verifySgin(usename + AppKey, sign);
    }

    public static void main(String[] args) {
        //LOG.error("pay muzhi1 开始调用sidInfo接口");
        String[] vParam = "47621975_mz6094182_46069522c415c7528ddbe405bd3599cd_1515740228523".split("_");
        String userId = vParam[0];
        String userName = vParam[1];
        String sign = vParam[2];
        String timestamp = vParam.length == 4 ? vParam[3] : null;
        new Muzhi1005Plat().verifySgin(userId + "zty337" + timestamp, sign);
    }
}
