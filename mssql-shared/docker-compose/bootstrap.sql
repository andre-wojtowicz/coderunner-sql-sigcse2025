USE [master]
-- create a login for jobe that's able to create users and databases
CREATE LOGIN [jobe_runner] WITH PASSWORD=N'jobe_runner', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF;
GRANT ALTER ANY DATABASE TO [jobe_runner];
GRANT ALTER ANY LOGIN TO [jobe_runner];
GRANT CREATE ANY DATABASE TO [jobe_runner];
-- modify model database to apply 100MB limits
ALTER DATABASE [model] MODIFY FILE ( NAME = N'modeldev', MAXSIZE = 102400KB )
ALTER DATABASE [model] MODIFY FILE ( NAME = N'modellog', MAXSIZE = 102400KB )