# STEP 1. Read parameters from command line
param($p,$m) 
if (!$p -or !$m) {
    echo "HVbackup Launcher (http://hypervbackup.codeplex.com/)`n
`tUsage:`n
`tHVbackupLaunch -p <path/to/backup/folder> -m <list,of,virtuals,machines>`n`n"
    exit(0)
}
if (!(Test-Path $p)) {
    echo("Backup folder {0} not exist.`r`n" -f $p)
    exit(0)
}

# STEP 2. Read parameters from ini-file and set default values
$inifile = Join-Path $PSScriptRoot ( $MyInvocation.MyCommand.Name.Replace("ps1", "ini") )
if (!(Test-Path $inifile)) {
    echo("INI-file not found ({0}).`r`nRTFM`r`n" -f $inifile)
    exit(0)
}
$ini = ConvertFrom-StringData((Get-Content $inifile) -join "`n")
if (!($ini.ContainsKey("LOGPATH"))) { 
    $ini.Add("LOGPATH", $PSScriptRoot) # whereis this script
}
if (!($ini.ContainsKey("RPTPATH"))) { 
    $ini.Add("RPTPATH", $PSScriptRoot) # whereis this script
}
if (!($ini.ContainsKey("LOGSTORETIME"))) { 
    echo("Set LOGSTORETIME parameter in {0}.`r`nRecomended (days):`r`n" -f $inifile)
    echo("`t LOGSTORETIME=30")
    exit(0)
}

# STEP 3. Remove old logfiles (YYYYMMDD.log)
$logfiles = Get-ChildItem $ini["LOGPATH"] | Where-Object {$_.Name -match "^\d{8}.log$"}
$logstoredate = (Get-Date).AddMonths(-$ini["LOGSTORETIME"]).ToString('yyyyMMdd')
foreach ( $l in $logfiles ) {
    if ( ($l.Name).Split('.')[0] -lt $logstoredate ) {
        Remove-Item $l.FullName
    }
}

# STEP 4. Create logfile (
$log = Join-Path $ini["LOGPATH"] ( (Get-Date).ToString('yyyyMMdd') + ".log" )
if (!(Test-Path $log)) {
    New-Item -type file $log -force
}
# and simple function for logging to screen/logfile
function LogWrite($msg) {
    Add-Content $log ((get-date -format HH:mm:ss) + " " + $msg)
    Write-Output $msg
}
# and temporary report file
$report = Join-Path $ini["RPTPATH"] "report.txt" 
New-Item -type file $report -force

LogWrite("INFO`tStart")
LogWrite("INFO`tBackup {0} virtual machine(s) ({1}) to {2}"`
    -f $m.count, ($m -join ', '), $p)



LogWrite("INFO`tSuccessful Stop")