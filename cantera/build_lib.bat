CALL "%ROOT%\Scripts\activate.bat" "%PREFIX%""
CALL scons install prefix=%PREFIX% python3_package='none' python2_package='none' python_package='none'
