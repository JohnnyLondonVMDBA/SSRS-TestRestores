USE [VM_DBA_RestoreTest]
GO

/****** Object:  Table [dbo].[BackupFileHeaders]    Script Date: 3/23/2018 9:20:54 AM ******/
if exists (select * from sys.tables where name = 'BackupFileHeaders' ) drop TABLE [dbo].[BackupFileHeaders]
go
CREATE TABLE [dbo].[BackupFileHeaders](
	[RunID] [int] not NULL ,
	[FileName] [varchar](max) NULL,
	[FileLastWriteTime] [varchar](100) NULL,
	[ServerName] [varchar](50) NULL,
	[InstanceName] [varchar](50) NULL,
	[DatabaseName] [varchar](100) NULL,
	[BackupTypeDescription] [varchar](100) NULL,
	[BackupStartDate] [datetime] NULL,
	[BackupFinishDate] [datetime] NULL,
	[DatabaseBackupLSN] [varchar](30) NULL,
	[FirstLSN] [varchar](30) NULL,
	[LastLSN] [varchar](30) NULL,
	[HasBackupChecksums] [char](5) NULL,
	[BackupSize] [bigint] NULL,
	[Compressed] [char](5) NULL,
	[CompressedBAckupSize] [bigint] NULL,
	[SoftwareVersionMajor] [smallint] NULL,
	[SoftwareVersionMinor] [smallint] NULL,
	[SoftwareVersionBuild] [smallint] NULL,
	[DatabaseVersion] [smallint] NULL,
	[CompatibilityLevel] [smallint] NULL,
	[BeginsLogChain] [char](5) NULL,
	[RecoveryModel] [varchar](12) NULL,
    constraint PK_BackupFileHeaders primary key (RunID)
	) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

if exists (select * from sys.tables where name = 'BackupFileHeaders_Work') drop TABLE [dbo].[BackupFileHeaders_Work]
go
CREATE TABLE [dbo].[BackupFileHeaders_Work](
	[ServerName] [varchar](50) NULL,
	[InstanceName] [varchar](50) NULL,
	[DatabaseName] [varchar](100) NULL,
	[BackupTypeDescription] [varchar](100) NULL,
	[BackupStartDate] [datetime] NULL,
	[BackupFinishDate] [datetime] NULL,
	[DatabaseBackupLSN] [varchar](30) NULL,
	[FirstLSN] [varchar](30) NULL,
	[LastLSN] [varchar](30) NULL,
	[HasBackupChecksums] [char](5) NULL,
	[BackupSize] [bigint] NULL,
	[Compressed] [char](5) NULL,
	[CompressedBAckupSize] [bigint] NULL,
	[SoftwareVersionMajor] [smallint] NULL,
	[SoftwareVersionMinor] [smallint] NULL,
	[SoftwareVersionBuild] [smallint] NULL,
	[DatabaseVersion] [smallint] NULL,
	[CompatibilityLevel] [smallint] NULL,
	[BeginsLogChain] [char](5) NULL,
	[RecoveryModel] [varchar](12) NULL
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[BackupFileList]    Script Date: 3/23/2018 9:20:54 AM ******/

if exists (select * from sys.tables where name = 'BackupFileList') drop TABLE [dbo].[BackupFileList]
go

create TABLE [dbo].[BackupFileList](
	[RunID] [int] not NULL,
	[LogicalName] [varchar](100) NULL,
	[PhysicalName] [varchar](100) NULL,
	[Type] [char](1) NULL,
	[FileGroupName] [varchar](10) NULL,
	[Size] [bigint] NULL,
	[MaxSize] [bigint] NULL,
	[FileId] [smallint] NULL,
	[CreateLSN] [bigint] NULL,
	[DropLSN] [bigint] NULL,
	[UniqueId] [uniqueidentifier] NULL,
	[ReadOnlyLSN] [bigint] NULL,
	[ReadWriteLSN] [bigint] NULL,
	[BackupSizeInBytes] [bigint] NULL,
	[SourceBlockSize] [bigint] NULL,
	[FileGroupId] [smallint] NULL,
	[LogGroupGUID] [uniqueidentifier] NULL,
	[DifferentialBaseLSN] [bigint] NULL,
	[DifferentialBaseGUID] [uniqueidentifier] NULL,
	[IsReadOnly] [bit] NULL,
	[IsPresent] [bit] NULL,
	[TDEThumbprint] [varchar](100) NULL,
	[SnapshotUrl] [varchar](100) NULL
		constraint PK_BackupFileList primary key (RunID),
	

) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[BackupFileList_work]    Script Date: 3/23/2018 9:20:54 AM ******/

if exists (select * from sys.tables where name = 'BackupFileList_work') drop TABLE [dbo].[BackupFileList_work]
go
CREATE TABLE [dbo].[BackupFileList_work](
	[LogicalName] [varchar](100) NULL,
	[PhysicalName] [varchar](100) NULL,
	[Type] [char](1) NULL,
	[FileGroupName] [varchar](10) NULL,
	[Size] [bigint] NULL,
	[MaxSize] [bigint] NULL,
	[FileId] [smallint] NULL,
	[CreateLSN] [bigint] NULL,
	[DropLSN] [bigint] NULL,
	[UniqueId] [uniqueidentifier] NULL,
	[ReadOnlyLSN] [bigint] NULL,
	[ReadWriteLSN] [bigint] NULL,
	[BackupSizeInBytes] [bigint] NULL,
	[SourceBlockSize] [bigint] NULL,
	[FileGroupId] [smallint] NULL,
	[LogGroupGUID] [uniqueidentifier] NULL,
	[DifferentialBaseLSN] [bigint] NULL,
	[DifferentialBaseGUID] [uniqueidentifier] NULL,
	[IsReadOnly] [bit] NULL,
	[IsPresent] [bit] NULL,
	[TDEThumbprint] [varchar](100) NULL,
	[SnapshotUrl] [varchar](100) NULL
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[DBCCResults]    Script Date: 3/23/2018 9:20:54 AM ******/

if exists (select * from sys.tables where name = 'DBCCResults') drop TABLE [dbo].[DBCCResults]
go

CREATE TABLE [dbo].[DBCCResults](
	[Error] [int] NULL,
	[Level] [int] NULL,
	[State] [int] NULL,
	[MessageText] [varchar](7000) NULL,
	[RepairLevel] [int] NULL,
	[Status] [int] NULL,
	[DbId] [int] NULL,
	[DbFragID] [int] NULL,
	[ObjectId] [int] NULL,
	[IndexId] [int] NULL,
	[PartitionID] [int] NULL,
	[AllocUnitID] [int] NULL,
	[RidDbID] [int] NULL,
	[RidPruId] [int] NULL,
	[File] [int] NULL,
	[Page] [int] NULL,
	[Slot] [int] NULL,
	[RefDbId] [int] NULL,
	[RefPruId] [int] NULL,
	[RefFile] [int] NULL,
	[RefPage] [int] NULL,
	[RefSlot] [int] NULL,
	[Allocation] [int] NULL,
	[TimeStamp] [datetime] NULL
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[DBCCResults_History]    Script Date: 3/23/2018 9:20:54 AM ******/

if exists (select * from sys.tables where name = 'dbccresults_history') drop TABLE [dbo].[DBCCResults_History]
go

CREATE TABLE [dbo].[DBCCResults_History](
	[RunID] [int] not NULL ,
	[InstanceName] [varchar](50) not NULL,
	[DatabaseName] [varchar](100) not NULL,
	[StartTime] [datetime] NULL,
	[FinishTime] [datetime] NULL,
	[MessageText] [varchar](max) NULL
	constraint PK_DBCCResults_History primary key (RunID),
	
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]


GO

/****** Object:  Table [dbo].[DBCCResults_Work]    Script Date: 3/23/2018 9:20:54 AM ******/

if exists (select * from sys.tables where name = 'DBCCResults_Work') drop table [dbo].[DBCCResults_Work]
go

CREATE TABLE [dbo].[DBCCResults_Work](
	[Error] [int] NULL,
	[Level] [int] NULL,
	[State] [int] NULL,
	[MessageText] [varchar](7000) NULL,
	[RepairLevel] [int] NULL,
	[Status] [int] NULL,
	[DbId] [int] NULL,
	[DbFragID] [int] NULL,
	[ObjectId] [int] NULL,
	[IndexId] [int] NULL,
	[PartitionID] [int] NULL,
	[AllocUnitID] [int] NULL,
	[RidDbID] [int] NULL,
	[RidPruId] [int] NULL,
	[File] [int] NULL,
	[Page] [int] NULL,
	[Slot] [int] NULL,
	[RefDbId] [int] NULL,
	[RefPruId] [int] NULL,
	[RefFile] [int] NULL,
	[RefPage] [int] NULL,
	[RefSlot] [int] NULL,
	[Allocation] [int] NULL,
	[TimeStamp] [datetime] NULL
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[RestoreTest_InstanceRun]    Script Date: 3/23/2018 9:20:55 AM ******/

if exists (select * from sys.tables where name = 'RestoreTest_InstanceRun' ) drop TABLE [dbo].[RestoreTest_InstanceRun]
go

CREATE TABLE [dbo].[RestoreTest_InstanceRun](
	[InstanceRunID] [int] IDENTITY(1,1) NOT NULL primary key,
	RptInfoEnvironment varchar(10),
	[RestoreBeginTime] [datetime] NULL,
	[RestoreEndTime] [datetime] NULL,
	[RestoreETSeconds] [int] NULL
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[RestoreTest_InstanceRunDetail]    Script Date: 3/23/2018 9:20:55 AM ******/
if exists (select * from sys.tables where name = 'RestoreTEst_InstanceRunDetail') drop TABLE [dbo].[RestoreTest_InstanceRunDetail] 
go

CREATE TABLE [dbo].[RestoreTest_InstanceRunDetail](
	[InstanceRunID] [int] NULL,
	[RunId] [int] NULL
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[RestoreTest_Results]    Script Date: 3/23/2018 9:20:55 AM ******/


/****** Object:  Table [dbo].[RestoreTest_Results_Detail]    Script Date: 3/23/2018 9:20:55 AM ******/

if exists (select * from sys.tables where name = 'RestoreTest_Results_Detail') drop TABLE [dbo].[RestoreTest_Results_Detail]
go

CREATE TABLE [dbo].[RestoreTest_Results_Detail](
	[RunID] [int] not NULL,
	FullBackupFileName varchar(max),
	[FullBackupFileSizeMB] [numeric](10, 2) NULL,
	[FullBackupFileSizeMBCompressed] [numeric](10, 2) NULL,
	DiffBackupFileName varchar(max),
	[DiffBackupFileSizeMB] [numeric](10, 2) NULL,
	[DiffBackupFileSizeMBCompressed] [numeric](10, 2) NULL,
	[LogsBackupFileSizeMB] [numeric](10, 2) NULL,
	[LogsBackupFileSizeMBCompressed] [numeric](10, 2) NULL,
	[TotalNumLogFiles] [smallint] NULL,
	constraint PK_RestoreTest_Results_Detail primary key (RunID),
	

) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[RestoreTest_Results_VerifyOnly]    Script Date: 3/23/2018 9:20:55 AM ******/

drop TABLE [dbo].[RestoreTest_Results_VerifyOnly]
go
CREATE TABLE [dbo].[RestoreTest_Results_VerifyOnly](
	[RunID] [int] NULL,
	[StartTime] [datetime] NULL,
	[FinishTime] [datetime] NULL
) ON [PRIMARY]
GO


if exists (select * from sys.tables where name = 'RestoreTest_Results') drop TABLE [dbo].[RestoreTest_Results]
go

CREATE TABLE [dbo].[RestoreTest_Results](
	[RunID] [int] IDENTITY(1,1) NOT NULL ,
	[MSDB_Restore_History_ID] [int] NULL,
	[InstanceName] [varchar](50) NOT NULL,
	[DatabaseName] [varchar](100) NOT NULL,
	[RecoveryModel] varchar(10)  null,
	[DatabaseSizeMB] numeric(8,2) NULL,
	[RestoredDatabaseName] [varchar](100) NOT NULL,
	[RestoreBeginTime] [datetime] NULL,
	[RestoreFinishTime] [datetime] NULL,
	[RestoreETSeconds] [numeric](7, 2) NULL,
	[RestoreResult] [varchar](300) NULL,
	[MaxTransfersize] [int] NULL,
	[BufferCount] [int] NULL,
	[BlockSize] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[RunID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO



if exists (select * from sys.tables where name = 'RestoreTest_Parameters') drop TABLE [dbo].[RestoreTest_Parameters]
go

CREATE TABLE [dbo].[RestoreTest_Parameters](
	[ScriptRunID] [int] NULL,
	[PointInTime] [varchar](20) NULL,
	[CheckIntegrity] [bit] NULL,
	[CohesityNode] [char](3) NULL,
	[MemParmMaxTransferSize] [int] NULL,
	[MemParmBufferCount] [smallint] NULL,
	[MemParmBlocksize] [smallint] NULL,
	[ExcludeLogBackups] [bit] NULL,
	[ExcludeDiffBackup] [bit] NULL
) ON [PRIMARY]


if exists (select * from sys.tables where name = 'RestoreTest_ScriptRun') drop TABLE [dbo].[RestoreTest_ScriptRun]
go

CREATE TABLE [dbo].[RestoreTest_ScriptRun](
	[ScriptRunID] [int] IDENTITY(1,1) NOT NULL,
	[RptInfoIsUnattendedRun] [bit] NULL,
	[ScriptBeginTime] [datetime] NULL,
	[ScriptEndTime] [datetime] NULL,
	[ScriptETSeconds] [int] NULL
) ON [PRIMARY]
GO

if exists (select * from sys.tables where name = 'RestoreTest_ScriptRunDetail') drop TABLE [dbo].[RestoreTest_ScriptRunDetail]
go

CREATE TABLE [dbo].[RestoreTest_ScriptRunDetail](
	[ScriptRunId] [int] NULL,
	[InstanceRunID] [int] NULL
) ON [PRIMARY]
GO




ALTER TABLE [dbo].[DBCCResults] ADD  CONSTRAINT [DF_dbcc_history_TimeStamp]  DEFAULT (getdate()) FOR [TimeStamp]
GO

ALTER TABLE [dbo].[DBCCResults_Work] ADD  CONSTRAINT [DF_DBCCResults_Work_TimeStamp]  DEFAULT (getdate()) FOR [TimeStamp]
GO




	alter table BAckupFileHeaders add constraint FK_BackupFileHeaders1 foreign key (runid) references dbo.RestoreTest_Results (RunID)

	alter table BAckupFileList add constraint FK_BackupFileList_RunID foreign key (runid) references dbo.RestoreTest_Results (RunID)

	alter table DBCCResults_History add constraint FK_DBCCResults_History_RunID foreign key (runid) references dbo.RestoreTest_Results (RunID)

	alter table RestoreTest_Results_Detail add	constraint FK_RestoreTest_Results_Detail foreign key (runid) references dbo.RestoreTest_Results (RunID)