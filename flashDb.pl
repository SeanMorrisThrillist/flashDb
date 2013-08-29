#!/usr/bin/perl
use strict;
use DBI;

if(not scalar @ARGV)
{
  print "Usage: flashdb command db_name db_user db_pass backup_name\n"
    . "\tcommand\t\t- [backup|restore]\n"
    . "\tdb_name\t\t- name of the database to use\n"
    . "\tdb_user\t\t- database username\n"
    . "\tdb_pass\t\t- database username\n"
    . "\tbackup_name\t- name of backup to store or restore\n"
  ;
  exit;
}

my $command = $ARGV[0];
my $db_name = $ARGV[1];
my $db_user = $ARGV[2];
my $db_pass = $ARGV[3];
my $dump_name = $ARGV[4];

my $db = DBI->connect(
  "dbi:mysql:" . $db_name
  , $db_user
  , $db_pass
);

my $path = `pwd`;
chomp $path;

my %tablesExist;

(my $showTables = $db->prepare('SHOW TABLES'))->execute();

while(my $tableRecord = $showTables->fetchrow_hashref())
{
  my ($col , $tableName) = %$tableRecord;
  $tablesExist{ $tableName } = 1;
}

my $tableFileName = "$path/tables";

if($command eq 'backup')
{
  if(-e $tableFileName)
  {
    open my $tableFile, $tableFileName;

    my $dumpDir = $path . '/' . time;

    if($dump_name)
    {
      $dumpDir = "$path/$dump_name";
    }

    if(-d $dumpDir)
    {
      printf "Dump %s exists. Please choose a different name or remove it.\n"
        , $dump_name
      ;
      exit;
    }

    mkdir $dumpDir;

    while(<$tableFile>)
    {
      chomp;

      if($tablesExist{$_})
      {
        printf "Dumping %s into %s...\n"
          , $_
          , $dumpDir
        ;

        my $dumpCommand = sprintf "mysqldump -u %s -p%s %s %s"
          . " > %s/%s.sql"
            , $db_user
            , $db_pass
            , $db_name
            , $_
            , $dumpDir
            , $_
        ;

        `$dumpCommand`;
      }
    }
  }
  else
  {
    print "table file not found\n";
    exit;
  }
}
elsif($command eq 'restore')
{
  my $backUpDirName = $path . '/' . $dump_name;

  $backUpDirName =~ s/\/+$//;

  if(not -d $backUpDirName or $dump_name eq '')
  {
    printf "Dump not found.\n";
    exit;
  }

  opendir my $backUpDir, $backUpDirName;

  while(my $fileName = readdir($backUpDir))
  {
    next if($fileName =~ /^\.\.?$/);

    printf "Importing %s/%s...\n"
      , $backUpDirName
      , $fileName
    ;

    my $importCommand =sprintf "mysql -u %s -p%s %s < %s/%s\n"
      , $db_user
      , $db_pass
      , $db_name
      , $backUpDirName
      , $fileName
    ;

    `$importCommand`;
  }
}
elsif($command eq 'tables')
{
  while(my ($tableName, $xx) = each(%tablesExist))
  {
    print "$tableName\n";
  }
}
else
{
  printf "flashdb does not implement %s\n"
    , $command
  ;
}

