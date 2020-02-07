# cython: language_level=3
import subprocess
cdef class Gpu():
    cdef dict __dict__
    def __init__(self):
        self.sensors = subprocess.getoutput("sensors -A").splitlines()
        self.glxinfo = subprocess.getoutput("glxinfo -B").splitlines()
        self.amdgpu_info = subprocess.getoutput("cat /sys/kernel/debug/dri/0/amdgpu_pm_info").splitlines()
    cpdef str name(self):
        cdef list data
        cpdef str line
        cpdef str name
        for line in self.glxinfo:
            if 'Device: ' in line:
                name = line.split('Device: ')[1].replace('(TM) ', '').split(' (')[0]
                return name

    cpdef int vram_total(self):
        cdef int vram
        cdef str line
        for line in self.glxinfo:
            if 'Video memory:' in line:
                vram = int(line.split(': ')[1].replace('MB', '').strip())
                return vram
    cpdef int vram_usage_percentage(self):
        cdef list data
        cdef int vram_usage
        data = (subprocess.getoutput("rocm-smi --showmemuse")).splitlines()
        for line in data:
            if 'GPU memory use (%)' in line:
                vram_percentage = line.split('GPU memory use (%):')[-1].strip()
                return int(vram_percentage)
                

    cpdef str vram_usage_total(self):
        cdef int vram_total, vram_usage_percentage, vram_usage
        cdef str vram_usage_total
        vram_total = int(self.vram_total())
        vram_usage_percentage = int(self.vram_usage_percentage())
        one_percentage = vram_total / 100
        usage = str(int(one_percentage * vram_usage_percentage))
        vram_usage_total = (f'~{usage}/{str(vram_total)}')
        return vram_usage_total


    cpdef str vendor(self):
        cdef str vendor
        vendor = subprocess.getoutput(f"lspci | grep VGA")
        if 'AMD' in vendor:
            return 'amd'
        elif 'NVIDIA' in vendor:
            return 'nvidia'
        else:
            return 'error'

    cpdef str clock(self):
        for line in self.amdgpu_info:
            if '(SCLK)' in line:
                clock = line.split(' MHz (SCLK)')[0].strip()
        return clock

    cpdef int fan_speed_current(self):
        cdef str line
        for line in self.sensors:
            if 'fan1:' in line:
                FanSpeed = line.split('fan1:')[1].split('  (')[0].strip().replace('RPM', '')
                return int(FanSpeed)
    cpdef str temperature(self):
        for line in self.amdgpu_info:
            if 'GPU Temperature:' in line:
                temp = line.split('GPU Temperature: ')[1].replace(' C', ' °C')
        return temp

    cpdef str load(self):
        cdef str load
        for line in self.amdgpu_info:
            if 'GPU Load:' in line:
                load = line.split(': ')[1]
                return load

