import cpu
import gpu
import ram
from window import Window
import os
from get_path import FileData
if os.getuid() == 0:
    app = Window
    app(cpu.Cpu, gpu.Gpu, ram.Ram).main()
else:
    quit()
