CALL "%ROOT%\Scripts\activate.bat" "%PREFIX%""

SET PY_MAJ_VER=%PY_VER:~0,1%

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
:: Change to the Python interface directory and run the installer using the
:: proper version of Python.
cd interfaces/cython
"%PYTHON%" setup%PY_MAJ_VER%.py build --build-lib=../../build/python%PY_MAJ_VER% install
