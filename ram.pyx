# cython: language_level=3
import os
import subprocess


class Ram:
    __slots__ = ('__weakref__',)

    @staticmethod
    def capacity():
        with subprocess.Popen(
                ('lsmem', '-o', 'SIZE'),
                bufsize=1,
                stdin=subprocess.DEVNULL,
                stdout=subprocess.PIPE,
                stderr=subprocess.DEVNULL,
                close_fds=True,
                shell=False,
                universal_newlines=True,
                env={**os.environ, 'LC_ALL': 'C'}
        ) as popen:
            for line in popen.stdout:
                if not line.startswith('Total online memory:'):
                    continue

                ram_capacity = line[len('Total online memory:'):].strip()
                if not ram_capacity[-1:].isdigit():
                    return ram_capacity[0:-1] + ' ' + ram_capacity[-1:] + 'B'
                return ram_capacity

    @staticmethod
    def modules_manufacturer():
        manufacturers = set()

        with subprocess.Popen(
                ('dmidecode', '--type', 'memory'),
                bufsize=1,
                stdin=subprocess.DEVNULL,
                stdout=subprocess.PIPE,
                stderr=subprocess.DEVNULL,
                close_fds=True,
                shell=False,
                universal_newlines=True,
                env={**os.environ, 'LC_ALL': 'C'}
        ) as popen:
            for line in popen.stdout:
                if not line.startswith('\tManufacturer: '):
                    continue
                if line[-1:] == '\n':
                    line = line[0:-1]

                manufacturer = line[len('\tManufacturer: '):]
                if manufacturer != 'Not Specified':
                    manufacturers.add(manufacturer)

        return ', '.join(manufacturers)
