# Yasiac
Yet Another System Info And Control app
A simple app that lets you get some system info and control gpu fan/s

## Getting Started
**root folder = Yasiac**
**How to get a copy of this project ?**
>By executing ```git clone  https://github.com/RubixPower/Yasiac.git``` in the terminal.

**How to run this app ?**
>At the current state of the app you can run it by executing ```sudo python app.py``` in apps root folder

**Dependencies**
>Python3
>Glxinfo
>lm-sensors
>Cython (build only)
>rocm-smi
>dmidecode
##  Build instructions
1. Make a folder named `compiled`in the apps root folder.
2. Execute ``python3 setup.py  build_ext --inplace && mv ./*.so ./compiled/ && rm *.c`` in the apps root folder.
