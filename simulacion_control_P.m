function R = simulacion_control_P()
%SIMULACION_CONTROL_P Control P de velocidad con perturbacion fluctuante.
% Ejecuta una integracion explicita del modelo no lineal y grafica velocidad,
% torque y error. No requiere Control System Toolbox.

P = parametros_mezcladora();
rng(P.semilla);

t = 0:P.dt:P.t_final;
N = numel(t);
omega = zeros(1,N);
Tm = zeros(1,N);
Td = zeros(1,N);
error = zeros(1,N);

% Ruido de carga de baja frecuencia: ruido blanco filtrado por primer orden.
ruido = randn(1,N);
ruido_filtrado = zeros(1,N);
tau_ruido = 0.30;
a = P.dt/(tau_ruido + P.dt);
for k = 1:N-1
    ruido_filtrado(k+1) = ruido_filtrado(k) + ...
        a*(ruido(k)-ruido_filtrado(k));
end

% Perturbacion: oscilaciones por mezclado, impactos y cambio medio de carga.
Td = 24*sin(2*pi*0.15*t) + 16*sin(2*pi*0.45*t + pi/4) ...
    + 10*ruido_filtrado;
Td = Td + 35*(t >= 20 & t < 40) + 65*(t >= 40);
Td = max(Td,0);

for k = 1:N-1
    error(k) = P.omega_ref - omega(k);
    torque_solicitado = P.T_ff + P.Kp*error(k);
    Tm(k) = min(max(torque_solicitado,P.T_min),P.T_max);

    T_bingham = P.T_y*tanh(omega(k)/P.epsilon) ...
        + P.B_eq*omega(k);
    domega = (Tm(k)-T_bingham-Td(k))/P.J_eq;
    omega(k+1) = max(omega(k) + domega*P.dt,0);
end

error(end) = P.omega_ref-omega(end);
Tm(end) = Tm(end-1);

omega_rpm = omega*60/(2*pi);
error_rpm = error*60/(2*pi);

% Metricas después del arranque (t >= 10 s).
idx = t >= 10;
R.error_medio_abs_rpm = mean(abs(error_rpm(idx)));
R.error_max_abs_rpm = max(abs(error_rpm(idx)));
R.rpm_final = omega_rpm(end);
R.t = t;
R.omega_rpm = omega_rpm;
R.error_rpm = error_rpm;
R.torque_motor = Tm;
R.torque_perturbacion = Td;
R.parametros = P;

figure('Color','w','Name','Control P de la mezcladora');
tiledlayout(3,1,'TileSpacing','compact','Padding','compact');

nexttile;
plot(t,omega_rpm,'b','LineWidth',1.5); hold on;
yline(P.rpm_ref,'--r',sprintf('Referencia: %.1f rpm',P.rpm_ref), ...
    'LineWidth',1.2);
grid on; box on;
ylabel('Velocidad (rpm)');
title('Seguimiento de velocidad con realimentacion unitaria');

nexttile;
plot(t,Tm,'b','LineWidth',1.3); hold on;
plot(t,Td,'Color',[0.85 0.20 0.15],'LineWidth',1.0);
yline(P.T_ff,':k','Torque nominal');
grid on; box on;
ylabel('Torque (N*m)');
legend('Motor','Perturbacion','Location','best');

nexttile;
plot(t,error_rpm,'m','LineWidth',1.3); hold on;
yline(0,'--k');
grid on; box on;
xlabel('Tiempo (s)');
ylabel('Error (rpm)');

fprintf('\n--- Control P de velocidad ---\n');
fprintf('Referencia                 : %.2f rpm\n',P.rpm_ref);
fprintf('Inercia equivalente        : %.2f kg*m^2\n',P.J_eq);
fprintf('Ganancia proporcional Kp   : %.2f N*m/(rad/s)\n',P.Kp);
fprintf('Error medio absoluto       : %.3f rpm\n',R.error_medio_abs_rpm);
fprintf('Error maximo (desde 10 s)  : %.3f rpm\n',R.error_max_abs_rpm);
fprintf('Velocidad final            : %.3f rpm\n',R.rpm_final);
end

