package com.account.plat.impl.tt;

import java.net.URLDecoder;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Properties;

import javax.annotation.PostConstruct;
import javax.servlet.http.HttpServletResponse;

import org.springframework.stereotype.Component;
import org.springframework.web.context.request.WebRequest;

import com.account.constant.GameError;
import com.account.domain.Account;
import com.account.plat.PayInfo;
import com.account.plat.PlatBase;
import com.account.util.RandomHelper;
import com.alibaba.fastjson.JSONObject;
import com.game.pb.AccountPb.DoLoginRq;
import com.game.pb.AccountPb.DoLoginRs;

@Component
public class TTPlat extends PlatBase {

    private static String GAME_ID;
    // sdk server的接口地址
    private static String VERIRY_URL;

    private static String VERIFY_KEY;

    private static String PAY_KEY;

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/tt/", "plat.properties");
        GAME_ID = properties.getProperty("GAME_ID");
        VERIFY_KEY = properties.getProperty("VERIFY_KEY");
        PAY_KEY = properties.getProperty("PAY_KEY");
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

        String[] vParam = sid.split("&");
        if (vParam.length < 2) {
            return GameError.PARAM_ERROR;
        }

        String uid = vParam[0];

        if (!verifyAccount(uid, vParam[1])) {
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
        LOG.error("pay TT ");
        LOG.error("[接收到的参数]" + content);

        Head head = new Head();
        TTResult result = new TTResult();
        result.setHead(head);
        ;
        try {
            Iterator<String> iterator = request.getParameterNames();
            while (iterator.hasNext()) {
                String paramName = iterator.next();
                LOG.error(paramName + ":" + request.getParameter(paramName));
            }
            LOG.error("[参数结束]");

            // 获取签名
            String ttsign = request.getHeader("sign");

            // 将报文进行urldecode
            String urldata = URLDecoder.decode(content, "utf-8");
            String sign = SignUtils.sign(urldata, PAY_KEY);
            LOG.error("服务器ttsign=" + ttsign);
            LOG.error("本地签名sign=" + sign);
            if (sign.equals(ttsign)) {
                LOG.error("支付回调参数信息:" + urldata);
                PayCallback pay = JSONObject.parseObject(urldata, PayCallback.class);
                if (null == pay) {
                    LOG.error("TT 充值参数异常， urldata:" + urldata);
                    head.setResult("-99");
                    head.setMessage("充值参数异常");
                } else {
                    if ("1".equals(pay.getPayResult())) {
                        String[] v = pay.getCpOrderId().split("_");

                        PayInfo payInfo = new PayInfo();
                        payInfo.platNo = getPlatNo();
                        payInfo.platId = pay.getUid();
                        payInfo.orderId = pay.getSdkOrderId();
                        payInfo.serialId = pay.getCpOrderId();
                        payInfo.serverId = Integer.valueOf(v[0]);
                        payInfo.roleId = Long.valueOf(v[1]);
                        payInfo.realAmount = Double.valueOf(pay.getPayFee());
                        payInfo.amount = (int) (payInfo.realAmount / 1);
                        int code = payToGameServer(payInfo);
                        if (code != 0) {
                            LOG.error("TT 充值发货失败！！ " + code);
                        } else {
                            LOG.error("TT 充值发货成功！！ ");
                        }
                    }
                    head.setResult("0");
                    head.setMessage("成功");
                }

            } else {
                head.setResult("-1");
                head.setMessage("验签失败");
            }
        } catch (Exception e) {
            LOG.error("TT 充值发货异常！！ " + e.getMessage());
            e.printStackTrace();
            head.setResult("-100");
            head.setMessage("充值发货异常");
        }
        return JSONObject.toJSONString(result);
    }

    private boolean verifyAccount(String uid, String sid) {
        LOG.error("TT 开始调用sidInfo接口");

        /**************************** 组合报文 *****************************/
        Map<String, Object> urldata = new HashMap<String, Object>();
        urldata.put("gameId", GAME_ID);
        urldata.put("uid", uid);
        String jsonBody = JSONObject.toJSONString(urldata);
        /**************************** 使用密钥进行签名 **********************/
        String sign = SignUtils.sign(jsonBody, VERIFY_KEY);
        LOG.error("sign=" + sign);

        /**************************** 组合headers *****************************/
        Map<String, Object> header = new HashMap<String, Object>();
        header.put("sid", sid);
        header.put("sign", sign);

        try {
            String result = HttpUtil.doPost(VERIRY_URL, jsonBody, header);
            LOG.error("[响应结果]" + result);// 结果也是一个json格式字符串
            if (result == null) {
                return false;
            }

            TTResult tt = JSONObject.parseObject(result, TTResult.class);
            LOG.error("调用sidInfo接口结束");
            if (tt == null || tt.getHead() == null || !"0".equals(tt.getHead().getResult())) {
                return false;
            } else {
                return true;
            }
        } catch (Exception e) {
            LOG.error("接口返回异常:" + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public GameError doLogin(net.sf.json.JSONObject param, net.sf.json.JSONObject response) {
        // TODO Auto-generated method stub
        return null;
    }
}

class TTResult {
    private Head head;

    public Head getHead() {
        return head;
    }

    public void setHead(Head head) {
        this.head = head;
    }
}

class Head {
    private String result;// 返回代码 0 为用户处于登录状态，其它为失败

    private String message;

    public String getResult() {
        return result;
    }

    public void setResult(String result) {
        this.result = result;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }
}

class PayCallback {
    private String uid;
    private String gameId;
    private String sdkOrderId;
    private String cpOrderId;
    private float payFee;
    private String payResult;
    private String payDate;
    private String exInfo;

    public String getUid() {
        return uid;
    }

    public void setUid(String uid) {
        this.uid = uid;
    }

    public String getGameId() {
        return gameId;
    }

    public void setGameId(String gameId) {
        this.gameId = gameId;
    }

    public String getSdkOrderId() {
        return sdkOrderId;
    }

    public void setSdkOrderId(String sdkOrderId) {
        this.sdkOrderId = sdkOrderId;
    }

    public String getCpOrderId() {
        return cpOrderId;
    }

    public void setCpOrderId(String cpOrderId) {
        this.cpOrderId = cpOrderId;
    }

    public float getPayFee() {
        return payFee;
    }

    public void setPayFee(float payFee) {
        this.payFee = payFee;
    }

    public String getPayResult() {
        return payResult;
    }

    public void setPayResult(String payResult) {
        this.payResult = payResult;
    }

    public String getPayDate() {
        return payDate;
    }

    public void setPayDate(String payDate) {
        this.payDate = payDate;
    }

    public String getExInfo() {
        return exInfo;
    }

    public void setExInfo(String exInfo) {
        this.exInfo = exInfo;
    }
}