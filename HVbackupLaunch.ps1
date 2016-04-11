[cmdletbinding(SupportsShouldProcess=$True)]

# STEP 1. Read parameters from Command line or Pipeline
 Param (
        [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
        [ValidateNotNullorEmpty()]
		[Alias("Name")]
		[Alias("l")]
		[string[]]$VMList,
		
		[Parameter(Mandatory=$True)]
		[ValidateNotNullorEmpty()]
		[Alias("o")]
		[string[]]$Path
		) 

Begin {

# STEP 2. Read parameters from ini-file and set default values
$inifile = Join-Path $PSScriptRoot ( $MyInvocation.MyCommand.Name.Replace("ps1", "ini") )
if (!(Test-Path $inifile)) {
    echo("INI-file not found ({0}).`r`nRTFM`r`n" -f $inifile)
    exit(0)
}
$ini = ConvertFrom-StringData((Get-Content $inifile) -join "`r`n")
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
if (!($ini.ContainsKey("HVBACKUPEXE"))) { 
    echo("Set HVBACKUPEXE parameter in {0}.`r`nExample:`r`n" -f $inifile)
    echo("`t " + 'HVBACKUPEXE=c:\hvbackup101\HVBackup.exe --outputformat "{0}_{2:yyyyMMdd}.zip"')
    exit(0)
}
if (!($ini.ContainsKey("KEEPBACKUPS"))) { 
    echo("Set KEEPBACKUPS parameter in {0}.`r`nRecomended minimum:`r`n" -f $inifile)
    echo("`t KEEPBACKUPS=1")
    exit(0)
}
Write-Verbose "END: STEP 2. Read parameters from ini-file and set default values"

# STEP 3. Remove old logfiles (YYYYMMDD.log)
Get-ChildItem $ini["LOGPATH"] | Where-Object {$_.Name -match "^\d{8}.log$"}`
    | ? {$_.PSIsContainer -eq $false -and $_.lastwritetime -lt (get-date).adddays(-$ini["LOGSTORETIME"])}`
    | Remove-Item -Force
Write-Verbose "END: STEP 3. Remove old logfiles (YYYYMMDD.log)"

# STEP 4. Create logfile 
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

Add-Content $log ("--------------------------------------------------------------------------------")
LogWrite("INFO`tStart")
Write-Verbose "END: STEP 4. Create logfile - END Begin"

# variables initialisation 
$totalSuccess = 0
$totalError = 0
$totalVM = 0
$totalSize = 0
$elapsedTime = 0
$backupTime = 0
$totalTime = 0
$msgSummary = ''

} #End Begin

Process {

# STEP 5. Remove very old backups
foreach ($Name in $VMList) {
    $files = Get-ChildItem -Path (Join-Path $Path ($Name + "_*.*")) | sort desc
    for ($j=[int]$ini["KEEPBACKUPS"]; $j -lt $files.Count; $j++)
    {
        LogWrite("INFO`tDelete {0}" -f $files[$j].FullName)
        Remove-Item $files[$j].FullName
		Add-Content $log ("--------------------------------------------------------------------------------")
    }
}
Write-Verbose "END: STEP 5. Remove very old backups"

# STEP 6. Backup for every virtual machine
foreach ($Name in $VMList) {
    $cmd =  $ini["HVBACKUPEXE"] + ' -o ' + $Path + ' -l ' + $Name + ' 2>&1'
    LogWrite("INFO`tBackup {0}. Run: {1}`r`n" -f $Name.ToUpper(), $cmd)
    $cmdResult = invoke-expression $cmd
    LogWrite($cmdResult | out-string)
	$cmdResultStr = $cmdResult | out-string
    # get error
	if ($cmdResultStr.Contains("Error:")) {
			$totalError = $totalError + 1
            $totalVM = $totalVM + 1
			$error = $cmdResult | Select-String 'Error:' -SimpleMatch
	LogWrite("INFO`tERROR HVBackup {0}. {1}" -f $Name, [String]$error)
	Write-Verbose "ERROR: STEP 6. Error HVBackup: $Name, [String]$error"
	Add-Content $log ("--------------------------------------------------------------------------------")
	}
	else {
	# get summary
	$elapsedTime = $cmdResult | Select-String 'Elapsed time:' -SimpleMatch | ForEach-Object {$_ -replace "Elapsed time: ", ""} 
    if ($elapsedTime.ToString().Length -gt 0)
    {
        $file = Join-Path $Path ($Name + '_' + (get-date -format yyyyMMdd) + '.zip')
        if (Test-Path $file) 
        { 
            $totalVM = $totalVM + 1
            $totalSuccess = $totalSuccess + 1
			$size = ((Get-Item $file).length/1GB)
            $totalSize += $size
			$backupTime = [TimeSpan]$elapsedTime.substring(0,8)
			$totalTime += $backupTime
            $msgSummary += $file + "`t`t" + "{0:N1}" -f $size + "Gb`t`t" + $backupTime.ToString("hh\:mm\:ss") + "`r`n"
        }
		LogWrite("INFO`tSUCCESS HVBackup {0} in {1}, Size: {2:N1} Gb" -f $Name, $backupTime.ToString("hh\:mm\:ss"), $Size)
		Add-Content $log ("--------------------------------------------------------------------------------")
		Write-Verbose "SUCCESS: STEP 6. Success HVBackup: $Name, $elapsedTime, $Size"
    }
	}
}
Write-Verbose "INFO: STEP 6. End VM backup"

} #End Process

End {

LogWrite("INFO`tSuccessful Stop")
Write-Verbose "END: STEP 6. Backup for every VM"

# write summary
$msgSubject = ('HVbackup {0} to {1}. Success: {2}/{3}, Error: {4} in {5} Size: {6:N1} Gb'`
    -f (Get-Item env:\Computername).Value, [string]$Path, $totalSuccess, $totalVM, $totalError, $totalTime.ToString("hh\:mm\:ss"), $totalSize)
Add-Content $report ($msgSubject + "`r`n`r`n" + $msgSummary)
Write-Verbose "END: STEP 6. Summary: $msgSubject"
Write-Verbose "END: STEP 6. Detail: $msgSummary"

# log summary
LogWrite("`r`n--------------------------- Summary -------------------------------`r`n")
LogWrite("SUMM`t{0}`r`n`r`n{1}"`
	-f $msgSubject,$msgSummary)
	
# STEP 7. (optional) Send summary report
if ($ini.ContainsKey("MAILADDRESS") -and $ini.ContainsKey("MAILSERVER"))  {
    $msg = New-Object Net.Mail.MailMessage($ini["MAILADDRESS"], $ini["MAILADDRESS"])
    $msg.Subject = $msgSubject
    $msg.Body = ((Get-Content $report) -join "`r`n")`
         + "`r`n----------------------- Detailed Log -------------------------------`r`n`r`n"`
         + ((Get-Content $log) -join "`r`n")
    $smtp = New-Object Net.Mail.SmtpClient("")
    if ($ini["MAILSERVER"].Contains(":")) {
        $mailserver = $ini["MAILSERVER"].Split(":")
        $smtp.Host = $mailserver[0]
        $smtp.Port = $mailserver[1]
    }
    else {
        $smtp.Host = $ini["MAILSERVER"]
    }
    #$smtp.EnableSsl = $true 
    if ($ini.ContainsKey("MAILUSER") -and $ini.ContainsKey("MAILPASSWORD"))  {
        $smtp.Credentials = New-Object System.Net.NetworkCredential($ini["MAILUSER"], $ini["MAILPASSWORD"]); 
    }
	try {   
    $smtp.Send($msg)
	LogWrite("INFO`t... Success: sent e-mail summary")
	} 
	catch { 
	LogWrite("INFO`t... Error sending e-mail summary: {0}"`
	-f $($_.Exception.Message))
	}
}
Write-Verbose "END: STEP 7. (optional) Send summary report"
Add-Content $log ("--------------------------------------------------------------------------------")
} #End End
