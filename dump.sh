#!/bin/bash
#Scripted by Htay Aung Shein

array=($(cut -d "," -f2 ../mtable.txt))
freq=10

echo "#!/bin/bash" > ../idump.txt
echo "SHELL=/bin/bash" >> ../idump.txt
echo "PATH=/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:../bin:../bin" >> ../idump.txt

# To empty the data file and grant permission before dumping reports
echo "" > ../data.txt
chmod 777 ../data.txt

# This part is for non-target campaigns.
for((i=0; i < ${#array[@]}; i+=freq))
do
echo "{">>../idump.txt
echo "sleep 2">>../idump.txt
echo "echo username">>../idump.txt
echo "sleep 1">>../idump.txt
echo "echo passwd">>../idump.txt
echo "sleep 1">>../idump.txt
echo "echo cd imdb">>../idump.txt
echo "echo pwd">>../idump.txt
part=( "${array[@]:i:freq}" )
for s in ${!part[*]}
do
        echo "echo da ${part[$s]} 501">>../idump.txt
done
echo "sleep 1">>../idump.txt
echo "echo exit">>../idump.txt
echo "} | telnet 0 4444 >>../data.txt">>../idump.txt
done

# This  part is for target campaigns dump.
array=($(cut -d "," -f2 ../Tarcam.txt))
freq=10

for((i=0; i < ${#array[@]}; i+=freq))
do
echo "{">>../idump.txt
echo "sleep 2">>../idump.txt
echo "echo username">>../idump.txt
echo "sleep 1">>../idump.txt
echo "echo passwd">>../idump.txt
echo "sleep 1">>../idump.txt
echo "echo cd imdb">>../idump.txt
echo "echo pwd">>../idump.txt
part=( "${array[@]:i:freq}" )
for s in ${!part[*]}
do
        echo "echo da ${part[$s]} 501">>../idump.txt
done
echo "sleep 1">>../idump.txt
echo "echo exit">>../idump.txt
echo "} | telnet 0 4444 >>../data.txt">>../idump.txt
done

#cat idump.txt>outdump.sh
mv ../idump.txt ../idump.sh
chmod 777 ../idump.sh
sh ../idump.sh
