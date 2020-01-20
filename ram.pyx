# cython: language_level=3, boundscheck=False   
import subprocess 
cdef class Ram():
    cpdef str capacity(self):
        ram_output = subprocess.getoutput(f"lsmem -o SIZE").splitlines()
        for line in ram_output:
            if 'Total online memory' in line:
                ram_capacity = line.replace('Total online memory:', '').strip().replace('G', '')
                return ram_capacity
        


    cpdef str modules_manufacturer(self):
        cdef list data 
        cdef str line
        cdef str temporary
        cdef set manufacturer
        manufacturer = set()
        data = subprocess.getoutput(f"sudo dmidecode --type memory").splitlines()
        for line in data:
            if 'Manufacturer: ' in line:
                temporary = line.split('Manufacturer: ')[1]
                manufacturer.add(temporary)
        manufacturer.discard('Not Specified')
        return (', '.join(manufacturer))
         
