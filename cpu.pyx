# cython: language_level=3, boundscheck=False
import subprocess, psutil
cdef class Cpu:
    cdef dict __dict__
    def __init__(self):
        with open('/proc/cpuinfo', 'r') as f:
            self.cpuinfo = f.read().splitlines()

    cpdef str name(self):
        cdef str name
        for line in self.cpuinfo:
            if 'model name' in line:
                name = line.split(':')[1].split(' CPU @')[0].replace('(R)', '').replace('(TM)', '').strip()
                return name

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
        cdef list clean
        cdef int temps
        temps = 0
        data = subprocess.getoutput("sudo sensors -A | grep -F 'Core'").splitlines()
        cpu_cores = len(data) # gets how many cures you have
        for line in data:
            clean = line.split(':        +')[1].replace('°C', '').split('  (')
            temps = int(float(clean[0])) + temps
        return str(round(temps / 6))

    cpdef str clock(self):
        cdef str clock
        clock = subprocess.getoutput(f"sudo lscpu | grep -F 'CPU MHz'").split(':')[1].strip().split('.')[0]
        return clock
    cpdef str load(self):
        load = '{:.2f}'.format(psutil.cpu_percent())
        
        return load