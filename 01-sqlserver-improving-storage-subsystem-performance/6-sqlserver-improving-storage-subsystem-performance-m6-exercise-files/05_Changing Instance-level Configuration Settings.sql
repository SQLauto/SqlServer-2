-- Set instance-level options
-- Glenn Berry, SQLskills.com

-- Get configuration values for instance 
SELECT name, value, value_in_use, [description] 
FROM sys.configurations WITH (NOLOCK)
WHERE name IN
(N'backup checksum default', N'backup compression default',
 N'cost threshold for parallelism', N'max server memory (MB)',
 N'optimize for ad hoc workloads', N'remote admin connections')
ORDER BY name OPTION (RECOMPILE);


-- Set Instance-level options to more appropriate values

-- Enable backup checksum default (always enable)
EXEC sys.sp_configure 'backup checksum default', 1;
GO
RECONFIGURE WITH OVERRIDE;
GO
-- New setting for SQL Server 2014
-- Previous versions can use global TF 3023


-- Enable backup compression default
EXEC sys.sp_configure 'backup compression default', 1;
GO
RECONFIGURE WITH OVERRIDE;
GO
-- Enable in most cases. Exceptions:
-- If you are using TDE (unless you are SQL 2016)
-- If you are using a 3rd party backup compression product
-- If you are under sustained, high CPU pressure

-- Change cost threshold for parallelism to a higher value
EXEC sys.sp_configure 'cost threshold for parallelism', 25;
GO
RECONFIGURE WITH OVERRIDE;
GO
-- This depends on your workload

-- Set max server memory to 27000MB
EXEC sys.sp_configure 'max server memory (MB)', 27000;
GO
RECONFIGURE WITH OVERRIDE;
GO


-- Change max degree of parallelism to 4 (number of physical cores in a NUMA node)
EXEC sys.sp_configure 'max degree of parallelism', 4;
GO
RECONFIGURE WITH OVERRIDE;
GO


-- Enable optimize for ad hoc workloads
EXEC sys.sp_configure 'optimize for ad hoc workloads', 1;
RECONFIGURE WITH OVERRIDE;
GO
-- Always enable


-- Enable remote admin connections
EXEC sys.sp_configure 'remote admin connections', 1;
RECONFIGURE WITH OVERRIDE;
GO


-- Get configuration values for instance 
SELECT name, value, value_in_use, [description] 
FROM sys.configurations WITH (NOLOCK)
WHERE name IN
(N'backup checksum default', N'backup compression default',
 N'cost threshold for parallelism', N'max server memory (MB)',
 N'optimize for ad hoc workloads', N'remote admin connections')
ORDER BY name OPTION (RECOMPILE);







