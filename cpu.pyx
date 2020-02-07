# cython: language_level=3
import subprocess, psutil
cdef class Cpu:
    cdef dict __dict__
    def __init__(self):
        with open('/proc/cpuinfo', 'r') as f:
            self.cpuinfo = f.read().splitlines()

    def name(self):
        def clean(text):
            cleaned = text.split(':')[1].split(' CPU @')[0].replace('(R)', '').replace('(TM)', '').strip()
            return cleaned
        name = [clean(line) for line in self.cpuinfo if 'model name' in line]
        return name[0]

    cpdef str cores_threads(self): 
        cdef str cores
        cdef int thread_loop
        cdef str threads
        cdef str cores_threads
        cores = ''
        thread_loop = 0
        for line in self.cpuinfo:
            if 'cpu cores' in line:
                cores = (line.split(':'    ).pop(1).replace(' ', ''))
            elif 'processor' in line:
                thread_loop = thread_loop + 1
            else:
                pass
        threads = str(thread_loop)
        cores_threads = str(f'{cores}/{threads}')
        return cores_threads

    cpdef str temperature(self):
        cdef list data
        cdef int cpu_cores
        cdef str line
        cdef str float_str
        cdef int temp_int
        cdef int sum_temps
        sum_temps = 0
        data = subprocess.getoutput("sensors -A").splitlines()
        cpu_cores = 0 # gets how many cores you have
        for line in data:
            if 'Core' in line:
                float_str = line.split(':        +')[-1].split('°C  (')[0]
                temp_int = (int(float(float_str)))
                sum_temps = sum_temps + temp_int
                cpu_cores = cpu_cores + 1
        
        return (f'{str(round(sum_temps / cpu_cores))} [°C]')

    cpdef str clock(self):
        cdef str clock
        clock = subprocess.getoutput(f"lscpu | grep -F 'CPU MHz'").split(':')[1].strip().split('.')[0]
        return (f'{clock} [MHz]')
    cpdef str load(self):
        cdef str load
        load = '{:.0f}'.format(psutil.cpu_percent())
        
        return (f'{load} [%]')