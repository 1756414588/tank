package com.gamemysql.jdbc;

import com.google.common.base.Strings;

import java.math.BigDecimal;
import java.math.BigInteger;
import java.text.DecimalFormat;
import java.text.NumberFormat;
import java.text.ParseException;

/**
 * Miscellaneous utility methods for number conversion and parsing. Mainly for internal use within
 * the framework; consider Jakarta's Commons Lang for a more comprehensive suite of string
 * utilities.
 *
 * @author Juergen Hoeller
 * @author Rob Harrop
 * @since 1.1.2
 */
public abstract class NumberUtils {

  /**
   * Convert the given number into an instance of the given target class.
   *
   * @param number the number to convert
   * @param targetClass the target class to convert to
   * @return the converted number
   * @throws IllegalArgumentException if the target class is not supported (i.e. not a standard
   *     Number subclass as included in the JDK)
   * @see Byte
   * @see Short
   * @see Integer
   * @see Long
   * @see BigInteger
   * @see Float
   * @see Double
   * @see BigDecimal
   */
  @SuppressWarnings("unchecked")
  public static <T extends Number> T convertNumberToTargetClass(Number number, Class<T> targetClass)
      throws IllegalArgumentException {
    if (targetClass.isInstance(number)) {
      return (T) number;
    } else if (targetClass.equals(Byte.class)) {
      long value = number.longValue();
      if (value < Byte.MIN_VALUE || value > Byte.MAX_VALUE) {
        raiseOverflowException(number, targetClass);
      }
      return (T) new Byte(number.byteValue());
    } else if (targetClass.equals(Short.class)) {
      long value = number.longValue();
      if (value < Short.MIN_VALUE || value > Short.MAX_VALUE) {
        raiseOverflowException(number, targetClass);
      }
      return (T) new Short(number.shortValue());
    } else if (targetClass.equals(Integer.class)) {
      long value = number.longValue();
      if (value < Integer.MIN_VALUE || value > Integer.MAX_VALUE) {
        raiseOverflowException(number, targetClass);
      }
      return (T) new Integer(number.intValue());
    } else if (targetClass.equals(Long.class)) {
      return (T) new Long(number.longValue());
    } else if (targetClass.equals(BigInteger.class)) {
      if (number instanceof BigDecimal) {
        // do not lose precision - use BigDecimal's own conversion
        return (T) ((BigDecimal) number).toBigInteger();
      } else {
        // original value is not a Big* number - use standard long conversion
        return (T) BigInteger.valueOf(number.longValue());
      }
    } else if (targetClass.equals(Float.class)) {
      return (T) new Float(number.floatValue());
    } else if (targetClass.equals(Double.class)) {
      return (T) new Double(number.doubleValue());
    } else if (targetClass.equals(BigDecimal.class)) {
      // always use BigDecimal(String) here to avoid unpredictability of BigDecimal(double)
      // (see BigDecimal javadoc for details)
      return (T) new BigDecimal(number.toString());
    } else {
      throw new IllegalArgumentException(
          "Could not convert number ["
              + number
              + "] of type ["
              + number.getClass().getName()
              + "] to unknown target class ["
              + targetClass.getName()
              + "]");
    }
  }

  /**
   * Raise an overflow exception for the given number and target class.
   *
   * @param number the number we tried to convert
   * @param targetClass the target class we tried to convert to
   */
  private static void raiseOverflowException(Number number, Class targetClass) {
    throw new IllegalArgumentException(
        "Could not convert number ["
            + number
            + "] of type ["
            + number.getClass().getName()
            + "] to target class ["
            + targetClass.getName()
            + "]: overflow");
  }

  /**
   * Parse the given text into a number instance of the given target class, using the corresponding
   * {@code decode} / {@code valueOf} methods.
   *
   * <p>Trims the input {@code String} before attempting to parse the number. Supports numbers in
   * hex format (with leading "0x", "0X" or "#") as well.
   *
   * @param text the text to convert
   * @param targetClass the target class to parse into
   * @return the parsed number
   * @throws IllegalArgumentException if the target class is not supported (i.e. not a standard
   *     Number subclass as included in the JDK)
   * @see Byte#decode
   * @see Short#decode
   * @see Integer#decode
   * @see Long#decode
   * @see #decodeBigInteger(String)
   * @see Float#valueOf
   * @see Double#valueOf
   * @see BigDecimal#BigDecimal(String)
   */
  @SuppressWarnings("unchecked")
  public static <T extends Number> T parseNumber(String text, Class<T> targetClass) {
    String trimmed = trimAllWhitespace(text.trim());

    if (targetClass.equals(Byte.class)) {
      return (T) (isHexNumber(trimmed) ? Byte.decode(trimmed) : Byte.valueOf(trimmed));
    } else if (targetClass.equals(Short.class)) {
      return (T) (isHexNumber(trimmed) ? Short.decode(trimmed) : Short.valueOf(trimmed));
    } else if (targetClass.equals(Integer.class)) {
      return (T) (isHexNumber(trimmed) ? Integer.decode(trimmed) : Integer.valueOf(trimmed));
    } else if (targetClass.equals(Long.class)) {
      return (T) (isHexNumber(trimmed) ? Long.decode(trimmed) : Long.valueOf(trimmed));
    } else if (targetClass.equals(BigInteger.class)) {
      return (T) (isHexNumber(trimmed) ? decodeBigInteger(trimmed) : new BigInteger(trimmed));
    } else if (targetClass.equals(Float.class)) {
      return (T) Float.valueOf(trimmed);
    } else if (targetClass.equals(Double.class)) {
      return (T) Double.valueOf(trimmed);
    } else if (targetClass.equals(BigDecimal.class) || targetClass.equals(Number.class)) {
      return (T) new BigDecimal(trimmed);
    } else {
      throw new IllegalArgumentException(
          "Cannot convert String [" + text + "] to target class [" + targetClass.getName() + "]");
    }
  }

  public static String trimAllWhitespace(String str) {
    if (Strings.isNullOrEmpty(str)) {
      return str;
    }
    StringBuilder sb = new StringBuilder(str);
    int index = 0;
    while (sb.length() > index) {
      if (Character.isWhitespace(sb.charAt(index))) {
        sb.deleteCharAt(index);
      } else {
        index++;
      }
    }
    return sb.toString();
  }

  /**
   * Parse the given text into a number instance of the given target class, using the given
   * NumberFormat. Trims the input {@code String} before attempting to parse the number.
   *
   * @param text the text to convert
   * @param targetClass the target class to parse into
   * @param numberFormat the NumberFormat to use for parsing (if {@code null}, this method falls
   *     back to {@code parseNumber(String, Class)})
   * @return the parsed number
   * @throws IllegalArgumentException if the target class is not supported (i.e. not a standard
   *     Number subclass as included in the JDK)
   * @see NumberFormat#parse
   * @see #convertNumberToTargetClass
   * @see #parseNumber(String, Class)
   */
  public static <T extends Number> T parseNumber(
      String text, Class<T> targetClass, NumberFormat numberFormat) {
    if (numberFormat != null) {
      DecimalFormat decimalFormat = null;
      boolean resetBigDecimal = false;
      if (numberFormat instanceof DecimalFormat) {
        decimalFormat = (DecimalFormat) numberFormat;
        if (BigDecimal.class.equals(targetClass) && !decimalFormat.isParseBigDecimal()) {
          decimalFormat.setParseBigDecimal(true);
          resetBigDecimal = true;
        }
      }
      try {
        Number number = numberFormat.parse(trimAllWhitespace(text));
        return convertNumberToTargetClass(number, targetClass);
      } catch (ParseException ex) {
        throw new IllegalArgumentException("Could not parse number: " + ex.getMessage());
      } finally {
        if (resetBigDecimal) {
          decimalFormat.setParseBigDecimal(false);
        }
      }
    } else {
      return parseNumber(text, targetClass);
    }
  }

  /**
   * Determine whether the given value String indicates a hex number, i.e. needs to be passed into
   * {@code Integer.decode} instead of {@code Integer.valueOf} (etc).
   */
  private static boolean isHexNumber(String value) {
    int index = (value.startsWith("-") ? 1 : 0);
    return (value.startsWith("0x", index)
        || value.startsWith("0X", index)
        || value.startsWith("#", index));
  }

  /**
   * Decode a {@link BigInteger} from a {@link String} value. Supports decimal, hex and octal
   * notation.
   *
   * @see BigInteger#BigInteger(String, int)
   */
  private static BigInteger decodeBigInteger(String value) {
    int radix = 10;
    int index = 0;
    boolean negative = false;

    // Handle minus sign, if present.
    if (value.startsWith("-")) {
      negative = true;
      index++;
    }

    // Handle radix specifier, if present.
    if (value.startsWith("0x", index) || value.startsWith("0X", index)) {
      index += 2;
      radix = 16;
    } else if (value.startsWith("#", index)) {
      index++;
      radix = 16;
    } else if (value.startsWith("0", index) && value.length() > 1 + index) {
      index++;
      radix = 8;
    }

    BigInteger result = new BigInteger(value.substring(index), radix);
    return (negative ? result.negate() : result);
  }
}
