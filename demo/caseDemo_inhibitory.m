addpath(genpath('C:/Users/gaw19004/Desktop/ganchaoResearch/GBLM_SMOOTH-master/helper'));
addpath(genpath('C:/Users/gaw19004/Desktop/ganchaoResearch/GBLM_SMOOTH-master/core'));

%% set up true parameters
clc;clear all;close all;
T = 20*60;
dt = 0.001;
Q = diag([1e-5 1e-5]);

trueParam = [0 0 3 2 1]'*(-0.03);
beta0 = ones(1, T/dt)'*6;

wt_long = [repmat(-8, 1, round(T/(dt*2))) repmat(-4, 1, T/dt - round(T/(dt*2)))]';


sim.seed = 123;
sim.T = T;
sim.dt = dt;
sim.vecN = round(sim.T/sim.dt);
sim.pPreSpike = 15*sim.dt;
sim.alpha_dt = 0.004;
sim.alpha_tau = 0.001;
sim.stp_Nq = 5;
sim.stp_Nm = 450;
sim.stp_Ns = 50;
sim.stp_tau= 1;
sim.stp_B = trueParam;
sim.hist_tau = .005;
sim.hist_beta = -1;

sim.beta0 = beta0;
sim.wt_long = wt_long;
data.dt = sim.dt;
[data,sim] = sim_model(data,sim);
%%
[fit,~] = smooth_gblm(data.pre_spk_vec, data.post_spk_vec,...
    'iter',10, 'hist_tau', sim.hist_tau, 'hist_beta', sim.hist_beta);

save('inhibitory_depression.mat')

