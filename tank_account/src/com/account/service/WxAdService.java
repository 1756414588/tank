package com.account.service;

import java.net.URLEncoder;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;

import net.sf.json.JSONObject;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.context.request.WebRequest;

import com.account.dao.impl.WxAdDao;
import com.account.domain.Account;
import com.account.domain.WxAdvertise;
import com.account.plat.impl.self.util.HttpUtils;
import com.account.plat.impl.self.util.MD5;
import com.account.util.CheckNull;
import com.account.util.PrintHelper;
import com.caucho.util.Base64;

public class WxAdService {

    @Autowired
    private WxAdDao wxAdDao;

    public Logger LOG = LoggerFactory.getLogger(this.getClass());

    /**
     * 有效期 七天
     */
    private final long VALID_TIME = 5 * 24 * 60 * 60 * 1000;

    /**
     * 签名秘钥
     */
    private final String SIGN_KEY = "134262fd1a49b3d4";

    /**
     * 异或秘钥
     */
    private final String ENCRYPT_KEY = "BAAAAAAAAAAAFO6x";

    /**
     * 获取地址
     */
    private String getURL(String appId) {
        return "http://t.gdt.qq.com/conv/app/" + appId + "/conv?";
    }

    /**
     * 微信推广信息推送
     *
     * @param platNo
     * @param request
     * @return
     */
    public String wxInfo(int platNo, WebRequest request) {
        Iterator<String> iterator = request.getParameterNames();
        while (iterator.hasNext()) {
            String paramName = iterator.next();
            PrintHelper.println(paramName + ":" + request.getParameter(paramName));
        }
        String muid = request.getParameter("muid");

        if (CheckNull.isNullTrim(muid)) {
            return "MUID NULL";
        }

        String click_time = request.getParameter("click_time");
        String click_id = request.getParameter("click_id");
        String app_type = request.getParameter("app_type");
        String appid = request.getParameter("appid");
        String advertiser_id = request.getParameter("advertiser_id");

        JSONObject result = new JSONObject();
        Date now = new Date();
        muid = muid.trim();
        WxAdvertise wxAdvertise = wxAdDao.selectWxAdvertise(platNo, muid);
        if (wxAdvertise != null) {
            result.put("ret", -1);
            result.put("msg", "该设备已登记");
        } else {
            wxAdvertise = new WxAdvertise();
            wxAdvertise.setMuid(muid);
            wxAdvertise.setPlatNo(platNo);
            wxAdvertise.setClickTime(click_time);
            wxAdvertise.setClickId(click_id);
            wxAdvertise.setAppType(app_type);
            wxAdvertise.setAppid(appid);
            wxAdvertise.setAdvertiserId(advertiser_id);
            wxAdvertise.setCreateTime(now);
            wxAdDao.insertWxAdvertise(wxAdvertise);
            result.put("ret", 0);
            result.put("msg", "接收成功");
        }
        return result.toString();
    }

    /**
     * 设备激活
     *
     * @param platNo
     * @param deviceNo
     */
    public String checkWxIdfa(int platNo, String deviceNo) {
        if (CheckNull.isNullTrim(deviceNo)) {
            return "MUID NULL";
        }
        String muid = idfaMD5(platNo, deviceNo);
        WxAdvertise wxAdvertise = wxAdDao.selectWxAdvertise(platNo, muid);
        if (wxAdvertise == null) { // 广告方还未推送 不做处理
            return "NO ADVERTISE";
        }
        if (wxAdvertise.getCheckTime() != null) { // 已经处理过
            return "IS OVER";
        }
        wxAdvertise.setCheckTime(new Date());
        wxAdDao.updateWxAdvertise(wxAdvertise); // 更新处理时间

        if (wxAdvertise.getCheckTime().getTime() - wxAdvertise.getCreateTime().getTime() > VALID_TIME) { // 过期
            return "TIME OUT";
        }
        wxPost(wxAdvertise); // 向智汇推提交信息
        return "SUC";
    }

    /**
     * 创建账号判断是否是微信广告用户
     *
     * @param platNo
     * @param deviceNo
     * @return
     */
    public void checkWxIdfa(Account account) {
        try {
            String deviceNo = account.getDeviceNo();
            int platNo = account.getPlatNo();
            if (CheckNull.isNullTrim(deviceNo)) {
                return;
            }
            String muid = idfaMD5(platNo, deviceNo);
            WxAdvertise wxAdvertise = wxAdDao.selectWxAdvertise(platNo, muid);
            if (wxAdvertise == null) { // 广告方还未推送 不做处理
                return;
            }
            if (wxAdvertise.getCheckTime().getTime() - wxAdvertise.getCreateTime().getTime() > VALID_TIME) {
                return;
            }
            account.setChildNo(2); // 标记为微信广告用户
        } catch (Exception e) {
            System.err.println("检测微信广告设备异常    ：" + e);
        }
    }

    /**
     * 向微信 推送激活信息
     *
     * @param advertise
     * @return
     */
    public boolean wxPost(WxAdvertise wxAdvertise) {
        try {
            String urlInfo = getURL(wxAdvertise.getAppid());
            LOG.error("微信广告info:");
            String query_string = "click_id=" + wxAdvertise.getClickId() + "&muid=" + wxAdvertise.getMuid() + "&conv_time=" + System.currentTimeMillis() / 1000;
            LOG.error("query_string=" + query_string);
            String page = urlInfo + query_string;
            LOG.error("page=" + page);
            String encode_page = URLEncoder.encode(page, "UTF-8");
            LOG.error("encode_page=" + encode_page);
            String property = SIGN_KEY + "&GET&" + encode_page;
            LOG.error("property=" + property);
            String signature = MD5.md5Digest(property);
            LOG.error("signature=" + signature);
            String base_data = query_string + "&sign=" + URLEncoder.encode(signature, "UTF-8");
            LOG.error("base_data=" + base_data);
            String data = Base64.encode(xorWithKey(base_data, ENCRYPT_KEY));
            LOG.error("data=" + data);
            String attachment = "conv_type=MOBILEAPP_ACTIVITE&app_type=" + wxAdvertise.getAppType() + "&advertiser_id=" + wxAdvertise.getAdvertiserId();
            LOG.error("attachment=" + attachment);
            String url = urlInfo + "v=" + data + "&" + attachment;
            LOG.error("url=" + url);

            String result = HttpUtils.sendGet(url, new HashMap<String, String>());
            LOG.error("notice wxad result:" + result);
            if (result != null) {
                JSONObject rsp = JSONObject.fromObject(result);
                if (rsp.getInt("ret") == 0) {
                    return true;
                }
            }
            return false;
        } catch (Exception e) {
            e.printStackTrace();
            LOG.error("noticeAdvertise Exception, platNo:"
                    + wxAdvertise.getPlatNo() + ", MUID:" + wxAdvertise.getMuid()
                    + ", exception:" + e.getMessage());
            return false;
        }
    }

    /**
     * 微信设备号MD5
     *
     * @param platNo
     * @param deviceNo
     * @return
     */
    private String idfaMD5(int platNo, String deviceNo) {
        if (platNo == 94 || platNo == 95 || platNo >= 500) {
            //IOS 设备-muid 加密规则：IDFA 码（需转大写），进行 md5sum以后得到的 32位全小写MD5表现字符串。
            deviceNo = MD5.md5Digest(deviceNo.trim().toUpperCase()).toLowerCase();
        } else {
            //Android 设备-muid 加密规则：IMEI 号(需转小写)，进行 md5sum 以后得到的 32 位全小写 MD5 表现字符串。
            deviceNo = MD5.md5Digest(deviceNo.trim().toLowerCase()).toLowerCase();
        }
        return deviceNo;
    }

    /**
     * 字符串异或
     *
     * @param a
     * @param key
     * @return
     */
    private static byte[] xorWithKey(String txt, String key) {
        byte[] a = txt.getBytes();
        byte[] b = key.getBytes();
        byte[] out = new byte[a.length];
        for (int i = 0; i < a.length; i++) {
            out[i] = (byte) (a[i] ^ b[i % b.length]);
        }
        return out;
    }


}
