%%%%%%%%%%%%%%%%%%%%%%%%%%%% Proposed Projetion method %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% document description:
% 1. This file introduces generation of proposed projection patterns
% 2. Actual images captured by a camera are uploaded to "Data" folder.
% 3. See also "Method_Comparison.m"
% Symbol description and other definitions:
% 1. N1 denotes total number of external phase-shifitng steps
% 2. k1 denotes k1-th step of external phase-shifting
% 3. N2 denotes total number of internal phase-shifitng steps
% 4. k2 denotes the k2-th step of internal phase-shifting
% 5. internal phase-shifting is used to generate the camera image
% 6. external phase-shifting used camera images to extrct wrapped phase
% 7. Total number of projections is 120 in one exposure.
% 8. Projeciton numbers of I_k1k2 are: 20,19,15,10,5,1,0,1,5,10,15,19, respectively;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%% 1、Initialization
clc; clear; close all;
f = 1;              % fringe number
N1=3;               % total number of external phase-shifitng steps
N2=12;              % total number of internal phase-shifitng steps
A=0.5;
B=0.5;                          
Height_img=500;  Width_img=600;
u=1:Width_img;

%%%%%%%%%%%% 2、Algorithm
%%% 1) Information for setting the projection number of each pattern
c = 10;                               % c denotes the scaling factor
k2=1:N2;            
Sk_ideal=c*(cos(2*(k2-1)*pi/N2)+1);   % Ideal projection number
Sk=round(Sk_ideal);                   % Actual projection number
fprintf("Projeciton number for 12 patterns: ");
fprintf("%d, ",Sk);
%%% 2) Information for setting the exposure time of camera
Resonant_frequency=1150;                                   % Resonant frequency of MEMS mirror
Projection_speed=Resonant_frequency*2;                     % Projection speed of MEMS projector (fps) 
Total_Projecion_number=sum(Sk);                            % Total projection number in one exposure
Exposure_time=1/Projection_speed*Total_Projecion_number;   % Exposure time of camera
fprintf("\n Exposure time of camera: %d (ms) \n", Exposure_time*1000);
%%% 3) Generating projection patterns loaded by MEMS projector
for k1=1:1:N1
    I_k1=0;
    figure('name',[' External k1=',num2str(k1)]);
    for k2=1:1:N2
        %%% 12 kinds of patterns projected by MEMS projector
        phi_k1=2*(k1-1)*pi/N1;                 % external phase-shifting
        phi_k2=2*(k2-1)*pi/N2;                 % internal phase-shifting
        absolute_phase=2*pi*f*u/Width_img;     % Absolute Phase
        I_k1k2 = A + B*cos(absolute_phase + phi_k1 + phi_k2 - pi); %
        subplot(4,4,k2); plot(I_k1k2); 
        title(['Internal ',num2str(k2),'-th phase-shifting projection pattern']);
        xlabel('Pixel position u');ylabel('Light intensity');
        %%% Image captured by camera 
        % Note that acutal images are modulated by real objects and obtained by cameras in real world.
        % The actual captured images can be found in "Data" folder. 
        % The following I_k1 are non-modulated simulation images rather than actual images to conveniently show superimposition process.
        I_k1=I_k1+I_k1k2*Sk(k2);    
    end
    subplot(4,4,13:16); plot(I_k1/Total_Projecion_number); 
    title(['External ',num2str(k1),'-th phase-shifting image obtained by camera (superimposition of above 12×10 patterns)']);
    xlabel('Pixel position u');ylabel('Gray');
end
