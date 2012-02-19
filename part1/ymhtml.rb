#! /usr/local/bin/ruby -Ku

## ymHTML - Simple HTML Parser
## (c) 2003-2007 yoshidam
## You can redistribute it and/or modify it under the same term as Ruby.
##
## Nov 17, 2007 yoshidam version 0.1.13 Windows-1252
## Oct 30, 2006 yoshidam version 0.1.12 NKF, Iconv
## Sep 23, 2006 yoshidam version 0.1.11 comment end bug fix
## Apr 12, 2006 yoshidam version 0.1.10 forceHTML option
## Mar  7, 2006 yoshidam version 0.1.9 iso-2022-jp bug fix
## Nov 15, 2005 yoshidam version 0.1.8 table border
## Apr  6, 2004 yoshidam version 0.1.7 InputStream
## Mar 10, 2004 yoshidam version 0.1.6 exception, InputStream
## Sep 17, 2003 yoshidam version 0.1.5 bug fix
## Apr 05, 2003 yoshidam version 0.1.4
## Apr 04, 2003 yoshidam version 0.1.3
## Apr 02, 2003 yoshidam version 0.1.2
## Mar 27, 2003 yoshidam version 0.1.1
## Mar 26, 2003 yoshidam version 0.1.0

module YmHTML
  VERSION = 0.113

  class Error < StandardError
  end

  class ParseError < Error
  end

  class EncodingError < Error
  end

  class Parser
    HEAD_MISC = "script|style|meta|link|object"
    HEADING = "h1|h2|h3|h4|h5|h6"
    LIST = "ul|ol|dir|menu"
    PREFORMATTED = "pre"
    FONTSTYLE = "tt|i|b|u|s|strike|big|small"
    PHRASE = "em|strong|dfn|code|samp|kbd|var|cite|abbr|acronym"
    SPECIAL = "a|img|applet|object|font|basefont|br|script|map|q|sub|sup|span|bdo|iframe"
    FORMCTRL =  "input|select|textarea|label|button"
    INLINE = "#{FONTSTYLE}|#{PHRASE}|#{SPECIAL}|#{FORMCTRL}|ins|del"
    BLOCK = "p|#{HEADING}|#{LIST}|#{PREFORMATTED}|dl|div|center|noscript|noframes|blockquote|form|isindex|hr|table|fieldset|address|ins|del"
    FLOW  = "#{BLOCK}|#{INLINE}"
    EMPTY = ''

    ContentList = {}
    OpenElements = [
      ## ['omitted tag', 'outer', 'inner']
      ['html', nil, /^(head|body)$/u],
      ['head', 'html', /^(title|base|#{HEAD_MISC})$/u],
      ['body', 'html', /^(#{BLOCK}|script|ins|del)$/u],
      ['body', 'noframes', /^(#{BLOCK}|script|ins|del)$/u],
      ['tbody', 'table', /^tr$/],
      ## invalid omissions
      ['tr', 'tbody', /^td$/],
      ['dd', 'dl', /^(#{FLOW})$/],
      ['td', 'tr', /^(#{FLOW})$/],
      ['ul', proc {|p| p !~ /^(ul|ol|li)$/}, /^li$/],
    ]
    HAVE_PCDATA = /^(option|textarea|fieldset|title|#{FONTSTYLE}|#{PHRASE}|sub|sup|span|bdo|font|address|a|p|#{HEADING}|pre|q|dt|label|legend|caption|body|div|center|object|applet|blockquote|ins|del|dd|li|form|button|th|td|iframe|noscript)$/u
    ATTR_NAME = { 'table' => [
        ['frame',  /^(void|above|below|hsides|lhs|rhs|vsides|box|border)$/ ]
      ]
    }

    private

    def havePCDATA?(name)
      name =~ HAVE_PCDATA
    end
  
    def guessOmittedTag(parent, child)
      OpenElements.each do |e, p, c|
        if (c.is_a?(Regexp) && child =~ c) ||
            (c.is_a?(Proc) && c.call(child))
          if (p .nil? && parent.nil?) ||
              (p.is_a?(String) && p == parent) ||
              (p.is_a?(Proc) && p.call(parent))
            return [e]
          elsif !e.is_a?(Proc) && !c.is_a?(Proc)
            if ret = guessOmittedTag(parent, e)
              return ret.push(e)
            end
          end
        end
      end
      return nil
    end

    def self.setContentList(elements, content)
      elements.split('|').each do |name|
        ContentList[name] = Regexp.new("^(#{content})$", nil, 'u')
      end
    end

    setContentList(PHRASE, INLINE)
#    setContentList('body', "#{BLOCK}|script")
    setContentList('body', FLOW)
    setContentList('p', INLINE)
    setContentList('dt', INLINE)
    setContentList('dd', FLOW)
    setContentList('li', FLOW)
    setContentList('option', '')
    setContentList('thead', 'tr')
    setContentList('tfoot', 'tr')
    setContentList('tbody', 'tr')
    setContentList('colgroup', 'col')
    setContentList('tr', 'th|td')
    setContentList('th|td', FLOW)
    setContentList('head', "title|base|#{HEAD_MISC}")
    setContentList('html', "head|body|frameset")
    ## empty element
    setContentList('br|area|link|img|param|hr|input|col|base|meta|basefont|frame|isindex', '')
    ## elements which cannot omit end tag
    setContentList("#{FONTSTYLE}|#{PHRASE}", INLINE)
    setContentList('sub|sup|bdo|font', INLINE)
    setContentList('address', "#{INLINE}|p")
    setContentList('div|center', FLOW)
    setContentList('a', INLINE.sub(/\ba\|/, ''))
    setContentList('map', "#{BLOCK}|area")
    setContentList('object|applet', "param|#{FLOW}")
    setContentList(HEADING, INLINE)
    setContentList('pre', INLINE)
    setContentList('q', INLINE)
    setContentList('blockquote|ins|del', FLOW)
    setContentList('dl', 'dt|dd')
    setContentList('ol|ul|dir|menu', 'li')
    setContentList('form', FLOW)
    setContentList('label', INLINE)
    setContentList('select', 'optgroup|option')
    setContentList('optgroup', 'option')
    setContentList('textarea', '')
    setContentList('fieldset', "legend|#{FLOW}")
    setContentList('legend|caption', INLINE)
    setContentList('button', FLOW)
    setContentList('table', 'caption|col|colgroup|thead|tfoot|tbody')
    setContentList('frameset', 'frameset|frame|noframes')
    setContentList('iframe', FLOW)
    setContentList('noframes', "body|#{FLOW}")
    setContentList('title', '')
    setContentList('style|script', '')
    setContentList('noscript', FLOW)

    def normalizeAttrValue(str)
      str.gsub(/[\x9\r\n]/u, ' ')
    end

    ## expand entityRef/charRef in context text
    def expandRef(text = nil)
      return '' if text.nil?
      ret = []
      ret.taint if text.tainted?
      while text =~ /\&[\#0-9a-zA-Z]+\;?/u
        before = Regexp.last_match.pre_match
        ref = Regexp.last_match[0]
        text = Regexp.last_match.post_match
        ret.push(before) if before != ''
        if ref =~ /^\&\#(\d+);?$/u
          ## Numeric Character Reference (Decimal)
          ref = [$1.to_i].pack("U")
        elsif ref =~ /^\&\#x([0-9a-fA-F]+);?$/u
          ## Numeric Character Reference (Hexadecimal)
          ref = [$1.hex].pack("U")
        elsif !@xhtmlp && ref =~ /^\&\#X([0-9a-fA-F]+);?$/u
          ## Numeric Character Reference (Hexadecimal)
          ref = [$1.hex].pack("U")
        else
          ## Entity Reference
#          if !checkNameChar(ref.gsub(/\A\&([\#0-9a-zA-Z]+);?\Z/u, '\1'))
#            raise ParseError.new("illegal entity reference: #{ref.inspect}")
#          end
          ref = expandRef(getEntity(ref)) ##   expand recursively
        end
        ret.push(ref)
      end  ## end of while
      ret.push(text) if text != ''
      ret.join('')
    end

    ## expand entityRef/charRef in attribute value
    def expandAttrValue(text = nil)
      return '' if text.nil?
      ret = []
      ret.taint if text.tainted?
      text = normalizeAttrValue(text)
      while text =~ /\&[\#0-9a-zA-Z]+\;?/u
        before = Regexp.last_match.pre_match
        ref = Regexp.last_match[0]
        text = Regexp.last_match.post_match
        ret.push(before) if before != ''
        if ref =~ /^\&\#(\d+);?$/u
          ## Numeric Character Reference (Decimal)
          ref = [$1.to_i].pack("U")
        elsif ref =~ /^\&\#x([0-9a-fA-F]+);?$/u
          ## Numeric Character Reference (Hexadecimal)
          ref = [$1.hex].pack("U")
        elsif !@xhtmlp && ref =~ /^\&\#X([0-9a-fA-F]+);?$/u
          ## Numeric Character Reference (Hexadecimal)
          ref = [$1.hex].pack("U")
        else
          ## Entity Reference
#          if !checkNameChar(ref.gsub(/\A\&([\#0-9a-zA-Z]+);?\Z/u, '\1'))
#            raise ParseError.new("illegal entity reference: #{ref.inspect}")
#          end
          ref = expandAttrValue(getEntity(ref)) ##   expand recursively
        end
        ret.push(ref)
      end  ## end of while
      ret.push(text) if text != ''
      ret.join('')
    end


    def registerEntity(entname, entval)
      if @entity[entname].nil?
        @entity[entname] = entval
      end
    end

    def getEntity(entname)
      name = entname.sub(/^\&?([\#0-9a-zA-Z]+)\;?$/u, '\1')
      if !@entity[name].nil?
        return @entity[name]
      end
      if @xhtmlp
        raise ParseError.new("undeclarated entity reference: #{entname.inspect}")
      end
      entname.sub(/&/, '&#38;')
    end


    def initialize(encoding = nil)
      @content = ''
      @pos = -1
      @entity = {}
      @encoding = encoding ? encoding.downcase : nil
      @forceHTML = false
      @xhtmlp = false
      @eliminateWhiteSpace = false

      registerEntity("quot", "&#34;")
      registerEntity("amp", "&#38;")
      registerEntity("lt", "&#60;")
      registerEntity("gt", "&#62;")
      registerEntity("apos", "&#39;")

      registerEntity("nbsp", "&#160;")
      registerEntity("iexcl", "&#161;")
      registerEntity("cent", "&#162;")
      registerEntity("pound", "&#163;")
      registerEntity("curren", "&#164;")
      registerEntity("yen", "&#165;")
      registerEntity("brvbar", "&#166;")
      registerEntity("sect", "&#167;")
      registerEntity("uml", "&#168;")
      registerEntity("copy", "&#169;")
      registerEntity("ordf", "&#170;")
      registerEntity("laquo", "&#171;")
      registerEntity("not", "&#172;")
      registerEntity("shy", "&#173;")
      registerEntity("reg", "&#174;")
      registerEntity("macr", "&#175;")
      registerEntity("deg", "&#176;")
      registerEntity("plusmn", "&#177;")
      registerEntity("sup2", "&#178;")
      registerEntity("sup3", "&#179;")
      registerEntity("acute", "&#180;")
      registerEntity("micro", "&#181;")
      registerEntity("para", "&#182;")
      registerEntity("middot", "&#183;")
      registerEntity("cedil", "&#184;")
      registerEntity("sup1", "&#185;")
      registerEntity("ordm", "&#186;")
      registerEntity("raquo", "&#187;")
      registerEntity("frac14", "&#188;")
      registerEntity("frac12", "&#189;")
      registerEntity("frac34", "&#190;")
      registerEntity("iquest", "&#191;")
      registerEntity("Agrave", "&#192;")
      registerEntity("Aacute", "&#193;")
      registerEntity("Acirc", "&#194;")
      registerEntity("Atilde", "&#195;")
      registerEntity("Auml", "&#196;")
      registerEntity("Aring", "&#197;")
      registerEntity("AElig", "&#198;")
      registerEntity("Ccedil", "&#199;")
      registerEntity("Egrave", "&#200;")
      registerEntity("Eacute", "&#201;")
      registerEntity("Ecirc", "&#202;")
      registerEntity("Euml", "&#203;")
      registerEntity("Igrave", "&#204;")
      registerEntity("Iacute", "&#205;")
      registerEntity("Icirc", "&#206;")
      registerEntity("Iuml", "&#207;")
      registerEntity("ETH", "&#208;")
      registerEntity("Ntilde", "&#209;")
      registerEntity("Ograve", "&#210;")
      registerEntity("Oacute", "&#211;")
      registerEntity("Ocirc", "&#212;")
      registerEntity("Otilde", "&#213;")
      registerEntity("Ouml", "&#214;")
      registerEntity("times", "&#215;")
      registerEntity("Oslash", "&#216;")
      registerEntity("Ugrave", "&#217;")
      registerEntity("Uacute", "&#218;")
      registerEntity("Ucirc", "&#219;")
      registerEntity("Uuml", "&#220;")
      registerEntity("Yacute", "&#221;")
      registerEntity("THORN", "&#222;")
      registerEntity("szlig", "&#223;")
      registerEntity("agrave", "&#224;")
      registerEntity("aacute", "&#225;")
      registerEntity("acirc", "&#226;")
      registerEntity("atilde", "&#227;")
      registerEntity("auml", "&#228;")
      registerEntity("aring", "&#229;")
      registerEntity("aelig", "&#230;")
      registerEntity("ccedil", "&#231;")
      registerEntity("egrave", "&#232;")
      registerEntity("eacute", "&#233;")
      registerEntity("ecirc", "&#234;")
      registerEntity("euml", "&#235;")
      registerEntity("igrave", "&#236;")
      registerEntity("iacute", "&#237;")
      registerEntity("icirc", "&#238;")
      registerEntity("iuml", "&#239;")
      registerEntity("eth", "&#240;")
      registerEntity("ntilde", "&#241;")
      registerEntity("ograve", "&#242;")
      registerEntity("oacute", "&#243;")
      registerEntity("ocirc", "&#244;")
      registerEntity("otilde", "&#245;")
      registerEntity("ouml", "&#246;")
      registerEntity("divide", "&#247;")
      registerEntity("oslash", "&#248;")
      registerEntity("ugrave", "&#249;")
      registerEntity("uacute", "&#250;")
      registerEntity("ucirc", "&#251;")
      registerEntity("uuml", "&#252;")
      registerEntity("yacute", "&#253;")
      registerEntity("thorn", "&#254;")
      registerEntity("yuml", "&#255;")


      registerEntity("fnof", "&#402;")
      registerEntity("Alpha", "&#913;")
      registerEntity("Beta", "&#914;")
      registerEntity("Gamma", "&#915;")
      registerEntity("Delta", "&#916;")
      registerEntity("Epsilon", "&#917;")
      registerEntity("Zeta", "&#918;")
      registerEntity("Eta", "&#919;")
      registerEntity("Theta", "&#920;")
      registerEntity("Iota", "&#921;")
      registerEntity("Kappa", "&#922;")
      registerEntity("Lambda", "&#923;")
      registerEntity("Mu", "&#924;")
      registerEntity("Nu", "&#925;")
      registerEntity("Xi", "&#926;")
      registerEntity("Omicron", "&#927;")
      registerEntity("Pi", "&#928;")
      registerEntity("Rho", "&#929;")
      registerEntity("Sigma", "&#931;")
      registerEntity("Tau", "&#932;")
      registerEntity("Upsilon", "&#933;")
      registerEntity("Phi", "&#934;")
      registerEntity("Chi", "&#935;")
      registerEntity("Psi", "&#936;")
      registerEntity("Omega", "&#937;")
      registerEntity("alpha", "&#945;")
      registerEntity("beta", "&#946;")
      registerEntity("gamma", "&#947;")
      registerEntity("delta", "&#948;")
      registerEntity("epsilon", "&#949;")
      registerEntity("zeta", "&#950;")
      registerEntity("eta", "&#951;")
      registerEntity("theta", "&#952;")
      registerEntity("iota", "&#953;")
      registerEntity("kappa", "&#954;")
      registerEntity("lambda", "&#955;")
      registerEntity("mu", "&#956;")
      registerEntity("nu", "&#957;")
      registerEntity("xi", "&#958;")
      registerEntity("omicron", "&#959;")
      registerEntity("pi", "&#960;")
      registerEntity("rho", "&#961;")
      registerEntity("sigmaf", "&#962;")
      registerEntity("sigma", "&#963;")
      registerEntity("tau", "&#964;")
      registerEntity("upsilon", "&#965;")
      registerEntity("phi", "&#966;")
      registerEntity("chi", "&#967;")
      registerEntity("psi", "&#968;")
      registerEntity("omega", "&#969;")
      registerEntity("thetasym", "&#977;")
      registerEntity("upsih", "&#978;")
      registerEntity("piv", "&#982;")
      registerEntity("bull", "&#8226;")
      registerEntity("hellip", "&#8230;")
      registerEntity("prime", "&#8242;")
      registerEntity("Prime", "&#8243;")
      registerEntity("oline", "&#8254;")
      registerEntity("frasl", "&#8260;")
      registerEntity("weierp", "&#8472;")
      registerEntity("image", "&#8465;")
      registerEntity("real", "&#8476;")
      registerEntity("trade", "&#8482;")
      registerEntity("alefsym", "&#8501;")
      registerEntity("larr", "&#8592;")
      registerEntity("uarr", "&#8593;")
      registerEntity("rarr", "&#8594;")
      registerEntity("darr", "&#8595;")
      registerEntity("harr", "&#8596;")
      registerEntity("crarr", "&#8629;")
      registerEntity("lArr", "&#8656;")
      registerEntity("uArr", "&#8657;")
      registerEntity("rArr", "&#8658;")
      registerEntity("dArr", "&#8659;")
      registerEntity("hArr", "&#8660;")
      registerEntity("forall", "&#8704;")
      registerEntity("part", "&#8706;")
      registerEntity("exist", "&#8707;")
      registerEntity("empty", "&#8709;")
      registerEntity("nabla", "&#8711;")
      registerEntity("isin", "&#8712;")
      registerEntity("notin", "&#8713;")
      registerEntity("ni", "&#8715;")
      registerEntity("prod", "&#8719;")
      registerEntity("sum", "&#8721;")
      registerEntity("minus", "&#8722;")
      registerEntity("lowast", "&#8727;")
      registerEntity("radic", "&#8730;")
      registerEntity("prop", "&#8733;")
      registerEntity("infin", "&#8734;")
      registerEntity("ang", "&#8736;")
      registerEntity("and", "&#8743;")
      registerEntity("or", "&#8744;")
      registerEntity("cap", "&#8745;")
      registerEntity("cup", "&#8746;")
      registerEntity("int", "&#8747;")
      registerEntity("there4", "&#8756;")
      registerEntity("sim", "&#8764;")
      registerEntity("cong", "&#8773;")
      registerEntity("asymp", "&#8776;")
      registerEntity("ne", "&#8800;")
      registerEntity("equiv", "&#8801;")
      registerEntity("le", "&#8804;")
      registerEntity("ge", "&#8805;")
      registerEntity("sub", "&#8834;")
      registerEntity("sup", "&#8835;")
      registerEntity("nsub", "&#8836;")
      registerEntity("sube", "&#8838;")
      registerEntity("supe", "&#8839;")
      registerEntity("oplus", "&#8853;")
      registerEntity("otimes", "&#8855;")
      registerEntity("perp", "&#8869;")
      registerEntity("sdot", "&#8901;")
      registerEntity("lceil", "&#8968;")
      registerEntity("rceil", "&#8969;")
      registerEntity("lfloor", "&#8970;")
      registerEntity("rfloor", "&#8971;")
      registerEntity("lang", "&#9001;")
      registerEntity("rang", "&#9002;")
      registerEntity("loz", "&#9674;")
      registerEntity("spades", "&#9824;")
      registerEntity("clubs", "&#9827;")
      registerEntity("hearts", "&#9829;")
      registerEntity("diams", "&#9830;")

##      registerEntity("quot", "&#34;")
##      registerEntity("amp", "&#38;#38;")
##      registerEntity("lt", "&#38;#60;")
##      registerEntity("gt", "&#62;")
##      registerEntity("apos", "&#39;")
      registerEntity("OElig", "&#338;")
      registerEntity("oelig", "&#339;")
      registerEntity("Scaron", "&#352;")
      registerEntity("scaron", "&#353;")
      registerEntity("Yuml", "&#376;")
      registerEntity("circ", "&#710;")
      registerEntity("tilde", "&#732;")
      registerEntity("ensp", "&#8194;")
      registerEntity("emsp", "&#8195;")
      registerEntity("thinsp", "&#8201;")
      registerEntity("zwnj", "&#8204;")
      registerEntity("zwj", "&#8205;")
      registerEntity("lrm", "&#8206;")
      registerEntity("rlm", "&#8207;")
      registerEntity("ndash", "&#8211;")
      registerEntity("mdash", "&#8212;")
      registerEntity("lsquo", "&#8216;")
      registerEntity("rsquo", "&#8217;")
      registerEntity("sbquo", "&#8218;")
      registerEntity("ldquo", "&#8220;")
      registerEntity("rdquo", "&#8221;")
      registerEntity("bdquo", "&#8222;")
      registerEntity("dagger", "&#8224;")
      registerEntity("Dagger", "&#8225;")
      registerEntity("permil", "&#8240;")
      registerEntity("lsaquo", "&#8249;")
      registerEntity("rsaquo", "&#8250;")
      registerEntity("euro", "&#8364;")
    end

    ## parse token
    def nextToken
      token = ''
      if @xhtmlp
        elementpat = /[\<\>\[\]\=\/]/u
      else
        elementpat = /[\<\>\[\]\=]/u
      end

      while !(c = @content[@pos, 1]).nil?
        if c == ''
          ## EOF
          return token if token != ''
          return nil
        elsif c ==  '-' && token == '<!-'
          ## Comment
          commentpos = @content.index(/--[ \t\n\r]>/u, @pos + 1)
          raise ParseError.new("comment parse error") unless commentpos
          @content[commentpos..-1] =~ /--[ \t\n\r]>/u
          len = $&.length
          token += @content[@pos, commentpos - @pos + len]
          @pos = commentpos + len
          return token
        elsif c ==  '-' && token == '-'
          ## Comment in decl
          commentpos = @content.index(/--/u, @pos + 1)
          raise ParseError.new("comment parse error") unless commentpos
          token += @content[@pos, commentpos - @pos + 2]
          @pos = commentpos + 2
          return token
        elsif c == '?' && token == '<'
          ## PI
          pipos = @content.index("?>", @pos + 1)
          raise ParseError.new("PI parse error") unless pipos
          token += @content[@pos, pipos - @pos + 2]
          @pos = pipos + 2
          return token
        elsif c =~ /[ \t\n\r]/u
          ## White Space
          return token if token != ''
          @pos += 1
          next
        elsif c =~ elementpat
          ## Element
          return token if token != ''
          if c == '=' || c == '>'
            @pos += 1
            return c
          end
          @pos += 1
          token = c
          next
        ## Literal
        elsif token == '' && (c == '"' || c == "'")
          quotpos = @content.index(c, @pos + 1)
          raise ParseError.new("literal parse error") unless quotpos
          token = @content[@pos, quotpos - @pos + 1]
          @pos = quotpos + 1
          return token
        ## Others
        else
          token += c
          @pos += 1
          next
        end
      end

      nil
    end

    def checkNameChar(str)
      str =~ /\A([^\W0-9]|:)[\w\.\-:]*\Z/u
    end


    ## parse DTD
    def parseDTD(dtd)
      @pos -= dtd.length
      start = @pos

      if (token = nextToken) != '<!DOCTYPE'
        raise ParseError.new("DOCTYPE parse error: #{token.inspect}")
      end
      doctype = nextToken
      if (token = nextToken) == 'SYSTEM'
        extid = nextToken
        token = nextToken
      elsif token == 'PUBLIC'
        pubid = nextToken
        token = nextToken
        if token != '>' && token != '['
          extid = token
          token = nextToken
        end
      end
      ## skip internel DTD subset
      if token == '['
        while (token = nextToken)
          if token == ']'
            token = nextToken
            break
          end
        end
      end
      if token != '>'
        raise ParseError.new("DOCTYPE parse error")
      end
      if !@forceHTML && pubid =~ /^[\"\']-\/\/W3C\/\/DTD XHTML /
        @xhtmlp = true
      end
#      p [doctype, pubid, extid]
      @content[start + 1, @pos - start - 2] ## chop the first '<' and
                                            ## the last  '>'
    end

    def isEmptyElement(name)
      return false if @xhtmlp
      name =~ /^(br|area|link|img|param|hr|input|col|base|meta|basefont|frame|isindex)$/
    end

    def isCdataElement(name)
      return false if @xhtmlp
      name =~ /^(style|script)$/
    end

    ## parse Element start tag
    def parseElementStartTag(elem)
      empty = nil
      attrs = {}
      rawattrs = {}

      ## rewind
      @pos -= elem.length
      start = @pos

      name = nextToken
      if !checkNameChar(name)
        ## rollback
        @pos = start
        return nil
#        raise ParseError.new("illegal element name: #{name.inspect}")
      end
      name.downcase! unless @xhtmlp

      token = nextToken
      while !token.nil?
        break if token == '>'
        if token == '/'  ## empty element tag
          token = nextToken
          if token != '>'
            ## rollback
            @pos = start
            return nil
#            raise ParseError.new("element parse error")
          end
          empty = 1
          break
        end
        attrname = token
#        if !checkNameChar(attrname)
#          raise ParseError.new("illegal attribute name: #{attrname.inspect}")
#        end
        attrname.downcase! unless @xhtmlp
        token = nextToken
        if token != '='
          raise ParseError.new("attribute parse error") if @xhtmlp
          attrvalue = attrname
          if ATTR_NAME[name]
            for n, v in ATTR_NAME[name]
              if attrvalue =~ v
                attrname = n
                break
              end
            end
          end
        else
          attrvalue = nextToken
          token = nextToken
        end
        if attrvalue !~ /\A([\'\"]?)([\w\W]*)\1\Z/u
          raise ParseError.new("attribute parse error: #{attrvalue.inspect}")
        end
#        if attrs.include?(attrname)
#          raise ParseError.new("dupulicate attribute: #{attrname.inspect}")
#        end
        attrs[attrname] = expandAttrValue($2)
        if @eliminateWhiteSpace
          attrs[attrname].gsub!(/[ \x9\n]+/, ' ')
          attrs[attrname].gsub!(/\A +| +\z/, '')
        end
        rawattrs[attrname] = attrvalue
      end
      empty = 1 if isEmptyElement(name)
      [name, attrs, empty, rawattrs]
    end

    def expect(key, include = 0)
      token = nil

      pos = @content.index(key, @pos)
      if pos.nil?
        token = @content[@pos..-1]
        @pos = -1
        return token
      elsif key.is_a?(Regexp) && include > 0
        @content[pos..-1] =~ key
        include = $&.length
      end
      token = @content[@pos, pos - @pos + include]
      @pos = pos + include
      token
    end


    def parseTag(e = nil)
      c = @content[@pos, 1]
      if !e.nil?
        token = expect(Regexp.new(e, 'i', 'u'), 0)
        return [:CDATA, token]
      elsif c == '<'
        ## Markup
        token = expect(">", 1)
        if token[-1, 1] != '>'
          return [:MARKUP, nil]
        end
        return [:MARKUP, token]
      else
        ## CharData
        return [:PCDATA, expect("<")]
      end
    end

    def normalizeLineBreak(str)
      return nil unless str
      str.gsub(/\x0d\x0a|\x0d/u, "\x0a")
    end

    def checkContent(parent, child)
      return true unless ContentList.include?(child)
      return true unless ContentList.include?(parent)
      return true if child =~ ContentList[parent]
      false
    end


    def doPreParseProcessing
      ## normalize line break
      @content[@pos..-1] = normalizeLineBreak(@content[@pos..-1])
    end


    public

    attr_accessor :eliminateWhiteSpace
    attr_accessor :forceHTML


    ZenkakuChar = [0x3000, ?-, 0x9fff, 0xf900, ?-, 0xfaff]
    IgnorableSpaces = /([#{ZenkakuChar.pack('U*')}])\n+([#{ZenkakuChar.pack('U*')}])/u

    def parse(content, &block)
      @content = content
      if !content.is_a?(InputStream) && content.respond_to?('read')
        @content = InputStream.new(content)
      end
      @block = block
      @pos = 0
      estack = []

      if @content.nil?
        return 0
      end

      if @encoding && @content.is_a?(InputStream)
        @content.setEncoding(@encoding)
      end

      lastContent = nil
      nextContent = nil
      while @pos >= 0
        ttype, part = parseTag(nextContent)
        oldpart = part
        nextContent = nil
        if part.nil?
          raise ParseError.new("unexpected EOF")
        elsif ttype == :PCDATA
          ## #PCDATA
          if !lastContent
            doPreParseProcessing
            part = normalizeLineBreak(part)
          end
          lastContent = :PCDATA
          if estack.length == 0
           next if part =~ /\A[ \x9\r\n]*\Z/u
            raise ParseError.new("cdata must be in document element: #{part.inspect}")
          end
          if !havePCDATA?(estack[-1])
            next if part =~ /\A[ \x9\r\n]*\Z/u
#            raise ParseError.new("cannot have #PCDATA in #{estack[-1]}")
          end
          part = expandRef(part)
          if @eliminateWhiteSpace && estack[-1] != 'pre'
            part.gsub!(IgnorableSpaces, '\1\2')
            part.gsub!(/[ \x9\n]+/, ' ')
            part.gsub!(/\A +| +\z/, '')
          end
          if part != ''
            if block_given?
              @block.call(:CDATA, nil, part)
            else
              character(part)
            end
          end
          next
        elsif ttype == :CDATA
          lastContent = :CDATA
          ## CDATA
          if block_given?
            @block.call(:CDATA, nil, part)
          else
            character(part)
          end
          next
        else
          first = part[1]
          if first == ?? && part =~ /\A<\?xml[ \t\n\r\?]/u && lastContent.nil?
            ## XML Declaration
            if (part =~ /\A<\?xml([ \t\n\r]+version[ \t\n\r]*=[ \t\n\r]*(['"])([a-zA-Z0-9_.:\-]+)\2)?([ \t\n\r]+encoding[ \t\n\r]*=[ \t\n\r]*(['"])(.*?)\5)?([ \t\n\r]+standalone[ \t\n\r]*=[ \t\n\r]*(['"])(yes|no)\8)?[ \t\n\r]*\?>/u) != 0
              raise ParseError.new("illegal XML declaration")
            end
            @xhtmlp = true if !@forceHTML
            version = $3
            encoding = $6
            standalone = $9

            if !version
              raise ParseError.new("invalid XML declaration")
            end
            if  version != '1.0' && version != '1.1'
              raise ParseError.new("version #{version} not supported")
            end

            if block_given?
              @block.call(:XML_DECL, nil, [version, encoding, standalone])
            else
              xmlDecl(version, encoding, standalone)
            end
            if encoding && @content.is_a?(InputStream)
              @content.setEncoding(encoding.downcase)
            end
            next
          end

          ## pre-parse processing after XML Declaration
          if !lastContent ||
              lastContent == :XML_DECL
            doPreParseProcessing
            part = normalizeLineBreak(part)
            next if lastContent
          end

          if first == ??
            ## Processing Instruction
            lastContent = :PI
            if part !~ /\?>\Z/u
              part += expect("?>", 2)
              if part !~ /\?>\Z/u
                raise ParseError.new("processing instruction data expected")
              end
            end
            part = part[2..-3] ## strip "<?" and "?>"
            part =~ /\A([^ \t\n\r]+)([ \t\n\r]+(.*))?\Z/mu
            name = $1
            data = $3.to_s
            if @xhtmlp && name =~ /\Axml\z/i
              raise ParseError.new("illegal PI name: #{name.inspect}")
            end
              ##!!! chack name
            if block_given?
              @block.call(:PI, name, data)
              else
              processingInstruction(name, data)
            end
            next
          elsif first == ?!
            if part =~ /\A<!--/u
              ## Comment
              lastContent = :COMMENT
              if part !~ /--([ \t\n\r]*>)\Z/u
                part += expect(/--[ \t\n\r]*>/u, 3)
              end
              if @xhtmlp && part !~ /-->\Z/u
                raise ParseError.new("comment must end with \"-->\"")
              end
              part =~ /\A<!--([\s\S]*)--[ \t\n\r]*>\Z/u
              part = $1
              if @xhtmlp && part =~ /--/u
                raise ParseError.new("comment must not contain '--'")
              end
              if block_given?
                @block.call(:COMMENT, nil, part)
              else
                comment(part)
              end
              next
            elsif part =~ /\A<!DOCTYPE/u
              ## Document type declaration
              lastContent = :DTD
              part = parseDTD(part)
              ## dtdHandler(part) if !part.nil?
              next
            elsif @xhtmlp && part =~ /\A<!\[CDATA\[/u
              if estack.length == 0
                raise ParseError.new("cdata must be in document element")
              end
              ## CDATA Section
              lastContent = :CDATA
              if part !~ /\]\]>\Z/u
                part += expect("]]>", 3)
                if part !~ /\]\]>\Z/u
                  raise ParseError.new("\"<![CDATA[\" must end with \"]]>\"")
                end
              end
              part = part[9..-4]
              if block_given?
                @block.call(:CDATA, nil, part)
              else
                character(part)
              end
              next
            else
#              raise ParseError.new("unknown markup: #{part.inspect}")
            end
          else
            ## Element
            lastContent = :ELEMENT
            name = nil
            attrs = nil
            rawattrs = nil
            empty = nil
            endTagP = nil

            if part =~ /\A<\//u
              ## element end tag
              name = part
              name.downcase! unless @xhtmlp
              name.sub!(/\A<\/([^ \t\n\r]+)[ \t\n\r]*>\Z/u, '\1')
              endTagP = 1
              ## end tag in document root
              if estack.length == 0
                if @xhtmlp
                  raise ParseError.new("not opened end tag: #{name.inspect}")
                end
                ## !!! INVALID !!!
                estack.push(name)
                if block_given?
                  @block.call(:START_ELEM, name, {})
                else
                  startElement(name, {})
                end
              end
              ## unmatch end tag
              if name != (e = estack.pop)
                if @xhtmlp
                  raise ParseError.new("not opened end tag: #{name.inspect}")
                end

                if !estack.include?(name)
                  estack.push(e)
                  if block_given?
                    @block.call(:START_ELEM, name, {})
                  else
                    startElement(name, {})
                  end
                else
                  ## insert omitted end tags
                  while true
                    break if e == name
                    if block_given?
                      @block.call(:END_ELEM, e, nil)
                    else
                      endElement(e)
                    end
                    e = estack.pop
                  end
                end
              end
            elsif part =~ /\A<[a-zA-Z]+/u
              ## element start tag
              name, attrs, empty, rawattrs = parseElementStartTag(oldpart[1..-1])
              if name.nil?
                if block_given?
                  @block.call(:CDATA, nil, '<')
                else
                  character('<')
                end
                next
              end

              if @xhtmlp
#                if !checkContent(estack[-1], name)
#                  raise ParseError.new("illegal element #{name.inspect} in #{estack[-1].inspect}")
#                end
              else
                if (tags = guessOmittedTag(estack[-1], name))
                  ## insert omitted start tags
                  tags.each do |n|
                    estack.push(n)
                    if block_given?
                      @block.call(:START_ELEM, n, {})
                    else
                      startElement(n, {})
                    end
                  end
                else
                  ## insert omitted end tags
                  while !checkContent(estack[-1], name) &&
                      estack[-1] !~ /^(html|body)$/
                    if block_given?
                      @block.call(:END_ELEM, estack[-1], nil)
                    else
                      endElement(estack[-1])
                    end
                    estack.pop
                  end
                end
                ## insert omitted start tags
                if (tags = guessOmittedTag(estack[-1], name))
                  tags.each do |n|
                    estack.push(n)
                    if block_given?
                      @block.call(:START_ELEM, n, {})
                    else
                      startElement(n, {})
                    end
                  end
                end
              end
              estack.push(name) if !empty
              ## change encoding
              if @content.is_a?(InputStream) && name == 'meta' &&
                  attrs['http-equiv'] =~ /^content-type$/iu &&
                  attrs['content'] =~ /\bcharset[ \t\n\r]*=[ \t\n\r]*([a-zA-z0-9\-_]+)\b/
                @content.setEncoding($1.downcase)
              end
              if block_given?
                @block.call(:START_ELEM, name, attrs)
              else
                startElement(name, attrs)
              end
            else
              ## illegal markup
              part = expandRef(part)
              if block_given?
                @block.call(:CDATA, nil, part)
              else
                character(part)
              end
              next
            end
            if empty || endTagP
              if block_given?
                @block.call(:END_ELEM, name, nil)
              else
                endElement(name)
              end
              next
            elsif isCdataElement(name)
              ## style and script element
              nextContent = "</#{name}"
              next
            end
            next
          end
#          p [ttype, part]
        end
      end

      if estack.length > 0
        if @xhtmlp
          raise ParseError.new("unclosed element: #{estack.pop.inspect}")
        end
        estack.reverse_each do |name|
          if block_given?
            @block.call(:END_ELEM, name, nil)
          else
            endElement(name)
          end
        end
      end
    end

    ## stop to parse
    def stop
      @pos = -1
    end

    def getPos
      @pos
    end

    def getLine
      @content[0, @pos].count("\n")
    end

    ##
    ## Default handler
    ##

    protected

    def character(text)
    end

    def xmlDecl(version, encoding, standalone)
    end

    def processingInstruction(name, data)
    end

    def comment(data)
    end

    def startElement(name, attrs)
    end

    def endElement(name)
    end

  end



  class InputStream
    attr_reader :uri

    CP1252_TO_UCS =
      [0x20ac, 0xfffd, 0x201a, 0x0192, 0x201e, 0x2026, 0x2020, 0x2021,
       0x02c6, 0x2030, 0x0160, 0x2039, 0x0152, 0xfffd, 0x017d, 0xfffd,
       0xfffd, 0x2018, 0x2019, 0x201c, 0x201d, 0x2022, 0x2013, 0x2014,
       0x02dc, 0x2122, 0x0161, 0x203a, 0x0153, 0xfffd, 0x017e, 0x0178]

    def combineSurrogatePair(ary)
      i = 0
      len = ary.length
      ret = []
      while i < len
        c = ary[i]
        if c >= 0xd800 && c <= 0xdbff &&
            i + 1 < len && ary[i+1] >= 0xdc00 && ary[i+1] <= 0xdfff
          i += 1
          low = ary[i]
          c = (((c & 1023)) << 10 | (low & 1023)) + 0x10000
        end
        ret << c
        i += 1
      end
      ret
    end
    private :combineSurrogatePair

    def initialize(stream, encoding = nil, &block)
      @encoding = encoding ? encoding.downcase : nil
      @block = block
      @autodetectedEncoding = nil
      @uri = nil
      if stream.is_a?(String)
        @content = stream
      else
        @content = stream.read
      end
      taintp = @content.tainted?
      ## auto encoding detection
      if @encoding.nil?
        if @content.length >= 4
          if @content[0] == 0xff && @content[1] == 0xfe &&
              @content[2] != 0
            ## UTF-16 (LE)
            @content = combineSurrogatePair(@content[2..-1].unpack('v*')).pack('U*')
            @autodetectedEncoding = 'utf-16'
          elsif @content[0] == 0xfe && @content[1] == 0xff &&
              @content[3] != 0
            ## UTF-16 (BE)
            @content = combineSurrogatePair(@content[2..-1].unpack('n*')).pack('U*')
            @autodetectedEncoding = 'utf-16'
          elsif @content[0..3] == "<\0?\0"
            ## UTF-16LE
            @content = combineSurrogatePair(@content.unpack('v*')).pack('U*')
            @autodetectedEncoding = 'utf-16le'
          elsif @content[0..3] == "\0<\0?"
            ## UTF-16BE
            @content = combineSurrogatePair(@content.unpack('n*')).pack('U*')
            @autodetectedEncoding = 'utf-16be'
          elsif @content[0] == 0xff && @content[1] == 0xfe &&
              @content[2] == 0 && @content[3] == 0
            ## UTF-32 (LE)
            @content = @content[4..-1].unpack('V*').pack('U*')
            @autodetectedEncoding = 'utf-32'
          elsif @content[0] == 0 && @content[1] == 0 &&
              @content[2] == 0xfe && @content[3] == 0xff
            ## UTF-32 (BE)
            @content = @content[4..-1].unpack('N*').pack('U*')
            @autodetectedEncoding = 'utf-32'
          elsif @content[0..7] == "<\0\0\0?\0\0\0"
            ## UTF-32LE
            @content = @content.unpack('V*').pack('U*')
            @autodetectedEncoding = 'utf-32le'
          elsif @content[0..7] == "\0\0\0<\0\0\0?"
            ## UTF-32BE
            @content = @content.unpack('N*').pack('U*')
            @autodetectedEncoding = 'utf-32be'
          elsif @content[0] == 0xef && @content[1] == 0xbb &&
              @content[2] == 0xbf
            ## UTF-8 (BOM)
            @content = @content[3..-1]
            @autodetectedEncoding = 'utf-8'
          elsif @content[0..3] == "\x4c\x6f\xa7\x94" ||
              @content[0..3] == "\x4c\x6f\xb7\x75" ||
              @content[0..3] == "\x4c\x6f\xab\x73"
#          elsif @content[0] == 0x4c && @content[1] == 0x6f &&
#              @content[2] == 0xa7 && @content[3] == 0x94
            raise EncodingError.new("EBCDIC not supported")
          end
        end

      elsif @encoding == 'us-ascii'
        ## no conversion
      elsif @encoding == 'utf-8'
        ## delete BOM
        if @content[0] == 0xef && @content[1] == 0xbb &&
            @content[2] == 0xbf
          ## UTF-8 (BOM)
          @content = @content[3..-1]
        end
      elsif @encoding == 'utf-16'
        if @content.length >= 4
          if @content[0] == 0xff && @content[1] == 0xfe &&
              @content[2] != 0
            ## UTF-16 (LE)
            @content = combineSurrogatePair(@content[2..-1].unpack('v*')).pack('U*')
          elsif @content[0] == 0xfe && @content[1] == 0xff &&
              @content[3] != 0
            ## UTF-16 (BE)
            @content = combineSurrogatePair(@content[2..-1].unpack('n*')).pack('U*')
          else
            raise EncodingError.new("illegal UTF-16 sequence")
          end
        end
      elsif @encoding == 'utf-16le'
        @content = combineSurrogatePair(@content.unpack('v*')).pack('U*')
      elsif @encoding == 'utf-16be'
        @content = combineSurrogatePair(@content.unpack('n*')).pack('U*')
      elsif @encoding == 'utf-32'
        if @content[0] == 0xff && @content[1] == 0xfe &&
            @content[2] == 0 && @content[3] == 0
          ## UTF-32 (LE)
          @content = @content[4..-1].unpack('V*').pack('U*')
        elsif @content[0] == 0 && @content[1] == 0 &&
            @content[2] == 0xfe && @content[3] == 0xff
          ## UTF-32 (BE)
          @content = @content[4..-1].unpack('N*').pack('U*')
        else
          raise EncodingError.new("illegal UTF-32 sequence")
        end
      elsif @encoding == 'utf-32le'
        @content = @content.unpack('V*').pack('U*')
      elsif @encoding == 'utf-32be'
        @content = @content.unpack('N*').pack('U*')
      else
        @content = unknownEncoding(@encoding, @content)
      end
      @content.taint if taintp
    end

    def setEncoding(encoding)
      return if @encoding ## already set
      if @autodetectedEncoding && @autodetectedEncoding != encoding
        raise EncodingError.new("encoding does not match auto detected encoding (#{@autodetectedEncoding}): #{encoding.inspect}")
      end
      @encoding = encoding
      return if encoding == 'utf-8' || encoding == 'us-ascii' ||
        encoding == @autodetectedEncoding
      @content = unknownEncoding(encoding, @content)
    end

    def self._getURIBase(uri = nil)
      uri =~ /^(.*?\/?)[^\/]*$/
      $1
    end

    def self._getURIHost(uri)
      uri =~ /^((https?|ftp|file):\/\/[^\/]*\/?).*$/
      $1
    end

    def self._catURI(baseuri, uri)
      baseuri = baseuri.to_s
      if uri =~ /^([a-zA-Z]+):/
        uri
      elsif uri =~/^\//
        host = _getURIHost(baseuri)
        host =~ /^(.*?)\/?$/
        $1.to_s + uri
      else
        base = _getURIBase(baseuri)
#        base =~ /^(.*?)\/?$/
        base + uri
      end
    end

    def setURI(uri)
      @uri = uri
    end

    def getURI
      @uri
    end

    def getURIBase
      self.class._getURIBase(@uri)
    end

    def self.openFile(file, encoding = nil, &block)
      ret = self.new(open(file), encoding, &block)
      ret.setURI(file)
      ret
    end

    begin
      require 'open-uri';
      @@FETCH_CMD = proc {|uri| open(uri) }
    rescue LoadError
      @@FETCH_CMD = '/usr/bin/curl -s'
    end
    def self.setURIResolver(cmd)
      @@FETCH_CMD = cmd
    end

    def self.openURI(uri, base = nil, encoding = nil, &block)
      uri = _catURI(base, uri)
      if @@FETCH_CMD.is_a?(Proc)
        ret = self.new(@@FETCH_CMD.call(uri), encoding, &block)
      else
        if uri =~ /^(https?|ftp|file):/
          ret = self.new(open("|#{@@FETCH_CMD} '#{uri}'"), encoding, &block)
        else
          ret = self.new(open(uri), encoding, &block)
        end
      end
      ret.setURI(uri)
      ret
    end

    def index(pat, start)
      return nil if @content.nil?
      @content.index(pat, start)
    end

    def length
      return 0 if @content.nil?
      @content.length
    end

    def [](pos, len = nil)
      return nil if @content.nil?
      if len.nil?
        @content[pos]
      else
        @content[pos, len]
      end
    end

    def []=(pos, value1, value2 = nil)
      return if @content.nil?
      if value2.nil?
        @content[pos] = value1
      else
        @content[pos, value1] = value2
      end
    end

    def unknownEncoding(encoding, content)
      case encoding
      when 'euc-jp'
        begin
          require 'nkf'
          if NKF::UTF8
            return NKF.nkf('-Ewm0x', content)
          end
        rescue LoadError,NameError
        end
        begin
          require 'iconv'
          return Iconv.iconv('UTF-8', 'EUC-JP', content).join('')
        rescue LoadError
        end
        begin
          require 'uconv'
          return Uconv.euctou8(content)
        rescue LoadError
        end
      when 'shift_jis'
        begin
          require 'nkf'
          if NKF::UTF8
            return NKF.nkf('-Swm0x', content)
          end
        rescue LoadError,NameError
        end
        begin
          require 'iconv'
          return Iconv.iconv('UTF-8', 'SHift_JIS', content).join('')
        rescue LoadError
        end
        begin
          require 'uconv'
          return Uconv.sjistou8(content)
        rescue LoadError
        end
      when 'iso-2022-jp'
        begin
          require 'nkf'
          if NKF::UTF8
            return NKF.nkf('-Jwm0x', content)
          end
        rescue LoadError,NameError
        end
        begin
          require 'iconv'
          require 'nkf'
          return Iconv.iconv('UTF-8', 'EUC-JP', NKF.nkf('-Jem0x', content)).join('')
        rescue LoadError
        end
        begin
          require 'uconv'
          require 'nkf'
          return Uconv.euctou8(NKF.nkf('-Jem0x', content))
        rescue LoadError
        end
      when 'iso-8859-1'
        return @content.gsub(/([\x80-\xff])/n) {|m| [m[0]].pack('U') }
      when 'windows-1252'
        return @content.gsub(/([\x80-\xff])/n) {|m|
          m[0] < 0xa0 ?
          [CP1252_TO_UCS[m[0] - 0x80]].pack('U') :
          [m[0]].pack('U')
        }
      else
        if @block
          return @block.call(encoding, content)
        end
      end
      raise EncodingError.new("unknown encoding: #{encoding.inspect}")
    end
    private :unknownEncoding

  end
end




## Sample
##
## ruby -rymhtml -e urls <HTMLfile>

def urls
  if ARGV.length == 0
    stream = YmHTML::InputStream.new($<)
  elsif /^(https?|ftp|file):/ =~ ARGV[0]
    stream = YmHTML::InputStream.openURI(ARGV[0])
  else
    stream = YmHTML::InputStream.openFile(ARGV[0])
  end

  parser = YmHTML::Parser.new
  parser.eliminateWhiteSpace = true
  def parser.startElement(n, d)
    case n
    when 'link', 'a'
      if d['href']
        p([n, YmHTML::InputStream._catURI($base, d['href'])])
      end
    when 'img'
      if d['src']
        p([n, YmHTML::InputStream._catURI($base, d['src'])])
      end
    end
  end
  $base = stream.getURIBase
  parser.parse(stream)
end

if $0 == __FILE__
  $OPT_e = nil
  begin
    require 'optparse'
    ARGV.options do |o|
      o.banner << ' <HTMLfile>'
      o.on('-e', '--encoding ENCODING',
           'force input character encoding') do |arg|
        $OPT_e = arg
      end
      o.on('-h', '--forceHTML',
           'force HTML mode even if XHTML') do |arg|
        $OPT_h = arg
      end
      o.parse!
    end
  rescue LoadError
    require 'parsearg'
    $USAGE = 'print "Usage: #{$0} [-h] [-e <encoding>] <HTMLfile>\n"'
    parseArgs(0, nil, 'h', 'e:')
  end

##  YmHTML::InputStream.setURIResolver("wget -O - -o /dev/null")
  if ARGV.length == 0
    stream = YmHTML::InputStream.new($<, $OPT_e)
  elsif /^(https?|ftp|file):/ =~ ARGV[0]
    stream = YmHTML::InputStream.openURI(ARGV[0], $OPT_e)
  else
    stream = YmHTML::InputStream.openFile(ARGV[0], $OPT_e)
  end

  parser = YmHTML::Parser.new
  ## eliminate white spaces (without content of PRE element)
  parser.eliminateWhiteSpace = true
  parser.forceHTML = true if $OPT_h
  parser.parse(stream) do |t, n, d|
    p([t, n, d])
  end

end
