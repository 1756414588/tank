/**   
 * @Title: BaseConfig.java    
 * @Package com.game.server.config    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年7月29日 下午2:39:22    
 * @version V1.0   
 */
package com.game.server.config;

import com.game.server.loader.Formatter;
import com.game.server.loader.Loader;
import com.game.server.loader.XmlLoader;

/**
 * @ClassName: BaseConfig
 * @Description: 配置类的基类 现在用不到了
 * @author ZhangJun
 * @date 2015年7月29日 下午2:39:22
 * 
 */
abstract public class XmlConfig implements Loader, Formatter {
	public Object load(String path) {
		XmlLoader xl = new XmlLoader(this);
		return xl.load(path);
	}
}
