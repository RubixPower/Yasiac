#!/usr/bin/env python3
import subprocess
import os
import glob


class Gpu:
    __slots__ = ("glxinfo",
                 "gpu_mem_path",
                 "amdgpu_info",
                 "vram_total",
                 "amdgpu_path",
                 "__weakref__")

    def __init__(self):
        self.glxinfo = []
        # gpu path in hwmon
        gpu_mem_glob = glob.glob("/sys/class/hwmon/hwmon*/fan1_input")[0]
        self.gpu_mem_path = gpu_mem_glob.replace('fan1_input', '')

        with open(os.path.join(
            self.gpu_mem_path, 'device/mem_info_vram_total')
        ) as FileObj:
            self.vram_total = int(FileObj.read().strip()) / 1024 ** 2

        with subprocess.Popen(
            ("glxinfo", "-B"),
            bufsize=1,
            stdin=subprocess.DEVNULL,
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
            close_fds=True,
            shell=False,
            universal_newlines=True,
            env={**os.environ, "LC_ALL": "C"},
        ).stdout as popen:
            for line in popen:
                self.glxinfo.append(line)

        with open(
            glob.glob("/sys/kernel/debug/dri/*/amdgpu_pm_info")[0]
                  ) as FileObj:
            self.amdgpu_info = FileObj.read().splitlines()

    def name(self):
        for line in self.glxinfo:
            if "Device: " in line:
                tmp_var = line.split("Device: ")[1]
                return tmp_var.replace("(TM) ", "").split(" (")[0]

    def vram_usage_percentage(self):
        with open(
            os.path.join(self.gpu_mem_path, 'device/mem_info_busy')
        ) as FileObj:
            return int(FileObj.read().strip())

    def vram_usage_total(self):
        with open(
            os.path.join(self.gpu_mem_path, 'device/mem_info_vram_used')
        ) as FileObj:
            return (
                str(round(int(FileObj.read().strip()) / 1024**2)) +
                '/' +
                str(self.vram_total)
            )

    def clock(self):
        for line in self.amdgpu_info:
            if "(SCLK)" in line:
                return f"{line.split(' MHz (SCLK)')[0].strip()} [MHz]"

    def fan_speed_current(self):
        with open(os.path.join(self.gpu_mem_path, "fan1_input")) as FileObj:
            return FileObj.read().replace("\n", "")

    def temperature(self):
        for line in self.amdgpu_info:
            if "GPU Temperature:" in line:
                temp_var = line.split("GPU Temperature: ")[1]
                return temp_var.replace(" C", " °C").strip()

    def load(self):
        for line in self.amdgpu_info:
            if "GPU Load:" in line:
                return line.split(": ")[1]
