# cython: language_level=3
import subprocess
cdef class Gpu():
    cdef dict __dict__
    def __init__(self):
        self.sensors = subprocess.getoutput("sensors -A").splitlines()
        self.glxinfo = subprocess.getoutput("glxinfo -B").splitlines()
        self.rocm = subprocess.getoutput("rocm-smi -a").splitlines()
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
        vram_usage_total = (f'~{str(usage)}/{str(vram_total)}')
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
        return 'gpu clock needs to be implimented'

    cpdef int fan_speed_current(self):
        cdef str line
        for line in self.sensors:
            if 'fan1:' in line:
                FanSpeed = line.split('fan1:')[1].split('  (')[0].strip().replace('RPM', '')
                return int(FanSpeed)

    cpdef int temperature(self):
        for line in self.sensors:
            if 'edge:         ' in line:
                temp = line.replace('+', '').split('edge:         ')[1].split('°C  (')[0]
                return int(float(temp))

    cpdef int load(self):
        cdef list data
        cdef str load
        data = subprocess.getoutput('rocm-smi -u').splitlines()
        for line in data:
            if 'GPU use (%)' in line:
                load_line = line
                load = load_line.split('GPU use (%):')[-1].strip()
                return int(load)

