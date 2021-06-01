/**   
 * @Title: StaticMineForm.java    
 * @Package com.game.domain.s    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年9月15日 下午2:21:50    
 * @version V1.0   
 */
package com.game.domain.s;

import java.util.List;

/**
 * @ClassName: StaticMineForm
 * @Description: 资源点单位部队阵型配置
 * @author ZhangJun
 * @date 2015年9月15日 下午2:21:50
 * 
 */
public class StaticMineForm {
	private int keyId;
	private int lv;
	private List<List<Integer>> form;
	private List<List<Integer>> attr;

	public int getKeyId() {
		return keyId;
	}

	public void setKeyId(int keyId) {
		this.keyId = keyId;
	}

	public int getLv() {
		return lv;
	}

	public void setLv(int lv) {
		this.lv = lv;
	}

	public List<List<Integer>> getForm() {
		return form;
	}

	public void setForm(List<List<Integer>> form) {
		this.form = form;
	}

	public List<List<Integer>> getAttr() {
		return attr;
	}

	public void setAttr(List<List<Integer>> attr) {
		this.attr = attr;
	}

}
