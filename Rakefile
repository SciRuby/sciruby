begin
  require 'bundler/setup'
rescue Exception
end

task :test do
  sh 'scripts/test'
end

task 'gems.html' do
  sh 'slimrb --trace scripts/gems.slim > gems.html'
end

task default: %w(test gems.html)
