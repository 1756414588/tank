package com.account.plat.impl.chQzJdtk_appstore;

import com.account.constant.GameError;
import com.account.domain.Account;
import com.account.plat.PayInfo;
import com.account.plat.PlatBase;
import com.account.plat.impl.self.util.MD5;
import com.account.util.Http;
import com.account.util.RandomHelper;
import com.game.pb.AccountPb.DoLoginRq;
import com.game.pb.AccountPb.DoLoginRs;
import net.sf.json.JSONObject;
import org.springframework.stereotype.Component;
import org.springframework.web.context.request.WebRequest;

import javax.annotation.PostConstruct;
import javax.servlet.http.HttpServletResponse;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.util.Date;
import java.util.Properties;

@Component
public class ChQzJdtkAppstorePlat extends PlatBase {

    private static String AppID;

    private static String AppKey;

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/chQzJdtk_appstore/", "plat.properties");
        AppID = properties.getProperty("app_id");
        AppKey = properties.getProperty("app_key");
    }

    @Override
    public GameError doLogin(JSONObject param, JSONObject response) {
        return GameError.OK; // GameError.INVALID_PARAM

    }

    @Override
    public GameError doLogin(DoLoginRq req, DoLoginRs.Builder response) {

        if (!req.hasSid() || !req.hasBaseVersion() || !req.hasVersion() || !req.hasDeviceNo()) {
            LOG.error("GameError.PARAM_ERROR");
            return GameError.PARAM_ERROR;
        }

        String sid = req.getSid();
        String baseVersion = req.getBaseVersion();
        String versionNo = req.getVersion();
        String deviceNo = req.getDeviceNo();


        String[] vParam = sid.split("_");
        String uin = vParam[0];
        String user_token = vParam[1];

        if (!verifyAccount(uin, user_token)) {
            return GameError.SDK_LOGIN;
        }

        Account account = accountDao.selectByPlatId(getPlatNo(), uin);

        if (account == null) {
            String token = RandomHelper.generateToken();
            account = new Account();

            account.setPlatNo(this.getPlatNo());
            account.setChildNo(super.getPlatNo());
            account.setPlatId(uin);
            account.setAccount(getPlatNo() + "_" + uin);
            account.setPasswd(uin);
            account.setBaseVersion(baseVersion);
            account.setVersionNo(versionNo);
            account.setToken(token);
            account.setDeviceNo(deviceNo);
            Date now = new Date();
            account.setLoginDate(now);
            account.setCreateDate(now);
            account.setChildNo(this.getPlatNo());
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
            LOG.error("authorityRs:" + authorityRs);
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


    private boolean verifyAccount(String mem_id, String user_token) {

        String str = "app_id=" + AppID + "&mem_id=" + mem_id + "&user_token=" + user_token + "&app_key=" + AppKey;

        LOG.error("chQzJdtk_appstore str " + str);

        String md5Str = MD5.md5Digest(str);

        String param = "app_id=" + AppID + "&mem_id=" + mem_id + "&user_token=" + user_token + "&sign=" + md5Str;
        LOG.error("chQzJdtk_appstore param " + param);

        String post = Http.post("https://sdkapi.5taogame.com/api/v7/cp/user/check", param);
        LOG.error("chQzJdtk_appstore post " + post);

        if (post == null) {
            return false;
        }

        JSONObject jsonObject = JSONObject.fromObject(post);

        if (jsonObject.containsKey("status") && jsonObject.getInt("status") == 1) {
            return true;
        }

        return false;
    }


    final String[] PAY_BACK_PARAM = {"app_id", "cp_order_id", "mem_id", "order_id", "order_status", "pay_time", "product_id", "product_name", "product_price"};


    @Override
    public String payBack(WebRequest request, String content, HttpServletResponse response) {
        LOG.error("chQzJdtk_appstore payBack 开始 " + content);
        try {


            String order_status = request.getParameter("order_status");

            if (!order_status.equals("2")) {
                return "FAILURE";
            }


            StringBuilder sb = new StringBuilder();
            for (String param : PAY_BACK_PARAM) {
                sb.append(param);
                sb.append("=");

                if (param.equals("product_name")) {
                    sb.append(URLEncoder.encode(request.getParameter(param), "utf-8"));
                } else {
                    sb.append(request.getParameter(param));
                }
                sb.append("&");
            }

            sb.append("app_key=");
            sb.append(AppKey);

            // 调用MD5进行签名
            String checkSign = MD5.md5Digest(sb.toString());

            String sign = URLDecoder.decode(request.getParameter("sign"), "UTF-8");

            LOG.error("chQzJdtk_appstore payBack signstr:" + sb.toString());
            LOG.error("chQzJdtk_appstore payBack sign:" + sign);
            if (!sign.equalsIgnoreCase(checkSign)) {
                LOG.error("chQzJdtk_appstore payBack sign:md5验证失败");
                return "FAILURE";
            }
            String orderid = request.getParameter("order_id");
            String cp_order_id = request.getParameter("cp_order_id");
            String product_price = request.getParameter("product_price");

            PayInfo payInfo = new PayInfo();
            // 游戏内部渠道号
            payInfo.platNo = getPlatNo();
            payInfo.childNo = super.getPlatNo();
            // 渠道订单号
            payInfo.orderId = orderid;
            // 付费金额
            payInfo.amount = Float.valueOf(product_price).intValue();

            String[] param = cp_order_id.split("_");
            String serverid = param[0];
            String roleid = param[1];

            // 游戏内部订单号
            payInfo.serialId = cp_order_id;
            // 渠道id
            payInfo.platId = getPlatNo() + "";
            // 游戏区号
            payInfo.serverId = Integer.valueOf(serverid);
            // 玩家角色id
            payInfo.roleId = Long.valueOf(roleid);


            int code = payToGameServer(payInfo);

            if (code == 0 || code == 1) {
                LOG.error("chQzJdtk_appstore 充值发货成功！！ " + code);
                return "SUCCESS";
            }
            LOG.error("chQzJdtk_appstore 充值发货失败！！ " + code);
            return "FAILURE";


        } catch (Exception e) {
            LOG.error("chQzJdtk_appstore 充值异常！！ " + e.getMessage());
            e.printStackTrace();
            return "FAILURE";
        }
    }


    public static void main(String[] strings) {

        //LOG.error(MD5.md5Digest("app_id=6001&cp_order_id=20_56100200000001_20180519102240&mem_id=8&order_id=15266965676685800080001&order_status=2&pay_time=1526696567&product_id=com.jdtk2018.06&product_name=%E9%87%91%E5%B8%81&product_price=6.00&app_key=bd683522418ac5c0c0a66471a252dbd8"));

        //LOG.error("f4117f761d36b70e3c3818e499679b78");

    }


}
