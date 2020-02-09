import subprocess
try:
    from compiled import cpu, gpu, ram
    from window import Window
    app = Window
    app(cpu.Cpu, gpu.Gpu, ram.Ram).main()

except (ModuleNotFoundError, ImportError) as error:
    subprocess.Popen("notify-send --urgency=normal --app-name=Yasiac Yasiac 'You need to compile .pyx files'", shell=True)
    print(error)
    

