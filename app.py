# from compiled import window
from compiled import cpu, gpu, ram
import window
app = window.Window
app(cpu.Cpu, gpu.Gpu, ram.Ram).main()