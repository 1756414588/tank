/**   
 * @Title: StaffingService.java    
 * @Package com.game.service    
 * @Description:   
 * @author ZhangJun   
 * @date 2016年3月11日 下午3:15:20    
 * @version V1.0   
 */
package com.game.service;

import com.game.domain.Player;
import com.game.manager.GlobalDataManager;
import com.game.manager.PlayerDataManager;
import com.game.manager.RankDataManager;
import com.game.manager.StaffingDataManager;
import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb3.GetStaffingRs;
import com.game.util.TimeHelper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Iterator;

/**
 * @ClassName: StaffingService
 * @Description: 编制相关
 * @author ZhangJun
 * @date 2016年3月11日 下午3:15:20
 * 
 */
@Service
public class StaffingService {

	@Autowired
	private PlayerDataManager playerDataManager;

	@Autowired
	private RankDataManager rankDataManager;

	@Autowired
	private StaffingDataManager staffingDataManager;
	
	@Autowired
	private GlobalDataManager globalDataManager;

	/**
	 * 
	* 获得玩家编制信息
	* @param handler  
	* void
	 */
	public void getStaffing(ClientHandler handler) {
		if (!TimeHelper.isStaffingOpen()) {
			// 屏蔽掉返回错误码
//			handler.sendErrorMsgToPlayer(GameError.STAFFING_NOT_OPEN);
			return;
		}

		int ranking = rankDataManager.getPlayerRank(9, handler.getRoleId());

		// Player player = playerDataManager.getPlayer(handler.getRoleId());

		GetStaffingRs.Builder builder = GetStaffingRs.newBuilder();
		builder.setRanking(ranking);
		builder.setWorldLv(staffingDataManager.getWorldLv());
		handler.sendMsgToPlayer(GetStaffingRs.ext, builder.build());
	}   
	
	/**
	 * 
	*   获得世界编制等级
	* void
	 */
	public void recalcWorldLv() {
		staffingDataManager.reCalcWorldLv();
	}
	
	/**
	 *  由定时器调用  开服30天后编制功能时调用一次 会先判断有没调过此方法 然后给每个玩家增加开启编制功能之前的预存编制经验
	*   
	* void
	 */
	public void checkSaveExpAdd() {
		if (!globalDataManager.isSaveStaffingAdd){
			return;
		}
		Iterator<Player> iterator = playerDataManager.getPlayers().values()
				.iterator();
		while (iterator.hasNext()) {
			Player player = iterator.next();
			int add = player.lord.getStaffingSaveExp();
			if (add != 0) {
				playerDataManager.addStaffingExp(player, add);
				player.lord.setStaffingSaveExp(0);
			}
		}
		globalDataManager.isSaveStaffingAdd = false;
	}
	
}
