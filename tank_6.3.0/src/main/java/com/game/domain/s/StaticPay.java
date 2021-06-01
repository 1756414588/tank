/**   
 * @Title: StaticPay.java    
 * @Package com.game.domain.s    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年11月7日 下午2:17:29    
 * @version V1.0   
 */
package com.game.domain.s;

/**
 * @ClassName: StaticPay
 * @Description: 充值金额档位配置
 * @author ZhangJun
 * @date 2015年11月7日 下午2:17:29
 * 
 */
public class StaticPay {
	private int payId;
	private int topup;
	private int extraGold;

	public int getPayId() {
		return payId;
	}

	public void setPayId(int payId) {
		this.payId = payId;
	}

	public int getTopup() {
		return topup;
	}

	public void setTopup(int topup) {
		this.topup = topup;
	}

	public int getExtraGold() {
		return extraGold;
	}

	public void setExtraGold(int extraGold) {
		this.extraGold = extraGold;
	}

}
