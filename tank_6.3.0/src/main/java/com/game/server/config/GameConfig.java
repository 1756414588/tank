/**   
 * @Title: GameConfig.java    
 * @Package com.game.server.config    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年7月29日 下午1:55:53    
 * @version V1.0   
 */
package com.game.server.config;

import com.thoughtworks.xstream.XStream;

import java.util.Date;

/**
 * @ClassName: GameConfig
 * @Description:  游戏配置对象 现在没用到了
 * @author ZhangJun
 * @date 2015年7月29日 下午1:55:53
 * 
 */
public class GameConfig extends XmlConfig {
	private int serverId;
	private String serverName;
	private Date createTime;
	private int port;
	private int httpPort;
	private String publicHost;
	private int publicPort;
	

	public int getServerId() {
		return serverId;
	}

	public void setServerId(int serverId) {
		this.serverId = serverId;
	}

	public String getServerName() {
		return serverName;
	}

	public void setServerName(String serverName) {
		this.serverName = serverName;
	}

	public Date getCreateTime() {
		return createTime;
	}

	public void setCreateTime(Date createTime) {
		this.createTime = createTime;
	}

	public int getPort() {
		return port;
	}

	public void setPort(int port) {
		this.port = port;
	}

	public String getPublicHost() {
		return publicHost;
	}

	public void setPublicHost(String publicHost) {
		this.publicHost = publicHost;
	}

	public int getPublicPort() {
		return publicPort;
	}

	public void setPublicPort(int publicPort) {
		this.publicPort = publicPort;
	}

	/**
	 * Overriding: format
	 * 
	 * @param xs
	 * @see com.game.server.loader.Formatter#format(com.thoughtworks.xstream.XStream)
	 */
	@Override
	public void format(XStream xs) {
		//Auto-generated method stub
		xs.alias("config", GameConfig.class);
	}

	public int getHttpPort() {
		return httpPort;
	}

	public void setHttpPort(int httpPort) {
		this.httpPort = httpPort;
	}

}
