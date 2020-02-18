# cython: language_level=3
import subprocess
import os
from get_path import get_path, FileData


def static_variables():

    # /sys/devices
    global RPM_file_path, vraminfo_filepath, vram_total, vram_OnePercentage
    RPM_file_class = FileData('fan1_input')
    # this file is only used to find the right subfolder
    vram_info_class = FileData('mem_info_vram_used')
    file_data = {RPM_file_class.id: RPM_file_class,
                 vram_info_class.id: vram_info_class}
    get_path(file_data, '/sys/devices')
    # gets the path for the RPM data file
    RPM_file_path = file_data.get('fan1_input').path
    # gets the vram info path
    vram_info_tmpvar = file_data.get('mem_info_vram_used')
    vraminfo_filepath = vram_info_tmpvar.path.replace('mem_info_vram_used', '')
    with open(f'{vraminfo_filepath}mem_info_vram_total') as data:
        vram_total = int(data.read()) / 1048576
        vram_OnePercentage = vram_total / 100

    # /sys/kernel/debug/dri/
    global amdgpu_pm_filepath
    amdgpuInfo_file_class = FileData('amdgpu_pm_info')
    file_data = {amdgpuInfo_file_class.id: amdgpuInfo_file_class}
    get_path(file_data, '/sys/kernel/debug/dri')
    amdgpu_pm_filepath = file_data.get('amdgpu_pm_info').path


static_variables()


cdef class Gpu:
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
            env={**os.environ, 'LC_ALL': 'C'}
            ).stdout as popen:
                for line in popen:
                    self.glxinfo.append(line)

        with open(amdgpu_pm_filepath, 'r') as amdgpu_data:
            self.amdgpu_info = amdgpu_data.read().splitlines()

    cpdef str name(self):
        cpdef str line
        for line in self.glxinfo:
            if 'Device: ' in line:
                tmp_var = line.split('Device: ')[1]
                return tmp_var.replace('(TM) ', '').split(' (')[0]

    cpdef int vram_usage_percentage(self):
        with open(f'{vraminfo_filepath}mem_busy_percent', 'r') as data:
            return int(data.read().strip())

    cpdef str vram_usage_total(self):
        # cdef int vram_usage_percentage, vram_usage
        # vram_usage_percentage = int(self.vram_usage_percentage())
        # one_percentage = vram_total / 100
        # usage = round(vram_OnePercentage * vram_usage_percentage)
        # return (f'~{usage}/{vram_total}')

        # needs to be tested !! the code above & below
        with open(f'{vraminfo_filepath}mem_info_vram_used') as data:
            return f'{round(int(data.read().strip()) / 1048576)}/{vram_total}'

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
                temp_var = line.split('GPU Temperature: ')[1]
                return temp_var.replace(' C', ' °C').strip()

    cpdef str load(self):
        cdef str line
        for line in self.amdgpu_info:
            if 'GPU Load:' in line:
                return line.split(': ')[1]
