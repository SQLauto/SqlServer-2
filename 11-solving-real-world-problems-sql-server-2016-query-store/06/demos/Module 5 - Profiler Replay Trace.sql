/****************************************************/
/* Created by: SQL Server 2016 Profiler          */
/* Date: 2017/04/21  00:41:49         */
/****************************************************/


-- Create a Queue
declare @rc int
declare @TraceID int
declare @maxfilesize BIGINT
DECLARE @EndDate DATETIME;
set @maxfilesize = 1000;
SET @EndDate = DATEADD(HOUR,6,GETDATE());

-- Please replace the text InsertFileNameHere, with an appropriate
-- filename prefixed by a path, e.g., c:\MyFolder\MyTrace. The .trc extension
-- will be appended to the filename automatically. If you are writing from
-- remote server to local drive, please use UNC path and make sure server has
-- write access to your network share

exec @rc = sp_trace_create @TraceID output, 2, N'D:\Databases\Traces\ReplayTrace', @maxfilesize, @EndDate,5 
if (@rc != 0) goto error

-- Client side File and Table cannot be scripted

-- Set the events
declare @on bit
set @on = 1
exec sp_trace_setevent @TraceID, 78, 3, @on
exec sp_trace_setevent @TraceID, 78, 11, @on
exec sp_trace_setevent @TraceID, 78, 12, @on
exec sp_trace_setevent @TraceID, 78, 6, @on
exec sp_trace_setevent @TraceID, 78, 7, @on
exec sp_trace_setevent @TraceID, 78, 8, @on
exec sp_trace_setevent @TraceID, 78, 9, @on
exec sp_trace_setevent @TraceID, 78, 10, @on
exec sp_trace_setevent @TraceID, 78, 14, @on
exec sp_trace_setevent @TraceID, 78, 26, @on
exec sp_trace_setevent @TraceID, 78, 33, @on
exec sp_trace_setevent @TraceID, 78, 35, @on
exec sp_trace_setevent @TraceID, 78, 49, @on
exec sp_trace_setevent @TraceID, 78, 51, @on
exec sp_trace_setevent @TraceID, 78, 60, @on
exec sp_trace_setevent @TraceID, 74, 3, @on
exec sp_trace_setevent @TraceID, 74, 11, @on
exec sp_trace_setevent @TraceID, 74, 12, @on
exec sp_trace_setevent @TraceID, 74, 6, @on
exec sp_trace_setevent @TraceID, 74, 7, @on
exec sp_trace_setevent @TraceID, 74, 8, @on
exec sp_trace_setevent @TraceID, 74, 9, @on
exec sp_trace_setevent @TraceID, 74, 10, @on
exec sp_trace_setevent @TraceID, 74, 14, @on
exec sp_trace_setevent @TraceID, 74, 26, @on
exec sp_trace_setevent @TraceID, 74, 33, @on
exec sp_trace_setevent @TraceID, 74, 35, @on
exec sp_trace_setevent @TraceID, 74, 49, @on
exec sp_trace_setevent @TraceID, 74, 51, @on
exec sp_trace_setevent @TraceID, 74, 60, @on
exec sp_trace_setevent @TraceID, 53, 3, @on
exec sp_trace_setevent @TraceID, 53, 11, @on
exec sp_trace_setevent @TraceID, 53, 12, @on
exec sp_trace_setevent @TraceID, 53, 6, @on
exec sp_trace_setevent @TraceID, 53, 7, @on
exec sp_trace_setevent @TraceID, 53, 8, @on
exec sp_trace_setevent @TraceID, 53, 9, @on
exec sp_trace_setevent @TraceID, 53, 10, @on
exec sp_trace_setevent @TraceID, 53, 14, @on
exec sp_trace_setevent @TraceID, 53, 26, @on
exec sp_trace_setevent @TraceID, 53, 33, @on
exec sp_trace_setevent @TraceID, 53, 35, @on
exec sp_trace_setevent @TraceID, 53, 49, @on
exec sp_trace_setevent @TraceID, 53, 51, @on
exec sp_trace_setevent @TraceID, 53, 60, @on
exec sp_trace_setevent @TraceID, 70, 3, @on
exec sp_trace_setevent @TraceID, 70, 11, @on
exec sp_trace_setevent @TraceID, 70, 12, @on
exec sp_trace_setevent @TraceID, 70, 6, @on
exec sp_trace_setevent @TraceID, 70, 7, @on
exec sp_trace_setevent @TraceID, 70, 8, @on
exec sp_trace_setevent @TraceID, 70, 9, @on
exec sp_trace_setevent @TraceID, 70, 10, @on
exec sp_trace_setevent @TraceID, 70, 14, @on
exec sp_trace_setevent @TraceID, 70, 26, @on
exec sp_trace_setevent @TraceID, 70, 33, @on
exec sp_trace_setevent @TraceID, 70, 35, @on
exec sp_trace_setevent @TraceID, 70, 49, @on
exec sp_trace_setevent @TraceID, 70, 51, @on
exec sp_trace_setevent @TraceID, 70, 60, @on
exec sp_trace_setevent @TraceID, 77, 3, @on
exec sp_trace_setevent @TraceID, 77, 11, @on
exec sp_trace_setevent @TraceID, 77, 12, @on
exec sp_trace_setevent @TraceID, 77, 6, @on
exec sp_trace_setevent @TraceID, 77, 7, @on
exec sp_trace_setevent @TraceID, 77, 8, @on
exec sp_trace_setevent @TraceID, 77, 9, @on
exec sp_trace_setevent @TraceID, 77, 10, @on
exec sp_trace_setevent @TraceID, 77, 14, @on
exec sp_trace_setevent @TraceID, 77, 26, @on
exec sp_trace_setevent @TraceID, 77, 33, @on
exec sp_trace_setevent @TraceID, 77, 35, @on
exec sp_trace_setevent @TraceID, 77, 49, @on
exec sp_trace_setevent @TraceID, 77, 51, @on
exec sp_trace_setevent @TraceID, 77, 60, @on
exec sp_trace_setevent @TraceID, 16, 3, @on
exec sp_trace_setevent @TraceID, 16, 11, @on
exec sp_trace_setevent @TraceID, 16, 12, @on
exec sp_trace_setevent @TraceID, 16, 6, @on
exec sp_trace_setevent @TraceID, 16, 7, @on
exec sp_trace_setevent @TraceID, 16, 8, @on
exec sp_trace_setevent @TraceID, 16, 9, @on
exec sp_trace_setevent @TraceID, 16, 10, @on
exec sp_trace_setevent @TraceID, 16, 14, @on
exec sp_trace_setevent @TraceID, 16, 15, @on
exec sp_trace_setevent @TraceID, 16, 26, @on
exec sp_trace_setevent @TraceID, 16, 35, @on
exec sp_trace_setevent @TraceID, 16, 49, @on
exec sp_trace_setevent @TraceID, 16, 51, @on
exec sp_trace_setevent @TraceID, 16, 60, @on
exec sp_trace_setevent @TraceID, 14, 1, @on
exec sp_trace_setevent @TraceID, 14, 9, @on
exec sp_trace_setevent @TraceID, 14, 2, @on
exec sp_trace_setevent @TraceID, 14, 10, @on
exec sp_trace_setevent @TraceID, 14, 3, @on
exec sp_trace_setevent @TraceID, 14, 11, @on
exec sp_trace_setevent @TraceID, 14, 6, @on
exec sp_trace_setevent @TraceID, 14, 7, @on
exec sp_trace_setevent @TraceID, 14, 8, @on
exec sp_trace_setevent @TraceID, 14, 12, @on
exec sp_trace_setevent @TraceID, 14, 14, @on
exec sp_trace_setevent @TraceID, 14, 21, @on
exec sp_trace_setevent @TraceID, 14, 26, @on
exec sp_trace_setevent @TraceID, 14, 35, @on
exec sp_trace_setevent @TraceID, 14, 49, @on
exec sp_trace_setevent @TraceID, 14, 51, @on
exec sp_trace_setevent @TraceID, 14, 60, @on
exec sp_trace_setevent @TraceID, 15, 3, @on
exec sp_trace_setevent @TraceID, 15, 11, @on
exec sp_trace_setevent @TraceID, 15, 6, @on
exec sp_trace_setevent @TraceID, 15, 7, @on
exec sp_trace_setevent @TraceID, 15, 8, @on
exec sp_trace_setevent @TraceID, 15, 9, @on
exec sp_trace_setevent @TraceID, 15, 10, @on
exec sp_trace_setevent @TraceID, 15, 12, @on
exec sp_trace_setevent @TraceID, 15, 14, @on
exec sp_trace_setevent @TraceID, 15, 15, @on
exec sp_trace_setevent @TraceID, 15, 21, @on
exec sp_trace_setevent @TraceID, 15, 26, @on
exec sp_trace_setevent @TraceID, 15, 35, @on
exec sp_trace_setevent @TraceID, 15, 49, @on
exec sp_trace_setevent @TraceID, 15, 51, @on
exec sp_trace_setevent @TraceID, 15, 60, @on
exec sp_trace_setevent @TraceID, 17, 1, @on
exec sp_trace_setevent @TraceID, 17, 9, @on
exec sp_trace_setevent @TraceID, 17, 2, @on
exec sp_trace_setevent @TraceID, 17, 10, @on
exec sp_trace_setevent @TraceID, 17, 3, @on
exec sp_trace_setevent @TraceID, 17, 11, @on
exec sp_trace_setevent @TraceID, 17, 6, @on
exec sp_trace_setevent @TraceID, 17, 7, @on
exec sp_trace_setevent @TraceID, 17, 8, @on
exec sp_trace_setevent @TraceID, 17, 12, @on
exec sp_trace_setevent @TraceID, 17, 14, @on
exec sp_trace_setevent @TraceID, 17, 26, @on
exec sp_trace_setevent @TraceID, 17, 35, @on
exec sp_trace_setevent @TraceID, 17, 49, @on
exec sp_trace_setevent @TraceID, 17, 51, @on
exec sp_trace_setevent @TraceID, 17, 60, @on
exec sp_trace_setevent @TraceID, 100, 1, @on
exec sp_trace_setevent @TraceID, 100, 9, @on
exec sp_trace_setevent @TraceID, 100, 3, @on
exec sp_trace_setevent @TraceID, 100, 11, @on
exec sp_trace_setevent @TraceID, 100, 6, @on
exec sp_trace_setevent @TraceID, 100, 7, @on
exec sp_trace_setevent @TraceID, 100, 8, @on
exec sp_trace_setevent @TraceID, 100, 10, @on
exec sp_trace_setevent @TraceID, 100, 12, @on
exec sp_trace_setevent @TraceID, 100, 14, @on
exec sp_trace_setevent @TraceID, 100, 26, @on
exec sp_trace_setevent @TraceID, 100, 35, @on
exec sp_trace_setevent @TraceID, 100, 49, @on
exec sp_trace_setevent @TraceID, 100, 51, @on
exec sp_trace_setevent @TraceID, 100, 60, @on
exec sp_trace_setevent @TraceID, 10, 9, @on
exec sp_trace_setevent @TraceID, 10, 2, @on
exec sp_trace_setevent @TraceID, 10, 10, @on
exec sp_trace_setevent @TraceID, 10, 3, @on
exec sp_trace_setevent @TraceID, 10, 6, @on
exec sp_trace_setevent @TraceID, 10, 7, @on
exec sp_trace_setevent @TraceID, 10, 8, @on
exec sp_trace_setevent @TraceID, 10, 11, @on
exec sp_trace_setevent @TraceID, 10, 12, @on
exec sp_trace_setevent @TraceID, 10, 14, @on
exec sp_trace_setevent @TraceID, 10, 15, @on
exec sp_trace_setevent @TraceID, 10, 26, @on
exec sp_trace_setevent @TraceID, 10, 31, @on
exec sp_trace_setevent @TraceID, 10, 35, @on
exec sp_trace_setevent @TraceID, 10, 48, @on
exec sp_trace_setevent @TraceID, 10, 49, @on
exec sp_trace_setevent @TraceID, 10, 51, @on
exec sp_trace_setevent @TraceID, 10, 60, @on
exec sp_trace_setevent @TraceID, 11, 9, @on
exec sp_trace_setevent @TraceID, 11, 2, @on
exec sp_trace_setevent @TraceID, 11, 10, @on
exec sp_trace_setevent @TraceID, 11, 3, @on
exec sp_trace_setevent @TraceID, 11, 6, @on
exec sp_trace_setevent @TraceID, 11, 7, @on
exec sp_trace_setevent @TraceID, 11, 8, @on
exec sp_trace_setevent @TraceID, 11, 11, @on
exec sp_trace_setevent @TraceID, 11, 12, @on
exec sp_trace_setevent @TraceID, 11, 14, @on
exec sp_trace_setevent @TraceID, 11, 26, @on
exec sp_trace_setevent @TraceID, 11, 35, @on
exec sp_trace_setevent @TraceID, 11, 49, @on
exec sp_trace_setevent @TraceID, 11, 51, @on
exec sp_trace_setevent @TraceID, 11, 60, @on
exec sp_trace_setevent @TraceID, 72, 3, @on
exec sp_trace_setevent @TraceID, 72, 11, @on
exec sp_trace_setevent @TraceID, 72, 12, @on
exec sp_trace_setevent @TraceID, 72, 6, @on
exec sp_trace_setevent @TraceID, 72, 7, @on
exec sp_trace_setevent @TraceID, 72, 8, @on
exec sp_trace_setevent @TraceID, 72, 9, @on
exec sp_trace_setevent @TraceID, 72, 10, @on
exec sp_trace_setevent @TraceID, 72, 14, @on
exec sp_trace_setevent @TraceID, 72, 26, @on
exec sp_trace_setevent @TraceID, 72, 33, @on
exec sp_trace_setevent @TraceID, 72, 35, @on
exec sp_trace_setevent @TraceID, 72, 49, @on
exec sp_trace_setevent @TraceID, 72, 51, @on
exec sp_trace_setevent @TraceID, 72, 60, @on
exec sp_trace_setevent @TraceID, 71, 3, @on
exec sp_trace_setevent @TraceID, 71, 11, @on
exec sp_trace_setevent @TraceID, 71, 12, @on
exec sp_trace_setevent @TraceID, 71, 6, @on
exec sp_trace_setevent @TraceID, 71, 7, @on
exec sp_trace_setevent @TraceID, 71, 8, @on
exec sp_trace_setevent @TraceID, 71, 9, @on
exec sp_trace_setevent @TraceID, 71, 10, @on
exec sp_trace_setevent @TraceID, 71, 14, @on
exec sp_trace_setevent @TraceID, 71, 26, @on
exec sp_trace_setevent @TraceID, 71, 33, @on
exec sp_trace_setevent @TraceID, 71, 35, @on
exec sp_trace_setevent @TraceID, 71, 49, @on
exec sp_trace_setevent @TraceID, 71, 51, @on
exec sp_trace_setevent @TraceID, 71, 60, @on
exec sp_trace_setevent @TraceID, 12, 1, @on
exec sp_trace_setevent @TraceID, 12, 9, @on
exec sp_trace_setevent @TraceID, 12, 3, @on
exec sp_trace_setevent @TraceID, 12, 11, @on
exec sp_trace_setevent @TraceID, 12, 6, @on
exec sp_trace_setevent @TraceID, 12, 7, @on
exec sp_trace_setevent @TraceID, 12, 8, @on
exec sp_trace_setevent @TraceID, 12, 10, @on
exec sp_trace_setevent @TraceID, 12, 12, @on
exec sp_trace_setevent @TraceID, 12, 14, @on
exec sp_trace_setevent @TraceID, 12, 15, @on
exec sp_trace_setevent @TraceID, 12, 26, @on
exec sp_trace_setevent @TraceID, 12, 31, @on
exec sp_trace_setevent @TraceID, 12, 35, @on
exec sp_trace_setevent @TraceID, 12, 48, @on
exec sp_trace_setevent @TraceID, 12, 49, @on
exec sp_trace_setevent @TraceID, 12, 51, @on
exec sp_trace_setevent @TraceID, 12, 60, @on
exec sp_trace_setevent @TraceID, 13, 1, @on
exec sp_trace_setevent @TraceID, 13, 9, @on
exec sp_trace_setevent @TraceID, 13, 3, @on
exec sp_trace_setevent @TraceID, 13, 11, @on
exec sp_trace_setevent @TraceID, 13, 6, @on
exec sp_trace_setevent @TraceID, 13, 7, @on
exec sp_trace_setevent @TraceID, 13, 8, @on
exec sp_trace_setevent @TraceID, 13, 10, @on
exec sp_trace_setevent @TraceID, 13, 12, @on
exec sp_trace_setevent @TraceID, 13, 14, @on
exec sp_trace_setevent @TraceID, 13, 26, @on
exec sp_trace_setevent @TraceID, 13, 35, @on
exec sp_trace_setevent @TraceID, 13, 49, @on
exec sp_trace_setevent @TraceID, 13, 51, @on
exec sp_trace_setevent @TraceID, 13, 60, @on


-- Set the Filters
declare @intfilter int
declare @bigintfilter bigint

exec sp_trace_setfilter @TraceID, 10, 0, 7, N'SQL Server Profiler - e6cc5a18-0442-4297-9d98-4d3c35bf9551'
-- Set the trace status to start
exec sp_trace_setstatus @TraceID, 1

-- display trace id for future references
select TraceID=@TraceID
goto finish

error: 
select ErrorCode=@rc

finish: 
go
