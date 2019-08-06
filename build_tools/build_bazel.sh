#! /bin/bash

# ensure setup_devtoolset.sh and setup_python.sh
#

gcc -v
python -V
FULL_JAVA_HOME=$(readlink -f $JAVA_HOME)
echo "FULL_JAVA_HOME="$FULL_JAVA_HOME
export JAVA_HOME=$FULL_JAVA_HOME
cd /opt/app-root/
echo "BAZEL_VERSION="$BAZEL_VERSION
if [ "$BAZEL_VERSION" = "0.24.1" ] ; then 
    # mkdir -p /opt/app-root/output/
    # cd /opt/app-root/output/
    # wget https://github.com/sub-mod/bazel-builds/releases/download/0.24.1/bazel-0.24.1
    ls -l /opt/app-root/output/
else
    ./compile.sh
fi
# put /opt/app-root/output/bazel in path
export PATH=/opt/app-root/output/:$PATH
# cp /opt/app-root/output/bazel /usr/local/bin/
bazel version