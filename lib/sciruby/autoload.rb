class Module
  alias :const_missing_without_sciruby :const_missing

  def const_missing(name)
    (Object != self && sciruby_autoload("#{self.name}::#{name}")) ||
      sciruby_autoload(name) ||
      const_missing_without_sciruby(name)
  end

  private

  def sciruby_autoload(name)
    return unless paths = SciRuby.autoload_modules.delete(name.to_s)
    paths.each {|path| require path }
    const_get(name)
  end
end
