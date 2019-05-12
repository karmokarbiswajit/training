#!/bin/bash

rm -r ./PDO/*
rm -r mapping_xml.txt
rm -r mapping.txt
rm -r mapplet.txt
rm -r pdo.txt
rm -r workflow_xml.txt
rm -r workflow.txt
rm -r icf_control_file.txt
rm -r xml_tag.txt

while IFS=',' read -r object name; do
  [[ $object == "Workflow" ]] && printf "%s\n" "$name"
done < test.csv > workflow.txt

while IFS=',' read -r object name; do
  [[ $object == "Mapping" ]] && printf "%s\n" "$name"
done < test.csv  > mapping.txt
#done < test.csv | grep "insurer"  > mapping.txt

while IFS=',' read -r object name; do
  [[ $object == "Mapplet" ]] && printf "%s\n" "$name"
done < test.csv > mapplet.txt

while IFS=',' read -r object db name; do
  [[ $object == "PDO" ]] && printf "%s\n" "$db,$name"
done < test.csv > pdo.txt

awk -F\, 'NF{F="./PDO/" $1 ".txt"; print $2 >> F; close(F)}' pdo.txt

if ! [[ -s workflow.txt ]]; then rm -r workflow.txt; fi
if ! [[ -s mapping.txt ]]; then rm -r mapping.txt; fi
if ! [[ -s mapplet.txt ]]; then rm -r mapplet.txt; fi
if ! [[ -s pdo.txt ]]; then rm -r pdo.txt; fi

if [ -f workflow.txt ]; then
echo '      <objectList resolution="reuse" select="all" type="Workflow">' > workflow_xml.txt
while read -r name
do
echo '           <object resolution="replace" name="'${name[0]}'"/>' >> workflow_xml.txt
done < workflow.txt
echo '      </objectList>' >> workflow_xml.txt
fi

if [ -f mapping.txt ]; then
echo '      <objectList resolution="reuse" select="all" type="Mapping">' > mapping_xml.txt
while read -r name
do
echo '           <object resolution="replace" name="'${name[0]}'"/>' >> mapping_xml.txt
done < mapping.txt
echo '      </objectList>' >> mapping_xml.txt
fi

echo '<xml tags here>' > icf_control_file.txt
echo '<another set of xml tags>' >> icf_control_file.txt
echo '   <folderMaps>' >> icf_control_file.txt
echo '      <!--******* section for EDW Standar *********-->' >> icf_control_file.txt
echo '      <folderMap sourceProject="EDW_STANDARDIZATION" sourceFolderPath="/ACT" targetProject="EDW_STANDARDIZATION" targetFolderPath="/ACT"  recursive="false" select="all" resolution="reuse"' >> icf_control_file.txt
if [ -f workflow_xml.txt ]; then cat workflow_xml.txt >> icf_control_file.txt; fi
if [ -f mapping_xml.txt ]; then cat mapping_xml.txt >> icf_control_file.txt; fi
echo '      </folderMap>' >> icf_control_file.txt

touch xml_tag.txt

ls ./PDO/*.txt | while read i
do  #echo "${i}"
    dbname=$(echo "${i}" | sed 's/\.\/PDO\///g' | sed -e 's/\.txt//g')
    echo "          foldermap /PDO/${dbname}"
    while IFS=$',' read -r -a table
    do
    echo '   object name="'${table[0]}'"/>'>>xml_tag.txt
    done <./PDO/${dbname}.txt

done>>xml_tag.txt
