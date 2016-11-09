%define name libpydhcpserver
%define version ~version~
%define unmangled_version ~version~
%define release ~release~

Summary: Pure-Python, spec-compliant DHCP-packet-processing and networking library
Name: %{name}
Version: %{version}
Release: %{release}
Source0: %{name}-%{unmangled_version}.tar.gz
License: GPLv3
Group: Development/Libraries
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-buildroot
Prefix: %{_prefix}
BuildArch: noarch
Vendor: Neil Tallim <flan@uguu.ca>
Url: http://uguu.ca/

%description
libpydhcpserver provides the implementation for staticDHCPd's DHCP-processing needs, but has a stable API and may be used by other applications that have a reason to work with DHCP packets and perform server-oriented functions.

%prep
%setup -n %{name}-%{unmangled_version}

%build
python setup.py build

%install
python setup.py install -O1 --root=$RPM_BUILD_ROOT --record=INSTALLED_FILES

%clean
rm -rf $RPM_BUILD_ROOT

%files -f INSTALLED_FILES
%defattr(-,root,root)
