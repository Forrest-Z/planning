function createfigure(YMatrix1)
%CREATEFIGURE(YMATRIX1)
%  YMATRIX1:  y ���ݵľ���

%  �� MATLAB �� 01-Nov-2018 21:44:03 �Զ�����

% ���� figure
figure1 = figure;

% ���� axes
axes1 = axes('Parent',figure1);
box(axes1,'on');
hold(axes1,'on');

% ʹ�� plot �ľ������봴������
plot1 = plot(YMatrix1,'Parent',axes1);
set(plot1(1),'DisplayName','simout(:,1)');
set(plot1(2),'DisplayName','simout(:,2)');
set(plot1(3),'DisplayName','simout(:,3)');


