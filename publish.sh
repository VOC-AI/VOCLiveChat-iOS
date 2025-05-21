#!/bin/bash
git pull origin main
ver=`cat VocLiveChatFramework.podspec| grep 's.version ' |grep -oE '[0-9]+\.[0-9]+\.[0-9]+'`
echo $ver
git tag $ver
git push --tags
rm -rf ./VocLiveChatFramework/
mkdir -p VocLiveChatFramework
cp -R ./Assets/ VocLiveChatFramework/Assets
cp -R ./Classes/ VocLiveChatFramework/Classes
pod repo push SPEC_REPO *.podspec --verbose --use-libraries --allow-warnings