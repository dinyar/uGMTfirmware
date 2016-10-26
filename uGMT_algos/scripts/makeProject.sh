#!/bin/bash

usage="
# Directory for mp7fw can be chosen freely.
# Call with the following options:
# $0 [path in CACTUS] [tag/branch] [username for svn] [path for mp7fw]
# e.g. $0 tags/mp7/stable/firmware/ mp7fw_v2_2_0 dinyar /[...]/mp7fwdirectory
# or   $0 branches/ mp7fw_v2_2_X_support dinyar /[...]/mp7fwdirectory
"

if [ ! $# -eq 4 ];
then
    echo "ERROR: Expected 4 arguments."
    echo
    echo "########### Usage: ###########"
    echo "$usage"
    exit
fi

cactusPath=$1
cactusDir=$2
username=$3

if [ ! -d $4 ];
then
    mkdir -p $4
fi
mp7fwPath=$(cd $4 && pwd)

scriptsPath=$(pwd)
uGMTalgosPath=$scriptsPath"/../"
#topPath=$scriptsPath"/../../../"

# If directory for mp7fw doesn't exist we'll create it.
mp7path=$mp7fwPath"/"$cactusDir
if [ ! -d $mp7path ];
then
    mkdir -p $mp7path
fi

# Check out mp7fw
pushd $mp7path
wget --no-check-certificate https://svnweb.cern.ch/trac/cactus/browser/trunk/cactusupgrades/scripts/firmware/ProjectManager.py\?format\=txt -O ProjectManager.py
if [ -f ProjectManager.py.1 ];
then
    mv ProjectManager.py.1 ProjectManager.py
fi
chmod a+x ProjectManager.py

checkoutString="create "$cactusPath"/"$cactusDir
checkoutCommand="$checkoutString -u $username --board mp7"
./ProjectManager.py $checkoutCommand

if [ "$?" == 0 ];
then
    echo "Done with mp7fw checkout. Fetching project.. "
else
    cd ..
    rm -rf $cactusDir
    echo "Error, couldn't check out mp7fw."
    exit
fi
./ProjectManager.py fetch projects/ugmt
./ProjectManager.py vivado projects/ugmt

cd ..

echo "Setting this tag as current tag.. "
mp7currDir=mp7fw_current
rm -f $mp7currDir
ln -s $cactusDir $mp7currDir
mp7currPath=$mp7fwPath/$mp7currDir

cd $mp7currPath

echo "Replacing ugmt algos from SVN repo with our version.. "
pushd cactusupgrades/projects/ugmt
rm -rf *
ln -s $uGMTalgosPath/* .

popd

cd ugmt
ln -s $scriptsPath/runAll.sh .
ln -s $scriptsPath/checkTiming.py .

pushd $scriptsPath
echo "Retrieving LUT content files.."
python get_luts.py binary --outpath ../firmware/hdl/ipbus_slaves/

echo "#############################################################################"
echo "To create the project execute 'make project' in
$mp7currPath/ugmt ."
echo "#############################################################################"

exit
