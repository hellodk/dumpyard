class DemoClass:
    '''
    Demo Class Definition
    '''

    def __init__(self, file_name, data):
        '''
        Init method
        '''
        self.file_name = file_name
        self.data = data

    def write(self):
        with open(self.file_name, mode='w', encoding='utf-8') as f:
            f.write(self.data)
        return "Data is written"


data = 'Success\n'
object_x = DemoClass('/tmp/demo_file.txt', data)
object_x.write()
