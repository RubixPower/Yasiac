from compiled import cpu, gpu, ram
cpu = cpu.Cpu()
gpu = gpu.Gpu()
ram = ram.Ram()

print(cpu.name()) #real    0m0,044s
print(cpu.cores_threads()) #real    0m0,041s
print(cpu.temperature()) #real    0m0,058s
print(cpu.clock()) #real    0m0,064s

print(gpu.name()) #real    0m0,086s
print(gpu.vram()) #real    0m0,071s
print(gpu.vendor()) #real    0m0,052s
print(gpu.clock())
print(gpu.temp()) #real    0m0,043s
print(gpu.load()) #real    0m0,073s

print(ram.ram_capacity()) #real    0m0,068s
print(ram.ram_sticks_manufacturer()) #real    0m0,056s