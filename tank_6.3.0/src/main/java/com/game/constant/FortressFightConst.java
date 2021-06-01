/**   
 * @Title: FortressFightConst.java    
 * @Package com.game.constant    
 * @Description:   
 * @author WanYi  
 * @date 2016年6月4日 下午3:06:47    
 * @version V1.0   
 */
package com.game.constant;

/**
 * @ClassName: FortressFightConst
 * @Description: 要塞战
 * @author WanYi
 * @date 2016年6月4日 下午3:06:47
 * 
 */
public class FortressFightConst {
	public static int Fighter_Out = 1; // 出局
	public static int Fighter_No_Out = 0;// 未出局

	public static int Fight_UnBegin = 0;// 要塞战未开始
	public static int Fight_prepare = 1; // 要塞战准备
	public static int Fight_Begin = 2; // 要塞战开始
	public static int Fight_Cancel = 3; // 要塞战取消
	public static int Fight_End = 4;// 要塞战战斗结束
	public static int Fortress_End = 5;// 结束
	
	public static int CaiWuGuanId = 5; // 财务官

	public static int npcMaxNum = 400; // 防守方npc个数

	public static int Fail_CD = 60 * 2; // 失败CD时间
	public static int Attack_Vector_CD = 30;// 进攻方胜利CD时间
	
	public static int Record_All = 1;// 全服战况
	public static int Record_Personal = 2; //个人战况
	
	public static boolean Attack =  true;
	public static boolean Defence = false; 
	
	public static int JiFen_Rank_Party_Type = 1;// 积分军团排名
	public static int JiFen_Rank_All_Type= 2;//积分全服排名
	
	public static int ComBatStatics_Personal = 1; // 个人战绩
	public static int ComBatStatics_Party = 2;// 军团战绩
	
	public static String NPC_NAME = "要塞守卫军";
	public static String NPC_PartyName = "要塞";
	
	public static int Win_Default = 0 ;// 默认
	public static int Win_Attack = 1; // 攻击方赢
	public static int Win_Defence = 2;// 防守方赢
	
	public static int Attr_Fen = 4 ;// 分则能成
	public static int Attr_UpperHand = 5; // 增加先手值
	public static int Attr_Angle = 6; // 狂怒
	
	
	public static int Buff = 1; //职位buff
	public static int DeBuff = 2;//职位Debuff
}
