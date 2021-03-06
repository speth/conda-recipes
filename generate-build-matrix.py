"""
This script is used to generate the build matrix portions of the
``.travis.yml`` and ``appveyor.yml`` files. The intended use is for a
maintainer of the project to edit the ``numpy_versions`` list and
``pythons`` dictionary to include the relevant versions, then run
the script to modify the two configuration files. The maintainer
then commits the changes to the files and pushes to GitHub to
trigger the CI builds.

The only requirement for this script is ruamel.yaml version
greater than 0.15.0. This can be installed from pip

    pip install ruamel.yaml

or conda-forge

    conda install -c conda-forge ruamel.yaml
"""

from ruamel.yaml import YAML, __version__ as ryvers
from itertools import product
from distutils.version import StrictVersion

if StrictVersion(ryvers) < StrictVersion('0.15.0'):
    raise ImportError('ruamel.yaml must be at least version 0.15.0')

yaml = YAML()
yaml.default_flow_style = False
yaml.preserve_quotes = True
yaml.block_seq_indent = 2
yaml.indent = 4
yaml.width = 200

numpy_versions = ['1.12', '1.13']
pythons = {
    '2.7': numpy_versions,
    '3.5': numpy_versions,
    '3.6': numpy_versions,
}

travis_env = 'BUILD_PYTHON="{python}" BUILD_ARCH="{arch}" BUILD_NPY="{numpy}"'

travis_matrix = []
for arch, python in product(['x86', 'x64'], pythons.keys()):
    for numpy in pythons[python]:
        env = travis_env.format(python=python, arch=arch, numpy=numpy)
        travis_matrix.append({'os': 'linux', 'env': env})

for arch, python in product(['x64'], pythons.keys()):
    for numpy in pythons[python]:
        env = travis_env.format(python=python, arch=arch, numpy=numpy)
        travis_matrix.append({'os': 'osx', 'env': env})

with open('.travis.yml', 'r') as travis_file:
    travis_data = yaml.load(travis_file)

travis_data['matrix']['include'] = travis_matrix

with open('.travis.yml', 'w') as travis_file:
    yaml.dump(travis_data, travis_file)

appveyor_matrix = []
for arch, python in product(['32', '64'], pythons.keys()):
    for numpy in pythons[python]:
        env = {
            'PYTHON_LOC': "C:\\Miniconda" if arch == '32' else "C:\\Miniconda-x64",
            'PYTHON_VERSION': "{}".format(python),
            'BUILD_ARCH': "{}".format(arch),
            'BUILD_NPY': "{}".format(numpy),
        }
        appveyor_matrix.append(env)

with open('appveyor.yml', 'r') as app_file:
    app_data = yaml.load(app_file)

app_data['environment']['matrix'] = appveyor_matrix

with open('appveyor.yml', 'w') as app_file:
    yaml.dump(app_data, app_file)
