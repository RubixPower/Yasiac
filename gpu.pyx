# cython: language_level=3
import subprocess
cdef class Gpu():
    cdef dict __dict__
    def __init__(self):
        self.gpu_hwmon_path = subprocess.getoutput()
        self.sensors = subprocess.getoutput("sensors -A").splitlines()
        self.glxinfo = subprocess.getoutput("glxinfo -B").splitlines()
        self.amdgpu_info = subprocess.getoutput("cat /sys/kernel/debug/dri/0/amdgpu_pm_info").splitlines()

    cpdef str name(self):
        cpdef str line
        for line in self.glxinfo:
            if 'Device: ' in line:
                return line.split('Device: ')[1].replace('(TM) ', '').split(' (')[0]

    cpdef int vram_total(self):
        cdef int vram
        cdef str line
        for line in self.glxinfo:
            if 'Video memory:' in line:
                return int(line.split(': ')[1].replace('MB', '').strip())
                
    cpdef str vram_usage_percentage(self):
        cdef list data
        data = (subprocess.getoutput("rocm-smi --showmemuse")).splitlines()
        for line in data:
            if 'GPU memory use (%)' in line:
                return line.split('GPU memory use (%):')[-1].strip()
                
    cpdef str vram_usage_total(self):
        cdef int vram_total, vram_usage_percentage, vram_usage
        cdef str vram_usage_total
        vram_total = self.vram_total()
        vram_usage_percentage = int(self.vram_usage_percentage())
        one_percentage = vram_total / 100
        usage = round(one_percentage * vram_usage_percentage)
        return (f'~{usage}/{vram_total}')

    cpdef str clock(self):
        cdef str line
        for line in self.amdgpu_info:
            if '(SCLK)' in line: 
                return f"{line.split(' MHz (SCLK)')[0].strip()} [MHz]"

    cpdef str fan_speed_current(self):
        cdef str line
        for line in self.sensors:
            if 'fan1:' in line:
                return line.split('fan1:')[1].split('  (')[0].strip()

    cpdef str temperature(self):
        cdef str line
        for line in self.amdgpu_info:
            if 'GPU Temperature:' in line:
                return line.split('GPU Temperature: ')[1].replace(' C', ' °C')

    cpdef str load(self):
        cdef str line
        for line in self.amdgpu_info:
            if 'GPU Load:' in line:
                return line.split(': ')[1]
