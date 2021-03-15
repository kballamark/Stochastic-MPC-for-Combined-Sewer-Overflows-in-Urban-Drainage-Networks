function [output]  = SMPC_full_DW(X0,time)
% define persistent variables
eml.extrinsic('evalin');
persistent x_init;
persistent lam_g;
persistent OCP;
persistent Hp;
persistent warmStartEnabler;
persistent D_sim;
persistent X_ref;
persistent U0;
persistent sigma_x
% and others
dT = 10;           % Sample time in minutes
simulink_frequency = 2;  % Sampling frequency in seconds
% init persistent variables

if isempty(lam_g)
    lam_g = 1;
    x_init = 0.001;
    % get optimization problem and warmStartEnabler
    OCP = evalin('base','OCP');
    Hp = evalin('base','Hp');
    D_sim = evalin('base','D_sim');
    X_ref = evalin('base','X_ref_sim');
    warmStartEnabler = evalin('base','warmStartEnabler');
    U0 = [3;4.5];
    D_sim = D_sim(1:2:3,:);
    
    % Precompute sigma_X for chance constraint
    sigma_D = 0.0065^2; 
    sigma_x = zeros(nS,Hp);
    sigma_x(:,1) = sigma_D; 
    for i = 1:Hp-1
        sigma_x(:,i+1) = sigma_x(:,i) + sigma_D;
    end
end


%Create forcast from disturbance reference
time = int64(round(time));
disturbance = zeros(2,Hp);
for i=0:1:Hp-1
    start_index = time+1+i*dT*simulink_frequency;
    end_index = start_index+dT*simulink_frequency-1;
    disturbance(:,i+1) = mean(D_sim(:,start_index:end_index),2)/60;
end

X0 = X0/100;                                                               % Unit convertion from mm to dm
reference = [X_ref(1,time+1), 0, 0, 0, 0, X_ref(2,time+1)]';

% run openloop MPC
if warmStartEnabler == 1
    % Parametrized Open Loop Control problem with WARM START
    [u , S, S_ub, lam_g, x_init] = (OCP(X0,U0,disturbance, lam_g, x_init, dT,reference,sigma_x));
elseif warmStartEnabler == 0
    % Parametrized Open Loop Control problem without WARM START 
    [u , S, S_ub] = (OCP(X0,U0, disturbance, dT, reference,sigma_x));
end


u_full = full(u);
S_full = full(S);
S_ub_full = full(S_ub);

output = [u_full(:,1); S_full(:,1)]*60;
output = [output; X_ref(:,time+1)*100; S_ub_full(:,1)];
U0 = u_full(:,1);
end
