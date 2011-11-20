module Hooks
  def metaclass()
    class << self
      self
    end
  end
  
  def hooked_methods()
    @hooked_methods ||= []
    return ([] + @hooked_methods)
  end
  
  def hook(method, &block)
    metaclass.instance_eval do
      define_method(method) do |*a, &b|
        block.call(*a, &b)
        super(*a, &b)
      end
    end
    @hooked_methods ||= []
    @hooked_methods << method
    return
  end
  
  def unhook(method)
    hook(method) {}
    @hooked_methods.reject! {|m| m==method}
    return
  end
  
  def unhook_all()
    return if hooked_methods.empty?
    hooked_methods.each do |m|
      unhook(m)
    end
    return
  end
end

if $0 == __FILE__
  puts "## Hooks module demonstration ##"
  
  class A
    include Hooks
    def foo(*a)
      puts "bar #{a}"
    end
  end
  
  a = A.new
  
  puts ""
  puts "Original:"
  a.foo("one", "two") { puts "three" } 
  
  puts ""
  puts "Hooked:"
  a.hook(:foo) do |*a, &b|
    puts "qux #{a}"
    b.call if b
  end
  a.foo("four", "five") { puts "six" }
  
  puts ""
  puts "Unhooked:"
  a.unhook(:foo)
  a.foo("seven", "eight") { puts "nine" }
  
end