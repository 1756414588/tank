/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package com.test;

/**
 *
 * @author Administrator
 */
import sun.misc.BASE64Decoder;     
import sun.misc.BASE64Encoder; 

public class Base64{     
        private static final char[] base64Map =  //base64 character table

         { 'A','B','C','D','E','F','G','H','I','J','K','L','M','N',
           'O','P','Q','R','S','T','U','V','W','X','Y','Z','a','b',
           'c','d','e','f','g','h','i','j','k','l','m','n','o','p',
           'q','r','s','t','u','v','w','x','y','z','0','1','2','3',
           '4','5','6','7','8','9','+','/' } ;
 
  /** convert the platform dependent string characters to UTF8 which can 
    * also be done by calling the java String method getBytes("UTF-8"),but I
    * hope to do it from the ground up.
    */

    private static byte[] toUTF8ByteArray(String s) 
    {
         int ichar; 
         byte buffer[]=new byte[3*(s.length())];
         byte hold[];
         int index=0;
         int count=0; //count the actual bytes in the
                          //buffer array          
             
         for(int i=0;i<s.length();i++)
         { 
               ichar = (int)s.charAt(i);

                 //determine the bytes for a specific character
               if((ichar>=0x0080)&(ichar<=0x07FF))
                 {
                   buffer[index++] = (byte)((6<<5)|((ichar>>6)&31));
                   buffer[index++] = (byte)((2<<6)|(ichar&63));
                   count+=2;
                 }
              
               //determine the bytes for a specific character
               else if((ichar>=0x0800)&(ichar<=0x0FFFF))
                 {
                   buffer[index++] = (byte)((14<<4)|((ichar>>12)&15));
                   buffer[index++] = (byte)((2<<6)|((ichar>>6)&63));
                   buffer[index++] = (byte)((2<<6)|(ichar&63));
                   count+=3;
                 }
                 
              //determine the bytes for a specific character
               else if((ichar>=0x0000)&(ichar<=0x007F))
                 {
                   buffer[index++] = (byte)((0<<7)|(ichar&127));  
                   count+=1;
                 }

              //longer than 16 bit Unicode is not supported
               else throw new RuntimeException("Unsupported encoding character length!\n");
         }
         hold = new byte[count];
         System.arraycopy(buffer,0,hold,0,count); //trim to size
         return hold ;
    }

    public static String encode(String s)
    {
          byte buf[] = toUTF8ByteArray(s);
         return encode(buf);
    }

    public static String encode(byte buf[]) 
    {     
         StringBuffer sb = new StringBuffer();
         String padder = "" ; 
             
         if( buf.length == 0 )  return "" ; 
       
         //cope with less than 3 bytes conditions at the end of buf
 
         switch( buf.length%3)
         {
               case 1 : 
               { 
                  padder += base64Map[(( buf[buf.length-1] >>> 2 ) & 63) ] ;
                  padder += base64Map[ (( buf[buf.length-1] << 4 ) & 63) ] ;     
                  padder += "==" ;
                  break ;
               }      
               case 2 :
               {
                  padder += base64Map[ ( buf[buf.length-2] >>> 2 ) & 63 ] ;
                  padder += base64Map[ (((buf[buf.length-2] << 4 )&63)) | ((( buf[buf.length-1] >>>4 ) & 63)) ] ;          
                  padder += base64Map[ ( buf[buf.length-1] << 2 ) & 63 ] ;          
                  padder += "=" ;
                  break ;
               }
               default :    break ;
         }           

         int temp =0 ;
         int index = 0 ;
          
         //encode buf.length-buf.length%3 bytes which must be a multiply of 3

         for( int i=0 ; i < ( buf.length-(buf.length % 3) ) ; )
         {
              //get three bytes and encode them to four base64 characters
              temp = ((buf[i++] << 16)&0xFF0000)|((buf[i++] << 8)&0xFF00)|(buf[i++]&0xFF) ;
              index = (temp >> 18) & 63 ;        
              sb.append(base64Map[ index ]);
              if(sb.length()%76==0)//a Base64 encoded line is no longer than 76 characters
                  sb.append('\n');
  
              index = (temp >> 12 ) & 63 ;
              sb.append(base64Map[ index ]);
              if(sb.length()%76==0)
                  sb.append('\n');
           
              index = (temp >> 6 ) & 63 ;
              sb.append(base64Map[ index ]);
              if(sb.length()%76==0)
                  sb.append('\n');

              index = temp & 63 ;
              sb.append(base64Map[ index ]);
              if(sb.length()%76==0)
                  sb.append('\n');
         }

         sb.append(padder);  //add the remaining one or two bytes
         return sb.toString(); 
   }

    public static String decode(String s)
    {
          
        byte buf[];
        try {
            buf = decodeToByteArray(s);
            
            s=new String(buf,"UTF-8");
            s=s.replaceAll("[\\n|\\r]","");;
        } catch (Exception e) {
            // TODO Auto-generated catch block
            return "";
        }
         return s;
    }
    
    public static byte[] decodeToByteArray(String s) throws Exception
    {
         byte hold[];

         if( s.length() == 0 )  return null ; 
         byte buf[] = s.getBytes("iso-8859-1") ;
         byte debuf[] = new byte[buf.length*3/4] ;
         byte tempBuf[]=new byte[4] ;
         int index=0;
         int index1=0;
         int temp;
         int count=0;
         int count1=0; 
         
         //decode to byte array
         for(int i=0; i<buf.length;i++)
         {
             if(buf[i]>=65 && buf[i]<91)
               tempBuf[index++]=(byte)(buf[i]-65);
             else if(buf[i]>=97 && buf[i]<123)
               tempBuf[index++]=(byte)(buf[i]-71);
             else if(buf[i]>=48 && buf[i]<58)
               tempBuf[index++]=(byte)(buf[i]+4);
             else if(buf[i]=='+')
               tempBuf[index++]=62;
             else if(buf[i]=='/')
               tempBuf[index++]=63;
             else if(buf[i]=='=')
             {
               tempBuf[index++]=0;
               count1++;
             }

             //Discard line breaks and other nonsignificant characters
             else
             {
               if(buf[i]=='\n' || buf[i]=='\r' || buf[i]==' ' || buf[i]=='\t')
                  continue;
               else   throw new RuntimeException("Illegal character found in encoded string!");
             }
             if(index==4)
             { 
               temp=((tempBuf[0]<<18)) | (( tempBuf[1] <<12)) | ((tempBuf[2]<<6)) | (tempBuf[3]) ;
               debuf[index1++]=(byte)(temp>>16) ;
               debuf[index1++]=(byte)((temp>>8)&255) ;
               debuf[index1++]=(byte)(temp&255) ;
               count+=3;
               index=0;
             }
         }
         hold = new byte[count-count1];
         System.arraycopy(debuf,0,hold,0,count-count1); //trim to size
         return hold ;
    }
}    