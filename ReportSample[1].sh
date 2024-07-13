#!/bin/bash
#Scripted by Htay Aung Shein
#The purpose of this script is to generate campaign Qualifier Revenue Report of V2 only.

repo=directory_location

#To get master table from db for taker revenue report.
rm "$repo"table.txt
ssh user@db_server_ip "python ../reports_table.py;exit"
echo "df ../table.txt"|sftp -b - user@db_server_ip
if [ $? != 0 ]
then
    echo "File does not exists"
    exit
fi

sftp user@db_server_ip <<< $'lcd ../auto_taker_revenue_report\n cd ../taker_master_table\n get table.txt\n rm table.txt'

cut -d "," -f1,2,3,4 "$repo"table.txt|grep ",0$">"$repo"mtable.txt
cut -d "," -f1,2,3,4 "$repo"table.txt|grep ",1$">"$repo"Tarcam.txt
cat "$repo"Tarcam.txt>>"$repo"mtable.txt
rm "$repo"cam.csv
rm "$repo"Tcam.csv
sh "$repo"dump.sh
sh "$repo"idump.sh
sleep 5


array=($(cut -d "," -f2 "$repo"mtable.txt))

n=${array[-1]}

cut -d "," -f2,3,4 "$repo"mtable.txt|grep ",0"|cut -d "," -f2>"$repo"camname.csv
cut -d "," -f2,3,4 "$repo"mtable.txt|grep ",1"|cut -d "," -f2>"$repo"Tcamname.csv

evaluate_value() {
        if [ $Tflag -eq 0 ]
        then
                (cat "$repo"data.txt| sed -n "/name:$curr_id/,/name:$next_id/p"|head -n-1 |tail -n+2)>"$repo"tmp.txt
                TD=`date +%m/%d/%Y`
                YD=`date +%m/%d/%Y --date='yesterday'`
                local a=($(grep "def:37789 " "$repo"tmp.txt -A 7 |grep `date +%m/%d/%Y --date=' yesterday'`|cut -d " " -f5))
                local b=($(grep "def:37789 " "$repo"tmp.txt -A 7 |grep `date +%m/%d/%Y --date=' today'`|cut -d " " -f5))
                local c=($(grep "def:37789 " "$repo"tmp.txt -B 2 |grep `date +%m/%d/%Y --date=' yesterday'`|cut -d " " -f5))
                local d=($(grep "def:37789 " "$repo"tmp.txt -B 2 |grep `date +%m/%d/%Y --date=' today'`|cut -d " " -f5))
#               echo -e "$a\t$b\t$c\t$d"
                if [ -z "$a" ]
                then
                        printf "0,">>"$repo"cam.csv
                else
                        printf "$a,">>"$repo"cam.csv
                fi

                if [ -z "$b" ]
                then
                        printf "0,">>"$repo"cam.csv
                else
                        printf "$b,">>"$repo"cam.csv
                fi

                if [ -z "$c" ]
                then
                        printf "0,">>"$repo"cam.csv
                else
                        printf "$c,">>"$repo"cam.csv
                fi

                if [ -z "$d" ]
                then
                        printf "0\n">>"$repo"cam.csv
                else
                        printf "$d\n">>"$repo"cam.csv
                fi
        else
                (cat "$repo"data.txt| sed -n "/name:$curr_id/,/name:$next_id/p"|head -n-1 |tail -n+2)>"$repo"tmp.txt
                TD=`date +%m/%d/%Y`
                YD=`date +%m/%d/%Y --date='yesterday'`
                local a=($(grep "def:37789 " "$repo"tmp.txt -A 7 |grep `date +%m/%d/%Y --date=' yesterday'`|cut -d " " -f5))
                local b=($(grep "def:37789 " "$repo"tmp.txt -A 7 |grep `date +%m/%d/%Y --date=' today'`|cut -d " " -f5))
                local c=($(grep "def:37789 " "$repo"tmp.txt -B 2 |grep `date +%m/%d/%Y --date=' yesterday'`|cut -d " " -f5))
                local d=($(grep "def:37789 " "$repo"tmp.txt -B 2 |grep `date +%m/%d/%Y --date=' today'`|cut -d " " -f5))
                local e=($(grep " 37746 " "$repo"tmp.txt|cut -d " " -f4))
                if [ -z "$a" ]
                then
                        printf "0,">>"$repo"Tcam.csv
                else
                        printf "$a,">>"$repo"Tcam.csv
                fi

                if [ -z "$b" ]
                then
                        printf "0,">>"$repo"Tcam.csv
                else
                        printf "$b,">>"$repo"Tcam.csv
                fi

                if [ -z "$c" ]
                then
                        printf "0,">>"$repo"Tcam.csv
                else
                        printf "$c,">>"$repo"Tcam.csv
                fi

                if [ -z "$d" ]
                then
                        printf "0,">>"$repo"Tcam.csv
                else
                        printf "$d,">>"$repo"Tcam.csv
                fi

                if [ -z "$e" ]
                then
                        printf "0\n">>"$repo"Tcam.csv
                else
                        printf "$e\n">>"$repo"Tcam.csv
                fi
        fi
}
for ix in ${!array[*]}
do
   curr_id=${array[$ix]}
   Tflag=$(cat "$repo"mtable.txt|grep "$curr_id"|cut -d "," -f4|tr -d '\r')

   if [ $curr_id != $n ]
   then
                next_id=${array[$[ix+1]]}
                evaluate_value "$curr_id" "$next_id" "$Tflag"
   else
                next_id=tail
                evaluate_value "$curr_id" "$next_id" "$Tflag"
   fi
done

paste -d, "$repo"camname.csv "$repo"cam.csv | sed 's/^,//; s/,$//' > "$repo"result.csv
paste -d, "$repo"Tcamname.csv "$repo"Tcam.csv | sed 's/^,//; s/,$//' > "$repo"Tresult.csv

python "$repo"htmlformat.py
sleep 3

python "$repo"mailTo.py