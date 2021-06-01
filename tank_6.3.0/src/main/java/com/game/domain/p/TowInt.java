package com.game.domain.p;

public class TowInt {

    public TowInt(int key, int value) {
        this.key = key;
        this.value = value;

    }

    private int key;
    private int value;

    public int getKey() {
        return key;
    }

    public void setKey(int key) {
        this.key = key;
    }

    public int getValue() {
        return value;
    }

    public void setValue(int value) {
        this.value = value;
    }
}
