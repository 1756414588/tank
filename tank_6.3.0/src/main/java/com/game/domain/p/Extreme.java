/**   
 * @Title: ExtremeRecord.java    
 * @Package com.game.domain.p    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年9月26日 上午11:06:14    
 * @version V1.0   
 */
package com.game.domain.p;

import java.util.LinkedList;

import com.game.pb.CommonPb.AtkExtreme;

/**
 * @ClassName: ExtremeRecord
 * @Description: 极限探险
 * @author ZhangJun
 * @date 2015年9月26日 上午11:06:14
 * 
 */
public class Extreme {
	private int extremeId;
	private AtkExtreme first1;
	private LinkedList<AtkExtreme> last3 = new LinkedList<>();

	public int getExtremeId() {
		return extremeId;
	}

	public void setExtremeId(int extremeId) {
		this.extremeId = extremeId;
	}

	public AtkExtreme getFirst1() {
		return first1;
	}

	public void setFirst1(AtkExtreme first) {
		this.first1 = first;
	}

	public LinkedList<AtkExtreme> getLast3() {
		return last3;
	}

	public void setLast3(LinkedList<AtkExtreme> last3) {
		this.last3 = last3;
	}

}
