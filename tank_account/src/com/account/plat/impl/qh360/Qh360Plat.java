package com.account.plat.impl.qh360;

import com.account.constant.GameError;
import com.account.domain.Account;
import com.account.plat.PayInfo;
import com.account.plat.PlatBase;
import com.account.plat.impl.self.util.HttpUtils;
import com.account.plat.impl.self.util.MD5;
import com.account.util.RandomHelper;
import com.game.pb.AccountPb;
import net.sf.json.JSONObject;
import org.springframework.stereotype.Component;
import org.springframework.web.context.request.WebRequest;

import javax.annotation.PostConstruct;
import javax.servlet.http.HttpServletResponse;
import java.util.*;

/**
 * @author yeding
 * @create 2019/6/26 19:32
 * @decs
 */

class QihuAccount {
    public String id;
    public String name;
    public String userInfo;
}
@Component
public class Qh360Plat extends PlatBase {

    // sdk server的接口地址
    private static String serverUrl = "";

    private static String APP_KEY;
    private static String APP_SECRET;

    private QihuUtil qihuUtil;

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/qh360/", "plat.properties");
        // if (properties != null) {
        APP_KEY = properties.getProperty("APP_KEY");
        APP_SECRET = properties.getProperty("APP_SECRET");
        serverUrl = properties.getProperty("VERIRY_URL");
        // }
        setQihuUtil(new QihuUtil());
    }

    public GameError doLogin(AccountPb.DoLoginRq req, AccountPb.DoLoginRs.Builder response) {

        if (!req.hasSid() || !req.hasBaseVersion() || !req.hasVersion() || !req.hasDeviceNo()) {
            return GameError.PARAM_ERROR;
        }

        String sid = req.getSid();
        String baseVersion = req.getBaseVersion();
        String versionNo = req.getVersion();
        String deviceNo = req.getDeviceNo();

        QihuAccount qihuAccount = verifyAccount(sid);
        if (qihuAccount == null) {
            return GameError.SDK_LOGIN;
        }

        Account account = accountDao.selectByPlatId(getPlatNo(), qihuAccount.id);
        if (account == null) {
            String token = RandomHelper.generateToken();
            account = new Account();
            account.setPlatNo(this.getPlatNo());
            account.setPlatId(qihuAccount.id);
            account.setAccount(getPlatNo() + "_" + qihuAccount.id);
            account.setPasswd(qihuAccount.id);
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

        response.addAllRecent(super.getRecentServers(account));
        response.setKeyId(account.getKeyId());
        response.setToken(account.getToken());
        response.setUserInfo(qihuAccount.userInfo);

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

        QihuAccount qihuAccount = verifyAccount(sid);
        if (qihuAccount == null) {
            return GameError.SDK_LOGIN;
        }

        Account account = accountDao.selectByPlatId(getPlatNo(), qihuAccount.id);
        if (account == null) {
            String token = RandomHelper.generateToken();
            account = new Account();
            account.setPlatNo(this.getPlatNo());
            account.setPlatId(qihuAccount.id);
            account.setAccount(getPlatNo() + "_" + qihuAccount.id);
            account.setPasswd(qihuAccount.id);
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

        response.put("recent", super.getRecentServers(account));
        response.put("keyId", account.getKeyId());
        response.put("token", account.getToken());
        response.put("userInfo", qihuAccount.userInfo);
        if (isActive(account)) {
            response.put("active", 1);
        } else {
            response.put("active", 0);
        }

        return GameError.OK;
    }

    public static String getSign(HashMap<String, String> params, String appSecret) {
        Object[] keys = params.keySet().toArray();
        Arrays.sort(keys);
        String k, v;

        String str = "";
        for (int i = 0; i < keys.length; i++) {
            k = (String) keys[i];
            if (k.equals("sign") || k.equals("plat") || k.equals("sign_return")) {
                continue;
            }

            if (params.get(k) == null) {
                continue;
            }
            v = (String) params.get(k);

            if (v.equals("0") || v.equals("")) {
                continue;
            }
            str += v + "#";
        }
        //LOG.error("getSign:" + str);
        return MD5.md5Digest(str + appSecret);
    }

    @Override
    public String payBack(WebRequest request, String content, HttpServletResponse response) {
        LOG.error("pay qihu");
        // LOG.error("[接收到的参数]" + content);
        try {
            Map<String, String[]> paramterMap = request.getParameterMap();
            HashMap<String, String> params = new HashMap<String, String>();
            String k, v;
            Iterator<String> iterator = paramterMap.keySet().iterator();
            while (iterator.hasNext()) {
                k = iterator.next();
                String arr[] = paramterMap.get(k);
                v = (String) arr[0];
                params.put(k, v);
                LOG.error(k + "=" + v);
            }
            LOG.error("[参数结束]");
            String app_key = request.getParameter("app_key");
            // String product_id = request.getParameter("product_id");
            String amount = request.getParameter("amount");
            // String app_uid = request.getParameter("app_uid");
            // String app_ext1 = request.getParameter("app_ext1");
            // String app_ext2 = request.getParameter("app_ext2");
            String user_id = request.getParameter("user_id");
            String order_id = request.getParameter("order_id");
            String gateway_flag = request.getParameter("gateway_flag");
            // String sign_type = request.getParameter("sign_type");
            String app_order_id = request.getParameter("app_order_id");
            // String sign_return = request.getParameter("sign_return");
            String sign = request.getParameter("sign");

            if (!APP_KEY.equals(app_key)) {
                return "ok";
            }

            if (!"success".equals(gateway_flag)) {
                return "ok";
            }

            String orginSign = getSign(params, APP_SECRET);
            LOG.error("签名：" + orginSign + " | " + sign);

            if (orginSign.equals(sign)) {
                String[] infos = app_order_id.split("_");
                if (infos.length != 3) {
                    LOG.error("传参数错误");
                    return "ok";
                }
                int serverid = Integer.valueOf(infos[0]);
                Long lordId = Long.valueOf(infos[1]);

                PayInfo payInfo = new PayInfo();
                payInfo.platNo = getPlatNo();
                payInfo.platId = user_id;
                payInfo.orderId = order_id;

                payInfo.serialId = app_order_id;
                payInfo.serverId = serverid;
                payInfo.roleId = lordId;
                payInfo.realAmount = Double.valueOf(amount) / 100.0;
                payInfo.amount = (int) (payInfo.realAmount / 1);
                int retcode = payToGameServer(payInfo);
                if (retcode == 0) {
                    LOG.error("发货成功");
                    return "ok";
                } else {
                    LOG.error("发货失败" + retcode);
                    return "ok";
                }
            } else {
                return "ok";
            }
        } catch (Exception e) {
            e.printStackTrace();
            return "ok";
        }
    }

    private QihuAccount verifyAccount(String sid) {
        try {
            LOG.error("qihu开始调用sidInfo接口:" + serverUrl + "|" + sid);
            // https://openapi.360.cn/user/me.json?access_token=12345678983b38aabcdef387453ac8133ac3263987654321&fields=id,name,avatar,sex,area
            String body = "access_token=" + sid;
            LOG.error("[请求参数]" + body);
            String result = HttpUtils.sentPost(serverUrl, body);
            // String result = HttpHelper.doPost(serverUrl, body);
            // HashMap<String, String> parameter = new HashMap<>();
            // parameter.put("access_token", sid);
            //
            // String result = HttpUtils.sendGet(serverUrl, parameter);
            // post方式调用服务器接口,请求的body内容是参数json格式字符串
            LOG.error("[响应结果]" + result);// 结果也是一个json格式字符串

            QihuAccount qihuAccount = new QihuAccount();

            JSONObject rsp = JSONObject.fromObject(result);
            if (!rsp.containsKey("id")) {
                return null;
            }

            qihuAccount.id = rsp.getString("id");
            qihuAccount.name = rsp.getString("name");
            qihuAccount.userInfo = rsp.toString();
            LOG.error("[id]" + qihuAccount.id);
            LOG.error("[name]" + qihuAccount.name);
            LOG.error("调用sidInfo接口结束");
            return qihuAccount;
        } catch (Exception e) {
            // TODO: handle exception
            LOG.error("接口返回异常");
            e.printStackTrace();
            return null;
        }
    }

    public QihuUtil getQihuUtil() {
        return qihuUtil;
    }

    public void setQihuUtil(QihuUtil qihuUtil) {
        this.qihuUtil = qihuUtil;
    }
}
