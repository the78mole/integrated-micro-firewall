# Fix: upstream repo renamed default branch from 'master' to 'main'.
# The original SRCREV (v0.23 tag) is no longer reachable via 'master'.
SRC_URI = "git://github.com/analogdevicesinc/libiio.git;protocol=https;branch=main \
           file://0001-CMake-Move-include-CheckCSourceCompiles-before-its-m.patch \
          "
