/**
 * @Title: AttrId.java @Package com.game.constant @Description: TODO
 * @author ZhangJun
 * @date 2015年8月28日 下午6:02:32
 * @version V1.0
 */
package com.game.constant;

/**
 * @ClassName: AttrId @Description: TODO
 *
 * @author ZhangJun
 * @date 2015年8月28日 下午6:02:32
 */
public interface AttrId {
    final int HP = 1;
    final int HP_F = 2;
    final int ATTACK = 3;
    final int ATTACK_F = 4;
    final int HIT = 5;
    final int DODGE = 7;
    final int CRIT = 9;
    final int CRITDEF = 11;
    final int IMPALE = 13;
    final int DEFEND = 15;
    final int INJURED_F = 18; // 减伤万分比

    final int TENACITY_F = 20; // 坚韧万分比
    final int BURST_F = 22; // 爆裂万分比
    final int CONTROL = 24; // 掌控(属性集合,暴击，抗暴，命中 实际配置中不存在23)
    final int PRODUCT = 26; // 生产改造(效率，特殊属性)
    final int ACTIVATE = 28; // 激活改造(特殊属性)

    final int CritAndCritDef_F = 32; // 暴击与抗暴万分比
    final int HitAndDodge_F = 33; // 命中与闪避万分比
    final int DEMAGE_F = 34; // 伤害（增伤）万分比
    final int ImpaAndDefend = 35; // 穿刺与防护

    final int FORTITUDE = 37; // 刚毅
    final int FRIGHTEN = 39; // 震慑

    /**
     * 载重百分比
     */
    int LOAD_CAPACITY_ALL = 1020;
}
