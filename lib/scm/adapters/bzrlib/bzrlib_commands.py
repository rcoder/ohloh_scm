from bzrlib.branch import Branch
from bzrlib.revisionspec import RevisionSpec

class BzrCommander:
  def __init__(self, repository_url):
    self.branch = Branch.open(repository_url)
    self.branch.lock_read()
    #self.repository = self.branch.repository

  def get_file_content(self, filename, revision):
    rev_spec = RevisionSpec.from_string(revision)
    tree = rev_spec.as_tree(self.branch)
    file_id = tree.path2id(filename)
    if file_id == None:
      return None
    content = tree.get_file_text(file_id)
    #if isinstance(content, unicode):
    #  content = content.encode('UTF-8')
    return content

  def get_parent_tokens(self, revision):
    revision = RevisionSpec.from_string(revision)
    tree = revision.as_tree(self.branch)
    parents = tree.get_parent_ids()
    #print parents
    return parents

  def cleanup():
    self.branch.unlock()


if __name__ == "__main__":
  #print bzr_cat('/home/amujumdar/bzrlib_examples/bzr.2.1', 'bzrlib/transport/local.py', 'revid:pqm@pqm.ubuntu.com-20090624225712-x20543g8bpv6e9ny')
  cmd = BzrCommander('/home/amujumdar/bzrlib_examples/bzr.2.1')
  print cmd.get_file_content('bzrlib/transport/local.py', 'revid:pqm@pqm.ubuntu.com-20090624225712-x20543g8bpv6e9ny'),

