Usage: flashdb command db_name db_user db_pass backup_name
	command		- [backup|restore|tables]
	db_name		- name of the database to use
	db_user		- database username
	db_pass		- database username
	backup_name	- name of backup to store or restore (optional)
      (if ommitted, the current unix timestamp will be used)

  Commands:
    backup  - Creates a backup
    restore - Restores a backup (uses all files in backup
              ignores table file)
    tables  - Dumps all table names in database


There should be a tables file in the directory where you
run the script, each line should have a single table name
that will be backed up. **ALL OTHER TABLES WILL BE
IGNORED.

You can create this file by using the following command:

  flashdb tables DB_NAME DB_USER DB_PASS > tables
