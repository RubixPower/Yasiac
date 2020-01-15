import subprocess 
cdef class Cpu:
    cdef dict __dict__
    def __init__(self):
        with open('/proc/cpuinfo' 'r') as f:
            self.cpuinfo = f.read().splitlines()

    cpdef str name(self):
        cdef str name
        for line in self.cpuinfo:
            if 'model name' in line:
                name = line.split(':')[1].split('@')[0].replace('(R)', '').replace('(TM)', '').strip()
                return name

    cpdef str cores_threads(self):
        cdef str cores_threads 
        cdef int threads
        threads = 0
        for line in self.cpuinfo:
            if 'cpu cores' in line:
                cores = line.split(':'    ).pop(1).replace(' ', '') + '/')
            for 'processor' in line:
                threads = threads +1
            return (cores +' / '+ str(threads))

    cpdef str temperature(self):
        cdef int data
        cdef str line
        cdef int cpu_cores
        cdef str core_temp
        cdef int final_temp
        data = subprocess.getoutput("sudo sensors -A | grep -F 'Core'").splitlines()
        cpu_cores = len(data) # gets how many cures you have
        for line in data:
            core_temp=line.replace('°C', '').split(':        +')[1].split('  (')[0]
            final_temp = int(float(core_temp)) + final_temp
        return str(int(final_temp / cpu_cores))

    cpdef str clock(self):
        cdef str clock
        clock = subprocess.getoutput(f"sudo lscpu | grep -F 'CPU MHz'").split(':')[1].strip().split('.')[0]
        return clock