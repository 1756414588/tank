package com.account.plat.impl.wandoujianew;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.Properties;

import javax.annotation.PostConstruct;
import javax.servlet.http.HttpServletResponse;

import net.sf.json.JSONObject;

import org.springframework.stereotype.Component;
import org.springframework.web.context.request.WebRequest;

import com.account.constant.GameError;
import com.account.domain.Account;
import com.account.domain.form.RoleLog;
import com.account.plat.PayInfo;
import com.account.plat.impl.self.util.HttpUtils;
import com.account.plat.impl.self.util.MD5;
import com.account.plat.impl.wandoujia.WdjPlat;
import com.account.plat.interfaces.LogRoleCreate2sdk;
import com.account.plat.interfaces.LogRoleLogin2sdk;
import com.account.plat.interfaces.LogRoleUp2sdk;
import com.account.util.RandomHelper;
import com.game.pb.AccountPb.DoLoginRq;
import com.game.pb.AccountPb.DoLoginRs;

@Component
public class WdjNewPlat extends WdjPlat implements LogRoleLogin2sdk, LogRoleCreate2sdk, LogRoleUp2sdk {
    public static final String PLAT_NAME = "wdj";

    /**
     * sdk相关
     */
    static class SdkConst {
        /**
         * sdk server的接口地址
         */
        private static String SERVER_URL;
        /**
         * sdk 扩展数据接口地址
         */
        private static String ROLELOG_URL;
        /**
         * sdk参数
         */
        private static int GAME_ID;
        /**
         * sdk参数
         */
        private static String API_KEY;
        /**
         * md5编码
         */
        private static String CHARSET = "UTF-8";

    }

    /**
     * 充值加签处理参数
     */
    static final class OrderConst {
        /**
         * 充值加签处理参数
         */
        private static final String[] PARAM_KEYS = {"accountId", "amount", "callbackInfo", "cpOrderId", "notifyUrl"};
        /**
         * 签名类型KEY
         */
        private static final String SIGN_TYPE = "signType";
        /**
         * MD5
         */
        private static final String SIGN_TYPE_MD5 = "MD5";
        /**
         * RSA
         */
        private static final String SIGN_TYPE_RSA = "RSA";
        /**
         * 签名结果KEY
         */
        private static final String SIGN = "sign";

    }

    /**
     * 充值结果回调接口参数
     */
    static final class PayBackConst {
        /**
         * 版本号
         */
        private static final String VER = "ver";
        /**
         * json数据
         */
        private static final String DATA = "data";
        /**
         * 签名
         */
        private static final String SIGN = "sign";

        /** 分割===========data 的key============= */
        /**
         * 充值订单号
         */
        private static final String ORDER_ID = "orderId";
        /**
         * 游戏编号
         */
        private static final String GAME_ID = "gameId";
        /**
         * 账号标识
         */
        private static final String ACCOUNT_ID = "accountId";
        /**
         * 账号的创建者
         */
        private static final String CREATOR = "creator";
        /**
         * 支付通道代码
         */
        private static final String PAY_WAY = "payWay";
        /**
         * 支付金额
         */
        private static final String AMOUNT = "amount";
        /**
         * 游戏合作商自定义参数
         */
        private static final String CALLBACK_INFO = "callbackInfo";
        /**
         * 订单状态
         */
        private static final String ORDER_STATUS = "orderStatus";
        /**
         * 订单失败原因详细描述
         */
        private static final String FAILED_DESC = "failedDesc";
        /**
         * Cp订单号
         */
        private static final String CP_ORDER_ID = "cpOrderId";

        /**
         * 回调MD5签名规则中的参数
         */
        private static final String[] SIGN_PARAM = {ACCOUNT_ID, AMOUNT, CALLBACK_INFO, CP_ORDER_ID, CREATOR,
                FAILED_DESC, GAME_ID, ORDER_ID, ORDER_STATUS, PAY_WAY};

    }

    /**
     * 用户登录接口接口请求参数key
     */
    static final class LoginRqConst {
        /**
         * 请求的唯一标识
         */
        private static final String ID = "id";
        /**
         * 请求数据
         */
        private static String DATA = "data";
        /**
         * game参数
         */
        private static String GAME = "game";
        /**
         * 签名参数
         */
        private static String SIGN = "sign";
        /**
         * 附属于DATA
         */
        private static String SID = "sid";
        /**
         * 附属于GAME
         */
        private static String GAME_ID = "gameId";

    }

    /**
     * 用户登录接口接口响应参数key
     */
    static final class RsConst {
        /**
         * 请求的唯一标识
         */
        private static final String ID = "id";
        /**
         * 响应状态
         */
        private static final String STATE = "state";
        /**
         * 响应状态编码
         */
        private static final String STATE_CODE = "code";
        /**
         * 响应状态值成功
         */
        private static final String STATE_SUCCESS = "1";
        /**
         * 响应状态值请求参数错误
         */
        private static final String STATE_PARAM_ERROR = "10";
        /**
         * 响应状态值用户未登录
         */
        private static final String STATE_NO_LOGIN = "11";
        /**
         * 响应状态值 游戏内部错误
         */
        private static final String STATE_SYSTEM_ERROR = "99";
        /**
         * 响应数据
         */
        private static String DATA = "data";
        /**
         * 账号标识
         */
        private static String ACCOUNT_ID = "accountId";
        /**
         * 账号创建者
         */
        private static String CREATOR = "creator";
        /**
         * 用户昵称
         */
        private static String NICK_NAME = "nickName";
    }

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/wandoujianew/", "plat.properties");

        SdkConst.GAME_ID = Integer.parseInt(properties.getProperty("GAME_ID"));
        SdkConst.API_KEY = properties.getProperty("API_KEY");
        SdkConst.SERVER_URL = properties.getProperty("SERVER_URL");
        SdkConst.ROLELOG_URL = properties.getProperty("ROLELOG_URL");
        SdkConst.CHARSET = properties.getProperty("CHARSET");
    }

    @Override
    public GameError doLogin(DoLoginRq req, DoLoginRs.Builder response) {
        // 兼容老豌豆荚
        if (req.getSid().indexOf(",") != -1) {
            return super.doLogin(req, response);
        }
        if (!req.hasSid() || !req.hasBaseVersion() || !req.hasVersion() || !req.hasDeviceNo()) {
            return GameError.PARAM_ERROR;
        }

        String sid = req.getSid();
        String baseVersion = req.getBaseVersion();
        String versionNo = req.getVersion();
        String deviceNo = req.getDeviceNo();

        JSONObject returnObject = verifyAccount(sid);
        String stateCode = returnObject.getJSONObject(RsConst.STATE).get(RsConst.STATE_CODE).toString();
        switch (stateCode) {
            case RsConst.STATE_SUCCESS:
                LOG.error("[wdjnew登陆成功]:");
                break;
            case RsConst.STATE_PARAM_ERROR:
                LOG.error("[wdjnew 登录失败]: 登陆接口参数错误");
                return GameError.PARAM_ERROR;
            case RsConst.STATE_NO_LOGIN:
                LOG.error("[wdjnew 登录失败]: 登陆接口参数错误");
                return GameError.SDK_LOGIN;
            case RsConst.STATE_SYSTEM_ERROR:
                LOG.error("[wdjnew 登录失败]: sdk登陆接口异常");
                return GameError.SDK_LOGIN;
            default:
                break;
        }

        String uid;
        {
            JSONObject data = (JSONObject) returnObject.get(RsConst.DATA);
            uid = (String) data.get(RsConst.ACCOUNT_ID);
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
        response.setUserInfo(uid);
        if (isActive(account)) {
            response.setActive(1);
        } else {
            response.setActive(0);
        }

        return GameError.OK;
    }

    @Override
    public String order(WebRequest request, String content) {
        LOG.error("pay wdjnew order");
        Map<String, String> paramMap = new HashMap<String, String>();
        StringBuffer sb = new StringBuffer();

        for (int i = 0; i < OrderConst.PARAM_KEYS.length; i++) {
            String v = request.getParameter(OrderConst.PARAM_KEYS[i]);
            if (v == null) {
                continue;
            }
            sb.append(OrderConst.PARAM_KEYS[i]).append("=").append(v);
        }
        sb.append(SdkConst.API_KEY);

        String signNation = sb.toString();
        LOG.error("订单签名原文:" + signNation);
        String signType = request.getParameter(OrderConst.SIGN_TYPE);
        if (OrderConst.SIGN_TYPE_MD5.equals(signType)) {
            return MD5.md5Digest(signNation);
        } else {
            return null;
        }
    }


    @Override
    public String payBack(WebRequest request, String content1, HttpServletResponse response) {
        JSONObject contentJson;
        String ver;
        try {
            contentJson = JSONObject.fromObject(content1);
            ver = contentJson.getString(PayBackConst.VER);
            if (ver == null) {
                return super.payBack(request, content1, response);
            }
        } catch (Exception e) {
            return super.payBack(request, content1, response);
        }
        LOG.error("pay wdjnew");
        LOG.error("[接收到的参数]" + content1);
        try {

            String data = contentJson.getString(PayBackConst.DATA);
            String sign = contentJson.getString(PayBackConst.SIGN);

            JSONObject dataJson = JSONObject.fromObject(data);
            StringBuffer sb = new StringBuffer();

            for (int i = 0; i < PayBackConst.SIGN_PARAM.length; i++) {
                sb.append(PayBackConst.SIGN_PARAM[i]).append("=").append(dataJson.get(PayBackConst.SIGN_PARAM[i]));
            }
            sb.append(SdkConst.API_KEY);

            String signstr = sb.toString();
            LOG.error("[参数原文]" + signstr);

            // 调用MD5进行签名
            String checkSign = MD5.md5Digest(signstr);
            LOG.error("[生成签名]" + checkSign);
            LOG.error("[签名原文]:" + sign);
            if (!checkSign.equalsIgnoreCase(sign)) {
                LOG.error("wandoujianew 签名不一致！！ " + checkSign + "|" + sign);
                return "FAILURE";
            }

            String uid;
            int serverId;
            Long lordId;
            String orderId;
            String serialId;
            String amount;
            {
                String callBackInfoStr = dataJson.getString(PayBackConst.CALLBACK_INFO);
                String[] callBackInfo = callBackInfoStr.split("_");
                serverId = Integer.valueOf(callBackInfo[0]);
                lordId = Long.valueOf(callBackInfo[1]);
                uid = callBackInfo[2];
                orderId = dataJson.getString(PayBackConst.ORDER_ID);
                serialId = callBackInfoStr;
                amount = dataJson.getString(PayBackConst.AMOUNT);
            }
            PayInfo payInfo = new PayInfo();
            payInfo.platNo = getPlatNo();
            payInfo.platId = uid;// 渠道玩家号为玩家用户名
            payInfo.orderId = orderId;

            payInfo.serialId = serialId;
            payInfo.serverId = serverId;
            payInfo.roleId = lordId;
            payInfo.amount = Float.valueOf(amount).intValue();
            int code = payToGameServer(payInfo);
            if (code == 0) {
                LOG.error("发货成功");
                return "SUCCESS";
            } else {
                LOG.error("发货失败");
                return "FAILURE";
            }
        } catch (Exception e) {
            e.printStackTrace();
            LOG.error("支付异常");
            return "FAILURE";
        }
    }

    public static void main(String[] args) {
//LOG.error(MD5.md5Digest("af33670758034"));

    }

    private JSONObject verifyAccount(String sid) {
        LOG.error("wdjnew 开始调用sidInfo接口");

        JSONObject param = new JSONObject();

        param.put(LoginRqConst.ID, System.currentTimeMillis());
        {
            JSONObject data = new JSONObject();
            data.put(LoginRqConst.SID, sid);
            param.put(LoginRqConst.DATA, data);
        }
        {
            JSONObject game = new JSONObject();
            game.put(LoginRqConst.GAME_ID, SdkConst.GAME_ID);
            param.put(LoginRqConst.GAME, game);
        }
        String sign = "sid=" + sid + SdkConst.API_KEY;
        String checkSign = MD5.md5Digest(sign);
        LOG.error("[生成签名]" + checkSign);
        LOG.error("[签名原文]:" + sign);
        param.put(LoginRqConst.SIGN, checkSign);

        String paramStr = param.toString();
        LOG.error("[请求参数]" + paramStr);
        LOG.error("[请求地址]" + SdkConst.SERVER_URL);
        String result = HttpUtils.sendJsonPost(SdkConst.SERVER_URL, paramStr);

        LOG.error("[响应结果]" + result);// 结果也是一个json格式字符串
        if (result == null || result.equals("")) {
            return null;
        }
        return JSONObject.fromObject(result);
    }

    /**
     * 向SDK写入日志
     */
    private void doLogRole(RoleLog role) {
        LOG.error("[wdjnew]: 向sdk写入日志");
        LOG.error("[roleLog]: " + role.toString());
        try {
            JSONObject log = new JSONObject();
            log.put("id", System.currentTimeMillis());
            log.put("service", "ucid.game.gameData");
            StringBuffer signSb = new StringBuffer();
            {// data
                JSONObject data = new JSONObject();

                data.put("accountId", role.getAccountKey());
                signSb.append("accountId=").append(role.getAccountKey());
                {// gameData
                    JSONObject gameData = new JSONObject();
                    gameData.put("category", "loginGameRole");
                    {// content
                        JSONObject content = new JSONObject();
                        content.put("zoneId", role.getServerId());
                        content.put("zoneName", role.getServerName());
                        content.put("roleId", role.getRoleId());
                        content.put("roleName", role.getRoleName());
                        content.put("roleCTime", role.getCreateTime() / 1000);
                        content.put("roleLevel", role.getLevel());
                        gameData.put("content", content);

                    }
                    String gameDataStr = URLEncoder.encode(gameData.toString(), SdkConst.CHARSET);
                    data.put("gameData", gameDataStr);
                    signSb.append("gameData=").append(gameDataStr);
                }
                log.put("data", data);
            }
            {// game
                JSONObject game = new JSONObject();
                game.put("gameId", SdkConst.GAME_ID);
                log.put("game", game);
            }
            signSb.append(SdkConst.API_KEY);

            String sign = signSb.toString();
            String checkSign = MD5.md5Digest(sign);
            LOG.error("[生成签名]" + checkSign);
            LOG.error("[签名原文]:" + sign);
            log.put("sign", checkSign);

            String paramStr = log.toString();
            LOG.error("[请求参数]" + paramStr);
            LOG.error("[请求地址]" + SdkConst.ROLELOG_URL);
            String result = HttpUtils.sendJsonPost(SdkConst.ROLELOG_URL, paramStr);

            LOG.error("[响应结果]" + result);// 结果也是一个json格式字符串
            if (result == null || result.equals("")) {
                LOG.error("[ wdjnew 写入日志失败]" + result);
            }
            JSONObject resultObject = JSONObject.fromObject(result);
            String stateCode = resultObject.getJSONObject(RsConst.STATE).get(RsConst.STATE_CODE).toString();
            switch (stateCode) {
                case RsConst.STATE_SUCCESS:
                    LOG.error("[wdjnew 写入日志成功]:");
                    break;
                case RsConst.STATE_PARAM_ERROR:
                    LOG.error("[wdjnew 写入日志失败]: 参数错误");
                    break;
                case RsConst.STATE_NO_LOGIN:
                    LOG.error("[wdjnew 写入日志失败]: 用户未登录");
                    break;
                default:
                    LOG.error("[wdjnew 写入日志失败]: sdk接口异常");
                    break;
            }
        } catch (UnsupportedEncodingException e) {
            LOG.error("[wdjnew 写入日志出错]:" + e.getMessage());
            e.printStackTrace();
        }
    }

    @Override
    public void logRoleCreate2sdk(RoleLog role) {
        doLogRole(role);
    }

    @Override
    public void logRoleLogin2sdk(RoleLog role) {
        doLogRole(role);
    }

    @Override
    public void logRoleUp2sdk(RoleLog role) {
        doLogRole(role);
    }

}
