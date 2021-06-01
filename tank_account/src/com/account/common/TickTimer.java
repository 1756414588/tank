package com.account.common;

import java.util.Date;

public class TickTimer {
    private Date tickDate;

    static public TickTimer getInstance() {
        return new TickTimer();
    }

    private TickTimer() {
        tickDate = new Date();
    }

    public long tick() {
        Date current = new Date();
        return current.getTime() - tickDate.getTime();
    }
}
