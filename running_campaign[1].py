#!/usr/bin/python
# author - Htay Aung Shein
# The purpose of this script is to fetch all running campaing from the database and delivery to respective people on mail.

from os import popen
from sys import argv
from argparse import ArgumentParser
from datetime import date, datetime


import psycopg2

from config import config


def connect(ini_file):
        """ Connect to the PostgreSQL database server """
        connection = None
        try:
                # read connection parameters
                params = config(ini_file)
                # connect to the PostgreSQL server
                print('Connection to the PostgreSQL database...')
                connection = psycopg2.connect(**params)
        except  (Exception, psycopg2.OperationalError) as error:
                print("Error while connecting to PostgreSQL", error)
        return connection

def read_query(connection, query):
        result = list()
        if connection is not None:
                try:
                        with connection.cursor() as cursor:
                                # Fetch result
                                cursor.execute(query)
                                result = cursor.fetchall()
                except (psycopg2.Error) as db_err:
                        print("Error to Execute query {0}".format(db_err))
        else:
                print("No connection to the database")
        return result

def close_connection(connection):
        try:
                connection.close()
                print("PostgreSQL connection is closed")
        except (Exception,IOError,psycopg2.Error) as e:
                print("Error while closing connection: {0}".format(e))


def main():
        connection = connect('../database.ini')
        adhoc_query = "select row_number() over (order by t.iid) as Num , api.profile_identity, left(t.iname, -9) as Campaign, (select case when cast(parameter_value as INTEGER) = 0 then '1' when cast(parameter_value as INTEGER) > 0 then '0' END from task_in_out_params tiop where task_id = t.iid and task_param_type_id = 130) as Tflag from tasks t join use_case_runs ucr on (t.use_case_run_id = ucr.iid) left join agg_profile_instances api on (ucr.iid = api.run_id) where api.prof_spec_id = 10064 and api.profile_ident_type = 501 and t.task_type_id = 8 and t.task_status_id = 2 and ltrim(t.iname) like 'UC-%' and position(',' in t.iname) = 0;"
        report_table = read_query(connection, adhoc_query)
        with open('../table.txt', "wt") as f:
                for line in report_table:
                        f.write(','.join(str(s) for s in line) + '\n')

        close_connection(connection)
        os.chmod('../table.txt', 0o777)

if __name__=='__main__':
        main()
