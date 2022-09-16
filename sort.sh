shopt -s extglob

if [ ! -d data ]
then
    echo "error... no data directory found"
    exit 1
fi


if [ ! -d data/sorted ]
then
    mkdir data/sorted
else
    rm -r data/sorted/*
fi

#New bounds on (m,n) for the git repository: m: [4,12], n: [2,10]
for i in data/@([4-9]|10|11|12)-@([2-9]|10)*.txt
do
   cat $i | gawk '{ print length, $0 }' | sort -n | gawk 'BEGIN {FS="+|-"}; { print NF, $0 }' | sort -n -s | cut -d " " -f3- > data/sorted/$(echo $i | cut -d "/" -f2-)
   #head -n 1 data/sorted/$(echo $i | cut -d "/" -f2-) | sed 's/matrix {{//g; s/\s*//g; s/}}//g; s/\*//g' > data/formatted/$(echo $i | cut -d "/" -f2-)
   echo $i
done
