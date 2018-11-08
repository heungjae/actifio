## Setting up Oracle Protection
   
** Actifio / Oracle - Prerequisites for capture:**   

- [ ] Actifio connector must be installed on DB host(s)
- [ ] Confirm source database is up & running
- [ ] Make sure that corresponding SID entry is updated in /etc/oratab with Oracle Home location
- [ ] Confirm database is running in ARCHIVELOG mode
- [ ] Confirm database is running with server parameter file (SPFILE)
- [ ] For an Oracle RAC configuration, confirm the snapshot control file is located under shared disks
- [ ] Enable Database Block Change Tracking (optional)
- [ ] Database user (eg act_rman_user) should be created in source database if using “DB Authentication mode”.
- [ ] Make sure that asm_diskstring is not empty. (If target/source DB host is running on ASM storage)
   
   
** Actifio / Oracle - Prerequisites for access:**   

- [ ] Actifio connector must be installed on DB host(s)
- [ ] Make sure that /etc/oratab exists
- [ ] Make sure that asm_diskstring is not empty. (If target/source DB host is running on ASM storage)
   
---

Prior to protecting an Oracle database using Actifio, we will need to:

## Preparing for protection

### Patching Oracle 12c
If we working with Oracle 12, ensure the software is patched with the following patches:
`Oracle Database 12c Bug# 19404068 (ORA-1610 ON RECOVER DATABASE FOR CREATED CONTROLFILE)`
• (Patch 19404068) Linux x86-64 for Oracle 12.1.0.2.0
• (Patch 19404068) IBM AIX on POWER Systems (64-bit) for Oracle 12.1.0.2.0
• (Patch 19404068) Solaris on SPARC (64-bit) for Oracle 12.1.0.2.0

Actifio Application Aware mounts may fail if your Oracle 12c installation does not include the above patch, which can be downloaded from the Oracle support portal: 

To see if the patch is installed, run:
```
$ cd $ORACLE_HOME/OPatch
$ ./opatch lsinventory -details
```

### Oracle Authentication
We support OS and DB authentication.

With OS authentication (default setting), Actifio passes OS username to the Oracle server, the username is recognized and the connection is accepted. There is no need for database user account (listener service) and Actifio backup operations use “/ as sysdba” to connect to database.   

Actifio will use Oracle DB credentials to perform backup. We will need two kinds of Oracle credentials: 1) Database credentials to connect to the database with sysdba privilege, 2) An Oracle listener (tnsnames) service name to connect to the database as sysdba. This type of authentication is required in order to run parallel ASM disk group backups from multiple nodes in a RAC environment.  


### Oracle Environment Variables
If the variable ORAENV_ASK is changed to YES or is not set at all, there is a prompted to enter a SID when logging in. Set it to NO to avoid this.
```
export ORAENV_ASK=NO
export ORACLE_SID=MYDB
. oraenv
export ORAENV_ASK=YES
```

Following is a list of standard Oracle related environment variables:
```
export ORACLE_HOME=<oracle home path>
export ORACLE_SID=<database instance name>
export ORACLE_SID=orcl 
export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=/u01/app/oracle/product/11.2.0/db_1
export TNS_ADMIN=$ORACLE_HOME/network/admin      
export PATH=$ORACLE_HOME/bin:$PATH
```

### Ensure the Oracle database is up and running

Each Oracle database to be protected must be up and running:   `ps –ef | grep pmon`

The Oracle database SID entry must be in the **/etc/oratab** (or, /var/opt/oracle/oratab) file.   

For a database named "prod", the entry looks like:    `prod:/home/oracle/app/oracle/product/11.1.0/db_1:Y`


### Ensure ASM diskstring is not NULL

If you are using Oracle ASM protection out-of-band, then check that the ASM diskstring parameter is not null. 

Log into the ASM instance on the database server as ASM OS user and set the ASM environment variable:
```
sqlplus / as sysasm
show parameter asm_diskstring
```
If the result of value is null, then get the correct ASM disk string value for existing ASM disks before proceeding with Actifio protection. The Actifio backup will add its diskstring path (/dev/actifio/asm/*) for its backup staging disk to map to ASM. Add `ORCL:*` to asm_diskstring using the `alter system set asm_diskstring='ORCL:*' ;` command.

Following are some SQL scripts to list the members of the ASM diskgroup:
```
set lines 120
col name for a30
col path for a30
col state for a30
select name,path from v$asm_disk;
select group_number,name,state,type from v$asm_diskgroup;
alter system set asm_diskstring='ORCL:*' ;

col compatibility format a10
col database_compatibility format a10
col name format a15
set linesize 200
col total_gb format 99099.99
col free_gb format 99099.99
select group_number, name, type, total_mb, total_mb/1024 total_gb, free_mb, free_mb/1024 free_gb, compatibility, database_compatibility from v$asm_diskgroup;

. oraenv
+ASM
sqlplus / as sysasm
shutdown immediate
alter system set asm_diskstring=NULL scope=spfile;
alter system set asm_diskstring='ORCL:*','/dev/actifio/asm/*' scope=spfile;
alter system set asm_diskstring='ORCL:*','/dev/actifio/asm/*' scope=both;
startup
```

### Find out the running instance and environment variables
Log into the database server as Oracle OS user and set the database environment variable:
```
export ORACLE_HOME=<oracle home path>        (get this from /etc/oratab or /var/opt/oracle/oratab on Solaris systems)
export ORACLE_SID=<database instance name>   (you can get this through ps ‐ef | grep pmon)
export PATH=$ORACLE_HOME/bin:$PATH
```

If you need to script the setting of environment variables:
```
export ORACLE_SID=$oracleSID
export ORAENV_ASK=NO
. /usr/local/bin/oraenv
```

Find out if ASM is running on the host:     `ps –ef | grep asm_pmon`

List the ASM diskgroups            `oracleasm  listdisks  or  ls –l /dev/oracleasm/disks`

### Find out the running processes if capturing from RAC environment
Find out the status of the ASM service
```
srvctl status asm
srvctl status service –d <racbigdb>
```

Ensure all the services in the RAC is running fine:           `crsctl status resource -t`

For an Oracle RAC configuration, make sure the snapshot controlfile is located under Shared Disks.  

To check this, connect to RMAN and run the show all command. Configure it if necessary:
```
RMAN target /
RMAN> show all
RMAN> configure snapshot controlfile name to ‘+<DG name><DB name>’
```

### Ensure the database is using SPFILE

The location of text pfile is in $ORACLE_HOME/dbs/init{ORACLE_SID}.ora , whereas the encoded binary file is spfile{ORACLE_SID}.ora. To create a pfile from spfile, use the `create pfile from spfile`

To create an spfile 
```
startup mount   <-- will use the pfile
create spfile=’+DATA/ORCL/spfileorcl.ora’ from pfile;
```
Replace or insert the following line in initorcl.ora `spfile=’+DATA/ORCL/spfileorcl.ora’`

```
$ cat initdemo.ora 
SPFILE='+DATA/demo/spfiledemo.ora'
```

Verify database is running with spfile: 
```
sqlplus / as sysdba
show parameter spfile
```

### Ensure the database is running in ARCHIVELOG mode
Verify database is running in archive mode: 
`archive log list`

If the database is running noarchivelog mode and you will need to change it archivelog by connecting to the instance:
```
shutdown immediate
startup mount
alter database archivelog;
alter database open;
```

```
set lines 120
select incarnation#, resetlogs_time, resetlogs_change#, prior_resetlogs_change#, status from v$database_incarnation;
select name, created, resetlogs_change#, log_mode, open_resetlogs, open_mode, database_role, current_scn from v$database;
```

### Not required - Setting Flash Recovery Area
```
SQL> archive log list;
SQL> startup mount
alter system set db_recovery_file_dest_size=10G scope=both
alter system set db_recovery_file_dest='+data'
SQL> alter database archivelog;
SQL> alter database open;
```

Verify the Database in flash back mode and the retention_target:
`SELECT flashback_on, log_mode FROM v$database;`


### DATABASE AUTHENTICATION, as opposed to OS AUTHENTICATION
Create a database user account for Actifio backup (if not provided):
`create user act_rman_user identified by <password>; `

For Oracle 12c, 
```
create user c##act_rman_user identified by act_rman_user container=all;
Grant sysdba access. 
grant create session, resource, sysdba to act_rman_user;
```

Oracle database authentication uses your Oracle credentials. With Oracle Database Authentication, you must provide two kinds of Oracle credentials:
- Database credentials to connect to the database with sysdba privilege (sysbackup for Oracle 12c)
- An Oracle listener (tnsnames) service name to connect to the database as sysdba (sysbackup for Oracle 12c)

Create a database user account for Actifio backup (if not provided):
sql> create user act_rman_user identified by <password>;
e.g. SQL> create user act_rman_user identified by act_rman_user default tablespace users;

Grant sysdba access. For Oracle 12c this role can be sysbackup instead of sysdba. For RAC, the grant must be run on all nodes.
sql> grant create session, resource, sysdba to act_rman_user;

Create a database user account for Actifio backup (if not provided):
sql> create user act_rman_user identified by <password>;

3. Grant sysdba access:
sql> grant create session, resource, sysdba to act_rman_user;
For Oracle 12c this role can be sysbackup instead of sysdba, and the database user name starts with #.
 
4. Verify the sysdba role has been granted:
```
sqlplus / as sysasm
select * from gv$pwfile_users;
```

### Creating and Verifying the Oracle Servicename in a non-RAC Environment

The Oracle Servicename is used for database authentication only.

Example: Database name: dbstd, Instance Name: dbstd
1. If the Oracle Servicename is not listed, then create the service name entry in the tnsnames.ora file at
```
$ORACLE_HOME/network/admin or at $GRID_HOME/network/admin by adding the entry:
act_svc_dbstd =
(DESCRIPTION =
  (ADDRESS = (PROTOCOL = TCP)(HOST = <IP of the database server>)(PORT = 1521))
    (CONNECT_DATA =
    (SERVER = DEDICATED)
    (SERVICE_NAME = dbstd)
) )
```

If the tnsnames.ora file is in a non-standard location, then provide the absolute path to it in the Application Advanced Settings.

2. Test that the service name entry for the database is configured:
Login as Oracle OS user and set the Oracle environment:
```
TNS_ADMIN=<tnsnames.ora file location>
tnsping act_svc_dbstd


For Oracle 12c this role can be sysbackup instead of sysdba:
`grant create session, resource, sysbackup to c##act_rman_user; `

Check the database user account to be sure the Actifio backup can connect:
`sqlplus act_rman_user/act_rman_user@act_svc_dbstd as sysdba`

Verify the sysdba role has been granted. For RAC, verify the grant on all nodes.
`select * from v$pwfile_users;`
```

### BLOCK CHANGE TRACKING (optional)

Recommend enabling database change block tracking. With database CBT off incremental backup time will be impacted. Oracle database block change tracking feature is available in oracle Enterprise Edition. SQL query to check block change tracking enabled/disabled: 

Check if database block change tracking is enabled:     `select * from v$block_change_tracking;`

```
set lines 120
col status for a10
col filename for a30
col bytes for 999,999
select status, filename,bytes from v$block_change_tracking;
```

To enable database block change tracking from sqlplus:  

For an Oracle instance running from ASM disk group:
`alter database enable block change tracking using file '<ASM Disk Group Name>’;`

For an Oracle instance running from a file system:
`alter database enable block change tracking using file '$ORACLE_HOME/dbs/<dbname>.bct';`

### Ensure password file exists
Verify the password file for the database exists on the Oracle host

### Ensure snapshot controlfile on shared disks
For Oracle RAC configuration, make sure the snapshot controlfile is located under Shared Disks.


### ORACLE SERVICE NAME

Find out the service name (<service_name>). Test the service name by running
```
tnsping <service_name>
lnsrctl status
```

The listener process must be up and running:       `ps –ef | grep tns`

If the listner is down:               `su - oracle ; . oraenv ; lsnrctl status`

lsnrctl status to ensure the listener is running. If it's down, lsnrctl start will read the **$TNS_ADMIN/listener.ora** (under the grid or oracle user) and start the tnslsnr process. 

To reload the listener.ora file:
`lsnrctl start ; lsnrctl reload ; lsnrctl services`

If it fails, then create a service name entry in **tnsnames.ora** . The file should be in either one of the directories: $ORACLE_HOME/network/admin or $ASM_HOME/network/admin . The entry should be as follow:
```
<service_name> =
(DESCRIPTION =
  (ADDRESS = (PROTOCOL = TCP)(HOST = <IP address_Oracle server>)(PORT = 1521))
    (CONNECT_DATA =
    (SERVER = DEDICATED)
    (SERVICE_NAME = <service_name>) 
  )
)
```

To test the service name, login as Oracle user and set the Oracle environment
export TNS_ADMIN=$GRID_HOME/network/admin 
tnsping <service_name>"

Test the service name and user credentials. 

For Oracle 12c this role can be sysbackup instead of sysdba:	
sqlplus act_rman_user/act_rman_user@<service_name> as sysdba

### Creating a Servicename Entry in tnsnames.ora	
Create the service name entry in the tnsnames.ora file at $ORACLE_HOME/network/admin or at $GRID_HOME/network/admin by adding the entry: 
```
<service_name> = (DESCRIPTION = (ADDRESS = (PROTOCOL = TCP)(HOST = <IP of the database server>)(PORT = 1521)) (CONNECT_DATA = (SERVER = DEDICATED) (SERVICE_NAME = <service_name>)) )"
```

Confirm that the TNS entry is working:
```
tnsping <service_name>
sqlplus act_rman_user/act_rman_user@<service_name> as sysdba
```
- - -

```
# touch /act/scripts/wf_mdb_pre.sh
# touch /act/scripts/wf_mdb_post.sh
# touch /act/scripts/wf_xdb_pre.sh
# touch /act/scripts/wf_xdb_post.sh
# touch /act/scripts/wf_vdb_pre.sh
# touch /act/scripts/wf_vdb_post.sh
# touch /act/scripts/wf_db_post.sh
# touch /act/scripts/wf_db_pre.sh

# chown oracle:oinstall /act/scripts/*.sh
# chmod 755 /act/scripts/*.sh
```

- - -
Find out the configuration on the server:
```
cat /proc/meminfo | grep MemTotal
cat /proc/meminfo | grep SwapTotal
df –h
cat /etc/redhat-release
uname -a
Linux melnaborcl 2.6.32-696.23.1.el6.x86_64 #1 SMP Tue Mar 13 22:44:18 UTC 2018 x86_64 x86_64 x86_64 GNU/Linux
```

Run the query from sqlplus connected as sysdba:
   
```
set lines 150
col name for a65
col member for a50
col bytes for 9,999,999,999
select status, enabled, bytes, name, checkpoint_change#  from v$datafile;
select name, status from v$controlfile;
select group#, status,type, member from v$logfile;

select host_name from v$instance;
select platform_name from v$database;
select file_name from dba_temp_files;

select distinct machine from v$session;
select name, value, unit from v$pgastat;
select name, value from v$sga;
select banner from v$version;

select instance_name, host_name, version, status, logins, database_status, instance_role, active_state from v$instance;

select name, created, sysdate, log_mode, controlfile_type, open_mode, protection_mode, database_role, db_unique_name, platform_name from v$database;

select recid, name, dest_id, sequence#, resetlogs_change#, status, next_change# from v$archived_log;

## Getting the last data update time of a specific table in Oracle
select max(ora_rowscn), scn_to_timestamp(max(ora_rowscn)) from scott.emp;

```

## Manual scripts
```
cd /act/act_scripts/oracleclone

OracleAppMount.sh (formerly customerClone.sh)
# sh ./customerClone.sh <New database sid name> <Oracle Home path> <Backup location mount path>

OracleAppMount_tstamp.sh (formerly customerClone_tstamp.sh)
# sh ./customerClone_tstamp.sh <New database sid name> <Oracle Home path> <Backup location mount path> <log mount path> <timestamp yyyymmddhh24mi>

OracleAppTeardown.sh (customerRewind.sh)
# sh ./customerRewind.sh testdb $ORACLE_HOME /act/mnt/Job_4537358_mountpoint_1417562372683/ 
```
