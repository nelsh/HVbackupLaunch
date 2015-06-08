# README #

* Launch HVBackup (http://hypervbackup.codeplex.com/) for every VM

## Features ##

* Remove old backup
* Simple logging with logrotate
* Create summary report and send by email

## Usage ##

Execute from command line

    powershell.exe -ExecutionPolicy Bypass -Command "c:/hvbackup/HVbackupLaunch.ps1" -p f:/backup -l server-one,server-two  

where

* -p - Backup output folder
* -l - List of VMs to backup, comma separated

Sample ini-file

    LOGSTORETIME=30
    KEEPBACKUPS=1
    HVBACKUPEXE=c:/hvbackup/HVBackup.exe --outputformat "{0}_{2:yyyyMMdd}.zip"
    MAILADDRESS	= HVBackup <admin@example.com>
    MAILSERVER	= localhost

 