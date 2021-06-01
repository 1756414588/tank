package com.account.util;

import com.account.common.ServerConfig;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.Resource;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;

/**
 * @author Tandonghai
 * @date 2017-12-26 11:57
 */
public class ServerListHelper {
    protected static Logger LOG = LoggerFactory.getLogger(ServerListHelper.class);

    private ServerListHelper() {
    }

    private static ServerConfig serverConfig;

    public static ServerConfig getServerConfig() {
        return serverConfig;
    }

    public static void setServerConfig(ServerConfig serverConfig) {
        ServerListHelper.serverConfig = serverConfig;
    }

    /**
     * 读取serverlist信息
     *
     * @return
     */
    public static String readServerListJson() {
        try {
            String url = serverConfig.getServerListUrl();
            LOG.error("server list 开始从http url [ {} ] 读取 url", url);
            if (url != null) {
                String json = requestServerListJson(url);
                if (!CheckNull.isNullTrim(json)) {
                    return json;
                }
            }
            String filePath = serverConfig.getServerListFile();
            LOG.error("server list 从http url [ {} ] 获取失败,开始从本地文件读取 filePath [ {} ]", url, filePath);
            return readTxtFile(filePath);
        } catch (Exception e) {
            LOG.error("", e);
        }
        return null;
    }

    /**
     * 远程获取server list
     *
     * @param url
     * @return
     */
    public static String requestServerListJson(String url) {
        try {

            try {
                String doPost = HttpHelper.doPost(url, "");
                if (doPost != null) {
                    return doPost;
                }
            } catch (Exception e) {
                LOG.error("server list 远程获取 serverList 出错 1", e);
            }

            return HttpHelper.requestRemoteFileData(url, "", 5000);
        } catch (Exception e) {
            LOG.error("server list 远程获取 serverList 出错 2", e);
        }
        LOG.error("server list 从http url [ {} ]获取失败", url);
        return "";
    }

    /**
     * 从serverlist文件读取
     *
     * @param path
     * @return
     */
    public static String readTxtFile(String path) {
        Resource resource = new FileSystemResource(path);
        String content = new String();
        if (resource.isReadable()) {
            try {
                String encoding = "UTF-8";
                InputStream is = resource.getInputStream();
                InputStreamReader read = new InputStreamReader(is, encoding);
                BufferedReader bufferedReader = new BufferedReader(read);
                String lineTxt = null;
                while ((lineTxt = bufferedReader.readLine()) != null) {
                    content += lineTxt;
                }

                if (is != null) {
                    is.close();
                }
                if (bufferedReader != null) {
                    bufferedReader.close();
                }

            } catch (Exception e) {
                LOG.error("读取文件内容出错:{}", path, e);
            }

        } else {
            path = "web/serverlist.json";
            try {
                String encoding = "UTF-8";
                InputStream inputStream = ServerListHelper.class.getClassLoader().getResourceAsStream(path);

                // 考虑到汉子编码格式
                InputStreamReader read = new InputStreamReader(inputStream, encoding);
                BufferedReader bufferedReader = new BufferedReader(read);
                String lineTxt = null;
                while ((lineTxt = bufferedReader.readLine()) != null) {
                    content += lineTxt;
                }

                if (inputStream != null) {
                    inputStream.close();
                }
                if (bufferedReader != null) {
                    bufferedReader.close();
                }
            } catch (Exception e) {
                LOG.error("读取文件内容出错:{}", path, e);
            }

            LOG.info(" server config resource can not read from out directory");
        }

        return content;
    }
}
