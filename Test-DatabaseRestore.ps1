<#

.SYNOPSIS
    Tests restores from SQL Server backup files from the Cohesity SMB drive onto the instance specified by $RestoreInstance
  
.DESCRIPTION
    SQL Server backups are created in the SMB file share "'\\cohesity<DomainDependent>\DatabaseBackups\SQLBackups\<Instance>\<Database>".
    This script will take the files stored in those folders and use them to restore to a database with the name <Instance>__<Database>, within the instance $RestoreInstance.
    For transaction log restores, if there was no data changed, then the logs will be skipped.

.PARAMETER Instance
    Description   : The instance that you want to restore. Use this when you want to restore from a single instance, or you can specify more than one, when separated by commas.
    Valid Values  : Any valid instance which is backing up to Cohesity.
    Default Value : None

    
.PARAMETER InstanceListFile
    Description   : Specify a file which contains the list of instances you wish to restore.
    Valid Values  : File name which contains list of instances
    Default Value : None
    

.PARAMETER InstanceListRegistered
    Description   : Specify the Registered Server Group (on mssqldba-ym) which contains the instances you wish to restore.
    Valid Values  : Cohesity Backups, Environment\Prod, Environment\Test
    Default Value : None


.PARAMETER Database
    Description   : Database(s) to restore
    Valid Values  : Any valid databases within the specified instance.
    Default Value : None
    Note          : Can pass in a comma delimited list as well. If a database name is not specified, all databases in the instance (with backup files in Cohesity) will be restored.

    
.PARAMETER BackupCreatedInPastXHours
    Description   : Look only for backup files created in the past X hours
    Valid Values  : 1-72
    Default Value : 24


.PARAMETER PointInTime
    Description   : Specifies a Point-in-Time (PIT) Restore
    Valid Values  : A datetime in the format "YYYY-MM-DD HH:MM:SS"
    Default Value : None


.PARAMETER MaxDatabaseSizeMB
    Description   : Do not attempt a restore if the database is over specified size, in MB
    Valid Values  : Any Integer
    Default Value : None
    Note          : Not yet implemented, will need to read file header to determine backup size


.PARAMETER OutputScriptOnly
    Description   : Generate SQL for source database restore; do not actually run the restore.
    Valid Values  : Switch
    Default Value : False
    

.PARAMETER CheckIntegrity
    Description   : Run DBCC CHECKDB after database is restored
    Valid Values  : Switch
    Default Value : False

   
.PARAMETER CohesityNode
    Description   : Specify a single Cohesity node to restore from. "All"=All Nodes.
    Valid Values  : 1,2,3,4
    Default Value : All
    Note          : Just for testing, really, possibly applicable for load balancing.


.PARAMETER NoDrop
    Description   : Do NOT drop the database after doing the restore. 
    Valid Values  : Switch
    Default Value : False
    Note          : Use with caution, we only have 1TB of disk to restore to.


.PARAMETER VerifyOnly
    Description   : Run a "Verify Only" restore, which reads the backup header and file for integrity but does not actually do the restore.
    Valid Values  : Switch
    Default Value : False
    Note          : Needs work, right now it is not isolated, and there is also a similar switch on Restore-DBADatabase


.PARAMETER UseLegacyCohesityBackupPath
    Description   : The Legacy path refers to the path \\cohesity-yak-m1.yvmh.org\DatabaseBackups\SQLBackups; this is where backups went before we split them into prod and non-prod.
    Valid Values  : Switch
    Default Value : False
    Note          : Memorial-specific, and this won't be useful for much longer. 


.PARAMETER MemParmMaxTransferSize
    Description   : The value for the SQL Server Backup/Restore memory parameter MaxTransferSize. This value specifies the unit of transfer.
    Valid Values  : Multiples of 65536, up to 4194304 bytes 
    Default Value : 65536
    Note          : 


.PARAMETER MemParmBufferCount
    Description   : The value for the SQL Server Backup/Restore memory parameter BufferCount. This value specifies the number of buffers to use for the restore.
    Valid Values  : 1 - Memory Dependent; BufferCount x MaxTransferSize = total memory required (plus some overhead).
    Default Value : 7
    Note          : When I've used over 200, I got memory outage errors.


.PARAMETER MemParmBlockSize
    Description   : The value (in bytes) for the SQL Server Backup/Restore memory block size
    Valid Values  : Multiples of 512, from 512 to 65536.
    Default Value : 512
    Note          : Typically 512 is fine. Some have said that 65536 works better with SAN.


.PARAMETER ShowResults
    Description   : Display a short summary of results after each backup restore completes
    Valid Values  : Switch
    Default Value : False
    Note          : All results are logged to table VM_DBA_RestoreTests:RestoreTest_Results
    

.PARAMETER ShowRestoreCommands
    Description   : Display Restore Commands Used for each database
    Valid Values  : Switch
    Default Value : False
    Note          : 


.PARAMETER ShowRestoreCommandsToFile
    Description   : Sends restore commands to the database directory on Cohesity
    Valid Values  : Switch
    Default Value : False
    Note          : File format is Restore_{instance}_{database}_YYYYMMDD-HHMM, where the timestamp represents the time the commands were generated. Example: Restore_memorialdb_vm_dba_tools_20180313-1315



.PARAMETER ExcludeSystemDatabases
    Description   : When restoring all databases in an instance, do not restore system databases (msdb,model). Note that tempdb and master is never restored.
    Valid Values  : Switch
    Default Value : False
    Note          : Master database cannot be restored to a higher version. We might look at allowing it if versions are ok, will require file header reading.


.PARAMETER ExcludeLogBackups
    Description   : Do not apply transaction log backups to the restore.
    Valid Values  : Switch
    Default Value : False


.PARAMETER OHMSAware
    Description   : Pass in the -MaintenanceSolutionBackup flag to Restore-DBADatabase
    Valid Values  : Switch
    Default Value : False
    Note          : Required when ignoring log backups, but not required to explicitly pass in. Still figuring this one out. 
    

.PARAMETER ShowDatabases
    Description   : List all of the subdirectories under the specified instance
    Valid Values  : Switch
    Default Value : False
    Note          : Has nothing to do with the restore, just for seeing what's available to restore.


.PARAMETER ReadFileHeaders
    Description   : Read headers on each of the files involved in the restore and put them in tables
    Valid Values  : Switch
    Default Value : False
    

.PARAMETER ExcludeDiffBackup
    Description   : Do not apply the differential backup file
    Valid Values  : Switch
    Default Value : False


    
.EXAMPLE

    .\Test-DatabaseRestore -Instance memorialsql -database Abacus,Ascend -verbose

    Restore two databases from the instance 'memorialsql'


.EXAMPLE

    .\Test-DatabaseRestore -Instance memorialsql,memorialdb -database vm_dba_tools,msdb -verbose

    Restore two databases from the instances 'memorialsql' and 'memorialdb'.  Note that this only works if those databases are present on both instances. If not, you will get errors. 


.EXAMPLE

    .\Test-DatabaseRestore.ps1 -Instance memorialdb -Database intranet -verbose -PointInTime "2018-03-14 07:30:00"

    Does a point in time restore.





.NOTES  
    File Name    : Test-DatabaseRestore.ps1  
    Author       : Johnny London, VMMH
    Date Created : 2018-01-30
    Version .90
    
    The -verbose parameter is supported, and will output SQL statements and other additional info.

#>

<#
.TODO
    -Point in time fails on simple; don't allow that
    --Standby restore script generate
    -For Tail of Log restore, need to get file names from file header
        select top(1) logicalname from backupfilelist where runid = 698 and type = 'D'
        select top(1) logicalname from backupfilelist where runid = 698 and type = 'L'
    -
#>




[CmdletBinding()]

Param(

[Parameter (Mandatory=$false)]
[String[]] $Instance,

[Parameter (Mandatory=$false)]
[String[]] $Database,

[Parameter (Mandatory=$false)]
[String] $InstanceListFile,

[Parameter (Mandatory=$false)]
[ValidateSet("Cohesity Backups","Environment\Test","Environment\Prod")]
[String] $InstanceListRegistered,

[Parameter (Mandatory=$false)]
[String] $BackupCreatedInPastXHours,

[Parameter (Mandatory=$false)]
[String] $BackupCreatedSince,

[Parameter (Mandatory=$false)]  #Note: The restore will fail if the database is not FULL recovery model
[String] $PointInTime,

[Parameter (Mandatory=$false)]  
[String] $MaxFileSizeMB,

[Parameter (Mandatory=$false)]
[Switch] $OutputRestoreToSourceScriptOnly,

[Parameter (Mandatory=$false)]
[Switch] $CheckIntegrity=$false,

[Parameter (Mandatory=$false)]
[ValidateSet(1,2,3,4,"All")]
[String] $CohesityNode="All",

[Parameter (Mandatory=$false)]
[Switch] $NoDrop=$false,

[Parameter (Mandatory=$false)]
[Switch] $VerifyOnly=$false,

[Parameter (Mandatory=$false)]
[Switch] $UseLegacyCohesityBackupPath=$false,

[Parameter (Mandatory=$false)]
[ValidateSet(65536,131072,262144,1048576,2097152,4194304)]
[int] $MemParmMaxTransferSize=65536,

[Parameter (Mandatory=$false)]
[int] $MemParmBufferCount=7,

[Parameter (Mandatory=$false)]
[ValidateSet(512,1024,2048,4096,8192,16384,32768,65536)]
[int] $MemParmBlocksize=512,

[Parameter (Mandatory=$false)]
[switch] $ShowResults,

[Parameter (Mandatory=$false)]
[switch] $ShowRestoreCommands,

[Parameter (Mandatory=$false)]
[switch] $ShowRestoreCommandsToFile,

[Parameter (Mandatory=$false)]
[switch] $ExcludeSystemDatabases,

[Parameter (Mandatory=$false)]
[switch] $ExcludeLogBackups,

[Parameter (Mandatory=$false)]
[switch] $OHMSAware,

[Parameter (Mandatory=$false)]
[switch] $ShowDatabases,

[Parameter (Mandatory=$false)]
[switch] $ReadFileHeaders,

[Parameter (Mandatory=$false)]
[switch] $ExcludeDiffBackup,

[Parameter (Mandatory=$false)]
[switch] $RptInfoIsUnattendedRun,

[Parameter (Mandatory=$false)]
[string] $RptInfoEnvironment


)




Function RestoreVerifyOnly {

    #Run a Restore Verify Only on the backup file to see if it checks out ok, and to time how long it takes

    [Parameter (mandatory=$true)]
    [String] $DatabaseBackupPath,

    [Parameter (mandatory=$true)]
    [String] $RestoreInstance

    
    $File=(Get-ChildItem "$DatabaseBackupPath\FULL" -recurse -include *.bak | ? {  $_.LastWriteTime -gt "$BackupCreatedSince" }  | select-object name |ft -HideTableHeaders |out-string).trim()

    $SQLCmd="Insert into RestoreTest_Results_VerifyOnly (RunID,StartTime) values ($RunID,getdate())"
    Write-Verbose $SQLCmd
    Invoke-dbasqlquery -SqlInstance dba-sql-restore -database VM_DBA_RestoreTest -Query $SQLCmd

    $SQLCmd="RESTORE VERIFYONLY FROM DISK = N'" + $DatabaseBackupPath + "\FULL\" + $file + "' WITH CHECKSUM"
    Write-Verbose $SQLCmd
    Invoke-dbasqlquery -SqlInstance dba-sql-restore -database VM_DBA_RestoreTest -Query $SQLCmd

    $SQLCmd="Update RestoreTest_Results_VerifyOnly set FinishTime = getdate() where RunID = $RunID"
    Write-Verbose $SQLCmd
    Invoke-dbasqlquery -SqlInstance dba-sql-restore -database VM_DBA_RestoreTest -Query $SQLCmd

} # Function RestoreVerifyOnly



Function ReadHeaders {

    $SubDirs=@('FULL','DIFF','LOG')

    ForEach ($SubDir in $SubDirs) {
    
        $DatabaseBackupPathDir =$DatabaseBackupPath + "\" + $SubDir
    
        Write-Verbose "Testing Existence of $DatabaseBackupPathDir ..."

        if (!(Test-Path $DatabaseBackupPathDir)) {

            Write-Verbose "$DatabaseBackupPathDir does NOT exist"

            Continue

        } #If
                                       
        
        Get-ChildItem "$DatabaseBackupPathDir" -recurse -include *.bak,*.trn | ? {  $_.LastWriteTime -gt "$BackupCreatedSince" }  | select-object name,LastWriteTime | sort-object -property name |
        
        ForEach-Object  { 
        
            #First, get the header info

            $FilePath= $DatabaseBackupPathDir + '\' + $_.name  
        
            $SQLCmd="RESTORE HEADERONLY FROM DISK = '" + $FilePath + "'" ; Write-Verbose $SQLCmd
        
            Write-Verbose "Truncating table BackupHeaders_Work"
        
            Invoke-dbasqlquery -SqlInstance dba-sql-restore -database VM_DBA_RestoreTest -query "truncate table BackupFileHeaders_Work"
            
            $HeaderInfo=Invoke-dbasqlquery -SqlInstance dba-sql-restore -Query $SQLCmd | Select-Object MachineName,Servername,DatabaseName,BackupTypeDescription,BackupStartDate,BackupFinishDate,DatabaseBackupLSN,FirstLSN,LastLSN,HasBackupChecksums,BackupSize,Compressed,CompressedBackupSize,Softwareversionmajor,softwareversionminor,softwareversionbuild,DatabaseVersion,CompatibilityLevel,Beginslogchain,RecoveryModel | ConvertTo-DbaDataTable 
         
            Write-Verbose "HeaderInfo=$HeaderInfo"
         
            Write-Verbose "Write-DbaDataTable -SqlServer dba-sql-restore -InputObject $HeaderInfo -database VM_DBA_RestoreTest -Table BackupFileHeaders_Work"
         
            Write-DbaDataTable -SqlServer dba-sql-restore -InputObject $HeaderInfo -database VM_DBA_RestoreTest -Table BackupFileHeaders_Work
            
            $SQLCmd="INSERT INTO BackupFileHeaders SELECT $RunID," + "'" + $FilePath + "'" + ",'" + $_.LastWriteTime + "',* FROM BackupFileHeaders_Work"; Write-Verbose $SQLCmd
         
            Invoke-dbasqlquery -SqlInstance dba-sql-restore -database VM_DBA_RestoreTest -query $SQLCmd



            #Now get the filelist info

            $SQLCmd="RESTORE FILELISTONLY FROM DISK = '" + $FilePath + "'" ; Write-Verbose $SQLCmd
        
            Write-Verbose "Truncating table BackupFileList_Work"
        
            Invoke-dbasqlquery -SqlInstance dba-sql-restore -database VM_DBA_RestoreTest -query "truncate table BackupFileList_Work"

            Write-Verbose "Truncating table BackupFileList_Work Complete"

            
            $BackupFileList=Invoke-dbasqlquery -SqlInstance dba-sql-restore -Query $SQLCmd | Select-Object LogicalName,	PhysicalName,	Type,	FileGroupName,	Size,	MaxSize,	FileId,	CreateLSN,	DropLSN,	UniqueId,	ReadOnlyLSN,	ReadWriteLSN,	BackupSizeInBytes,	SourceBlockSize,	FileGroupId,	LogGroupGUID,	DifferentialBaseLSN,	DifferentialBaseGUID,	IsReadOnly,	IsPresent,	TDEThumbprint,	SnapshotUrl  | ConvertTo-DbaDataTable 
         
            
            Write-Verbose "Write-DbaDataTable -SqlServer dba-sql-restore -InputObject $BackupFileList -database VM_DBA_RestoreTest -Table BackupFileList_Work"
         
            Write-DbaDataTable -SqlServer dba-sql-restore -InputObject $BackupFileList -database VM_DBA_RestoreTest -Table BackupFileList_Work
            
            $SQLCmd="INSERT INTO BackupFileList SELECT $RunID, * FROM BackupFileList_Work" 
            
            Write-Verbose $SQLCmd
         
            Invoke-dbasqlquery -SqlInstance dba-sql-restore -database VM_DBA_RestoreTest -query $SQLCmd

            

            
            } #Foreach Backup Path

    } #Foreach subdirectory

} #Function ReadHeaders


Function CheckIntegrity {

    param(

        [Parameter (Mandatory=$false)]
        [String[]] $InstanceToRestore,

        [Parameter (Mandatory=$false)]
        [String[]] $DatabaseToRestore,

        [Parameter (Mandatory=$false)]
        [String[]] $RestoredDatabaseName

    )

    

    # Run DBCC against restored database

    #Skip system databases for now
    #if (($DatabaseToRestore -eq "master") -or ($DatabaseToRestore -eq "model") -or ($DatabaseToRestore -eq "msdb")) { Continue }
    
    #if (($DatabaseToRestore -eq "model") -or ($DatabaseToRestore -eq "msdb")) { Continue }
          
    
    $SQLCmd = "EXEC sp_RunDBCC " + [int]$RunID + "," + "'" + $InstanceToRestore + "'" + "," + "'" + $RestoredDatabaseName + "'" 
    Write-Verbose $SQLCmd
    
    write-output "Running DBCC against database $RestoredDatabaseName ..."

    try {
        Invoke-SQLCmd -ServerInstance dba-sql-restore -Database VM_DBA_RestoreTest -query $SQLCmd -QueryTimeout 3600
    }

    catch {
        Write-Host "DBCC Failed";exit
    }    
   
} # Function CheckIntegrity


Function New-InstanceList {

    #Create a list of instances to restore from

    #Eliminate invalid parameter combinations
    if ( $Instance -and $InstanceListFile ) { 
    
        write-verbose "InstanceListFile=$InstanceListFile"
        Write-Host; Write-Host 'Error: Parameters "-Instance" and "-InstanceListFile" cannot be used together.'; exit 
    
    }

    #Since there are a few different ways to specify the instance or instances to be restored, we will distill that list to the same file to be iterated: Test-DatabaseRestore_InstanceList.txt
    $InstanceWorkingFile="Test-DatabaseRestore_InstanceList.txt"

    #Single Instance
    if (($Instance) -and ($Instance -notcontains ",")) {
    
        Write-Verbose "Single Instance"; $instance > $InstanceWorkingFile 
    
    }

    #Two or more instances, comma-delimited
    if ($Instance -like '*,*') {
    
        Write-Verbose "Comma-delimted list of instances"; $InstancesInCommaDelimtedList= $Instance -split ',';    $InstancesInCommaDelimtedList > $InstanceWorkingFile
    
    }


    #Filename
    if ($InstanceListFile) { 
        
        Write-Verbose "Using file list for instances"; cat $InstanceListFile > $InstanceWorkingFile 
    
    }


    #Registered Servers
    If ($InstanceListRegistered) { 
        
        Write-Verbose "Using Registered List";  
        get-dbaregisteredserver -SqlInstance mssqldba-ym -Group "$InstanceListRegistered"  | select-object name | ft -HideTableHeaders > $InstanceWorkingFile 
    
        
        cat $InstanceWorkingFile
    }

    return $InstanceWorkingFile

} #Function CreateInstanceList



Function Update-RestoreTest_Results {

    param (

    
        [Parameter (Mandatory=$true)]
        [Object[]]$RestoreResults,

        [Parameter (Mandatory=$true)]
        [String[]] $RunID,

        [Parameter (Mandatory=$true)]
        [String[]] $RestoreHistoryID

    )


    # Initialize Counters
    $NumLogFiles=0
    $TotalMBLogFiles=0
    $TotalMBLogFilesCompressed=0
    $NumDiffFiles=0
    $TotalMBDiffFiles=0
    $TotalMBDiffFilesCompressed=0
    $NumFullFiles=0
    $TotalMBFullFiles=0
    $TotalMBDiffFilesCompressed=0


    Foreach ($Restore in $RestoreResults) {

        If ($Restore.BackupFile -like "*\LOG\*") {
            $NumLogFiles++
            $TotalMBLogFiles = $TotalMBLogFiles + $Restore.BackupSizeMB
            $TotalMBLogFilesCompressed = $TotalMBLogFilesCompressed + $Restore.CompressedBackupSizeMB
        }


        If ($Restore.BackupFile -like "*\DIFF\*") {
            
            $NumDiffFiles++
            $TotalMBDiffFiles = $TotalMBDiffFiles + $Restore.BackupSizeMB
            $TotalMBDiffFilesCompressed = $TotalMBDiffFilesCompressed + $Restore.CompressedBackupSizeMB
            $DiffBackupFileName=$Restore.BackupFile
        }

        If ($Restore.BackupFile -like "*\FULL\*") {
            
            $NumFullFiles++
            $TotalMBFullFiles = $TotalMBFullFiles + $Restore.BackupSizeMB
            $TotalMBFullFilesCompressed = $TotalMBFullFilesCompressed + $Restore.CompressedBackupSizeMB
            $FullBackupFileName=$Restore.BackupFile

        }

    
    } #Foreach

    Write-Verbose "Restore Object             : $Restore"
    Write-Verbose "Full File Name             : $FullBackupFileName"
    Write-Verbose "Total Full files           : $NumFullFiles"
    Write-Verbose "Total Full Size            : $TotalMBFullFiles"
    Write-Verbose "Total Full Size Compressed : $TotalMBFullFilesCompressed"
    Write-Verbose "Diff File Name             : $DiffBackupFileName"
    Write-Verbose "Total Diff files           : $NumDiffFiles"
    Write-Verbose "Total Diff Size            : $TotalMBDiffFiles"
    Write-Verbose "Total Diff Size Compressed : $TotalMBDiffFilesCompressed"
    Write-Verbose "Total Log files            : $NumLogFiles"
    Write-Verbose "Total Log Size             : $TotalMBLogFiles"
    Write-Verbose "Total Log Size Compressed  : $TotalMBLogFilesCompressed"


    

    # Write a detail record for the restore
    $SQLCmd = "Insert into RestoreTest_Results_Detail values ($RunID,'$FullBackupFileName',$TotalMBFullFiles,$TotalMbFullFilesCompressed,'$DiffBackupFileName',$TotalMBDiffFiles,$TotalMBDiffFilesCompressed,$TotalMBLogFiles,$TotalMbLogFilesCompressed,$NumLogFiles)"
    Write-Verbose $SQLCmd
    Invoke-dbasqlquery -SqlInstance dba-sql-restore -Database VM_DBA_RestoreTest -Query $SQLCmd


    $RestoreDatabase=      ($RestoreResults.DatabaseName    | out-string).trim()
    $RestoreResult=        ($RestoreResults.RestoreResult   | out-string).trim()
    $RestoreDatabaseSize=  ($RestoreResults.Size            | out-string).trim()
    $RestoreBackupSizeMB=  ($RestoreResults.BackupSizeMB    | out-string).trim()
    $RestoreTotalFilesUsed=($RestoreResults.BackupFilesCount| out-string).trim()
    $RestoreComplete=      ($RestoreResults.RestoreComplete | out-string).trim()


    If ($RestoreComplete) { 

        $RestoreResult = "Success" 

    } else {

        $RestoreResult = "Fail"

    }

    # Get database recovery model
    $SQLCmd = "select recovery_model_desc from sys.databases where name = '" + $RestoredDatabaseName + "'"
    Write-Verbose $SQLCmd
    $RecoveryModel=(Invoke-dbasqlquery -SqlInstance dba-sql-restore -Database VM_DBA_RestoreTest -Query $SQLCmd | ft -HideTableHeaders | out-string -Stream).trim()
    

    $SQLCmd="UPDATE RestoreTest_Results SET RestoreFinishTime = getdate(),RecoveryModel='$RecoveryModel',RestoreResult='$RestoreResult',MSDB_Restore_History_ID='$RestoreHistoryID',MaxTransferSize=$MemParmMaxTransferSize,BufferCount=$MemParmBufferCount,BlockSize=$MemParmBlockSize where RunID = " + $RunID
    Write-Verbose $SQLCmd
    Invoke-dbasqlquery -ServerInstance dba-sql-restore -Database VM_DBA_RestoreTest -query $SQLCmd 

    $SQLCmd="UPDATE RestoreTest_Results SET RestoreETSeconds=DATEDIFF(ss,RestoreBeginTime,RestoreFinishTime) where RunID = " + $RunID
    Write-Verbose $SQLCmd
    Invoke-dbasqlquery -ServerInstance dba-sql-restore -Database VM_DBA_RestoreTest -query $SQLCmd 
                

    #Get restored database size
    $SQLCmd = "select (cast (sum(size) as bigint) *8192/1024/1024) as cnt from sys.master_files where database_id = (select database_id from sys.databases where name = '" + $RestoredDatabaseName + "')" 
    Write-Verbose $SQLCmd

    $DBSizeMB=(Invoke-dbasqlquery -ServerInstance dba-sql-restore -database master -query $SQLCmd)

    $size=$DBSizeMb.cnt
    
    $SQLCmd="UPDATE RestoreTest_Results SET DatabaseSizeMB=$size WHERE RunID = " + $RunID
    Write-Verbose $SQLCmd
    Invoke-dbasqlquery -ServerInstance dba-sql-restore -Database VM_DBA_RestoreTest -query $SQLCmd 

    
} #Function Update-RestoreTest_Results 


Function Log-Params {

if ($CheckIntegrity) {$CheckIntegrityVal=1} else { $CheckIntegrityVal=0}
if ($ExcludeLogBackups) {$ExcludeLogBackupsVal=1} else { $ExcludeLogBackupsVal=0}
if ($ExcludeDiffBackup) {$ExcludeDiffBackupVal=1} else { $ExcludeDiffBackupVal=0}
if (!$PointInTime) {$PointInTimeVal='None'} 
    

 $SQLCmd="insert into RestoreTest_Parameters values($ScriptRunID,'$PointInTimeVal',$CheckIntegrityVal,'$CohesityNode',$MemParmMaxTransferSize,$MemParmBufferCount,$MemParmBlockSize,$ExcludeLogBackupsVal,$ExcludeDiffBackupVal)"

 Write-Verbose $SQLCmd


 invoke-dbasqlquery -SqlInstance dba-sql-restore -Database VM_DBA_RestoreTest -Query $SQLCmd

}



# ------------------- MAIN --------------------


$ErrorActionPreference="Continue"


cd D:\vmmc\bin\PowerShell\mssql_scripts\VM_DBA_RestoreTest


#Read configuration file
. .\Test-DatabaseRestore_CFG.ps1








#Import the dbatools module
remove-module -name dbatools 2> $null
import-module -name dbatools 

#Get the list of instances to restore
$InstanceWorkingFile=New-InstanceList

Write-Verbose "InstanceWorkingFile=$InstanceWorkingFile"

#Set Clauses from parameters

If ($PointInTime) { 

    $PointInTimeClause = "-RestoreTime ""$PointInTime""" 


    #We need to go back 24 hours before the specified point in time to ensure that we get a full
    $EndDate=Get-Date $PointInTime
    $BackupCreatedSince=$EndDate.AddDays(-1).ToString("yyyy-MM-dd hh:mm:ss")
    
    
 }

If ($OutputRestoreToSourceScriptOnly) {

    $OutputScriptOnlyClause=" -OutputScriptOnly"

}

If (!($CheckIntegrity)) {

    $CheckIntegrityClause="-NoCheck" 

}

IF ($MaxDatabaseSizeMB) {

    $MaxDatabaseSizeMBClause="-maxmb " + $MaxDatabaseSizeMB    

}

If (!($MaxDatabaseSizeMB)) {

    $MaxDatabaseSizeMB = -1
    
}


if ($ExcludeLogBackups) {

    $IgnoreLogBackupClause="-IgnoreLogBackup"
    $OHMSAwareClause="-MaintenanceSolutionBackup"
}


if ($OHMSAware) {

    $OHMSAwareClause="-MaintenanceSolutionBackup"
}



#Set a default of 24 hours for $BackupCreatedSince

if (! $BackupCreatedSince) {
    
    Write-VErbose "BackupCreatedSince is null - setting it to 24 hours ago"
    $BackupCreatedSince = (Get-Date).AddHours(-24) 

}

if ($BackupCreatedInPastXHours) {

        $BackupCreatedSince = (Get-Date).AddHours(-$BackupCreatedInPastXHours)

}


write-verbose "BackupCreatedSince=$BackupCreatedSince"

if ($RptInfoIsUnattendedRun) {

    $RptInfoIsUnattendedRunVal=1
}

else {

    $RptInfoIsUnattendedRunVal=0
    
    }



if ($RptInfoEnvironment) {

    $RptInfoEnvironmentVal=$RptInfoEnvironment
}

else {

    $RptInfoEnvironmentVal="Unspecified"
    
    }





#Log the script run so we can easily get most recent run for reports

$SQLCmd="INSERT INTO RestoreTest_ScriptRun(ScriptBeginTime,RptInfoisUnattendedRun) VALUES (getdate(),$RptInfoIsUnattendedRunVal)"
    Write-Verbose $SQLCmd 
    Invoke-dbasqlquery -ServerInstance dba-sql-restore -Database VM_DBA_RestoreTest -query $SQLCmd 
              

    $SQLCmd="select ident_current ('RestoreTest_ScriptRun')"
    Write-Verbose $SQLCmd 
    $ScriptRunID = Invoke-dbasqlquery -ServerInstance dba-sql-restore -Database VM_DBA_RestoreTest -query $SQLCmd | select -expand column1

    Write-Verbose "ScriptRunID=$ScriptRunID"


    #Log the parameters passed in
        Log-Params
        



# The main loop - process each specified instance...
    

ForEach ($InstanceToRestore in Get-Content $InstanceWorkingFile ) {

    $Line="-"*120
    $Line

    write-Verbose "InstanceToRestore=$InstanceToRestore"

    if ($InstanceToRestore -eq [String]::Empty){
    
        Continue
    
    }

    $InstanceToRestore=($InstanceToRestore).trim()
    
    #Folders where the restored database files will go.
    $DataDirectory = "D:\SQLData\" + $InstanceToRestore
    $LogDirectory  = "D:\SQLLogs\" + $InstanceToRestore

       
    #BackupPath is the Cohesity Base Path plus the Instance Name
    #Set the appropriate BackupFileParentDirectory according if instance is Prod or NonProd
    
    Write-Verbose "InstanceToRestore=$InstanceToRestore"

    #If the Instance is a named instance, it has a backslash in it; we need to escape that to find it.

    $InstanceToRestoreSearchString=$InstanceToRestore.Replace("\","\\")



    # Right now, we have two files with instances listed, based on whether it is prod or non-prod.
    # I don't like this, but it will do for now.
    
    if (sls $InstanceToRestoreSearchString InstanceList_NonProd.txt) {

        $BackupFileParentDirectory = $CohesityPathNonProd

        $RptInfoEnvironment="NonProd"
    } 

    if (sls $InstanceToRestoreSearchString InstanceList_Prod.txt) {

        $BackupFileParentDirectory = $CohesityPathProd
        
        Write-Verbose "BackupFileParentDirectory=$BackupFileParentDirectory"

        $RptInfoEnvironment="Prod"
    }


    if ($UseLegacyCohesityBackuppath) {
        
        $BackupFileParentDirectory = $CohesityPathLegacy

    }

    

    #Insert starting row into instance run table...
    
    $SQLCmd="INSERT INTO RestoreTest_InstanceRun(RestoreBeginTime,RptInfoEnvironment) VALUES (getdate(),'$RptInfoEnvironment')"
    Write-Verbose $SQLCmd 
    Invoke-dbasqlquery -ServerInstance dba-sql-restore -Database VM_DBA_RestoreTest -query $SQLCmd 
              

    $SQLCmd="select ident_current ('RestoreTest_InstanceRun')"
    Write-Verbose $SQLCmd 
    $InstanceRunID = Invoke-dbasqlquery -ServerInstance dba-sql-restore -Database VM_DBA_RestoreTest -query $SQLCmd | select -expand column1

    Write-Verbose "InstanceRunID=$InstanceRunID"

    #Add instance id to the script run table
    $SQLCmd="INSERT INTO RestoreTest_ScriptRunDetail(ScriptRunID, InstanceRunID) VALUES ($ScriptRunID, $InstanceRunID)"
    Write-Verbose $SQLCmd 
    Invoke-dbasqlquery -ServerInstance dba-sql-restore -Database VM_DBA_RestoreTest -query $SQLCmd 
        


       
    
        
    Write-Verbose "CohesityNode=$CohesityNode"
    
    Switch ($CohesityNode) {

            "1" {$DatabaseBackupPath=$CohesityRootPath_Node1 + $BackupFileParentDirectory}
            "2" {$DatabaseBackupPath=$CohesityRootPath_Node2 + $BackupFileParentDirectory}
            "3" {$DatabaseBackupPath=$CohesityRootPath_Node3 + $BackupFileParentDirectory}
            "4" {$DatabaseBackupPath=$CohesityRootPath_Node4 + $BackupFileParentDirectory}
            "All" {$DatabaseBackupPath=$CohesityRootPath + $BackupFileParentDirectory}
        }


    Write-Verbose "DatabaseBackupPath=$DatabaseBackupPath"
    
    if (! $BackupFileParentDirectory ) {

        Write-Output "BackupFileParentDirectory is null - Check files InstanceList_NonProd.txt and InstanceList_Prod.txt"
        exit

    }

    Write-Verbose "BackupFileParentDirectory=$BackupFileParentDirectory"


    #Change backslash to dollar sign, this is how OHMS annotates named instances
    $InstanceToRestore=$InstanceToRestore.replace("\","$")

    $BackupPath       = $DatabaseBackuppath + $InstanceToRestore 
    
    Write-Verbose "BackupPath=$Backuppath"
    
    
    if (!(Test-Path $BackupPath)) {
            
        Write-Verbose "BackupPath:$BackupPath does not exist" 
        exit 

    }

    if ($ShowDatabases) {

        get-childitem $BackupPath -Recurse -Filter "*.bak"
        exit
    }
    
    
    # Get Databases
    # If -Database is passed in, we'll use it
    # Since there are a few different ways to specify the database or databases to be restored, we will distill that list to the same file to be iterated: Test-DatabaseRestore_DatabaseList.txt
    
    $DatabaseWorkingFile="Test-DatabaseRestore_DatabaseList.txt"

    #Single Database
    if ($Database -notcontains ",") { 
    
        Write-Verbose "Single Database Name Passed In: $Database"

        $Database > $DatabaseWorkingFile 

    }

    
    # Two or more databases, comma-delimited
    
    If ($Database -like '*,*') {
        
        $DatabasesInCommaDelimtedList= $Database -split ','
        
        $DatabasesInCommaDelimtedList > $DatabaseWorkingFile  
    
    }
        
    
    # Database Not Specified, so all databases for the specified instance
    # Get all of the database subdirectory names for this instance

    If ([string]::IsNullOrEmpty($Database)) { 
               
        $DatabasesToRestore = (Get-ChildItem $BackupPath | Sort-Object -Property column1 | Format-Table -HideTableHeaders name | Out-String -Stream).Trim() > $DatabaseWorkingFile
    
    }


    # Now we have a list of databases in our working file.  Loop through each database to restore.
    ForEach ($DatabaseToRestore in get-content $DatabaseWorkingFile ) {
        
        if ($DatabaseToRestore -eq [String]::Empty){

            Continue

        }
            

        If ($ExcludeSystemDatabases) {

            if ($DatabaseToRestore -eq "master" -or $DatabaseToRestore -eq "msdb" -or $DatabaseToRestore -eq "model") {

                Continue

            }

        }

        
        #Exclude master for now, getting filestream error
        #This is because Master database cannot be restored to a higher version
                
        if ($DatabaseToRestore -eq "master") {

            Continue

        }
        
                
        Write-Verbose "Restoring database ${InstanceToRestore}:${DatabaseToRestore} ..."


        #Set all possible paths

        $DatabaseBackupPath="${BackupPath}\${DatabaseToRestore}"
        $DatabaseBackupPath_Node1=$BackupPath_Node1 + "\" + $DatabaseToRestore
        $DatabaseBackupPath_Node2=$BackupPath_Node2 + "\" + $DatabaseToRestore
        $DatabaseBackupPath_Node3=$BackupPath_Node3 + "\" + $DatabaseToRestore
        $DatabaseBackupPath_Node4=$BackupPath_Node4 + "\" + $DatabaseToRestore

        
        #Prepend the database name with the instance name so it will be clear in SSMS, and to eliminate duplicate naming issue

        # In Ola structures, Named instances have a '$' separating the server name from the instance name.
        # That doesn't work so well within a PS script
        # So, if an instance name has a $in it, let's replace that with an underscore
        # $InstanceToRestorePrefix=$InstanceToRestore -replace '`$', '`$'

        $InstanceToRestorePrefix=($InstanceToRestore).Replace('$', '_')

        Write-Verbose "InstanceToRestorePrefix=$InstanceToRestorePrefix"

        $RestoredDatabaseName = $InstanceToRestorePrefix.trim() + "__" + $DatabaseToRestore
                
        Write-Verbose "RestoredDatabaseName=$RestoredDatabaseName"
        
        Write-Verbose "DatabaseBackupPath=$DatabaseBackupPath"
        
                        
        $FullBAckupPath="${DatabaseBackupPath}\FULL"

        write-verbose "FullBackupPath=$FullBackupPath"

        #Do we have any backup files for this database?
        if (!(Test-Path $FullBackupPath)) {
                   
            Write-Host "FullBackupPath $FullBackupPath does NOT exist."

            Continue

         }

        
        $IncludeFiles=("*.bak")

        $NumFulls=(Get-ChildItem $FullBackupPath -Include $IncludeFiles -Recurse | ? { $_.LastWriteTime -gt "$BackupCreatedSince" })

        If ([string]::IsNullOrEmpty($NumFulls)) {            

            Write-Host
            Write-Host "WARNING: There are no .bak files in $FullBackupPath that have been created since $BackupCreatedSince ."
            Continue

        }
        

        # BUILD THE RESTORE COMMAND 

        Write-Verbose "Build Restore Command"
                
        #Replace Any dollar signs with underscore
        #This is for databases like "ReportServer$TELETRACKER"

        $RestoredDatabaseName=$RestoredDatabaseName.replace("$","_")

        Write-Verbose "DatabaseBackupPath=$DatabaseBackupPath"
        

        
        $IncludeFiles=("*.trn")
        #Good start, but I just want the ones since the last full or diff

        Write-Verbose "BackupCreatedSince=$BackupCreatedSince"

        Get-ChildItem -path $DatabaseBackupPath -Include $IncludeFiles -Recurse | ? { $_.LastWriteTime -gt "$BackupCreatedSince" }  > t_numlogs

        $NumLogs=0

        if (Test-Path .\t_numlogs) {
            $NumLogs=(get-content t_numlogs | sls -SimpleMatch 'trn' | measure-object).Count
        }
        
               
        $ExcludeFiles=(".junk")

        if ($ExcludeDiffBackup) {

            $ExcludeFiles=("*DIFF*")

        }

        
        if (! $MaxFileSizeMB) {
            $MaxFileSizeMB=1000000000
        }

        $IncludeFiles=("*.bak,*.trn")

        $RestoreCommand="Get-ChildItem '$DatabaseBackupPath' -Include $IncludeFiles -Exclude $ExcludeFiles -Recurse | ? { `$_.LastWriteTime -gt ""$BackupCreatedSince"" } | sort-object -property name | Restore-DbaDatabase -SqlInstance $RestoreInstance -DestinationDataDirectory $DataDirectory -DestinationLogDirectory $LogDirectory -DatabaseName ""${RestoredDatabaseName}"" -WithReplace $PointInTimeClause $OutputScriptOnlyClause $IgnoreLogBackupClause -BlockSize $MemParmBlockSize -MaxTransferSize $MemParmMaxTransferSize -BufferCount $MemParmBufferCount $OHMSAwareClause "
        #$RestoreCommand="Get-ChildItem '$DatabaseBackupPath' -Include $IncludeFiles -Exclude $ExcludeFiles -Recurse | ? { `$_.LastWriteTime -gt ""$BackupCreatedSince"" } | ? {( `$_.Length /1MB) -lt $MaxFileSizeMB } | sort-object -property name | Restore-DbaDatabase -SqlInstance $RestoreInstance -DestinationDataDirectory $DataDirectory -DestinationLogDirectory $LogDirectory -DatabaseName ""${RestoredDatabaseName}"" -WithReplace $PointInTimeClause $OutputScriptOnlyClause $IgnoreLogBackupClause -BlockSize $MemParmBlockSize -MaxTransferSize $MemParmMaxTransferSize -BufferCount $MemParmBufferCount $OHMSAwareClause"


        Write-Verbose "Get-ChildItem -path ""$DatabaseBackupPath"" -Include $IncludeFiles -Exclude $ExcludeFiles -Recurse | ? { `$_.LastWriteTime -gt ""$BackupCreatedSince"" }"

        #Get-ChildItem -path "$DatabaseBackupPath" -Include ""$IncludeFiles"" -Exclude $ExcludeFiles -Recurse | ? { `$_.LastWriteTime -gt "$BackupCreatedSince" } | sort-object -property name > t_FilesToRestore

        #Get-ChildItem -path "$DatabaseBackupPath" -Recurse -Include "$IncludeFiles" | ? { $_.LastWriteTime -gt "$BackupCreatedSince" } | sort-object -property name > t_FilesToRestore

        <#
        if ((Get-Content .\t_FilesToRestore) -eq $Null) {
            write-host "Nothing in file"
            exit

        }
        #>



        #write-verbose "IncludeFiles=*.bak"

        #Get-Childitem -path $DatabaseBackupPath -Recurse -Include $IncludeFiles

        #exit

        #$RestoreCommand="Get-Content t_FilesToRestore | Restore-DbaDatabase -SqlInstance $RestoreInstance -DestinationDataDirectory $DataDirectory -DestinationLogDirectory $LogDirectory -DatabaseName ""${RestoredDatabaseName}"" -WithReplace $PointInTimeClause $OutputScriptOnlyClause $IgnoreLogBackupClause -BlockSize $MemParmBlockSize -MaxTransferSize $MemParmMaxTransferSize -BufferCount $MemParmBufferCount $OHMSAwareClause "
        


        If ($OutputRestoreToSourceScriptOnly) {

            # Let's include a tail-log backup
            # A tail-log backup captures any log records that have not yet been backed up. 
            # This is intended to just get you started, please understand what you are doing with this.

            $Timestamp = [DateTime]::Now.ToString("yyyyMMdd_HHmmss") 
            $TailOfLogBackupFile="$DatabaseBackupPath\LOG\${InstanceToRestore}_${DatabaseToRestore}_LOG_${Timestamp}.trn"
            write-output "`n"
            write-output "--Tail of Log Backup"            
                
            $Cmd="BACKUP LOG $DatabaseToRestore TO DISK = '" + $TailOfLogBackupFile + "' WITH NO_TRUNCATE --,CONTINUE_AFTER_ERROR --(use if database is damaged)" 
            write-output $Cmd
            write-output "`n"
                       
            $RestoreCommand="Get-ChildItem '$DatabaseBackupPath' -Include $IncludeFiles -Recurse | ? { `$_.LastWriteTime -gt ""$BackupCreatedSince"" } | sort-object -property name | Restore-DbaDatabase -SqlInstance $RestoreInstance -ReuseSourceFolderStructure -DatabaseName ""${DatabaseToRestore}"" -WithReplace $PointInTimeClause $OutputScriptOnlyClause $IgnoreLogBackupClause -BlockSize $MemParmBlockSize -MaxTransferSize $MemParmMaxTransferSize -BufferCount $MemParmBufferCount $OHMSAwareClause"
            Invoke-Expression $RestoreCommand

            write-output "`n"
            write-output "-- Restore Tail of Log backup"
            write-output "-- You may need to change the target data and log directories, just used the defaults here"
            $Cmd= "RESTORE LOG $DatabaseToRestore FROM DISK = '" + ${TailOfLogBackupFile} + "', MOVE ${DatabaseToRestore} to D:\SQLData\${DatabaseToRestore}_log.mdf, MOVE ${DatabaseToRestore}_log to L:\SQLLogs\${DatabaseToRestore}_log.ldf"               
            $Cmd
        

            exit

        }
        

               
        Write-Verbose "RestoreCommand=$RestoreCommand"

        #Insert starting row into results table...
        $SQLCmd='INSERT INTO RestoreTest_Results(InstanceName,DatabaseName,RestoredDatabaseName,RestoreBeginTime) VALUES (''' + $InstanceToRestore + ''',''' + $DatabaseToRestore + ''',''' + $RestoredDatabaseName + ''', getdate())'
        Write-Verbose $SQLCmd 
        Invoke-dbasqlquery -ServerInstance dba-sql-restore -Database VM_DBA_RestoreTest -query $SQLCmd 
        
        
        #Each database restore gets a unique Run ID; probably want a unique runID for the instance, too.

        $SQLCmd="select ident_current ('RestoreTest_Results')"
        Write-Verbose $SQLCmd 
        $RunID = Invoke-dbasqlquery -ServerInstance dba-sql-restore -Database VM_DBA_RestoreTest -query $SQLCmd | select -expand column1

        $SQLCmd="INSERT INTO RestoreTest_InstanceRunDetail(InstanceRunID, RunID)  VALUES ($InstanceRunID, $RunID)"
        Write-Verbose $SQLCmd 
        Invoke-dbasqlquery -ServerInstance dba-sql-restore -Database VM_DBA_RestoreTest -query $SQLCmd 
        

        

        if ($ReadFileHeaders) {

            Write-Verbose "Calling function ReadHeaders..."              
            ReadHeaders
        }


        #Remove any existing files
        
                
        
        #If database exists, drop it
        #The -replace flag doesn't always work as expected

        $SQLCmd = "if exists (select * from sys.databases where name = '$RestoredDatabaseName') drop database [${RestoredDatabaseName}]"

        write-verbose $SQLCmd

        Invoke-Sqlcmd2 -ServerInstance $RestoreInstance -Query $SQLCmd
        
        
        
        


        if (Test-Path "D:\SQLData\$InstanceToRestore\${DatabaseToRestore}*.mdf") {
            rm "D:\SQLData\$InstanceToRestore\${DatabaseToRestore}*.mdf" #| out-null
            write-verbose "rm D:\SQLData\$InstanceToRestore\${DatabaseToRestore}*mdf"
        }

        write-verbose "if (Test-Path D:\SQLData\$InstanceToRestore\${DatabaseToRestore}*.ldf) "

        if (Test-Path "D:\SQLLogs\$InstanceToRestore\${DatabaseToRestore}*.ldf") {
            write-verbose "rm D:\SQLLogs\$InstanceToRestore\${DatabaseToRestore}*ldf"
            rm "D:\SQLLogs\$InstanceToRestore\${DatabaseToRestore}*ldf" #| out-null
        }
        
        Write-Verbose $RestoreCommand

        # Run the restore for current database
                
            
        $RestoreResults=Invoke-Expression $RestoreCommand 
        
        #write-verbose $RestoreResults
           
        If ($RestoreResults.RestoreComplete -eq $false -or $RestoreResults.RestoreComplete -eq $null) {

            $_.Exception.Message
            $_.Exception.ItemName

        Write-VErbose "Restore FAILED"

        #Failure, let's log it

        $SQLCmd="update RestoreTest_Results set RestoreResult = 'Failed' where RunID = $RunID"

        Write-Verbose $SQLCmd

        Invoke-Sqlcmd2 -ServerInstance $RestoreInstance -Database VM_DBA_RestoreTest -Query $SQLCmd

        continue

        

        }


        
        if ($ShowRestoreCommands) {
                  
            write-host "`n"
            $RestoreResults.Script        
            write-host "`n"
        
        }

                   

        if ($ShowRestoreCommandsToFile) {

            $Timestamp = [DateTime]::Now.ToString("yyyyMMdd-HHmm") 
            $RestoreSQLFile="Restore_${InstanceToRestore}_${DatabaseToRestore}_${Timestamp}.sql"
            $RestoreResults.Script >>  ${DatabaseBackupPath}\${RestoreSQLFile}

            Write-Output "`nRestore Script Generated: ${DatabaseBackupPath}\${RestoreSQLFile}."
        }
        
                    
        
        #Put in the msdb restore_history_id so we can cross-reference
        
        Write-Verbose "RestoredDatabaseName=$RestoredDatabaseName"

        $SQLCmd="SELECT MAX(restore_history_id) FROM msdb.dbo.restorehistory where destination_database_name = '" + $RestoredDatabaseName + "'" + "" ; Write-Verbose $SQLCmd
        $RestoreHistoryID=Invoke-dbasqlquery -ServerInstance dba-sql-restore -Database VM_DBA_RestoreTest -query $SQLCmd  | select -expand column1
                
                
        #Restore complete

        Write-Verbose "Update-RestoreTest_Results $RestoreResults $RunID $RestoreHistoryID"

        Update-RestoreTest_Results $RestoreResults $RunID $RestoreHistoryID

        If ($ShowResults) {
        
                              
            $SQLCmd="select	rtr.RunID	,RTR.instancename as Instance	,RTR.databasename	as [Database] ,RTR.RecoveryModel,  cast(RTR.databasesizemb	as int) as DBSizeMB,RTR.restoreresult	,RTR.restoreetseconds as ETSeconds	,cast(RTRD.FullBackupFileSizeMB as int) as FullSizeMB	,RTRD.FullBackupFileSizeMBCompressed	,RTRD.DiffBackupFileSizeMB	as DiffSizeMB,RTRD.DiffBackupFileSizeMBCompressed	,RTRD.TotalNumLogFiles as NumLogsApplied, $NumLogs as NumLogsAvail, RTRD.LogsBackupFileSizeMB as TotalLogMB	,RTRD.LogsBackupFileSizeMBCompressed	from RestoreTest_Results as RTR 	inner join RestoreTest_Results_Detail as RTRD on RTR.RunID = RTRD.RunID 	and RestoreResult is not null  and RTR.RunID = $RunID	order by rtr.InstanceName,rtr.DatabaseName,databasesizemb"
            write-verbose $SQLCmd
            Invoke-dbasqlquery -SqlInstance $RestoreInstance -Database VM_DBA_RestoreTest -Query $SQLCmd |select-object Instance,Database,RecoveryModel,ETSeconds,DBSizeMB,FullSizeMB,DiffSizeMB,NumLogsAvail,NumLogsApplied,  TotalLogMB | Format-Table -Property @{e='Instance';width=27},@{e='Database';width=40},@{e='RecoveryModel';width=8},@{e='ETSeconds';width=10},@{e='DBSizeMb';width=10},@{e='FullSizeMB';width=10},@{e='DiffSizeMB';width=10},@{e='NumLogsAvail';width=7},@{e='NumLogsApplied';width=7},@{e='TotalLogMB';width=12}

        }


        
        If ($VerifyOnly) {

                RestoreVerifyOnly 

        }      

                
        if ($CheckIntegrity) {

            CheckIntegrity -InstanceToRestore $InstanceToRestore -DatabaseToRestore $DatabaseToRestore -RestoredDatabaseName $RestoredDatabaseName

            if ($ShowResults) {

                $SQLCmd="select instancename,'$DatabaseToRestore' as DB,datediff(ss,StartTime,FinishTime) as NumSeconds,MessageText as Results  from dbccresults_history where runid = $RunID"
                Write-Verbose $SQLCmd
                Invoke-dbasqlquery -SqlInstance $RestoreInstance -Database VM_DBA_RestoreTest -Query $SQLCmd 
                
            }
            
        }

        
        if (!($NoDrop)) {
        
         # Drop the database
         $DropCommand="if exists (select * from sysdatabases where name = '" + $RestoredDatabaseName + "')"  + " DROP DATABASE " + "[" + ${RestoredDatabaseName} + "]"


         Write-Verbose "Invoke-dbasqlquery -SqlInstance $RestoreInstance -Database master -Query $DropCommand"
        
         try {

            Invoke-dbasqlquery -SqlInstance $RestoreInstance -Database master -Query $DropCommand

         } 

         catch {
            
            Write-Host "Unable to drop database [${RestoredDatabaseName}]. Exiting script."
            exit
         
         } 
        
        } #If NoDrop

     
     } #Foreach Database
    


        #Instance Run complete
        
        $SQLCmd="Update RestoreTest_InstanceRun set RestoreEndTime = getdate() where InstanceRunID=$InstanceRunID"

        Write-Verbose $SQLCmd 
        Invoke-dbasqlquery -ServerInstance dba-sql-restore -Database VM_DBA_RestoreTest -query $SQLCmd 
        
        $SQLCmd="Update RestoreTest_InstanceRun set RestoreETSeconds = datediff(ss,RestoreBeginTime,RestoreEndTime) where InstanceRunID=$InstanceRunID"
        Write-Verbose $SQLCmd 
        Invoke-dbasqlquery -ServerInstance dba-sql-restore -Database VM_DBA_RestoreTest -query $SQLCmd 
        
                
        if ($ShowResults) {

            $SQLCmd="select RestoreETSeconds from RestoreTest_InstanceRun where InstanceRunID = $InstanceRunID"
        
            Write-VErbose $SQLCmd

            $InstanceRunETSeconds=(Invoke-dbasqlquery -ServerInstance dba-sql-restore -Database VM_DBA_RestoreTest -query $SQLCmd | ft -HideTableHeaders | out-string -Stream).trim()


            $InstanceToRestore=$InstanceToRestore.ToUpper()
            $Msg= "`n`nTotal Run Time for Instance $InstanceToRestore : " + $InstanceRunETSeconds + "Seconds"

            Write-Output $Msg

        }




} #Foreach Instance



$SQLCmd="Update RestoreTest_ScriptRun set ScriptEndTime = getdate() where ScriptRunID=$ScriptRunID"

        Write-Verbose $SQLCmd 
        Invoke-dbasqlquery -ServerInstance dba-sql-restore -Database VM_DBA_RestoreTest -query $SQLCmd 
        
        $SQLCmd="Update RestoreTest_ScriptRun set ScriptETSeconds = datediff(ss,ScriptBeginTime,ScriptEndTime) where ScriptRunID=$ScriptRunID"
        Write-Verbose $SQLCmd 
        Invoke-dbasqlquery -ServerInstance dba-sql-restore -Database VM_DBA_RestoreTest -query $SQLCmd 
        

