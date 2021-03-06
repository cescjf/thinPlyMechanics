function[nodes,edges,elements]=rve_mesh_F1_C1_tri1(isUpperBounded,isLowerBounded,isCohesive,Rf,Vff,tratio,theta,deltatheta,f1,f2,f3,N1,N2,N3,N4,N5,N6)
%%
%==============================================================================
% Copyright (c) 2016 Universit� de Lorraine & Lule� tekniska universitet
% Author: Luca Di Stasio <luca.distasio@gmail.com>
%                        <luca.distasio@ingpec.eu>
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
% 
% 
% Redistributions of source code must retain the above copyright
% notice, this list of conditions and the following disclaimer.
% Redistributions in binary form must reproduce the above copyright
% notice, this list of conditions and the following disclaimer in
% the documentation and/or other materials provided with the distribution
% Neither the name of the Universit� de Lorraine or Lule� tekniska universitet
% nor the names of its contributors may be used to endorse or promote products
% derived from this software without specific prior written permission.
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.
%==============================================================================
%
%  DESCRIPTION
%  
%  A function to perform 
%
%  Input: isBounded = true; % flag for model type
% 
% Rf = 1; %[10^-6 m] Fiber diameter in micrometers. 
%         % Carbon fibers have a tipical diameter between 5 and 10 
%         % micrometers, glass fibers between 3 and 20
% Vff = 0.6; %[-] Fiber volume fraction
% tratio = 0.6; % [-] ratio of [0�] ply thickness to [90�] ply thickness
% theta = 30; %[�] angular position of crack
% theta = theta*pi/180;
% deltatheta = 10; %[�] angular aperture of crack
% deltatheta = deltatheta*pi/180;
% 
% f1 = 0.5; %[-] Innermost square mesh region side defined by 2*f1*Rf
% f2 = 0.77; %[-] Inner circular mesh region radius defined by f2*Rf
% f3 = 1.05; %[-] Outer circular mesh region radius defined by f2*Rf
% 
% %Number of elements:
% N1 = 20; %[-] Notice that angular resolution is equal to 90�/N1
% N2 = 10; %[-] 
% N3 = 8; %[-] 
% N4 = 5; %[-] 
% N5 = 20; %[-] 
% N6 = 20; %[-] 
%  Output: 
%
%%

%-------------------------------------------------------------------------%
%-------------------------------------------------------------------------%
%-                          Input Data                                   -%
%-------------------------------------------------------------------------%
%-------------------------------------------------------------------------%

l = 0.5*Rf*sqrt(pi/Vff);

%-------------------------------------------------------------------------%
%-------------------------------------------------------------------------%
%-                        Mesh Generation                                -%
%-------------------------------------------------------------------------%
%-------------------------------------------------------------------------%

%-------------------------------------------------------------------------%
%-                   Section 1 (innermost part)                          -%
%-------------------------------------------------------------------------%

part1 = structSquare(0,0,2*f1*Rf,N1);

%-------------------------------------------------------------------------%
%-                           Section 2                                   -%
%-------------------------------------------------------------------------%

A = [f2*Rf*cos(5*pi/4) f2*Rf*sin(5*pi/4)];
B = [f2*Rf*cos(7*pi/4) f2*Rf*sin(7*pi/4)];
C = [f1*Rf -f1*Rf];
D = [-f1*Rf -f1*Rf];

part2 = generatelattice2D(A(1),N1+1,(B(1)-A(1))/N1,A(2),N2+1,(D(2)-A(2))/N2,A(1),B(1),N1+1,A(2),D(2),N2+1);

e1 = zeros(N1+1,6);
e2 = zeros(N2+1,6);
e3 = zeros(N1+1,6);
e4 = zeros(N2+1,6);
c1 = zeros(1,8);
c2 = zeros(1,8);
c3 = zeros(1,8);
c4 = zeros(1,8);
 
c1(1,1:2) = A;
c2(1,1:2) = B;
c3(1,1:2) = C;
c4(1,1:2) = D;

thetas = (5*pi/4:(pi/2)/N1:7*pi/4)';
e1(:,1) = f2*Rf*cos(thetas);
e1(:,2) = f2*Rf*sin(thetas);

e2(:,1) = (c2(1):(c3(1)-c2(1))/N2:c3(1))';
e2(:,2) = (c2(2):(c3(2)-c2(2))/N2:c3(2))';

xs = (c4(1):(c3(1)-c4(1))/N1:c3(1))';
e3(:,1) = xs;
e3(:,2) = c3(2)*ones(length(xs),1);

e4(:,1) = (c1(1):(c4(1)-c1(1))/N2:c4(1))';
e4(:,2) = (c1(2):(c4(2)-c1(2))/N2:c4(2))';

itmax = 10;
tol = 10^-6;

part2 = transfiniteinterpolation2D((N1+1)*(N2+1),part2(:,1:2),A(1),B(1),A(2),D(2),N1+1,N2+1,1,e1,e2,e3,e4,c1,c2,c3,c4);

[indicesbulk,indicesinternalbulk,indicesE1,indicesE2,indicesE3,indicesE4,indicesexternalE1,indicesexternalE2,indicesexternalE3,indicesexternalE4,indicesinternalE1,indicesinternalE2,indicesinternalE3,indicesinternalE4,indicesC1,indicesC2,indicesC3,indicesC4,indicesinternalC1,indicesinternalC2,indicesinternalC3,indicesinternalC4] = getindices2D(N1+1,N2+1);
[temp1,temp2,temp3,firstdevneighbours] = build_neighbourhoods2D((N1+1)*(N2+1),N1+1,0,0,0,0,0,indicesbulk,indicesinternalbulk,indicesE1,indicesE2,indicesE3,indicesE4,indicesexternalE1,indicesexternalE2,indicesexternalE3,indicesexternalE4,indicesinternalE1,indicesinternalE2,indicesinternalE3,indicesinternalE4,indicesC1,indicesC2,indicesC3,indicesC4,indicesinternalC1,indicesinternalC2,indicesinternalC3,indicesinternalC4);
part2 = sparseellipticgridgen2D(N1+1,(N1+1)*(N2+1),part2,[(B(1)-A(1))/N1,(D(2)-A(2))/N2],0,0,indicesbulk,indicesE1,indicesE2,indicesE3,indicesE4,indicesC1,indicesC2,indicesC3,indicesC4,firstdevneighbours,itmax,tol,0);

clear temp1 temp2 temp3

part2 = part2(1:N2*(N1+1),3:4);

temp = part2;

part2 = zeros(N1*N2,2);

for j=1:N2
    part2((j-1)*N1+1:j*N1,:) = temp((j-1)*(N1+1)+1:j*(N1+1)-1,:);
end

part2a = part2;
part2b = rotate2D(part2,pi/2);
part2c = rotate2D(part2,pi);
part2d = rotate2D(part2,3*pi/2);

part2 = zeros(4*N1*N2,2);

for i=1:N2
    part2((i-1)*4*N1+1:(i-1)*4*N1+N1,:) = part2a((i-1)*N1+1:i*N1,:);
    part2((i-1)*4*N1+N1+1:(i-1)*4*N1+2*N1,:) = part2b((i-1)*N1+1:i*N1,:);
    part2((i-1)*4*N1+2*N1+1:(i-1)*4*N1+3*N1,:) = part2c((i-1)*N1+1:i*N1,:);
    part2((i-1)*4*N1+3*N1+1:(i-1)*4*N1+4*N1,:) = part2d((i-1)*N1+1:i*N1,:);
end

%-------------------------------------------------------------------------%
%-                           Section 3                                   -%
%-------------------------------------------------------------------------%

part3 = circular_arc(0,0,Rf,f2*Rf,5*pi/4,7*pi/4,N3,N1);
part3 = part3(1:N3*(N1+1),:);

part3 = part3(1:N3*(N1+1),1:2);

temp = part3;

part3 = zeros(N1*N3,2);

for j=1:N3
    part3((j-1)*N1+1:j*N1,:) = temp((j-1)*(N1+1)+1:j*(N1+1)-1,:);
end

part3a = part3;
part3b = rotate2D(part3,pi/2);
part3c = rotate2D(part3,pi);
part3d = rotate2D(part3,3*pi/2);

part3 = zeros(4*N1*N3,2);

for i=1:N3
    part3((i-1)*4*N1+1:(i-1)*4*N1+N1,:) = part3a((i-1)*N1+1:i*N1,:);
    part3((i-1)*4*N1+N1+1:(i-1)*4*N1+2*N1,:) = part3b((i-1)*N1+1:i*N1,:);
    part3((i-1)*4*N1+2*N1+1:(i-1)*4*N1+3*N1,:) = part3c((i-1)*N1+1:i*N1,:);
    part3((i-1)*4*N1+3*N1+1:(i-1)*4*N1+4*N1,:) = part3d((i-1)*N1+1:i*N1,:);
end

%-------------------------------------------------------------------------%
%-                           Section 4                                   -%
%-------------------------------------------------------------------------%

part4 = circular_arc(0,0,f3*Rf,Rf,5*pi/4,7*pi/4,N4,N1);

temp = part4;

part4 = zeros(N1*(N4+1),2);

for j=1:N4+1
    part4((j-1)*N1+1:j*N1,:) = temp((j-1)*(N1+1)+1:j*(N1+1)-1,:);
end

part4a = part4;
part4b = rotate2D(part4,pi/2);
part4c = rotate2D(part4,pi);
part4d = rotate2D(part4,3*pi/2);

part4 = zeros(4*N1*(N4+1),2);

for i=1:N4+1
    part4((i-1)*4*N1+1:(i-1)*4*N1+N1,:) = part4a((i-1)*N1+1:i*N1,:);
    part4((i-1)*4*N1+N1+1:(i-1)*4*N1+2*N1,:) = part4b((i-1)*N1+1:i*N1,:);
    part4((i-1)*4*N1+2*N1+1:(i-1)*4*N1+3*N1,:) = part4c((i-1)*N1+1:i*N1,:);
    part4((i-1)*4*N1+3*N1+1:(i-1)*4*N1+4*N1,:) = part4d((i-1)*N1+1:i*N1,:);
end

%-------------------------------------------------------------------------%
%-                   Section 5 (outermost part)                          -%
%-------------------------------------------------------------------------%

A = [-l -l];
B = [l -l];
C = [f3*Rf*cos(7*pi/4) f3*Rf*sin(7*pi/4)];
D = [f3*Rf*cos(5*pi/4) f3*Rf*sin(5*pi/4)];


part5 = generatelattice2D(A(1),N1+1,(B(1)-A(1))/N1,A(2),N5+1,(D(2)-A(2))/N5,A(1),B(1),N1+1,A(2),D(2),N5+1);

e1 = zeros(N1+1,6);
e2 = zeros(N5+1,6);
e3 = zeros(N1+1,6);
e4 = zeros(N5+1,6);
c1 = zeros(1,8);
c2 = zeros(1,8);
c3 = zeros(1,8);
c4 = zeros(1,8);
 
c1(1,1:2) = A;
c2(1,1:2) = B;
c3(1,1:2) = C;
c4(1,1:2) = D;

xs = (c1(1):(c2(1)-c1(1))/N1:c2(1))';
e1(:,1) = xs;
e1(:,2) = c1(2)*ones(length(xs),1);

e2(:,1) = (c2(1):(c3(1)-c2(1))/N5:c3(1))';
e2(:,2) = (c2(2):(c3(2)-c2(2))/N5:c3(2))';

thetas = (5*pi/4:(pi/2)/N1:7*pi/4)';
e3(:,1) = f3*Rf*cos(thetas);
e3(:,2) = f3*Rf*sin(thetas);

e4(:,1) = (c1(1):(c4(1)-c1(1))/N5:c4(1))';
e4(:,2) = (c1(2):(c4(2)-c1(2))/N5:c4(2))';

itmax = 10;
tol = 10^-6;

part5 = transfiniteinterpolation2D((N1+1)*(N5+1),part5(:,1:2),A(1),B(1),A(2),D(2),N1+1,N5+1,1,e1,e2,e3,e4,c1,c2,c3,c4);

[indicesbulk,indicesinternalbulk,indicesE1,indicesE2,indicesE3,indicesE4,indicesexternalE1,indicesexternalE2,indicesexternalE3,indicesexternalE4,indicesinternalE1,indicesinternalE2,indicesinternalE3,indicesinternalE4,indicesC1,indicesC2,indicesC3,indicesC4,indicesinternalC1,indicesinternalC2,indicesinternalC3,indicesinternalC4] = getindices2D(N1+1,N5+1);
[temp1,temp2,temp3,firstdevneighbours] = build_neighbourhoods2D((N1+1)*(N5+1),N1+1,0,0,0,0,0,indicesbulk,indicesinternalbulk,indicesE1,indicesE2,indicesE3,indicesE4,indicesexternalE1,indicesexternalE2,indicesexternalE3,indicesexternalE4,indicesinternalE1,indicesinternalE2,indicesinternalE3,indicesinternalE4,indicesC1,indicesC2,indicesC3,indicesC4,indicesinternalC1,indicesinternalC2,indicesinternalC3,indicesinternalC4);
part5 = sparseellipticgridgen2D(N1+1,(N1+1)*(N5+1),part5,[(B(1)-A(1))/N1,(D(2)-A(2))/N2],0,0,indicesbulk,indicesE1,indicesE2,indicesE3,indicesE4,indicesC1,indicesC2,indicesC3,indicesC4,firstdevneighbours,itmax,tol,0);

clear temp1 temp2 temp3

part5 = part5(1:N5*(N1+1),3:4);

temp = part5;

part5 = zeros(N1*N5,2);

for j=1:N5
    part5((j-1)*N1+1:j*N1,:) = temp((j-1)*(N1+1)+1:j*(N1+1)-1,:);
end

part5a = part5;
part5b = rotate2D(part5,pi/2);
part5c = rotate2D(part5,pi);
part5d = rotate2D(part5,3*pi/2);

part5 = zeros(4*N1*N5,2);

for i=1:N5
    part5((i-1)*4*N1+1:(i-1)*4*N1+N1,:) = part5a((i-1)*N1+1:i*N1,:);
    part5((i-1)*4*N1+N1+1:(i-1)*4*N1+2*N1,:) = part5b((i-1)*N1+1:i*N1,:);
    part5((i-1)*4*N1+2*N1+1:(i-1)*4*N1+3*N1,:) = part5c((i-1)*N1+1:i*N1,:);
    part5((i-1)*4*N1+3*N1+1:(i-1)*4*N1+4*N1,:) = part5d((i-1)*N1+1:i*N1,:);
end

%-------------------------------------------------------------------------%
%-            Section 6 (bounding 0� layer, if present)                  -%
%-------------------------------------------------------------------------%

if isUpperBounded && isLowerBounded
    part6up = structRectangle(0,l+0.5*tratio*l,2*l,tratio*l,N1,N6);
    part6bot = rotate2D(part6up,pi);
    part6 = [part6bot;...
            part6up];
elseif isUpperBounded
    part6up = structRectangle(0,l+0.5*tratio*l,2*l,tratio*l,N1,N6);
    part6 = part6up;
elseif isLowerBounded
    part6up = structRectangle(0,l+0.5*tratio*l,2*l,tratio*l,N1,N6);
    part6bot = rotate2D(part6up,pi);
    part6 = part6bot;
end

%-------------------------------------------------------------------------%
%-                              Overall                                  -%
%-------------------------------------------------------------------------%

nodes = [part5;...
            part4;...
            part3;...
            part2;...
            part1];
        
if isUpperBounded || isLowerBounded
    nodes = [nodes;...
            part6];
end

%-------------------------------------------------------------------------%
%-                         Elements & Edges                              -%
%-------------------------------------------------------------------------%

elements1 = zeros(4*N1*(N5+N4),4);
for j=1:N5+N4
    elements1((j-1)*4*N1+1:j*4*N1,1) = ((j-1)*4*N1+1:j*4*N1)';
    elements1((j-1)*4*N1+1:j*4*N1-1,2) = ((j-1)*4*N1+2:j*4*N1)';
    elements1(j*4*N1,2) = (j-1)*4*N1+1;
    elements1((j-1)*4*N1+1:j*4*N1-1,3) = (j*4*N1+2:(j+1)*4*N1)';
    elements1(j*4*N1,3) = j*4*N1+1;
    elements1((j-1)*4*N1+1:j*4*N1,4) = (j*4*N1+1:(j+1)*4*N1)';
end

edges1 = zeros(2*(4*N1)*(N5+N4)+4*N1,2);
for j=1:N5+N4
    edges1((j-1)*(2*(4*N1))+1:2:j*(2*(4*N1))-1,1) = elements1((j-1)*4*N1+1:j*4*N1,1);
    edges1((j-1)*(2*(4*N1))+1:2:j*(2*(4*N1))-1,2) = elements1((j-1)*4*N1+1:j*4*N1,4);
    edges1((j-1)*(2*(4*N1))+2:2:j*(2*(4*N1)),1) = elements1((j-1)*4*N1+1:j*4*N1,1);
    edges1((j-1)*(2*(4*N1))+2:2:j*(2*(4*N1)),2) = elements1((j-1)*4*N1+1:j*4*N1,2);
end
edges1((2*(4*N1))*(N5+N4)+1:(2*(4*N1))*(N5+N4)+4*N1,1) = elements1(((N5+N4)-1)*4*N1+1:(N5+N4)*4*N1,4);
edges1((2*(4*N1))*(N5+N4)+1:(2*(4*N1))*(N5+N4)+4*N1,2) = elements1(((N5+N4)-1)*4*N1+1:(N5+N4)*4*N1,3);

elements2 = zeros(4*N1*(N3+N2),4);
for j=1:N3+N2-1
    elements2((j-1)*4*N1+1:j*4*N1,1) = 4*N1*(N5+N4+1) + ((j-1)*4*N1+1:j*4*N1)';
    elements2((j-1)*4*N1+1:j*4*N1-1,2) = 4*N1*(N5+N4+1) + ((j-1)*4*N1+2:j*4*N1)';
    elements2(j*4*N1,2) = 4*N1*(N5+N4+1)+(j-1)*4*N1+1;
    elements2((j-1)*4*N1+1:j*4*N1-1,3) = 4*N1*(N5+N4+1) + (j*4*N1+2:(j+1)*4*N1)';
    elements2(j*4*N1,3) = 4*N1*(N5+N4+1) + j*4*N1+1;
    elements2((j-1)*4*N1+1:j*4*N1,4) = 4*N1*(N5+N4+1) + (j*4*N1+1:(j+1)*4*N1)';
end
elements2((N3+N2-1)*4*N1+1:(N3+N2)*4*N1,1) = 4*N1*(N5+N4+1) + (((N3+N2)-1)*4*N1+1:(N3+N2)*4*N1)';
elements2((N3+N2-1)*4*N1+1:(N3+N2)*4*N1-1,2) = 4*N1*(N5+N4+1) + (((N3+N2)-1)*4*N1+2:(N3+N2)*4*N1)';
elements2((N3+N2)*4*N1,2) = 4*N1*(N5+N4+1)+((N3+N2)-1)*4*N1+1;

elements2((N3+N2-1)*4*N1+1:(N3+N2-1)*4*N1+N1,3) = 4*N1*(N5+N4+1) + 4*N1*(N3+N2) + (2:N1+1)';
elements2((N3+N2-1)*4*N1+N1+1:(N3+N2-1)*4*N1+2*N1,3) = 4*N1*(N5+N4+1) + 4*N1*(N3+N2) + (2*(N1+1):N1+1:(N1+1)*(N1+1))';
elements2((N3+N2-1)*4*N1+2*N1+1:(N3+N2-1)*4*N1+3*N1,3) = 4*N1*(N5+N4+1) + 4*N1*(N3+N2) + N1*(N1+1) + (N1:-1:1)';
elements2((N3+N2-1)*4*N1+3*N1+1:(N3+N2-1)*4*N1+4*N1,3) = 4*N1*(N5+N4+1) + 4*N1*(N3+N2) + ((N1-1)*(N1+1)+1:-(N1+1):1)';

elements2((N3+N2-1)*4*N1+1:(N3+N2-1)*4*N1+N1,4) = 4*N1*(N5+N4+1) + 4*N1*(N3+N2) + (1:N1)';
elements2((N3+N2-1)*4*N1+N1+1:(N3+N2-1)*4*N1+2*N1,4) = 4*N1*(N5+N4+1) + 4*N1*(N3+N2) + ((N1+1):N1+1:N1*(N1+1))';
elements2((N3+N2-1)*4*N1+2*N1+1:(N3+N2-1)*4*N1+3*N1,4) = 4*N1*(N5+N4+1) + 4*N1*(N3+N2) + N1*(N1+1) + (N1+1:-1:2)';
elements2((N3+N2-1)*4*N1+3*N1+1:(N3+N2-1)*4*N1+4*N1,4) = 4*N1*(N5+N4+1) + 4*N1*(N3+N2) + (N1*(N1+1)+1:-(N1+1):(N1+1)+1)';

edges2 = zeros(2*(4*N1)*(N3+N2),2);
for j=1:N3+N2
    edges2((j-1)*(2*(4*N1))+1:2:j*(2*(4*N1))-1,1) = elements2((j-1)*4*N1+1:j*4*N1,1);
    edges2((j-1)*(2*(4*N1))+1:2:j*(2*(4*N1))-1,2) = elements2((j-1)*4*N1+1:j*4*N1,4);
    edges2((j-1)*(2*(4*N1))+2:2:j*(2*(4*N1)),1) = elements2((j-1)*4*N1+1:j*4*N1,1);
    edges2((j-1)*(2*(4*N1))+2:2:j*(2*(4*N1)),2) = elements2((j-1)*4*N1+1:j*4*N1,2);
end

elements3 = zeros(N1*N1,4);
for j=1:N1
   elements3((j-1)*N1+1:j*N1,1) =  4*N1*(N5+N4+1) + 4*N1*(N3+N2) + (j-1)*(N1+1) + (1:N1)';
   elements3((j-1)*N1+1:j*N1,2) =  4*N1*(N5+N4+1) + 4*N1*(N3+N2) + (j-1)*(N1+1) + (2:N1+1)';
   elements3((j-1)*N1+1:j*N1,3) =  4*N1*(N5+N4+1) + 4*N1*(N3+N2) + j*(N1+1) + (2:N1+1)';
   elements3((j-1)*N1+1:j*N1,4) =  4*N1*(N5+N4+1) + 4*N1*(N3+N2) + j*(N1+1) + (1:N1)';
end

edges3 = zeros((2*N1+1)*N1+N1,2);
for j=1:N1
    edges3((j-1)*(2*N1+1)+1:2:j*(2*N1+1)-2,1) = elements3((j-1)*N1+1:j*N1,1);
    edges3((j-1)*(2*N1+1)+1:2:j*(2*N1+1)-2,2) = elements3((j-1)*N1+1:j*N1,4);
    edges3((j-1)*(2*N1+1)+2:2:j*(2*N1+1)-1,1) = elements3((j-1)*N1+1:j*N1,1);
    edges3((j-1)*(2*N1+1)+2:2:j*(2*N1+1)-1,2) = elements3((j-1)*N1+1:j*N1,2);
    edges3(j*(2*N1+1),1) = elements3(j*N1,2);
    edges3(j*(2*N1+1),2) = elements3(j*N1,3);
end
edges3((2*N1+1)*N1+1:(2*N1+1)*N1+N1,1) = elements3((N1-1)*N1+1:N1*N1,4);
edges3((2*N1+1)*N1+1:(2*N1+1)*N1+N1,2) = elements3((N1-1)*N1+1:N1*N1,3);

tri1 = [];

for i=1:size(elements1,1)
    if rand()>0.5
        tri1 = [tri1;...
                elements1(i,1) elements1(i,2) elements1(i,3);...
                elements1(i,1) elements1(i,3) elements1(i,4)];
        edges1 = [edges1;...
                  elements1(i,1) elements1(i,3)];
    else
        tri1 = [tri1;...
                elements1(i,1) elements1(i,2) elements1(i,4);...
                elements1(i,2) elements1(i,3) elements1(i,4)];
        edges1 = [edges1;...
                  elements1(i,4) elements1(i,2)];
    end
end

tri2 = [];

for i=1:size(elements2,1)
    if rand()>0.5
        tri2 = [tri2;...
                elements2(i,1) elements2(i,2) elements2(i,3);...
                elements2(i,1) elements2(i,3) elements2(i,4)];
        edges2 = [edges2;...
                  elements2(i,1) elements2(i,3)];
    else
        tri2 = [tri2;...
                elements2(i,1) elements2(i,2) elements2(i,4);...
                elements2(i,2) elements2(i,3) elements2(i,4)];
        edges2 = [edges2;...
                  elements2(i,4) elements2(i,2)];
    end
end

tri3 = [];

for i=1:size(elements3,1)
    if rand()>0.5
        tri3 = [tri3;...
                elements3(i,1) elements3(i,2) elements3(i,3);...
                elements3(i,1) elements3(i,3) elements3(i,4)];
        edges3 = [edges3;...
                  elements3(i,1) elements3(i,3)];
    else
        tri3 = [tri3;...
                elements3(i,1) elements3(i,2) elements3(i,4);...
                elements3(i,2) elements3(i,3) elements3(i,4)];
        edges3 = [edges3;...
                  elements3(i,4) elements3(i,2)];
    end
end

if isCohesive
    cohesiveEl = zeros(4*N1,4);
    cohesiveEl(:,1) = (N5+N4)*4*N1+1:((N5+N4)+1)*4*N1;
    cohesiveEl(1:end-1,2) = (N5+N4)*4*N1+2:((N5+N4)+1)*4*N1;
    cohesiveEl(end,2) = (N5+N4)*4*N1+1;
    cohesiveEl(1:end-1,3) = 4*N1*(N5+N4+1) + (2:4*N1);
    cohesiveEl(end,3) = 4*N1*(N5+N4+1) + 1;
    cohesiveEl(:,4) = 4*N1*(N5+N4+1) + (1:4*N1);
    
    cohesiveEd = zeros(4*N1,2);
    cohesiveEd(1:4*N1,1) = cohesiveEl(1:4*N1,1);
    cohesiveEd(1:4*N1,2) = cohesiveEl(1:4*N1,4);

    elements = [tri1;...
                cohesiveEl;...
                tri2;...
                tri3];
    edges = [edges1;...
             cohesiveEd;...
             edges2;...
             edges3];
else
    elements = [tri1;...
                tri2;...
                tri3];
    edges = [edges1;...
             edges2;...
             edges3];
end

if isUpperBounded && isLowerBounded
    boundedBot = zeros(N1*N6,4);
    boundedUp = zeros(N1*N6,4);
    for j=1:N6
        boundedBot((j-1)*N1+1:j*N1,1) = 4*N1*(N5+N4+1) + 4*N1*(N3+N2) + (N1+1)*(N1+1) + (j-1)*(N1+1) + (1:N1)';
        boundedBot((j-1)*N1+1:j*N1,2) = 4*N1*(N5+N4+1) + 4*N1*(N3+N2) + (N1+1)*(N1+1) + (j-1)*(N1+1) + (2:N1+1)';
        boundedBot((j-1)*N1+1:j*N1,3) = 4*N1*(N5+N4+1) + 4*N1*(N3+N2) + (N1+1)*(N1+1) + j*(N1+1) + (2:N1+1)';
        boundedBot((j-1)*N1+1:j*N1,4) = 4*N1*(N5+N4+1) + 4*N1*(N3+N2) + (N1+1)*(N1+1) + j*(N1+1) + (1:N1)';
        
        boundedUp((j-1)*N1+1:j*N1,1) = 4*N1*(N5+N4+1) + 4*N1*(N3+N2) + (N1+1)*(N1+1) + (N1+1)*(N1+1) + (j-1)*(N1+1) + (1:N1)';
        boundedUp((j-1)*N1+1:j*N1,2) = 4*N1*(N5+N4+1) + 4*N1*(N3+N2) + (N1+1)*(N1+1) + (N1+1)*(N1+1) + (j-1)*(N1+1) + (2:N1+1)';
        boundedUp((j-1)*N1+1:j*N1,3) = 4*N1*(N5+N4+1) + 4*N1*(N3+N2) + (N1+1)*(N1+1) + (N1+1)*(N1+1) + j*(N1+1) + (2:N1+1)';
        boundedUp((j-1)*N1+1:j*N1,4) = 4*N1*(N5+N4+1) + 4*N1*(N3+N2) + (N1+1)*(N1+1) + (N1+1)*(N1+1) + j*(N1+1) + (1:N1)';
    end
                
    edgesBot = zeros((2*N1+1)*N6+N1,2);
    edgesUp = zeros((2*N1+1)*N6+N1,2);
    for j=1:N6
        edgesBot((j-1)*(2*N1+1)+1:2:j*(2*N1+1)-2,1) = boundedBot((j-1)*N1+1:j*N1,1);
        edgesBot((j-1)*(2*N1+1)+1:2:j*(2*N1+1)-2,2) = boundedBot((j-1)*N1+1:j*N1,4);
        edgesBot((j-1)*(2*N1+1)+2:2:j*(2*N1+1)-1,1) = boundedBot((j-1)*N1+1:j*N1,1);
        edgesBot((j-1)*(2*N1+1)+2:2:j*(2*N1+1)-1,2) = boundedBot((j-1)*N1+1:j*N1,2);
        edgesBot(j*(2*N1+1),1) = boundedBot(j*N1,2);
        edgesBot(j*(2*N1+1),2) = boundedBot(j*N1,3);
        
        edgesUp((j-1)*(2*N1+1)+1:2:j*(2*N1+1)-2,1) = boundedUp((j-1)*N1+1:j*N1,1);
        edgesUp((j-1)*(2*N1+1)+1:2:j*(2*N1+1)-2,2) = boundedUp((j-1)*N1+1:j*N1,4);
        edgesUp((j-1)*(2*N1+1)+2:2:j*(2*N1+1)-1,1) = boundedUp((j-1)*N1+1:j*N1,1);
        edgesUp((j-1)*(2*N1+1)+2:2:j*(2*N1+1)-1,2) = boundedUp((j-1)*N1+1:j*N1,2);
        edgesUp(j*(2*N1+1),1) = boundedUp(j*N1,2);
        edgesUp(j*(2*N1+1),2) = boundedUp(j*N1,3);
    end
    edgesBot((2*N1+1)*N6+1:(2*N1+1)*N6+N1,1) = boundedBot((N6-1)*N1+1:N1*N6,4);
    edgesBot((2*N1+1)*N6+1:(2*N1+1)*N6+N1,2) = boundedBot((N6-1)*N1+1:N1*N6,3);
    edgesUp((2*N1+1)*N6+1:(2*N1+1)*N6+N1,1) = boundedUp((N6-1)*N1+1:N1*N6,4);
    edgesUp((2*N1+1)*N6+1:(2*N1+1)*N6+N1,2) = boundedUp((N6-1)*N1+1:N1*N6,3);
    
    triBot = [];

    for i=1:size(boundedBot,1)
        if rand()>0.5
            triBot = [triBot;...
                    boundedBot(i,1) boundedBot(i,2) boundedBot(i,3);...
                    boundedBot(i,1) boundedBot(i,3) boundedBot(i,4)];
            edgesBot = [edgesBot;...
                      boundedBot(i,1) boundedBot(i,3)];
        else
            triBot = [triBot;...
                    boundedBot(i,1) boundedBot(i,2) boundedBot(i,4);...
                    boundedBot(i,2) boundedBot(i,3) boundedBot(i,4)];
            edgesBot = [edgesBot;...
                      boundedBot(i,4) boundedBot(i,2)];
        end
    end

    triUp = [];

    for i=1:size(boundedUp,1)
        if rand()>0.5
            triUp = [triUp;...
                    boundedUp(i,1) boundedUp(i,2) boundedUp(i,3);...
                    boundedUp(i,1) boundedUp(i,3) boundedUp(i,4)];
            edgesUp = [edgesUp;...
                      boundedUp(i,1) boundedUp(i,3)];
        else
            triUp = [triUp;...
                    boundedUp(i,1) boundedUp(i,2) boundedUp(i,4);...
                    boundedUp(i,2) boundedUp(i,3) boundedUp(i,4)];
            edgesUp = [edgesUp;...
                      boundedUp(i,4) boundedUp(i,2)];
        end
    end

    elements = [elements;...
                triUp;...
                triBot];
            
    edges = [edges;...
             edgesUp;...
             edgesBot];
elseif isUpperBounded
    boundedUp = zeros(N1*N6,4);
    for j=1:N6
        boundedUp((j-1)*N1+1:j*N1,1) = 4*N1*(N5+N4+1) + 4*N1*(N3+N2) + (N1+1)*(N1+1) + (j-1)*(N1+1) + (1:N1)';
        boundedUp((j-1)*N1+1:j*N1,2) = 4*N1*(N5+N4+1) + 4*N1*(N3+N2) + (N1+1)*(N1+1) + (j-1)*(N1+1) + (2:N1+1)';
        boundedUp((j-1)*N1+1:j*N1,3) = 4*N1*(N5+N4+1) + 4*N1*(N3+N2) + (N1+1)*(N1+1) + j*(N1+1) + (2:N1+1)';
        boundedUp((j-1)*N1+1:j*N1,4) = 4*N1*(N5+N4+1) + 4*N1*(N3+N2) + (N1+1)*(N1+1) + j*(N1+1) + (1:N1)';
    end
        
            
    edgesUp = zeros((2*N1+1)*N6+N1,2);
    for j=1:N6
        edgesUp((j-1)*(2*N1+1)+1:2:j*(2*N1+1)-2,1) = boundedUp((j-1)*N1+1:j*N1,1);
        edgesUp((j-1)*(2*N1+1)+1:2:j*(2*N1+1)-2,2) = boundedUp((j-1)*N1+1:j*N1,4);
        edgesUp((j-1)*(2*N1+1)+2:2:j*(2*N1+1)-1,1) = boundedUp((j-1)*N1+1:j*N1,1);
        edgesUp((j-1)*(2*N1+1)+2:2:j*(2*N1+1)-1,2) = boundedUp((j-1)*N1+1:j*N1,2);
        edgesUp(j*(2*N1+1),1) = boundedUp(j*N1,2);
        edgesUp(j*(2*N1+1),2) = boundedUp(j*N1,3);
    end
    edgesUp((2*N1+1)*N6+1:(2*N1+1)*N6+N1,1) = boundedUp((N6-1)*N1+1:N1*N6,4);
    edgesUp((2*N1+1)*N6+1:(2*N1+1)*N6+N1,2) = boundedUp((N6-1)*N1+1:N1*N6,3);
    
    triUp = [];

    for i=1:size(boundedUp,1)
        if rand()>0.5
            triUp = [triUp;...
                    boundedUp(i,1) boundedUp(i,2) boundedUp(i,3);...
                    boundedUp(i,1) boundedUp(i,3) boundedUp(i,4)];
            edgesUp = [edgesUp;...
                      boundedUp(i,1) boundedUp(i,3)];
        else
            triUp = [triUp;...
                    boundedUp(i,1) boundedUp(i,2) boundedUp(i,4);...
                    boundedUp(i,2) boundedUp(i,3) boundedUp(i,4)];
            edgesUp = [edgesUp;...
                      boundedUp(i,4) boundedUp(i,2)];
        end
    end
    
    elements = [elements;...
                triUp];
            
    edges = [edges;...
             edgesUp];
elseif isLowerBounded
    boundedBot = zeros(N1*N6,4);
    for j=1:N6
        boundedBot((j-1)*N1+1:j*N1,1) = 4*N1*(N5+N4+1) + 4*N1*(N3+N2) + (N1+1)*(N1+1) + (j-1)*(N1+1) + (1:N1)';
        boundedBot((j-1)*N1+1:j*N1,2) = 4*N1*(N5+N4+1) + 4*N1*(N3+N2) + (N1+1)*(N1+1) + (j-1)*(N1+1) + (2:N1+1)';
        boundedBot((j-1)*N1+1:j*N1,3) = 4*N1*(N5+N4+1) + 4*N1*(N3+N2) + (N1+1)*(N1+1) + j*(N1+1) + (2:N1+1)';
        boundedBot((j-1)*N1+1:j*N1,4) = 4*N1*(N5+N4+1) + 4*N1*(N3+N2) + (N1+1)*(N1+1) + j*(N1+1) + (1:N1)';
    end
                    
    edgesBot = zeros((2*N1+1)*N6+N1,2);
    for j=1:N6
        edgesBot((j-1)*(2*N1+1)+1:2:j*(2*N1+1)-2,1) = boundedBot((j-1)*N1+1:j*N1,1);
        edgesBot((j-1)*(2*N1+1)+1:2:j*(2*N1+1)-2,2) = boundedBot((j-1)*N1+1:j*N1,4);
        edgesBot((j-1)*(2*N1+1)+2:2:j*(2*N1+1)-1,1) = boundedBot((j-1)*N1+1:j*N1,1);
        edgesBot((j-1)*(2*N1+1)+2:2:j*(2*N1+1)-1,2) = boundedBot((j-1)*N1+1:j*N1,2);
        edgesBot(j*(2*N1+1),1) = boundedBot(j*N1,2);
        edgesBot(j*(2*N1+1),2) = boundedBot(j*N1,3);
    end
    edgesBot((2*N1+1)*N6+1:(2*N1+1)*N6+N1,1) = boundedBot((N6-1)*N1+1:N1*N6,4);
    edgesBot((2*N1+1)*N6+1:(2*N1+1)*N6+N1,2) = boundedBot((N6-1)*N1+1:N1*N6,3);
    
    triBot = [];

    for i=1:size(boundedBot,1)
        if rand()>0.5
            triBot = [triBot;...
                    boundedBot(i,1) boundedBot(i,2) boundedBot(i,3);...
                    boundedBot(i,1) boundedBot(i,3) boundedBot(i,4)];
            edgesBot = [edgesBot;...
                      boundedBot(i,1) boundedBot(i,3)];
        else
            triBot = [triBot;...
                    boundedBot(i,1) boundedBot(i,2) boundedBot(i,4);...
                    boundedBot(i,2) boundedBot(i,3) boundedBot(i,4)];
            edgesBot = [edgesBot;...
                      boundedBot(i,4) boundedBot(i,2)];
        end
    end
    
    elements = [elements;...
                triBot];
            
    edges = [edges;...
             edgesBot];
end

return