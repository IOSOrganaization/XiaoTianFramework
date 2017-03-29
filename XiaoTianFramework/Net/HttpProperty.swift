//
//  HttpProperty.swift
//  DriftBook
//  Http请求属性配置
//  Created by XiaoTian on 16/7/3.
//  Copyright © 2016年 XiaoTian. All rights reserved.
//

import Foundation

public class HttpProperty {
    public class HeaderProperty{
        // header fields
        public static let ACCEPT = "Accept";
        public static let ACCEPT_CHARSET = "Accept-Charset";
        public static let ACCEPT_ENCODING = "Accept-Encoding";
        public static let ACCEPT_LANGUAGE = "Accept-Language";
        public static let AUTHORIZATION = "Authorization";
        public static let FROM = "From";
        public static let HOST = "Host";
        public static let RANGE = "Range";
        public static let EXPECT = "Expect";
        public static let REFERER = "Referer";
        public static let USER_AGENT = "User-Agent";
        public static let MAX_FORWARDS = "Max-Forwards";
        public static let PROXY_AUTHORIZATION = "Proxy-Authorization";
        public static let TE = "TE";
        public static let IF_RANGE = "If-Range";
        public static let IF_MATCH = "If-Match";
        public static let IF_NONE_MATCH = "If-None-Match";
        public static let IF_MODIFIED_SINCE = "If-Modified-Since";
        public static let IF_UNMODIFIED_SINCE = "If-Unmodified-Since";
        // header fields for Entity
        public static let DATE = "Date";
        public static let ALLOW = "Allow";
        public static let EXPIRES = "Expires";
        public static let CHARSET = "Charset";
        public static let CONNECTION = "Connection";
        public static let CONTENT_MD5 = "Content-MD5";
        public static let CONTENT_TYPE = "Content-Type";
        public static let LAST_MODIFIED = "Last-Modified";
        public static let CONTENT_RANGE = "Content-Range";
        public static let CONTENT_LENGTH = "Content-Length";
        public static let CONTENT_ENCODING = "Content-Encoding";
        public static let CONTENT_LANGUAGE = "Content-Language";
        public static let CONTENT_LOCATION = "Content-Location";
        public static let CONTENT_DISPOSITION = "Content-Disposition";
        public static let CONTENT_TRANSFER_ENCODING = "Content-Transfer-Encoding";
        // Media
        public static let BOUNDARY = "boundary";
    }
    public class ContentType {
        public static let TEXT_PLAN = "text/plain";
        public static let TEXT_HTML = "text/html";
        public static let IMAGE_GIF = "image/gif";
        public static let IMAGE_PNG = "image/png";
        public static let IMAGE_JPG = "image/jpeg";
        public static let VIDEO_MPEG = "video/mpeg";
        public static let MESSAGE_HTTP = "message/http";
        public static let MESSAGE_RFC822 = "message/rfc822";
        public static let APPLICATION_PDF = "application/pdf";
        public static let APPLICATION_JSON = "application/json";
        public static let APPLICATION_WORD = "application/msword";
        public static let APPLICATION_XHTML = "application/xhtml+xml";
        public static let APPLICATION_WAP_HTML_10 = "application/vnd.wap.xhtml+xml";
        public static let APPLICATION_WAP_HTML_20 = "application/xhtml+xml";
        public static let APPLICATION_STREAM = "application/octet-stream";
        public static let MULTIPART_ALTERNATIVE = "multipart/alternative";
        public static let MULTIPART_FORM_DATA = "multipart/form-data";
        public static let MULTIPART_BYTERANGES = "multipart/byteranges";
        public static let APPLICATION_FORM_URLENCODEED = "application/x-www-form-urlencoded;charset=utf-8";
        // 必要参数:
        // **1.message/http**
        // Media Type name: message
        // Media subtype name: http
        // Required parameters: none
        // Optional parameters: version, msgtype
        // version: The HTTP-Version number of the enclosed message
        // (e.g., "1.1"). If not present, the version can be
        // determined from the first line of the body.
        // msgtype: The message type -- "request" or "response". If not
        // present, the type can be determined from the first
        // line of the body.
        // Encoding considerations: only "7bit", "8bit", or "binary" are
        // permitted
        // Security considerations: none
        // **2.application/http**
        // Media Type name: application
        // Media subtype name: http
        // Required parameters: none
        // Optional parameters: version, msgtype
        // version: The HTTP-Version number of the enclosed messages
        // (e.g., "1.1"). If not present, the version can be
        // determined from the first line of the body.
        // msgtype: The message type -- "request" or "response". If not
        // present, the type can be determined from the first
        // line of the body.
        // Encoding considerations: HTTP messages enclosed by this type
        // are in "binary" format; use of an appropriate
        // Content-Transfer-Encoding is required when
        // transmitted via E-mail.
        // Security considerations: none
        // 3.**multipart/byteranges**
        // Media Type name: multipart
        // Media subtype name: byteranges
        // Required parameters: boundary
        // Optional parameters: none
        // Encoding considerations: only "7bit", "8bit", or "binary" are
        // permitted
        // Security considerations: none
        // ######范例:#####
        // Date: Wed, 15 Nov 1995 06:25:24 GMT
        // Last-Modified: Wed, 15 Nov 1995 04:58:08 GMT
        // Content-type: multipart/byteranges; boundary=THIS_STRING_SEPARATES
        //
        // --THIS_STRING_SEPARATES
        // Content-type: application/pdf
        // Content-range: bytes 500-999/8000
        //
        // ...the first range...
        // --THIS_STRING_SEPARATES
        // Content-type: application/pdf
        // Content-range: bytes 7000-7999/8000
        //
        // ...the second range
        // --THIS_STRING_SEPARATES--
    }
    //
    public class TransferEncoding {
        public static let BIT_7 = "7bit"; // 7 BIT ASCII
        public static let BIT_8 = "8bit"; // 8 BIT ASCII
        public static let BINARY = "binary";
        public static let BASE64 = "base64";
        public static let QUOTED_PRINTABLE = "quoted-printable";
    }
    
    //
    public class Charset {
        public static let ASCII = "ASCII";
        public static let GBK = "GBK";
        public static let UTF_8 = "UTF-8";
    }
    
    //
    public class Method {
        public static let GET = "GET";
        public static let PUT = "PUT";
        public static let POST = "POST";
        public static let HEAD = "HEAD";
        public static let TRACE = "TRACE";
        public static let DELETE = "DELETE";
        public static let CONNECT = "CONNECT";
        public static let OPTIONS = "OPTIONS";
    }
    
    //
    public class Accept {
        public static let ALL = "*/*";
        public static let TEXT = "text/*";
        public static let TEXT_HTML = "text/html";
        public static let TEXT_HTML_level_1 = "text/html;level=1";
        public static let IMAGE = "image/*";
        public static let IMAGE_jpeg = "image/jpeg";
    }
    
    public class AcceptEncoding {
        public static let ALL = "*";
        public static let COMPRESS_GZIP = "compress, gzip";
    }
    
    public class ConetentEncoding {
        public static let GZIP = "gzip";
    }
    
    public class Date {
        public func current() -> String{
            let nowDouble = NSDate().timeIntervalSince1970
            let millisecond = Int64(nowDouble * 1000)
            return String(millisecond)
        }
    }
    
    public class ETag {
        public static let XYZZY = "\"xyzzy\"";
        public static let WXYZZY = "W/\"xyzzy\"";
    }
    
    public class From {
        public static let ME = "gtrstudio@qq.com";
    }
    
    public class Host {
        public static let ME = "www.xiaotiangd.com";
    }
    
    public class UserAgent {
        public static let IE = "IntentExplorer";
        public static let Chrome = "Chrome";
        public static let IOS = "IOS";
        public static let CERN = "CERN-LineMode/2.15 libwww/2.17b3";
    }
    
    public class ContentTransferEncoding {
        public static let QUOTED_PRINTABLE = "quoted-printable";
        public static let BASE64 = "base64";
    }
    
    public class ContentDisposition {
        public static let ATTACHMENT_FILENAME = "attachment; filename=\"fname.ext\"";
    }
    
    public class Language {
        public static let EN = "en";
        public static let EN_US = "en-US";
        public static let CN = "cn";
        public static let ZH_CN = "zh-CN";
    }
    
    public class Connection {
        public static let KEEP_ALIVE = "keep-alive";
    }
    // **General Header Fields**
    // general-header = Cache-Control ; Section 14.9
    // | Connection ; Section 14.10
    // | Date ; Section 14.18
    // | Pragma ; Section 14.32
    // | Trailer ; Section 14.40
    // | Transfer-Encoding ; Section 14.41
    // | Upgrade ; Section 14.42
    // | Via ; Section 14.45
    // | Warning ; Section 14.46
    // **Request Header Fields**
    // request-header = Accept ; Section 14.1
    // | Accept-Charset ; Section 14.2
    // | Accept-Encoding ; Section 14.3
    // | Accept-Language ; Section 14.4
    // | Authorization ; Section 14.8
    // | Expect ; Section 14.20
    // | From ; Section 14.22
    // | Host ; Section 14.23
    // | If-Match ; Section 14.24
    // | If-Modified-Since ; Section 14.25
    // | If-None-Match ; Section 14.26
    // | If-Range ; Section 14.27
    // | If-Unmodified-Since ; Section 14.28
    // | Max-Forwards ; Section 14.31
    // | Proxy-Authorization ; Section 14.34
    // | Range ; Section 14.35
    // | Referer ; Section 14.36
    // | TE ; Section 14.39
    // | User-Agent ; Section 14.43
    // **Status Code and Reason Phrase**
    // - 1xx: Informational - Request received, continuing process
    //
    // - 2xx: Success - The action was successfully received,
    // understood, and accepted
    //
    // - 3xx: Redirection - Further action must be taken in order to
    // complete the request
    //
    // - 4xx: Client Error - The request contains bad syntax or cannot
    // be fulfilled
    //
    // - 5xx: Server Error - The server failed to fulfill an apparently
    // valid request Status-Code = "100" ; Section 10.1.1: Continue
    // | "101" ; Section 10.1.2: Switching Protocols
    // | "200" ; Section 10.2.1: OK
    // | "201" ; Section 10.2.2: Created
    // | "202" ; Section 10.2.3: Accepted
    // | "203" ; Section 10.2.4: Non-Authoritative Information
    // | "204" ; Section 10.2.5: No Content
    // | "205" ; Section 10.2.6: Reset Content
    // | "206" ; Section 10.2.7: Partial Content
    // | "300" ; Section 10.3.1: Multiple Choices
    // | "301" ; Section 10.3.2: Moved Permanently
    // | "302" ; Section 10.3.3: Found
    // | "303" ; Section 10.3.4: See Other
    // | "304" ; Section 10.3.5: Not Modified
    // | "305" ; Section 10.3.6: Use Proxy
    // | "307" ; Section 10.3.8: Temporary Redirect
    // | "400" ; Section 10.4.1: Bad Request
    // | "401" ; Section 10.4.2: Unauthorized
    // | "402" ; Section 10.4.3: Payment Required
    // | "403" ; Section 10.4.4: Forbidden
    // | "404" ; Section 10.4.5: Not Found
    // | "405" ; Section 10.4.6: Method Not Allowed
    // | "406" ; Section 10.4.7: Not Acceptable
    // | "407" ; Section 10.4.8: Proxy Authentication Required
    // | "408" ; Section 10.4.9: Request Time-out
    // | "409" ; Section 10.4.10: Conflict
    // | "410" ; Section 10.4.11: Gone
    // | "411" ; Section 10.4.12: Length Required
    // | "412" ; Section 10.4.13: Precondition Failed
    // | "413" ; Section 10.4.14: Request Entity Too Large
    // | "414" ; Section 10.4.15: Request-URI Too Large
    // | "415" ; Section 10.4.16: Unsupported Media Type
    // | "416" ; Section 10.4.17: Requested range not satisfiable
    // | "417" ; Section 10.4.18: Expectation Failed
    // | "500" ; Section 10.5.1: Internal Server Error
    // | "501" ; Section 10.5.2: Not Implemented
    // | "502" ; Section 10.5.3: Bad Gateway
    // | "503" ; Section 10.5.4: Service Unavailable
    // | "504" ; Section 10.5.5: Gateway Time-out
    // | "505" ; Section 10.5.6: HTTP Version not supported
    // **Response Header Fields**
    // response-header = Accept-Ranges ; Section 14.5
    // | Age ; Section 14.6
    // | ETag ; Section 14.19
    // | Location ; Section 14.30
    // | Proxy-Authenticate ; Section 14.33
    // **Entity Header Fields**
    // entity-header = Allow ; Section 14.7
    // | Content-Encoding ; Section 14.11
    // | Content-Language ; Section 14.12
    // | Content-Length ; Section 14.13
    // | Content-Location ; Section 14.14
    // | Content-MD5 ; Section 14.15
    // | Content-Range ; Section 14.16
    // | Content-Type ; Section 14.17
    // | Expires ; Section 14.21
    // | Last-Modified ; Section 14.29
    // | extension-header
}
