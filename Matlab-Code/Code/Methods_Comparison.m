%%%%%%%%%% Proposed phase-shifting method VS Traditional phase-shifting method %%%%%
% document description:
% 1. This file compares accurcy of the phases obtained by two methods
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
root_path='..\Image\';
Target_name='Plane-';
method_name={'Traditional-12-Step','Traditional-3-Step','Traditional-4-Step','Traditional-5-Step',...
             'Our-3-Step','Our-4-Step','Our-5-Step'};
for i=1:length(method_name)
    Method_name{i}=[Target_name,method_name{i}];
end
Step_name=[12, 3, 4, 5, 3, 4, 5];
Flag_Ours=[ 0, 0, 0, 0, 1, 1, 1];
Method_number=length(Method_name);
img_width=648; img_height=588; 
img_phase = zeros(img_height,img_width,Method_number); 

%%%%%%%%%%%% 2、Algorithm
%%% 1) Calculation of parameters c2, c3 in the proposed method
N2=12;
c=10;   
k2=1:N2;
Sk_ideal=c*(cos(2*(k2-1)*pi/N2)+1);  
Sk=round(Sk_ideal);
beta=Sk_ideal-Sk;                     % rounding error β
c2=N2*c/2; c3=0;  
for k2=1:N2
    c2=c2-cos(2*(k2-1)*pi/N2)*beta(k2);  % constants c2 and c3
    c3=c3+sin(2*(k2-1)*pi/N2)*beta(k2);
end
%%% 2) Phase retrieval (for unit-frequency fringes)
for id_method = 1:Method_number
    N=Step_name(id_method);
    numerator=0;
    denominator=0;
    for k=1:N
        path=[root_path,Method_name{id_method},'\1_', num2str(k),'.bmp'];
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
    img_phase(:,:,id_method)=-atan2(numerator,denominator)+pi;    % Range: 0-2*pi
end

%%%%%%%%%%%% 3、Error analysis
Phase_error_2D = zeros(img_height,img_width,Method_number-1); 
Phase_error_2D_noabs = zeros(img_height,img_width,Method_number-1); 
% Traditional 12-step phase-shifting method (as Gruoundthruth)
for id_method = 2:Method_number
    Phase_error_2D_noabs(:,:,id_method-1)=img_phase(:,:,id_method)-img_phase(:,:,1);
    Phase_error_2D(:,:,id_method-1)=abs(img_phase(:,:,id_method)-img_phase(:,:,1));
    Phase_error_1D = reshape(Phase_error_2D(:,:,id_method-1),[1,img_height*img_width]);
end
% Draw 2D error map
for id_method = 1:Method_number-1
    errormap=Phase_error_2D(:,:,id_method);
    fig=figure;ax = axes(fig);imagesc(errormap);colormap(jet); caxis([0 0.2]); colorbar; 
    adjust_fig(fig, ax, 0, 'u (pixel)', 'v (pixel)');
    axis equal; xlim([0,img_width]);ylim([0,img_height]);ax.XMinorTick = 'off'; ax.YMinorTick = 'off'; grid off;
    set(gca,'xtick',0:100:680); set(gca,'ytick',0:100:700);
    title([method_name{id_method+1},': Phase Error'],'FontSize',10);
    hold off; 
end
% Draw cross-section of error map
Row_instrest=300;
for id_method=1:Method_number-1
    fig=figure;
    ax = axes(fig);
    colororder([0.40 0.30 0.90; 0.50 0.65 0.15]);
    yyaxis left; 
    plot(img_phase(Row_instrest,:,id_method+1)-pi,...
         'Marker','none','LineStyle','-','LineWidth',1);
    hold on;plot(img_phase(Row_instrest,:,1)-pi,...
         'Marker','none','LineStyle','--','LineWidth',1,'Color','r');
    ylabel('Phase (rad)'); ylim([-1.2 1.2]); 
    yyaxis right; 
    hold on;stairs(Phase_error_2D_noabs(Row_instrest,:,id_method),...
        'Marker','*','MarkerSize',3,'LineStyle','-','LineWidth',0.01);
    ylabel('Phase error (rad)'); ylim([-0.2 0.2]);  
    xlabel('u (pixel)');set(gca,'xtick',0:300:600);xlim([0 img_width]);
    if id_method<4
        Step_string='$P{S^{N = 3}}$';
        label = legend(['$P{S^{N =',num2str(id_method+2),'}}$'],'Ideal Phase','Phase Error','Interpreter','latex');
    else 
        label = legend(['$Ours_{{N_2} = 12}^{{N_1} =',num2str(id_method-1),'}$'],'Ideal Phase','Phase Error','Interpreter','latex');
    end
    label.ItemTokenSize= [24,24];
    adjust_fig(fig, ax, 0, 'u (pixel)','Phase error (rad)'); 
    yyaxis right; 
    set(get(gca,'YLabel'),'FontSize',13); 
    set(gca,'FontSize',11); 
    yyaxis left;
    set(get(gca,'YLabel'),'FontSize',13'); 
    set(gca,'FontSize',11); 
    outerpos = ax.OuterPosition;
    ti = ax.TightInset;
    left = outerpos(1)+1*ti(1) ;
    bottom = outerpos(2)+1.5*ti(2) ;
    ax_width = outerpos(3) - 0.5*(ti(1) + ti(3));
    ax_height = outerpos(4) - 1.8*(ti(2) + ti(4));
    ax.Position = [left bottom ax_width ax_height]; 
    title([method_name{id_method+1},': Phase Error of cross section'],'FontSize',10);
end