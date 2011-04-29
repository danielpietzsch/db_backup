namespace :db do
  
  desc "Creates a backup of the database for the provided stage; use compressed format with compress=true."
  task :backup do
    compress = ENV['compress'] || 'false'
    
    # The rake task executed can be found at lib/tasks/db_backup.rake
    run("cd #{deploy_to}/current && rake RAILS_ENV=#{rails_env} db:backup compress=#{compress}")
  end
  
  desc "Restores a backup of the database for the provided stage."
  task :restore do
    raise "You have to specify a file on the server to restore. E.g.: file=~/my_database_20110401162500.sql" if ENV['file'].nil?
    
    # The rake task executed can be found at lib/tasks/db_backup.rake
    run("cd #{deploy_to}/current && rake RAILS_ENV=#{rails_env} db:restore file=#{ENV['file']}")
  end
  
end