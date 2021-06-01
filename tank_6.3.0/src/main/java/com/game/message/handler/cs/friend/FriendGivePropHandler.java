package com.game.message.handler.cs.friend;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6;
import com.game.service.FriendService;

/**
 * 好友赠送道具
 */
public class FriendGivePropHandler extends ClientHandler {

    @Override
    public void action() {
        GamePb6.FriendGivePropRq req = msg.getExtension(GamePb6.FriendGivePropRq.ext);
        getService(FriendService.class).friendGiveProp(req,this);
    }
}
