
from compiled import cpu, gpu, ram
cpu_info = cpu.Cpu()
gpu = gpu.Gpu()
ram = ram.Ram()
# from compiled import cpu, gpu, ram
# import pyximport; pyximport.install()
# import cpu, gpu, ram
# print(cpu_info.name()) #real    0m0,044s
# print(cpu_info.cores_threads()) #real    0m0,041s
# print(cpu_info.temperature()) #real    0m0,058s
# print(cpu_info.clock()) #real    0m0,064s
# print(cpu_info.load())

print(gpu.name()) #real    0m0,086s
# print(gpu.vram_total()) #real    0m0,071s
# print(gpu.vram_usage_percentage())
# print(gpu.vram_usage_total())
# print(gpu.clock())
# print(gpu.temperature()) #real    0m0,043s
# print(gpu.load()) #real    0m0,073s

# print(ram.capacity()) #real    0m0,068s
# print(ram.modules_manufacturer()) #real    0m0,056s
