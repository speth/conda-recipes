#!/bin/bash

scons clean

set +x

# We want neither the MATLAB interface nor the Fortran interface
echo "matlab_toolbox='n'" >> cantera.conf
echo "f90_interface='n'" >> cantera.conf
echo "system_sundials='n'" >> cantera.conf
echo "debug='n'" >> cantera.conf
echo "boost_inc_dir = '$PREFIX/include'" >> cantera.conf
echo "blas_lapack_libs = 'mkl_rt,dl'" >> cantera.conf
echo "blas_lapack_dir = '$PREFIX/lib'" >> cantera.conf

if [[ "$ARCH" == "32" ]]; then
  echo "cc_flags='-m32'" >> cantera.conf
  echo "no_debug_linker_flags='-m32'" >> cantera.conf
fi

set -x

# Run SCons to build the proper Python interface
if [ "${PY3K}" == "0" ]; then
    scons build -j$((CPU_COUNT/2)) python3_package='n' python_cmd=$PYTHON python_package='full'
else
    scons build -j$((CPU_COUNT/2)) python3_package='y' python3_cmd=$PYTHON python_package='none'
fi

# Change to the Python interface directory and run the installer using the
# proper version of Python.
cd interfaces/cython
$PYTHON setup${PY_MAJ_VER}.py build --build-lib=../../build/python${PY_MAJ_VER} install
