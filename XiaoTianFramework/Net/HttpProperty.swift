//
//  HttpProperty.swift
//  DriftBook
//  Http请求属性配置
//  Created by XiaoTian on 16/7/3.
//  Copyright © 2016年 XiaoTian. All rights reserved.
//

import Foundation

open class HttpProperty {
    open class HeaderProperty{
        // header fields
        open static let ACCEPT = "Accept";
        open static let ACCEPT_CHARSET = "Accept-Charset";
        open static let ACCEPT_ENCODING = "Accept-Encoding";
        open static let ACCEPT_LANGUAGE = "Accept-Language";
        open static let AUTHORIZATION = "Authorization";
        open static let FROM = "From";
        open static let HOST = "Host";
        open static let RANGE = "Range";
        open static let EXPECT = "Expect";
        open static let REFERER = "Referer";
        open static let USER_AGENT = "User-Agent";
        open static let MAX_FORWARDS = "Max-Forwards";
        open static let PROXY_AUTHORIZATION = "Proxy-Authorization";
        open static let TE = "TE";
        open static let IF_RANGE = "If-Range";
        open static let IF_MATCH = "If-Match";
        open static let IF_NONE_MATCH = "If-None-Match";
        open static let IF_MODIFIED_SINCE = "If-Modified-Since";
        open static let IF_UNMODIFIED_SINCE = "If-Unmodified-Since";
        // header fields for Entity
        open static let DATE = "Date";
        open static let ALLOW = "Allow";
        open static let EXPIRES = "Expires";
        open static let CHARSET = "Charset";
        open static let CONNECTION = "Connection";
        open static let CONTENT_MD5 = "Content-MD5";
        open static let CONTENT_TYPE = "Content-Type";
        open static let LAST_MODIFIED = "Last-Modified";
        open static let CONTENT_RANGE = "Content-Range";
        open static let CONTENT_LENGTH = "Content-Length";
        open static let CONTENT_ENCODING = "Content-Encoding";
        open static let CONTENT_LANGUAGE = "Content-Language";
        open static let CONTENT_LOCATION = "Content-Location";
        open static let CONTENT_DISPOSITION = "Content-Disposition";
        open static let CONTENT_TRANSFER_ENCODING = "Content-Transfer-Encoding";
        // Media
        open static let BOUNDARY = "boundary";
    }
    open class ContentType {
        open static let TEXT_PLAN = "text/plain";
        open static let TEXT_HTML = "text/html";
        open static let IMAGE_GIF = "image/gif";
        open static let IMAGE_PNG = "image/png";
        open static let IMAGE_JPG = "image/jpeg";
        open static let VIDEO_MPEG = "video/mpeg";
        open static let MESSAGE_HTTP = "message/http";
        open static let MESSAGE_RFC822 = "message/rfc822";
        open static let APPLICATION_PDF = "application/pdf";
        open static let APPLICATION_JSON = "application/json";
        open static let APPLICATION_WORD = "application/msword";
        open static let APPLICATION_XHTML = "application/xhtml+xml";
        open static let APPLICATION_WAP_HTML_10 = "application/vnd.wap.xhtml+xml";
        open static let APPLICATION_WAP_HTML_20 = "application/xhtml+xml";
        open static let APPLICATION_STREAM = "application/octet-stream";
        open static let MULTIPART_ALTERNATIVE = "multipart/alternative";
        open static let MULTIPART_FORM_DATA = "multipart/form-data";
        open static let MULTIPART_BYTERANGES = "multipart/byteranges";
        open static let APPLICATION_FORM_URLENCODEED = "application/x-www-form-urlencoded;charset=utf-8";
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
    open class TransferEncoding {
        open static let BIT_7 = "7bit"; // 7 BIT ASCII
        open static let BIT_8 = "8bit"; // 8 BIT ASCII
        open static let BINARY = "binary";
        open static let BASE64 = "base64";
        open static let QUOTED_PRINTABLE = "quoted-printable";
    }
    
    //
    open class Charset {
        open static let ASCII = "ASCII";
        open static let GBK = "GBK";
        open static let UTF_8 = "UTF-8";
    }
    
    //
    open class Method {
        open static let GET = "GET";
        open static let PUT = "PUT";
        open static let POST = "POST";
        open static let HEAD = "HEAD";
        open static let TRACE = "TRACE";
        open static let DELETE = "DELETE";
        open static let CONNECT = "CONNECT";
        open static let OPTIONS = "OPTIONS";
    }
    
    //
    open class Accept {
        open static let ALL = "*/*";
        open static let TEXT = "text/*";
        open static let TEXT_HTML = "text/html";
        open static let TEXT_HTML_level_1 = "text/html;level=1";
        open static let IMAGE = "image/*";
        open static let IMAGE_jpeg = "image/jpeg";
    }
    
    open class AcceptEncoding {
        open static let ALL = "*";
        open static let COMPRESS_GZIP = "compress, gzip";
    }
    
    open class ConetentEncoding {
        open static let GZIP = "gzip";
    }
    
    open class Date {
        open func current() -> String{
            let nowDouble = Foundation.Date().timeIntervalSince1970
            let millisecond = Int64(nowDouble * 1000)
            return String(millisecond)
        }
    }
    
    open class ETag {
        open static let XYZZY = "\"xyzzy\"";
        open static let WXYZZY = "W/\"xyzzy\"";
    }
    
    open class From {
        open static let ME = "gtrstudio@qq.com";
    }
    
    open class Host {
        open static let ME = "www.xiaotiangd.com";
    }
    
    open class UserAgent {
        open static let IE = "IntentExplorer";
        open static let Chrome = "Chrome";
        open static let IOS = "IOS";
        open static let CERN = "CERN-LineMode/2.15 libwww/2.17b3";
    }
    
    open class ContentTransferEncoding {
        open static let QUOTED_PRINTABLE = "quoted-printable";
        open static let BASE64 = "base64";
    }
    
    open class ContentDisposition {
        open static let ATTACHMENT_FILENAME = "attachment; filename=\"fname.ext\"";
    }
    
    open class Language {
        open static let EN = "en";
        open static let EN_US = "en-US";
        open static let CN = "cn";
        open static let ZH_CN = "zh-CN";
    }
    
    open class Connection {
        open static let KEEP_ALIVE = "keep-alive";
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
