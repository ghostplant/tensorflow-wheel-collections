#!/bin/sh -e

docker build . --network host -t tensorflow -f "${@:-Dockerfile.tf18-py35-cuda8-cudnn7104-ubuntu}"
docker run -it --rm -v `pwd`:/mnt tensorflow bash -c 'cp ../tensorflow_pkg/*.whl /mnt'

echo "You can install the wheel package via:"
echo
echo "pip3 install" ./*.whl
