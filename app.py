import subprocess

from compiled import cpu, gpu, ram
from window import Window
app = Window
app(cpu.Cpu, gpu.Gpu, ram.Ram).main()