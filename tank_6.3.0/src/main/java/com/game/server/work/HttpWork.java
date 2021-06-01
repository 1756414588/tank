/**   
 * @Title: HttpWork.java    
 * @Package com.game.server.work    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年11月3日 上午11:14:10    
 * @version V1.0   
 */
package com.game.server.work;

import com.game.pb.BasePb.Base;
import com.game.server.GameServer;
import com.game.server.HttpServer;
import com.game.util.HttpUtils;
import com.game.util.LogUtil;
import com.game.util.PbHelper;

/**
 * @ClassName: HttpWork
 * @Description: 和账号服务器通信并执行的相关逻辑的指令
 * @author ZhangJun
 * @date 2015年11月3日 上午11:14:10
 * 
 */
public class HttpWork extends AbstractWork {
	private Base msg;
	private HttpServer httpServer;
	private String accountServerUrl;

	/**
	 * 
	* <p>Title: run</p> 
	* <p>Description: 执行任务</p>  
	* @see java.lang.Runnable#run()
	 */
	@Override
	public void run() {
		//Auto-generated method stub
		try {
			// GameServer.ERROR_LOGGER.error("HttpWork send to url:" +
			// httpServer.accountServerUrl);
			byte[] result = HttpUtils.sendPbByte(this.accountServerUrl, msg.toByteArray());
			if(result == null){
				LogUtil.error("发送账号服数据失败["+this.accountServerUrl + "]msg-->"+msg);
				return;
			}
			short len = PbHelper.getShort(result, 0);
			// LogUtil.info("back len:" + len);
			byte[] data = new byte[len];
			System.arraycopy(result, 2, data, 0, len);

			Base rs = Base.parseFrom(data, GameServer.registry);
			httpServer.doPublicCommand(rs);

			// GameServer.ERROR_LOGGER.error("HttpWork send to url end");
		} catch (Exception e) {
			// e.printStackTrace();
//			LogHelper.ERROR_LOGGER.error("HttpWork send to url exception", e);
			LogUtil.error("HttpWork send to url exception", e);
		}
	}

	/**
	 * 
	* Title: 
	* Description: 
	* @param httpServer 账号服实例
	* @param msg 消息内容
	 */
	public HttpWork(HttpServer httpServer, Base msg) {
		super();
		this.msg = msg;
		this.httpServer = httpServer;
		this.accountServerUrl = httpServer.accountServerUrl;
	}

	/**
	 * 
	* Title: 
	* Description: 
	* @param httpServer 账号服实例
	* @param fixServerAccount 账号服url
	* @param msg 消息内容
	 */
	public HttpWork(HttpServer httpServer, String fixServerAccount, Base msg) {
		super();
		this.msg = msg;
		this.httpServer = httpServer;
		this.accountServerUrl = fixServerAccount;
	}
}
