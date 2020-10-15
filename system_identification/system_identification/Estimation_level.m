clear all; 
close all;
clear path;
clc; 

%% ================================================ Load Data ================================================
data = dataLoad('epa_swmm_data_0.mat');                                    % Load simulation data 
startDataIndex = 1; 
endDataIndex = size(data,2);
%% ================================================ Prepare Data =============================================
N_sensors = 4;                                                             % Select section number, i.e. pick number of level sensor data

N_states = N_sensors + 1;                                                  % Number of states +1 -> tank 2
h(1:N_sensors,:) = uConv(data(3:1:6,startDataIndex:endDataIndex), []);
%output = [h(1:1:end,:); T2]';

Q(1,:) = uConv(data(9,startDataIndex:endDataIndex), []);                   % Select in/outflows
Q(2,:) = uConv(data(10,startDataIndex:endDataIndex), []); 
input = [Q(1,:)' Q(2,:)'];

if ~isnan(data(7,:))
    Q(3,:) = uConv(data(7,startDataIndex:endDataIndex), []);               % Pump_2 flow
    input = [input Q(3,:)'];
end

T1 = uConv(data(2,startDataIndex:endDataIndex), []);                       % Select tanks
T2 = uConv(data(8,startDataIndex:endDataIndex), []);                       

tank_area = data(11,1);
phi_2 = 1/tank_area;

%% ============================================ Idata object ================================================ 
dataTimeStep = 1;                                                          % Time step size in seconds

output = [h(1:1:end,:); T2]';

ioData = iddata(output,input,dataTimeStep);                                % (y,u,Ts) (order)

ioData.TimeUnit = 'minutes';

%% ===================================================== Model ============================================

modelName = 'free_flow_model';
Ts_model = 0;                                                              % 0 - continuous model, 1,2,.. - discrete model 
order = [size(output,2) size(input,2) N_states];                                 % [Ny Nu Nx] (order)

parametersInitial = [0.0171    0.7898    0.8335   -2.7316    0.0192    1.5835]*10e-4;                                      % select initial parameters

systemParamaters = [parametersInitial, N_states];

initStates = 0.0001*ones(N_states, 1);                                           % assume no flow at t0

sys_init = idnlgrey(modelName, order, systemParamaters, initStates, Ts_model);       % create nlgreyest object
sys_init.TimeUnit = 'minutes';
sys_init.Parameters(1).Name = 'p1';
sys_init.Parameters(2).Name = 'p2';
sys_init.Parameters(3).Name = 'p3';
sys_init.Parameters(4).Name = 'p4';
sys_init.Parameters(5).Name = 'p5';
sys_init.Parameters(6).Name = 'theta_2';
%sys_init.Parameters(6).Fixed = true;
sys_init.Parameters(7).Name = 'Nx';
sys_init.Parameters(7).Fixed = true;                                       % number of sections fixed
size(sys_init);

sys_init = setinit(sys_init, 'Fixed', false(N_states,1));

sys_init.SimulationOptions.AbsTol = 1e-10;
sys_init.SimulationOptions.RelTol = 1e-8;

sys_init.SimulationOptions.Solver = 'ode4';                                % 4th order Runge-Kutte solver - fixed-step size                 


%% ============================================= Solver options ============================================

opt = nlgreyestOptions;
%Search methods: 'gn' | 'gna' | 'lm' | 'grad' | 'lsqnonlin' | 'auto'
opt.SearchMethod = 'gna'; 
opt.Display = 'on';
opt.SearchOption.MaxIter = 150;
opt.SearchOption.Tolerance = 1e-15;

%% =============================================== Estimation =============================================
tic 
sys_final = nlgreyest(ioData,sys_init, opt)                                           % Parameter estimation START

fprintf('\n\nThe search termination condition:\n')
sys_final.Report.Termination

estParams = [sys_final.Parameters(1).Value...
             sys_final.Parameters(2).Value,...
             sys_final.Parameters(3).Value...
             sys_final.Parameters(4).Value...
             sys_final.Parameters(5).Value...
             sys_final.Parameters(6).Value];

finalStates = sys_final.Report.Parameters.X0;                                       % estimated initial states
toc

%% ========================================== Simulate model =============================================
opt_init = simOptions('InitialCondition',initStates);                               % Simulate model on training data with initial parameters
y_init = sim(sys_init,ioData,opt_init);

opt_final = simOptions('InitialCondition',finalStates);                             % Simulate model on training data with estimated parameters
y_final = sim(sys_final,ioData,opt_final);

%% ========================================== Post - process ============================================
estParams
EstPlotter;

%% Save params
p_grav_Nx4 = estParams;
save('data\p_grav_Nx4','p_grav_Nx4')


