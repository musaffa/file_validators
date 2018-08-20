# frozen_string_literal: true

begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'rspec/core/rake_task'

namespace :test do
  RSpec::Core::RakeTask.new(:unit) do |t|
    t.pattern = ['spec/lib/**/*_spec.rb']
  end

  RSpec::Core::RakeTask.new(:integration) do |t|
    t.pattern = ['spec/integration/**/*_spec.rb']
  end
end

task default: ['test:unit', 'test:integration']

# require 'rdoc/task'

# RDoc::Task.new(:rdoc) do |rdoc|
#   rdoc.rdoc_dir = 'rdoc'
#   rdoc.title    = 'FileValidators'
#   rdoc.options << '--line-numbers'
#   rdoc.rdoc_files.include('README.rdoc')
#   rdoc.rdoc_files.include('lib/**/*.rb')
# end

Bundler::GemHelper.install_tasks
