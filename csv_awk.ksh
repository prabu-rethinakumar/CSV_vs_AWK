#!/usr/bin/ksh
basedir=$HOMEDIR/AWK
name=$(basename $0)
day=$(date +%d%m%y%H%M%S)
logname=$name.$day.log
cat >> $logname < /dev/null
summary=$basedir/assign/summary.txt

#########################
###Repo which contains all of your CSV files 
repo=$basedir/stats/DATA/
#############################

cd $basedir/assign

if [ -e $summary ]
then
    rm -f $basedir/assign/summary.txt
    rm -f $basedir/assign/summary_out.csv
    echo "Files removed successfully" >> $logname
else
    echo "Cleanup unnecessary"
fi

echo "Finding all *.csv files from repo"

find $repo -iname '*.csv' > $summary

if [ $? -eq 0 ]
then
    echo "Find completed successfully"
else
    echo "Couldn't find any *.csv files"
fi

echo "FileName, TotalRecords, TotalFields, WordCount" >> summary_out.csv
while read filename
do
  #echo "Filename is $filename"
  word_count=$(wc -w < $filename)
  awk -v w_c="$word_count" '
       BEGIN{FS=",";OFS=","}
       END{print FILENAME, FNR, NF, w_c >> "summary_out.csv" ;}
      ' $filename ;
 # echo $filename
done < $summary

  awk '
      BEGIN{
            print "Started Caculating stats";
            FS=",";ACC_SUM=0;ACC_FIELDS=0
           }
           {if(NR>1)
                {
                  ACC_SUM+=$2;
                  ACC_FIELDS+=$3
                }
            }
      END{
          print "Total Files processed            : " NR "\n",
                "Sum of records in all files      : " ACC_SUM "\n",
                "Average of no. of fields in files: " ACC_FIELDS/NR
         };' summary_out.csv


echo " Print all Contents of file "
cat summary_out.csv
