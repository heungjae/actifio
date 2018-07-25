### Setting up Oracle Protection

Prior to protecting an Oracle database using Actifio, we will need to:

#### Patching Oracle 12c

Actifio Application Aware mounts may fail if your Oracle 12c installation does not include this patch, which can be downloaded from the Oracle support portal: 
`Oracle Database 12c Bug# 19404068 (ORA-1610 ON RECOVER DATABASE FOR CREATED CONTROLFILE)`
• (Patch 19404068) Linux x86-64 for Oracle 12.1.0.2.0
• (Patch 19404068) IBM AIX on POWER Systems (64-bit) for Oracle 12.1.0.2.0
• (Patch 19404068) Solaris on SPARC (64-bit) for Oracle 12.1.0.2.0

To see if the patch is installed, run:
```
$ cd $ORACLE_HOME/OPatch
$ ./opatch lsinventory -details
```

#### Ensure the database is up and running

Each Oracle database to be protected must be up and running: 
`ps –ef | grep pmon`

The Oracle database SID entry must be in the /etc/oratab (or, /var/opt/oracle/oratab) file. For a database named “prod”, the entry looks like: 
`prod:/home/oracle/app/oracle/product/11.1.0/db_1:Y`

The listener process must be up and running: 
`ps –ef | grep tns`

#### Preparing for protection

##### ASM diskstring

If you are using Oracle ASM protection out-of-band, then check that the ASM diskstring parameter is not null. Log into the database server as ASM OS user and set the ASM environment variable:
```
sqlplus / as sysasm
show parameter asm_diskstring
```
If the result of value is null, then get the correct ASM disk string value for existing ASM disks before proceeding with Actifio protection. The Actifio backup will add its diskstring path (/dev/actifio/asm/*) for its backup staging disk to map to ASM.


##### Find out the running instance and environment variables
Log into the database server as Oracle OS user and set the database environment variable:
```
export ORACLE_HOME=<oracle home path> 
(get this from /etc/oratab or /var/opt/oracle/oratab on Solaris systems)
export ORACLE_SID=<database instance name> 
(you can get this through ps ‐ef | grep pmon)
export PATH=$ORACLE_HOME/bin:$PATH
```

Find out if ASM is running on the host:
`ps –ef | grep asm_pmon`

List the ASM diskgroups
`oracleasm  listdisks  or  ls –l /dev/oracleasm/disks`

##### Find out the running processes if capturing from RAC environment
Find out the status of the ASM service
```
srvctl status asm
srvctl status service –d <racbigdb>
```

Ensure all the services in the RAC is running fine:
`crsctl status resource -t`

For an Oracle RAC configuration, make sure the snapshot controlfile is located under Shared Disks.  

To check this, connect to RMAN and run the show all command. Configure it if necessary:
```
RMAN target /
RMAN> show all
RMAN> configure snapshot controlfile name to ‘+<DG name><DB name>’
```


##### spfile

Verify database is running with spfile: 
```
sqlplus / as sysdba
show parameter spfile
```

##### ARCHIVELOG
Verify database is running in archive mode: 
`archive log list`

If the database is running noarchivelog mode and you need to change it archivelog:
```
shutdown immediate
startup mount
alter database archivelog;
alter database open;
```

##### DATABASE AUTHENTICATION, as opposed to OS AUTHENTICATION
Create a database user account for Actifio backup (if not provided):
`create user act_rman_user identified by <password>; `

For Oracle 12c, 
```
create user c##act_rman_user identified by act_rman_user container=all;
Grant sysdba access. 
grant create session, resource, sysdba to act_rman_user;
```

For Oracle 12c this role can be sysbackup instead of sysdba:
`grant create session, resource, sysbackup to c##act_rman_user; `

Verify the sysdba role has been granted: 
`select * from v$pwfile_users;`

##### BLOCK CHANGE TRACKING (optional)

Check if database block change tracking is enabled: 
`select * from v$block_change_tracking;`

To enable database block change tracking from sqlplus:  

For an Oracle instance running from ASM disk group:
`alter database enable block change tracking using file '<ASM Disk Group Name>’;`

For an Oracle instance running from a file system:
`alter database enable block change tracking using file '$ORACLE_HOME/dbs/<dbname>.bct';`

##### ORACLE SERVICE NAME

Find out the service name (<service_name>). Test the service name by running
```
tnsping <service_name>
lnsrctl status
```

If it fails, then create a service name entry in tnsnames.ora. The file should be in either one of the directories: $ORACLE_HOME/network/admin or $ASM_HOME/network/admin . The entry should be as follow:
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

Confirm that the TNS entry is working:
```
tnsping <service_name>
sqlplus act_rman_user/act_rman_user@<service_name> as sysdba
```
