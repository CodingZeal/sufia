require 'rspec/core'
require 'rspec/core/rake_task'
APP_ROOT="." # for jettywrapper
require 'jettywrapper'
#ENV["RAILS_ROOT"] ||= 'spec/internal'

desc 'Spin up hydra-jetty and run specs'
task ci: ['jetty:clean', 'jetty:config'] do
  puts 'running continuous integration'
  jetty_params = Jettywrapper.load_config
  error = Jettywrapper.wrap(jetty_params) do
    Rake::Task['spec'].invoke
  end
  raise "test failures: #{error}" if error
end

task spec: :generate do
  Bundler.with_clean_env do
    within_test_app do
      Rake::Task['rspec'].invoke
    end
  end
end

desc "Run specs"
RSpec::Core::RakeTask.new(:rspec) do |t|
  t.pattern = '../**/*_spec.rb'
  if ENV["TRAVIS"]
    t.rspec_opts = ["--colour -I ../", '--backtrace', '--profile 20']
  else
    t.rspec_opts = ["--colour -I ../"]
  end
end

desc "Create the test rails app"
task :generate do
  unless File.exists?('spec/internal/Rakefile')
    puts "Generating rails app"
    `rails new spec/internal`
    puts "Updating gemfile"

    `echo "gem 'sufia', path: '../../../sufia'
gem 'capybara'
gem 'database_cleaner'
gem 'factory_girl_rails'
gem 'poltergeist'
gem 'rspec-its'
gem 'rspec-activemodel-mocks'
gem 'kaminari', github: 'harai/kaminari', branch: 'route_prefix_prototype'" >> spec/internal/Gemfile`
    puts "Copying generator"
    `cp -r spec/support/lib/generators spec/internal/lib`
    Bundler.with_clean_env do
      within_test_app do
        puts "Bundle install"
        `bundle install`
        puts "running test_app_generator"
        system "rails generate test_app"

        # These factories are autogenerated and conflict with our factories
        system 'rm test/factories/users.rb'
        puts "running migrations"
        puts `rake db:migrate db:test:prepare`
      end
    end
  end
  puts "Done generating test app"
end

desc "Clean out the test rails app"
task :clean do
  if File.directory?('spec/internal')
    within_test_app do
      puts "Stopping Spring"
      `spring stop`
    end
  end
  puts "Removing sample rails app"
  `rm -rf spec/internal`
end

def within_test_app
  FileUtils.cd('spec/internal')
  yield
  FileUtils.cd('../..')
end

namespace :meme do
  desc "configure jetty to generate checksums"
  task :config do
  end
end
