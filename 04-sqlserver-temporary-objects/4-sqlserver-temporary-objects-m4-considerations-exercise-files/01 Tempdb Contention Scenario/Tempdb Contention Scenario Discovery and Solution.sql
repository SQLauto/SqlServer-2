-- Waiting tasks?
SELECT  [w].[session_id],
        [w].[wait_duration_ms],
        [w].[wait_type],
        [w].[resource_description]
FROM    sys.[dm_os_waiting_tasks] AS [w]
INNER JOIN sys.[dm_exec_sessions] AS [s]
        ON w.[session_id] = s.[session_id]
WHERE   s.[is_user_process] = 1;

-- Allocation pages?
-- Page 1 = PFS and occurs every 8,088 pages
-- Page 2 = GAM and occurs every 511,232 pages
-- Page 3 = SGAM and occurs every 511,232 + 1 pages

-- Tempdb
USE [tempdb];
EXEC sp_helpfile;

-- Let's do a few samples of PFS contention counts
SELECT  [w].[resource_description],
        COUNT(*) AS [rowcount]
FROM    sys.[dm_os_waiting_tasks] AS [w]
INNER JOIN sys.[dm_exec_sessions] AS [s]
        ON w.[session_id] = s.[session_id]
WHERE   s.[is_user_process] = 1 AND
        w.[resource_description] = '2:1:1'
GROUP BY [w].[resource_description];

-- We have four cores, so let's add three more equal sized tempdb files
USE [master]
GO
ALTER DATABASE [tempdb] 
MODIFY FILE ( NAME = N'tempdev', SIZE = 1048576KB , 
FILEGROWTH = 1048576KB )
GO

ALTER DATABASE [tempdb] 
ADD FILE ( NAME = N'tempdev2', FILENAME = N'S:\DATA\tempdb2.ndf' , 
SIZE = 1048576KB , FILEGROWTH = 1048576KB )
GO

ALTER DATABASE [tempdb] 
ADD FILE ( NAME = N'tempdev3', FILENAME = N'S:\DATA\tempdb3.ndf' ,
SIZE = 1048576KB , FILEGROWTH = 1048576KB )
GO

ALTER DATABASE [tempdb] 
ADD FILE ( NAME = N'tempdev4', FILENAME = N'S:\DATA\tempdb4.ndf' , 
SIZE = 1048576KB , FILEGROWTH = 1048576KB )
GO

-- Tempdb
USE [tempdb];
EXEC sp_helpfile;

-- Now how do things look?
SELECT  [w].[resource_description],
        COUNT(*) AS [rowcount]
FROM    sys.[dm_os_waiting_tasks] AS [w]
INNER JOIN sys.[dm_exec_sessions] AS [s]
        ON w.[session_id] = s.[session_id]
WHERE   s.[is_user_process] = 1 AND
        w.[resource_description] = '2:1:1'
GROUP BY [w].[resource_description];


-- There are other tempdb considerations as well, so some recommended reading:
/*
	"Recommendations to reduce allocation contention in SQL Server tempdb database", 
	Microsoft, http://bit.ly/Pab7Su

	 "A SQL Server DBA myth a day: (12/30) tempdb should always have one data file per processor core", 
	 Paul Randal, http://bit.ly/15AqUne 

	"Misconceptions around TF 1118", Paul Randal, http://bit.ly/Wp1d2t

*/






-- Reset demo
USE [tempdb]
GO

DBCC SHRINKFILE (N'tempdev2' , EMPTYFILE)
GO

ALTER DATABASE [tempdb]  REMOVE FILE [tempdev2]
GO


USE [tempdb]
GO
DBCC SHRINKFILE (N'tempdev3' , EMPTYFILE)
GO

ALTER DATABASE [tempdb]  REMOVE FILE [tempdev3]
GO

USE [tempdb]
GO

DBCC SHRINKFILE (N'tempdev4' , EMPTYFILE)
GO

ALTER DATABASE [tempdb]  REMOVE FILE [tempdev4]
GO

