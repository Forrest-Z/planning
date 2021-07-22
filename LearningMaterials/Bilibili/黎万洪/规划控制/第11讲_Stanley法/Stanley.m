% Stanley��
% ���ߣ�Ally
% ���ڣ�20210312
clc
clear
close all
load  path.mat

%% ��ز�������
RefPos = path;              % �ο��켣
targetSpeed = 20;           % Ŀ���ٶȣ���λ�� m /s
InitialState = [0,-2,0,0];  % ����λ�á�����λ�á�����ǡ��ٶ�
k = 0.1;                    % �������
Kp = 1;                     % �ٶ�P������ϵ��
dt = 0.1;                   % ʱ��������λ��s
L = 2;                      % ������࣬��λ��m

%% ������

% ������ʼ״̬����
state = InitialState;
state_actual = state;
target_idx = 1;

while target_idx < size(RefPos,1)-1
    % Ѱ��Ԥ����뷶Χ�����·����
    [target_idx,latError] = findTargetIdx(state,RefPos);
    
    % ���������
    delta = stanley_control(target_idx,state,latError,RefPos,k);
    
    % ������ٶ�
    a = Kp* (targetSpeed-state(4));
    
    % ����״̬��
    state_new = UpdateState(a,state,delta,dt,L);
    state = state_new;
    
    % ����ÿһ����ʵ��״̬��
    state_actual(end+1,:) = state_new;
end

% ��ͼ
figure
plot(path(:,1), path(:,2), 'b');
xlabel('�������� / m');
ylabel('�������� / m');
hold on
for i = 1:size(state_actual,1)
    scatter(state_actual(i,1), state_actual(i,2),150, '.r');
    pause(0.01)
end
legend('�滮�����켣', 'ʵ����ʻ�켣')

%  ����
path_stanley = state_actual(:,1:2);
save path_stanley.mat path_stanley;

%% �����ڲο��켣�������뵱ǰλ������ĵ�
function [target_idx,latError] = findTargetIdx(state,RefPos)
for i = 1:size(RefPos,1)
    d(i,1) = norm(RefPos(i,:) - state(1:2));
end
[latError_temp,target_idx] = min(d);  % �ҵ����뵱ǰλ�������һ���ο��켣������

if state(2) < RefPos(target_idx,2)    % ��ǰλ��������С�ڲο��켣��������ʱ
    latError = -latError_temp;
else
    latError = latError_temp;
end
end

%% ��ÿ�����
function delta = stanley_control(target_idx,state,latError,RefPos,k)
sizeOfRefPos = size(RefPos,1);
if target_idx < sizeOfRefPos-5
    Point = RefPos(target_idx+5,1:2);  % ע�⣬target_idx��ǰ��5����Ϊ
else
    Point = RefPos(end,1:2);
end

theta_fai = pipi(atan((Point(2)-state(2))/(Point(1)-state(1))) -state(3));
theta_y = atan(k*latError / state(4));

% ǰ��ת��
delta = theta_fai + theta_y;
end


%% ����״̬��
function state_new = UpdateState(a,state_old,delta,dt,L)
state_new(1) =  state_old(1) + state_old(4)*cos(state_old(3))*dt; %��������
state_new(2) =  state_old(2) + state_old(4)*sin(state_old(3))*dt; %��������
state_new(3) =  state_old(3) + state_old(4)*dt*tan(delta)/L;      %�����
state_new(4) =  state_old(4) + a*dt;                              %�����ٶ�
end
