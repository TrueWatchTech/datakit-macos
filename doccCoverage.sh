# sh doccCoverage.sh all  Get all documentation coverage
# sh doccCoverage.sh      Get public file documentation coverage
project_path='FTMacOSSDK.xcodeproj/project.pbxproj'
sdk_path=$(pwd)/build

changeFileAttributeToPublic(){
states='init'
lineNum=0
cat -n $project_path | while read line
do
  lineNum=`expr $lineNum + 1`
  if [[ $line =~ 'Begin PBXBuildFile section */' ]]
  then
  states='start'
      echo $line
  elif [[ $line =~ 'End PBXBuildFile section */' ]]
  then
  states='end'
      echo $line
  elif [[ $states = 'start' ]]
  then
    if [[ $line =~ '.h in Headers */' ]];then
       if [[ $line =~ 'settings = {ATTRIBUTES = (Public,' ]];then
           echo "Already a Public file"
       else
           #brew install gnu-sed
           sed -i "" "$lineNum s/\}\;/settings = \{ATTRIBUTES = \(Public, \)\; \}\; \}\;/" $project_path
       fi
    fi
  fi
done
}

doccCoverage(){
xcodebuild -target FTMacOSSDK DOCC_EXTRACT_SWIFT_INFO_FOR_OBJC_SYMBOLS=NO

xcrun docc convert FTMacOSSDK/Documentation.docc \
--fallback-display-name FTMacOSSDK \
--fallback-bundle-identifier com.ft.mobile.sdk.FTMacOSSDK \
--fallback-bundle-version 1.0 \
--additional-symbol-graph-dir ./build/FTMacOSSDK.build/Release/FTMacOSSDK.build/symbol-graph \
--experimental-documentation-coverage \
--level detailed
}

# If all, get comment coverage for all files
FT_ALL_FILE_COVERAGE="$1"
echo "----- Start -----"

if [[ "$FT_ALL_FILE_COVERAGE" == "all" ]]; then
echo "-----changeFileAttributeToPublic Start-----"
changeFileAttributeToPublic
echo "-----changeFileAttributeToPublic End-----"
fi

echo "-----Coverage Start-----"
doccCoverage
echo "-----Coverage End-----"

if [[ "$FT_ALL_FILE_COVERAGE" == "all" ]]; then
git checkout -- $project_path
echo "----- End -----"
fi
