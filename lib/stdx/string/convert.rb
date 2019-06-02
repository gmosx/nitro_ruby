# credit: merb

class String

  # Returns the string converted to snake case.
  #
  # Examples:
  #   "FooBar".snake_case #=> "foo_bar"
  #   "HeadlineCNNNews".snake_case #=> "headline_cnn_news"
  #   "CNN".snake_case #=> "cnn"

  def snake_case
    return self.downcase if self =~ /^[A-Z]+$/
    self.gsub(/([A-Z]+)(?=[A-Z][a-z]?)|\B[A-Z]/, '_\&') =~ /_*(.*)/
      return $+.downcase
  end

  # Returns the string converted to camel case.
  #
  # Examples:
  #   "foo_bar".camel_case #=> "FooBar"

  def camel_case
    return self if self !~ /_/ && self =~ /[A-Z]+.*/
    split('_').map{|e| e.capitalize}.join
  end

  # Returns The string converted to a constant name.
  #
  # Examples:
  #   "merb/core_ext/string".to_const_string #=> "Merb::CoreExt::String"
  #   "merb.core_ext.string".to_const_string #=> "Merb::CoreExt::String"

  def to_const_string
    gsub(/[\/|\.](.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_-)(.)/) { $1.upcase }
  end

end

