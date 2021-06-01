package com.account.plat.impl.chdgzhgAppstore;

import java.security.NoSuchAlgorithmException;
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

//class UcAccount {
//	public int ucid;
//	public String nickName;
//}

@Component
public class ChdgzhgAppstorePlat extends PlatBase {
    // sdk server的接口地址
    private static String VERIRY_URL_SANBOX = "";
    private static String VERIRY_URL = "";
    private static String AppId;
    private static String AppSecret;

    private static Map<Integer, String> RECHARGE_MAP = new HashMap<Integer, String>();
    private static Map<Integer, Integer> MONEY_MAP = new HashMap<Integer, Integer>();

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/chdgzhgAppstore/", "plat.properties");
        VERIRY_URL = properties.getProperty("VERIRY_URL");
        VERIRY_URL_SANBOX = properties.getProperty("VERIRY_URL_SANBOX");
        AppId = properties.getProperty("AppId");
        AppSecret = properties.getProperty("AppSecret");
        initRechargeMap();
    }

    private void initRechargeMap() {
        RECHARGE_MAP.put(1, "com.empirezhg.gz_1");
        MONEY_MAP.put(1, 6);

        RECHARGE_MAP.put(2, "com.empirezhg.gz_2");
        MONEY_MAP.put(2, 30);

        RECHARGE_MAP.put(3, "com.empirezhg.gz_3");
        MONEY_MAP.put(3, 98);

        RECHARGE_MAP.put(4, "com.empirezhg.gz_4");
        MONEY_MAP.put(4, 198);

        RECHARGE_MAP.put(5, "com.empirezhg.gz_5");
        MONEY_MAP.put(5, 328);

        RECHARGE_MAP.put(6, "com.empirezhg.gz_6");
        MONEY_MAP.put(6, 648);
    }

    @Override
    public GameError doLogin(JSONObject param, JSONObject response) {
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
        // String userName = vParam[1];
        // String token = vParam[2];

        if (!verifyAccount(vParam)) {
            return GameError.SDK_LOGIN;
        }

        Account account = accountDao.selectByPlatId(getPlatNo(), userId);
        if (account == null) {
            String token = RandomHelper.generateToken();
            account = new Account();
            account.setPlatNo(this.getPlatNo());
            account.setPlatId(userId);
            account.setAccount(getPlatNo() + "_" + userId);
            account.setPasswd(userId);
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

    @Override
    public String payBack(WebRequest request, String content, HttpServletResponse response) {
        Iterator<String> iterator = request.getParameterNames();
        LOG.error("pay chdgzhg_appstore");
        LOG.error("pay chdgzhg_appstore content:" + content);
        String paytype = request.getParameter("paytype");
        LOG.error("paytype:" + paytype);
        // paytype = 1 表明是苹果官方支付，支付验证直接使用ch_appstore 原来的代码
        // paytype = 2 表明是草花第三方支付
        if (null != paytype && "2".equals(paytype.trim())) {
            chPayBack(request, content, response);
            return "1|" + (System.currentTimeMillis() / 1000);
        }

        while (iterator.hasNext()) {
            String paramName = iterator.next();
            LOG.error(paramName + ":" + request.getParameter(paramName));
        }

        try {

            String data = request.getParameter("data");
            String extInfo = request.getParameter("extInfo");
            // String orderId = request.getParameter("orderId");

            JSONObject params = new JSONObject();
            params.put("receipt-data", data);
            String body = params.toString();
            LOG.error("[请求参数]" + body);

            String result = HttpUtils.sentPost(VERIRY_URL, body);
            LOG.error("[appstore 返回]" + result);
            JSONObject rsp = JSONObject.fromObject(result);
            int status = rsp.getInt("status");
            if (status != 0) {
                LOG.error("form status error");
                result = HttpUtils.sentPost(VERIRY_URL_SANBOX, body);
                JSONObject rsp1 = JSONObject.fromObject(result);
                if (rsp1.getInt("status") != 0) {
                    return "FAILURE";
                }
                rsp = rsp1;
            }

            JSONObject receipt = rsp.getJSONObject("receipt");
            // String item_id = receipt.getString("item_id");
            String product_id = receipt.getString("product_id");
            String transaction_id = receipt.getString("transaction_id");

            // serverId_roleId_timeStamp_platId_rechargeId
            String[] v = extInfo.split("_");

            int rechargeId = Integer.valueOf(v[4]);

            PayInfo payInfo = new PayInfo();
            payInfo.platNo = getPlatNo();
            payInfo.platId = v[3];
            payInfo.orderId = transaction_id;
            payInfo.serialId = v[0] + "_" + v[1] + "_" + v[2];
            payInfo.serverId = Integer.valueOf(v[0]);
            payInfo.roleId = Long.valueOf(v[1]);

            if (!product_id.equals(RECHARGE_MAP.get(rechargeId))) {
                LOG.error("rechargeId abnormal!!!");
                return "FAILURE";
            }

            int money = MONEY_MAP.get(rechargeId);
            payInfo.realAmount = Double.valueOf(money);
            payInfo.amount = (int) (payInfo.realAmount / 1);
            int code = payToGameServer(payInfo);
            if (code != 0) {
                LOG.error("chdgzhg_appstore 充值发货失败！！ " + code);
                return "0|" + (System.currentTimeMillis() / 1000);
            }

            return "1|" + (System.currentTimeMillis() / 1000);
        } catch (Exception e) {
            LOG.error("chdgzhg_appstore 充值异常！！ :" + e.getMessage());
            e.printStackTrace();
            return "0|" + (System.currentTimeMillis() / 1000);
        }
    }

    /**
     * 该方法不需要返回参数
     *
     * @param request
     * @param content
     * @param response
     * @return
     */
    private void chPayBack(WebRequest request, String content, HttpServletResponse response) {
        LOG.error("草花第三方支付逻辑");
        Iterator<String> iterator = request.getParameterNames();
        while (iterator.hasNext()) {
            String paramName = iterator.next();
            LOG.error(paramName + ":" + request.getParameter(paramName));
        }

        try {

            String orderId = request.getParameter("orderId");
            String amount = request.getParameter("amount");
            String type = request.getParameter("type");
            String status = request.getParameter("status");
            String trade_no = request.getParameter("trade_no");
            String sign = request.getParameter("sign");

            StringBuilder sb = new StringBuilder();
            sb.append("orderId=").append(orderId).append("&amount=").append(amount).append("&type=").append(type)
                    .append("&status=").append(status).append("&trade_no=").append(trade_no).append("&appid=")
                    .append(AppId).append(AppSecret);
            LOG.error("待签名字符串:" + sb);
            String checkSign = md5(sb.toString().getBytes());

            if (!checkSign.equals(sign)) {
                LOG.error("签名验证失败, checkSign:" + checkSign);
                return;
            }

            if (!"1".equalsIgnoreCase(status)) {
                LOG.error("用户支付失败，跳过发货逻辑");
                return;
            }

            String[] v = orderId.split("_");
            PayInfo payInfo = new PayInfo();
            payInfo.platNo = getPlatNo();
            payInfo.platId = v[3];
            payInfo.orderId = trade_no;
            payInfo.serialId = v[0] + "_" + v[1] + "_" + v[2];
            payInfo.serverId = Integer.valueOf(v[0]);
            payInfo.roleId = Long.valueOf(v[1]);

            payInfo.realAmount = Double.valueOf(amount);
            payInfo.amount = (int) (payInfo.realAmount / 1);
            int code = payToGameServer(payInfo);
            if (code != 0) {
                LOG.error("chdgzhg_appstore 充值发货失败！！ " + code);
                return;
            }

            return;
        } catch (Exception e) {
            LOG.error("chdgzhg_appstore 充值异常！！ :" + e.getMessage());
            e.printStackTrace();
        }
    }

    public static String md5(byte[] source) {
        String s = null;
        char hexDigits[] = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'};// 用来将字节转换成16进制表示的字符
        try {
            java.security.MessageDigest md = java.security.MessageDigest.getInstance("MD5");
            md.update(source);
            byte tmp[] = md.digest();// MD5 的计算结果是一个 128 位的长整数，
            // 用字节表示就是 16 个字节
            char str[] = new char[16 * 2];// 每个字节用 16 进制表示的话，使用两个字符， 所以表示成 16
            // 进制需要 32 个字符
            int k = 0;// 表示转换结果中对应的字符位置
            for (int i = 0; i < 16; i++) {// 从第一个字节开始，对 MD5 的每一个字节// 转换成 16
                // 进制字符的转换
                byte byte0 = tmp[i];// 取第 i 个字节
                str[k++] = hexDigits[byte0 >>> 4 & 0xf];// 取字节中高 4 位的数字转换,// >>>
                // 为逻辑右移，将符号位一起右移
                str[k++] = hexDigits[byte0 & 0xf];// 取字节中低 4 位的数字转换

            }
            s = new String(str);// 换后的结果转换为字符串

        } catch (NoSuchAlgorithmException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        return s;
    }

    private boolean verifyAccount(String[] param) {
        LOG.error("chdgzhg_appstore 开始调用sidInfo接口");
        String signSource = param[0] + param[1];// 组装签名原文
        String sign = MD5.md5Digest(signSource).toLowerCase();
        LOG.error("[签名原文]" + signSource);
        LOG.error("[签名结果]" + sign);

        try {
            if (sign.equals(param[2])) {// 成功
                LOG.error("chdgzhg_appstore 登陆成功");
                return true;
            } else {
                LOG.error("chdgzhg_appstore 登陆失败");
                return false;
            }
        } catch (Exception e) {
            LOG.error("chdgzhg_appstore 接口返回异常:" + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            LOG.error("调用sidInfo接口结束");
        }

    }
}
