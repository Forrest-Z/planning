function errorfigure(simout,speed,steer)
a=simout.Data;
x=a(:,1);
y=a(:,2);
t1=simout.Time;
err1=(x.^2+(y-35).^2)-25^2;
figure(1);
subplot(2,1,1);
plot(t1,err1);
xlabel('t');
ylabel('·��ƫ��')
grid on;

theta=a(:,3);
err2=theta-0.2.*t1;
subplot(2,1,2)
plot(t1,err2);
xlabel('t');
ylabel('����ƫ��');
grid on;
hold on;

figure(2);
subplot(2,1,1)
b=speed.Data;
t2=speed.Time;
plot(t2,b);
xlabel('t');
ylabel('�ٶȱ仯');
grid on;

subplot(2,1,2)
c=steer.Data;
t3=steer.Time;
plot(t3,c);
xlabel('t');
ylabel('�����̽Ƕȱ仯');
grid on;



