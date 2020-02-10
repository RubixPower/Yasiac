# Yasiac                                                                                                                                                           
Yet Another System Info And Control app                                                                                                                            
A simple app that lets you get some system info and control gpu fan/s                                                                                              
                                                                                                                                                                   
### How to download the files:
    1. Download the ZIP file and extract it wherever you want it.
    1. Navigate to the folder of your liking and execute:     git clone  https://github.com/RubixPower/Yasiac.git
       in the terminal.
### Build instructions:                                                                                                                                                
    You can build the .pyx files by navigating to apps root folder and executing: 
    python3 setup.py  build_ext --inplace && mv ./*.so ./compiled/ && rm *.c     int the terminal.   
                                                                                                                                                                   
### How to run the app:                                                                                                                                                
    Before you run: 
      1. Execute sensors-detect and for every choice select "Yes" so it detects everything.                                                       
      2. Navigate to apps root folder after building process and executing sudo python app.py     in the terminal.                                                                    
                                                                                                                                                                   
### Dependencies:                                                                                                                                              
1. Packages:                                                                                                                                                       
    >python3                                                                                                                                                       
    >glxinfo or mesa-demos                                                                                                                                         
    >lm-sensors                                                                                                                                                    
    >cython                                                                                                                                                        
    >rocm-smi                                                                                                                                                      
2. Python packages/modules:                                                                                                                                        
    >python-psutil
