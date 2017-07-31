--:setvar db ERP_DAI
--:setvar bakfile 'D:\DBBACKUP\ERP_Production_Copy.bak'

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

RESTORE DATABASE $(db) FROM DISK = '$(bakfile)' WITH REPLACE, FILE = 1, RECOVERY,
MOVE N'ERP_Production' TO 'D:\DBDATA\$(db).mdf',
MOVE N'ERP_Production_log' TO 'D:\DBDATA\$(db)_log.ldf'
GO

USE $(db)
ALTER DATABASE $(db) SET RECOVERY SIMPLE
GO

DBCC SHRINKFILE (ERP_Production_log, 0);
GO
