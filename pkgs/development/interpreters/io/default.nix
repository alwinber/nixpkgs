{ lib, stdenv, fetchFromGitHub, cmake, zlib, sqlite, gmp, libffi, cairo,
  ncurses, freetype, libGLU, libGL, libpng, libtiff, libjpeg, readline, libsndfile,
  libxml2, freeglut, libsamplerate, pcre, libevent, libedit, yajl,
  python3, openssl, glfw, pkg-config, libpthreadstubs, libXdmcp, libmemcached
}:

stdenv.mkDerivation {
  name = "io-2017.09.06";
  src = fetchFromGitHub {
    owner = "stevedekorte";
    repo = "io";
    rev = "b8a18fc199758ed09cd2f199a9bc821f6821072a";
    sha256 = "07rg1zrz6i6ghp11cm14w7bbaaa1s8sb0y5i7gr2sds0ijlpq223";
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    zlib sqlite gmp libffi cairo ncurses freetype
    libGLU libGL libpng libtiff libjpeg readline libsndfile libxml2
    freeglut libsamplerate pcre libevent libedit yajl
    pkg-config glfw openssl libpthreadstubs libXdmcp
    libmemcached python3
  ];

  preConfigure = ''
    # The Addon generation (AsyncRequest and a others checked) seems to have
    # trouble with building on Virtual machines. Disabling them until it
    # can be fully investigated.
    sed -ie \
          "s/add_subdirectory(addons)/#add_subdirectory(addons)/g" \
          CMakeLists.txt
    # glibc 2.32 removed sysctl.h
    sed -i '/sys\/sysctl.h/g' libs/iovm/source/IoSystem.c
    # Bind Libs STATIC to avoid a segfault when relinking
    sed -i 's/basekit SHARED/basekit STATIC/' libs/basekit/CMakeLists.txt
    sed -i 's/garbagecollector SHARED/garbagecollector STATIC/' libs/garbagecollector/CMakeLists.txt
    sed -i 's/coroutine SHARED/coroutine STATIC/' libs/coroutine/CMakeLists.txt

  '';

  # for gcc5; c11 inline semantics breaks the build
  NIX_CFLAGS_COMPILE = "-fgnu89-inline";

  meta = with lib; {
    description = "Io programming language";
    homepage = "http://iolanguage.org/";
    license = licenses.bsd3;

    maintainers = with maintainers; [
      raskin
      maggesi
      vrthra
    ];
    platforms = [ "x86_64-linux" ];
  };
}
