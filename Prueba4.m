clear;
clc;
close all;

%% ================================================================
%  1. GEOMETRIA DE LA TOLVA
% ================================================================

Ri = 0.39;                  % Radio interior [m]
L  = 0.80;                  % Longitud [m]
f  = 0.75;                  % Fraccion de llenado

VT = pi*Ri^2*L;             % Volumen total [m^3]
Vh = f*VT;                  % Volumen de concreto [m^3]

%% ================================================================
%  2. PROPIEDADES DEL CONCRETO
% ================================================================

rho_h = 2400;               % Densidad [kg/m^3]
tau_y = 150;                % Esfuerzo de fluencia [Pa]
mu_p  = 50;                 % Viscosidad plastica [Pa*s]
hs    = 0.15;               % Longitud de corte equivalente [m]

mh = rho_h*Vh;

%% ================================================================
%  3. MOMENTOS DE INERCIA
% ================================================================

Jd = 27.48;                 % Tolva vacia con tapa [kg*m^2]

etaJ = 0.65;                % Acoplamiento intermedio
Jh_rigido = 0.5*mh*Ri^2;
Jh = etaJ*Jh_rigido;

Jeq = Jd + Jh;

%% ================================================================
%  4. TORQUE RESISTENTE DEL CONCRETO
% ================================================================

Ty = f*2*pi*L*Ri^2*tau_y;

Bh = f*2*pi*mu_p*L*Ri^3/hs;

Bf = 1.0;                   % Friccion viscosa mecanica
Beq = Bh + Bf;

epsilon = 0.02;             % Suavizado del modelo Bingham

%% ================================================================
%  5. REFERENCIA
% ================================================================

rpm_ref = 30;
omega_ref = rpm_ref*2*pi/60;

T0 = Beq*omega_ref + Ty;

%% ================================================================
%  6. FUNCIONES DE TRANSFERENCIA
% ================================================================

Gp_vacia = tf(1,[Jd Bf]);

Gp_cargada = tf(1,[Jeq Beq]);

Gd_cargada = tf(-1,[Jeq Beq]);

K = 150;

Hr = tf(K,[Jeq Beq+K]);
Hd = tf(-1,[Jeq Beq+K]);

disp('Planta de la tolva vacia:')
Gp_vacia

disp('Planta linealizada con 75 % de concreto:')
Gp_cargada

disp('Perturbacion hacia velocidad:')
Gd_cargada

disp('Sistema retroalimentado:')
Hr

disp('Perturbacion con retroalimentacion:')
Hd

%% ================================================================
%  7. RESULTADOS NUMERICOS
% ================================================================

fprintf('\nVolumen total         = %.4f m^3\n',VT);
fprintf('Volumen de concreto   = %.4f m^3\n',Vh);
fprintf('Masa de concreto      = %.2f kg\n',mh);
fprintf('Inercia de concreto   = %.2f kg*m^2\n',Jh);
fprintf('Inercia equivalente   = %.2f kg*m^2\n',Jeq);
fprintf('Torque de fluencia    = %.2f N*m\n',Ty);
fprintf('Coeficiente viscoso   = %.2f N*m*s/rad\n',Beq);
fprintf('Torque en 30 rpm      = %.2f N*m\n',T0);

%% ================================================================
%  8. SIMULACION LINEAL: VACIA VS CARGADA
% ================================================================

t1 = 0:0.01:8;
deltaTorque = 50;           % Escalon incremental de torque [N*m]

y_vacia = deltaTorque*step(Gp_vacia,t1);
y_cargada = deltaTorque*step(Gp_cargada,t1);

figure('Color','w');

plot(t1,y_vacia*60/(2*pi), ...
    'LineWidth',2);

hold on;

plot(t1,y_cargada*60/(2*pi), ...
    'LineWidth',2);

grid on;
box on;

xlabel('Tiempo (s)');
ylabel('Cambio de velocidad (rpm)');
title('Respuesta incremental ante 50 N·m');

legend('Tolva vacía', ...
       'Tolva con 75 % de concreto', ...
       'Location','best');

%% ================================================================
%  9. SIMULACION NO LINEAL CON RETROALIMENTACION
% ================================================================

dt = 0.001;
t_final = 50;
t = 0:dt:t_final;
N = length(t);

omega = zeros(1,N);
error = zeros(1,N);

Tm = zeros(1,N);
TL = zeros(1,N);

% Torque maximo disponible en el modelo ideal
Tmax = 450;

for k = 1:N-1

    % Perturbaciones adicionales
    if t(k) < 20
        TL(k) = 0;

    elseif t(k) < 32
        TL(k) = 50;

    elseif t(k) < 42
        TL(k) = 100;

    else
        TL(k) = 25;
    end

    % Error retroalimentado
    error(k) = omega_ref-omega(k);

    % Torque base mas correccion proporcional
    T_solicitado = T0 + K*error(k);

    % Saturacion del torque
    Tm(k) = max(min(T_solicitado,Tmax),0);

    % Torque Bingham
    T_bingham = ...
        Ty*tanh(omega(k)/epsilon) ...
        + Beq*omega(k);

    % Ecuacion diferencial no lineal
    domega = ...
        (Tm(k)-T_bingham-TL(k))/Jeq;

    % Integracion por Euler
    omega(k+1) = omega(k)+domega*dt;
end

TL(end) = TL(end-1);
Tm(end) = Tm(end-1);
error(end) = omega_ref-omega(end);

omega_rpm = omega*60/(2*pi);

%% ================================================================
%  10. GRAFICAS
% ================================================================

figure('Color','w');

subplot(3,1,1);

plot(t,omega_rpm,'b','LineWidth',2);
hold on;

yline(rpm_ref,'--r','Referencia: 30 rpm', ...
    'LineWidth',1.5);

xline(20,':k','50 N·m');
xline(32,':k','100 N·m');
xline(42,':k','25 N·m');

grid on;
box on;

xlabel('Tiempo (s)');
ylabel('Velocidad (rpm)');
title('Velocidad con 75 % de concreto');

subplot(3,1,2);

plot(t,Tm,'b','LineWidth',2);
hold on;

plot(t,TL,'--r','LineWidth',1.8);
yline(T0,':k','Torque nominal');

grid on;
box on;

xlabel('Tiempo (s)');
ylabel('Torque (N·m)');
title('Torque aplicado y perturbador');

legend('Torque aplicado', ...
       'Perturbación', ...
       'Location','best');

subplot(3,1,3);

plot(t,error*60/(2*pi), ...
    'm','LineWidth',2);

hold on;
yline(0,'--k');

grid on;
box on;

xlabel('Tiempo (s)');
ylabel('Error (rpm)');
title('Error de velocidad');