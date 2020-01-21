#!/usr/bin/env python3
import subprocess
import os
import threading

import gi
gi.require_version("Gtk", "3.0")
from gi.repository import Gtk, Gdk, GObject

import control as cntrl
import time

class Handler():
    def __init__(self, window, control):
        self.window = window
        self.control = control
    def on_destroy(self, *args):
        self.window.thread_run = False
        Gtk.main_quit()
        quit()

    ############################################
    # Load Stack
    def load_info(self, *args):
        pass
        # def cpu():
        #     pass
        # def gpu():
        #     pass
        # def ram():
        #     pass
    
    ############################################
    # Control Stack
    def GpuFanScaleMode(self, *args):
        status = self.window.GpuCheckBtnStatus()
        if status == True:
            self.window.ControlGpuScale.set_sensitive(False)
        else:
            self.window.ControlGpuScale.set_sensitive(True)

    def ControlApply(self, *args):
        CheckBtn_status = self.window.ControlGpuCheckButton.get_active()
        if CheckBtn_status == True:
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
    def __init__(self, cpu_class, gpu_class, ram_class):
        self.path = (f"{os.path.dirname(os.path.abspath(__file__))}/") # current directory path
        self.builder = Gtk.Builder()
        self.builder.add_from_file(f'{self.path}ui.glade') # imports the .glade file
        self.control = cntrl.Control() # makes an instance of the control.Control() class in the control(named cntrl so you can know its a file) module
        self.builder.connect_signals(Handler(self, self.control)) # connect the event signals to MainHandler class
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
        self.ram_info = ram_class
        

        # Info Stack

        # static info
        self.cpu_static_info = cpu_class()
        self.gpu_static_info = gpu_class()
        self.ram_static_info = ram_class()
        self.ram_static_info = ram_class()
        self.cpu_labels = {'cpu_name_label':self.cpu_static_info.name, 'cpu_cores_threads_label':self.cpu_static_info.cores_threads}
        self.gpu_labels = {'gpu_name_label':self.gpu_static_info.name}
        self.ram_labels = {'ram_capacity_label': self.ram_static_info.capacity, 'ram_manufacturer_label':self.ram_static_info.modules_manufacturer}
        self.static_cpu_labels()
        self.static_gpu_labels()
        self.static_ram_labels()

        
        #dynamic info


        # Control Stack

        self.ControlGpuCheckButton = self.builder.get_object('GpuCheckButton')
        self.ControlGpuScale = self.builder.get_object('GpuFanScale')
        self.ControlGpuAdjustment = self.builder.get_object('GpuFanAdjustment')
        self.threads_run = True
        # self.ControlInit()
### Labels ################################################################################################################################
        
    def static_cpu_labels(self):
        for element in self.cpu_labels:
            label = self.builder.get_object(element)
            value = self.cpu_labels.get(element)()
            label.set_text(f'\t{str(value)}')

    def static_gpu_labels(self):
        for element in self.gpu_labels:
            label = self.builder.get_object(element)
            value = self.gpu_labels.get(element)()
            label.set_text(f'\t{str(value)}')

    def static_ram_labels(self):
        for element in self.ram_labels:
            label = self.builder.get_object(element)
            value = self.ram_labels.get(element)()
            label.set_text(f'\t{str(value)}')

### Control ###############################################################################################################################
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

    def FanUpdater(self):
    #updates the fan adjustment value every 1 sec WHEN check button is not active
        while self.threads_run:
            time.sleep(1)
            if self.ControlGpuCheckButton.get_active() == True:
                fan_speed = self.control.amd_fan_speed_current()
                self.ControlGpuAdjustment.set_value(fan_speed / 2.55)
            else:
                pass
    def DynamicInfo(self):
        def cpu():
            for key in self.cpu_dynamic_labels:
                label = self.builder.get_object(key)
                value = self.cpu_dynamic_labels.get(key)()
                label.set_text(f'\t{str(value)}')
        def gpu():
            for key in self.gpu_dynamic_labels:
                label = self.builder.get_object(key)
                value = self.gpu_dynamic_labels.get(key)()
                label.set_text(f'\t{str(value)}')
        while self.threads_run:
            self.gpu_dynamic_info = self.gpu_info()
            self.cpu_dynamic_info = self.cpu_info()
            self.cpu_dynamic_labels = {'cpu_clock_label':self.cpu_dynamic_info.clock, 'cpu_temp_label':self.cpu_dynamic_info.temperature, 'cpu_load_label':self.cpu_dynamic_info.load}
            self.gpu_dynamic_labels = {'gpu_vram_label':self.gpu_dynamic_info.vram_usage_total, 'gpu_clock_label':self.gpu_dynamic_info.clock, 'gpu_temp_label':self.gpu_dynamic_info.temperature, 'gpu_fspeed_label':self.gpu_dynamic_info.fan_speed_current, 'gpu_load_label':self.gpu_dynamic_info.load}
           
            cpu()
            gpu()
            time.sleep(1)

    def show_window(self):
        self.window.show()
        Gtk.main()
    def main(self):
        # self.FanUpdater_loop = threading.Thread(target=self.FanUpdater)
        # self.FanUpdater_loop.start()
        self.DynamicInfo_loop = threading.Thread(target=self.DynamicInfo)
        self.DynamicInfo_loop.start()
        self.MainWindow_poop = threading.Thread(target=self.show_window)
        self.MainWindow_poop.start()