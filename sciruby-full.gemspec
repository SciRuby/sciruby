::SCIRUBY_FULL = true
file = File.expand_path(File.join(__FILE__, '..', 'sciruby.gemspec'))
eval(File.read(file), TOPLEVEL_BINDING, file)
