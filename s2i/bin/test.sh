#!/bin/bash -e
#
# S2I run script for the 's2i' image.
# The run script executes the server that runs your application.
#
# For more information see the documentation:
#	https://github.com/openshift/source-to-image/blob/master/docs/builder_image.md
#
set -e
set -o pipefail

echo "run...."
export CUSTOM_BUILD="bazel build -c opt --local_resources 2048,2.0,1.0  //tensorflow_serving/model_servers:tensorflow_model_server --verbose_failures"
command_exists () { type "$1" &> /dev/null ; }
file_exists () { test -f $1 ; }
folder_exists () { test -d $1 ; }


### These ENVs should be set for configure.
echo "TF_NEED_JEMALLOC = "$TF_NEED_JEMALLOC
echo "TF_NEED_GCP = "$TF_NEED_GCP
echo "TF_NEED_VERBS = "$TF_NEED_VERBS
echo "TF_NEED_HDFS = "$TF_NEED_HDFS
echo "TF_ENABLE_XLA = "$TF_ENABLE_XLA
echo "TF_NEED_OPENCL = "$TF_NEED_OPENCL
echo "TF_NEED_CUDA = "$TF_NEED_CUDA
echo "TF_NEED_MPI = "$TF_NEED_MPI
echo "TF_NEED_GDR = "$TF_NEED_GDR
echo "TF_NEED_S3 = "$TF_NEED_S3
echo "TF_CUDA_VERSION = "$TF_CUDA_VERSION
echo "TF_CUDA_COMPUTE_CAPABILITIES = "$TF_CUDA_COMPUTE_CAPABILITIES
echo "TF_CUDNN_VERSION = "$TF_CUDNN_VERSION
echo "TF_NEED_OPENCL_SYCL= "$TF_NEED_OPENCL_SYCL
echo "TF_CUDA_CLANG= "$TF_CUDA_CLANG
echo "GCC_HOST_COMPILER_PATH= "$GCC_HOST_COMPILER_PATH
echo "CUDA_TOOLKIT_PATH= "$CUDA_TOOLKIT_PATH
echo "CUDNN_INSTALL_PATH= "$CUDNN_INSTALL_PATH

### 1.9 tensorflow needs below new configs
echo "TF_NEED_KAFKA="$TF_NEED_KAFKA
echo "TF_NEED_OPENCL_SYCL="$TF_NEED_OPENCL_SYCL
echo "TF_DOWNLOAD_CLANG="$TF_DOWNLOAD_CLANG
echo "TF_SET_ANDROID_WORKSPACE="$TF_SET_ANDROID_WORKSPACE

### These ENVs should be correctly set.
echo "PATH = "$PATH
echo "JAVA_HOME = "$JAVA_HOME
echo "PYTHON_LIB_PATH ="$PYTHON_LIB_PATH
echo "LD_LIBRARY_PATH ="$LD_LIBRARY_PATH
echo "PYTHON_BIN_PATH ="$PYTHON_BIN_PATH 

### These ENVs are used in build/publish logic
echo "PORT = "$PORT
echo "BUILD_OPTS = "$BUILD_OPTS
echo "CUSTOM_BUILD = "$CUSTOM_BUILD
echo "TEST_LOOP = "$TEST_LOOP
echo "TF_GIT_BRANCH = "$TF_GIT_BRANCH
echo "NB_PYTHON_VER = "$NB_PYTHON_VER
echo "HOST_ON_HTTP_SERVER ="$HOST_ON_HTTP_SERVER
echo "TEST_WHEEL_FILE = "$TEST_WHEEL_FILE
echo "GIT_RELEASE_REPO = "$GIT_RELEASE_REPO
echo "HOME = "$HOME
echo "============================================"

TEST_CMD="import tensorflow as tf ; a = tf.constant([1.0, 2.0, 3.0, 4.0, 5.0, 6.0], shape=[2, 3], name='a') ; \
	b = tf.constant([1.0, 2.0, 3.0, 4.0, 5.0, 6.0], shape=[3, 2], name='b') ; c = tf.matmul(a, b) ; \
	sess = tf.Session(config=tf.ConfigProto(log_device_placement=True)) ;print(sess.run(c))"



#pip list 2>&1 | grep "YAML\|proto\|numpy"
#echo "PYTHON_LIB_PATH=`$PYTHON_BIN_PATH -c 'import site; print(site.getsitepackages()[0])'`"
#echo "PYTHONPATH="$PYTHONPATH
#PYTHON_LIB_PATH="$($PYTHON_BIN_PATH -c 'import sys;for pth in sys.path: print pth)')"
echo "which_python="`which python`
echo "link_which_python="`ls -l $(which python) | awk '{print  $9 $10 $11}'`
echo "link_bin_python="`ls -l /usr/bin/python |awk '{print  $9 $10 $11}'`
echo "which_pip="`which pip`
echo "which_pip_version="`pip --version `
echo "which_pip_site="`pip --version |awk '{print $4}' `
echo "link_which_pip="`ls -l $(which pip) | awk '{print  $9 $10 $11}'`
pip list 2>&1 | grep "YAML\|proto\|numpy"



# Naming the directory according to the naming convention
OSVER=$(. /etc/os-release;echo $ID$VERSION_ID)
for varname in ${!TF_NEED_*}; do
    if [ "${!varname}" = "1" ]; then
        WORD=$(echo "${varname//TF_NEED_}" | tr '[:upper:]' '[:lower:]')
        if [ "$varname" = "TF_NEED_CUDA" ]; then
                WORD+=$TF_CUDA_VERSION
        fi
        FINAL_STR+=$WORD"+"
    fi
done
TENSORFLOW_BUILD_DIR_NAME=$OSVER/${TF_GIT_BRANCH//r}/${FINAL_STR::-1}



# Dev Mode
# if [[ $TEST_LOOP = "y" ]]
# then
# 	echo "####################################"
# 	echo "      DEV/TEST MODE.....       	  "
# 	echo "####################################"
#     echo "Starting a infinite while loop to debug in console terminal\n"
#     while :
# 	do
# 		echo "Press [CTRL+C] to stop.."
# 		sleep 1
# 	done
# fi


echo "The Python conundrum."
sh /build_tools/python_script.sh
echo "The Python conundrum.DONE."

echo | gcc -E -Wp,-v -
echo "which_pip_version="`pip --version `
pip list 2>&1 | grep "yaml\|proto\|numpy"



### Setup Bazel
cd /workspace
if command_exists bazel ; then 
	echo "bazel command exists."; 
else 
	echo "bazel doesnt exists" && cd /tf/tools/ && 
	./bazel-$BAZEL_VERSION-installer-linux-x86_64.sh --user && 
	export PATH=$HOME/bin:$PATH && bazel && echo "PATH = "$PATH ; 
fi



### git clone tf and test
cd /workspace
echo "####################################"
echo "      clone git repo.....       	  "
echo "####################################"
# git clone --branch=r1.12 --depth=1 https://github.com/tensorflow/serving .
git clone --branch=$TF_GIT_BRANCH --depth=1 https://github.com/tensorflow/serving .
# echo "####################################"
# echo "      test.....       	      "
# echo "####################################"
# bazel test -c opt -- //tensorflow/...
# echo "####################################"
# echo "      configure.....       	      "
# echo "####################################"
# ./configure


export PATH=$HOME/bin:$PATH
echo "PATH = "$PATH



###########################
### TODO NO GPU support yet
###########################
echo "TF_NEED_CUDA = "$TF_NEED_CUDA
if [ $TF_NEED_CUDA = "1" ]; then 
	echo "####################################"
	echo "      CUDA BUILD TODO.....       	  "
	echo "####################################"
fi 

export JAVA_HOME=$(readlink -f $JAVA_HOME)
ls -l $JAVA_HOME


# Naming the directory according to the naming convention
OSVER=$(. /etc/os-release;echo $ID$VERSION_ID)
for varname in ${!TF_NEED_*}; do
	if [ "$varname" = "TF_GIT_BRANCH" ]; then
        continue
    fi
    if [ "${!varname}" = "1" ]; then
        WORD=$(echo "${varname//TF_NEED_}" | tr '[:upper:]' '[:lower:]')
        echo $WORD
        unset "${varname}"
    elif [ "${!varname}" = "0" ]; then
        WORD=$(echo "${varname//TF_NEED_}" | tr '[:upper:]' '[:lower:]')
        echo $WORD
        unset "${varname}"
    fi
done
TENSORFLOW_BUILD_DIR_NAME=$OSVER/${TF_GIT_BRANCH//r}/${FINAL_STR::-1}


### enable TEST_LOOP only which deployment config and NOT with Jobs. 
# if [[ $TEST_LOOP = "y" ]]
# then
# 	echo "####################################"
# 	echo "      DEV/TEST MODE.....       	  "
# 	echo "####################################"
#     echo "Starting a infinite while loop to debug in console terminal\n"
#     while :
# 	do
# 		echo "Press [CTRL+C] to stop.."
# 		sleep 1
# 	done
# fi


# /workspace/bins is final location of binaries
echo "####################################"
echo "      CUSTOM_BUILD.....       	  "
echo "####################################"
cd /workspace
mkdir -p /workspace/bins
cp /build_tools/*.sh .
cp /tmp/*.sh .
ls -l
source ./print_build_info.sh && echo "OK" || echo "Failed"
mv build_info.yaml /workspace/bins/


# TODO refator this out to script
eval "$CUSTOM_BUILD" 2>&1 | tee -a /workspace/build.log ; test ${PIPESTATUS[0]} -eq 0
if (( $? )); then
    echo "####################################"
	echo "      CUSTOM_BUILD  ERROR!!     	  "
	echo "####################################"
	exit 1
else
	echo "####################################"
	echo "      CUSTOM_BUILD  SUCCESS     	  "
	echo "####################################"
	if [ -e bazel-bin/tensorflow_serving/model_servers/tensorflow_model_server ]
	then
		## bazel build is success 
		## cleanup old
		rm -fr /workspace/bins/tensorflow*
		cp bazel-bin/tensorflow_serving/model_servers/tensorflow_model_server /workspace/bins ;

		ls -l /workspace/bins
		#release
		echo "####################################"
		echo "      Releasing...			      "
		echo "####################################"
		rm -fr /tmp/release_dir
		mkdir -p /tmp/release_dir
		cd /tmp/release_dir/
		pwd
		cp /build_tools/*.sh .
		cp /build_tools/*.py .
		cp /workspace/bins/build_info.* /tmp/release_dir/
		cp /workspace/bins/* /tmp/release_dir/
		whlff=$(basename `ls tensorflow*`)
		OSVER=$(. /etc/os-release;echo $ID$VERSION_ID)
		#OSVER=$(cat build_info.yaml | grep -e "OS_VER" | awk '{print $2,$4}' |tr -d " ")
		RELEASE_NAME=$OSVER/$NB_PYTHON_VER/$TF_GIT_BRANCH
		if [ $TF_NEED_CUDA = "1" ]; then
			GIT_TAG="tf-serving-${TF_GIT_BRANCH}-gpu-$(date +%Y-%m-%d_%H%M%S)"
		else
			GIT_TAG="tf-serving-${TF_GIT_BRANCH}-cpu-$(date +%Y-%m-%d_%H%M%S)"
		fi
		NOTES=$(python /tmp/release_dir/utils.py /tmp/release_dir/build_info.yaml)
		GIT_TOKEN="${GIT_TOKEN}"
		FILES="../${whlff} ../build_info.json  ../build_info.yaml"
		ls -l
		git clone $GIT_RELEASE_REPO
		cd tensorflow-wheels
		source ../release.sh "${GIT_TAG}" "${TENSORFLOW_BUILD_DIR_NAME}" "${NOTES}" "${GIT_TOKEN}" "${FILES}"
	fi #end
fi # end build
if ls -l  /workspace/build.log; then
	mv /workspace/build.log /workspace/bins/ ;
fi



### enable HOST_ON_HTTP_SERVER only which deployment config and NOT with Jobs. 
if [[ $HOST_ON_HTTP_SERVER = "y" ]]
then
	echo "Starting httpserver to host the binary...\n"
    cd /workspace/
	if [[ $NB_PYTHON_VER = "2.7" ]] ; then 
		python -m SimpleHTTPServer $PORT ; 
	else python -m http.server $PORT ; 
	fi
fi

