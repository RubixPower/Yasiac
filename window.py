#!/usr/bin/env python3
import control as cntrl
import os
import threading
import time
import gi
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

    # Control Stack
    def fan_scale_mode(self, *args):
        status = self.window.check_btn_status()
        if status:
            self.window.control_scale.set_sensitive(False)
        else:
            self.window.control_scale.set_sensitive(True)

    def apply(self, *args):
        btn_status = self.window.cntrl_check_button.get_active()
        if btn_status:
            self.control.amd_fan_speed_mode_change('auto')
        else:
            adjustment_value = self.window.control_gpu_adjustment.get_value()
            self.control.amd_fan_speed_mode_change('manual')
            self.control.amd_fan_speed_change(int(adjustment_value * 2.55))

    def reset(self, *args):
        if self.control.amd_fan_speed_mode_current() == 'auto':
            self.window.cntrl_check_button.set_active(True)
            self.window.control_scale.set_sensitive(False)
        else:
            self.window.cntrl_check_button.set_active(False)
            fan_speed = self.control.amd_fan_speed_current()
            self.window.control_gpu_adjustment.set_value(
                round(fan_speed / 2.55))


class Window:
    __slots__ = (
        "path", "builder",
        "control", "window",
        "cpu_info", "gpu_info",
        "cntrl_check_button", "control_scale", "control_gpu_adjustment",
        "threads_run",
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
        self.cntrl_check_button = self.builder.get_object('GpuCheckButton')
        self.control_scale = self.builder.get_object('GpuFanScale')
        self.control_gpu_adjustment = self.builder.get_object(
            'GpuFanAdjustment')
        self.threads_run = True
        self.control_init()

    #  LABELS
    def update_labels(self, dictionary):
        for element in dictionary:
            label = self.builder.get_object(element)
            value = dictionary.get(element)()
            label.set_text(f'\t{str(value)}')

    #  CONTROL stack
    def check_btn_status(self):
        status = self.cntrl_check_button.get_active()
        return status

    def control_init(self):
        mode = self.control.amd_fan_speed_mode_current()
        if mode == 'auto':
            self.cntrl_check_button.set_active(True)
            self.control_scale.set_sensitive(False)
        else:
            self.cntrl_check_button.set_active(False)
            self.control_scale.set_sensitive(True)
            self.control_scale.set_value(
                self.control.amd_fan_speed_current() / 2.55
                )

    def fan_updater(self):
        # updates the fan adjustment value when check box not activated
        while self.threads_run:
            time.sleep(1)
            if self.cntrl_check_button.get_active():
                fan_speed = self.control.amd_fan_speed_current()
                self.control_gpu_adjustment.set_value(fan_speed / 2.55)
            else:
                pass

    # INFO stack
    def dynamic_info(self):
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

    def show_window(self):
        self.window.show_all()
        Gtk.main()

    def main(self):
        threading.Thread(target=self.fan_updater).start()
        threading.Thread(target=self.dynamic_info).start()
        threading.Thread(target=self.show_window).start()
