--:setvar db ERP_Development_Dobrinin

USE Master
GO

Declare @spid int
Select @spid = min(spid) from master.dbo.sysprocesses
where dbid = db_id('$(db)')
While @spid Is Not Null
Begin
        Execute ('Kill ' + @spid)
        Select @spid = min(spid) from master.dbo.sysprocesses
        where dbid = db_id('$(db)') and spid > @spid
End

GO

DECLARE @backup_filename varchar(100);
DECLARE @diff_filename varchar(100);

DECLARE @files table (ID int IDENTITY, FileName varchar(100))
DECLARE @diff_files table (ID int IDENTITY, FileName varchar(100))
insert into @files execute xp_cmdshell 'dir \\rtits-back-01.rtits.ru\MSSQL_1C\_FULL\ERP*.* /b'
insert into @diff_files execute xp_cmdshell 'dir \\rtits-back-01.rtits.ru\MSSQL_1C\_DIFF\ERP*.* /b'

set @backup_filename = '\\rtits-back-01.rtits.ru\MSSQL_1C\_FULL\' + (select top 1 FileName from @files where FileName is not null order by ID desc )
set @diff_filename = '\\rtits-back-01.rtits.ru\MSSQL_1C\_DIFF\' + (select top 1 FileName from @diff_files where FileName is not null order by ID desc )

RESTORE DATABASE $(db) FROM DISK = @backup_filename WITH REPLACE, FILE = 1, NORECOVERY,
MOVE N'ERP_Production' TO 'D:\MSSQL\Data\$(db).mdf',
MOVE N'ERP_Production_log' TO 'D:\MSSQL\Logs\$(db)_log.ldf'
 
RESTORE DATABASE $(db)
FROM DISK = @diff_filename
WITH FILE = 1,
RECOVERY
GO

USE $(db)
ALTER DATABASE $(db) SET RECOVERY SIMPLE
GO

DBCC SHRINKFILE (ERP_Production_log, 0);
GO