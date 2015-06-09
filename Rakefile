rule '.html' => ['.slim'] do |t|
  sh "slimrb #{t.source} > #{t.name}"
end

task default: 'gems.html'
