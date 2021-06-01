/**   
 * @Title: Loader.java    
 * @Package com.game.server.loader    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年7月29日 下午2:08:09    
 * @version V1.0   
 */
package com.game.server.loader;

/**
 * @ClassName: Loader
 * @Description: 加载器接口 定义一个加载本地文件的方法
 * @author ZhangJun
 * @date 2015年7月29日 下午2:08:09
 * 
 */
public interface Loader {
	Object load(String path);
}
