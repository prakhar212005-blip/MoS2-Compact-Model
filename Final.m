clear; clc; close all;

q = 1.602e-19;
kB = 1.38e-23;
T = 300;
const.Vth = kB * T / q;

eps_0 = 8.854e-12;
C_Al2O3 = eps_0 * 9 / 1.7e-9;
C_HfO2 = eps_0 * 22 / 5.9e-9;
const.Ct = (1/C_Al2O3 + 1/C_HfO2)^-1;

const.Cdq = 0.05;
const.V_norm = 1.1;
const.V_min = 0.25;
const.V_error = 0.08;

dev(1).L = 500e-9;
dev(1).W = 1e-6;
dev(1).mu = 185 * 1e-4;
dev(1).Vg0 = -1.75;
dev(1).alpha = 4.2;
dev(1).vsat = 1.55e4;
dev(1).nu = 1.45;
dev(1).m = 7.4;
dev(1).lambda = 0.003;
dev(1).dibl = 0.0;

dev(2).L = 200e-9;
dev(2).W = 1e-6;
dev(2).mu = 185 * 1e-4;
dev(2).Vg0 = -1.85;
dev(2).alpha = 4.3;
dev(2).vsat = 2.5e4;
dev(2).nu = 1.65;
dev(2).m = 2.5;
dev(2).lambda = 0.001;
dev(2).dibl = 0.0;

dev(3).L = 60e-9;
dev(3).W = 1e-6;
dev(3).mu = 43.5 * 1e-4;
dev(3).Vg0 = -2.4;
dev(3).alpha = 5.3;
dev(3).vsat = 2.0e4;
dev(3).nu = 1.3;
dev(3).m = 1.4;
dev(3).lambda = -0.035;
dev(3).dibl = 0.2;

Vds_sweep = linspace(0, 2.5, 100);

Vds_steps{1} = [0.05, 0.2, 0.6, 1.0];
Vds_steps{2} = [0.1, 0.4, 0.6, 0.8];
Vds_steps{3} = [0.1, 0.4, 0.6, 1.0];

Vgs_steps{1} = [0.1, 0.4, 0.6, 1.0];
Vgs_steps{2} = [0.1, 0.4, 0.8, 1.2];
Vgs_steps{3} = [0.1, 0.4, 0.8, 1.0];

fig_lin = figure('Name', 'Linear Transfer Characteristics (Ids vs Vgs)', 'Position', [100, 100, 1200, 400]);
fig_log = figure('Name', 'Log Transfer Characteristics (Ids vs Vgs)', 'Position', [150, 150, 1200, 400]);
fig_gm  = figure('Name', 'Transconductance (gm vs Vgs)', 'Position', [200, 200, 1200, 400]);
fig_out = figure('Name', 'Output Characteristics (Ids vs Vds)', 'Position', [250, 250, 1200, 400]);

for i = 1:3
    p = dev(i);
    
    if i == 3
        Vgs_sweep = linspace(-4.5, 1.0, 500);
    else
        Vgs_sweep = linspace(-3.5, 1.5, 500);
    end
    
    for j = 1:length(Vds_steps{i})
        Vd_val = Vds_steps{i}(j);
        Ids_trans = zeros(size(Vgs_sweep));
        
        for k = 1:length(Vgs_sweep)
            Ids_trans(k) = calc_Ids(Vgs_sweep(k), Vd_val, p, const);
        end
        
        gm = gradient(Ids_trans) ./ gradient(Vgs_sweep);
        
        figure(fig_lin); subplot(1, 3, i); hold on; grid on;
        plot(Vgs_sweep, Ids_trans, 'LineWidth', 2, 'DisplayName', sprintf('Vds = %.2g V', Vd_val));
        
        figure(fig_log); subplot(1, 3, i);
        semilogy(Vgs_sweep, Ids_trans, 'LineWidth', 2, 'DisplayName', sprintf('Vds = %.2g V', Vd_val));
        hold on; grid on;
        
        figure(fig_gm); subplot(1, 3, i); hold on; grid on;
        plot(Vgs_sweep, gm, 'LineWidth', 2, 'DisplayName', sprintf('Vds = %.2g V', Vd_val));
    end
    
    figure(fig_lin); subplot(1, 3, i);
    xlabel('V_{gs} (V)'); ylabel('I_{ds} (A)'); legend('Location', 'northwest');
    if i == 1, xlim([-3.5 1.5]); ylim([0 1.4e-5]); title('L = 500 nm'); end
    if i == 2, xlim([-3.5 1.5]); ylim([0 2.2e-5]); title('L = 200 nm'); end
    if i == 3, xlim([-4.5 1.0]); ylim([0 1.4e-5]); title('L = 60 nm'); end
    
    figure(fig_log); subplot(1, 3, i);
    set(gca, 'YScale', 'log');
    xlabel('V_{gs} (V)'); ylabel('I_{ds} (A)'); legend('Location', 'southeast');
    if i == 1, xlim([-3.5 1.5]); ylim([1e-14 1e-4]); title('L = 500 nm'); end
    if i == 2, xlim([-3.5 1.5]); ylim([1e-12 1e-4]); title('L = 200 nm'); end
    if i == 3, xlim([-4.5 1.0]); ylim([1e-12 1e-4]); title('L = 60 nm'); end
    
    figure(fig_gm); subplot(1, 3, i);
    xlabel('V_{gs} (V)'); ylabel('g_m (S)'); legend('Location', 'northwest');
    if i == 1, xlim([-3.5 1.5]); ylim([0 5.0e-6]); title('L = 500 nm'); end
    if i == 2, xlim([-3.5 1.5]); ylim([0 9.0e-6]); title('L = 200 nm'); end
    if i == 3, xlim([-4.5 1.0]); ylim([0 4.5e-6]); title('L = 60 nm'); end
    
    for j = 1:length(Vgs_steps{i})
        Vg_val = Vgs_steps{i}(j);
        Ids_out = zeros(size(Vds_sweep));
        
        for k = 1:length(Vds_sweep)
            Ids_out(k) = calc_Ids(Vg_val, Vds_sweep(k), p, const);
        end
        
        figure(fig_out); subplot(1, 3, i); hold on; grid on;
        plot(Vds_sweep, Ids_out, 'LineWidth', 2, 'DisplayName', sprintf('Vgs = %.2g V', Vg_val));
    end
    
    figure(fig_out); subplot(1, 3, i);
    xlabel('V_{ds} (V)'); ylabel('I_{ds} (A)'); legend('Location', 'southeast');
    if i == 1, xlim([0 2.5]); ylim([0 1.4e-5]); title('L = 500 nm'); end
    if i == 2, xlim([0 2.5]); ylim([0 2.6e-5]); title('L = 200 nm'); end
    if i == 3, xlim([0 2.0]); ylim([0 1.8e-5]); title('L = 60 nm'); end
end

function Ids = calc_Ids(Vg, Vds, p, c)
    Vov = calc_Vov(Vg, p.Vg0, Vds, p.dibl, c.V_min, c.V_error);
    mueff = calc_mueff(p.mu, Vov, p.nu, c.V_norm);
    
    Vds_sat = calc_Vds_sat(Vov, p.vsat, p.L, mueff);
    Vds_eff = calc_Vds_eff(Vds, Vds_sat, p.m);
    
    Qs = calc_Q(Vg, p.Vg0, p.alpha, Vds, 0, p.dibl, c.Ct, c.Vth, c.Cdq);
    Qd = calc_Q(Vg, p.Vg0, p.alpha, Vds, Vds_eff, p.dibl, c.Ct, c.Vth, c.Cdq);
    
    I_charge_term = (Qs.^2 - Qd.^2) ./ (2 * c.Ct) + c.Vth .* (Qs - Qd);
    
    Esat_L = (p.vsat ./ mueff) .* p.L;
    vel_sat_factor = 1 ./ (1 + Vds_eff ./ Esat_L);
    
    clm_factor = (1 + p.lambda .* Vds);
    
    Ids_raw = (p.W .* mueff ./ p.L) .* I_charge_term .* vel_sat_factor .* clm_factor;
    Ids = max(Ids_raw, 1e-20);
end

function Q = calc_Q(Vg, Vg0, alpha, Vds, Vx, DIBL, Ct, Vth, Cdq)
    arg = (Vg - Vg0 + DIBL .* Vds - Vx) ./ (alpha * Vth);
    arg = min(arg, 700);
    Q = Ct * Vth * real(lambertw((Cdq / Ct) * exp(arg)));
end

function Vov = calc_Vov(Vg, Vg0, Vds, DIBL, V_min, V_error)
    V_shift = Vg - (Vg0 - DIBL .* Vds);
    Vov = (V_min / 2) .* ((1 + V_shift ./ V_min) + sqrt(V_error^2 + (V_shift ./ V_min - 1).^2));
end

function mueff = calc_mueff(mu, Vov, nu, V_norm)
    mueff = mu ./ (1 + (Vov ./ V_norm).^nu);
end

function Vds_sat = calc_Vds_sat(Vov, vsat, L, mueff)
    vel_term = 2 * vsat * L ./ mueff;
    raw_sat = (Vov .* vel_term) ./ (Vov + vel_term);
    Vds_sat = sqrt(raw_sat.^2 + (1e-3)^2);
end

function Vds_eff = calc_Vds_eff(Vds, Vds_sat, m)
    Vds_eff = Vds ./ ((1 + (Vds ./ Vds_sat).^m).^(1/m));
end