package com.account.plat.impl.muzhiM1;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
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
import com.account.plat.impl.muzhiM1.Base64;
import com.account.plat.impl.muzhiM1.Rsa;
import com.account.util.RandomHelper;
import com.game.pb.AccountPb.DoLoginRq;
import com.game.pb.AccountPb.DoLoginRs;

//class UcAccount {
//	public int ucid;
//	public String nickName;
//}

@Component
public class MuzhiM1Plat extends PlatBase {
    // sdk server的接口地址
    // private static String serverUrl = "";

    // 游戏编号
    private static String AppID;

    private static String AppKey;

    // 分配给游戏合作商的接入密钥,请做好安全保密
    // private static String SecretKey = "";

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/muzhiM1/", "plat.properties");
        AppID = properties.getProperty("AppID");
        AppKey = properties.getProperty("AppKey");
        // SecretKey = properties.getProperty("SecretKey");
        // serverUrl = properties.getProperty("VERIRY_URL");
    }

    @Override
    public GameError doLogin(JSONObject param, JSONObject response) {
        // TODO Auto-generated method stub
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

        String[] vParam = sid.split("_");
        if (vParam.length < 3) {
            return GameError.PARAM_ERROR;
        }

        String userId = vParam[0];
        String userName = vParam[1];
        String sign = vParam[2];

        if (!verifyAccount(userId, userName, sign)) {
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
        LOG.error("pay mzwM1");
        LOG.error("[接收到的参数]" + content);
        try {
            String contentParam = request.getParameter("content");
            String sign = request.getParameter("sign");
            contentParam = new String(Base64.decode(contentParam));
            LOG.error("[content]" + contentParam);

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
                LOG.error("[订单参数]" + json);
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
                    LOG.error("mzwM1 充值回调错误！！gameid: " + game_id);
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
                        LOG.error("mzwM1 充值发货失败！！ " + code);
                    } else {
                        LOG.error("mzwM1 充值,发货成功");
                    }
                } else {
                    LOG.error("mzwM1 充值,失败订单，跳过");
                }
            } else {
                LOG.error("mzwM1 充值,签名验证失败 ");
            }
        } catch (Exception e) {
            LOG.error("mzwM1 充值异常！！ ");
            LOG.error("mzwM1 充值异常:" + e.getMessage());
            e.printStackTrace();
        }

        return "success";
    }

    private boolean verifyAccount(String userid, String usename, String sign) {
        LOG.error("mzwM1 开始调用sidInfo接口");
        // String signSource = usename + AppKey;// 组装签名原文
        // String signGenerate = Rsa.getMD5(signSource).toLowerCase();

        try {
            String signSource = usename + AppKey;
            signSource = URLEncoder.encode(signSource, "utf-8");
            String signGenerate = Rsa.getMD5(signSource).toLowerCase();

            LOG.error("[签名原文]" + signSource);
            LOG.error("[签名结果]" + signGenerate);
            LOG.error("[签名传入]" + sign);

            if (sign.equals(signGenerate)) {
                return true;
            }
        } catch (UnsupportedEncodingException e) {
            LOG.error("mzwM1 用户验证异常:" + e.getMessage());
            e.printStackTrace();
        }

        return false;
    }
}
