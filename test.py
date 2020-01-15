from compiled import cpu, gpu, ram
cpu = cpu.Cpu()
gpu = gpu.Gpu()
ram = ram.Ram()

print(cpu.name())
print(cpu.cores_threads())
print(cpu.temp())
print(cpu.clock())

print(gpu.name())
print(gpu.vram())
print(gpu.vendor())
print(gpu.clock())
print(gpu.temp())
print(gpu.load())

print(ram.ram_capacity())
print(ram.ram_sticks_manufacturer())