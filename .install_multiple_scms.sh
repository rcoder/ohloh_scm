sudo apt-get install -y cvs
sudo ln -s /usr/bin/cvs /usr/bin/cvsnt
sudo apt-get install -y bzr
sudo apt-get install -y mercurial
sudo sh -c 'echo "deb http://opensource.wandisco.com/ubuntu precise svn18" >> /etc/apt/sources.list.d/subversion18.list'
sudo wget -q http://opensource.wandisco.com/wandisco-debian.gpg -O- | sudo apt-key add -
sudo apt-get update
sudo apt-get install -y subversion
