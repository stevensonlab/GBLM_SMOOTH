addpath(genpath('D:/cleanTemp/helper'));
addpath(genpath('D:/cleanTemp/core'));

%%
clc;clear all;close all;
load('F:\COVID-19\updateResults\caseResults\2_depression_constant.mat');

%% diagnose (informal)
paramPlot(fit.beta0, squeeze(fit.W(1, 1, :)), sim.beta0,...
    fit.wt_long, squeeze(fit.W(2, 2, :)),...
    sim.wt_long, fit.wt_short, 1 + sim.stp_X*sim.stp_B,...
    fit.covB, fit.stp_X)

modPlot(sim, fit)
%% calculate lambda

Tpre = data.pre_spk_times;
Tpost = data.post_spk_times(:, 1);

lam = exp(fit.beta0 + fit.wt_long.*fit.wt_short.*fit.Xc +...
    fit.hist*fit.hist_beta)*dt;

%% pre and post firing rate
firRate = figure(1);
hold on
plot(filter(ones(2000,1),1,data.pre_spk_vec)/2, 'b');
plot(filter(ones(2000,1),1,data.post_spk_vec)/2, 'k');
plot(filter(ones(2000,1),1,lam)/2, 'r');
hold off
legend('pre', 'post', 'post-fit')
ylabel('Firing Rates')

saveas(firRate, 'firRate.svg')

%% Overall Cross Correlogram
[d,~] = corr_fast_v3(Tpre, Tpost,-.02,.02,40);
[d_fit, lag_fit] = xcorr(data.pre_spk_vec, lam, 20);


corrOverall = figure(2);
hold on
bar(linspace(-.02,.02,40),d,'k');
plot(-lag_fit*data.dt, d_fit, 'r', 'LineWidth',2)
xlim([-.01 .02]);
title('Overall Cross Correlogram')
xlabel('s')
ylabel('Count')
legend('data', 'fitted results')
hold off

saveas(corrOverall, 'overallCorr.svg')

%% show STP
isi = diff(find(data.pre_spk_vec>0)*data.dt);
isiQ1 = prctile(isi,25);
isiQ2 = prctile(isi,50); 
isiQ3 = prctile(isi,75);

TpreISI1 = Tpre(find(isi<isiQ1)+1);
TpreISI2 = Tpre(find(isi >= isiQ1 & isi<isiQ2)+1);
TpreISI3 = Tpre(find(isi >= isiQ2 & isi<isiQ3)+1);
TpreISI4 = Tpre(find(isi >= isiQ3)+1);

TpreISI1_spk_vec = zeros(1,sim.vecN);TpreISI1_spk_vec(round(TpreISI1/data.dt))=1;
TpreISI2_spk_vec = zeros(1,sim.vecN);TpreISI2_spk_vec(round(TpreISI2/data.dt))=1;
TpreISI3_spk_vec = zeros(1,sim.vecN);TpreISI3_spk_vec(round(TpreISI3/data.dt))=1;
TpreISI4_spk_vec = zeros(1,sim.vecN);TpreISI4_spk_vec(round(TpreISI4/data.dt))=1;


[dISI1,~] = corr_fast_v3(TpreISI1, Tpost,-.02,.02,40);
[dISI2,~] = corr_fast_v3(TpreISI2, Tpost,-.02,.02,40);
[dISI3,~] = corr_fast_v3(TpreISI3, Tpost,-.02,.02,40);
[dISI4,~] = corr_fast_v3(TpreISI4, Tpost,-.02,.02,40);

[dISI1_fit, lagISI1_fit] = xcorr(TpreISI1_spk_vec, lam, 20);
[dISI2_fit, lagISI2_fit] = xcorr(TpreISI2_spk_vec, lam, 20);
[dISI3_fit, lagISI3_fit] = xcorr(TpreISI3_spk_vec, lam, 20);
[dISI4_fit, lagISI4_fit] = xcorr(TpreISI4_spk_vec, lam, 20);


yULim = ceil(max([dISI1; dISI2; dISI3; dISI4])/25)*25;
% subplot(1,4,1)
corrISI_Q01 = figure(3);
hold on
bar(linspace(-.02,.02,40),dISI1,'k');
plot(-lagISI1_fit*data.dt, dISI1_fit, 'r', 'LineWidth',2)
title('Correlogram for < Q_1 of ISI')
xlim([-.01,.02]);ylim([0, yULim]);
xlabel('s')
ylabel('Count')
hold off

saveas(corrISI_Q01, 'corrISI_Q01.svg')

% subplot(1,4,2)
corrISI_Q12 = figure(4);
hold on
bar(linspace(-.02,.02,40),dISI2,'k');
plot(-lagISI2_fit*data.dt, dISI2_fit, 'r', 'LineWidth',2)
title('Correlogram for Q_1 to Q_2 of ISI')
xlim([-.01,.02]);ylim([0, yULim]);
xlabel('s')
ylabel('Count')
hold off

saveas(corrISI_Q12, 'corrISI_Q12.svg')

% subplot(1,4,3)
corrISI_Q23 = figure(5);
hold on
bar(linspace(-.02,.02,40),dISI3,'k');
plot(-lagISI3_fit*data.dt, dISI3_fit, 'r', 'LineWidth',2)
title('Correlogram for Q_2 to Q_3 of ISI')
xlim([-.01,.02]);ylim([0, yULim]);
xlabel('s')
ylabel('Count')
hold off

saveas(corrISI_Q23, 'corrISI_Q23.svg')

% subplot(1,4,4)
corrISI_Q34 = figure(6);
hold on
bar(linspace(-.02,.02,40),dISI4,'k');
plot(-lagISI4_fit*data.dt, dISI4_fit, 'r', 'LineWidth',2)
title('Correlogram for > Q_3 of ISI')
xlim([-.01,.02]);ylim([0, yULim]);
xlabel('s')
ylabel('Count')
hold off

saveas(corrISI_Q34, 'corrISI_Q34.svg')


%% show LTP

Tpre1 = Tpre(Tpre<(0.25*sim.T));
Tpre2 = Tpre(Tpre >= (0.25*sim.T) & Tpre<(0.5*sim.T));
Tpre3 = Tpre(Tpre >= (0.5*sim.T) & Tpre<(0.75*sim.T));
Tpre4 = Tpre(Tpre >= (0.75*sim.T));

Tpre1_spk_vec = zeros(1,sim.vecN);Tpre1_spk_vec(round(Tpre1/data.dt))=1;
Tpre2_spk_vec = zeros(1,sim.vecN);Tpre2_spk_vec(round(Tpre2/data.dt))=1;
Tpre3_spk_vec = zeros(1,sim.vecN);Tpre3_spk_vec(round(Tpre3/data.dt))=1;
Tpre4_spk_vec = zeros(1,sim.vecN);Tpre4_spk_vec(round(Tpre4/data.dt))=1;


[d1,~] = corr_fast_v3(Tpre1, Tpost,-.02,.02,40);
[d2,~] = corr_fast_v3(Tpre2, Tpost,-.02,.02,40);
[d3,~] = corr_fast_v3(Tpre3, Tpost,-.02,.02,40);
[d4,~] = corr_fast_v3(Tpre4, Tpost,-.02,.02,40);

[d1_fit, lag1_fit] = xcorr(Tpre1_spk_vec, lam, 20);
[d2_fit, lag2_fit] = xcorr(Tpre2_spk_vec, lam, 20);
[d3_fit, lag3_fit] = xcorr(Tpre3_spk_vec, lam, 20);
[d4_fit, lag4_fit] = xcorr(Tpre4_spk_vec, lam, 20);


yULim = ceil(max([d1; d2; d3; d4])/25)*25;
% subplot(1,4,1)

corrT_Q01 = figure(7);
hold on
bar(linspace(-.02,.02,40),d1,'k');
plot(-lag1_fit*data.dt, d1_fit, 'r', 'LineWidth',2)
title('Correlogram for <Q_1 of T')
xlim([-.01,.02]);ylim([0, yULim]);
xlabel('s')
ylabel('Count')
hold off

saveas(corrT_Q01, 'corrT_Q01.svg')

% subplot(1,4,2)

corrT_Q12 = figure(8);
hold on
bar(linspace(-.02,.02,40),d2,'k');
plot(-lag2_fit*data.dt, d2_fit, 'r', 'LineWidth',2)
title('Correlogram for Q_1 to Q_2 of T')
xlim([-.01,.02]);ylim([0, yULim]);
xlabel('s')
ylabel('Count')
hold off

saveas(corrT_Q12, 'corrT_Q12.svg')

% subplot(1,4,3)

corrT_Q23 = figure(9);
hold on
bar(linspace(-.02,.02,40),d3,'k');
plot(-lag3_fit*data.dt, d3_fit, 'r', 'LineWidth',2)
title('Correlogram for Q_2 to Q_3 of T')
xlim([-.01,.02]);ylim([0, yULim]);
xlabel('s')
ylabel('Count')
hold off

saveas(corrT_Q23, 'corrT_Q23.svg')

% subplot(1,4,4)

corrT_Q34 = figure(10);
hold on
bar(linspace(-.02,.02,40),d4,'k');
plot(-lag4_fit*data.dt, d4_fit, 'r', 'LineWidth',2)
title('Correlogram for > Q_3 of T')
xlim([-.01,.02]);ylim([0, yULim]);
xlabel('s')
ylabel('Count')
hold off

saveas(corrT_Q34, 'corrT_Q34.svg')
