%HVDC Light
clc;clear all;
r12=0.02;
r13=0.08;
r14=0;
r15=0;
r16=0;
r17=0;
r23=0.06;
r24=0.06;
r25=0.04;
r26=0;
r27=0;
%r34=0.01;
r34=0;
r35=0;
r36=0;
r37=0;
r45=0.08;
r46=0;
%r47=0.01;
r47=0.0094;
r56=0;
r57=0;
r67=0;

x12=1i*0.06;
x13=1i*0.24;
x14=1i*0;
x15=1i*0;
x16=1i*0;
x17=1i*0;
x23=1i*0.18;
x24=1i*0.18;
x25=1i*0.12;
x26=1i*0;
x27=1i*0;
%x34=1i*0.03;
x34=1i*0;
x35=1i*0;
x36=-1i*0.753;
x37=1i*0;
x45=1i*0.24;
x46=1i*0;
% x47=-1i*0.01193;
x47=1i*0.071;
x56=1i*0;
x57=1i*0;
x67=1i*0;

b12=1i*0.06;
b13=1i*0.05;
b14=0;
b15=0;
b16=0;
b17=0;
b23=1i*0.04;
b24=1i*0.04;
b25=1i*0.03;
b26=1i*0;
b27=1i*0;
%b34=1i*0.02;
b34=0;
b35=0;
b36=0;
b37=0;
b45=1i*0.05;
b46=0;
b47=0;
b56=0;
b57=0;
b67=0;

n=7;
Y=zeros(n,n);
Y=AddLine(Y,1,2,r12,x12,b12);
Y=AddLine(Y,1,3,r13,x13,b13);
Y=AddLine(Y,2,3,r23,x23,b23);
Y=AddLine(Y,2,4,r24,x24,b24);
Y=AddLine(Y,2,5,r25,x25,b25);
Y=AddLine(Y,3,6,r36,x36,b36);
Y=AddLine(Y,4,5,r45,x45,b45);
Y=AddLine(Y,4,7,r47,x47,b47);


GenP=[0;0.8847;0;0;0;0;0.25];
GenQ=[0;0;0;0;0;0;-.06];
LoadP=[0;.20;.45;.40;.60;0.25;0];
LoadQ=[0;.10;.15;.05;.10;0;0];
NetP=GenP-LoadP;
NetQ=GenQ-LoadQ;
Vm=[1.036;1.029;1;1;1;1.005;1];
Vp=[0;0;0;0;0;0;1.71*(pi/180)];
Ym=zeros(n,n);
Yp=zeros(n,n);
maxiter=7;

PowerMeasurements1=[];
PowerMeasurements2=[];
PhaseMeasurements=[];
MagnitudeMeasurements=[];


for t=1:n
    for k=1:n
        Ym(t,k)=abs(Y(t,k));
        Yp(t,k)=phase(Y(t,k));
    end
end

    
for iteration=1:maxiter


    J1=zeros(n-1,n-1);
    J2=zeros(n-1,n-1);
    J3=zeros(n-1,n-1);
    J4=zeros(n-1,n-1);
    DeltaP=zeros(n-1,1);
    DeltaQ=zeros(n-1,1);
    DeltaPowers =zeros(2*(n-1),1);
    CalcP=zeros(n,1);
    CalcQ=zeros(n,1);
    for x=1:n
        P=0;
        Q=0;
        for k=1:n
            P=P+abs(Vm(x))*abs(Y(x,k))*abs(Vm(k))*cos(phase(Y(x,k))-(Vp(x))+(Vp(k)));
            Q=Q-abs(Vm(x))*abs(Y(x,k))*abs(Vm(k))*sin(phase(Y(x,k))-(Vp(x))+(Vp(k)));
        end
        CalcP(x,1)=P;
        CalcQ(x,1)=Q;
    end


    DeltaP=NetP-CalcP;
    DeltaP=DeltaP(2:n,1);
    DeltaQ=NetQ-CalcQ;
    DeltaQ=DeltaQ(2:n,1);
    DeltaPowers=[DeltaP;DeltaQ];

    for y=2:n
        for o=2:n
            if (y==o)
                for k=1:n
                    if (k~=y)
                        J1(y-1,o-1)=J1(y-1,o-1)+abs(Vm(y))*abs(Y(y,k))*abs(Vm(k))*sin(phase(Y(y,k))-(Vp(y))+(Vp(k)));
                        J2(y-1,o-1)=J2(y-1,o-1)+           abs(Y(y,k))*abs(Vm(k))*cos(phase(Y(y,k))-(Vp(y))+(Vp(k)));
                        J3(y-1,o-1)=J3(y-1,o-1)+abs(Vm(y))*abs(Y(y,k))*abs(Vm(k))*cos(phase(Y(y,k))-(Vp(y))+(Vp(k)));
                        J4(y-1,o-1)=J4(y-1,o-1)-           abs(Y(y,k))*abs(Vm(k))*sin(phase(Y(y,k))-(Vp(y))+(Vp(k)));
                    else
                        J1(y-1,o-1)=J1(y-1,o-1)+0;
                        J2(y-1,o-1)=J2(y-1,o-1)+2*abs(Y(y,k))*abs(Vm(k))*cos(phase(Y(y,k))-(Vp(y))+(Vp(k)));
                        J3(y-1,o-1)=J3(y-1,o-1)+0;
                        J4(y-1,o-1)=J4(y-1,o-1)-2*abs(Y(y,k))*abs(Vm(k))*sin(phase(Y(y,k))-(Vp(y))+(Vp(k)));
                    end
                end
            else
                J1(y-1,o-1)=J1(y-1,o-1)-abs(Vm(y))*abs(Y(y,o))*abs(Vm(o))*sin(phase(Y(y,o))-(Vp(y))+(Vp(o)));
                J2(y-1,o-1)=J2(y-1,o-1)+           abs(Y(y,o))*abs(Vm(o))*cos(phase(Y(y,o))-(Vp(y))+(Vp(o)));
                J3(y-1,o-1)=J3(y-1,o-1)-abs(Vm(y))*abs(Y(y,o))*abs(Vm(o))*cos(phase(Y(y,o))-(Vp(y))+(Vp(o)));
                J4(y-1,o-1)=J4(y-1,o-1)-           abs(Y(y,o))*abs(Vm(o))*sin(phase(Y(y,o))-(Vp(y))+(Vp(o)));
            end
        end
    end
    
    J2(1,1)=0;
    J2(2,1)=0;
    J2(3,1)=0;
    J2(4,1)=0;
    J2(5,1)=0;
    J2(6,1)=0;
    J4(1,1)=1;
    J4(2,1)=0;
    J4(3,1)=0;
    J4(4,1)=0;
    J4(5,1)=0;
    J4(6,1)=0;
    
    J=[J1 J2;J3 J4];
    J(1,11)=0;
    J(2,11)=0;
    J(3,11)=0;
    J(4,11)=0;
    J(5,11)=0;
    J(6,11)=0;
    J(7,11)=0;
    J(8,11)=0;
    J(9,11)=0;
    J(10,11)=0;
    J(11,11)=1;
    J(12,11)=0;
    
    DeltaVoltage=inv(J)*DeltaPowers;
    iteration
    Vm
    Vp
    Y
    CalcP
    CalcQ
    J
    inv(J)
    DeltaPowers
    DeltaVoltage

        PowerMeasurements1(iteration)=CalcP(6,1);
        PowerMeasurements2(iteration)=CalcQ(7,1);
        PhaseMeasurements(iteration)=Vp(6)*(180/pi);
        MagnitudeMeasurements(iteration)=Vm(7);

    
    Vp=Vp+[0; DeltaVoltage(1:n-1,1)];
    Vm=Vm+[0;0;0;DeltaVoltage((n+2),1);DeltaVoltage((n+3),1);0;DeltaVoltage((n+5),1)];
    GenQ(2,1)=GenQ(2,1)+DeltaVoltage(n,1);
    LoadQ(6,1)=LoadQ(6,1)-DeltaVoltage(n+4,1);
end

subplot(2,2,1);
plot(PowerMeasurements1);title('Rectifier Real Power');
xlabel('Iteration Number');
subplot(2,2,2);
plot(PowerMeasurements2);title('Inverter Reactive Power');
xlabel('Iteration Number');
subplot(2,2,3);
plot(PhaseMeasurements);title('Rectifier Voltage Phase');
xlabel('Iteration Number');
subplot(2,2,4);
plot(MagnitudeMeasurements);title('Inverter Voltage Magnitude');
xlabel('Iteration Number');