#!/usr/bin/env python3
import os
import subprocess
import psutil


class Cpu:
    __slots__ = (
        "cached_cpuinfo",
        "cached_name",
        "cached_cores_threads",
        "cores",
        "FileData",
        "__weakref__",
    )

    def __init__(self, FileData):
        with open("/proc/cpuinfo") as f:
            self.cached_cpuinfo = f.read().splitlines()
        self.cached_name = None
        self.cached_cores_threads = None
        self.cores = None
        self.FileData = FileData

    @staticmethod
    def clean(text):
        if text.startswith("Intel"):
            text = text.split(" CPU @")[0]
            return text.replace("(R)", "").replace("(TM)", "")
        elif text.startswith("AMD"):
            splitted = text.split(" ")
            for i in range(2):
                splitted.pop(-1)
            return " ".join(splitted)
        else:
            print("Cpu not found or supported")

    def name_(self):
        return next(
            Cpu.clean(line.split(": ")[1])
            for line in self.cached_cpuinfo
            if line.startswith("model name\t")
        )

    def name(self):
        if self.cached_name is None:
            self.cached_name = next(
                Cpu.clean(line.split(": ")[1])
                for line in self.cached_cpuinfo
                if line.startswith("model name\t")
            )
        return self.cached_name

    def cores_threads_(self):
        threads = 0
        for line in self.cached_cpuinfo:
            if line.startswith("cpu cores\t"):
                self.cores = line.split(": ")[1]
            elif line.startswith("processor\t"):
                threads = threads + 1
        return f"{self.cores}/{threads}"

    def cores_threads(self):
        if self.cached_cores_threads is None:
            self.cached_cores_threads = self.cores_threads_()
        return self.cached_cores_threads

    def temperature(self):
        with open(os.path.join(self.FileData.cpu_path, 'temp1_input')) as file_data:
            return int(file_data.read()) / 1000

    def clock(self):
        clock = None
        with subprocess.Popen(
            ("lscpu",),
            bufsize=1,
            stdin=subprocess.DEVNULL,
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
            close_fds=True,
            shell=False,
            universal_newlines=True,
            env={**os.environ, "LC_ALL": "C"},
        ) as popen:
            for line in popen.stdout:
                if not line.startswith("CPU MHz:"):
                    continue

                clock = line.split(":")[1].strip().split(".")[0]

        return f"{clock} [MHz]"

    def load(self):
        return f"{psutil.cpu_percent():.0f} [%]"
