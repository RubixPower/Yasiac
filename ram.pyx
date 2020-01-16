import subprocess 
cdef class Ram():
    cpdef str ram_capacity(self):
        ram_output = subprocess.getoutput(f"lsmem -o SIZE").splitlines()
        for line in ram_output:
            if 'Total online memory' in line:
                ram_capacity = line.replace('Total online memory:', '').strip().replace('G', '')
                return ram_capacity
        


    cpdef str ram_sticks_manufacturer(self):
        cdef list data 
        cdef str line
        cdef str temporary
        cdef list manufacturer_list
        cdef list manufacturer
        manufacturer_list = []
        data = subprocess.getoutput(f"sudo dmidecode --type memory").splitlines()
        for line in data:
            if 'Manufacturer: ' in line:
                temporary = line.split('Manufacturer: ')[1]
                manufacturer_list.append(temporary)
        manufacturer = list(set(manufacturer_list))
        manufacturer.remove('Not Specified')
        return (', '.join(manufacturer))
         
