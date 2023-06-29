%%%%%%%%%%%%%%%%%%%%%%%%%%%% Voltage data generation of the proposed projection method %%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% document description %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   A、Function: Voltage data generation of the proposed projection method.
%   B、description：
%     1. The output power is controlled by modulating the laser voltage, thereby changing the laser light intensity.
%     2. Laser voltage control mode: angle pulse voltage modulation
%     3. Generate a coe file
%     4. The frequency is 1, internal number of steps is N2=12, and external number of steps is N1=3. 
%     5. Update the relationship between voltage and optical power, update the voltage data to 700 points, and update the optical power to 0-104mW

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% code %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% 1、Initialization and Variable Definition
clc; clear; close all;
f = 1;           % Number of stripes
N=12;
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
savepath='..\Result\Proposed_Projection_Method.coe';
fid = fopen(savepath, 'w');
fprintf(fid, 'memory_initialization_radix=10;\n');
fprintf(fid, 'memory_initialization_vector =\n') ;
fclose(fid);

%%%%%%%%%%%% 3、algorithm
N1=3;
N2=12;
A=0.5*P_max;
B=0.5*P_max;
%%%Exposure time setting
c=10;   % c is a scaling factor that makes the number of scans as integer as possible.
k2=1:N2;
k2_ideal_scanning_number=c*(cos(2*(k2-1)*pi/N2)+1);  % +1 To make the number of scans not negative. A total of c * N2 patterns were scanned without considering rounding errors.
k2_scanning_number=round(k2_ideal_scanning_number);
scanning_total_number=sum(k2_scanning_number);
k2_difference=k2_ideal_scanning_number-k2_scanning_number;
c2=N2*c/2; c3=0;  % c is a scaling factor that makes the number of scans as integer as possible.
for k2=1:N2
    c2=c2-cos(2*(k2-1)*pi/N2)*k2_difference(k2);
    c3=c3+sin(2*(k2-1)*pi/N2)*k2_difference(k2);
end
fprintf(" Total_scanning_number=%d \n k2_scanning_number=",scanning_total_number);
fprintf("%d,", k2_scanning_number);
fprintf("\n c2=%d, c3=%d \n ",c2,c3);
%%%data generating
for i=1:length(N1)
    for j=1:length(f)
        for k1=1:1:N1(i)
            I_k1=0;
            figure('name',['The external number of steps:',num2str(N1(i)),', ','Frequency:',num2str(f(j)),',','Step:',num2str(k1)]);
            for k2=1:1:N2
                if k2_scanning_number(k2)==0
                    continue;   %%%% When the number of scans is 0, the data of this phase shift map is not written.
                end 
                P = A + B*cos(2*pi*f(j)*tand(alpha)/tand(alpha_max)+2*(k1-1)*pi/N1(i)+2*(k2-1)*pi/N2 - pi);
                P = P*(P_max-P_min)/P_max + P_min;
                %Convert power into voltage using the functional relationship between U-P (calibration of the relationship function)
                U=a(1)*P.^5+a(2)*P.^4+a(3)*P.^3+a(4)*P.^2+a(5)*P+a(6);
                U_data=[round(-U*Q/Voltage_Quantitative + Q/2);512*ones(Num_data-pulse_max,1)]; 
                %%% data saving
                fid = fopen(savepath,'a+');
                for data_line = 1:1:Num_data
                    fprintf(fid,'%d,\n',U_data(data_line));
                end
                fclose(fid);
                %%% Drawing&determining whether the data meets the requirements
                subplot(4,4,k2);plot(P);title(['Internal ',num2str(k2),'-th phase-shifting pattern']);xlabel('Number of Pulse');ylabel('Laser Power (mW)');
                I_k1=I_k1+P*k2_scanning_number(k2);
            end
            subplot(4,4,13:16);plot(I_k1/P_max/scanning_total_number);title(['External ',num2str(k1),'-th phase-shifting Image']);xlabel('Number of Pulse');ylabel('Internsity');
        end
    end
end