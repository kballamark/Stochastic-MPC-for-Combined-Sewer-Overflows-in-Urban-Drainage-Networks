function [output]  = MPC_tank1(X0,time,disturbance_flow)
% define persistent variables
eml.extrinsic('evalin');
persistent x_init;
persistent lam_g;
persistent OCP;
persistent Hp;
persistent warmStartEnabler;
persistent log;

% and others
dT = 1/6;           % Sample time in minutes
simulink_frequency = 2;  % Sampling frequency in seconds
% init persistent variables

if isempty(lam_g)
    lam_g = 1;
    x_init = 0.01;
    Hp = 0;
    warmStartEnabler = 0;
    % get optimization problem and warmStartEnabler
    OCP = evalin('base','OCP');
    Hp = evalin('base','Hp');
    warmStartEnabler = evalin('base','warmStartEnabler');
end

time = int64(round(time));
disturbance = zeros(1,Hp);
for i=0:1:Hp-1
    start_index = time+1+i*dT*60*simulink_frequency;
    end_index = start_index+dT*60*simulink_frequency-1;
    disturbance(i+1) = mean(disturbance_flow(start_index:end_index));
end

% Unit convertion:

X0 = X0/100;
reference = 3;

% run openloop MPC
if warmStartEnabler == 1
    % Parametrized Open Loop Control problem with WARM START
    [u , S, lam_g, x_init] = (OCP(X0, D_sim(:,(i)*(20)-19:20:(i-1)*20 + (Hp)*20-19), lam_g, x_init, dT,reference));
elseif warmStartEnabler == 0
    % Parametrized Open Loop Control problem without WARM START 
    [u , S] = (OCP(X0, disturbance, dT,reference));
end


u_full = full(u);
S_full = full(S);
u = u_full(1);
S = S_full(1);

log = [u_full S_full]';
output = [u;S;log];

%plot_simulink_mpc(u_full,S_full,X0,disturbance,Hp);


end
