#!/bin/bash -e
R_WHEEL_FILE=$(basename `ls  $1` )
R_BUILD_INFO=$(basename `ls  $2` )
[[  -z "$R_WHEEL_FILE" ]] && echo "R_WHEEL_FILE value needed" && exit 1 
[[  -z "$R_BUILD_INFO" ]] && echo "R_BUILD_INFO value needed" && exit 1 


echo "Changing METADATA..."
unzip -xvf $R_WHEEL_FILE | grep METADATA
unzip -q $R_WHEEL_FILE
ls -l *.dist-info/

printf "METADATA...\n"
grep -e "Platform" -e "Author-email"   -e "Author"  -e "Disclaimer" *.dist-info/METADATA 
sed -i "s/Platform.*/Platform: $(cat /etc/redhat-release)\\nKernel: $(uname -or |awk '{print $1;}')/" *.dist-info/METADATA
sed -i "s/Author-email:.*/Author-email: smodeel@redhat.com/" *.dist-info/METADATA
sed -i "s/Author:.*/Author: Red Hat Inc./" *.dist-info/METADATA		
DISCLAIMER="$(cat <<-EOF
Disclaimer: Following wheel files are created by Red Hat AICoE experimental builds and are without any support.
There is NO warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
EOF
)"
echo "$DISCLAIMER" >> *.dist-info/METADATA

cp $2 *.dist-info/
zip -u $R_WHEEL_FILE *.dist-info/*
rm -fr *.dist-info/
rm -fr *.data/
ls -l


printf "New METADATA...\n"
unzip -q $R_WHEEL_FILE
grep -e "Platform" -e "Author-email"   -e "Author"  -e "Disclaimer" *.dist-info/METADATA
ls -l *.dist-info | grep build_info.yaml
whlff=$(basename `ls  *.whl` .whl )
mv /workspace/bins/*.whl /workspace/bins/$whlff.whl.bkp
cp *.whl /workspace/bins/


pip install /workspace/bins/*.whl --user
