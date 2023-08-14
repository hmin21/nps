%%%%%%%%%% Proposed phase-shifting method VS Traditional phase-shifting method %%%%%
% document description:
% 1. This file compares two methods on complex surfaces.
% 2. This file shows the real experiments
% 3. Actual images captured by a camera are uploaded to "Data" folder.
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
clc; close all; clear;
img_width=648; img_height=588; 
Frequency_number=4;         % Fringe frequency:1 2 8 32
FrequencyRatio = [2,4,4];  
root_path='..\Image\';
Target_name='David-';
method_name={'Traditional-12-Step','Traditional-3-Step',...
             'Our-3-Step',};
for i=1:length(method_name)
    Method_name{i}=[Target_name,method_name{i}];
end
Step_name=[12, 3, 3];
Flag_Ours=[0, 0, 1];
Method_number=length(Method_name);

%%%%%%%%%%%% 2、Algorithm
%%% 1) Calculation of parameters c2, c3 in the proposed method
N2=12;
c=10;   
k2=1:N2;
Sk_ideal=c*(cos(2*(k2-1)*pi/N2)+1);  
Sk=round(Sk_ideal);
beta=Sk_ideal-Sk;                        % rounding error β
c2=N2*c/2; c3=0;  
for k2=1:N2
    c2=c2-cos(2*(k2-1)*pi/N2)*beta(k2);  % constants c2 and c3
    c3=c3+sin(2*(k2-1)*pi/N2)*beta(k2);
end
%%% 2) Phase retrieval
for id_method = 1:Method_number
    N=Step_name(id_method);
    for id_frequency=1:Frequency_number
        numerator=0;
        denominator=0;
        for k=1:N
            path=[root_path,Method_name{id_method},'\',num2str(id_frequency), '_', num2str(k),'.bmp'];
            Img=imread(path);
            Img=im2double(Img);
            if Flag_Ours(id_method)==0   % a). Traditional phase-shifting method
                numerator=numerator+Img*sin(2*(k-1)*pi/N);
                denominator=denominator+Img*cos(2*(k-1)*pi/N);
            else                         % b). Proposed phase-shifting method
                numerator=numerator-(c3*cos(2*(k-1)*pi/N)-c2*sin(2*(k-1)*pi/N))*Img; 
                denominator=denominator+(c2*cos(2*(k-1)*pi/N)+c3*sin(2*(k-1)*pi/N))*Img;
            end
        end
        phi(:,:,id_frequency)=-atan2(numerator,denominator)+pi;
    end
    % Phase unwrapping
    phl = phi(:,:,1);
    for i=1:Frequency_number-1
        phh = phi(:,:,i+1);
        kh = round((FrequencyRatio(i)*phl-phh)/(2*pi));
        phl = phh + kh*2*pi;
    end
    phi_unwrapped = phl; 
    absolute_Phase_mask(:,:,id_method)=phi_unwrapped;
end

%%%%%%%%%%%% 3、Visualization of phase
% 1) Mask
B_sin=0;B_cos=0;
N=Step_name(1);
for k=1:N
    path=[root_path,Method_name{1},'\',num2str(Frequency_number), '_', num2str(k),'.bmp'];
    Img=imread(path);
    Img=im2double(Img);
    B_sin=B_sin+Img*sin(2*pi*(k-1)/N);
    B_cos=B_cos+Img*cos(2*pi*(k-1)/N); 
end
B_mask=sqrt(B_sin.^2+B_cos.^2)*2/N;
Mask=imbinarize(B_mask,0.05);
% 2) Draw absolute phase map
for id_method = 1:Method_number
    absolute_Phase_mask(:,:,id_method)=Mask.*absolute_Phase_mask(:,:,id_method);
    figure;imshow(absolute_Phase_mask(:,:,id_method),[]);title([Method_name{id_method},': Absolute Phase']);
end

%%%%%%%%%%%% 4、Error analysis
img_phase = absolute_Phase_mask; 
Phase_error_2D = zeros(img_height,img_width,Method_number-1); 
for id_method = 2:Method_number
    Phase_error_2D(:,:,id_method-1)=abs(img_phase(:,:,id_method)-img_phase(:,:,1));
end
for id_method = 1:Method_number-1
    errormap=Phase_error_2D(:,:,id_method);
    fig=figure;ax = axes(fig);imagesc(errormap);colormap(jet); caxis([0 0.2]); colorbar; 
    title([Method_name{id_method+1},': Phase Error']);
    adjust_fig(fig, ax, 0, 'u (pixel)', 'v (pixel)');
    axis equal; xlim([0,img_width]);ylim([0,img_height]);ax.XMinorTick = 'off'; ax.YMinorTick = 'off'; grid off;
    set(gca,'xtick',0:100:680); set(gca,'ytick',0:100:700);  hold off; 
end

