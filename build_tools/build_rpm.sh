#!/bin/bash

export TF_NAME=tensorflow-model-serving-$TF_GIT_BRANCH
export BIN_FILE=/home/default/rpmbuild/SOURCES/tensorflow_model_server
export BIN_NAME=tensorflow_model_server
echo $TF_NAME
echo $BIN_FILE
echo $BIN_NAME

rpmdev-setuptree
cp -r $BUILD_TOOLS_DIR/rpmmacros /home/default/.rpmmacros
cp -r /workspace/bazel-bin/tensorflow_serving/model_servers/tensorflow_model_server /home/default/rpmbuild/SOURCES/tensorflow_model_server
cp -r $BUILD_TOOLS_DIR/specfile /home/default/rpmbuild/SPECS/$TF_NAME.spec
cd /home/default/rpmbuild/SPECS
rpmbuild -bb tensorflow-*
cp bld/rpm/x86_64/tensorflow-model-serving-* /workspace/bins/
