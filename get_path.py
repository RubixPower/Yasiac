import os


class FileData:
    def __init__(self):
        self.cpu_path = ''
        self.gpu_path = ''
        self.get_path()

    def get_path(self):
        path = '/sys/class/hwmon/'
        for dirs in os.listdir(path):
            current_path = os.path.join(path, dirs)
            with open(os.path.join(current_path, 'name')) as FileObj:
                name_file_data = FileObj.read().strip()
            if name_file_data == 'coretemp':
                self.cpu_path = current_path
            elif name_file_data == 'amdgpu':
                self.gpu_path = current_path
