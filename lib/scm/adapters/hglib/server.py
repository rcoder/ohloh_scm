import sys
import time
import traceback

from mercurial import ui, hg

class HglibPipeServer:
  def __init__(self, repository_url):
    self.ui = ui.ui()
    self.repository = hg.repository(self.ui, repository_url)

  def get_file_content(self, filename, revision):
    c = self.repository.changectx(revision)
    fc = c[filename]
    contents = fc.data()
    return contents

  def get_parent_tokens(self, revision):
    c = self.repository.changectx(revision)
    parents = [p.hex() for p in c.parents() if p.hex() != '0000000000000000000000000000000000000000']
    return parents

class Command:
  def __init__(self, line):
    self.args = line.rstrip().split('\t')

  def get_action(self):
    return self.args[0]

  def get_arg(self, num):
    return self.args[num]

def send_status(code, data_len):
  sys.stderr.write('%s%09d' % (code, data_len))
  sys.stderr.flush()

def send_success(data_len=0):
  send_status('T', data_len)

def send_failure(data_len=0):
  send_status('F', data_len)

def send_error(data_len=0):
  send_status('E', data_len)

def send_data(result):
  sys.stdout.write(result)
  sys.stdout.flush()

def command_loop():
  while True:
    s = sys.stdin.readline()
    cmd = Command(s)
    if s == '' or cmd.get_action() == 'QUIT':
      sys.exit(0)
    elif cmd.get_action() == 'REPO_OPEN':
      commander = HglibPipeServer(cmd.get_arg(1))
      send_success()
    elif cmd.get_action() == 'CAT_FILE':
      try:
        content = commander.get_file_content(cmd.get_arg(2), cmd.get_arg(1))
        send_success(len(content))
        send_data(content)
      except Exception:
        send_failure() # Assume file not found
    elif cmd.get_action() == 'PARENT_TOKENS':
      tokens = commander.get_parent_tokens(cmd.get_arg(1))
      tokens = '\t'.join(tokens)
      send_success(len(tokens))
      send_data(tokens)
    else:
      error = "Invalid Command - %s" % cmd.get_action()
      send_error(len(error))
      send_data(error)
      sys.exit(1)

if __name__ == "__main__":
  try:
    command_loop()
  except Exception:
    exc_trace = traceback.format_exc()
    send_error(len(exc_trace))
    send_data(exc_trace)
    sys.exit(1)
