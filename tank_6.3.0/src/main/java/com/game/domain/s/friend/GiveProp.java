package com.game.domain.s.friend;

import java.util.Objects;

/**
 * 赠送道具
 */
public class GiveProp {

    private int type;
    private int id;

    public GiveProp(int type, int id) {
        this.type = type;
        this.id = id;
    }

    public int getType() {
        return type;
    }

    public void setType(int type) {
        this.type = type;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        GiveProp giveProp = (GiveProp) o;
        return type == giveProp.type &&
                id == giveProp.id;
    }

    @Override
    public int hashCode() {
        return Objects.hash(type, id);
    }
}
