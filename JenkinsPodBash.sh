#FT_PUSH_TAG="refs/tags/1.0.0-alpha.1"


VERSION=$(echo "$FT_PUSH_TAG" | sed -e 's/.*\///g' | sed -e 's/~.*//g' )
REPO_URL=git@github.com:TrueWatchTech/datakit-macos.git

if git config remote.github.url; then
    git config remote.github.url $REPO_URL
else
    git remote add github $REPO_URL
fi

git push github $VERSION

if [[ $? -eq 0 ]];then

  sed  -i '' 's/SDK_VERSION.*/SDK_VERSION @"'$VERSION'"/g' FTMacOSSDK/SDKCore/FTMacOSSDKVersion.h

  sed  -i '' 's/$JENKINS_DYNAMIC_VERSION/'"$VERSION"'/g' FTMacOSSDK.podspec

  echo pod trunk push FTMacOSSDK.podspec --verbose --allow-warnings

else
  exit  1
fi
