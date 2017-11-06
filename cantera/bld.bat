@ECHO off

IF %ARCH% EQU 64 (
	CALL "%VS140COMNTOOLS%"\..\..\VC\bin\amd64\vcvars64.bat
) ELSE (
	CALL "%VS140COMNTOOLS%"\..\..\VC\bin\vcvars32.bat
)

:: Set the number of CPUs to use in building
SET /A CPU_USE=%CPU_COUNT% / 2
IF %CPU_USE% EQU 0 SET CPU_USE=1

:: Have to use CALL to prevent the script from exiting after calling SCons
CALL scons clean

:: Put important settings into cantera.conf for the build. Use VS 2015 to
:: compile the interface.
ECHO msvc_version='14.0' >> cantera.conf
ECHO matlab_toolbox='n' >> cantera.conf
ECHO debug='n' >> cantera.conf
ECHO f90_interface='n' >> cantera.conf
ECHO system_sundials='n' >> cantera.conf

SET "ESC_PREFIX=%PREFIX:\=/%"
ECHO boost_inc_dir="%ESC_PREFIX%/Library/include" >> cantera.conf

:: Select which version of the interface should be built
IF "%PY3K%" EQU "0" GOTO PYTHON2
IF "%PY3K%" EQU "1" GOTO PYTHON3

:PYTHON2
ECHO Building for Python 2
CALL scons build -j%CPU_USE% python3_package=n python_cmd="%PYTHON%" python_package=full
GOTO BUILD_SUCCESS

:PYTHON3
ECHO Building for Python 3
CALL scons build -j%CPU_USE% python3_package=y python3_cmd="%PYTHON%" python_package=none
GOTO BUILD_SUCCESS

:BUILD_SUCCESS
:: Change to the Python interface directory and run the installer
cd interfaces/cython
SET PY_MAJ_VER=%PY_VER:~0,1%
"%PYTHON%" setup%PY_MAJ_VER%.py build --build-lib=../../build/python%PY_MAJ_VER% install
