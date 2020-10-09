function data = dataLoad()
    addpath("data")
%data = readmatrix('.\data\no_backflow.csv'); 
rawData = load('Simulation_data_1.mat');
rawData = [rawData.ans.Time, rawData.ans.Data];
rawData = rawData(200:size(rawData(:,1))-200,:);
data = [rawData(:,1), zeros(size(rawData(:,1))), rawData(:,5:8), rawData(:,2), rawData(:,10)-rawData(1,10), rawData(:,3)];
