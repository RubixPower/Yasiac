#!/usr/bin/env python3
import subprocess
import os

import gi
gi.require_version("Gtk", "3.0")
from gi.repository import Gtk, Gdk, GObject

from compiled import cpu, gpu, ram
import control

cdef class Handler():
    cdef dict __dict__
    def __init__(self):
        self.window = Window()
        self.gpu = gpu.Gpu()
        self.Control = control.Control()

    def on_destroy(self, *args):
        Gtk.main_quit()
        quit()
    ############################################
    # Load Stack
    def load_info(self, *args):
        def cpu():
            pass
        def gpu():
            pass
        def ram():
            pass
    
    ############################################
    # Control Stack
    def control_apply(self, *args):
        status = self.window.control_toggle_button_mode()
        cpdef int adjustment_value
        if status == True:
            self.Control.amd_fan_speed_mode_change('auto')
        else:
            adjustment_value = self.window.adjustment_value()
            self.Control.amd_fan_speed_mode_change('manual')
            self.Control.amd_fan_speed_change(float(adjustment_value) * 2.55)
        
    def GpuFanScaleMode(self, *args):
        status = self.window.control_toggle_button_mode()
        if status == False:
            self.window.ScaleSetSensitive(True)
        else:
            self.window.ScaleSetSensitive(False)

cdef class Window:
    cdef dict __dict__
    def __init__(self):
        self.path = ("{}/".format(os.path.dirname(os.path.abspath(__file__)))) # current directory path
        self.builder = Gtk.Builder()
        self.builder.add_from_file('{}ui.glade'.format(self.path)) # imports the .glade file
        self.builder.connect_signals(Handler(self)) # connect the event signals to MainHandler class
        self.window = self.builder.get_object('application_window')

        self.cpu = cpu.Cpu()
        self.gpu = gpu.Gpu()
        self.ram = ram.Ram()
        

        # Imports the css
        style_provider = Gtk.CssProvider()
        style_provider.load_from_path('{}style.css'.format(self.path))
        Gtk.StyleContext.add_provider_for_screen(
            Gdk.Screen.get_default(),
            style_provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        )
        # Info Stack
        #update the dynamic info

        # Control Stack
        self.Control = control.Control()
        self.GpuCheckBtn = self.builder.get_object('GpuCheckButton')
        self.GpuScale = self.build.get_object('GpuScale')
        self.GpuAdjustment = self.build.get_object('GpuFanAdjustment')

        # functions that need to be executed for the app
        self.GpuFanMode()
    # Only gets the information
    cpdef control_toggle_button_mode(self):
        return self.GpuCheckBtn.get_active()

    cpdef adjustment_value(self):
        return self.GpuAdjustment.get_value()

    # Edits/does something
    cdef ScaleSetSensitive(self, mode):
        # True or False
        self.GpuScale.set_sensitive(mode)


    cdef GpuFanMode(self):
        vendor = gpu.vendor()
        if vendor == 'amd':
            fan_status = self.Control.amd_fan_speed_status
            if fan_status == 'max':
                self.GpuCheckBtn.set_active(False)
                self.ScaleSetSensitive(True)
                self.GpuAdjustment.set_value(100)
            elif fan_status == 'manual':
                self.GpuCheckBtn.set_active(False)
                self.ScaleSetSensitive(True)
                self.GpuAdjustment.set_value(self.Control.amd_fan_speed_current())
            elif fan_status == 'auto':
                self.GpuCheckBtn.set_active(True)
                self.ScaleSetSensitive(False)
    cdef label_cpu_static(self):
        label_set = {'cpu_name_label':self.cpu_info.name, 'cpu_cores_threads_label':self.cpu_info.cores_threads}
        for element in self.label_set:
            label = self.builder.get_object(element)
            value = self.label_set.get(element)()
            label.set_text(f'\t{value}')


    cdef main(self):
        self.window.show_all()
        Gtk.main()