#/usr/bin/env sh

bazaar_plugins_path=`bzr --version |  awk '/bzrlib:/ {print $2}'`

cd "$bazaar_plugins_path/plugins"

sudo bzr branch lp:bzr-xmloutput

sudo mv bzr-xmloutput xmloutput

gem install 'test-unit' -v '3.2.4'

cd xmloutput

python setup.py build_ext -i
