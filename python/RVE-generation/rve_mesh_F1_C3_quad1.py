# Autogenerated with SMOP 
from smop.core import *
# 

    
@function
def rve_mesh_F1_C1_quad1(isUpperBounded=None,isLowerBounded=None,isCohesive=None,Rf=None,Vff=None,tratio=None,theta=None,deltatheta=None,f1=None,f2=None,f3=None,N1=None,N2=None,N3=None,N4=None,N5=None,N6=None,*args,**kwargs):
    varargin = rve_mesh_F1_C1_quad1.varargin
    nargin = rve_mesh_F1_C1_quad1.nargin

    ##
#==============================================================================
# Copyright (c) 2016 Universit de Lorraine & Lule tekniska universitet
# Author: Luca Di Stasio <luca.distasio@gmail.com>
#                        <luca.distasio@ingpec.eu>
    
    # Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 
# 
# Redistributions of source code must retain the above copyright
# notice, this list of conditions and the following disclaimer.
# Redistributions in binary form must reproduce the above copyright
# notice, this list of conditions and the following disclaimer in
# the documentation and/or other materials provided with the distribution
# Neither the name of the Universit de Lorraine or Lule tekniska universitet
# nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#==============================================================================
    
    #  DESCRIPTION
#  
#  A function to perform
    
    #  Input: isBounded = true; # flag for model type
# 
# Rf = 1; #[10^-6 m] Fiber diameter in micrometers. 
#         # Carbon fibers have a tipical diameter between 5 and 10 
#         # micrometers, glass fibers between 3 and 20
# Vff = 0.6; #[-] Fiber volume fraction
# tratio = 0.6; # [-] ratio of [0] ply thickness to [90] ply thickness
# theta = 30; #[] angular position of crack
# theta = theta*pi/180;
# deltatheta = 10; #[] angular aperture of crack
# deltatheta = deltatheta*pi/180;
# 
# f1 = 0.5; #[-] Innermost square mesh region side defined by 2*f1*Rf
# f2 = 0.77; #[-] Inner circular mesh region radius defined by f2*Rf
# f3 = 1.05; #[-] Outer circular mesh region radius defined by f2*Rf
# 
# #Number of elements:
# N1 = 20; #[-] Notice that angular resolution is equal to 90/N1
# N2 = 10; #[-] 
# N3 = 8; #[-] 
# N4 = 5; #[-] 
# N5 = 20; #[-] 
# N6 = 20; #[-] 
#  Output:
    
    ##
    
    #-------------------------------------------------------------------------#
#-------------------------------------------------------------------------#
#-                          Input Data                                   -#
#-------------------------------------------------------------------------#
#-------------------------------------------------------------------------#
    
    l=dot(dot(0.5,Rf),sqrt(pi / Vff))
    #-------------------------------------------------------------------------#
#-------------------------------------------------------------------------#
#-                        Mesh Generation                                -#
#-------------------------------------------------------------------------#
#-------------------------------------------------------------------------#
    
    #-------------------------------------------------------------------------#
#-                   Section 1 (innermost part)                          -#
#-------------------------------------------------------------------------#
    
    part1=structSquare(0,0,dot(dot(2,f1),Rf),N1)
    #-------------------------------------------------------------------------#
#-                           Section 2                                   -#
#-------------------------------------------------------------------------#
    
    A=matlabarray(cat(dot(dot(f2,Rf),cos(dot(5,pi) / 4)),dot(dot(f2,Rf),sin(dot(5,pi) / 4))))
    B=matlabarray(cat(dot(dot(f2,Rf),cos(dot(7,pi) / 4)),dot(dot(f2,Rf),sin(dot(7,pi) / 4))))
    C=matlabarray(cat(dot(f1,Rf),dot(- f1,Rf)))
    D=matlabarray(cat(dot(- f1,Rf),dot(- f1,Rf)))
    part2=generatelattice2D(A[1],N1 + 1,(B[1] - A[1]) / N1,A[2],N2 + 1,(D[2] - A[2]) / N2,A[1],B[1],N1 + 1,A[2],D[2],N2 + 1)
    e1=zeros(N1 + 1,6)
    e2=zeros(N2 + 1,6)
    e3=zeros(N1 + 1,6)
    e4=zeros(N2 + 1,6)
    c1=zeros(1,8)
    c2=zeros(1,8)
    c3=zeros(1,8)
    c4=zeros(1,8)
    c1[1,1:2]=A
    c2[1,1:2]=B
    c3[1,1:2]=C
    c4[1,1:2]=D
    thetas=(arange(dot(5,pi) / 4,dot(7,pi) / 4,(pi / 2) / N1)).T
    e1[:,1]=dot(dot(f2,Rf),cos(thetas))
    e1[:,2]=dot(dot(f2,Rf),sin(thetas))
    e2[:,1]=(arange(c2[1],c3[1],(c3[1] - c2[1]) / N2)).T
    e2[:,2]=(arange(c2[2],c3[2],(c3[2] - c2[2]) / N2)).T
    xs=(arange(c4[1],c3[1],(c3[1] - c4[1]) / N1)).T
    e3[:,1]=xs
    e3[:,2]=dot(c3[2],ones(length(xs),1))
    e4[:,1]=(arange(c1[1],c4[1],(c4[1] - c1[1]) / N2)).T
    e4[:,2]=(arange(c1[2],c4[2],(c4[2] - c1[2]) / N2)).T
    itmax=10
    tol=10 ** - 6
    part2=transfiniteinterpolation2D(dot((N1 + 1),(N2 + 1)),part2[:,1:2],A[1],B[1],A[2],D[2],N1 + 1,N2 + 1,1,e1,e2,e3,e4,c1,c2,c3,c4)
    indicesbulk,indicesinternalbulk,indicesE1,indicesE2,indicesE3,indicesE4,indicesexternalE1,indicesexternalE2,indicesexternalE3,indicesexternalE4,indicesinternalE1,indicesinternalE2,indicesinternalE3,indicesinternalE4,indicesC1,indicesC2,indicesC3,indicesC4,indicesinternalC1,indicesinternalC2,indicesinternalC3,indicesinternalC4=getindices2D(N1 + 1,N2 + 1,nargout=22)
    temp1,temp2,temp3,firstdevneighbours=build_neighbourhoods2D(dot((N1 + 1),(N2 + 1)),N1 + 1,0,0,0,0,0,indicesbulk,indicesinternalbulk,indicesE1,indicesE2,indicesE3,indicesE4,indicesexternalE1,indicesexternalE2,indicesexternalE3,indicesexternalE4,indicesinternalE1,indicesinternalE2,indicesinternalE3,indicesinternalE4,indicesC1,indicesC2,indicesC3,indicesC4,indicesinternalC1,indicesinternalC2,indicesinternalC3,indicesinternalC4,nargout=4)
    part2=sparseellipticgridgen2D(N1 + 1,dot((N1 + 1),(N2 + 1)),part2,cat((B[1] - A[1]) / N1,(D[2] - A[2]) / N2),0,0,indicesbulk,indicesE1,indicesE2,indicesE3,indicesE4,indicesC1,indicesC2,indicesC3,indicesC4,firstdevneighbours,itmax,tol,0)
    clear('temp1','temp2','temp3')
    part2=part2[1:dot(N2,(N1 + 1)),3:4]
    temp=copy(part2)
    part2=zeros(dot(N1,N2),2)
    for j in arange(1,N2).reshape(-1):
        part2[dot((j - 1),N1) + 1:dot(j,N1),:]=temp[dot((j - 1),(N1 + 1)) + 1:dot(j,(N1 + 1)) - 1,:]
    
    part2a=copy(part2)
    part2b=rotate2D(part2,pi / 2)
    part2c=rotate2D(part2,pi)
    part2d=rotate2D(part2,dot(3,pi) / 2)
    part2=zeros(dot(dot(4,N1),N2),2)
    for i in arange(1,N2).reshape(-1):
        part2[dot(dot((i - 1),4),N1) + 1:dot(dot((i - 1),4),N1) + N1,:]=part2a[dot((i - 1),N1) + 1:dot(i,N1),:]
        part2[dot(dot((i - 1),4),N1) + N1 + 1:dot(dot((i - 1),4),N1) + dot(2,N1),:]=part2b[dot((i - 1),N1) + 1:dot(i,N1),:]
        part2[dot(dot((i - 1),4),N1) + dot(2,N1) + 1:dot(dot((i - 1),4),N1) + dot(3,N1),:]=part2c[dot((i - 1),N1) + 1:dot(i,N1),:]
        part2[dot(dot((i - 1),4),N1) + dot(3,N1) + 1:dot(dot((i - 1),4),N1) + dot(4,N1),:]=part2d[dot((i - 1),N1) + 1:dot(i,N1),:]
    
    #-------------------------------------------------------------------------#
#-                           Section 3                                   -#
#-------------------------------------------------------------------------#
    
    part3=circular_arc(0,0,Rf,dot(f2,Rf),dot(5,pi) / 4,dot(7,pi) / 4,N3,N1)
    part3=part3[1:dot(N3,(N1 + 1)),:]
    part3=part3[1:dot(N3,(N1 + 1)),1:2]
    temp=copy(part3)
    part3=zeros(dot(N1,N3),2)
    for j in arange(1,N3).reshape(-1):
        part3[dot((j - 1),N1) + 1:dot(j,N1),:]=temp[dot((j - 1),(N1 + 1)) + 1:dot(j,(N1 + 1)) - 1,:]
    
    part3a=copy(part3)
    part3b=rotate2D(part3,pi / 2)
    part3c=rotate2D(part3,pi)
    part3d=rotate2D(part3,dot(3,pi) / 2)
    part3=zeros(dot(dot(4,N1),N3),2)
    for i in arange(1,N3).reshape(-1):
        part3[dot(dot((i - 1),4),N1) + 1:dot(dot((i - 1),4),N1) + N1,:]=part3a[dot((i - 1),N1) + 1:dot(i,N1),:]
        part3[dot(dot((i - 1),4),N1) + N1 + 1:dot(dot((i - 1),4),N1) + dot(2,N1),:]=part3b[dot((i - 1),N1) + 1:dot(i,N1),:]
        part3[dot(dot((i - 1),4),N1) + dot(2,N1) + 1:dot(dot((i - 1),4),N1) + dot(3,N1),:]=part3c[dot((i - 1),N1) + 1:dot(i,N1),:]
        part3[dot(dot((i - 1),4),N1) + dot(3,N1) + 1:dot(dot((i - 1),4),N1) + dot(4,N1),:]=part3d[dot((i - 1),N1) + 1:dot(i,N1),:]
    
    #-------------------------------------------------------------------------#
#-                           Section 4                                   -#
#-------------------------------------------------------------------------#
    
    part4=circular_arc(0,0,dot(f3,Rf),Rf,dot(5,pi) / 4,dot(7,pi) / 4,N4,N1)
    temp=copy(part4)
    part4=zeros(dot(N1,(N4 + 1)),2)
    for j in arange(1,N4 + 1).reshape(-1):
        part4[dot((j - 1),N1) + 1:dot(j,N1),:]=temp[dot((j - 1),(N1 + 1)) + 1:dot(j,(N1 + 1)) - 1,:]
    
    part4a=copy(part4)
    part4b=rotate2D(part4,pi / 2)
    part4c=rotate2D(part4,pi)
    part4d=rotate2D(part4,dot(3,pi) / 2)
    part4=zeros(dot(dot(4,N1),(N4 + 1)),2)
    for i in arange(1,N4 + 1).reshape(-1):
        part4[dot(dot((i - 1),4),N1) + 1:dot(dot((i - 1),4),N1) + N1,:]=part4a[dot((i - 1),N1) + 1:dot(i,N1),:]
        part4[dot(dot((i - 1),4),N1) + N1 + 1:dot(dot((i - 1),4),N1) + dot(2,N1),:]=part4b[dot((i - 1),N1) + 1:dot(i,N1),:]
        part4[dot(dot((i - 1),4),N1) + dot(2,N1) + 1:dot(dot((i - 1),4),N1) + dot(3,N1),:]=part4c[dot((i - 1),N1) + 1:dot(i,N1),:]
        part4[dot(dot((i - 1),4),N1) + dot(3,N1) + 1:dot(dot((i - 1),4),N1) + dot(4,N1),:]=part4d[dot((i - 1),N1) + 1:dot(i,N1),:]
    
    #-------------------------------------------------------------------------#
#-                   Section 5 (outermost part)                          -#
#-------------------------------------------------------------------------#
    
    A=matlabarray(cat(- l,- l))
    B=matlabarray(cat(l,- l))
    C=matlabarray(cat(dot(dot(f3,Rf),cos(dot(7,pi) / 4)),dot(dot(f3,Rf),sin(dot(7,pi) / 4))))
    D=matlabarray(cat(dot(dot(f3,Rf),cos(dot(5,pi) / 4)),dot(dot(f3,Rf),sin(dot(5,pi) / 4))))
    part5=generatelattice2D(A[1],N1 + 1,(B[1] - A[1]) / N1,A[2],N5 + 1,(D[2] - A[2]) / N5,A[1],B[1],N1 + 1,A[2],D[2],N5 + 1)
    e1=zeros(N1 + 1,6)
    e2=zeros(N5 + 1,6)
    e3=zeros(N1 + 1,6)
    e4=zeros(N5 + 1,6)
    c1=zeros(1,8)
    c2=zeros(1,8)
    c3=zeros(1,8)
    c4=zeros(1,8)
    c1[1,1:2]=A
    c2[1,1:2]=B
    c3[1,1:2]=C
    c4[1,1:2]=D
    xs=(arange(c1[1],c2[1],(c2[1] - c1[1]) / N1)).T
    e1[:,1]=xs
    e1[:,2]=dot(c1[2],ones(length(xs),1))
    e2[:,1]=(arange(c2[1],c3[1],(c3[1] - c2[1]) / N5)).T
    e2[:,2]=(arange(c2[2],c3[2],(c3[2] - c2[2]) / N5)).T
    thetas=(arange(dot(5,pi) / 4,dot(7,pi) / 4,(pi / 2) / N1)).T
    e3[:,1]=dot(dot(f3,Rf),cos(thetas))
    e3[:,2]=dot(dot(f3,Rf),sin(thetas))
    e4[:,1]=(arange(c1[1],c4[1],(c4[1] - c1[1]) / N5)).T
    e4[:,2]=(arange(c1[2],c4[2],(c4[2] - c1[2]) / N5)).T
    itmax=10
    tol=10 ** - 6
    part5=transfiniteinterpolation2D(dot((N1 + 1),(N5 + 1)),part5[:,1:2],A[1],B[1],A[2],D[2],N1 + 1,N5 + 1,1,e1,e2,e3,e4,c1,c2,c3,c4)
    indicesbulk,indicesinternalbulk,indicesE1,indicesE2,indicesE3,indicesE4,indicesexternalE1,indicesexternalE2,indicesexternalE3,indicesexternalE4,indicesinternalE1,indicesinternalE2,indicesinternalE3,indicesinternalE4,indicesC1,indicesC2,indicesC3,indicesC4,indicesinternalC1,indicesinternalC2,indicesinternalC3,indicesinternalC4=getindices2D(N1 + 1,N5 + 1,nargout=22)
    temp1,temp2,temp3,firstdevneighbours=build_neighbourhoods2D(dot((N1 + 1),(N5 + 1)),N1 + 1,0,0,0,0,0,indicesbulk,indicesinternalbulk,indicesE1,indicesE2,indicesE3,indicesE4,indicesexternalE1,indicesexternalE2,indicesexternalE3,indicesexternalE4,indicesinternalE1,indicesinternalE2,indicesinternalE3,indicesinternalE4,indicesC1,indicesC2,indicesC3,indicesC4,indicesinternalC1,indicesinternalC2,indicesinternalC3,indicesinternalC4,nargout=4)
    part5=sparseellipticgridgen2D(N1 + 1,dot((N1 + 1),(N5 + 1)),part5,cat((B[1] - A[1]) / N1,(D[2] - A[2]) / N2),0,0,indicesbulk,indicesE1,indicesE2,indicesE3,indicesE4,indicesC1,indicesC2,indicesC3,indicesC4,firstdevneighbours,itmax,tol,0)
    clear('temp1','temp2','temp3')
    part5=part5[1:dot(N5,(N1 + 1)),3:4]
    temp=copy(part5)
    part5=zeros(dot(N1,N5),2)
    for j in arange(1,N5).reshape(-1):
        part5[dot((j - 1),N1) + 1:dot(j,N1),:]=temp[dot((j - 1),(N1 + 1)) + 1:dot(j,(N1 + 1)) - 1,:]
    
    part5a=copy(part5)
    part5b=rotate2D(part5,pi / 2)
    part5c=rotate2D(part5,pi)
    part5d=rotate2D(part5,dot(3,pi) / 2)
    part5=zeros(dot(dot(4,N1),N5),2)
    for i in arange(1,N5).reshape(-1):
        part5[dot(dot((i - 1),4),N1) + 1:dot(dot((i - 1),4),N1) + N1,:]=part5a[dot((i - 1),N1) + 1:dot(i,N1),:]
        part5[dot(dot((i - 1),4),N1) + N1 + 1:dot(dot((i - 1),4),N1) + dot(2,N1),:]=part5b[dot((i - 1),N1) + 1:dot(i,N1),:]
        part5[dot(dot((i - 1),4),N1) + dot(2,N1) + 1:dot(dot((i - 1),4),N1) + dot(3,N1),:]=part5c[dot((i - 1),N1) + 1:dot(i,N1),:]
        part5[dot(dot((i - 1),4),N1) + dot(3,N1) + 1:dot(dot((i - 1),4),N1) + dot(4,N1),:]=part5d[dot((i - 1),N1) + 1:dot(i,N1),:]
    
    #-------------------------------------------------------------------------#
#-            Section 6 (bounding 0 layer, if present)                  -#
#-------------------------------------------------------------------------#
    
    if isUpperBounded and isLowerBounded:
        part6up=structRectangle(0,l + dot(dot(0.5,tratio),l),dot(2,l),dot(tratio,l),N1,N6)
        part6bot=rotate2D(part6up,pi)
        part6=matlabarray(cat([part6bot],[part6up]))
    else:
        if isUpperBounded:
            part6up=structRectangle(0,l + dot(dot(0.5,tratio),l),dot(2,l),dot(tratio,l),N1,N6)
            part6=copy(part6up)
        else:
            if isLowerBounded:
                part6up=structRectangle(0,l + dot(dot(0.5,tratio),l),dot(2,l),dot(tratio,l),N1,N6)
                part6bot=rotate2D(part6up,pi)
                part6=copy(part6bot)
    
    #-------------------------------------------------------------------------#
#-                              Overall                                  -#
#-------------------------------------------------------------------------#
    
    nodes=matlabarray(cat([part5],[part4],[part3],[part2],[part1]))
    if isUpperBounded or isLowerBounded:
        nodes=matlabarray(cat([nodes],[part6]))
    
    #-------------------------------------------------------------------------#
#-                         Elements & Edges                              -#
#-------------------------------------------------------------------------#
    
    elements1=zeros(dot(dot(4,N1),(N5 + N4)),4)
    for j in arange(1,N5 + N4).reshape(-1):
        elements1[dot(dot((j - 1),4),N1) + 1:dot(dot(j,4),N1),1]=(arange(dot(dot((j - 1),4),N1) + 1,dot(dot(j,4),N1))).T
        elements1[dot(dot((j - 1),4),N1) + 1:dot(dot(j,4),N1) - 1,2]=(arange(dot(dot((j - 1),4),N1) + 2,dot(dot(j,4),N1))).T
        elements1[dot(dot(j,4),N1),2]=dot(dot((j - 1),4),N1) + 1
        elements1[dot(dot((j - 1),4),N1) + 1:dot(dot(j,4),N1) - 1,3]=(arange(dot(dot(j,4),N1) + 2,dot(dot((j + 1),4),N1))).T
        elements1[dot(dot(j,4),N1),3]=dot(dot(j,4),N1) + 1
        elements1[dot(dot((j - 1),4),N1) + 1:dot(dot(j,4),N1),4]=(arange(dot(dot(j,4),N1) + 1,dot(dot((j + 1),4),N1))).T
    
    edges1=zeros(dot(dot(2,(dot(4,N1))),(N5 + N4)) + dot(4,N1),2)
    for j in arange(1,N5 + N4).reshape(-1):
        edges1[dot((j - 1),(dot(2,(dot(4,N1))))) + 1:2:dot(j,(dot(2,(dot(4,N1))))) - 1,1]=elements1[dot(dot((j - 1),4),N1) + 1:dot(dot(j,4),N1),1]
        edges1[dot((j - 1),(dot(2,(dot(4,N1))))) + 1:2:dot(j,(dot(2,(dot(4,N1))))) - 1,2]=elements1[dot(dot((j - 1),4),N1) + 1:dot(dot(j,4),N1),4]
        edges1[dot((j - 1),(dot(2,(dot(4,N1))))) + 2:2:dot(j,(dot(2,(dot(4,N1))))),1]=elements1[dot(dot((j - 1),4),N1) + 1:dot(dot(j,4),N1),1]
        edges1[dot((j - 1),(dot(2,(dot(4,N1))))) + 2:2:dot(j,(dot(2,(dot(4,N1))))),2]=elements1[dot(dot((j - 1),4),N1) + 1:dot(dot(j,4),N1),2]
    
    edges1[dot((dot(2,(dot(4,N1)))),(N5 + N4)) + 1:dot((dot(2,(dot(4,N1)))),(N5 + N4)) + dot(4,N1),1]=elements1[dot(dot(((N5 + N4) - 1),4),N1) + 1:dot(dot((N5 + N4),4),N1),4]
    edges1[dot((dot(2,(dot(4,N1)))),(N5 + N4)) + 1:dot((dot(2,(dot(4,N1)))),(N5 + N4)) + dot(4,N1),2]=elements1[dot(dot(((N5 + N4) - 1),4),N1) + 1:dot(dot((N5 + N4),4),N1),3]
    elements2=zeros(dot(dot(4,N1),(N3 + N2)),4)
    for j in arange(1,N3 + N2 - 1).reshape(-1):
        elements2[dot(dot((j - 1),4),N1) + 1:dot(dot(j,4),N1),1]=dot(dot(4,N1),(N5 + N4 + 1)) + (arange(dot(dot((j - 1),4),N1) + 1,dot(dot(j,4),N1))).T
        elements2[dot(dot((j - 1),4),N1) + 1:dot(dot(j,4),N1) - 1,2]=dot(dot(4,N1),(N5 + N4 + 1)) + (arange(dot(dot((j - 1),4),N1) + 2,dot(dot(j,4),N1))).T
        elements2[dot(dot(j,4),N1),2]=dot(dot(4,N1),(N5 + N4 + 1)) + dot(dot((j - 1),4),N1) + 1
        elements2[dot(dot((j - 1),4),N1) + 1:dot(dot(j,4),N1) - 1,3]=dot(dot(4,N1),(N5 + N4 + 1)) + (arange(dot(dot(j,4),N1) + 2,dot(dot((j + 1),4),N1))).T
        elements2[dot(dot(j,4),N1),3]=dot(dot(4,N1),(N5 + N4 + 1)) + dot(dot(j,4),N1) + 1
        elements2[dot(dot((j - 1),4),N1) + 1:dot(dot(j,4),N1),4]=dot(dot(4,N1),(N5 + N4 + 1)) + (arange(dot(dot(j,4),N1) + 1,dot(dot((j + 1),4),N1))).T
    
    elements2[dot(dot((N3 + N2 - 1),4),N1) + 1:dot(dot((N3 + N2),4),N1),1]=dot(dot(4,N1),(N5 + N4 + 1)) + (arange(dot(dot(((N3 + N2) - 1),4),N1) + 1,dot(dot((N3 + N2),4),N1))).T
    elements2[dot(dot((N3 + N2 - 1),4),N1) + 1:dot(dot((N3 + N2),4),N1) - 1,2]=dot(dot(4,N1),(N5 + N4 + 1)) + (arange(dot(dot(((N3 + N2) - 1),4),N1) + 2,dot(dot((N3 + N2),4),N1))).T
    elements2[dot(dot((N3 + N2),4),N1),2]=dot(dot(4,N1),(N5 + N4 + 1)) + dot(dot(((N3 + N2) - 1),4),N1) + 1
    elements2[dot(dot((N3 + N2 - 1),4),N1) + 1:dot(dot((N3 + N2 - 1),4),N1) + N1,3]=dot(dot(4,N1),(N5 + N4 + 1)) + dot(dot(4,N1),(N3 + N2)) + (arange(2,N1 + 1)).T
    elements2[dot(dot((N3 + N2 - 1),4),N1) + N1 + 1:dot(dot((N3 + N2 - 1),4),N1) + dot(2,N1),3]=dot(dot(4,N1),(N5 + N4 + 1)) + dot(dot(4,N1),(N3 + N2)) + (arange(dot(2,(N1 + 1)),dot((N1 + 1),(N1 + 1)),N1 + 1)).T
    elements2[dot(dot((N3 + N2 - 1),4),N1) + dot(2,N1) + 1:dot(dot((N3 + N2 - 1),4),N1) + dot(3,N1),3]=dot(dot(4,N1),(N5 + N4 + 1)) + dot(dot(4,N1),(N3 + N2)) + dot(N1,(N1 + 1)) + (arange(N1,1,- 1)).T
    elements2[dot(dot((N3 + N2 - 1),4),N1) + dot(3,N1) + 1:dot(dot((N3 + N2 - 1),4),N1) + dot(4,N1),3]=dot(dot(4,N1),(N5 + N4 + 1)) + dot(dot(4,N1),(N3 + N2)) + (arange(dot((N1 - 1),(N1 + 1)) + 1,1,- (N1 + 1))).T
    elements2[dot(dot((N3 + N2 - 1),4),N1) + 1:dot(dot((N3 + N2 - 1),4),N1) + N1,4]=dot(dot(4,N1),(N5 + N4 + 1)) + dot(dot(4,N1),(N3 + N2)) + (arange(1,N1)).T
    elements2[dot(dot((N3 + N2 - 1),4),N1) + N1 + 1:dot(dot((N3 + N2 - 1),4),N1) + dot(2,N1),4]=dot(dot(4,N1),(N5 + N4 + 1)) + dot(dot(4,N1),(N3 + N2)) + (arange((N1 + 1),dot(N1,(N1 + 1)),N1 + 1)).T
    elements2[dot(dot((N3 + N2 - 1),4),N1) + dot(2,N1) + 1:dot(dot((N3 + N2 - 1),4),N1) + dot(3,N1),4]=dot(dot(4,N1),(N5 + N4 + 1)) + dot(dot(4,N1),(N3 + N2)) + dot(N1,(N1 + 1)) + (arange(N1 + 1,2,- 1)).T
    elements2[dot(dot((N3 + N2 - 1),4),N1) + dot(3,N1) + 1:dot(dot((N3 + N2 - 1),4),N1) + dot(4,N1),4]=dot(dot(4,N1),(N5 + N4 + 1)) + dot(dot(4,N1),(N3 + N2)) + (arange(dot(N1,(N1 + 1)) + 1,(N1 + 1) + 1,- (N1 + 1))).T
    edges2=zeros(dot(dot(2,(dot(4,N1))),(N3 + N2)),2)
    for j in arange(1,N3 + N2).reshape(-1):
        edges2[dot((j - 1),(dot(2,(dot(4,N1))))) + 1:2:dot(j,(dot(2,(dot(4,N1))))) - 1,1]=elements2[dot(dot((j - 1),4),N1) + 1:dot(dot(j,4),N1),1]
        edges2[dot((j - 1),(dot(2,(dot(4,N1))))) + 1:2:dot(j,(dot(2,(dot(4,N1))))) - 1,2]=elements2[dot(dot((j - 1),4),N1) + 1:dot(dot(j,4),N1),4]
        edges2[dot((j - 1),(dot(2,(dot(4,N1))))) + 2:2:dot(j,(dot(2,(dot(4,N1))))),1]=elements2[dot(dot((j - 1),4),N1) + 1:dot(dot(j,4),N1),1]
        edges2[dot((j - 1),(dot(2,(dot(4,N1))))) + 2:2:dot(j,(dot(2,(dot(4,N1))))),2]=elements2[dot(dot((j - 1),4),N1) + 1:dot(dot(j,4),N1),2]
    
    elements3=zeros(dot(N1,N1),4)
    for j in arange(1,N1).reshape(-1):
        elements3[dot((j - 1),N1) + 1:dot(j,N1),1]=dot(dot(4,N1),(N5 + N4 + 1)) + dot(dot(4,N1),(N3 + N2)) + dot((j - 1),(N1 + 1)) + (arange(1,N1)).T
        elements3[dot((j - 1),N1) + 1:dot(j,N1),2]=dot(dot(4,N1),(N5 + N4 + 1)) + dot(dot(4,N1),(N3 + N2)) + dot((j - 1),(N1 + 1)) + (arange(2,N1 + 1)).T
        elements3[dot((j - 1),N1) + 1:dot(j,N1),3]=dot(dot(4,N1),(N5 + N4 + 1)) + dot(dot(4,N1),(N3 + N2)) + dot(j,(N1 + 1)) + (arange(2,N1 + 1)).T
        elements3[dot((j - 1),N1) + 1:dot(j,N1),4]=dot(dot(4,N1),(N5 + N4 + 1)) + dot(dot(4,N1),(N3 + N2)) + dot(j,(N1 + 1)) + (arange(1,N1)).T
    
    edges3=zeros(dot((dot(2,N1) + 1),N1) + N1,2)
    for j in arange(1,N1).reshape(-1):
        edges3[dot((j - 1),(dot(2,N1) + 1)) + 1:2:dot(j,(dot(2,N1) + 1)) - 2,1]=elements3[dot((j - 1),N1) + 1:dot(j,N1),1]
        edges3[dot((j - 1),(dot(2,N1) + 1)) + 1:2:dot(j,(dot(2,N1) + 1)) - 2,2]=elements3[dot((j - 1),N1) + 1:dot(j,N1),4]
        edges3[dot((j - 1),(dot(2,N1) + 1)) + 2:2:dot(j,(dot(2,N1) + 1)) - 1,1]=elements3[dot((j - 1),N1) + 1:dot(j,N1),1]
        edges3[dot((j - 1),(dot(2,N1) + 1)) + 2:2:dot(j,(dot(2,N1) + 1)) - 1,2]=elements3[dot((j - 1),N1) + 1:dot(j,N1),2]
        edges3[dot(j,(dot(2,N1) + 1)),1]=elements3[dot(j,N1),2]
        edges3[dot(j,(dot(2,N1) + 1)),2]=elements3[dot(j,N1),3]
    
    edges3[dot((dot(2,N1) + 1),N1) + 1:dot((dot(2,N1) + 1),N1) + N1,1]=elements3[dot((N1 - 1),N1) + 1:dot(N1,N1),4]
    edges3[dot((dot(2,N1) + 1),N1) + 1:dot((dot(2,N1) + 1),N1) + N1,2]=elements3[dot((N1 - 1),N1) + 1:dot(N1,N1),3]
    if isCohesive:
        cohesiveEl=zeros(dot(4,N1),4)
        cohesiveEl[:,1]=arange(dot(dot((N5 + N4),4),N1) + 1,dot(dot(((N5 + N4) + 1),4),N1))
        cohesiveEl[1:end() - 1,2]=arange(dot(dot((N5 + N4),4),N1) + 2,dot(dot(((N5 + N4) + 1),4),N1))
        cohesiveEl[end(),2]=dot(dot((N5 + N4),4),N1) + 1
        cohesiveEl[1:end() - 1,3]=dot(dot(4,N1),(N5 + N4 + 1)) + (arange(2,dot(4,N1)))
        cohesiveEl[end(),3]=dot(dot(4,N1),(N5 + N4 + 1)) + 1
        cohesiveEl[:,4]=dot(dot(4,N1),(N5 + N4 + 1)) + (arange(1,dot(4,N1)))
        cohesiveEd=zeros(dot(4,N1),2)
        cohesiveEd[1:dot(4,N1),1]=cohesiveEl[1:dot(4,N1),1]
        cohesiveEd[1:dot(4,N1),2]=cohesiveEl[1:dot(4,N1),4]
        elements=matlabarray(cat([elements1],[cohesiveEl],[elements2],[elements3]))
        edges=matlabarray(cat([edges1],[cohesiveEd],[edges2],[edges3]))
    else:
        elements=matlabarray(cat([elements1],[elements2],[elements3]))
        edges=matlabarray(cat([edges1],[edges2],[edges3]))
    
    if isUpperBounded and isLowerBounded:
        boundedBot=zeros(dot(N1,N6),4)
        boundedUp=zeros(dot(N1,N6),4)
        for j in arange(1,N6).reshape(-1):
            boundedBot[dot((j - 1),N1) + 1:dot(j,N1),1]=dot(dot(4,N1),(N5 + N4 + 1)) + dot(dot(4,N1),(N3 + N2)) + dot((N1 + 1),(N1 + 1)) + dot((j - 1),(N1 + 1)) + (arange(1,N1)).T
            boundedBot[dot((j - 1),N1) + 1:dot(j,N1),2]=dot(dot(4,N1),(N5 + N4 + 1)) + dot(dot(4,N1),(N3 + N2)) + dot((N1 + 1),(N1 + 1)) + dot((j - 1),(N1 + 1)) + (arange(2,N1 + 1)).T
            boundedBot[dot((j - 1),N1) + 1:dot(j,N1),3]=dot(dot(4,N1),(N5 + N4 + 1)) + dot(dot(4,N1),(N3 + N2)) + dot((N1 + 1),(N1 + 1)) + dot(j,(N1 + 1)) + (arange(2,N1 + 1)).T
            boundedBot[dot((j - 1),N1) + 1:dot(j,N1),4]=dot(dot(4,N1),(N5 + N4 + 1)) + dot(dot(4,N1),(N3 + N2)) + dot((N1 + 1),(N1 + 1)) + dot(j,(N1 + 1)) + (arange(1,N1)).T
            boundedUp[dot((j - 1),N1) + 1:dot(j,N1),1]=dot(dot(4,N1),(N5 + N4 + 1)) + dot(dot(4,N1),(N3 + N2)) + dot((N1 + 1),(N1 + 1)) + dot((N1 + 1),(N1 + 1)) + dot((j - 1),(N1 + 1)) + (arange(1,N1)).T
            boundedUp[dot((j - 1),N1) + 1:dot(j,N1),2]=dot(dot(4,N1),(N5 + N4 + 1)) + dot(dot(4,N1),(N3 + N2)) + dot((N1 + 1),(N1 + 1)) + dot((N1 + 1),(N1 + 1)) + dot((j - 1),(N1 + 1)) + (arange(2,N1 + 1)).T
            boundedUp[dot((j - 1),N1) + 1:dot(j,N1),3]=dot(dot(4,N1),(N5 + N4 + 1)) + dot(dot(4,N1),(N3 + N2)) + dot((N1 + 1),(N1 + 1)) + dot((N1 + 1),(N1 + 1)) + dot(j,(N1 + 1)) + (arange(2,N1 + 1)).T
            boundedUp[dot((j - 1),N1) + 1:dot(j,N1),4]=dot(dot(4,N1),(N5 + N4 + 1)) + dot(dot(4,N1),(N3 + N2)) + dot((N1 + 1),(N1 + 1)) + dot((N1 + 1),(N1 + 1)) + dot(j,(N1 + 1)) + (arange(1,N1)).T
        elements=matlabarray(cat([elements],[boundedUp],[boundedBot]))
        edgesBot=zeros(dot((dot(2,N1) + 1),N6) + N1,2)
        edgesUp=zeros(dot((dot(2,N1) + 1),N6) + N1,2)
        for j in arange(1,N6).reshape(-1):
            edgesBot[dot((j - 1),(dot(2,N1) + 1)) + 1:2:dot(j,(dot(2,N1) + 1)) - 2,1]=boundedBot[dot((j - 1),N1) + 1:dot(j,N1),1]
            edgesBot[dot((j - 1),(dot(2,N1) + 1)) + 1:2:dot(j,(dot(2,N1) + 1)) - 2,2]=boundedBot[dot((j - 1),N1) + 1:dot(j,N1),4]
            edgesBot[dot((j - 1),(dot(2,N1) + 1)) + 2:2:dot(j,(dot(2,N1) + 1)) - 1,1]=boundedBot[dot((j - 1),N1) + 1:dot(j,N1),1]
            edgesBot[dot((j - 1),(dot(2,N1) + 1)) + 2:2:dot(j,(dot(2,N1) + 1)) - 1,2]=boundedBot[dot((j - 1),N1) + 1:dot(j,N1),2]
            edgesBot[dot(j,(dot(2,N1) + 1)),1]=boundedBot[dot(j,N1),2]
            edgesBot[dot(j,(dot(2,N1) + 1)),2]=boundedBot[dot(j,N1),3]
            edgesUp[dot((j - 1),(dot(2,N1) + 1)) + 1:2:dot(j,(dot(2,N1) + 1)) - 2,1]=boundedUp[dot((j - 1),N1) + 1:dot(j,N1),1]
            edgesUp[dot((j - 1),(dot(2,N1) + 1)) + 1:2:dot(j,(dot(2,N1) + 1)) - 2,2]=boundedUp[dot((j - 1),N1) + 1:dot(j,N1),4]
            edgesUp[dot((j - 1),(dot(2,N1) + 1)) + 2:2:dot(j,(dot(2,N1) + 1)) - 1,1]=boundedUp[dot((j - 1),N1) + 1:dot(j,N1),1]
            edgesUp[dot((j - 1),(dot(2,N1) + 1)) + 2:2:dot(j,(dot(2,N1) + 1)) - 1,2]=boundedUp[dot((j - 1),N1) + 1:dot(j,N1),2]
            edgesUp[dot(j,(dot(2,N1) + 1)),1]=boundedUp[dot(j,N1),2]
            edgesUp[dot(j,(dot(2,N1) + 1)),2]=boundedUp[dot(j,N1),3]
        edgesBot[dot((dot(2,N1) + 1),N6) + 1:dot((dot(2,N1) + 1),N6) + N1,1]=boundedBot[dot((N6 - 1),N1) + 1:dot(N1,N6),4]
        edgesBot[dot((dot(2,N1) + 1),N6) + 1:dot((dot(2,N1) + 1),N6) + N1,2]=boundedBot[dot((N6 - 1),N1) + 1:dot(N1,N6),3]
        edgesUp[dot((dot(2,N1) + 1),N6) + 1:dot((dot(2,N1) + 1),N6) + N1,1]=boundedUp[dot((N6 - 1),N1) + 1:dot(N1,N6),4]
        edgesUp[dot((dot(2,N1) + 1),N6) + 1:dot((dot(2,N1) + 1),N6) + N1,2]=boundedUp[dot((N6 - 1),N1) + 1:dot(N1,N6),3]
        edges=matlabarray(cat([edges],[edgesUp],[edgesBot]))
    else:
        if isUpperBounded:
            boundedUp=zeros(dot(N1,N6),4)
            for j in arange(1,N6).reshape(-1):
                boundedUp[dot((j - 1),N1) + 1:dot(j,N1),1]=dot(dot(4,N1),(N5 + N4 + 1)) + dot(dot(4,N1),(N3 + N2)) + dot((N1 + 1),(N1 + 1)) + dot((j - 1),(N1 + 1)) + (arange(1,N1)).T
                boundedUp[dot((j - 1),N1) + 1:dot(j,N1),2]=dot(dot(4,N1),(N5 + N4 + 1)) + dot(dot(4,N1),(N3 + N2)) + dot((N1 + 1),(N1 + 1)) + dot((j - 1),(N1 + 1)) + (arange(2,N1 + 1)).T
                boundedUp[dot((j - 1),N1) + 1:dot(j,N1),3]=dot(dot(4,N1),(N5 + N4 + 1)) + dot(dot(4,N1),(N3 + N2)) + dot((N1 + 1),(N1 + 1)) + dot(j,(N1 + 1)) + (arange(2,N1 + 1)).T
                boundedUp[dot((j - 1),N1) + 1:dot(j,N1),4]=dot(dot(4,N1),(N5 + N4 + 1)) + dot(dot(4,N1),(N3 + N2)) + dot((N1 + 1),(N1 + 1)) + dot(j,(N1 + 1)) + (arange(1,N1)).T
            elements=matlabarray(cat([elements],[boundedUp]))
            edgesUp=zeros(dot((dot(2,N1) + 1),N6) + N1,2)
            for j in arange(1,N6).reshape(-1):
                edgesUp[dot((j - 1),(dot(2,N1) + 1)) + 1:2:dot(j,(dot(2,N1) + 1)) - 2,1]=boundedUp[dot((j - 1),N1) + 1:dot(j,N1),1]
                edgesUp[dot((j - 1),(dot(2,N1) + 1)) + 1:2:dot(j,(dot(2,N1) + 1)) - 2,2]=boundedUp[dot((j - 1),N1) + 1:dot(j,N1),4]
                edgesUp[dot((j - 1),(dot(2,N1) + 1)) + 2:2:dot(j,(dot(2,N1) + 1)) - 1,1]=boundedUp[dot((j - 1),N1) + 1:dot(j,N1),1]
                edgesUp[dot((j - 1),(dot(2,N1) + 1)) + 2:2:dot(j,(dot(2,N1) + 1)) - 1,2]=boundedUp[dot((j - 1),N1) + 1:dot(j,N1),2]
                edgesUp[dot(j,(dot(2,N1) + 1)),1]=boundedUp[dot(j,N1),2]
                edgesUp[dot(j,(dot(2,N1) + 1)),2]=boundedUp[dot(j,N1),3]
            edgesUp[dot((dot(2,N1) + 1),N6) + 1:dot((dot(2,N1) + 1),N6) + N1,1]=boundedUp[dot((N6 - 1),N1) + 1:dot(N1,N6),4]
            edgesUp[dot((dot(2,N1) + 1),N6) + 1:dot((dot(2,N1) + 1),N6) + N1,2]=boundedUp[dot((N6 - 1),N1) + 1:dot(N1,N6),3]
            edges=matlabarray(cat([edges],[edgesUp]))
        else:
            if isLowerBounded:
                boundedBot=zeros(dot(N1,N6),4)
                for j in arange(1,N6).reshape(-1):
                    boundedBot[dot((j - 1),N1) + 1:dot(j,N1),1]=dot(dot(4,N1),(N5 + N4 + 1)) + dot(dot(4,N1),(N3 + N2)) + dot((N1 + 1),(N1 + 1)) + dot((j - 1),(N1 + 1)) + (arange(1,N1)).T
                    boundedBot[dot((j - 1),N1) + 1:dot(j,N1),2]=dot(dot(4,N1),(N5 + N4 + 1)) + dot(dot(4,N1),(N3 + N2)) + dot((N1 + 1),(N1 + 1)) + dot((j - 1),(N1 + 1)) + (arange(2,N1 + 1)).T
                    boundedBot[dot((j - 1),N1) + 1:dot(j,N1),3]=dot(dot(4,N1),(N5 + N4 + 1)) + dot(dot(4,N1),(N3 + N2)) + dot((N1 + 1),(N1 + 1)) + dot(j,(N1 + 1)) + (arange(2,N1 + 1)).T
                    boundedBot[dot((j - 1),N1) + 1:dot(j,N1),4]=dot(dot(4,N1),(N5 + N4 + 1)) + dot(dot(4,N1),(N3 + N2)) + dot((N1 + 1),(N1 + 1)) + dot(j,(N1 + 1)) + (arange(1,N1)).T
                elements=matlabarray(cat([elements],[boundedBot]))
                edgesBot=zeros(dot((dot(2,N1) + 1),N6) + N1,2)
                for j in arange(1,N6).reshape(-1):
                    edgesBot[dot((j - 1),(dot(2,N1) + 1)) + 1:2:dot(j,(dot(2,N1) + 1)) - 2,1]=boundedBot[dot((j - 1),N1) + 1:dot(j,N1),1]
                    edgesBot[dot((j - 1),(dot(2,N1) + 1)) + 1:2:dot(j,(dot(2,N1) + 1)) - 2,2]=boundedBot[dot((j - 1),N1) + 1:dot(j,N1),4]
                    edgesBot[dot((j - 1),(dot(2,N1) + 1)) + 2:2:dot(j,(dot(2,N1) + 1)) - 1,1]=boundedBot[dot((j - 1),N1) + 1:dot(j,N1),1]
                    edgesBot[dot((j - 1),(dot(2,N1) + 1)) + 2:2:dot(j,(dot(2,N1) + 1)) - 1,2]=boundedBot[dot((j - 1),N1) + 1:dot(j,N1),2]
                    edgesBot[dot(j,(dot(2,N1) + 1)),1]=boundedBot[dot(j,N1),2]
                    edgesBot[dot(j,(dot(2,N1) + 1)),2]=boundedBot[dot(j,N1),3]
                edgesBot[dot((dot(2,N1) + 1),N6) + 1:dot((dot(2,N1) + 1),N6) + N1,1]=boundedBot[dot((N6 - 1),N1) + 1:dot(N1,N6),4]
                edgesBot[dot((dot(2,N1) + 1),N6) + 1:dot((dot(2,N1) + 1),N6) + N1,2]=boundedBot[dot((N6 - 1),N1) + 1:dot(N1,N6),3]
                edges=matlabarray(cat([edges],[edgesBot]))
    
    #-------------------------------------------------------------------------#
#-                               Crack                                   -#
#-------------------------------------------------------------------------#
    
    gammaNo1=matlabarray([])
    gammaNo2=matlabarray([])
    gammaNo3=matlabarray([])
    gammaEl1=matlabarray([])
    gammaEl2=matlabarray([])
    gammaEl3=matlabarray([])
    if logical_not(isCohesive):
        pass
    
    return nodes,edges,elements