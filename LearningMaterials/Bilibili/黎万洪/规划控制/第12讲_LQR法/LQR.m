clc
clear
close all
load  path.mat

%% ��������
dt = 0.1;
L = 2.9 ;
Q = [1, 0,  0;
      0, 1, 0;
      0, 0,  1];
R = eye(2)* 2;
refSpeed = 40/3.6;


%% �켣����
% ����ο��켣
refPos_x = path(:,1);
refPos_y = path(:,2);
refPos = [refPos_x, refPos_y];

% ����һ�׵���
for i = 1:length(refPos_x)-1
    refPos_d(i) = (refPos(i+1,2)-refPos(i,2))/(refPos(i+1,1)-refPos(i,1));
end
refPos_d(end+1) = refPos_d(end);

% ������׵���
for i =2: length(refPos_x)-1
    refPos_dd(i) = (refPos(i+1,2)-2*refPos(i,2) + refPos(i-1,2))/(0.5*(-refPos(i-1,1)+refPos(i+1,1)))^2;
end
refPos_dd(1) = refPos_dd(2);
refPos_dd(length(refPos_x)) = refPos_dd(length(refPos_x)-1);

% ��������
for i  = 1:length(refPos_x)-1
    k(i) = (refPos_dd(i))/(1+refPos_d(i)^2)^(1.5);
end

refPos_x = refPos_x';
refPos_y = refPos_y';
refPos_yaw = atan(refPos_d');
refPos_k = k';
refPos_Delta = atan(L*refPos_k);

%% ������
% ����ֵ
pos_x = 0; 
pos_y = 0; 
pos_yaw = 0; 
v = 10;
Delta = 0;
idx = 1;

% ������ʵ����
pos_actual = [pos_x,pos_y];
v_actual  = v;
Delta_actual = Delta;
idx_actual = 1;
% ѭ��
while idx < length(refPos_x)-1
    % Ѱ�Ҳο��켣���Ŀ���
    idx = calc_target_index(pos_x,pos_y,refPos_x,refPos_y);
    refDelta = 0;%refPos_Delta(idx);
    
    % LQR������
    [v_delta,delta,yaw_error] =  LQR_control(idx,pos_x,pos_y,v,pos_yaw,refPos_x,refPos_y,refPos_yaw,refPos_k,L,Q,R,dt);    
    
    % ����״̬
    [pos_x,pos_y,pos_yaw,v,Delta] = update(pos_x,pos_y,pos_yaw,v, v_delta,delta, dt,L, refSpeed,refDelta);
    pos_actual(end+1,:) = [pos_x,pos_y];
    v_actual(end+1,:)  = v;
    Delta_actual(end+1)  = Delta;
    idx_actual(end+1) = idx;
end

% ��ͼ
figure
yyaxis left
plot(refPos_x,refPos_y,'b-')
hold on
for i = 1:size(pos_actual,1)
    scatter(pos_actual(i,1), pos_actual(i,2),150,'b.')
    pause(0.05);
end

% ����ƽ���������
pos_refer = refPos(idx_actual);
for i = 1:length(idx_actual)
     LQR_error(i) = norm(refPos(idx_actual(i),:) - pos_actual(i,:));
end
yyaxis right
plot(LQR_error, 'r');

% ����
path_LQR = pos_actual;
save path_LQR.mat path_LQR

%% Ѱ�Ҳο��켣���Ŀ���
function target_idx = calc_target_index(pos_x,pos_y, refPos_x,refPos_y)
i = 1:length(refPos_x)-1;
dist = sqrt((refPos_x(i)-pos_x).^2 + (refPos_y(i)-pos_y).^2);
[~, target_idx] = min(dist);
end


%% LQR����
function [v_delta,delta,yaw_error] =  LQR_control(idx,pos_x,pos_y,v,pos_yaw,refPos_x,refPos_y,refPos_yaw,refPos_k,L,Q,R,dt)

% ��λ�á������״̬������
x_error  = pos_x - refPos_x(idx);
y_error = pos_y - refPos_y(idx);
yaw_error =  pipi(pos_yaw - refPos_yaw(idx));
X(1,1) = x_error; 
X(2,1) = y_error;  
X(3,1) = yaw_error;

% ��״̬���̾���ϵ��������K
A = [1,  0,  -v*dt*sin(pos_yaw);
     0,  1,  v * dt * cos(pos_yaw);
     0,  0,  1];
B = [dt * cos(pos_yaw),    0;
     dt * sin(pos_yaw),    0;
     dt * tan(pos_yaw)/L,  v*dt/(L * cos(pos_yaw)^2)];


K = calcu_K(A,B,Q,R);

% ���ǰ���ٶȱ仯����ǰ��ת�Ǳ仯������������
u = -K * X;  % 2��1��
v_delta = u(1);
delta = pipi(u(2));

end

%% �Ƕ�ת����[-pi, pi]
function angle_out = pipi(angle_in)
if (angle_in > pi)
    angle_out =  angle_in - 2*pi;
elseif (angle_in < -pi)
    angle_out = angle_in + 2*pi;
else
    angle_out = angle_in;
end
end

%% ��������
function K = calcu_K (A,B,Q,R)

% ��ֹ��������
iter_max = 500;
epsilon = 0.01;

% ѭ��
P_old = Q;
for i = 1:iter_max
    P_new = A' * P_old * A - (A' * P_old * B) / (R + B' * P_old * B) *( B' * P_old * A) +Q;
    if abs(P_new - P_old) <= epsilon
        break
    else
        P_old = P_new; 
    end
end

P = P_new;
K = (B' * P * B + R) \ (B' * P * A);  % 2��3��
end

%% ����״̬
function [x, y, yaw, v, Delta] = update(x, y, yaw, v, v_delta,delta,dt,L,refSpeed,refDelta)
Delta = refDelta + delta;
x = x + v * cos(yaw) * dt;
y = y + v * sin(yaw) * dt;
yaw = yaw + v / L * tan(Delta) * dt;
v = refSpeed + v_delta;
end
