%HVDC Light
clc;clear all;

n=14;
%% system MVA base
baseMVA = 100;

%% bus data
%bus_i	type	Pd	Qd	Gs	Bs	area    Vm	Va	baseKV	zone	Vmax	Vmin
bus = [
	1	3	0       0       0	0	1	1.06	0       0	1	1.06	0.94;
	2	2	21.7	12.7	0	0	1	1.045	-4.98	0	1	1.06	0.94;
	3	2	94.2	19      0	0	1	1.01	-12.72	0	1	1.06	0.94;
	4	1	47.8	-3.9	0	0	1	1.019	-10.33	0	1	1.06	0.94;
	5	1	7.6     1.6     0	0	1	1.02	-8.78	0	1	1.06	0.94;
	6	2	11.2	7.5     0	0	1	1.07	-14.22	0	1	1.06	0.94;
	7	1	0       0       0	0	1	1.062	-13.37	0	1	1.06	0.94;
	8	2	0       0       0	0	1	1.09	-13.36	0	1	1.06	0.94;
	9	1	29.5	16.6	0	19	1	1.056	-14.94	0	1	1.06	0.94;
	10	1	9       5.8     0	0	1	1.051	-15.1	0	1	1.06	0.94;
	11	1	3.5     1.8     0	0	1	1.057	-14.79	0	1	1.06	0.94;
	12	1	6.1     1.6     0	0	1	1.055	-15.07	0	1	1.06	0.94;
	13	1	13.5	5.8     0	0	1	1.05	-15.16	0	1	1.06	0.94;
	14	1	14.9	5       0	0	1	1.036	-16.04	0	1	1.06	0.94;
];

for b=1:14
    LoadP(bus(b,1),1)=bus(b,3)/baseMVA;
    LoadQ(bus(b,1),1)=bus(b,4)/baseMVA;
    if (b==2)||(b==3)||(b==6)||(b==8)
        Vm(bus(b,1),1)=bus(b,8);
        Vp(bus(b,1),1)=bus(b,9)*(pi/180);
    else
        Vm(bus(b,1),1)=1;
        Vp(bus(b,1),1)=0;
    end
end
    
%% generator data
%	bus	Pg	Qg	Qmax	Qmin	Vg	mBase	status	Pmax	Pmin
gen = [
	1	232.4	-16.9	10	0	1.06	100	1	332.4	0;
	2	40      42.4	50	-40	1.045	100	1	140     0;
	3	0       23.4	40	0	1.01	100	1	100     0;
	6	0       12.2	24	-6	1.07	100	1	100     0;
	8	0       17.4	24	-6	1.09	100	1	100     0;
];

for g=1:5
    GenP(gen(g,1),1)=gen(g,2)/baseMVA;
    GenQ(gen(g,1),1)=gen(g,3)/baseMVA;
end
    GenP(14,1)=0;
    GenQ(14,1)=0;
    
%% branch data
%	fbus	tbus	r	x	b	rateA	rateB	rateC	ratio	angle	status
branch = [
	1	2	0.01938 0.05917	0.0528	9900	1	1	1       0	1;
	1	5	0.05403	0.22304	0.0492	9900	1	1	1       0	1;
	2	3	0.04699	0.19797	0.0438	9900	1	1	1       0	1;
	2	4	0.05811	0.17632	0.034	9900	1	1	1       0	1;
	2	5	0.05695	0.17388	0.0346	9900	1	1	1       0	1;
	3	4	0.06701	0.17103	0.0128	9900	1	1	1       0	1;
	4	5	0.01335	0.04211	0       9900	0	1	1       1	1;
	4	7	0       0.20912	0       9900	0	0	0.978	0	1;
	4	9	0       0.55618	0       9900	0	0	0.969	0	1;
	5	6	0       0.25202	0       9900	0	0	0.932	0	1;
	6	11	0.09498	0.1989	0       9900	0	1	1       0	1;
	6	12	0.12291	0.25581	0       9900	0	1	1       0	1;
	6	13	0.06615	0.13027	0       9900	0	1	1       0	1;
	7	8	0       0.17615	0       9900	0	0	1       1	1;
	7	9	0       0.11001	0       9900	0	0	1       1	1;
	9	10	0.03181	0.0845	0       9900	0	1	1       0	1;
	9	14	0.12711	0.27038	0       9900	0	0	1       0	1;
	10	11	0.08205	0.19207	0       9900	0	0	1       0	1;
	12	13	0.22092	0.19988	0       9900	0	0	1       0	1;
	13	14	0.17093	0.34802	0       9900	0	0	1       0	1;
];


Y=zeros(n,n);
for b=1:20
    Y=AddLine(Y,branch(b,1),branch(b,2),1i*branch(b,3),1i*branch(b,4),branch(b,5),branch(b,9)*exp(-1i*(pi/180)*branch(b,10)));
end



%%
NetP=GenP-LoadP;
NetQ=GenQ-LoadQ;
Ym=zeros(n,n);
Yp=zeros(n,n);
maxiter=10;

VoltageMagnitudes=[];
VoltagePhases=[];
BusActivePowers=[];
BusReactivePowers=[];

for t=1:n
    for k=1:n
        Ym(t,k)=abs(Y(t,k));
        Yp(t,k)=phase(Y(t,k));
    end
end

%%    
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
   
    J=[J1 J2;J3 J4];

    for b=1:26
    J(b,14)=0;
    J(b,15)=0;
    J(b,18)=0;
    J(b,20)=0;
    end
    
    J(14,14)=1;
    J(15,15)=1;
    J(18,18)=1;
    J(20,20)=1;
    
    DeltaVoltage=inv(J)*DeltaPowers;
%     iteration
%     Vm
%     Vp
%     Y
%     CalcP
%     CalcQ
%     J
%     inv(J)
%     DeltaPowers
%     DeltaVoltage

    VoltageMagnitudes(:,iteration)=Vm;
    VoltagePhases(:,iteration)=Vp;
    BusActivePowers(:,iteration)=CalcP;
    BusReactivePowers(:,iteration)=CalcQ;
    
    
    Vp=Vp+[0; DeltaVoltage(1:n-1,1)];
    Vm=Vm+[0;0;0;DeltaVoltage(n+2,1);DeltaVoltage(n+3,1);0;DeltaVoltage(n+5,1);0;DeltaVoltage((n+7):2*(n-1),1)];
    GenP(2,1)=CalcP(2,1);
    GenP(3,1)=CalcP(3,1);
    GenP(6,1)=CalcP(6,1);
    GenP(8,1)=CalcP(8,1);
    GenQ(2,1)=CalcQ(2,1);
    GenQ(3,1)=CalcQ(3,1);
    GenQ(6,1)=CalcQ(6,1);
    GenQ(8,1)=CalcQ(8,1);
end

%%
s1=subplot(2,2,1);
s1=subplot(2,2,1);
plot(1:maxiter,VoltageMagnitudes(2,:),1:maxiter,VoltageMagnitudes(3,:),1:maxiter,VoltageMagnitudes(4,:),1:maxiter,VoltageMagnitudes(5,:),1:maxiter,VoltageMagnitudes(5,:),1:maxiter,VoltageMagnitudes(7,:),1:maxiter,VoltageMagnitudes(8,:),1:maxiter,VoltageMagnitudes(9,:),1:maxiter,VoltageMagnitudes(10,:),1:maxiter,VoltageMagnitudes(11,:),1:maxiter,VoltageMagnitudes(12,:),1:maxiter,VoltageMagnitudes(13,:),1:maxiter,VoltageMagnitudes(14,:));
title('Bus Voltage Magnitudes');
xlabel('Iteration Number');
legend({'2','3','4','5','6','7','8','9','10','11','12','13','14'},'Location','NorthEastOutside');axis([1 maxiter 0.88 1.12]);
% legend({'cos(x)','cos(2x)','cos(3x)','cos(4x)'},'Location','northwest','NumColumns',2)

subplot(2,2,2);
plot(VoltagePhases(n,:));
plot(1:maxiter,VoltagePhases(2,:),1:maxiter,VoltagePhases(3,:),1:maxiter,VoltagePhases(4,:),1:maxiter,VoltagePhases(5,:),1:maxiter,VoltagePhases(6,:),1:maxiter,VoltagePhases(7,:),1:maxiter,VoltagePhases(8,:),1:maxiter,VoltagePhases(9,:),1:maxiter,VoltagePhases(10,:),1:maxiter,VoltagePhases(11,:),1:maxiter,VoltagePhases(12,:),1:maxiter,VoltagePhases(13,:),1:maxiter,VoltagePhases(14,:));
title('Bus Voltage Phases');
xlabel('Iteration Number');
legend({'2','3','4','5','6','7','8','9','10','11','12','13','14'},'Location','NorthEastOutside');axis([1 maxiter -0.5 0.5]);

subplot(2,2,3);
plot(1:maxiter,BusActivePowers(2,:),1:maxiter,BusActivePowers(3,:),1:maxiter,BusActivePowers(4,:),1:maxiter,BusActivePowers(5,:),1:maxiter,BusActivePowers(6,:),1:maxiter,BusActivePowers(7,:),1:maxiter,BusActivePowers(8,:),1:maxiter,BusActivePowers(9,:),1:maxiter,BusActivePowers(10,:),1:maxiter,BusActivePowers(11,:),1:maxiter,BusActivePowers(12,:),1:maxiter,BusActivePowers(13,:),1:maxiter,BusActivePowers(14,:));
title('Bus Active Powers');
xlabel('Iteration Number');
legend({'2','3','4','5','6','7','8','9','10','11','12','13','14'},'Location','NorthEastOutside');axis([1 maxiter -1 1]);

subplot(2,2,4);
plot(1:maxiter,BusReactivePowers(2,:),1:maxiter,BusReactivePowers(3,:),1:maxiter,BusReactivePowers(4,:),1:maxiter,BusReactivePowers(5,:),1:maxiter,BusReactivePowers(6,:),1:maxiter,BusReactivePowers(7,:),1:maxiter,BusReactivePowers(8,:),1:maxiter,BusReactivePowers(9,:),1:maxiter,BusReactivePowers(10,:),1:maxiter,BusReactivePowers(11,:),1:maxiter,BusReactivePowers(12,:),1:maxiter,BusReactivePowers(13,:),1:maxiter,BusReactivePowers(14,:));
title('Bus Reactive Powers');
xlabel('Iteration Number');
legend({'2','3','4','5','6','7','8','9','10','11','12','13','14'},'Location','NorthEastOutside');axis([1 maxiter -1.5 1.5]);
