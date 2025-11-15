#!/usr/bin/env python3
"""
check_mysql_jar.py
Simple helper to scan the repository for a MySQL Connector/J jar and print its path(s).
"""
import os
import glob

repo_root = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
patterns = [
    os.path.join(repo_root, '**', 'mysql-connector*.jar'),
    os.path.join(repo_root, '**', '*mysql*connector*.jar'),
    os.path.join(repo_root, '**', 'mysql-connector-java-*.jar')
]

matches = []
for p in patterns:
    matches.extend(glob.glob(p, recursive=True))

matches = sorted(set(matches))

if not matches:
    print('No MySQL Connector/J jar found in the repository.')
    print('You can run download_mysql_connector.sh to fetch one: ./SCD/download_mysql_connector.sh')
else:
    print('Found MySQL Connector/J jars:')
    for m in matches:
        print(' -', m)
