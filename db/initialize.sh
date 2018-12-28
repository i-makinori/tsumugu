#!/bin/bash


DB_NAME="tsumugu.db"
INITIALIZE="initialize.sql"

rm "$DB_NAME"
cat $INITIALIZE | sqlite3 $DB_NAME
