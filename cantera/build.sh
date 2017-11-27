set +x

scons clean

# Use the compilers from the Conda environment
echo "CC = '$CC'" >> cantera.conf
echo "CXX = '$CXX'" >> cantera.conf

# We want neither the MATLAB interface nor the Fortran interface
echo "matlab_toolbox='n'" >> cantera.conf
echo "f90_interface='n'" >> cantera.conf
echo "system_sundials='n'" >> cantera.conf
echo "debug='n'" >> cantera.conf
echo "boost_inc_dir = '$PREFIX/include'" >> cantera.conf

if [[ "$ARCH" == "32" ]]; then
  echo "cc_flags='-m32'" >> cantera.conf
  echo "no_debug_linker_flags='-m32'" >> cantera.conf
fi

if [[ "$OSX_ARCH" == "" ]]; then
    echo "blas_lapack_libs = 'mkl_rt,dl'" >> cantera.conf
    echo "blas_lapack_dir = '$PREFIX/lib'" >> cantera.conf
fi

set -xe

scons build -j$((CPU_COUNT/2)) python2_package='none' python3_package='none' python_package='none'

echo "\n\n****************************"
echo "BUILD COMPLETED SUCCESSFULLY"
echo "****************************\n\n"

scons test

set +xe
