# Conexiones del control de velocidad

## Lazo principal

1. **Referencia:** `w Referencia` entrega la consigna en rad/s.
2. **Conversión:** `Referencia` convierte la consigna a rpm.
3. **Comparador:** `Sum` calcula `referencia - velocidad_real`.
4. **Controlador:** `PID Controller` se configura como controlador **P puro**.
5. **Saturación:** limita el torque entre `T_min` y `T_max`.
6. **Suma de torques:** `Sum1` resta al torque del motor la perturbación.
7. **Conversión física:** `Simulink-PS Converter` convierte el torque a señal
   física en N·m.
8. **Planta:** el torque actúa sobre `Revolute Joint` y hace girar la tolva.
9. **Sensor:** el puerto de velocidad del joint alimenta `w real`.
10. **Realimentación:** `Real w` convierte rad/s a rpm y regresa la medición al
    terminal negativo del comparador.

## Perturbación

`Mezcla1`, `Mezcla2` y `Simulacion Rocas` se suman en `Sum2`. La señal resultante
representa un torque resistente variable y entra con signo negativo en `Sum1`.

## Punto crítico de unidades

La referencia y la velocidad real deben llegar al comparador en la misma unidad.
En el modelo ambas se convierten a rpm antes de calcular el error. El torque del
controlador se expresa en N·m y el sensor de la articulación entrega rad/s antes
de la conversión. Por eso el script usa `P.Kp_rpm`; es la conversión de la
ganancia definida originalmente por unidad de rad/s.

## Uso recomendado

Ejecute `configurar_simulink.m`. El script corrige la ruta absoluta del archivo
`Tolva.STEP`, cambia el bloque PI original a P puro, aplica la referencia definida
en `parametros_mezcladora.m` y crea `PlantaControlP.slx` sin modificar el modelo
original.

## Limitación del controlador P

Ante un torque constante, un controlador P puro normalmente conserva un error
estacionario. Aumentar `Kp` reduce el error, pero también eleva el esfuerzo del
actuador y puede producir oscilación o saturación. La compensación `T_ff` del
modelo matemático ayuda con la carga nominal; las variaciones desconocidas aún
producen un error pequeño. Esta característica debe mostrarse como parte del
análisis, no ocultarse.
