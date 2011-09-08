from bzrlib.builtins import cmd_cat
from bzrlib.builtins import cmd_log
from bzrlib.revisionspec import RevisionSpec
import StringIO
import os

# Get contents of a file for specific revision.
def bzr_cat(repository_url, filename, revision):
  os.chdir(repository_url)
  spec = RevisionSpec.from_string(revision)
  output = StringIO.StringIO()
  cmd = cmd_cat()
  cmd.outf = output
  cmd.run_direct(filename=filename, revision=[spec], name_from_revision=True)
  return output.getvalue()

# Get log for a specific revision.
def bzr_log(repository_url, change):
  os.chdir(repository_url)
  change_rev = RevisionSpec.from_string(change)
  output = StringIO.StringIO()
  cmd = cmd_log()
  cmd.outf = output
  cmd.run_direct(file_list=None, show_ids=True, change=[change_rev], limit=1)
  val = output.getvalue()
  if isinstance(val, unicode):
    return val.encode('utf-8')
  else:
    return val

if __name__ == "__main__":
  #print bzr_cat('/home/amujumdar/bzrlib_examples/bzr.2.1', 'bzrlib/transport/local.py', 'revid:pqm@pqm.ubuntu.com-20090624225712-x20543g8bpv6e9ny')
  #print bzr_log('/home/amujumdar/bzrlib_examples/bzr.2.1', 'bzrlib/transport/local.py', show_ids=True, change='revid:pqm@pqm.ubuntu.com-20090624225712-x20543g8bpv6e9ny', limit=1)
  #print bzr_log('/home/amujumdar/app/ohloh_scm/test/repositories/bzr', change='revid:obnox@samba.org-20090204004942-73rnw0izen42f154')
  print bzr_log('/home/amujumdar/app/ohloh_scm/test/repositories/bzr', change='1')

