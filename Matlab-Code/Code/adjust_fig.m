function adjust_fig(fig, ax, leg, x_label, y_label)
%%
%该函数用于对函数图像的尺寸、坐标轴的尺寸、线条的尺寸颜色等进行基本设置
%%
%图像尺寸与背景设置
fig.Units = 'centimeters';
fig.Position(3:4) = [10,9]; %设置图像尺寸(实际复制到word中的尺寸大小）
% fig.Position(3:4) = [13,9]; %设置图像尺寸(实际复制到word中的尺寸大小）
fig.Color = [1 1 1]; %设置图像背景

%X标签设置 (只有先确定了标签，才能确定标签尺寸，进而才能调整axes尺寸)
if x_label==0
    image_show="no x_label";
else
    ax.XLabel.String = x_label;
    ax.XLabel.Units = 'normalized';
    %ax.XLabel.Position(1:2) = [0.5, -0.125];
    ax.XLabel.Interpreter = 'latex'; %采用latex解释器能够解决tex解释器下标下沉的问题
end
%Y标签设置
if y_label==0
    image_show="no y_label";
else
    ax.YLabel.String = y_label;
    ax.YLabel.Units = 'normalized';
    %ax.YLabel.Position(1:2) = [-0.15, 0.5];
    ax.YLabel.Interpreter = 'latex';
end

%axes铺满figure设置方法
ax.Units = 'normalized';%将其设置为normalized可使其随figure的调整而调整
%ax.OuterPosition(3:4) = [8,5.5]; %设置绘图区域尺寸(包括标签）
outerpos = ax.OuterPosition;
%获取坐标轴文本标签的边距（即标尺文字序列）
ti = ax.TightInset;
left = outerpos(1)+1.5*ti(1) ;%1.1用于预留一点边界范围，否则导出的图片边缘线条会有缺失（该值可根据图形尺寸进行调整），下同。
bottom = outerpos(2)+1.5*ti(2) ;
ax_width = outerpos(3) - 1.8*(ti(1) + ti(3));
ax_height = outerpos(4) - 1.8*(ti(2) + ti(4));
ax.Position = [left bottom ax_width ax_height]; 

ax.LineWidth = 1; %设置坐标轴宽度
ax.FontName = 'Times New Roman';
ax.FontSize = 12;
ax.TickLabelInterpreter = 'latex';
ax.XGrid = 'on';
ax.YGrid = 'on';

ax.XMinorTick = 'on'; %次刻度线
ax.YMinorTick = 'on';
ax.TickLength(1) = 0.02;
if leg==0
    image_show="no lengd";
else
    leg.Interpreter = 'latex';
    leg.Location = 'best';
    leg.Box = 'on';
    leg.FontSize=12;
end
end