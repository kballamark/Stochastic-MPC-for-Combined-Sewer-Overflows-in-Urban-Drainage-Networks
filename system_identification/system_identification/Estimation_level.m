clear all; 
close all;
clear path;
clc; 
%% ================================================ Load Data ================================================
rawData = dataLoad()';                                                      % Load simulation data 
%rawData = readmatrix('.\data\no_backflow.csv')'; 
startDataIndex = 1; 
endDataIndex = size(rawData,2);
%% ================================================ Prepare Data =============================================


N_sensors = 4;                                                                   % Select section number, i.e. pick number of level sensor data
Nx = N_sensors + 1;                                                              % Number of states +1 -> tank 2
h(1:N_sensors,:) = rawData(3:1:6,startDataIndex:endDataIndex)/1000;

Q(1,:) = rawData(9,startDataIndex:endDataIndex)/(1000);                              % Select in/outflows
Q(2,:) = rawData(7,startDataIndex:endDataIndex)/(1000);                              % Pump_2 flow

T2 = rawData(8,startDataIndex:endDataIndex)/1000;                                  % Select tanks

%% ============================================ Idata object ================================================ 
dataTimeStep = 1;                                                          % Time step size in seconds

input = [Q(1,:)' Q(2,:)'];
output = [h(1:1:end,:); T2]';

ioData = iddata(output,input,dataTimeStep);                                % (y,u,Ts) (order)

ioData.TimeUnit = 'minutes';

%% ===================================================== Model ============================================

modelName = 'free_flow_model';
Ts_model = 0;                                                              % 0 - continuous model, 1,2,.. - discrete model 
order = [size(output,2) size(input,2) Nx];                                 % [Ny Nu Nx] (order)

parametersInitial = [4.2895    0.1106    0.1133   -0.0001    0.0513    0.5970];                                      % select initial parameters

systemParamaters = [parametersInitial, Nx];

initStates = 0.0001*ones(Nx, 1);                                           % assume no flow at t0

sys_init = idnlgrey(modelName, order, systemParamaters, initStates, Ts_model);       % create nlgreyest object
sys_init.TimeUnit = 'minutes';
sys_init.Parameters(1).Name = 'p1';
sys_init.Parameters(2).Name = 'p2';
sys_init.Parameters(3).Name = 'p3';
sys_init.Parameters(4).Name = 'p4';
sys_init.Parameters(5).Name = 'p5';
sys_init.Parameters(6).Name = 'p6';
sys_init.Parameters(7).Name = 'Nx';
sys_init.Parameters(7).Fixed = true;                                       % number of sections fixed
size(sys_init);

sys_init.SimulationOptions.AbsTol = 1e-10;
sys_init.SimulationOptions.RelTol = 1e-8;

sys_init.SimulationOptions.Solver = 'ode4';                                % 4th order Runge-Kutte solver - fixed-step size                 

% Model Constarints 
% sys_init.Parameters(1).Minimum = 0.001;     sys_init.Parameters(1).Maximum = 0.5;   
% sys_init.Parameters(2).Minimum = 0.001;     sys_init.Parameters(2).Maximum = 10000;
% sys_init.Parameters(3).Minimum = 0.001;     sys_init.Parameters(3).Maximum = 0.6;
% sys_init.Parameters(4).Minimum = 0.001;     sys_init.Parameters(4).Maximum = 6;
% sys_init.Parameters(5).Minimum = 0.001;     sys_init.Parameters(5).Maximum = 2;
for i = 1:Nx
sys_init.InitialStates(i).Minimum = 0.000001;                             
end


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


