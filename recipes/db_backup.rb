namespace :db do
  
  desc "Creates a backup of the database for the provided stage; use uncompressed format with compress=false."
  task :backup do
    compress = ENV['compress'] || 'true'
    
    # The rake task executed can be found at lib/tasks/backup.rake
    run("cd #{deploy_to}/current && rake RAILS_ENV=#{rails_env} db:backup compress=#{compress}")
  end
  
end