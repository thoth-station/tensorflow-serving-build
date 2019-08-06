#!/bin/bash -e
# Setup devtoolset gcc
# ----------------------------

echo "==============================="
echo "Setup devtoolset gcc..."
major=$(cat /etc/centos-release | tr -dc '0-9.'|cut -d \. -f1)
minor=$(cat /etc/centos-release | tr -dc '0-9.'|cut -d \. -f2)
OSVER=$(cat /etc/redhat-release | cut -d' ' -f1 |  awk '{print tolower($0)}')
echo "OSVER = "$OSVER
export OS_VERSION="$OSVER$major"
echo "OS_VERSION = "$OS_VERSION

# todo find current Python version
if [ "$DEV_TOOLSET_VERSION" = "7" ] ; then 
	if [[ "$OS_VERSION" = "rhel6" ]] || [[ "$OS_VERSION" = "centos6" ]] ; then
		echo "Found environment $OS_VERSION-$PYTHON_VERSION"  &&
		export MANPATH=/opt/rh/devtoolset-7/root/usr/share/man:$MANPATH &&
		export INFOPATH=/opt/rh/devtoolset-7/root/usr/share/info:$INFOPATH &&
		export PCP_DIR=/opt/rh/devtoolset-7/root:$INFOPATH &&
		export LD_LIBRARY_PATH=/opt/rh/devtoolset-7/root/usr/lib64:/opt/rh/devtoolset-7/root/usr/lib:/opt/rh/devtoolset-7/root/usr/lib64/dyninst:/opt/rh/devtoolset-7/root/usr/lib/dyninst:/opt/rh/devtoolset-7/root/usr/lib64:/opt/rh/devtoolset-7/root/usr/lib:$LD_LIBRARY_PATH &&
		export PATH=/opt/rh/devtoolset-7/root/usr/bin:$PATH &&
		export PYTHONPATH=/opt/rh/devtoolset-7/root/usr/lib64/python2.6/site-packages:/opt/rh/devtoolset-7/root/usr/lib/python2.6/site-packages:$PYTHONPATH &&
		export PERL5LIB=/opt/rh/devtoolset-7/root//usr/lib64/perl5/vendor_perl:/opt/rh/devtoolset-7/root/usr/lib/perl5:/opt/rh/devtoolset-7/root//usr/share/perl5/vendor_perl &&
		rm -fr /usr/bin/gcc &&
		rm -fr /usr/bin/g++ &&
		rm -fr /usr/bin/ld &&
		ln -s /opt/rh/devtoolset-$DEV_TOOLSET_VERSION/root/usr/bin/gcc /usr/bin/gcc &&
		ln -s /opt/rh/devtoolset-$DEV_TOOLSET_VERSION/root/usr/bin/g++ /usr/bin/g++ &&
		ln -s /opt/rh/devtoolset-$DEV_TOOLSET_VERSION/root/usr/bin/ld /usr/bin/ld;
	fi
fi
if [ "$DEV_TOOLSET_VERSION" = "8" ] ; then 
	if [[ "$OS_VERSION" = "rhel6" ]] || [[ "$OS_VERSION" = "centos6" ]] ; then
		echo "Found environment $OS_VERSION-$PYTHON_VERSION"  &&
		export MANPATH=/opt/rh/devtoolset-8/root/usr/share/man:$MANPATH &&
		export INFOPATH=/opt/rh/devtoolset-8/root/usr/share/info:$INFOPATH &&
		export PCP_DIR=/opt/rh/devtoolset-8/root:$INFOPATH &&
		export LD_LIBRARY_PATH=/opt/rh/devtoolset-8/root/usr/lib64:/opt/rh/devtoolset-8/root/usr/lib:/opt/rh/devtoolset-8/root/usr/lib64/dyninst:/opt/rh/devtoolset-8/root/usr/lib/dyninst:/opt/rh/devtoolset-8/root/usr/lib64:/opt/rh/devtoolset-8/root/usr/lib:$LD_LIBRARY_PATH &&
		export PATH=/opt/rh/devtoolset-8/root/usr/bin:$PATH &&
		export PYTHONPATH=/opt/rh/devtoolset-8/root/usr/lib64/python2.6/site-packages:/opt/rh/devtoolset-8/root/usr/lib/python2.6/site-packages:$PYTHONPATH &&
		export PERL5LIB=/opt/rh/devtoolset-8/root//usr/lib64/perl5/vendor_perl:/opt/rh/devtoolset-8/root/usr/lib/perl5:/opt/rh/devtoolset-8/root//usr/share/perl5/vendor_perl &&
		rm -fr /usr/bin/gcc &&
		rm -fr /usr/bin/g++ &&
		rm -fr /usr/bin/ld &&
		ln -s /opt/rh/devtoolset-$DEV_TOOLSET_VERSION/root/usr/bin/gcc /usr/bin/gcc &&
		ln -s /opt/rh/devtoolset-$DEV_TOOLSET_VERSION/root/usr/bin/g++ /usr/bin/g++ &&
		ln -s /opt/rh/devtoolset-$DEV_TOOLSET_VERSION/root/usr/bin/ld /usr/bin/ld;
	fi
fi

echo "LD_LIBRARY_PATH ="$LD_LIBRARY_PATH;
echo "MANPATH ="$MANPATH;
echo "INFOPATH ="$INFOPATH; 
echo "PCP_DIR ="$PCP_DIR; 
echo "PYTHONPATH ="$PYTHONPATH;
echo "PERL5LIB ="$PERL5LIB;
echo "PATH ="$PATH;
echo "==============================="
