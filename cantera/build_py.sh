source activate $PREFIX

PY_MAJ_VER=${PY_VER:0:1}

if [ "${PY_MAJ_VER}" == "2" ]; then
    scons build python3_package='none' python2_package='y' python_package='none' prefix=''
else
    scons build python3_package='y' python2_package='none' python_package='none' prefix=''
fi

cd interfaces/cython
$PYTHON setup${PY_MAJ_VER}.py build --build-lib=../../build/python${PY_MAJ_VER} install
