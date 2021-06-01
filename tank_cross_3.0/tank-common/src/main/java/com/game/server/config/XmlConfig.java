/**
 * @Title: BaseConfig.java @Package com.game.server.config @Description: TODO
 * @author ZhangJun
 * @date 2015年7月29日 下午2:39:22
 * @version V1.0
 */
package com.game.server.config;

import com.game.server.loader.Formatter;
import com.game.server.loader.Loader;
import com.game.server.loader.XmlLoader;

/**
 * @ClassName: BaseConfig @Description: TODO
 *
 * @author ZhangJun
 * @date 2015年7月29日 下午2:39:22
 */
public abstract class XmlConfig implements Loader, Formatter {
    public Object load(String path) {
        XmlLoader xl = new XmlLoader(this);
        return xl.load(path);
    }
}
