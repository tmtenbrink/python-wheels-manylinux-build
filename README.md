# Python wheels manylinux build - GitHub Action


Build manylinux wheels for a (Cython) Python package.

This action uses the [manylinux](https://github.com/pypa/manylinux) containers to
build manylinux wheels for a (Cython) Python package. The wheels are placed in a
new directory `<package-path>/dist` and can be uploaded to PyPI in the next step of your
workflow.

## Usage

### Example
Minimal:

```yaml
uses: RalfG/python-wheels-manylinux-build@v0.3.4
with:
  python-versions: 'cp36-cp36m cp37-cp37m'
```

Using all arguments:

```yaml
uses: RalfG/python-wheels-manylinux-build@v0.3.4-manylinux2010_x86_64
with:
  python-versions: 'cp36-cp36m cp37-cp37m'
  build-requirements: 'cython numpy'
  system-packages: 'lrzip-devel zlib-devel'
  pre-build-command: 'sh pre-build-script.sh'
  package-path: 'my_project'
  pip-wheel-args: '-w ./dist --no-deps'
```

See
[full_workflow_example.yml](https://github.com/RalfG/python-wheels-manylinux-build/blob/master/full_workflow_example.yml)
for a complete example that includes linting and uploading to PyPI.


### Inputs

| name | description | required | default | example(s) |
| - | - | - | - | - |
| `python-versions` | Python version tags for which to build (PEP 425 tags) wheels, as described in the [manylinux image documentation](https://github.com/pypa/manylinux), space-separated | required | `'cp36-cp36m cp37-cp37m cp38-cp38 cp39-cp39'` | `'cp36-cp36m cp37-cp37m'` |
| `build-requirements` | Python (pip) packages required at build time, space-separated | optional | `''` | `'cython'` or `'cython==0.29.14'` |
| `system-packages` | System (yum) packages required at build time, space-separated | optional | `''` | `'lrzip-devel zlib-devel'` |
| `pre-build-command` | Command to run before build, e.g. the execution of a script to perform additional build-environment setup | optional | `''` | `'sh pre-build-script.sh'` |
| `package-path` | Path to python package to build (e.g. where `setup.py` file is located), relative to repository root | optional | `''` | `'my_project'` |
| `pip-wheel-args` | Extra extra arguments to pass to the `pip wheel` command (see [pip documentation](https://pip.pypa.io/en/stable/reference/pip_wheel/)), passed paths are relative to `package-path` | optional | `'-w ./dist --no-deps'` | `'-w ./wheelhouse --no-deps --pre'` |

### Output
The action creates wheels, by default in the `<package-path>/dist` directory. The output
path can be modified in the `pip-wheel-args` option with the `-w` argument. Be sure to
upload only the `*-manylinux*.whl` wheels, as the non-audited (e.g. `linux_x86_64`)
wheels are not accepted by PyPI.

### Using a different manylinux container
The `manylinux2010_x86_64` container is used by default. To use another manylinux
container, append `-<container-name>` to the reference. For example:
`RalfG/python-wheels-manylinux-build@v0.3.4-manylinux2014_aarch64` instead of
`RalfG/python-wheels-manylinux-build@v0.3.4`.

## Contributing
Bugs, questions or suggestions? Feel free to post an issue in the
[issue tracker](https://github.com/RalfG/python-wheels-manylinux-build/issues)
or to make a pull request!
