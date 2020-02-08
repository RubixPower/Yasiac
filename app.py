import subprocess
try:
    from compiled import cpu, gpu, ram
    import window
except ModuleNotFoundError:
    subprocess.run("notify-send --urgency=normal --app-name=Yasiac Yasiac 'You need to compile .pyx files'", shell=True)
app = window.Window
app(cpu.Cpu, gpu.Gpu, ram.Ram).main()