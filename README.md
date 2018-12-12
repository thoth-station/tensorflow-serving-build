# Tensorflow Serving Build S2I

## About

This S2I respository has [template](https://docs.openshift.org/latest/dev_guide/templates.html) files used for building tensorflow wheel files for:
* `Centos7`

TODO:
* `Fedora27`
* `Fedora28`
* `RHEL7.5`
NOTE: for `RHEL7.5` you need a system with RHEL Subscription enabled.

##### For CPU 
The files created from these templates are available at [AICoE/tensorflow-wheels](https://github.com/AICoE/tensorflow-wheels/releases).
And the instructions to use with pipfile are given here [AICoE's TensorFlow Artifacts](https://index-aicoe.a3c1.starter-us-west-1.openshiftapps.com/).

##### For GPU: TODO
GPU is not yet supported.




## Usage

```
PYTH_VERSION=3.6
GIT_TOKEN=
```

```
oc new-app --template=tensorflow-serving-build-image  \
--param=APPLICATION_NAME=tf-serving-centos7-build-image-${PYTH_VERSION//.} \
--param=S2I_IMAGE=openshift/base-centos7   \
--param=DOCKER_FILE_PATH=Dockerfile.centos7 \
--param=NB_PYTHON_VER=$PYTH_VERSION --param=VERSION=1
```

```
oc new-app --template=tensorflow-serving-build-job  \
--param=APPLICATION_NAME=tf-serving-centos7-build-job-${PYTH_VERSION//.} \
--param=BUILDER_IMAGESTREAM=tf-serving-centos7-build-image-${PYTH_VERSION//.}:1  \
--param=NB_PYTHON_VER=$PYTH_VERSION     --param=GIT_TOKEN=$GIT_TOKEN \
--param=BAZEL_VERSION=0.15.0
```