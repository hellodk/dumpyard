file_name = "/home/dk/Desktop/machines.txt"


def parse_file(file):
    with open(file_name) as f:
        lines = f.read().splitlines()
    return lines


def test_port(lines, ports):
    '''
    This function takes a list of dns/servers as input and a list of
    ports and returns the if the ports are open of not
    '''
    machines = []
    status = {element, machines for element in ports}
    while():
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.settimeout(2)
        s.connect((host, port))
        s.close()



ports = [80, 22, 443]
parse_file(file_name)
