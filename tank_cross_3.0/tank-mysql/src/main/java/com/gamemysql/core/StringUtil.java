package com.gamemysql.core;

import com.google.common.base.Function;
import com.google.common.base.Joiner;
import com.google.common.base.Splitter;

public interface StringUtil {
  public static final Splitter SPLITTER_COMMA = Splitter.on(',').omitEmptyStrings().trimResults();
  public static final Splitter SPLITTER_SEMICOLON =
      Splitter.on(';').omitEmptyStrings().trimResults();
  public static final String SPLITER_INDEX_STRING = "$SPLIT_INDEX$";
  /** 自定义的分隔附 */
  public static final Splitter SPLITTER_INDEX_SELF =
      Splitter.on(SPLITER_INDEX_STRING).omitEmptyStrings().trimResults();

  public static final Splitter SPLITTER_SHEFFER_STROKE =
      Splitter.on('|').omitEmptyStrings().trimResults();
  public static final Splitter SPLITTER_COLON = Splitter.on(':').omitEmptyStrings().trimResults();
  public static final Splitter SPLITTER_MULTIPLE =
      Splitter.on('*').omitEmptyStrings().trimResults();

  public static final Joiner JOINER_COMMA = Joiner.on(',');
  public static final Joiner JOINER_SEMICOLON = Joiner.on(';');
  public static final Joiner JOINER_SHEFFER_STROKE = Joiner.on('|');
  public static final Joiner JOINER_COLON = Joiner.on(':');
  public static final Joiner JOINER_MULTIPLE = Joiner.on('*');

  public static final Splitter.MapSplitter MAP_SPLITTER_COMMA_COLON =
      Splitter.on(',').withKeyValueSeparator(':');
  public static final Splitter.MapSplitter MAP_SPLITTER_COMMA_MULTIPLE =
      Splitter.on(',').withKeyValueSeparator('*');

  public static final Function<String, Integer> Function_String_Integer =
      new Function<String, Integer>() {
        @Override
        public Integer apply(String input) {
          return Integer.parseInt(input);
        }
      };
}
