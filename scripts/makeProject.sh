#!/bin/bash

usage="
# Directory for mp7fw can be chosen freely.
# Call with the following options:
# $0 [tag] ['unstable'/'stable'] [username for svn] [path for mp7fw]
# e.g. $0 mp7fw_v1_6_0 stable dinyar /[...]/mp7fwdirectory
# or   $0 mp7fw_v1_7_1 unstable dinyar /[...]/mp7fwdirectory
"

if [ ! $# -eq 4 ];
then
	echo "ERROR: Expected 4 arguments."
	echo
	echo "########### Usage: ###########"
	echo "$usage"
	exit
fi

tag=$1
username=$3
mp7fwPath=$4

scriptsPath=$(pwd)
uGMTalgosPath=$scriptsPath"/../"
topPath=$scriptsPath"/../../"

# If directory for mp7fw doesn't exist we'll create it.
mp7path=$mp7fwPath"/"$tag
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
if [ "$2" == "stable" ];
then
	checkoutString=""
elif [ "$2" == "unstable" ];
then
	unstableSelector="unstable/"
else
	echo "Error, indicate whether checking out a stable or unstable tag."
	exit
fi

checkoutString="checkout tags/mp7/"$unstableSelector"firmware/"$tag
checkoutCommand="$checkoutString -u $username"
./ProjectManager.py $checkoutCommand

if [ "$?" == 0 ];
then
	echo "Done with mp7fw checkout. Fetching project.. "
else
	cd ..
	rm -rf $tag
	echo "Error, couldn't check out mp7fw."
	exit
fi
./ProjectManager.py fetch projects/examples/mp7xe_690
./ProjectManager.py vivado projects/examples/mp7xe_690

cd ..

echo "Setting this tag as current tag.. "
mp7currDir=mp7fw_current
rm -f $mp7currDir
ln -s $tag $mp7currDir
mp7currPath=$mp7fwPath/$mp7currDir

cd $mp7currPath

echo "Adding dependency file for the uGMT to the null algo dep file."
pushd cactusupgrades/components/mp7_null_algo/firmware/cfg/
sed -i '1iinclude -c components/uGMT_algos uGMT_algo.dep' mp7_null_algo.dep

popd

echo "Linking uGMT_algos into cactusupgrades/components"
pushd cactusupgrades/components/
ln -s $uGMTalgosPath/uGMT_algos .

popd

echo "Replacing top_decl.vhd by link to custom version"
pushd cactusupgrades/projects/examples/mp7xe_690/firmware/hdl
rm -f top_decl.vhd

ln -s $uGMTalgosPath/top_decl.vhd .

popd

echo "Removing constraints for null algo."
echo "" > cactusupgrades/components/mp7_null_algo/firmware/ucf/mp7_null_algo.tcl

cd mp7xe_690
ln -s $uGMTalgosPath/runAll.sh .

pushd $scriptsPath
echo "Retrieving LUT content files.."
python get_luts.py binary --outpath ../uGMT_algos/firmware/hdl/ipbus_slaves/

echo "#############################################################################"
echo "To complete the setup process navigate to
$mp7currPath and edit
cactusupgrades/boards/mp7/base_fw/mp7xe_690/firmware/hdl/mp7xe_690.vhd
as well as
cactusupgrades/components/mp7_infra/addr_table/mp7xe_infra.xml
as described in README.md."
echo "To then create the project execute 'make project' in
$mp7currPath/mp7xe_690."
echo "#############################################################################"

exit
