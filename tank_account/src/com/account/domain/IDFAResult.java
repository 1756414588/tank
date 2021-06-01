package com.account.domain;

/**
 * @author TanDonghai
 * @ClassName IDFAResult.java
 * @Description TODO
 * @date 创建时间：2016年9月29日 下午2:25:33
 */
public class IDFAResult {
    private boolean success;

    private String message;

    public boolean isSuccess() {
        return success;
    }

    public void setSuccess(boolean success) {
        this.success = success;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    @Override
    public String toString() {
        return "IDFAResult [success=" + success + ", message=" + message + "]";
    }
}
