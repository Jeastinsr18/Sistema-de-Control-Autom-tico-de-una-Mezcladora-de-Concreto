clear;
clc;
close all;

%% Parametros
J = 27.48;
K = 2;

%% Funciones de transferencia
Hr = tf(K,[J K]);
Hd = tf(-1,[J K]);

disp('Planta:')
G = tf(1,[J 0])

disp('Referencia -> velocidad:')
Hr

disp('Perturbacion -> velocidad:')
Hd

%% Tiempo
t = 0:0.01:180;

%% Referencia de 30 rpm
rpm_ref = 30;
omega_ref = rpm_ref*2*pi/60;

referencia = omega_ref*ones(size(t));

%% Perturbacion
perturbacion = zeros(size(t));

perturbacion(t >= 80 & t < 130) = 0.7;
perturbacion(t >= 130) = 0.3;

%% Respuesta provocada por la referencia
omega_referencia = lsim(Hr,referencia,t);

%% Respuesta provocada por la perturbacion
omega_perturbacion = lsim(Hd,perturbacion,t);

%% Respuesta total
omega = omega_referencia + omega_perturbacion;

%% Conversion a rpm
omega_rpm = omega*60/(2*pi);

%% Torque aplicado por la retroalimentacion
error = referencia(:)-omega;
torque_aplicado = K*error;

%% Graficas
figure('Color','w');

subplot(2,1,1);

plot(t,omega_rpm,'b','LineWidth',2);
hold on;

yline(rpm_ref,'--r','Referencia: 30 rpm', ...
    'LineWidth',1.5);

xline(80,':k','Entra perturbación');
xline(130,':k','Cambia perturbación');

grid on;
box on;

xlabel('Tiempo (s)');
ylabel('Velocidad (rpm)');
title('Respuesta del sistema retroalimentado');

subplot(2,1,2);

plot(t,torque_aplicado,'b','LineWidth',2);
hold on;

plot(t,perturbacion,'--r','LineWidth',1.8);

grid on;
box on;

xlabel('Tiempo (s)');
ylabel('Torque (N·m)');
title('Torque aplicado y perturbación');

legend('Torque aplicado','Torque perturbador', ...
       'Location','best');