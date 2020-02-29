from compiled import cpu, gpu, ram
from window import Window
from elevate import elevate
elevate() #  runs as root
app = Window
app(cpu.Cpu, gpu.Gpu, ram.Ram).main()
