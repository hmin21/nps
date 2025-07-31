%%%%%%%%%%%%%%%%%%%%%%% Simultion 2 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Simultion 1: Propsed projection method VS traditional projection method
% Simultion 2: Proposed 3-steps method VS Traditional 3-steps phase-shifting method
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% N1 denotes total number of external phase-shifitng steps
% k1 denotes k1-th step of external phase-shifting
% N2 denotes total number of internal phase-shifitng steps
% k2 denotes the k2-th step of internal phase-shifting
% 5th harmonics is used to simulate errors resulting from non-linear systems
% internal phase-shifting is used to generate the camera image
% external phase-shifting used camera images to extrct wrapped phase
% Total number of projections is 120 in one exposure.
% Projeciton numbers of I_k1k2 are: 20,19,15,10,5,1,0,1,5,10,15,19, respectively;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% Simulation 2:  Comparison of phase retrival methods 
clc; clear; close all;
f = [1,3];          % fringe number
N1=3;               % total number of external phase-shifitng steps
N2=12;              % total number of internal phase-shifitng steps
c = 10;             % c denotes the scaling factor
k2=1:N2;            
Sk_ideal=c*(cos(2*(k2-1)*pi/N2)+1);   % Ideal projection number
Sk=round(Sk_ideal);                   % Actual projection number
Height_img=500;  Width_img=600;
root_path='..\Image\Simulation\';
Wrapped_phase_all=zeros(Height_img,Width_img,length(f));

%%%%%%%%%%%% 一、Traditional 12-step phase-shifting method (as Gruoundthruth)
% 1) Wrapped phase extraction
for id_f=1:length(f)
    numerator=0;
    denominator=0;
    for k1=1:12     % N=12;
        path=[root_path,'Groundthruth-',num2str(f(id_f)), '-', num2str(k1),'.bmp'];
        Img=imread(path);
        Img=im2double(Img);
        phi_k1=2*(k1-1)*pi/12;  % external phase-shifting
        numerator=numerator+Img*sin(phi_k1);
        denominator=denominator+Img*cos(phi_k1);
    end
    Wrapped_phase=-atan2(numerator,denominator);      % Calculate wrapped phase based on Eq.(18)
    Wrapped_phase(Wrapped_phase<0)=Wrapped_phase(Wrapped_phase<0)+2*pi; % [-pi,pi] is transformed into [0,2*pi]
    Wrapped_Groundthruth(:,:,id_f)=Wrapped_phase;
end
%%% 3) Phase unwrapping
phi_low_frequency=Wrapped_Groundthruth(:,:,1);
for id_f=2:length(f)
    phi_high_frequency=Wrapped_Groundthruth(:,:,id_f);
    k_order=round((f(id_f)/f(id_f-1)*phi_low_frequency-phi_high_frequency)/(2*pi));
    phi_high_frequency=phi_high_frequency+k_order*2*pi;
    phi_low_frequency=phi_high_frequency;
end
unwrapping_Groundthruth = phi_high_frequency; 

%%%%%%%%%%%% 二、Proposed 3-steps phase-shifting method (i.e. external 3-step phase-shifting method)
% 1) Wrapped phase extraction
beta=Sk_ideal-Sk;                     % rounding error β
c2=N2*c/2; c3=0;  
for k2=1:N2
    c2=c2-cos(2*(k2-1)*pi/N2)*beta(k2);  % constants c2 and c3
    c3=c3+sin(2*(k2-1)*pi/N2)*beta(k2);
end
for id_f=1:length(f)
    numerator=0;
    denominator=0;
    for k1=1:N1
        path=[root_path,'Ours-',num2str(f(id_f)), '-', num2str(k1),'.bmp'];
        Img=imread(path);
        Img=im2double(Img);
        phi_k1=2*(k1-1)*pi/N1;  % external phase-shifting
        numerator=numerator-(c3*cos(phi_k1)-c2*sin(phi_k1))*Img;     % The numerator in Eq.(18)
        denominator=denominator+(c2*cos(phi_k1)+c3*sin(phi_k1))*Img; % The denominator in Eq.(18)
    end
    Wrapped_phase=-atan2(numerator,denominator);      % Calculate wrapped phase based on Eq.(18)
    Wrapped_phase(Wrapped_phase<0)=Wrapped_phase(Wrapped_phase<0)+2*pi; % [-pi,pi] is transformed into [0,2*pi]
    figure;plot(Wrapped_phase(300,:),'b-x',MarkerSize=2);               % show wrapped phase at each frequency
    hold on; plot(Wrapped_Groundthruth(300,:,id_f),'r-'); % show Groundtruth at each frequency 
    legend('Ours: Wrapped Phase','Groundthruth: Wrapped Phase');  
    Wrapped_phase_all(:,:,id_f)=Wrapped_phase;
end
%%% 2) Phase unwrapping(same to traditional method)
phi_low_frequency=Wrapped_phase_all(:,:,1);
for id_f=2:length(f)
    phi_high_frequency=Wrapped_phase_all(:,:,id_f);
    k_order=round((f(id_f)/f(id_f-1)*phi_low_frequency-phi_high_frequency)/(2*pi));
    phi_high_frequency=phi_high_frequency+k_order*2*pi;
    phi_low_frequency=phi_high_frequency;
end
unwrapping_phase = phi_high_frequency; 
figure;plot(unwrapping_phase(300,:),'b-x',MarkerSize=2); % show unwrapping phase
hold on; plot(unwrapping_Groundthruth(300,:),'r-'); % show Groundtruth
legend('Ours: Unwrapping Phase','Groundthruth: Unwrapping Phase');  

%%%%%%%%%%%% 三、Traditional 3-step phase-shifting method
% 1) Wrapped phase extraction
for id_f=1:length(f)
    numerator=0;
    denominator=0;
    for k1=1:N1
        path=[root_path,'Traditional-',num2str(f(id_f)), '-', num2str(k1),'.bmp'];
        Img=imread(path);
        Img=im2double(Img);
        phi_k1=2*(k1-1)*pi/N1;  % external phase-shifting
        numerator=numerator+Img*sin(phi_k1);
        denominator=denominator+Img*cos(phi_k1);
    end
    Wrapped_phase=-atan2(numerator,denominator);      % Calculate wrapped phase based on Eq.(18)
    Wrapped_phase(Wrapped_phase<0)=Wrapped_phase(Wrapped_phase<0)+2*pi; % [-pi,pi] is transformed into [0,2*pi]
    figure;plot(Wrapped_phase(300,:),'b-x',MarkerSize=2);               % show wrapped phase at each frequency
    hold on; plot(Wrapped_Groundthruth(300,:,id_f),'r-'); % show Groundtruth at each frequency 
    legend('Traditioanl: Wrapped Phase','Groundthruth: Wrapped Phase');  
    Wrapped_phase_all(:,:,id_f)=Wrapped_phase;
end
%%% 3) Phase unwrapping
phi_low_frequency=Wrapped_phase_all(:,:,1);
for id_f=2:length(f)
    phi_high_frequency=Wrapped_phase_all(:,:,id_f);
    k_order=round((f(id_f)/f(id_f-1)*phi_low_frequency-phi_high_frequency)/(2*pi));
    phi_high_frequency=phi_high_frequency+k_order*2*pi;
    phi_low_frequency=phi_high_frequency;
end
unwrapping_phase = phi_high_frequency; 
figure;plot(unwrapping_phase(300,:),'b-x',MarkerSize=2);
hold on; plot(unwrapping_Groundthruth(300,:),'r-'); % show Groundtruth
legend('Traditional: Unwrapping Phase','Groundthruth: Unwrapping Phase');  