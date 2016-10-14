@ECHO off

IF %ARCH% EQU 64 (
	CALL "%VS140COMNTOOLS%"\..\..\VC\bin\amd64\vcvars64.bat
) ELSE (
	CALL "%VS140COMNTOOLS%"\..\..\VC\bin\vcvars32.bat
)

:: Remove the old builder environment, if it exists
CALL conda env remove -yq -p %PREFIX:~0,-6%cantera-builder

:: Create a conda environment to build Cantera. It has to be Python 2, for
:: Scons compatibility. When SCons is available for Python 3, these machinations
:: can be removed
:: Important: As of 24-Dec-2015, the most recent version of SCons available in
:: the conda repositories is 2.3.0. Unfortunately, using VS 2015 requires SCons
:: 2.4.1. This version is available from the cantera channel on anaconda.org, so we add
:: -c cantera/label/builddeps to pick up SCons from that channel.
CALL conda create -yq -p %PREFIX:~0,-6%cantera-builder -c cantera/label/builddeps python=2 cython numpy pywin32 scons 3to2

:: The major version of the Python that will be used for the installer, not the
:: version used for building
SET PY_MAJ_VER=%PY_VER:~0,1%

:: Set the number of CPUs to use in building
SET /A CPU_USE=%CPU_COUNT% / 2
IF "%CPU_USE%" EQU "0" SET CPU_USE=1

:: Using the activate script doesn't work in PowerShell, and in cmd.exe it gives an
:: "Input line too long" error, so set the PATH manually.
SET OLD_PATH=%PATH%
SET PATH=%PREFIX:~0,-6%cantera-builder\bin;%PREFIX:~0,-6%cantera-builder\Scripts;%PATH%

:: Have to use CALL to prevent the script from exiting after calling SCons
CALL scons clean

:: Put important settings into cantera.conf for the build. Use VS 2015 to
:: compile the interface.
ECHO msvc_version='14.0' >> cantera.conf
ECHO env_vars='all' >> cantera.conf
ECHO matlab_toolbox='n' >> cantera.conf
ECHO debug='n' >> cantera.conf
ECHO f90_interface='n' >> cantera.conf
ECHO system_sundials='n' >> cantera.conf

:: Select which version of the interface should be built
IF "%PY_MAJ_VER%" EQU "2" GOTO PYTHON2
IF "%PY_MAJ_VER%" EQU "3" GOTO PYTHON3

:PYTHON2
ECHO Building for Python 2
CALL scons build -j%CPU_USE% python3_package=n python_cmd="%PYTHON%" python_package=full
GOTO BUILD_SUCCESS

:PYTHON3
ECHO Building for Python 3
CALL scons build -j%CPU_USE% python3_package=y python3_cmd="%PYTHON%" python_package=none
GOTO BUILD_SUCCESS

:BUILD_SUCCESS
:: Remove the builder environment and reset the path
CALL conda env remove -yq -p %PREFIX:~0,-6%cantera-builder
SET PATH=%OLD_PATH%

:: Change to the Python interface directory and run the installer using the
:: proper version of Python.
cd interfaces/cython
"%PYTHON%" setup%PY_MAJ_VER%.py build --build-lib=../../build/python%PY_MAJ_VER% install
