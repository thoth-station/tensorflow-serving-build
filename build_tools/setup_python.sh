#!/bin/bash -e
# Setup Python after devtoolset gcc
# ----------------------------

echo "==============================="
echo "Setup Python after devtoolset gcc..."
major=$(cat /etc/centos-release | tr -dc '0-9.'|cut -d \. -f1)
minor=$(cat /etc/centos-release | tr -dc '0-9.'|cut -d \. -f2)
OSVER=$(cat /etc/redhat-release | cut -d' ' -f1 |  awk '{print tolower($0)}')
echo "PYTHON_VERSION = "$PYTHON_VERSION
echo "OSVER = "$OSVER
OS_VERSION="$OSVER$major"
echo "OS_VERSION = "$OS_VERSION

if [ "$PYTHON_VERSION" = "2.7" ] ; then 
	if [[ "$OS_VERSION" = "rhel6" ]] || [[ "$OS_VERSION" = "centos6" ]] ; then
        echo "Found environment $OS_VERSION-$PYTHON_VERSION"  &&
        export MANPATH=/opt/rh/python27/root/usr/share/man:$MANPATH &&
        export PATH=/opt/rh/python27/root/usr/bin${PATH:+:${PATH}} &&
        export XDG_DATA_DIRS="/opt/rh/python27/root/usr/share:${XDG_DATA_DIRS:-/usr/local/share:/usr/share}" &&
        export PKG_CONFIG_PATH=/opt/rh/python27/root/usr/lib64/pkgconfig/${PKG_CONFIG_PATH:+:${PKG_CONFIG_PATH}} &&
        export LD_LIBRARY_PATH=/opt/rh/python27/root/usr/lib64/:/opt/rh/rpython27/root/usr/include:/opt/rh/python27/root/usr/include/python2.7/:/usr/local/lib${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}} &&
        export CPATH=/opt/rh/python27/root/usr/include:/opt/rh/python27/root/usr/include/python2.7:$CPATH &&
        export LIBRARY_PATH=/opt/rh/python27/root/usr/include:/opt/rh/python27/root/usr/include/python2.7:$LIBRARY_PATH &&
        export PYTHON_INCLUDE_PATH=/opt/rh/python27/root/usr/include/python2.7 &&
        export PYTHON_LIB_PATH=/opt/rh/python27/root/usr/lib/python2.7/site-packages &&
        rm -fr /usr/bin/python &&
        ln -s /opt/rh/python27/root/usr/bin/python2.7 /usr/bin/python &&
        python -V &&
        which python &&
        echo "PYTHON_H="`rpm -ql python27-python-devel | grep Python.h` &&
        echo "PYTHON_H="`rpm -ql python-devel | grep Python.h` ;
	fi
fi
if [ "$PYTHON_VERSION" = "3.6" ] ; then 
	if [[ "$OS_VERSION" = "rhel6" ]] || [[ "$OS_VERSION" = "centos6" ]] ; then
		echo "Found environment $OS_VERSION-$PYTHON_VERSION"  &&
		export MANPATH=/opt/rh/rh-python36/root/usr/share/man:$MANPATH &&
		export PATH=/opt/rh/rh-python36/root/usr/bin${PATH:+:${PATH}} &&
		export XDG_DATA_DIRS="/opt/rh/rh-python36/root/usr/share:${XDG_DATA_DIRS:-/usr/local/share:/usr/share}" &&
		export PKG_CONFIG_PATH=/opt/rh/rh-python36/root/usr/lib64/pkgconfig${PKG_CONFIG_PATH:+:${PKG_CONFIG_PATH}} &&
		export LD_LIBRARY_PATH=/opt/rh/rh-python36/root/usr/lib64/:/opt/rh/rh-python36/root/usr/include:/opt/rh/rh-python36/root/usr/include/python3.6m/:/usr/local/lib${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}} &&
		export CPATH=/opt/rh/rh-python36/root/usr/include:/opt/rh/rh-python36/root/usr/include/python3.6m:$CPATH &&
		export LIBRARY_PATH=/opt/rh/rh-python36/root/usr/include:/opt/rh/rh-python36/root/usr/include/python3.6m:$LIBRARY_PATH &&
		export PYTHON_INCLUDE_PATH=/opt/rh/rh-python36/root/usr/include/python3.6m &&
		export PYTHON_LIB_PATH=/opt/rh/rh-python36/root/usr/lib/python3.6/site-packages &&
		rm -fr /usr/bin/python && 
		ln -s /opt/rh/rh-python36/root/usr/bin/python3.6 /usr/bin/python &&
		python -V &&
		which python &&
		echo "PYTHON_H="`rpm -ql rh-python36-python-devel | grep Python.h` ;
	fi
fi

echo "LD_LIBRARY_PATH ="$LD_LIBRARY_PATH;
echo "CPATH ="$CPATH;
echo "PATH ="$PATH; 
echo "LIBRARY_PATH ="$LIBRARY_PATH;
echo "PYTHON_INCLUDE_PATH ="$PYTHON_INCLUDE_PATH;
echo "PYTHON_LIB_PATH ="$PYTHON_LIB_PATH;
echo "==============================="
