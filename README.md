# DB Backup

Supplies a rake task to conveniently backup the database of your Rails app.  
Only works with PostgreSQL at the moment.

## Usage

A backup will be created in `~/database_backups`. A backup is compressed by default (using [PostgreSQL's custom dump format](http://www.postgresql.org/docs/8.4/static/backup-dump.html "PostgreSQL: Documentation: Manuals: PostgreSQL 8.4: SQL Dump")).

	# create a compressed backup (file extension '.backup')
	rake db:backup
	
	# create an uncompressed backup (file extension '.sql')
	rake db:backup compress=false
	
If you have capified your application, you can also use the capistrano recipe to backup your remote databases.

	cap db:backup [compress=false]
	
Note: the backups are stored on the remote server.

## Credits

Inspiration taken from thoughbot's [limerick\_rake](https://github.com/thoughtbot/limerick_rake).


Copyright (c) 2011 Daniel Pietzsch, released under the MIT license
