namespace :db do
  
  desc "Backup the database specified with RAILS_ENV; stores it in ~/database_backups/db_name_timestamp.sql; use compressed format with compress=true."
  task :backup => :environment do
    config    = ActiveRecord::Base.configurations[Rails.env || 'development']
    filename  = "#{config['database']}_#{timestamp_for_time(Time.now)}"
    backupdir = File.expand_path('~/database_backups')
    pgdump    = `which pg_dump`.strip
    options   =  "-U #{config['username']}"
    options   += " -h #{config['host']}" if config['host']
    options   += " -p #{config['port']}" if config['port']
    
    if ENV['compress'] == 'true'
      options   += " -F c"
      extension = ".backup"
    else
      extension = ".sql"
    end
    
    filepath  = File.join(backupdir, filename + extension)
    
    raise RuntimeError, "I only work with PostgreSQL." unless config['adapter'] == 'postgresql'
    raise RuntimeError, "Cannot find pg_dump command." if pgdump.blank?
    
    FileUtils.mkdir_p backupdir
    
    puts "A backup of database '#{config['database']}' is now being created. It may take a couple of seconds (or even minutes) to finish, depending on the size of the database."
    
    success = system("export PGPASSWORD=#{config['password']} && #{pgdump} #{options} -f #{filepath} #{config['database']}")
    
    if success
      puts "A backup of the '#{config['database']}' database has been successfully saved to #{filepath}."
    else
      raise RuntimeError, "There was an error and a backup could not be created."
    end
  end # of task :backup
  
  # TODO .backup file restore
  desc "Restores the database from a .sql for the specified environment; will delete all existing data."
  task :restore do
    raise "You have to specify a file to restore. E.g.: file=~/my_database_20110401162500.sql" if ENV['file'].nil?
    
    puts
    puts "The following steps will be executed:"
    puts "  1. Creation of a backup of the existing database"
    puts "  2. Drop the existing database"
    puts "  3. Re-create and empty database"
    puts "  4. Database structure and data is restored from the file you specified."
    puts
    puts "Do you want to continue? (y|n)"
    
    answer = STDIN.getc

    unless answer == 'y' || answer == 121 # == y
      puts "Database restore cancelled."
      exit
    end
    
    Rake::Task['db:backup'].invoke
    
    Rake::Task['db:drop'].invoke
    puts "Database dropped"
    
    Rake::Task['db:create'].invoke
    puts "Database re-created"
    
    config = ActiveRecord::Base.configurations[Rails.env || 'development']    
    psql   = `which psql`.strip

    raise RuntimeError, "I only work with PostgreSQL." unless config['adapter'] == 'postgresql'
    raise RuntimeError, "Cannot find psql command." if psql.blank?
    
    options =  "-U #{config['username']}"
    options += " -h #{config['host']}" if config['host']
    options += " -p #{config['port']}" if config['port']
    
    # get the path of the file to import and store the log file there, too
    path         = ENV['file'][0..ENV['file'].rindex('/')]
    logfile_name = "#{path}#{config['database']}_import_#{timestamp_for_time(Time.now)}.log"
    
    puts "Restoring database from #{ENV['file']}"
    
    # Some advice taken from these URLs:
    # http://stackoverflow.com/questions/4459740/psql-o-not-what-i-expected-how-to-output-db-response-to-an-output-file
    # http://petereisentraut.blogspot.com/2010/03/running-sql-scripts-with-psql.html
    success = system "export PGPASSWORD=#{config['password']} && #{psql} --no-psqlrc --quiet #{options} -f #{ENV['file']} -d #{config['database']} &>#{logfile_name}"
    
    puts "A log file for this import has been created: #{logfile_name}."
    
    if success
      puts "The database has been restored successfully."
    else
      raise RuntimeError, "Database restore UNSUCCESSFUL!"
    end
  end # of task :restore
end

def timestamp_for_time(time)
  time.strftime('%Y%m%d%H%M%S')
end