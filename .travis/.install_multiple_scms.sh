sudo sh -c 'echo "deb http://opensource.wandisco.com/ubuntu precise svn18" >> /etc/apt/sources.list.d/subversion18.list'
sudo wget -q http://opensource.wandisco.com/wandisco-debian.gpg -O- | sudo apt-key add -
sudo apt-add-repository -y ppa:git-core/ppa
sudo apt-get update
sudo apt-get install -y git subversion cvs bzr mercurial
sudo ln -s /usr/bin/cvs /usr/bin/cvsnt
sudo add-apt-repository -y ppa:mercurial-ppa/releases
sudo apt-get update
sudo apt-get install --only-upgrade -y mercurial
