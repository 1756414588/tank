package com.game.domain.p;

import java.util.List;

/**
 * @ClassName:NewMail
 * @author zc
 * @Description: 对应p_mail表
 * 邮件一经创建，除了状态会改变，其他数据都不会改变，因此除了state多线程间无需同步，
 * @date 2017年9月27日
 */
public class NewMail {
    private long id;
    private long lordId;
    private int keyId;
    private int type;
    private int moldId;
    private List<String> param;
    private String title;
    private String sendName;
    private List<String> toName;
    private int state;
    private String contont;
    private String award;
    private byte[] report;
    private int time;
    private int lv;
    private int vipLv;
    private int collections;

    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public long getLordId() {
        return lordId;
    }

    public void setLordId(long lordId) {
        this.lordId = lordId;
    }

    public int getKeyId() {
        return keyId;
    }

    public void setKeyId(int keyId) {
        this.keyId = keyId;
    }

    public int getType() {
        return type;
    }

    public void setType(int type) {
        this.type = type;
    }

    public int getMoldId() {
        return moldId;
    }

    public void setMoldId(int moldId) {
        this.moldId = moldId;
    }

    public List<String> getParam() {
        return param;
    }

    public void setParam(List<String> param) {
        this.param = param;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getSendName() {
        return sendName;
    }

    public void setSendName(String sendName) {
        this.sendName = sendName;
    }

    public List<String> getToName() {
        return toName;
    }

    public void setToName(List<String> toName) {
        this.toName = toName;
    }

    public int getState() {
        return state;
    }

    public void setState(int state) {
        this.state = state;
    }

    public String getContont() {
        return contont;
    }

    public void setContont(String contont) {
        this.contont = contont;
    }

    public String getAward() {
        return award;
    }

    public void setAward(String award) {
        this.award = award;
    }

    public byte[] getReport() {
        return report;
    }

    public void setReport(byte[] report) {
        this.report = report;
    }

    public int getTime() {
        return time;
    }

    public void setTime(int time) {
        this.time = time;
    }

    public int getLv() {
        return lv;
    }

    public void setLv(int lv) {
        this.lv = lv;
    }

    public int getVipLv() {
        return vipLv;
    }

    public void setVipLv(int vipLv) {
        this.vipLv = vipLv;
    }

    public int getCollections() {
        return collections;
    }

    public void setCollections(int collections) {
        this.collections = collections;
    }
}
