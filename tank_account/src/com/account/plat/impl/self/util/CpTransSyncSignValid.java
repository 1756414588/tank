package com.account.plat.impl.self.util;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.math.BigInteger;

/**
 * Desc:cp交易同步签名验证 date:2012/12/14
 */
public final class CpTransSyncSignValid {
    public static Logger LOG = LoggerFactory.getLogger(CpTransSyncSignValid.class);

    /**
     * desc:生成密钥
     *
     * @param transdata 需要加密的数据，如{"appid":"1","exorderno":"2"}
     * @param key       应用的密钥(商户可从商户自服务系统获取)
     * @return
     */
    public static String genSign(String transdata, String key) {
        String sign = "";
        try {
            // 获取privatekey和modkey
            String decodeBaseStr = Base64.decode(key);

            String[] decodeBaseVec = decodeBaseStr.replace('+', '#').split("#");

            String privateKey = decodeBaseVec[0];
            String modkey = decodeBaseVec[1];

            // 生成sign的规则是先md5,再rsa
            String md5Str = MD5.md5Digest(transdata);

            sign = RSAUtil.encrypt(md5Str, new BigInteger(privateKey), new BigInteger(modkey));

        } catch (Exception e) {
            e.printStackTrace();
        }
        return sign;

    }

    /**
     * @param transdata 同步过来的transdata数据
     * @param sign      同步过来的sign数据
     * @param key       应用的密钥(商户可从商户自服务系统获取)
     * @return 验证签名结果 true:验证通过 false:验证失败
     */
    public static boolean validSign(String transdata, String sign, String key) {
        try {
            String md5Str = MD5.md5Digest(transdata);

            String decodeBaseStr = Base64.decode(key);

            String[] decodeBaseVec = decodeBaseStr.replace('+', '#').split("#");

            String privateKey = decodeBaseVec[0];
            String modkey = decodeBaseVec[1];

            String reqMd5 = RSAUtil.decrypt(sign, new BigInteger(privateKey), new BigInteger(modkey));
            LOG.error("md5Str|reqMd5: " + md5Str + "|" + reqMd5);
            if (md5Str.equals(reqMd5)) {
                return true;
            } else {
                return false;
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;

    }

//	public static void main(String[] args) {
//		// String reqJson =
//		// "{\"exorderno\":\"1\",\"transid\":\"2\",\"waresid\":\"3\",\"chargepoint\":31,\"feetype\":4,\"money\":5,\"count\":6,\"result\":0,\"transtype\":0,\"transtime\":\"2012-12-12 12:11:10\",\"cpprivate\":\"7\",\"sign\":\"64a04bc23987c621264a6295b8c61191 9c9ccd91cbc584316b9d99919921a9be 89c38dfa9329001a521bf4c904bb83cd \"}";
//		// boolean b = CpTransSyncSignValid.validSign(reqJson,
//		// "MjdFN0ExMURCM0JDMDc0QTQ3OTY1NzEwNDEzODMzMjhERkFDRDA5MU1UVTRNalkyTXpNek1ESTFNREUxT1RjME16RXJNakk0TnpjeE56ZzBNVEEyTlRJME16TTNORE00TkRBM09EY3hNemcxTkRrMU1UTXhPVEl4");
//		String md5 = MD5
//				.md5Digest("{\"exorderno\":\"test00001\",\"transid\":\"00012122916363200005\",\"waresid\":\"20000100000001200001\",\"appid\":\"1\",\"feetype\":2,\"money\":1,\"count\":1,\"result\":0,\"transtype\":0,\"transtime\":\"2012-12-29 16:36:33\",\"cpprivate\":\"123456\"}");
//		String sign = null;
//		try {
//			sign = RSAUtil.encrypt(md5, new BigInteger("57771314293114350820943284589604085519"), new BigInteger("13945683305049607291"));
//		} catch (Exception e) {
//		}
//		
//		LOG.error(validSign("{\"exorderno\":\"8772240ebd4f4a65b0fb54dd3657a7f0\",\"transid\":\"04215061114573869459\",\"waresid\":1,\"appid\":\"3002458134\",\"feetype\":0,\"money\":600,\"result\":0,\"transtype\":0,\"transtime\":\"2015-06-11 14:58:27\",\"count\":      1,\"cpprivate\":\"9446,1,1,8772240ebd4f4a65b0fb54dd3657a7f0\",\"paytype\":501}",
//				"9a9ecaddb54424897479e0b35ad35670 4ea6e4eb72f0c3dddd0d0647d68aeeba ab8eaa3046acbf8656afdd766bde99a2", 
//				"REJCMUUzRkZCQTgxM0ZDMjc0QjA1MzM0RTQzN0Y2MzYyMkU3MkFCRk1UWXlNekl4TmpRd01EYzBNVFF5TlRVeU16TXJNalE1TkRVeU5qTTROell4T1RVek5qQTVORFk0TURjNE1qSTVNVGc0TXpVNE5qVXlOekE1"));
//		LOG.error(sign);
//		// 3ae5508e339425e9d0d89c1bf6755183 5777a6fb3489bc48a8902636adc2e7bc
//		// 8404d152e2a891a488145c8c85f7f4ad
//
//	}

    public static void main(String[] args) {/* 1、设置支付密钥：从商户自服务系统获取 */

        /* 2、提取支付结果通知数据 */
        // InputStream in = request.getInputStream();
        // BufferedReader reader = new BufferedReader(new InputStreamReader(in,
        // "UTF-8"));// 请注意是UTF-8编码
        String line = null;
        // StringBuilder tranData = new StringBuilder();
        // while ((line = reader.readLine()) != null) {
        // tranData.append(line);
        // }
        line = "transdata={\"exorderno\":\"8772240ebd4f4a65b0fb54dd3657a7f0\",\"transid\":\"04215061114573869459\",\"waresid\":1,\"appid\":\"3002458134\",\"feetype\":0,\"money\":600,\"result\":0,\"transtype\":0,\"transtime\":\"2015-06-11 14:58:27\",\"count\":1,\"cpprivate\":\"9446,1,1,8772240ebd4f4a65b0fb54dd3657a7f0\",\"paytype\":501}&sign=9a9ecaddb54424897479e0b35ad35670 4ea6e4eb72f0c3dddd0d0647d68aeeba ab8eaa3046acbf8656afdd766bde99a2";
        String cpkey = "REJCMUUzRkZCQTgxM0ZDMjc0QjA1MzM0RTQzN0Y2MzYyMkU3MkFCRk1UWXlNekl4TmpRd01EYzBNVFF5TlRVeU16TXJNalE1TkRVeU5qTTROell4T1RVek5qQTVORFk0TURjNE1qSTVNVGc0TXpVNE5qVXlOekE1";
//		 boolean a= line.equals(line2);
//		 boolean b= cpkey.equalsIgnoreCase(cpkey2);
//       LOG.error("比较"+a+"   "+b);
//		 LOG.error("info:支付结果通知内容[" + line + "]");//记录收到数据
        String result = "FAILURE";
        /* 3、解析支付结果通知数据成业务数据 */
        if (null == line || "".equals(line.trim())) {
            LOG.error("error:支付结果通知内容为空");
        } else {
            int index = line.indexOf('&');
            if (0 > index) {
                LOG.error("error:支付结果通知内容格式不对，请确认格式为tranddate={}&sing=。");
            } else {

                String transdata = line.substring(10, index);// 这个是实际的意思就是从transdata=之后开始截取到 “&”。
                String sign = line.substring(index + 6);// sign=
                LOG.error("info:支付结果通知内容transdata[" + transdata + "]");
                LOG.error("info:支付结果通知签名sign[" + sign + "]");
                if (transdata == null || sign == null
                        || "".equalsIgnoreCase(transdata)
                        || "".equalsIgnoreCase(sign)) {
                    LOG.error("error:支付结果通知内容格式不对，请确认格式为tranddate={}&sing=。");
                } else {
                    boolean checkFlag = CpTransSyncSignValid.validSign(transdata, sign, cpkey);
                    if (checkFlag) {
                        /* 4、业务处理 */
                        result = "SUCCESS";
                        LOG.error("info:支付结果通知内容验签成功" + transdata + "/n" + sign);
                    } else {
                        LOG.error("error:支付结果通知内容验签失败" + transdata + "/n" + sign);
                    }
                }
            }
        }
        /* 5、返回处理结果 */
        LOG.error(result);
    }
}
