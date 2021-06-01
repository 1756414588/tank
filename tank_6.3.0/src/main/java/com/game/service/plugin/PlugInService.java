package com.game.service.plugin;

import com.game.constant.GameError;
import com.game.domain.Player;
import com.game.domain.p.PlugInCheck;
import com.game.manager.PlayerDataManager;
import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

/**
 * @author zhangdh
 * @ClassName: PlugInService
 * @Description:
 * @date 2017-12-27 15:08
 */
@Service
public class PlugInService {

    @Autowired
    private PlayerDataManager playerDataManager;

    /**
     * 解除扫矿验证信息
     * @param req
     * @param handler
     */
    public void plugInScoutMineValidCodeRq(GamePb6.PlugInScoutMineValidCodeRq req, ClientHandler handler) {
        String validCode = req.getValidCode();
        if (StringUtils.isEmpty(validCode)) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        PlugInCheck plugIn = player.plugInCheck;
        String code = plugIn.getScoutMineValidCode();
        if (StringUtils.isEmpty(code) || code.equals(validCode)) {
            plugIn.setScoutMineValidCode(null);
            plugIn.getLogScoutTime().clear();
        }
        GamePb6.PlugInScoutMineValidCodeRs.Builder builder = GamePb6.PlugInScoutMineValidCodeRs.newBuilder();
        handler.sendMsgToPlayer(GamePb6.PlugInScoutMineValidCodeRs.ext, builder.build());
    }

}
