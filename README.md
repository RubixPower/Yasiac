# Yasiac                                                                                                                                                           
Yet Another System Info And Control app                                                                                                                            
A simple app that lets you get some system info and control gpu fan/s                                                                                              
                                                                                                                                                                   
How to download the files:                                                                                                                                         
    You should be able to download the files by:                                                                                                                   
    1. Downloading the ZIP file and extracting it wherever you want it.                                                                                            
    2. Navigating to the folder of your liking and executing ```git clone  https://github.com/RubixPower/Yasiac.git``` in the terminal.                            
                                                                                                                                                                   
Build instructions:                                                                                                                                                
    YOu can build the .pyx files by navigating to apps root folder and executing ```python3 setup.py  build_ext --inplace && mv ./*.so ./compiled/ && rm *.c```.   
                                                                                                                                                                   
How to run the app:                                                                                                                                                
    Before you run: execute ```sensors-detect``` and for every choice select ``y`` so it detects everything.                                                       
    Navigate to apps root folder after building process and executing ```sudo python app.py```.                                                                    
                                                                                                                                                                   
Dependencies:                                                                                                                                                      
1. Packages:                                                                                                                                                       
    >python3                                                                                                                                                       
    >glxinfo or mesa-demos                                                                                                                                         
    >lm-sensors                                                                                                                                                    
    >cython                                                                                                                                                        
    >rocm-smi                                                                                                                                                      
2. Python packages/modules:                                                                                                                                        
>python-psutil