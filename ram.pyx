import subprocess 
cdef class Ram():
    cpdef str ram_capacity(self):
        cdef str ram_size
        cdef str ram_capacity
        ram_size = subprocess.getoutput(f"sudo lsmem | grep -F 'Total online memory'")
        ram_capacity = ram_size.split(':')[1].strip().replace('G', '')
        return ram_capacity

    cpdef str ram_sticks_manufacturer(self):
        cdef list ram_manufacturer
        cdef list temporary
        cdef str element
        ram_manufacturer = subprocess.getoutput(f"sudo dmidecode --type memory | grep 'Manufacturer'").splitlines() # gets the manufacturer and splits the lines into a list
        for element in ram_manufacturer:
            if 'Not Specified' not in element:
                element = element.split(':')[1].strip()
                temporary.append(element)
        ram_manufacturer = temporary
        return ram_manufacturer[0] # returns a list of manufacturers that made the ram sticks that u have connected on your motherboard
