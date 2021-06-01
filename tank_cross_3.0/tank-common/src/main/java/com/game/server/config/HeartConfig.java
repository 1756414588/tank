/**
 * @Title: HeartConfig.java @Package com.game.server.config @Description: TODO
 * @author ZhangJun
 * @date 2015年7月30日 上午10:05:04
 * @version V1.0
 */
package com.game.server.config;

import com.game.server.loader.Formatter;
import com.thoughtworks.xstream.XStream;

/**
 * @ClassName: HeartConfig @Description: TODO
 *
 * @author ZhangJun
 * @date 2015年7月30日 上午10:05:04
 */
public class HeartConfig extends XmlConfig {
    private long hearttime; // 心跳间隔时间
    private long allowtime; // 心跳允许间隔时间
    private int success; // 成功减少次数
    private int error; // 错误增加次数
    private long closetime; // 心跳关闭时间

    public long getHearttime() {
        return hearttime;
    }

    public void setHearttime(long hearttime) {
        this.hearttime = hearttime;
    }

    public long getAllowtime() {
        return allowtime;
    }

    public void setAllowtime(long allowtime) {
        this.allowtime = allowtime;
    }

    public int getSuccess() {
        return success;
    }

    public void setSuccess(int success) {
        this.success = success;
    }

    public int getError() {
        return error;
    }

    public void setError(int error) {
        this.error = error;
    }

    public long getClosetime() {
        return closetime;
    }

    public void setClosetime(long closetime) {
        this.closetime = closetime;
    }

    /**
     * Overriding: format
     *
     * @param xs
     * @see Formatter#format(XStream)
     */
    @Override
    public void format(XStream xs) {
        xs.alias("com/game/config", HeartConfig.class);
    }
}
