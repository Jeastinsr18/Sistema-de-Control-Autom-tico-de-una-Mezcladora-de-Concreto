clear;
clc;
close all;

%% Tolva vacia
Jd = 27.48;                 % kg*m^2

%% Geometria interior
Ri = 0.39;                  % m
L  = 0.80;                  % m
VT = pi*Ri^2*L;             % m^3

%% Concreto
rho_h = 2400;               % kg/m^3
llenado = 0.25;             % 0.25, 0.50, 0.75 o 1.00
mh = rho_h*llenado*VT;

%% Inercia aproximada del concreto
etaJ = 1.0;                 % Caso conservador
Jh = etaJ*0.5*mh*Ri^2;

%% Inercia equivalente
Jeq = Jd + Jh;

%% Parametros provisionales de friccion
bf = 0.10;                  % Friccion mecanica viscosa [N*m*s/rad]
bh = 0.50;                  % Efecto viscoso del concreto [N*m*s/rad]
tauC = 0.20;                % Friccion seca [N*m]
tauY = 1.00;                % Torque de fluencia equivalente [N*m]

Beq = bf + bh;
T0 = tauC + tauY;

%% Velocidad de operacion
rpm_ref = 30;
omega0 = rpm_ref*2*pi/60;

%% Torque gravitacional
g = 9.81;
rc = 0.05;                  % Posicion aproximada del centro de masa
delta = deg2rad(10);        % Desfase del material
inclinacion = deg2rad(45);

tauG = mh*g*rc*cos(inclinacion)*sin(delta);

%% Torque necesario en 30 rpm
tau_operacion = Beq*omega0 + T0 + tauG;

%% Planta linealizada
G = tf(1,[Jeq Beq]);

disp('Planta linealizada:')
G

fprintf('Volumen interno: %.3f m^3\n',VT);
fprintf('Masa de concreto: %.2f kg\n',mh);
fprintf('Inercia de la tolva: %.2f kg*m^2\n',Jd);
fprintf('Inercia del concreto: %.2f kg*m^2\n',Jh);
fprintf('Inercia equivalente: %.2f kg*m^2\n',Jeq);
fprintf('Torque gravitacional: %.2f N*m\n',tauG);
fprintf('Torque para mantener 30 rpm: %.2f N*m\n', ...
        tau_operacion);