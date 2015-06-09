file 'gems.html' => %w(scripts/gems.slim gems.yml) do |t|
  sh "slimrb --trace #{t.source} > #{t.name}"
end

task :test do
  sh 'scripts/test'
end

task :update do
  sh 'scripts/update'
end

task default: 'gems.html'
