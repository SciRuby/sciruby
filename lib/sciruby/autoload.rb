class Module
  alias :const_missing_without_sciruby :const_missing

  def const_missing(name)
    paths = SciRuby.autoload_modules.delete(name)
    if paths
      paths.each {|path| require path }
      const_get(name)
    else
      const_missing_without_sciruby(name)
    end
  end
end
