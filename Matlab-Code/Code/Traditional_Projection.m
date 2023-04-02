%%%%%%%%%%%%%%%%%%%%%%%%%%%% Voltage data generation of traditional propjection method %%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% document description %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   A、Function: Voltage data generation of traditional propjection method
%   B、description：
%     1. The output power is controlled by modulating the laser voltage, thereby changing the laser light intensity.
%     2. Laser voltage control mode: angle pulse voltage modulation
%     3. Generate a coe file
%     4. The frequency is 1, and the number of steps is 3, 4, 5, 12. 
%     5. Update the relationship between voltage and optical power, update the voltage data to 700 points, and update the optical power to 0-104mW

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% code %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% 1、Initialization and Variable Definition
clc; clear; close all;
f = 1;                    % Number of stripes
N=[3,4,5,12];
P_max = 104;              
P_min = 0;               
a=[5.86964588117397e-10	-1.30288492319589e-07	1.14243270722708e-05	-0.000415094802379048	0.0246249265443986	0.533180106832970];
Q = 1024;                 % The quantization level is 10 bits
Voltage_Quantitative=10;  % The voltage output range is -5V to +5V
alpha_max = 30;           % Maximum scanning angle of laser in one direction: 30 °
alpha_interval = 0.05;    % Angle marker pulse: 0.05 °
pulse_max=alpha_max/alpha_interval;     % Maximum number of angular pulses
pulse_id = 1:pulse_max;                 % Cumulative number of current angle pulses: 1~600 (vector)
alpha=alpha_interval*pulse_id';         % Current laser angle: 0.05 °~30 °
Num_data=700;            % The amount of data required for each phase shift map: 700

%%%%%%%%%%%% 2、Prefix description of coe file
savepath='..\Result\Traditional_Projection_Method.coe';
fid = fopen(savepath, 'w');
fprintf(fid, 'memory_initialization_radix=10;\n');
fprintf(fid, 'memory_initialization_vector =\n') ;
fclose(fid);
%%%%%%%%%%%% 3、algorithm         %Description: Projected cosine function; Initial phase: - pi;
A=0.5*P_max;
B=0.5*P_max;
for i=1:length(N)
    for j=1:length(f)
         figure('name',['The number of steps:',num2str(N(i)),', ','Frequency:',num2str(f(j))]);
        for k=1:1:N(i)
            P = A + B*cos(2*pi*f(j)*tand(alpha)/tand(alpha_max)+2*(k-1)*pi/N(i) - pi);
            P = P*(P_max-P_min)/P_max+P_min;
            %Convert power into voltage using the functional relationship between U-P (calibration of the relationship function)
            U=a(1)*P.^5+a(2)*P.^4+a(3)*P.^3+a(4)*P.^2+a(5)*P+a(6);
            U_data=[round(-U*Q/Voltage_Quantitative + Q/2);512*ones(Num_data-pulse_max,1)]; %其中前600个为有效数据，中间插入一个0电压数据，接着600个为前600个的反向数据，其余补0
            %%% data saving         
            fid = fopen(savepath,'a+');  
            for data_line = 1:1:Num_data
                fprintf(fid,'%d,\n',U_data(data_line));
            end
            fclose(fid);
            %%% Drawing&determining whether the data meets the requirements
            subplot(3,4,k);plot(P);title([num2str(k),'-th phase-shifting pattern']);xlabel('Number of Pulse');ylabel('Laser Power (mW)');
        end
    end
end