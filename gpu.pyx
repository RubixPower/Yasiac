# cython: language_level=3
import subprocess
import os

global RPM_file_path
global amdgpu_pm_filepath
with subprocess.Popen(
    ('find', '/sys/devices/virtual', '-name', 'temp1_input'),
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
            RPM_file_path = line.strip()
            break

with subprocess.Popen(
    ('find', '/sys/kernel/debug/dri/', '-name', 'amdgpu_pm_info'),
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
            amdgpu_pm_filepath = line.strip()# works


cdef class Gpu():
    cdef dict __dict__
    __slots__ = ('glxinfo', 'amdgpu_info',
                '__weakref__')
    cdef list glxinfo, amdgpu_info

    def __cinit__(self):
        self.glxinfo = []
        self.amdgpu_info = []
        with subprocess.Popen(
            ('glxinfo', '-B'),
            bufsize=1,
            stdin=subprocess.DEVNULL,
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
            close_fds=True,
            shell=False,
            universal_newlines=True,
            env={ **os.environ, 'LC_ALL': 'C' }
            ).stdout as popen:
                for line in popen:
                    self.glxinfo.append(line)

        with subprocess.Popen(
            ('cat', amdgpu_pm_filepath),
            bufsize=1,
            stdin=subprocess.DEVNULL,
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
            close_fds=True,
            shell=False,
            universal_newlines=True,
            env={ **os.environ, 'LC_ALL': 'C' }
            ).stdout as popen:
                for line in popen:
                    self.amdgpu_info.append(line)

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
        with open(RPM_file_path, 'r') as data:
            return data.read().replace('\n', '')

    cpdef str temperature(self):
        cdef str line
        for line in self.amdgpu_info:
            if 'GPU Temperature:' in line:
                return line.split('GPU Temperature: ')[1].replace(' C', ' °C').strip()

    cpdef str load(self):
        cdef str line
        for line in self.amdgpu_info:
            if 'GPU Load:' in line:
                return line.split(': ')[1]
