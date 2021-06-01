/**   
* @Title: GetMilitaryMaterialHandler.java    
* @Package com.game.message.handler.cs    
* @Description:   
* @author WanYi  
* @date 2016年5月12日 下午5:34:00    
* @version V1.0   
*/
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.MilitaryScienceService;

/**   
 * @ClassName: GetMilitaryMaterialHandler    
 * @Description: 获取军工科技材料信息
 * @author WanYi   
 * @date 2016年5月12日 下午5:34:00    
 *         
 */
public class GetMilitaryMaterialHandler extends ClientHandler {

	/** 
	 * Overriding: action    
	 * @see com.game.server.ICommand#action()    
	 */
	@Override
	public void action() {
		getService(MilitaryScienceService.class).getMilitaryMaterial(this);
	}

}
