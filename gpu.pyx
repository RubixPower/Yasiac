import subprocess
cdef class Gpu():
    cdef dict __dict__
    def __init__(self):
        self.sensors = subprocess.getoutput(f"sensors -A").splitlines()
    cpdef str name(self):
        cdef list temporary
        cdef str name
        cdef list clear_list
        temporary =  subprocess.getoutput("glxinfo -B | grep 'Device: '").split('    Device:')
        name = temporary.replace(' (TM)', '')
        clear_list = [' (TM)', 'Graphics']

    cpdef str vram(self):
        cdef list data
        cdef list vram
        
        data = (subprocess.getoutput("rocm-smi --showmemuse")).splitlines().split('Device: ')
        for line in data:
            if 'GPU memory use' in line:
                for element in clear_list:
                    line.replace(element, '')
                vram = line.split(' GPU memory use (%):').strip()[-1]
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
        return 'needs to be implimented'

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
        data = subprocess.getouput('rocm-smi -u').splitlines()
        for line in data:
            if 'GPU use (%)' in line:
                load_line = line
                load = load_line.split('GPU use (%):')[-1]
                return load

