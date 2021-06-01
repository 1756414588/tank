package com.account.plat.impl.leqi;

import java.security.NoSuchAlgorithmException;
import java.util.Date;
import java.util.Iterator;
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
import com.game.pb.AccountPb.DoLoginRq;
import com.game.pb.AccountPb.DoLoginRs;

import net.sf.json.JSONObject;

@Component
public class LeqiPlat extends PlatBase {

    private static String AppID;
    private static String AppKey;

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/leqi/", "plat.properties");
        AppID = properties.getProperty("AppID");
        AppKey = properties.getProperty("AppKey");
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
            e.printStackTrace();
        }
        return s;
    }

    public GameError doLogin(DoLoginRq req, DoLoginRs.Builder response) {

        if (!req.hasSid() || !req.hasBaseVersion() || !req.hasVersion() || !req.hasDeviceNo()) {
            return GameError.PARAM_ERROR;
        }

        String sid = req.getSid();
        String baseVersion = req.getBaseVersion();
        String versionNo = req.getVersion();
        String deviceNo = req.getDeviceNo();

        // 乐7没有用户登录验证，直接执行登录逻辑

        Account account = accountDao.selectByPlatId(getPlatNo(), sid);
        if (account == null) {
            String token = RandomHelper.generateToken();
            account = new Account();
            account.setPlatNo(this.getPlatNo());
            account.setPlatId(sid);
            account.setAccount(getPlatNo() + "_" + sid);
            account.setPasswd(sid);
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
        LOG.error("pay leqi begin");
        LOG.error("pay leqi content:" + content);
        while (iterator.hasNext()) {
            String paramName = iterator.next();
            LOG.error(paramName + ":" + request.getParameter(paramName));
        }
        LOG.error("[参数结束]");

        LeqiResult result = new LeqiResult();
        try {
            String orderid = request.getParameter("orderid");
            String username = request.getParameter("username");
            String gameid = request.getParameter("gameid");
            String roleid = request.getParameter("roleid");
            String serverid = request.getParameter("serverid");
            String paytype = request.getParameter("paytype");
            String amount = request.getParameter("amount");
            String paytime = request.getParameter("paytime");
            String attach = request.getParameter("attach");
            String sign = request.getParameter("sign");

            StringBuilder sb = new StringBuilder();
            sb.append("orderid=").append(orderid).append("&username=").append(username).append("&gameid=")
                    .append(gameid).append("&roleid=").append(roleid).append("&serverid=").append(serverid)
                    .append("&paytype=").append(paytype).append("&amount=").append(amount).append("&paytime=")
                    .append(paytime).append("&attach=").append(attach).append("&appkey=").append(AppKey);
            LOG.error("代签名字符串:" + sb);

            String checkSign = md5(sb.toString().getBytes());
            if (!checkSign.equals(sign)) {
                LOG.error("签名验证失败, checkSign:" + checkSign);
                result.setStatus("fail");
                result.setMsg("签名验证失败");
            } else {
                String[] v = attach.split("_");

                PayInfo payInfo = new PayInfo();
                payInfo.platNo = getPlatNo();
                payInfo.platId = username;
                payInfo.orderId = orderid;
                payInfo.serialId = attach;
                payInfo.serverId = Integer.valueOf(v[0]);
                payInfo.roleId = Long.valueOf(v[1]);

                payInfo.realAmount = Double.valueOf(amount);
                payInfo.amount = (int) (payInfo.realAmount / 1);
                payInfo.amount = Float.valueOf(amount).intValue();
                int code = payToGameServer(payInfo);
                if (code != 0) {
                    LOG.error("leqi 充值发货失败！！ " + code);
                    if (code == 1) {
                        // 渠道方要求，订单号重复的情况下返回成功
                    } else if (code == 2) {
                        result.setStatus("fail");
                        result.setMsg("发货失败:无法取到游戏服地址");
                    } else if (code == 3) {
                        result.setStatus("fail");
                        result.setMsg("发货失败:游戏服发货异常");
                    }
                } else {
                    LOG.error("leqi 充值发货成功！！ " + code);
                }
            }
        } catch (Exception e) {
            LOG.error("leqi 充值异常！！:" + e.getMessage());
            e.printStackTrace();
            result.setStatus("fail");
            result.setMsg("充值逻辑发生异常");
        }
        String ret = com.alibaba.fastjson.JSONObject.toJSONString(result, true).replace("\\\\u", "\\u");
        LOG.error("pay leqi end, result:" + ret);
        return ret;
    }

    @Override
    public GameError doLogin(JSONObject param, JSONObject response) {
        // TODO Auto-generated method stub
        return null;
    }
}

class LeqiResult {
    private String status = "succ";

    private String msg = "";

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getMsg() {
        return msg;
    }

    public void setMsg(String msg) {
        this.msg = convert(msg);
    }

    @Override
    public String toString() {
        return "LeqiResult [status=" + status + ", msg=" + msg + "]";
    }

    public static String convert(String str) {
        str = (str == null ? "" : str);
        String tmp;
        StringBuffer sb = new StringBuffer(1000);
        char c;
        int i, j;
        sb.setLength(0);
        for (i = 0; i < str.length(); i++) {
            c = str.charAt(i);
            sb.append("\\u");
            j = (c >>> 8); // 取出高8位
            tmp = Integer.toHexString(j);
            if (tmp.length() == 1)
                sb.append("0");
            sb.append(tmp);
            j = (c & 0xFF); // 取出低8位
            tmp = Integer.toHexString(j);
            if (tmp.length() == 1)
                sb.append("0");
            sb.append(tmp);

        }
        return sb.toString();
    }
}
