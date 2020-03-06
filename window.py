#!/usr/bin/env python3
import gi
import control as cntrl
import os
import threading
import time
gi.require_version("Gtk", "3.0")
from gi.repository import Gtk, Gdk


class Handler():
    def __init__(self, window, control):
        self.window = window
        self.control = control

    def on_destroy(self, *args):
        self.window.threads_run = False
        Gtk.main_quit()
        quit()

    ############################################
    # Control Stack
    def GpuFanScaleMode(self, *args):
        status = self.window.GpuCheckBtnStatus()
        if status:
            self.window.ControlGpuScale.set_sensitive(False)
        else:
            self.window.ControlGpuScale.set_sensitive(True)

    def ControlApply(self, *args):
        CheckBtn_status = self.window.ControlGpuCheckButton.get_active()
        if CheckBtn_status:
            self.control.amd_fan_speed_mode_change('auto')
        else:
            AdjustmentValue = self.window.ControlGpuAdjustment.get_value()
            self.control.amd_fan_speed_mode_change('manual')
            self.control.amd_fan_speed_change(int(AdjustmentValue * 2.55))

    def ControlReset(self, *args):
        if self.control.amd_fan_speed_mode_current() == 'auto':
            self.window.ControlGpuCheckButton.set_active(True)
            self.window.ControlGpuScale.set_sensitive(False)
        else:
            self.window.ControlGpuCheckButton.set_active(False)
            fan_speed = self.control.amd_fan_speed_current()
            self.window.ControlGpuAdjustment.set_value(round(fan_speed / 2.55))


class Window:
    __slots__ = (
        "path", "builder",
        "control", "window",
        "cpu_info", "gpu_info",
        "ControlGpuCheckButton", "ControlGpuScale", "ControlGpuAdjustment",
        "threads_run",
        "FanUpdater_loop",
        "MainWindow_loop",
        "__weakref__"
        )

    def __init__(self, cpu_class, gpu_class, ram_class):
        self.path = (f"{os.path.dirname(os.path.abspath(__file__))}/")
        self.builder = Gtk.Builder()
        self.builder.add_from_file(f'{self.path}ui.glade')
        self.control = cntrl.Control()
        self.builder.connect_signals(
            Handler(self, self.control)  # connect event signals to MainHandler
            )
        self.window = self.builder.get_object('application_window')
        # Imports the css
        style_provider = Gtk.CssProvider()
        style_provider.load_from_path(f'{self.path}style.css')
        Gtk.StyleContext.add_provider_for_screen(
            Gdk.Screen.get_default(),
            style_provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        )

        self.cpu_info = cpu_class
        self.gpu_info = gpu_class

        #  INFO
        def static_info():
            cpu_static_info = cpu_class()
            gpu_static_info = gpu_class()
            ram_static_info = ram_class()
            cpu_labels = {
                'cpu_name_label': cpu_static_info.name,
                'cpu_cores_threads_label': cpu_static_info.cores_threads
                }
            gpu_labels = {'gpu_name_label': gpu_static_info.name}
            ram_labels = {
                'ram_capacity_label': ram_static_info.capacity,
                'ram_manufacturer_label': ram_static_info.modules_manufacturer
                }
            self.update_labels(cpu_labels)
            self.update_labels(gpu_labels)
            self.update_labels(ram_labels)
        static_info()

        #  CONTROL
        self.ControlGpuCheckButton = self.builder.get_object('GpuCheckButton')
        self.ControlGpuScale = self.builder.get_object('GpuFanScale')
        self.ControlGpuAdjustment = self.builder.get_object('GpuFanAdjustment')
        self.threads_run = True
        self.ControlInit()

    #  LABELS
    def update_labels(self, dictionary):
        for element in dictionary:
            label = self.builder.get_object(element)
            value = dictionary.get(element)()
            label.set_text(f'\t{str(value)}')

    #  CONTROL
    def GpuCheckBtnStatus(self):
        status = self.ControlGpuCheckButton.get_active()
        return status

    def GpuScaleSetSens(self, choice):
        self.ControlGpuScale.set_sensitive(choice)

    def GpuScaleGetSens(self):
        status = self.ControlGpuScale.get_sensitive()
        return status

    def ControlInit(self):
        mode = self.control.amd_fan_speed_mode_current()
        if mode == 'auto':
            self.ControlGpuCheckButton.set_active(True)
            self.ControlGpuScale.set_sensitive(False)
        else:
            self.ControlGpuCheckButton.set_active(False)
            self.ControlGpuScale.set_sensitive(True)
            self.ControlGpuScale.set_value(
                self.control.amd_fan_speed_current() / 2.55
                )

    def FanUpdater(self):
        # updates the fan adjustment value when check box not activated
        while self.threads_run:
            time.sleep(1)
            if self.ControlGpuCheckButton.get_active():
                fan_speed = self.control.amd_fan_speed_current()
                self.ControlGpuAdjustment.set_value(fan_speed / 2.55)
            else:
                pass
    # INFO
    def DynamicInfo(self):
        while self.threads_run:
            cpu_dynamic_info = self.cpu_info()
            gpu_dynamic_info = self.gpu_info()
            cpu_dynamic_labels = {
                'cpu_clock_label': cpu_dynamic_info.clock,
                'cpu_temp_label': cpu_dynamic_info.temperature,
                'cpu_load_label': cpu_dynamic_info.load
            }

            gpu_dynamic_labels = {
                'gpu_vram_label': gpu_dynamic_info.vram_usage_total,
                'gpu_clock_label': gpu_dynamic_info.clock,
                'gpu_temp_label': gpu_dynamic_info.temperature,
                'gpu_fspeed_label': gpu_dynamic_info.fan_speed_current,
                'gpu_load_label': gpu_dynamic_info.load
            }

            self.update_labels(cpu_dynamic_labels)
            self.update_labels(gpu_dynamic_labels)
            time.sleep(1)
    # --------------------------------------------------------------------------
    def show_window(self):
        self.window.show_all()
        Gtk.main()

    def main(self):
        FanUpdater_loop = threading.Thread(target=self.FanUpdater).start()
        DynamicInfo_loop = threading.Thread(target=self.DynamicInfo).start()
        MainWindow_loop = threading.Thread(target=self.show_window).start()
