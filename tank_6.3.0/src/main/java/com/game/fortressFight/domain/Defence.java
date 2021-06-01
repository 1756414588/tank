/**   
 * @Title: Defence.java    
 * @Package com.game.fortressFight.domain    
 * @Description:   
 * @author WanYi  
 * @date 2016年6月4日 下午2:14:57    
 * @version V1.0   
 */
package com.game.fortressFight.domain;

import com.game.domain.p.Form;

/**
 * @ClassName: 要塞防守方
 * @author WanYi
 * @date 2016年6月4日 下午2:14:57
 * 
 */
public class Defence {
	protected Form form;// 初始form

	protected Form instForm; // 剩余的form

	/**
	 * @Fields state : 参战状态，0.未出局 1.已出局
	 */
	protected int state;

	public Form getForm() {
		return form;
	}

	public void setForm(Form form) {
		this.form = form;
	}

	public Form getInstForm() {
		return instForm;
	}

	public void setInstForm(Form instForm) {
		this.instForm = instForm;
	}

	public int getState() {
		return state;
	}

	public void setState(int state) {
		this.state = state;
	}
	
	public int calcHp() {
		Form baseForm = getForm();
		Form curForm = getInstForm();
		int base = baseForm.c[0] + baseForm.c[1] + baseForm.c[2] + baseForm.c[3] + baseForm.c[4] + baseForm.c[5];
		int cur = curForm.c[0] + curForm.c[1] + curForm.c[2] + curForm.c[3] + curForm.c[4] + curForm.c[5];
		return cur * 100 / base;
	}

}
