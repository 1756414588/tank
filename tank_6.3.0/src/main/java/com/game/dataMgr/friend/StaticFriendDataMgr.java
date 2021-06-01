package com.game.dataMgr.friend;

import com.game.dao.impl.s.StaticDataDao;
import com.game.dataMgr.BaseDataMgr;
import com.game.domain.s.friend.StaticFriend;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.HashMap;
import java.util.Map;

@Component
public class StaticFriendDataMgr extends BaseDataMgr {

    @Autowired
    private StaticDataDao staticDataDao;

    private Map<Integer, StaticFriend> friendAddMap = new HashMap<>();

    @Override
    public void init() {
        friendAddMap.clear();
        Map<Integer, StaticFriend> staticFriendMap = staticDataDao.selectFriendMap();
        this.friendAddMap = staticFriendMap;
    }

    public Map<Integer, StaticFriend> getFriendAddMap() {
        return friendAddMap;
    }
}
