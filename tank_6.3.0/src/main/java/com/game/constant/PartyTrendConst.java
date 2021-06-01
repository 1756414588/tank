package com.game.constant;

/**
 * 
* @ClassName: PartyTrendConst 
* @Description: 军团军情
* @author
 */
public interface PartyTrendConst {
	
	/** 我军在|%s|带领下进攻了|%s|，并取得的大捷，获取了飞艇的控制权。 */
	final int ATTACK_AIRSHIP_WIN = 24;
	
	/** 我军在|%s|带领下进攻了|%s|，但是铩羽而归,厉兵秣马择日再战。*/
	final int ATTACK_AIRSHIP_LOSE = 25;
	
	/** 我军在|%s|带领下进攻了|%s|，但事有变故,我军已经开始撤退。*/
	final int ATTACK_AIRSHIP_TEAM_CANCEL = 26;
	
	/** 我军在|%s|带领下进攻了|%s|，但飞艇已经处于安全状态,我军已经开始撤退。*/
	final int ATTACK_AIRSHIP_RETREAT = 27;
	
	/** 我军遭受来自军团:|%s|的指挥官:|%s|所率领的进攻|%s|的攻击，一番苦战后获得最终的胜利。*/
	final int DEFENCE_AIRSHIP_WIN = 28;
	
	/** 我军遭受来自军团:|%s|的指挥官:|%s|所率领的进攻|%s|的攻击，一番苦战后我军失守飞艇的控制权。*/
	final int DEFENCE_AIRSHIP_LOSE = 29;
	
	/** 指挥官|%s|振臂一呼,发起了针对|%s|的|%s|的攻击  */
	final int CREATE_ATTACK_AIRSHIP = 30;

	/** 我方飞艇|%s|受到了|%s|的|%s|的攻击  */
	final int CREATE_DEFENCE_AIRSHIP = 31;
	
	/** 我军成功夺取飞艇|%s|的控制权,但由于没有足够的指挥官来控制飞艇,改区域已经被武装分子重新控制.  */
	final int ATTACK_AIRSHIP_LOSE_BY_LEADER = 32;
}
