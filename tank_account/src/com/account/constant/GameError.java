package com.account.constant;

public enum GameError {
    OK(200, "OK") {
    },
    PARAM_ERROR(201, "PARAM FORMAT ERROR") {
    },
    INVALID_PARAM(202, "INVALID PARAM VALUE") {
    },
    MSG_LEN(203, "MSG LENTH ERROR") {
    },
    DDOS_ERROR(204, "SEND MSG TOO FAST") {
    },
    PROTOCAL_ERROR(205, "WRONG ENCODE") {
    },
    SERVER_EXCEPTION(206, "OCCUR EXCEPTION") {
    },
    CUR_VERSION(207, "CURRENT VERSION OLD") {// 版本有更新，请退出重进
    },
    SESSION_LOST(208, "SESSION LOST") {// SESSION失效，请重新登录
    },
    TOKEN_LOST(209, "TOKEN LOST") {// token丢失，请重新登录
    },
    NO_LORD(210, "NOT FOUND LORD") {
    },
    SENSITIVE_WORD(211, "CONTAIN SENSITIVE WORD") {
    },

    EXIST_ACCOUNT(401, "ACCOUNT ALREADY EXSIT") {
    },
    PWD_ERROR(402, "PASSWORD ERROR") {
    },
    NOT_EXIST_ACCOUNT(403, "ACCOUNT NOT EXSIT") {
    },
    NOT_WHITE_NAME(1404, "NOT IN WHITE NAME") {
    },
    FORBID_ACCOUNT(405, "ACCOUNT IS FORBID") {
    },
    INVALID_TOKEN(406, "INVALID TOKEN") {
    },
    BASE_VERSION(407, "VERSION TOO OLD") {
    },
    SDK_LOGIN(408, "SDK LOGIN FAILED") {
    },
    ACTIVE_AGAIN(409, "CAN'T ACTIVE AGAIN") {
    },
    NO_ACTIVE_CODE(410, "THIS CODE NOT EXIST") {
    },
    USED_ACTIVE_CODE(411, "THIS CODE USED") {
    };

    public int getCode() {
        return code;
    }

    public void setCode(int code) {
        this.code = code;
    }

    public String getMsg() {
        return msg;
    }

    public void setMsg(String msg) {
        this.msg = msg;
    }

    private GameError(int code, String msg) {
        this.code = code;
        this.msg = msg;
    }

    private int code;
    private String msg;
}
