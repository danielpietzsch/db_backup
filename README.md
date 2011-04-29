# DB Backup

Adds a rake task to your Rails app to conveniently backup its database.  
Only works with PostgreSQL at the moment.

## Installation

	script/plugin install git://github.com/pie4dan/db_backup.git

## Usage

### Backup

A backup will be created in `~/database_backups`. A backup is stored in a plain text .sql file by default.

	# create a backup (file extension '.sql')
	rake db:backup
	
If you want to compress your backup - using [PostgreSQL's custom dump format](http://www.postgresql.org/docs/8.4/static/backup-dump.html "PostgreSQL: Documentation: Manuals: PostgreSQL 8.4: SQL Dump") - do the following:
	
	# create a compressed backup (file extension '.backup')
	rake db:backup compress=true
	
If you have capified your application, you can also use the capistrano recipe to backup your remote databases.

	cap db:backup [compress=true]
	
Note: the backups are stored on the remote server.

### Restore

Currently, only .sql files are supported for restoring.  
Restore from your backup file like this:

	rake db:restore file=~/database_backups/mydb_production_20110429170000.sql
	
This will:

 1. Create a backup of the existing database,
 2. drop the existing database,
 3. re-create an empty database and
 4. restore the database structure and data from the file you specified.

There's a capistrano recipe for this task, too.

	# the file paramater has to be a valid filepath on the server
	cap db:backup file=~/mydb_production_20110429170000.sql

## TODO

 * Support for more databases
 * Ability to overwrite the path where the backup is saved to
 * Ability to add additional custom description to file name

## Credits

Inspiration taken from thoughbot's [limerick\_rake](https://github.com/thoughtbot/limerick_rake).


Copyright (c) 2011 Daniel Pietzsch, released under the MIT license