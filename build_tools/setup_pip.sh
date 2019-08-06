#!/bin/bash -e
# Setup pip
# Need to delete pip
# ----------------------------

echo "==============================="
echo "Setup pip after devtoolset gcc..."
major=$(cat /etc/centos-release | tr -dc '0-9.'|cut -d \. -f1)
minor=$(cat /etc/centos-release | tr -dc '0-9.'|cut -d \. -f2)
OSVER=$(cat /etc/redhat-release | cut -d' ' -f1 |  awk '{print tolower($0)}')
echo "PYTHON_VERSION = "$PYTHON_VERSION
echo "OSVER = "$OSVER
OS_VERSION="$OSVER$major"
echo "OS_VERSION = "$OS_VERSION


if [ "$PYTHON_VERSION" = "3.6" ] ; then 
	if [[ "$OS_VERSION" = "rhel6" ]] || [[ "$OS_VERSION" = "centos6" ]] ; then
		echo "Found environment $OS_VERSION-$PYTHON_VERSION"  &&
		rm -fr /usr/bin/pip &&
		ln -s /opt/rh/rh-python36/root/usr/bin/pip /usr/bin/pip &&
		pip -V;
	fi
fi
if [ "$PYTHON_VERSION" = "2.7" ] ; then 
	if [[ "$OS_VERSION" = "rhel6" ]] || [[ "$OS_VERSION" = "centos6" ]] ; then
		echo "Found environment $OS_VERSION-$PYTHON_VERSION"  &&
		rm -fr /usr/bin/pip &&
		ln -s /opt/rh/python27/root/usr/bin/pip /usr/bin/pip &&
		pip -V;
	fi
fi

echo "==============================="
