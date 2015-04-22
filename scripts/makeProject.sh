#!/bin/bash

usage="# Call with the following options:
# $0 [tag] ["unstable"/"stable"] [username for svn]
# e.g. $0 mp7fw_v1_6_0 stable dinyar
# or   $0 mp7fw_v1_7_1 unstable dinyar
"

if [ ! $# -eq 3 ];
then
	echo "ERROR: Expected 3 arguments."
	echo "Usage:"
	echo "$usage"
	exit
fi

tag=$1
username=$3

scriptsPath=$(pwd)
topPath=$scriptsPath"/../../"

# If directory for mp7fw doesn't exist we'll create it.
mp7fwPath=$topPath"/mp7fw/"
mp7Path=$mp7fwPath"/"$tag
if [ ! -d $mp7Path ];
then
	mkdir $mp7Path
fi

# Check out mp7fw
pushd $mp7Path
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
echo "Done with mp7fw checkout. Fetching project.. "
./ProjectManager.py fetch projects/examples/mp7xe_690
./ProjectManager.py vivado projects/examples/mp7xe_690

cd ..

echo "Setting this tag as current tag.. "
mp7currDir=mp7fw_current
mp7currPath=$mp7fwPath/$mp7currDir
rm -f $mp7currDir
ln -s $tag $mp7currDir

cd $mp7currPath

echo "Adding dependency file for the uGMT to the null algo dep file."
pushd cactusupgrades/components/mp7_null_algo/firmware/cfg/
{ echo -n 'include -c components/uGMT_algos uGMT_algo.dep\n'; cat mp7_null_algo.dep; } > mp7_null_algo.dep.1
mv mp7_null_algo.dep.1 mp7_null_algo.dep

popd
echo $(pwd)

echo "Removing constraints for null algo."
echo "" > cactusupgrades/components/mp7_null_algo/firmware/ucf/mp7_null_algo.tcl

pushd $scriptsPath
echo "Retrieving LUT content files.."
python get_luts.py binary --outpath ../uGMT_algos/firmware/hdl/ipbus_slaves/

echo "#########################################################################"
echo "To complete the setup process navigate to $mp7currPath and edit
cactusupgrades/boards/mp7/base_fw/mp7xe_690/firmware/hdl/mp7xe_690.vhd
as well as
cactusupgrades/components/mp7_infra/addr_table/mp7xe_infra.xml
as described in README.md."
echo "To create the project execute 'make project' in $mp7currPath/mp7xe_690."
echo "#########################################################################"

exit
