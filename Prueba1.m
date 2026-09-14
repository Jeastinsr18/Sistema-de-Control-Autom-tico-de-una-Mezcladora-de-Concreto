clear;
clc;
close all;

%% Velocidad de referencia
rpm_ref = 30;
omega_ref = rpm_ref*(2*pi/60);   % rad/s

%% Aceleraciones angulares analizadas
alpha = [0.25, 0.50, 1.000];   % rad/s^2

%% Vector de tiempo
t = linspace(0, 50, 2000);

%% Figura
figure;
hold on;
grid on;
box on;

colores = lines(length(alpha));

for k = 1:length(alpha)

    % Aceleración constante con limitación en la referencia
    omega = min(alpha(k)*t, omega_ref);

    % Conversión de rad/s a rpm
    omega_rpm = omega*60/(2*pi);

    % Tiempo de alcance
    t_alcance = omega_ref/alpha(k);

    plot(t, omega_rpm, ...
        'LineWidth', 2, ...
        'Color', colores(k,:), ...
        'DisplayName', sprintf( ...
        '\\alpha = %.3f rad/s^2, t_a = %.2f s', ...
        alpha(k), t_alcance));
end

%% Referencia de velocidad
yline(rpm_ref, '--k', ...
    'Referencia: 10 rpm', ...
    'LineWidth', 1.8);

xlabel('Tiempo (s)');
ylabel('Velocidad angular (rpm)');
title('Alcance de 10 rpm para diferentes aceleraciones angulares');

legend('Location', 'southeast');
ylim([0 11]);
xlim([0 50]);

hold off;