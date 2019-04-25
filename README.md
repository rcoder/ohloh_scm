[![Ohloh SCM on OpenHub](https://www.openhub.net/p/ohloh_scm/widgets/project_partner_badge.gif)](https://www.openhub.net/p/ohloh_scm) [![Build Status](https://travis-ci.org/blackducksoftware/ohloh_scm.svg?branch=master)](https://travis-ci.org/blackducksoftware/ohloh_scm)

# Ohloh SCM

The OpenHub source control management library

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License Version 2 as
published by the Free Software Foundation.

Ohcount is specifically licensed under GPL v2.0, and no later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

## Overview

Ohloh SCM is an abstraction layer for source control management systems,
allowing an application to interoperate with various SCMs using a
single interface.

It was originally developed at OpenHub, and is used to generate
the reports at www.openhub.net.

## System Requirements

One could use the bundled Dockerfile to test Ohloh SCM in a container and skip
this section entirely. See [docker](https://github.com/blackducksoftware/ohloh_scm/#using-docker).

Ohloh SCM is developed on Mac OS X 10.13.6(High Sierra) and Ubuntu 18.04 LTS.
Other Linux environments should also work, but your mileage may vary.

Ohloh SCM does not support Windows.

Ohloh SCM targets Ruby 2.3 and Rake 12.3.

Ohloh SCM interfaces with CVSNT, Subversion, Git and Mercurial through the
shell. In order to pass the unit tests, all three systems must be installed
and on your path. Ohloh is currently tested on the following versions:

cvsnt 2.5.03
svn 1.9.7
git 2.17.1
hg 4.5.3
bzr 2.8.0

If you are using CVS instead of CVSNT, you can potentially try creating
a shell alias or symlink mapping 'cvsnt' to 'cvs'.

Ohloh SCM uses [posix-spawn](https://github.com/rtomayko/posix-spawn) to
execute commands so ensure *posix-spawn* gem is installed

``gem install posix-spawn``


## Usage with Bundler

```
gem 'ohloh_scm', git: 'https://github.com/blackducksw/ohloh_scm/', require: 'scm'
gem 'posix-spawn'
```
## Running

Ensure that cvsnt, svn, svnadmin, svnsync, git, and hg are all on your path. You'll also need to ensure that you have the xmloutput plugin installed for bazaar.

### Installing The XmlOutput Plugin
    $ cd ~
    $ mkdir .bazaar
    $ cd .bazaar
    $ mkdir plugins
    $ cd plugins

Now checkout the latest version of the xmloutput plugin (0.8.8 as of 11/21/2011).

    $ bzr branch lp:~amujumdar/bzr-xmloutput/emit_authors

The default checkout directory is poorly named and bazaar will complain about this unless it is renamed.

    $ mv emit_authors xmloutput

Now you just need to install the xmloutput plugin

    $ cd xmloutput
    $ python setup.py build_ext -i

Verify that the plugin was installed correctly

    $ bzr plugins

You should see some text like "xmloutput 0.8.8"

Then you can run the unit tests:

    $ rake

You can load the library into your own Ruby application by requiring lib/ohloh_scm.rb.

## Using Docker

One may use Docker to run Ohloh SCM and test changes.

```sh
$ git clone https://github.com/blackducksoftware/ohloh_scm
$ cd ohloh_scm

# To run all tests, we need to start the ssh server and set UTF-8 locale for encoding tests.
$ cmd='/etc/init.d/ssh start; LANG=en_US.UTF-8 rake test 2> /dev/null'
$ docker run -P -w /home/app/ohloh_scm -v $(pwd):/home/app/ohloh_scm -ti notalex/ohloh_scm:ubuntu18 /bin/sh -c "$cmd"
# This mounts the current folder into the docker container;
#   hence any edits made in ohloh_scm on the host machine would reflect in the container.

# One may also edit the Dockerfile & build the image locally for other distros.
$ docker build -t ohloh_scm:custom .
$ docker run -ti ohloh_scm:custom -v $(pwd):/home/app/ohloh_scm /bin/bash
```

# Functionality

For each tracked repository, OpenHub uses the SCM library to maintain a private
local mirror. The SCM library hides the differences between source control
systems. The SCM library manages all required updates to a mirror, and reports
the contents of the mirror in standardized ways.

Each mirror is assigned a dedicated directory, and the SCM library adapter may
store any content it desires in that directory. Usually, it's a direct clone of
the original repository, but in the case of CVS or some Subversion servers, it
is a conversion of the original repository to Git.

The main OpenHub application orchestrates the scheduling of all updates and
backups. On demand, the SCM library adapter then performs the following basic
tasks on the local mirror:

1. Pull changes -- From a remote repository URL, pull any changes to the local
mirror. This step may involve conversion from one system to another.
2. Push changes -- From the local mirror, push any changes to another OpenHub
server. This is required to create backup copies and perform load balancing on
the OpenHub cluster, and typically occurs over ssh.
3. Commit log -- Given the last known commit, report the list of new commits,
if any, including their diffs.
4. Cat file or parent -- Given a commit, return either the contents of a
single file, or that file's previous contents.
5. Export tree -- Given a commit, export the entire contents of the source tree
to a specified temp directory.

The adapter must also implement validation routines used to filter user inputs
and confirm the presence of the remote server.

# Contact OpenHub

You can reach OpenHub via email at:
[info@openhub.net](mailto:info@openhub.net)
