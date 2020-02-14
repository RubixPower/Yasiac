# cython: language_level=3
import os
import subprocess

import psutil
from libc.stdio cimport FILE, fopen, fclose, printf
cdef class Cpu:
    __slots__ = ('cached_cpuinfo', 'cached_name', 'cached_cores_threads', 'cores',
                 '__weakref__')
    cdef list cached_cpuinfo
    cdef str cached_name
    cdef str cached_cores_threads
    cdef str cores

    def __cinit__(self):
        with open('/proc/cpuinfo', 'r') as f:
            self.cached_cpuinfo = f.read().splitlines()
        self.cached_name = None
        self.cached_cores_threads = None
        self.cores = None

    @staticmethod
    cdef str clean(str text):
        if text.startswith('Intel'):
            return (text.split(' CPU @')[0]
                        .replace('(R)', '').replace('(TM)', '')
                    )
        elif text.startswith('AMD'):
            splitted = text.split(' ')
            for i in range(2):
                splitted.pop(-1)
            return ' '.join(splitted)

        else:
            print('Cpu not found or supported')
    cdef str c_name(self):
        return next(
            Cpu.clean(line.split(': ')[1])
            for line in self.cached_cpuinfo
            if line.startswith('model name\t')
        )

    def name(self):
        if self.cached_name is None:
            self.cached_name = self.c_name()
        return self.cached_name

    cdef str c_cores_threads(self):
        cdef int threads
        cdef str line

        threads = 0
        for line in self.cached_cpuinfo:
            if line.startswith('cpu cores\t'):
                self.cores = line.split(': ')[1]
            elif line.startswith('processor\t'):
                threads = threads + 1
        return f'{self.cores}/{threads}'

    def cores_threads(self):
        if self.cached_cores_threads is None:
            self.cached_cores_threads = self.c_cores_threads()
        return self.cached_cores_threads

    cpdef str temperature(self):
        cdef float sum_temps
        cdef int num_cores
        cdef object popen
        cdef str line
        cdef str temp_str

        sum_temps = 0
        num_cores = 0
        with subprocess.Popen(
                ('sensors', '-A'),
                bufsize=1,
                stdin=subprocess.DEVNULL,
                stdout=subprocess.PIPE,
                stderr=subprocess.DEVNULL,
                close_fds=True,
                shell=False,
                universal_newlines=True,
                env={ **os.environ, 'LC_ALL': 'C' }
        ) as popen:
            for line in popen.stdout:
                if not line.startswith('Core '):
                    continue

                temp_str = line.split(': ')[1].split(' C  (')[0].strip()
                sum_temps = sum_temps + float(temp_str)
                num_cores = num_cores + 1

        return f'{round(sum_temps / num_cores)} [°C]'

    cpdef str clock(self):
        cdef str clock
        cdef object popen

        clock = None
        with subprocess.Popen(
                ('lscpu',),
                bufsize=1,
                stdin=subprocess.DEVNULL,
                stdout=subprocess.PIPE,
                stderr=subprocess.DEVNULL,
                close_fds=True,
                shell=False,
                universal_newlines=True,
                env={ **os.environ, 'LC_ALL': 'C' }
        ) as popen:
            for line in popen.stdout:
                if not line.startswith('CPU MHz:'):
                    continue
                
                clock = line.split(':')[1].strip().split('.')[0]

        return f'{clock} [MHz]'

    def load(self):
        return f'{psutil.cpu_percent():.0f} [%]'
