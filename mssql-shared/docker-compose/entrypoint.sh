#!/bin/bash
# start MSSQL and capture the PID for monitoring
/opt/mssql/bin/sqlservr & sqlpid=$!

# execute initial T-SQL load
/bootstrap.sh

# wait for sqlserver to exit
while s=`ps -p $sqlpid -o s=` && [[ "$s" && "$s" != 'Z' ]]; do
    sleep 1
done