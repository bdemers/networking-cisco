#!/bin/sh

# Many of neutron's repos suffer from the problem of depending on neutron,
# but it not existing on pypi. This ensures its installed into the test environment.
set -ex

ZUUL_CLONER=/usr/zuul-env/bin/zuul-cloner
TARBALL_VERSION=stable-liberty
BRANCH_VERSION=stable/liberty

mkdir -p .test-tars

if $(python -c "import neutronclient" 2> /dev/null); then
    echo "Neutronclient already installed."
elif [ -x $ZUUL_CLONER ]; then
    # Use zuul-cloner to clone openstack/neutronclient, this will ensure the Depends-On
    # references are retrieved from zuul and rebased into the repo, then installed.
    $ZUUL_CLONER --cache-dir /opt/git --workspace /tmp git://git.openstack.org openstack/python-neutronclient
    (cd /tmp/openstack/python-neutronclient && git checkout ${BRANCH_VERSION})
    pip install /tmp/openstack/python-neutronclient
else
    # Download or update neutronclient tarball and install
    ( cd .test-tars && curl -R -O http://tarballs.openstack.org/python-neutronclient/python-neutronclient-${TARBALL_VERSION}.tar.gz )
    pip install .test-tars/python-neutronclient-${TARBALL_VERSION}.tar.gz
fi

if $(python -c "import neutron" 2> /dev/null); then
    echo "Neutron already installed."
elif [ -x $ZUUL_CLONER ]; then
    # Use zuul-cloner to clone openstack/neutron, this will ensure the Depends-On
    # references are retrieved from zuul and rebased into the repo, then installed.
    $ZUUL_CLONER --cache-dir /opt/git --workspace /tmp git://git.openstack.org openstack/neutron
    (cd /tmp/openstack/neutron && git checkout ${BRANCH_VERSION})
    pip install /tmp/openstack/neutron
else
    # Download or update neutron tarball and install
    ( cd .test-tars && curl -R -O http://tarballs.openstack.org/neutron/neutron-${TARBALL_VERSION}.tar.gz )
    pip install .test-tars/neutron-${TARBALL_VERSION}.tar.gz
fi

# Install the rest of the requirements as normal
pip install -U $*

exit $?
