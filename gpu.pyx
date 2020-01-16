import subprocess
cdef class Gpu():
    cdef dict __dict__
    def __init__(self):
        self.sensors = subprocess.getoutput(f"sensors -A").splitlines()

    cpdef str name(self):
        cdef list data
        cpdef str line
        cpdef str name
        data=  subprocess.getoutput("glxinfo -B | grep 'Device: '").splitlines()
        for line in data:
            if 'Device: ' in line:
                name = line.split('Device: ')[1].replace('(TM) ', '').split(' (')[0]
                return name

    cpdef str vram(self):
        cdef list data
        cdef str vram
        data = (subprocess.getoutput("rocm-smi --showmemuse")).splitlines()
        for line in data:
            if 'GPU memory use (%):' in line:
                vram = line.split('GPU memory use (%): ')[-1]
        return vram

    cpdef str vendor(self):
        cdef str vendor
        vendor = subprocess.getoutput(f"lspci | grep VGA")
        if 'AMD' in vendor:
            return 'amd'
        elif 'NVIDIA' in vendor:
            return 'nvidia'
        else:
            'error'

    cpdef str clock(self):
        return 'gpu clock needs to be implimented'

    cpdef str fan_current(self):
        for line in self.sensors:
            if 'fan1:         ' in line:
                fan = line.split('fan1:         ')[1].split(' RPM')[0]
                return fan

    cpdef str temp(self):
        for line in self.sensors:
            if 'edge:         ' in line:
                temp = line.replace('+', '').split('edge:         ')[1].split('°C  (')[0]
                return temp

    cpdef str load(self):
        cdef list data
        cdef str load
        data = subprocess.getoutput('rocm-smi -u').splitlines()
        for line in data:
            if 'GPU use (%)' in line:
                load_line = line
                load = load_line.split('GPU use (%):')[-1].strip()
                return load

