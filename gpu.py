#!/usr/bin/env python3
import subprocess
import os
import glob


class Gpu:
    __slots__ = ("glxinfo",
                 "amdgpu_info",
                 "vram_total",
                 "FileData",
                 "amdgpu_path",
                 "__weakref__")

    def __init__(self, FileData):
        self.glxinfo = []
        self.amdgpu_info = []
        self.FileData = FileData
        gpu_pm_glob = glob.glob("/sys/kernel/debug/dri/*/amdgpu_pm_info")
        self.amdgpu_path = gpu_pm_glob[0].replace("amdgpu_pm_info", "")
        gpu_mem_glob = glob.glob("/sys/devices/pci*/*/*/mem_info_vram_total")
        with open(gpu_mem_glob[0]) as FileObj:
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
        with open(f"{self.amdgpu_path}amdgpu_pm_info") as amdgpu_data:
            self.amdgpu_info = amdgpu_data.read().splitlines()

    def name(self):
        for line in self.glxinfo:
            if "Device: " in line:
                tmp_var = line.split("Device: ")[1]
                return tmp_var.replace("(TM) ", "").split(" (")[0]

    def vram_usage_percentage(self):
        with open(
            os.path.join(self.FileData.gpu_path, "/device/mem_busy_percent")
        ) as data:
            return int(data.read().strip())

    def vram_usage_total(self):
        with open(
            self.FileData.gpu_path + "/device/mem_info_vram_used"
        ) as data:
            return f"{round(int(data.read().strip()) / 1048576)}/{self.vram_total}"

    def clock(self):
        for line in self.amdgpu_info:
            if "(SCLK)" in line:
                return f"{line.split(' MHz (SCLK)')[0].strip()} [MHz]"

    def fan_speed_current(self):
        with open(os.path.join(self.FileData.gpu_path, "fan1_input")) as data:
            return data.read().replace("\n", "")

    def temperature(self):
        for line in self.amdgpu_info:
            if "GPU Temperature:" in line:
                temp_var = line.split("GPU Temperature: ")[1]
                return temp_var.replace(" C", " °C").strip()

    def load(self):
        for line in self.amdgpu_info:
            if "GPU Load:" in line:
                return line.split(": ")[1]
