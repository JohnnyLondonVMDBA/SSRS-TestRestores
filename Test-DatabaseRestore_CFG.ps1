# This file contains variables for use within the script Test-DatabaseRestore.ps1

# Environment Variable File
$EnvVariableFile = "D:\vmmc\bin\PowerShell\mssql_scripts\Shared\ProfileGlobal.ps1"
. $EnvVariableFile

#The instance to which we will be restoring
# IMPORTANT - DO NOT CHANGE the variable $RestoreInstance without a full understanding of what you are doing.
# This variable references the instance to which the databases will be restored.
$RestoreInstance = "DBA-SQL-RESTORE"


$CohesityPathProd    = "\ProdDatabaseBackups\SQLBackups\"
$CohesityPathNonProd = "\NonProdDatabaseBackups\SQLBackups\"
$CohesityPathLegacy  = "\DatabaseBackups\SQLBackups\"

$CohesityRootPath="\\cohesity-yak-m1.yvmh.org"
$CohesityRootPath_Node1 = "\\10.25.3.104"
$CohesityRootPath_Node2 = "\\10.25.3.105"
$CohesityRootPath_Node3 = "\\10.25.3.106"
$CohesityRootPath_Node4 = "\\10.25.3.107"