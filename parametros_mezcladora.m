function P = parametros_mezcladora()
%PARAMETROS_MEZCLADORA Parametros centrales del modelo de velocidad.
% Los valores identificados experimentalmente deben sustituir los marcados
% como parametros de simulacion antes de implementar el sistema fisico.

%% Geometria y carga
P.Ri = 0.39;                % Radio interior [m]
P.L = 0.80;                 % Longitud efectiva [m]
P.fraccion_llenado = 0.75; % 0 (vacia) a 1 (llena)
P.rho_concreto = 2400;     % Densidad aproximada [kg/m^3]
P.J_tolva = 27.48;         % Inercia de la tolva vacia [kg*m^2]
P.eta_J = 0.65;            % Fraccion de masa acoplada a la rotacion [-]

P.volumen_total = pi*P.Ri^2*P.L;
P.masa_concreto = P.rho_concreto*P.fraccion_llenado*P.volumen_total;
P.J_concreto = P.eta_J*0.5*P.masa_concreto*P.Ri^2;
P.J_eq = P.J_tolva + P.J_concreto;

%% Modelo resistente Bingham simplificado (parametros de simulacion)
P.tau_y = 150;              % Esfuerzo de fluencia [Pa]
P.mu_p = 50;                % Viscosidad plastica [Pa*s]
P.h_corte = 0.15;           % Longitud de corte equivalente [m]
P.B_mecanico = 1.0;         % Friccion viscosa mecanica [N*m*s/rad]
P.epsilon = 0.02;           % Suavizado de sign(omega) [rad/s]

P.T_y = P.fraccion_llenado*2*pi*P.L*P.Ri^2*P.tau_y;
P.B_concreto = P.fraccion_llenado*2*pi*P.mu_p*P.L*P.Ri^3/P.h_corte;
P.B_eq = P.B_mecanico + P.B_concreto;

%% Referencia y controlador proporcional
P.rpm_ref = 30;             % Referencia configurable [rpm]
P.omega_ref = P.rpm_ref*2*pi/60;
P.Kp = 23;                  % Ganancia proporcional [N*m/(rad/s)]
P.Kp_rpm = P.Kp*2*pi/60;    % Ganancia equivalente [N*m/rpm]
P.T_max = 450;              % Torque maximo del accionamiento [N*m]
P.T_min = 0;                % Torque minimo [N*m]

% Compensacion nominal. El lazo de realimentacion sigue siendo proporcional.
P.T_ff = P.T_y + P.B_eq*P.omega_ref;

%% Simulacion
P.dt = 1e-3;                % Paso de integracion [s]
P.t_final = 60;             % Duracion [s]
P.semilla = 7;              % Perturbacion aleatoria reproducible
end
