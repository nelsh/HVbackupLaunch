# README #

## Features ##

* Launch HVBackup (http://hypervbackup.codeplex.com/) for every VM
* Previous version retention
* Simple logging with logrotate
* Create summary report and send by email

## Usage ##

1. Execute from command line

    powershell.exe -ExecutionPolicy Bypass -Command "c:/hvbackup/HVbackupLaunch.ps1" -o f:/backup -l server-one,server-two 

where

 * -o or -path : Backup output folder
 * -l or -name : List of VMs to backup, comma separated

2. Execute from Powershell console:

    get-vm | select Name | "HVBackupLaunch.ps1" -Path %BCKPATH%" -verbose


## Example report  ##

    HVbackup SA. Success: 2/2, Size: 52,2 Gb

    f:\backup\server-one_20150608.zip	24,5Gb	02:37:42.142
    f:\backup\server-two_20150608.zip	27,7Gb	01:54:08.422

    ----------------------- Detailed Log -------------------------------

    05:02:49 INFO	Start
    05:02:49 INFO	Backup 2 virtual machine(s) (server-one, server-two) to f:/ttthv
    05:02:49 INFO	Backup server-one. Run: c:/HVBackup/HVBackup.exe --outputformat "{0}_{2:yyyyMMdd}.zip" -o f:/backup -l server-one 2>&1

    05:03:04 Cloudbase HyperVBackup 1.0 beta1
    Copyright (C) 2012 Cloudbase Solutions Srl
    http://www.cloudbasesolutions.com

    Initializing VSS

    Starting snapshot set for:
    Backup Using Saved State\server-one

    Volumes:
    C:\
    D:\

    Component: "Backup Using Saved State\server-one"
    Archive: "f:/backup\server-one_20150608.zip"
    Entry: "server-one.vhdx"
    Entry: "ProgramData/Microsoft/Windows/Hyper-V/Virtual Machines/DAF7AD0A-F758-430A-8D4F-E4ACD95D8AFB.xml"
    Entry: "ProgramData/Microsoft/Windows/Hyper-V/Virtual Machines/DAF7AD0A-F758-430A-8D4F-E4ACD95D8AFB/"
    Entry: "ProgramData/Microsoft/Windows/Hyper-V/Virtual Machines/DAF7AD0A-F758-430A-8D4F-E4ACD95D8AFB/DAF7AD0A-F758-430A-8D4F-E4ACD95D8AFB.bin"
    Entry: "ProgramData/Microsoft/Windows/Hyper-V/Virtual Machines/DAF7AD0A-F758-430A-8D4F-E4ACD95D8AFB/DAF7AD0A-F758-430A-8D4F-E4ACD95D8AFB.vsv"
    Deleting snapshot set

    Elapsed time: 02:37:42.142

    05:03:05 INFO	Backup server-two. Run: c:/HVBackup/HVBackup.exe --outputformat "{0}_{2:yyyyMMdd}.zip" -o f:/backup -l server-two 2>&1

    05:03:19 Cloudbase HyperVBackup 1.0 beta1
    Copyright (C) 2012 Cloudbase Solutions Srl
    http://www.cloudbasesolutions.com

    Initializing VSS

    Starting snapshot set for:
    Backup Using Saved State\server-two

    Volumes:
    C:\
    D:\

    Component: "Backup Using Saved State\server-two"
    Archive: "f:/backup\server-two_20150608.zip"
    Entry: "server-two.vhdx"
    Entry: "ProgramData/Microsoft/Windows/Hyper-V/Virtual Machines/318720FF-DB1D-43B7-A16A-10E7FA0D3518.xml"
    Entry: "ProgramData/Microsoft/Windows/Hyper-V/Virtual Machines/318720FF-DB1D-43B7-A16A-10E7FA0D3518/"
    Entry: "ProgramData/Microsoft/Windows/Hyper-V/Virtual Machines/318720FF-DB1D-43B7-A16A-10E7FA0D3518/318720FF-DB1D-43B7-A16A-10E7FA0D3518.bin"
    Entry: "ProgramData/Microsoft/Windows/Hyper-V/Virtual Machines/318720FF-DB1D-43B7-A16A-10E7FA0D3518/318720FF-DB1D-43B7-A16A-10E7FA0D3518.vsv"
    Deleting snapshot set

    Elapsed time: 01:54:08.422

    05:03:19 INFO	Successful Stop
