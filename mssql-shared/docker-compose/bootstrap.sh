#!/bin/bash
/opt/mssql-tools/bin/sqlcmd \
        -S localhost \
        -U sa \
        -P FIXME \
        -d master \
        -l 30 \
        -t 30 \
        -i /bootstrap.sql

echo "Executed bootstrap.sql."