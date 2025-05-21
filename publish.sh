#!/bin/bash

git pull origin main
rm -rf ./VocLiveChatFramework/
mkdir -p VocLiveChatFramework
cp -R ./Assets/ VocLiveChatFramework/Assets
cp -R ./Classes/ VocLiveChatFramework/Classes
pod repo push SPEC_REPO *.podspec --verbose --use-libraries --allow-warnings