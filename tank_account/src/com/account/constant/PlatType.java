package com.account.constant;

/**
 * @author ：Liu Gui Jie
 * @date ：Created in 2019/1/24 10:32
 * @description：渠道类型
 * @version: $
 */
public enum PlatType {
    ALL(1, "所有渠道"),
    HUNFU(2, "混服"),
    YINGHE(3, "硬核"),
    LIANYUN(4, "联运"),
    OTHER(5, "其他"),
    OVERSEAS(6, "海外");

    private int platTypeId;
    private String desc;

    PlatType(int platTypeId, String desc) {
        this.platTypeId = platTypeId;
        this.desc = desc;
    }

    public int getPlatTypeId() {
        return platTypeId;
    }

    public String getDesc() {
        return desc;
    }
}
