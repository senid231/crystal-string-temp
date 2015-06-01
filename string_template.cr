# simple variable replacement in template string
# like string.Template in Python
class StringTemplate
  
  class StringTemplateException < Exception
  end
  
  class KeyNotFound < StringTemplateException
    def initialize(key : String?)
      super("Key Not Found: #{key}")
    end
  end
  
  class KeyInvalid < StringTemplateException
    def initialize(key : String?)
      super("Key Invalid: #{key}")
    end
  end
  
  class SeparatorInvalid < StringTemplateException
    def initialize(sep : Char?)
      super("Separator Invalid: #{sep}")
    end
  end
  
  class BracesInvalid < StringTemplateException
    def initialize(braces : Int32?)
      super("Braces Invalid: #{braces.to_s}")
    end
  end
    
  KEY_MATCHER = /[a-z0-9_]/i
  ROUND_BRACES = 1
  SQUARE_BRACES = 2
  FIGURE_BRACES = 3
  ALLOWED_SEPARATORS = ['$', '%', '@', '#', '&', '~', '?']
  BRACES = {
    ROUND_BRACES => ['(', ')'], 
    SQUARE_BRACES => ['[', ']'], 
    FIGURE_BRACES => ['{', '}']
  }
  DEFAULT_BRACES = FIGURE_BRACES
  DEFAULT_SEPARATOR = ALLOWED_SEPARATORS[0]
    
  getter separator
  getter braces

  
  # todo: add posibility to use templates without braces
  def initialize(@string : String, separator=DEFAULT_SEPARATOR : Char, braces=DEFAULT_BRACES : Int32)
    self.separator = separator
    self.braces = braces
  end

  def separator=(sep : Char) : Char
    raise SeparatorInvalid.new(sep) unless ALLOWED_SEPARATORS.includes?(sep)
    @separator = sep
  end

  def braces=(braces : Int32) : Int32
    raise BracesInvalid.new(braces) unless BRACES.keys.includes?(braces)
    @braces = braces
  end


  def substitute(vars : Hash(String|Symbol, String)) : String
    string = @string
    keys = vars.keys
    validate(keys)
    open_brace = BRACES[self.braces][0]
    close_brace = BRACES[self.braces][1]
    keys.each do |key|
      sub_key = substituted_variable(key.to_s, open_brace, close_brace)
      raise KeyNotFound.new(sub_key) unless @string.index(sub_key)
      string = string.gsub(sub_key, vars[key])
    end
    
    string
  end


  private def validate(keys : Array(String|Symbol)) : Nil
    keys.each do |key|
      raise KeyInvalid.new(key.to_s) unless key.to_s.match(KEY_MATCHER)
    end
    nil
  end


  private def substituted_variable(key : String, open_brace : Char, close_brace : Char) : String
    "#{@separator}#{open_brace}#{key}#{close_brace}"
  end
  
end
