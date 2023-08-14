%%%%%%%%%%%%%%%%%%%%%%%%%%%% Traditional Projetion method %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% document description:
% 1. This file introduces generation of traditional projection patterns
% 2. Actual images captured by a camera are uploaded to "Data" folder.
% 3. See also "Method_Comparison.m"
% Symbol description and other definitions:
% 1. N denotes total number of phase-shifitng steps
% 2. k denotes k-th step of phase-shifting
% 3. Total number of projections is 120 in one exposure.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%% 1、Initialization
clc; clear; close all;
f = 1;                    % Number of stripes
N=3;
A=0.5;
B=0.5;                          
Height_img=500;  Width_img=600;
u=1:Width_img;

%%%%%%%%%%%% 2、Algorithm   
%%% 1) Information for setting the projection number of each pattern
Total_Projecion_number=120;                                % This value is equal to that of the proposed method for fairness 
fprintf("Projeciton number for each pattern: ");
fprintf("%d, ",Total_Projecion_number);
%%% 2) Information for setting the exposure time of camera
Resonant_frequency=1150;                                   % Resonant frequency of MEMS mirror
Projection_speed=Resonant_frequency*2;                     % Projection speed of MEMS projector (fps) 
Exposure_time=1/Projection_speed*Total_Projecion_number;   % Exposure time of camera
fprintf("\n Exposure time of camera: %d (ms) \n", Exposure_time*1000);
%%% 3) Generating projection patterns loaded by MEMS projector
for k=1:1:N
    figure('name',['k=',num2str(k)]);
    %%% The pattern projected by MEMS projector
    phi_k=2*(k-1)*pi/N;                 % external phase-shifting
    absolute_phase=2*pi*f*u/Width_img;     % Absolute Phase
    I_k = A + B*cos(absolute_phase + phi_k - pi);
    subplot(2,1,1); plot(I_k); 
    title('Projection pattern');
    xlabel('Pixel position u');ylabel('Light intensity');
    %%% Image captured by camera
    % Note that acutal images are modulated by real objects and obtained by cameras in real world.
    % The actual captured images can be found in "Data" folder. 
    % The following I_k1 are non-modulated simulation images rather than actual images to conveniently show superimposition process.
    I_k=I_k*Total_Projecion_number;     % Here, I_k is a non-modulated simulation image just for show.
    subplot(2,1,2); plot(I_k/Total_Projecion_number); 
    title([num2str(k),'-th phase-shifting image obtained by camera (superimposition of above 1×120 patterns)']);
    xlabel('Pixel position u');ylabel('Gray');
end
