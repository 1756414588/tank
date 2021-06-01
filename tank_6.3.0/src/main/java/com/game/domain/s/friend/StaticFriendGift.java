package com.game.domain.s.friend;

import java.util.List;

public class StaticFriendGift {

    private long id;

    private long friend;

    private List<Integer> prop;

    private int type;

    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public long getFriend() {
        return friend;
    }

    public void setFriend(long friend) {
        this.friend = friend;
    }

    public List<Integer> getProp() {
        return prop;
    }

    public void setProp(List<Integer> prop) {
        this.prop = prop;
    }

    public int getType() {
        return type;
    }

    public void setType(int type) {
        this.type = type;
    }
}
