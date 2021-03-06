addpath(genpath('~/GitHub/GBLM_SMOOTH/helper'));
addpath(genpath('~/GitHub/GBLM_SMOOTH/core'));

%%
clc;clear all;close all;

plotFolder = '~\GitHub\GBLM_SMOOTH\plot\miss\complete';
% plotFolder = '~\GitHub\GBLM_SMOOTH\plot\miss\b0Constant';
cd(plotFolder)

%%
Tpre = data.pre_spk_times;
Tpost = data.post_spk_times(:, 1);
data.vecN = length(data.pre_spk_vec);

lam = exp(fit.beta0 + fit.wt_long.*fit.wt_short.*fit.Xc +...
    fit.hist*fit.hist_beta)*data.dt;

%% pre-synaptic firing rate
firRate = figure;
plot(linspace(0,sim.T,sim.vecN),...
    filter(ones(2000,1),1,data.pre_spk_vec)/2, 'k', 'LineWidth', 1.5);
xlim([0 sim.T])
set(gca,'FontSize',15, 'LineWidth', 1.5,'TickDir','out')
box off

set(firRate,'PaperUnits','inches','PaperPosition',[0 0 5 3])
saveas(firRate, '1_firRate.svg')
saveas(firRate, '1_firRate.png')

%% overall cross-correlogram
[d,~] = corr_fast_v3(Tpre, Tpost,-.02,.02,102);
[d_fit, lag_fit] = xcorr(data.pre_spk_vec, lam, 20);

tvec = linspace(-0.02,0.02,102);
tvec = tvec+mean(diff(tvec))/2;

corrOverall = figure;
hold on
bar(tvec(1:end-1)*1e3,d(1:end-1),1,'k','EdgeColor','none');
plot(-lag_fit*data.dt*1e3, d_fit*mean(diff(tvec))/data.dt, 'r', 'LineWidth',3)
xlim([-.01 .02]*1e3);
ylim([0 300])
set(gca,'FontSize',15, 'LineWidth', 1.5,'TickDir','out')
box off
hold off

set(corrOverall,'PaperUnits','inches','PaperPosition',[0 0 4 3])
saveas(corrOverall, '2_corrOverall.svg')
saveas(corrOverall, '2_corrOverall.png')

%% baseline
baseLine = figure;
idx = 1:size(fit.beta0);
hold on
plot(idx, fit.beta0, 'r', 'LineWidth', 3)
plot(idx, sim.beta0, 'k', 'LineWidth', 3)
plot(idx, fit.beta0 + sqrt(squeeze(fit.W(1, 1, :))), 'r:', 'LineWidth', 2)
plot(idx, fit.beta0 - sqrt(squeeze(fit.W(1, 1, :))), 'r:', 'LineWidth', 2)
ylim([min(sim.beta0)-1 max(sim.beta0)+1])
xlim([0 sim.T/sim.dt])
xticks([0 2 4 6 8 10 12]*1e5)
xticklabels({'0','200','400','600','800','1000','1200'})
hold off
set(gca,'FontSize',15, 'LineWidth', 1.5,'TickDir','out')
box off

set(baseLine,'PaperUnits','inches','PaperPosition',[0 0 5 3])
saveas(baseLine, '3_baseLine.svg')
saveas(baseLine, '3_baseLine.png')

%% LTP
ltp = figure;
idx = 1:size(fit.beta0);
hold on
plot(idx, fit.wt_long, 'r', 'LineWidth', 3)
plot(idx, sim.wt_long, 'k', 'LineWidth', 3)
plot(idx, fit.wt_long + sqrt(squeeze(fit.W(2, 2, :))), 'r:', 'LineWidth', 2)
plot(idx, fit.wt_long - sqrt(squeeze(fit.W(2, 2, :))), 'r:', 'LineWidth', 2)
ylim([min(sim.wt_long)-4 max(sim.wt_long)+4])
xlim([0 sim.T/sim.dt])
xticks([0 2 4 6 8 10 12]*1e5)
xticklabels({'0','200','400','600','800','1000','1200'})
hold off
set(gca,'FontSize',15, 'LineWidth', 1.5,'TickDir','out')
box off

set(ltp,'PaperUnits','inches','PaperPosition',[0 0 5 3])
saveas(ltp, '4_ltp.svg')
saveas(ltp, '4_ltp.png')

%% STP
se_wt_short = zeros(size(fit.stp_X, 1), 1);
for k = 1:size(fit.stp_X, 1)
    se_wt_short(k) = sqrt(fit.stp_X(k,:)*fit.covB*(fit.stp_X(k,:))');
end

stp = figure;
hold on
plot(idx, 1 + sim.stp_X*sim.stp_B, 'k', 'LineWidth', 3)
plot(idx, fit.wt_short, 'r', 'LineWidth', 2)
plot(idx, fit.wt_short + se_wt_short, 'r:', 'LineWidth', 2)
plot(idx, fit.wt_short - se_wt_short, 'r:', 'LineWidth', 2)
hold off
ylim([-1, 2])
xlim([0 sim.T/sim.dt])
xticks([0 2 4 6 8 10 12]*1e5)
xticklabels({'0','200','400','600','800','1000','1200'})
hold off
set(gca,'FontSize',15, 'LineWidth', 1.5,'TickDir','out')
box off

set(stp,'PaperUnits','inches','PaperPosition',[0 0 5 3])
saveas(stp, '5_stp.svg')
saveas(stp, '5_stp.png')

















