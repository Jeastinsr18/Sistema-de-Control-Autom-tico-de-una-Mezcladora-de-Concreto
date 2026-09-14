# Control automático de velocidad de una mezcladora de cemento

Proyecto académico para modelar y simular el control de velocidad angular de una
mezcladora de cemento. La variable controlada es la velocidad del tambor y la
consigna es una velocidad de referencia configurable, `rpm_ref`.

El repositorio conserva el modelo CAD y el modelo original de Simscape
Multibody. Además, incorpora una simulación matemática reproducible de un
controlador proporcional (P) con realimentación unitaria y perturbaciones de
carga variables.

## Objetivo

Mantener la velocidad del tambor cerca de una referencia aunque el torque
resistente cambie debido al movimiento del concreto, impactos de agregados y
variaciones de carga.

La dinámica rotacional empleada es

```text
Jeq*d(omega)/dt = Tm - Ty*tanh(omega/epsilon) - Beq*omega - Td
```

donde `Tm` es el torque del motor, `Td` es la perturbación, `Jeq` es la inercia
equivalente, `Beq` representa el efecto viscoso y `Ty` aproxima el torque de
fluencia del concreto mediante un modelo de Bingham suavizado.

El controlador más sencillo utilizado es

```text
error = omega_ref - omega
Tm = saturacion(Tff + Kp*error)
```

`Tff` compensa el torque resistente nominal. El término `Kp*error` corrige las
desviaciones. No se utiliza acción integral ni derivativa.

## Estructura

```text
CAD/                          Archivos de SolidWorks y geometría STEP
SIMULACIONES/
  PlantaIdealSinCemento.slx   Modelo original de Simscape Multibody
  parametros_mezcladora.m     Parámetros centralizados
  simulacion_control_P.m      Simulación principal sin depender de Simulink
  configurar_simulink.m       Configura el SLX con controlador P y rutas relativas
  Prueba1.m ... Prueba4.m     Ensayos previos conservados
docs/
  CONEXIONES_SIMULINK.md      Explicación del lazo y conexiones
```

## Requisitos

- MATLAB R2025b o una versión compatible.
- Simulink.
- Simscape y Simscape Multibody para ejecutar el archivo `.slx`.
- Control System Toolbox solamente para los ensayos que usan `tf`, `step` o
  `lsim`. La simulación principal `simulacion_control_P.m` no la necesita.

## Inicio rápido

1. Clone o descargue el repositorio.
2. Abra MATLAB en la carpeta raíz del proyecto.
3. Ejecute:

```matlab
cd SIMULACIONES
resultados = simulacion_control_P;
```

Para preparar el modelo de Simulink con rutas portables y control P:

```matlab
configurar_simulink
```

El script crea `PlantaControlP.slx` y mantiene intacto el modelo original.

## Cambio de referencia

Edite `rpm_ref` en `parametros_mezcladora.m`. Por defecto se usan 30 rpm:

```matlab
P.rpm_ref = 30;
```

## Parámetros y alcance del modelo

Los parámetros del concreto y algunos coeficientes de carga son valores de
simulación, no resultados de identificación experimental. Antes de construir el
controlador físico deben medirse o validarse `Jeq`, `Beq`, `Ty`, el torque máximo
del accionamiento y la relación de transmisión.

La simulación no sustituye las protecciones eléctricas, el diseño del variador de
frecuencia ni el análisis de seguridad de una mezcladora real.

## Autor

Jeastin Soto Ramírez — Ingeniería Mecatrónica.
