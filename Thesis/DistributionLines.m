clc;
clear all;
free_space_permeability=4*pi*(10^-7);
free_space_permittivity=8.854*(10^-12);
frequency=50;
Omega=2*pi*frequency;
Alpha=0;
Beta=Omega*sqrt(free_space_permeability*free_space_permittivity);
Gamma=Alpha+1i*Beta;

scale_min=-1;
scale_max=1;
scale_range=scale_max-scale_min;
step=0.05;
divisions=(scale_range/2)/step;

% Ix=zeros(2*divisions+1,2*divisions+1,2*divisions+1);
% Iy=zeros(2*divisions+1,2*divisions+1,2*divisions+1);
Iz=zeros(2*divisions+1,2*divisions+1,2*divisions+1);
Io=10;
for z=scale_min:step:scale_max
    Iz(round(divisions*0+divisions+1),round(divisions*0+divisions+1),round(divisions*z+divisions+1))=Io*exp(-Gamma*z);
    Iz(round(divisions*(-0.5)+divisions+1),round(divisions*(-0.5)+divisions+1),round(divisions*z+divisions+1))=Io*exp(-Gamma*z);
    Iz(round(divisions*0.5+divisions+1),round(divisions*0.5+divisions+1),round(divisions*z+divisions+1))=Io*exp(-Gamma*z);
end

Ax=zeros(2*divisions+1,2*divisions+1,2*divisions+1);
Ay=zeros(2*divisions+1,2*divisions+1,2*divisions+1);
Az=zeros(2*divisions+1,2*divisions+1,2*divisions+1);
z=0;
for x=scale_min:step:scale_max
    for y=scale_min:step:scale_max
        for z=-step:step:step
            for zs=scale_min:step:scale_max
                for ys=-0.5:0.5:0.5
                        xs=ys;
                        r=sqrt((x-xs)^2+(y-ys)^2+(z-zs)^2);
                        Az(round(divisions*x+divisions+1),round(divisions*y+divisions+1),round(divisions*z+divisions+1))=...
                            Az(round(divisions*x+divisions+1),round(divisions*y+divisions+1),round(divisions*z+divisions+1))+...
                            (free_space_permeability/(4*pi))*...
                            Iz(round(divisions*xs+divisions+1),round(divisions*ys+divisions+1),round(divisions*zs+divisions+1))*step*(1/r)*exp(-1i*Beta*r);
                    
                end
            end
        end
    end
    x;
end

z=0;
V=zeros(2*divisions+1,2*divisions+1,2*divisions+1);
for x=(scale_min+step):step:(scale_max-step)
    for y=(scale_min+step):step:(scale_max-step)
            V(round(divisions*x+divisions+1),round(divisions*y+divisions+1),round(divisions*z+divisions+1))=...
                (Az(round(divisions*x+divisions+1),round(divisions*y+divisions+1),round(divisions*z+divisions+2))...
                -Az(round(divisions*x+divisions+1),round(divisions*y+divisions+1),round(divisions*z+divisions+1)))...
                /(step*1i*Omega*free_space_permeability*free_space_permittivity);            
    end
    x
end

z=0;
Hx=zeros(2*divisions+1,2*divisions+1,2*divisions+1);
Hy=zeros(2*divisions+1,2*divisions+1,2*divisions+1);
Hz=zeros(2*divisions+1,2*divisions+1,2*divisions+1);
for x=(scale_min+step):step:(scale_max-step)
    for y=(scale_min+step):step:(scale_max-step)
            Hx(round(divisions*x+divisions+1),round(divisions*y+divisions+1),round(divisions*z+divisions+1))=(1/free_space_permeability)*...
                (Az(round(divisions*x+divisions+1),round(divisions*y+divisions+2),round(divisions*z+divisions+1))-...
                Az(round(divisions*x+divisions+1),round(divisions*y+divisions+1),round(divisions*z+divisions+1)));
            
            Hy(round(divisions*x+divisions+1),round(divisions*y+divisions+1),round(divisions*z+divisions+1))=-(1/free_space_permeability)*...
                (Az(round(divisions*x+divisions+2),round(divisions*y+divisions+1),round(divisions*z+divisions+1))-...
                Az(round(divisions*x+divisions+1),round(divisions*y+divisions+1),round(divisions*z+divisions+1)));
    end
    x
end

z=0;
Ex=zeros(2*divisions+1,2*divisions+1,2*divisions+1);
Ey=zeros(2*divisions+1,2*divisions+1,2*divisions+1);
Ez=zeros(2*divisions+1,2*divisions+1,2*divisions+1);
for x=(scale_min+step):step:(scale_max-step)
    for y=(scale_min+step):step:(scale_max-step)
            Ex(round(divisions*x+divisions+1),round(divisions*y+divisions+1),round(divisions*z+divisions+1))=-(1/(1i*Omega*free_space_permittivity))*...
                (Hy(round(divisions*x+divisions+1),round(divisions*y+divisions+1),round(divisions*z+divisions+2))-...
                Hy(round(divisions*x+divisions+1),round(divisions*y+divisions+1),round(divisions*z+divisions+1)));
            
            Ey(round(divisions*x+divisions+1),round(divisions*y+divisions+1),round(divisions*z+divisions+1))=-(1/(1i*Omega*free_space_permittivity))*...
                (Hx(round(divisions*x+divisions+1),round(divisions*y+divisions+1),round(divisions*z+divisions+2))-...
                Hx(round(divisions*x+divisions+1),round(divisions*y+divisions+1),round(divisions*z+divisions+1)));
            
            Ez(round(divisions*x+divisions+1),round(divisions*y+divisions+1),round(divisions*z+divisions+1))=(-(1/(1i*Omega*free_space_permittivity))*...
                (Hx(round(divisions*x+divisions+1),round(divisions*y+divisions+2),round(divisions*z+divisions+1))-...
                Hx(round(divisions*x+divisions+1),round(divisions*y+divisions+1),round(divisions*z+divisions+1))))...
                +((1/(1i*Omega*free_space_permittivity))*...
                (Hy(round(divisions*x+divisions+2),round(divisions*y+divisions+1),round(divisions*z+divisions+1))-...
                Hy(round(divisions*x+divisions+1),round(divisions*y+divisions+1),round(divisions*z+divisions+1))));
    end
    x
end

A=((Ax.*conj(Ax))+(Ay.*conj(Ay))+(Az.*conj(Az))).^0.5;
H=((Hx.*conj(Hx))+(Hy.*conj(Hy))+(Hz.*conj(Hz))).^0.5;
E=((Ex.*conj(Ex))+(Ey.*conj(Ey))+(Ez.*conj(Ez))).^0.5;


surf(-1:step:1,-1:step:1,abs(A(:,:,divisions+1)));
surf(-1:step:1,-1:step:1,abs(V(:,:,divisions+1)));
surf(-1:step:1,-1:step:1,abs(H(:,:,divisions+1)));
surf(-1:step:1,-1:step:1,abs(E(:,:,divisions+1)));