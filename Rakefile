file 'gems.html' => %w(gems.slim gems.yml) do |t|
  sh "slimrb #{t.source} > #{t.name}"
end

task default: 'gems.html'
