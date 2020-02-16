
from compiled import cpu, gpu, ram
cpu_info = cpu.Cpu()
gpu = gpu.Gpu()
ram = ram.Ram()
from compiled import cpu, gpu, ram
import pyximport; pyximport.install()
print(cpu_info.name())
print(cpu_info.cores_threads())
print(cpu_info.temperature())
print(cpu_info.clock())
print(cpu_info.load())

print(gpu.name())
print(gpu.vram_total())
print(gpu.vram_usage_percentage())
print(gpu.vram_usage_total())
print(gpu.clock())
print(gpu.temperature())
print(gpu.load())

print(ram.capacity())
print(ram.modules_manufacturer())
