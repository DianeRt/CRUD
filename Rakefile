namespace :db do
  desc "Run migrations"
  task :migrate, [:version] do |t, args|
    require "sequel"
    Sequel.extension :migration
    if (ENV['RACK_ENV'] == "test")
      db = Sequel.connect("postgresql://localhost/test")
    else
      db = Sequel.connect("postgresql://localhost/users")
    end
    if args[:version]
      puts "Migrating to version #{args[:version]}"
      Sequel::Migrator.run(db, "db/migrations", target: args[:version].to_i)
    else
      puts "Migrating to latest"
      Sequel::Migrator.run(db, "db/migrations")
    end
  end
end

namespace :generate do
  desc 'Generate a timestamped, empty Sequel migration.'
  task :migration, :name do |_, args|
    if args[:name].nil?
      puts 'You must specify a migration name (e.g. rake generate:migration[create_events])!'
      exit false
    end

    content = "Sequel.migration do\n  up do\n    \n  end\n\n  down do\n    \n  end\nend\n"
    timestamp = Time.now.strftime("%Y%m%d%H%M%S ").to_i
    filename = File.join(File.dirname(__FILE__), 'db/migrations', "#{timestamp}_#{args[:name]}.rb")

    File.open(filename, 'w') do |f|
      f.puts content
    end

    puts "Created the migration #{filename}"
  end
end

namespace :mini do
  desc "Run minitest"
  task :test
  ENV['RACK_ENV'] = 'test'
  Rake::Task["db:migrate"].invoke
  require 'rake/testtask'
  Rake::TestTask.new do |t|
    t.libs = %w(spec app)
    t.pattern = "spec/**/*_spec.rb"
    t.warning = false
  end
end