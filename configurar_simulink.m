%% CONFIGURAR_SIMULINK Prepara una copia portable con controlador P.
% Conserva PlantaIdealSinCemento.slx y genera PlantaControlP.slx.

clearvars;
clc;

P = parametros_mezcladora();
assignin('base','P',P);
carpeta_sim = fileparts(mfilename('fullpath'));
carpeta_raiz = fileparts(carpeta_sim);
modelo_origen = fullfile(carpeta_sim,'PlantaIdealSinCemento.slx');
modelo_nuevo = fullfile(carpeta_sim,'PlantaControlP.slx');
archivo_step = fullfile(carpeta_raiz,'CAD','Tolva.STEP');

assert(isfile(modelo_origen),'No se encontro %s.',modelo_origen);
assert(isfile(archivo_step),'No se encontro %s.',archivo_step);

copyfile(modelo_origen,modelo_nuevo,'f');
load_system(modelo_nuevo);
[~,nombre_modelo] = fileparts(modelo_nuevo);

% El archivo original guarda una ruta absoluta de Windows.
set_param([nombre_modelo '/File Solid'],'ExtGeomFileName',archivo_step);

% Referencia en rad/s. El bloque posterior la convierte a rpm para el error.
set_param([nombre_modelo '/w Referencia'],'Value','P.omega_ref');

% Control proporcional puro: sin integrador y sin derivativo.
bloque_control = [nombre_modelo '/PID Controller'];
set_param(bloque_control,'Controller','P','P','P.Kp_rpm','I','0','D','0');

% Limites físicos de torque del accionamiento.
set_param([nombre_modelo '/Saturation'], ...
    'UpperLimit','P.T_max','LowerLimit','P.T_min');

save_system(nombre_modelo,modelo_nuevo);
open_system(nombre_modelo);

fprintf('Modelo configurado: %s\n',modelo_nuevo);
fprintf('Referencia: %.2f rpm | Controlador P: Kp = %.3f N*m/rpm\n', ...
    P.rpm_ref,P.Kp_rpm);
