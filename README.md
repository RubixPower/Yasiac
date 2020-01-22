# Yasiac
Yet Another System Info And Control app                                                                                         
A simple app that lets you get some system info and control gpu fan/s                                                                                                                                                                                                                                                                                                       

## Getting Started
**How to get a copy of this project ?**                                                                                       
>By executing ```git clone  https://github.com/RubixPower/Yasiac.git``` in the terminal.                                                                                       
**How to run this app ?**                                                                                                       
>At the current state of the app you can execute/run it with just doing ```sudo python app.py```.
**Dependencies**
>Python3                                                                                                                                                                                                                                                                                                                                                                                                                        
>glxinfo                                                                                                                                                                                                                                                                                                                                                                                                                        
>sensors 
##  Build instructions
**root folder = Yasiac**
1. Make a folder named `compiled`in the apps root folder. 
2. Execute ``python3 setup.py  build_ext --inplace && mv ./*.so ./compiled/ && rm *.c`` in the apps root folder. 


*A huge thanks to openglfreak for the help and info about python programming*
