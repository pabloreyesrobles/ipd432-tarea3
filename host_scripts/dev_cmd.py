import numpy as np
import serial

# Se define un byte de control ctrl en el mensaje que indica la operación
# a realizar en la FPGA de forma:
# Bits:    7       6       5       4       3       2       1       0
#          X   |   X   |   X   | BRAMx |   X   |          CMD          |
# En caso de que no se opere sobre una BRAM específica la FPGA ignorará el
# bit 4 del byte de control

bram_map = {'BRAMA': 0, 
            'BRAMB': 1} 
cmd_map = {'writeVec':  1,
           'readVec':   2,
           'sumVec':    3,
           'avgVec':    4,
           'manDist':   5,
           'eucDist':   6}

def cmd_to_dev(cmd, bram=None, com=None):
  assert com != None, 'No COM port specified'
  ctrl = np.uint8(cmd_map[cmd])
  # En caso de que la operación sea de lectura de unas de las BRAM se debe
  # especificar cuál es el bloque objetivo
  if cmd == 'readVec':
    assert bram != None, 'No BRAMx provided'
    ctrl = ctrl | np.uint8((bram_map[bram] << 4))

  # Se define contexto de operación sobre puerto serial con timeout de 1 ms
  with serial.Serial(com, 115200, timeout=1) as ser:
    # Envío de comando de control
    ser.write(ctrl.tobytes())

    # Para este trabajo todas las operaciones han sido truncadas a 8 bits, es decir 
    # los 1024 bytes menos significativos de las sumas y promedios de cada elemento
    # de los vectores, y el byte menos significativo en el caso de Manhattan
    if cmd == 'readVec':
      data = ser.read(1024)
      return np.array(list(data))
    elif cmd == 'sumVec':
      data = np.array(list(ser.read(1024)), dtype=np.uint8)
      return data
    elif cmd == 'avgVec':
      data = np.array(list(ser.read(1024)), dtype=np.uint8)
      return data
    elif cmd == 'manDist':
      data = int.from_bytes(ser.read(1), byteorder='big')
      return data

# La función de escritura sobre una BRAM a diferencia de cmd_to_dev
# requiere de la especificación del bloque objetivo
def write_to_dev(vec_file, bram, com):
  # Se lee el contenido del vector y se fuerza que los elementos contenidos
  # sean variables enteras sin signo de 8 bits
  vec = np.load(vec_file).astype(np.uint8)

  cmd = cmd_map['writeVec']
  ctrl = cmd | (bram_map[bram] << 4)
  data = np.concatenate((np.array([ctrl], dtype=np.uint8), vec))

  # Se define contexto de operación sobre puerto serial con timeout de 1 ms
  with serial.Serial(com, 115200, timeout=1) as ser:
    # Envío de los 1024 bytes para escritura
    for d in data:
      ser.write(d.tobytes())
