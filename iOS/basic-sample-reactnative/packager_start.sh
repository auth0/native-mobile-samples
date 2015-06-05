#!/bin/bash

JS_DIR=`pwd`/React
ASSETS_DIR=`pwd`/iOS/Images.xcassets;

cd Pods/React
npm run start -- --root $JS_DIR --assetRoots $ASSETS_DIR