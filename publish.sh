#!/bin/bash
git pull origin main
ver=`cat VocLiveChatFramework.podspec| grep 's.version ' |grep -oE '[0-9]+\.[0-9]+\.[0-9]+'`
echo $ver
git tag $ver
git push --tags
pod repo push SPEC_REPO *.podspec --verbose --use-libraries --allow-warnings