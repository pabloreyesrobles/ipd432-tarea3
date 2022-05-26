# IPD-432: Tarea 3

## Integrantes
- Mauricio Aravena Cifuentes
- Pablo Reyes Robles

## Proyectos de Vivado
- **coprocessor_fully_comb**: implementación del adder_tree compuesto de solo lógica combinacional.
- **coprocessor_pipelined**: implementación del adder_tree con *flip-flop* entre sus etapas.

## Ejecución de scripts de Python
Es necesario indicar el puerto serial asociado como argumento del llamado a coprocessorTesting.py

```
python coprocessorTesting.py -port=COMx -trials N
```

**Nota: El argumento `-trials` indica el numero de pruebas a realizar, por defecto, sino se pasa este argumento se realiza una prueba**


Los resultados de las operaciones vectoriales y de Manhattan han sido truncadas a 8 bits, por tanto se evalúan los bits menos significativos de cada una de las operaciones.
