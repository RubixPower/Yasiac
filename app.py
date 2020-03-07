import os
import subprocess
import cpu
import gpu
import ram
from window import Window


if os.getuid() == 0:
    App = Window
    App(cpu.Cpu, gpu.Gpu, ram.Ram).main()
else:

    subprocess.Popen(
            ("notify-send", "Yasiac", "You did not run the app as root"),
            bufsize=1,
            close_fds=True,
            shell=False,
            universal_newlines=True,
            env={**os.environ, "LC_ALL": "C"})
    quit()
