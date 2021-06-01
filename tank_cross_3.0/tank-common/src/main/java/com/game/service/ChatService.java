package com.game.service;

import com.game.domain.p.chat.domain.Chat;
import com.game.domain.p.chat.domain.SystemChat;
import com.game.manager.ChatDataManager;
import com.game.pb.BasePb;
import com.game.pb.CommonPb;
import com.game.pb.CrossGamePb;
import com.game.server.GameContext;
import com.game.server.config.gameServer.Server;
import com.game.util.PbHelper;
import com.game.util.TimeHelper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class ChatService {

    @Autowired
    private ChatDataManager chatDataManager;


    public Chat createSysChat(int sysId, String... param) {
        SystemChat systemChat = new SystemChat();
        systemChat.setSysId(sysId);
        systemChat.setTime(TimeHelper.getCurrentSecond());
        systemChat.setParam(param);
        return systemChat;
    }

    /**
     * 给所有game服发消息
     *
     * @param chat
     */
    public void sendAllGameChat(Chat chat) {
        CommonPb.Chat b = chatDataManager.addWorldChat(chat);
        CrossGamePb.CCSynChatRq.Builder builder = CrossGamePb.CCSynChatRq.newBuilder();
        builder.setChat(b);

        BasePb.Base.Builder msg = PbHelper.createSynBase(CrossGamePb.CCSynChatRq.EXT_FIELD_NUMBER, CrossGamePb.CCSynChatRq.ext, builder.build());

        for (Server server : GameContext.gameServerMaps.values()) {
            if (server.isConect()) {
                GameContext.synMsgToPlayer(server.ctx, msg);
            }
        }
    }
}


