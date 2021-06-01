package com.account.plat.impl.newUc;

import java.util.Date;
import java.util.Properties;

import javax.annotation.PostConstruct;
import javax.servlet.http.HttpServletResponse;

import net.sf.json.JSONObject;

import org.springframework.stereotype.Component;
import org.springframework.web.context.request.WebRequest;

import com.account.constant.GameError;
import com.account.domain.Account;
import com.account.plat.PlatBase;
import com.account.plat.impl.self.util.HttpUtils;
import com.account.plat.impl.self.util.MD5;
import com.account.util.RandomHelper;
import com.game.pb.AccountPb.DoLoginRq;
import com.game.pb.AccountPb.DoLoginRs;

class UcAccount {
    public String ucid;
    public String nickName;
}

@Component
public class NewUcPlat extends PlatBase {
    // sdk server的接口地址
    private static String serverUrl = "";
    // 游戏合作商编号
    // private static String cpId;
    // 游戏编号
    private static String gameId;

    // 分配给游戏合作商的接入密钥,请做好安全保密
    private static String apiKey = "";

    // private static String asynnUrl;

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/newUc/", "plat.properties");
        // if (properties != null) {
        // cpId = properties.getProperty("CP_ID");
        apiKey = properties.getProperty("API_KEY");
        gameId = properties.getProperty("GAME_ID");
        serverUrl = properties.getProperty("VERIRY_URL");
        // asynnUrl = properties.getProperty("ASYN_URL");
        // }
    }

    public GameError doLogin(DoLoginRq req, DoLoginRs.Builder response) {

        if (!req.hasSid() || !req.hasBaseVersion() || !req.hasVersion() || !req.hasDeviceNo()) {
            return GameError.PARAM_ERROR;
        }

        String sid = req.getSid();
        String baseVersion = req.getBaseVersion();
        String versionNo = req.getVersion();
        String deviceNo = req.getDeviceNo();

        UcAccount ucAccount = verifyAccount(sid);
        if (ucAccount == null) {
            return GameError.SDK_LOGIN;
        }

        Account account = accountDao.selectByPlatId(getPlatNo(), String.valueOf(ucAccount.ucid));
        if (account == null) {
            String token = RandomHelper.generateToken();
            account = new Account();
            account.setPlatNo(this.getPlatNo());
            account.setPlatId(String.valueOf(ucAccount.ucid));
            account.setAccount(getPlatNo() + "_" + String.valueOf(ucAccount.ucid));
            account.setPasswd(String.valueOf(ucAccount.ucid));
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
    public GameError doLogin(JSONObject param, JSONObject response) {
        // TODO Auto-generated method stub
        if (!param.containsKey("sid") || !param.containsKey("baseVersion") || !param.containsKey("version") || !param.containsKey("deviceNo")) {
            return GameError.PARAM_ERROR;
        }

        String sid = param.getString("sid");
        String baseVersion = param.getString("baseVersion");
        String versionNo = param.getString("version");
        String deviceNo = param.getString("deviceNo");

        UcAccount ucAccount = verifyAccount(sid);
        if (ucAccount == null) {
            return GameError.SDK_LOGIN;
        }

        Account account = accountDao.selectByPlatId(getPlatNo(), String.valueOf(ucAccount.ucid));
        if (account == null) {
            String token = RandomHelper.generateToken();
            account = new Account();
            account.setPlatNo(this.getPlatNo());
            account.setPlatId(String.valueOf(ucAccount.ucid));
            account.setAccount(getPlatNo() + "_" + String.valueOf(ucAccount.ucid));
            account.setPasswd(String.valueOf(ucAccount.ucid));
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
            account.setVersionNo(versionNo);
            account.setDeviceNo(deviceNo);
            account.setLoginDate(new Date());
            accountDao.updateTokenAndVersion(account);
        }

        GameError authorityRs = super.checkAuthority(account);
        if (authorityRs != GameError.OK) {
            return authorityRs;
        }

        response.put("recent", super.getRecentServers(account));
        response.put("keyId", account.getKeyId());
        response.put("token", account.getToken());

        if (isActive(account)) {
            response.put("active", 1);
        } else {
            response.put("active", 0);
        }

        return GameError.OK;
    }

    @Override
    public String payBack(WebRequest request, String content, HttpServletResponse response) {
        LOG.error("pay uc");
        LOG.error("[接收到的参数]" + content);
        try {

            JSONObject json = JSONObject.fromObject(content);

            String sign = json.getString("sign");
            JSONObject data = json.getJSONObject("data");

            String orderId = data.getString("orderId");
            String gameId = data.getString("gameId");
            String accountId = data.getString("accountId");
            String creator = data.getString("creator");
            String payWay = data.getString("payWay");
            String amount = data.getString("amount");
            String callbackInfo = data.getString("callbackInfo");
            String orderStatus = data.getString("orderStatus");
            String failedDesc = data.getString("failedDesc");
            if (!"S".equals(orderStatus)) {
                return "SUCCESS";
            }

            /**
             * MD5(accountId=...+amount=...+callbackInfo=...+cpOrderId=...+
             * creator=...+failedDesc=...+gameId=...
             * +orderId=...+orderStatus=...+payWay=...+apiKey)（去掉+； 替换...为实际 值）
             */

            String signSource = "accountId=" + accountId + "amount=" + amount + "callbackInfo=" + callbackInfo + "creator=" + creator + "failedDesc="
                    + failedDesc + "gameId=" + gameId + "orderId=" + orderId + "orderStatus=" + orderStatus + "payWay=" + payWay + apiKey;

            String orginSign = MD5.md5Digest(signSource);
            LOG.error("签名：" + orginSign + " | " + sign);
            if (orginSign.equals(sign)) {
                String[] infos = callbackInfo.split(",");
                if (infos.length != 4) {
                    return "SUCCESS";
                }
//				Long lordId = Long.valueOf(infos[0]);
//				int serverid = Integer.valueOf(infos[1]);
//				int rechargeId = Integer.valueOf(infos[2]);
//				String exorderno = infos[3];

//				int rsCode = payResult(lordId, serverid, Double.valueOf(amount) * 100, rechargeId, orderId, exorderno);
                int rsCode = 0;
                if (rsCode == 200) {
                    LOG.error("返回充值成功");
                    return "SUCCESS";
                } else {
                    LOG.error("返回充值失败");
                    return "SUCCESS";
                }
            } else {
                return "FAILURE";
            }
        } catch (Exception e) {
            e.printStackTrace();
            return "SUCCESS";
        }
    }

    private UcAccount verifyAccount(String sid) {
        LOG.error("new uc开始调用sidInfo接口");
        JSONObject params = new JSONObject();
        params.put("id", System.currentTimeMillis());

        JSONObject game = new JSONObject();
        game.put("gameId", Integer.valueOf(gameId));

        JSONObject data = new JSONObject();
        data.put("sid", sid);

        params.put("game", game);
        params.put("data", data);
        /*
         * 签名规则=MD5(sid=...+apiKey)
         * 假定cpId=109,apiKey=202cb962234w4ers2aaa,sid=abcdefg123456
         * 那么签名原文sid=abcdefg123456202cb962234w4ers2aaa
         * 签名结果6e9c3c1e7d99293dfc0c81442f9a9984
         */
        String signSource = "sid=" + sid + apiKey;// 组装签名原文
        String sign = MD5.md5Digest(signSource).toLowerCase();

        LOG.error("[签名原文]" + signSource);
        LOG.error("[签名结果]" + sign);

        params.put("sign", sign);

        String body = params.toString();
        LOG.error("[请求参数]" + body);

        String result = HttpUtils.sentPost(serverUrl, body);
        // post方式调用服务器接口,请求的body内容是参数json格式字符串
        LOG.error("[响应结果]" + result);// 结果也是一个json格式字符串

        UcAccount ucAccount = new UcAccount();

        try {
            JSONObject rsp = JSONObject.fromObject(result);
            JSONObject state = rsp.getJSONObject("state");
            int code = state.getInt("code");
            if (code == 1) {
                JSONObject rspData = rsp.getJSONObject("data");
                ucAccount.ucid = rspData.getString("accountId");
                ucAccount.nickName = rspData.getString("nickName");
                LOG.error("[ucid]" + ucAccount.ucid);
                LOG.error("[nickName]" + ucAccount.nickName);
                return ucAccount;
            } else {
                String msg = state.getString("msg");
                LOG.error("uc登陆失败:" + code);
                LOG.error("[msg]" + msg);
                return null;
            }

        } catch (Exception e) {
            // TODO: handle exception
            LOG.error("接口返回异常");
            e.printStackTrace();
        } finally {
            LOG.error("调用sidInfo接口结束");
        }

        return null;
    }
}
