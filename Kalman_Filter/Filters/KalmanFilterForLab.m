function [EstimatedX,ErrorCo,KalmanGain] = KalmanFilterForLab(SystemMeas,PrevEstimatedX,PrevErrorCo,ControlInput)
%KALMANFILTERFORLAB is a Kalman filter for the AAU Smart Water Lab setup

%System Parameters
    DeltaT = 0.5;
%     p = [0.0367815377915250,0.0546308635442870,-0.00685599772690400,...
%         -0.00209121684418000,0.0365705383994410,0.203718327157626];
    p = [0.0348661973172381,0.0548687811513346,0.000100000000000000,...
        -0.00169231647536930,0.0342193052314381,0.203718327157626];
    phi = [1,1/4.908738521234052];
%     variance = [0.0194912514154121,0.0155729250526782,...
%                 0.0134318977059966,0.0182591773612488,0.438651709317892]'.^2;
    variance_model =[0.00139888812206957,0.000797324354867475,0.000322187764180357,0.000534989387547297,0.032914576421211]'.^2;
%     variance_meas = [0.826888663787374,0.808307645981179,0.782347907960311,0.544902200314622,0.826888663787374]'.^2;
    variance_meas = [0.0078234790960307,0.00826888663787373,0.0001]'.^2;
    Qm = diag(variance_model);       %Covariance of model noise
    Rm = diag(variance_meas);       %Covariance of messurment noise
    
%System Model
NumberOfStates = 5;
A = BuildA(NumberOfStates,p,phi,DeltaT);
B = BuildB(NumberOfStates,p,phi,DeltaT);
Delta = BuildDelta(NumberOfStates,p,DeltaT);
C = zeros(NumberOfStates-2,NumberOfStates);
C(1,2) = 1;
C(2,4) = 1;
C(3,5) = 1;

%Prediction Step
    PredictedX = A * PrevEstimatedX + B * ControlInput  + B_d *  + Delta;
    PredictedP = A * PrevErrorCo * A' + Qm;
    
%Compute KalmanGain
    KalmanGain = PredictedP * C' /(C * PredictedP * C' + Rm);

%Compute EstimatedX
    EstimatedX = PredictedX + KalmanGain * (SystemMeas - C * PredictedX);

%Compute ErrorCo
    ErrorCo = PredictedP - KalmanGain * C * PredictedP;
end

