#!/bin/bash

cp -r src deb/opt/vds-games/spheres/
cp -r data deb/opt/vds-games/spheres/
dpkg -b deb spheres-2.0.0.deb
