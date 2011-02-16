namespace :db do
  
  desc "Backup the database specified with RAILS_ENV; stores it in ~/database_backups/db-name-timestamp.sql; use uncompressed format with compress=false."
  task :backup => :environment do
    config    = ActiveRecord::Base.configurations[Rails.env || 'development']
    filename  = "#{config['database'].gsub(/_/, '-')}-#{Time.now.strftime('%Y-%m-%d-%H-%M-%S')}"
    backupdir = File.expand_path('~/database_backups')
    pgdump    = `which pg_dump`.strip
    options   =  "-U #{config['username']}"
    options   += " -h #{config['host']}" if config['host']
    options   += " -p #{config['port']}" if config['port']
    
    if ENV['compress'] == 'false'
      extension = ".sql"
    else
      options   += " -F c"
      extension = ".backup"
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
      puts "There was an error and a backup could not be created."
    end
  end # of task :backup
  
end