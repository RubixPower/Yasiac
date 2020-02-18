import os


class FileData:
    def __init__(self, id):
        self.id = id
        self.path = ''


def get_path(file_data, path):
    #cdef int counter
    counter = len(file_data)
    # gets the lenght of file_data dict and servers
    # as a counter for when to break the loop
    #cdef str root, dirs, files, data
    for root, dirs, files in os.walk(path):  # loops through folders and files
        for data in file_data:
            if file_data.get(data).id in files:
                if file_data.get(data).path != '':
                    print("ERROR: DUPLICATE FILE")
                else:
                    file_data.get(data).path = os.path.join(root, data)
                    counter -= 1
        if counter == 0:
            return file_data
