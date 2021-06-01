package com.game.util;

import java.util.LinkedList;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * @author ChenKui
 * @version 创建时间：2016-4-16 下午3:01:22
 * @declare
 */

public class ChatHelper {


	/**
	 * 比较若干条字符串是否相似
	 *
	 * @param c
	 * @return 返回期中有几条文字是相似的
	 */
	public static int isSamely(LinkedList<String> contents, float rate) {
		int samelyCount = 1;
		String refer = contents.getLast();
		for (String string : contents) {
			if(compare(refer, string ,rate)){
				samelyCount++;
			}
			refer =  string;
		}
		return samelyCount;
	}

	/**
	 * @param rate 相似比率 0到1
	 * @return
	 */
	public static boolean compare(String str1, String str2, float rate) {
		if(str1 == null || str2 == null){
			return false;
		}
		String longOne = null;
		String shortOne = null;
		if(str1.length() > str2.length() ) {
			longOne = str1;
			shortOne = str2;
		}else{
			longOne = str2;
			shortOne = str1;
		}
		if(longOne.length() < 10){//文字太短时增加判断的相似率值
			rate +=  (10 -longOne.length()) * 0.1;
			if(rate > 1){
				rate = 1;
			}
		}
		int diffChar = 0;//为了性能 这里判断差别文字所占比率
		float longlength = longOne.length();
		float shortlength = shortOne.length();
		for (int i = 0; i < shortlength; i++) {
			char c = shortOne.charAt(i);
			if(!longOne.contains(String.valueOf(c))){
				diffChar++;
			}
			if((shortlength - diffChar) / longlength < rate){//除去差别文字 得到剩余文字为可能相同文字  可能相同文字所占比率低于 rate 则不相似
				return false;
			}
		}
		return true;
	}
	/**
	 * 是否是中文
	 * 
	 * @param c
	 * @return
	 */
	public static boolean isChinese(char c) {
		Character.UnicodeBlock ub = Character.UnicodeBlock.of(c);
		if (ub == Character.UnicodeBlock.CJK_UNIFIED_IDEOGRAPHS || ub == Character.UnicodeBlock.CJK_COMPATIBILITY_IDEOGRAPHS
				|| ub == Character.UnicodeBlock.CJK_UNIFIED_IDEOGRAPHS_EXTENSION_A || ub == Character.UnicodeBlock.GENERAL_PUNCTUATION
				|| ub == Character.UnicodeBlock.CJK_SYMBOLS_AND_PUNCTUATION || ub == Character.UnicodeBlock.HALFWIDTH_AND_FULLWIDTH_FORMS) {
			return true;
		}
		return false;
	}

	/**
	 * 
	* 是否是合法字符
	* @param correct
	* @return  
	* boolean
	 */
	public static boolean isCorrect(String correct) {
		String regEx = "[^`~!@#$%ㄒ^&*╮╭3ε≧▽≦‖｜￣∶丶·§№☆★ 	○●◎◇◆□■△▲※→←↑↓〓＃＆＠＼＾＿┌┍┎┏┐┑┒┓—┄┈├┝┞┟┠┡┢┣|┆┊┬┭┮┯┰┱┲┳┼┽┾┿╀╂╁╃≈≡≠＝≤≥＜＞≮≯∷±＋－×÷／∫∮∝∞∧∨∑∏∪∩∈∵∴⊥‖∠⌒⊙≌∽√ⅠⅡⅢⅣⅤⅥⅦⅧⅨⅩⅪⅫ①②③④⑤⑥⑦⑧⑨⑩︻︼︽︾〒↑↓☉⊙●〇◎¤★☆■▓「」『』◆◇▲△▼▽◣◥◢◣◤ ◥№↑↓→←↘↙Ψ※㊣∑⌒∩【】〖〗＠ξζω□∮〓※》∏卐√ ╳々♀♂∞①ㄨ≡╬╭╮╰╯╱╲ ▂ ▂ ▃ ▄ ▅ ▆ ▇ █ ▂▃▅▆█ ▁▂▃▄▅▆▇█▇▆▅▄▃▂▁╰╯∩(（）)+=|{}':;',\\[\\].<>/?~！@#￥%……&*（）——+|{}【】‘；：”“’。，、？\\p{P}a-zA-Z0-9\\u4e00-\\u9fa5]+";
		Pattern p = Pattern.compile(regEx);
		Matcher m = p.matcher(correct);
		if (m.find())
			return true;
		else
			return false;
	}

	public static void main(String[] args) {
		// 特殊字符
		//LogUtil.info("isCorrect(\"(* ￣3)(ε￣ *)\")"+isCorrect("(* ￣3)(ε￣ *)"));
		// LogUtil.info(isCorrect(""));
		// LogUtil.info(isCorrect("O(∩_∩)O哈哈~"));
		// LogUtil.info(isCorrect("سمَـَّوُوُحخ ̷̴̐خ ̷̴̐خ ̷̴̐خ امارتيخ ̷̴̐خ"));
	}

}
