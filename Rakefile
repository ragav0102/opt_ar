require 'bundler/gem_tasks'
require 'rake/testtask'
require 'mysql2'
require 'active_record'
require 'active_record/connection_adapters/mysql2_adapter'
require 'coveralls/rake/task'

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/*_test.rb']
end

namespace :db do
  task :create do
    ActiveRecord::Base.establish_connection(
      adapter: 'mysql2',
      host: 'localhost',
      username: 'root',
      password: '',
      pool: 5
    )

    conn = ActiveRecord::Base.connection
    create_db = 'CREATE DATABASE optar_test'
    conn.execute(create_db)
  end
end

task default: :test

Coveralls::RakeTask.new
