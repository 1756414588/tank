/**   
 * @Title: Formatter.java    
 * @Package com.game.server.loader    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年7月29日 下午2:37:35    
 * @version V1.0   
 */
package com.game.server.loader;

import com.thoughtworks.xstream.XStream;

/**
 * @ClassName: Formatter
 * @Description: 格式化接口 定义一个格式化方法
 * @author ZhangJun
 * @date 2015年7月29日 下午2:37:35
 * 
 */
public interface Formatter {
	void format(XStream xs);
}
