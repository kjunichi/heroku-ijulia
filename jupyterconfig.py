import os
import uuid
import IPython.lib

c = get_config()

### Password protection ###
c.NotebookApp.password = IPython.lib.passwd(
    os.getenv('JUPYTER_NOTEBOOK_PASSWORD', default=str(uuid.uuid4())))
c.NotebookApp.notebook_dir = '/app/user'
