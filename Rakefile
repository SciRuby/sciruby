task 'gems.html' do
  sh 'slimrb --trace scripts/gems.slim > gems.html'
end

task :test do
  sh 'scripts/test'
end

task deploy: 'gems.html' do
  sh 'scripts/deploy'
end

task default: %w(test gems.html)
