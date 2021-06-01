package com.game.util;

import java.util.Arrays;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

/**
 * 排行榜实时排名对象，注意此类未做线程同步处理
 * Created by zhangdh on 2017/4/13.
 */
public class UnsafeSortInfo {
    /** 排名对象集合   索引是排名*/
    private ISortVO[] data;
    /**   key:lordid  value：排名*/
    private Map<String, Integer> indexMap;
    /**  排名最大数*/
    private int size;

    public UnsafeSortInfo(int size) {
        this.size = Math.min(Math.abs(size), 10000);
    }

    public UnsafeSortInfo(UnsafeSortInfo src) {
        if (src.data != null) {
            data = new ISortVO[src.data.length];
            System.arraycopy(src.data, 0, data, 0, data.length);
        }
        if (src.indexMap != null) {
            indexMap = new HashMap<>(src.indexMap);
        }
        size = src.size;
    }

    /**
     * 排行榜自检测
    *   
    * void
     */
    public void checkSelf() {
        for (Map.Entry<String, Integer> entry : indexMap.entrySet()) {
            ISortVO vo = data[entry.getValue()];
            if (!vo.getKey().equals(entry.getKey())) {
                LogUtil.info(String.format("check fail, cur size :%d, indexMap.size :%d, index:%d, key :%s, sort vo key :%s, sort vo value :%d", data.length, indexMap.size(), entry.getValue(), entry.getKey(), vo.getKey(), vo.getValue()));
                return;
            }
        }
        LogUtil.info("check self succ!!!");
    }

    public UnsafeSortInfo(ISortVO[] data, int size) {
        this(size);
        this.data = data;
        this.indexMap = new HashMap<>();
        for (int i = 0; i < data.length; i++) {
            indexMap.put(data[i].getKey(), i);
        }
    }

    /**
     * 转成字符串 排名详情
    * <p>Title: toString</p> 
    * <p>Description: </p> 
    * @return 
    * @see java.lang.Object#toString()
     */
    public String toString() {
        ISortVO[] str_data = data.length <= 500 ? data : Arrays.copyOf(data, 500);
        return String.format("data size :%d, per 500 data :%s", data.length, Arrays.toString(str_data));
    }
    

    /**
     * 排行榜最大排名数据
     *
     * @return
     */
    public int getMaxSize() {
        return size;
    }

    /**
     * 排行榜当前数据大小
     *
     * @return
     */
    public int getCurSize() {
        return data == null ? 0 : data.length;
    }

    /**
     * 排行榜访问接口
     *
     * @return
     */
    public Iterator<ISortVO> iterator() {
        return new ChartsIterator(data);
    }

    /**
     * 获取key 在排行榜中的排名
     *
     * @param key
     * @return <0 未上榜, >=0 排名名次
     */
    public int getRanking(String key) {
        if (indexMap == null) {
            return -1;
        } else {
            Integer index = indexMap.get(key);
            return index == null ? -1 : index;
        }
    }

    /**
     * 
    * 没用到
    * @param key
    * @return  
    * ISortVO
     */
    public ISortVO getSort(String key) {
        Integer index = indexMap.get(key);
        return index == null ? null : data[index];
    }

    /**
     * 
     * @param rank 排名 取值范围 [0, data.len)
     * @return
     */
    public ISortVO getSort(int rank) {
        if (data == null || rank >= data.length) return null;
        return data[rank];
    }

    public ISortVO[] getData() {
        return data;
    }

    public void remove(String key) {
        Integer index = indexMap.get(key);
        if (index == null) return;
        System.arraycopy(data, index + 1, data, index, data.length - (index + 1));
        for (int i = index; i < data.length; i++) {
            indexMap.put(data[i].getKey(), i);
        }
    }


    public void clear() {
        data = null;
        if (indexMap != null) {
            indexMap.clear();
        }
    }

    /**
     * 子列表
     *
     * @param start include
     * @param end   exclude
     * @return
     */
    public ISortVO[] getSubs(int start, int end) {
        if (data == null || indexMap == null || start >= getCurSize()) return null;
        if (start < 0 || end < 0 || start > (end = Math.min(end, data.length))) {
            throw new IllegalArgumentException(String.format("start :%d > end :%d", start, end));
        }
        ISortVO[] subs = new ISortVO[end - start];
        System.arraycopy(data, start, subs, 0, subs.length);
        return subs;
    }

    /**
     * 排行榜迭代器
    * @ClassName: ChartsIterator 
    * @Description: TODO
    * @author
     */
    private class ChartsIterator implements Iterator<ISortVO> {

        private ISortVO[] iterData;
        private int cusor;

        ChartsIterator(ISortVO[] data) {
            this.iterData = data;
        }

        @Override
        public boolean hasNext() {
            return iterData != null && cusor < this.iterData.length;
        }

        @Override
        public ISortVO next() {
            return this.iterData[cusor++];
        }

        @Override
        public void remove() {
            throw new UnsupportedOperationException();
        }

        public int size() {
            return iterData == null ? 0 : iterData.length;
        }
    }

    /**
     * 更新排行榜排名
     *
     * @param uvo 更新的信息
     * @return true - 排行榜发生了更新, false - 排行榜没有发生更新
     */
    public boolean upsert(ISortVO uvo) {
        String key = uvo != null ? uvo.getKey() : null;
        if (key == null) throw new NullPointerException("charts upsert key is null");
        Integer index = indexMap == null ? null : indexMap.get(key);
        if (index == null) {
            return insertNotfound(uvo);
        } else {
            return updateFound(uvo, index);
        }
    }

    /**
     * 插入之前未在排行榜之中的对象
     *
     * @param uvo
     * @return
     */
    @SuppressWarnings("unchecked")
    private boolean insertNotfound(ISortVO uvo) {
        if (data == null) {//第一次插入数据进来
            data = new ISortVO[]{uvo};
            indexMap = new HashMap<>();
            indexMap.put(uvo.getKey(), 0);
            return true;
        }
        if (uvo.compareTo(data[data.length - 1]) >= 0) {// 小于最后一名
            if (data.length >= size) {
                return false;
            } else {
                insert0(uvo, data.length);
            }
        } else if (uvo.compareTo(data[0]) < 0) {// 超过第一名
            insert0(uvo, 0);
        } else {
            insert0(uvo);
        }
        return true;
    }


    /**
     * 更新之前在排行榜上的对象
     *
     * @param uvo
     * @param oldIndex
     * @return
     */
    @SuppressWarnings("unchecked")
    private boolean updateFound(ISortVO uvo, int oldIndex) {
        ISortVO old = data[oldIndex];
        data[oldIndex] = uvo;
        int v = old.compareTo(uvo);
        if (v == 0) {
            return false;
        } else if (v > 0) {//数据变大计划往前更新排名
            if (oldIndex == 0) {
                return false;//已经最大,不更新
            } else {
                if (data[oldIndex - 1].compareTo(uvo) <= 0) {
                    return false;//比前一名小,不更新
                }
                update0(uvo, oldIndex, 0, oldIndex);
            }
        } else {//数据变小计划往后更新排名
            if (oldIndex == data.length - 1) {
                return false;//已经最小,不更新
            } else {
                if (data[oldIndex + 1].compareTo(uvo) >= 0) return false;//比后一名大,不更新
                update0(uvo, oldIndex, oldIndex + 1, data.length);
            }
        }
        return true;
    }

    /**
     * 
    *  在某个排名范围内更新排名  因为如果每次都从所有排名里更新该对象的排名性能损耗大 所以先找到它会在哪个范围更新
    * @param vo
    * @param oldIndex
    * @param formIndex
    * @param toIndex  
    * void
     */
    private void update0(ISortVO vo, int oldIndex, int formIndex, int toIndex) {
        int pos = Arrays.binarySearch(data, formIndex, toIndex, vo);
        int index = Math.abs(pos + 1);
        update0(vo, index, oldIndex);
    }
    

    /**
     * 
    * 变更排名
    * @param vo
    * @param index
    * @param oldIndex  
    * void
     */
    private void update0(ISortVO vo, int index, int oldIndex) {
        int start, end;
        if (index < oldIndex) {//排名往前提升
            System.arraycopy(data, index, data, index + 1, oldIndex - index);
            data[index] = vo;
            start = index;
            end = oldIndex;
        } else {
            System.arraycopy(data, oldIndex + 1, data, oldIndex, index - (oldIndex + 1));
            data[index - 1] = vo;
            start = oldIndex;
            end = index - 1;
        }
        for (int i = start; i <= end; i++) {
            indexMap.put(this.data[i].getKey(), i);
        }
    }

    /**
     * 
    * 插入排名中
    * @param vo  
    * void
     */
    private void insert0(ISortVO vo) {
        int pos = Arrays.binarySearch(data, vo);
        int index = Math.abs(pos + 1);
        insert0(vo, index);
    }

    /**
     * 
    * 插入到第index名
    * @param vo
    * @param index  
    * void
     */
    private void insert0(ISortVO vo, int index) {
        //更新数据和索引
        if (data.length >= size) {
            ISortVO old = data[data.length - 1];
            indexMap.remove(old.getKey());
            System.arraycopy(data, index, data, index + 1, (data.length - 1) - index);
            data[index] = vo;
        } else {
            ISortVO[] dest = new ISortVO[data.length + 1];
            System.arraycopy(data, 0, dest, 0, data.length);
            System.arraycopy(dest, index, dest, index + 1, data.length - index);
            dest[index] = vo;
            this.data = dest;
        }
        for (int i = index; i < data.length; i++) {
            indexMap.put(data[i].getKey(), i);
        }
    }

    public interface ISortVO<S extends ISortVO> extends Comparable<S>{

        String getKey();

        long getValue();
    }

}
