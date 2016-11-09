#!/bin/bash

CWD=$(pwd)
VERSION=2.0.0.rc1
RELEASE=1
SPEC1="libpydhcpserver.spec"
SPEC2="staticDHCPd.spec"
SOURCE_URL="https://github.com/flan/staticdhcpd.git"

which git > /dev/null
if [ $? -ne 0 ]; then
  echo "Aborting. Cannot continue without git."
  exit 1
fi

which rpmbuild > /dev/null
if [ $? -ne 0 ]; then
  echo "Aborting. Cannot continue without rpmbuild from the rpm-build package."
  exit 1
fi

if [ -d staticdhcpd ]; then
  echo "Updating git repository..."
  cd staticdhcpd
  git pull ${SOURCE_URL}
  cd ..
else
  echo "Cloning git repository..."
  git clone ${SOURCE_URL}
fi

if [ -d package ]; then
  rm -rf package
fi
mkdir package

echo "Creating libpydhcpserver package..."
mkdir -p package/libpydhcpserver-${VERSION}/libpydhcpserver
cp -R staticdhcpd/libpydhcpserver/libpydhcpserver/* package/libpydhcpserver-${VERSION}/libpydhcpserver
cp staticdhcpd/libpydhcpserver/setup.py package/libpydhcpserver-${VERSION}
find package/libpydhcpserver-${VERSION}/ -name '*.pyc' -exec rm -f {} \;
cd package
tar cf - libpydhcpserver-${VERSION} | gzip -9 > libpydhcpserver-${VERSION}.tar.gz
cd ..

echo "Creating staticDHCPd package..."
mkdir -p package/staticDHCPd-${VERSION}/{conf,staticdhcpdlib}
cp -R staticdhcpd/staticDHCPd/staticdhcpdlib/* package/staticDHCPd-${VERSION}/staticdhcpdlib
cp -R staticdhcpd/staticDHCPd/conf/* package/staticDHCPd-${VERSION}/conf
cp staticdhcpd/staticDHCPd/{README,setup.py,staticDHCPd} package/staticDHCPd-${VERSION}
find package/staticdhcpdlib-${VERSION} -name '*.pyc' -exec rm -f {} \;
cd package
tar cf - staticDHCPd-${VERSION} | gzip -9 > staticDHCPd-${VERSION}.tar.gz
cd ..

echo "Creating RPM build path structure..."
mkdir -p rpmbuild/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS,tmp}

echo "Copying sources..."
cp specs/*.spec rpmbuild/SPECS/
sed -i 's/~version~/'${VERSION}'/' rpmbuild/SPECS/libpydhcpserver.spec
sed -i 's/~version~/'${VERSION}'/' rpmbuild/SPECS/staticDHCPd.spec
sed -i 's/~release~/'${RELEASE}'/' rpmbuild/SPECS/libpydhcpserver.spec
sed -i 's/~release~/'${RELEASE}'/' rpmbuild/SPECS/staticDHCPd.spec
cp package/*.tar.gz rpmbuild/SOURCES

if [ -f ${CWD}/gpg-env ]; then
  echo "Building RPM with GPG signing..."
  cd ${CWD}

  source gpg-env
  if [ "${gpg_bin}" != "" ]; then
    rpmbuild --define "_topdir ${CWD}/rpmbuild" \
      --define "_signature ${signature}" \
      --define "_gpg_path ${gpg_path}" --define "_gpg_name ${gpg_name}" \
      --define "__gpg ${gpg_bin}" --sign -ba rpmbuild/SPECS/${SPEC1}
    rpmbuild --define "_topdir ${CWD}/rpmbuild" \
      --define "_signature ${signature}" \
      --define "_gpg_path ${gpg_path}" --define "_gpg_name ${gpg_name}" \
      --define "__gpg ${gpg_bin}" --sign -ba rpmbuild/SPECS/${SPEC2}
  else
    rpmbuild --define "_topdir ${CWD}/rpmbuild" \
      --define "_signature ${signature}" \
      --define "_gpg_path ${gpg_path}" --define "_gpg_name ${gpg_name}" \
      --sign --ba rpmbuild/SPECS/${SPEC1}
    rpmbuild --define "_topdir ${CWD}/rpmbuild" \
      --define "_signature ${signature}" \
      --define "_gpg_path ${gpg_path}" --define "_gpg_name ${gpg_name}" \
      --sign --ba rpmbuild/SPECS/${SPEC2}
  fi
else
  echo "Building RPM..."
  cd ${CWD}
  rpmbuild --define "_topdir ${CWD}/rpmbuild" --ba rpmbuild/SPECS/${SPEC1}
  rpmbuild --define "_topdir ${CWD}/rpmbuild" --ba rpmbuild/SPECS/${SPEC2}
fi
