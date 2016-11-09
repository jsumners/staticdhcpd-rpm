%define name staticDHCPd
%define version ~version~
%define unmangled_version ~version~
%define release ~release~

Summary: Highly customisable, static-lease-focused DHCP server
Name: %{name}
Version: %{version}
Release: %{release}
Source0: %{name}-%{unmangled_version}.tar.gz
License: GPLv3
Group: System Environment/Daemons
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-buildroot
Prefix: %{_prefix}
BuildArch: noarch
Vendor: Neil Tallim <flan@uguu.ca>
Requires: libpydhcpserver >= 2.0.0
Url: http://uguu.ca/

%description
staticDHCPd is an extensively customisable, high-performance, RFC-spec-compliant DHCP server, well-suited to labs, LAN parties, home and small-office networks, and specialised networks of vast size.

It supports all major DHCP extension RFCs and features a rich, plugin-oriented web-interface, has a variety of modules, ranging from statistics-management to notification services to dynamic address-provisioning and network-auto-discovery.

Multiple backend databases are supported, from INI files to RDBMS SQL servers, with examples of how to write and integrate your own, such as a REST-JSON endpoint, simple enough to complete in minutes.

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
