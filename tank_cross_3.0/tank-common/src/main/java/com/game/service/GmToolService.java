package com.game.service;

import com.game.message.handler.DealType;
import com.game.server.GameContext;
import com.game.server.ICommand;
import com.game.util.LogUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

/**
 * @author ChenKui
 */
@Service
public class GmToolService {
    @Autowired
    private LoadService loadService;

    /**
     * 重新加载配置
     *
     * @param type void
     */
    public void reloadParam(final int type) {
        GameContext.getMainLogicServer().addCommand(new ICommand() {
                                                        @Override
                                                        public void action() {
                                                            reloadParamLogic(type);
                                                        }
                                                    },
                DealType.MAIN);
    }

    /**
     * 重新加载配置
     *
     * @param type
     * @return boolean
     */
    public boolean reloadParamLogic(int type) {
        try {
            if (type == 1) {
                loadService.loadSystem();
            } else if (type == 2) {
                loadService.reloadAll();
            }
        } catch (Exception e) {
            LogUtil.error("热加载配置数据数据出错", e);
            return false;
        }
        return true;
    }


}
