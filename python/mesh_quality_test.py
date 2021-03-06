# Autogenerated with SMOP 
from smop.core import *
# 

    ##
#==============================================================================
# Copyright (c) 2016-2017 Universite de Lorraine & Lulea tekniska universitet
# Author: Luca Di Stasio <luca.distasio@gmail.com>
#                        <luca.distasio@ingpec.eu>
    
    # Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 
# Redistributions of source code must retain the above copyright
# notice, this list of conditions and the following disclaimer.
# Redistributions in binary form must reproduce the above copyright
# notice, this list of conditions and the following disclaimer in
# the documentation and/or other materials provided with the distribution
# Neither the name of the Universite de Lorraine or Lulea tekniska universitet
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
#  Abaqus preprocessor script
#
    
    
    clear('all')
    close_('all')
    N1=100
    N2=10
    N3=80
    N4=80
    N5=20
    N6=20
    optimized=0
    nodes,edges,elements,fiberN,matrixN,part6bot,part6up,fiberEl,matrixEl,cohesiveEl,boundedBot,boundedUp,gammaNo1,gammaNo2,gammaNo3,gammaNo4,gammaEl1,gammaEl2,gammaEl3,gammaEl4,NintUpNine,NintUpZero,NintBotNine,NintBotZero,NintUpNineCorners,NintUpZeroCorners,NintBotNineCorners,NintBotZeroCorners,NbotRight,NbotLeft,NupRight,NupLeft,EintUpNine,EintUpZero,EintBotNine,EintBotZero,EbotRight,EbotLeft,EupRight,EupLeft,Ncorners,Ndown,Nright,Nup,Nleft,Edown,Eright,Eup,Eleft=rve_mesh(1,0,0,0,1,1,1,optimized,1.0,0.001,1.0,0.0,0.523598775598,0.43,0.95,1.05,N1,N2,N3,N4,N5,N6,nargout=49)
    fshape,minL,maxL,meanL,minAlpha,maxAlpha,meanAlpha,minD,maxD,meanD,betas,A,minA,maxA,meanA,e1,e2,e3,e4,f1,f2,f3,f4,ar,skew,Tx,Ty,stretch,J,JA=quad4quality(nodes,elements,nargout=30)
    elCentroids=matlabarray(cat(dot(0.25,(nodes[elements[:,1],1] + nodes[elements[:,2],1] + nodes[elements[:,3],1] + nodes[elements[:,4],1])),dot(0.25,(nodes[elements[:,1],2] + nodes[elements[:,2],2] + nodes[elements[:,3],2] + nodes[elements[:,4],2]))))
    # xmin = min(elCentroids(:,1));
# xmax = max(elCentroids(:,1));
# ymin = min(elCentroids(:,2));
# ymax = max(elCentroids(:,2));
# 
# x = linspace(xmin,xmax,1000);
# y = linspace(ymin,ymax,1000);
# 
# [X,Y] = meshgrid(x,y);
# 
# f = TriScatteredInterp(elCentroids(:,1),elCentroids(:,2),fshape);
# 
# Z = f(X,Y);
    
    # figure()
# contourf(X,Y,Z)
# hold on
# grid on
# title('Shape factor')
    
    figure()
    subplot(4,2,1)
    hist(fshape)
    hold('on')
    grid('on')
    title('Shape factor, 10 bins')
    subplot(4,2,2)
    hist(fshape,100)
    hold('on')
    grid('on')
    title('Shape factor, 100 bins')
    subplot(4,2,3)
    hist(ar)
    hold('on')
    grid('on')
    title('Aspect Ratio, 10 bins')
    subplot(4,2,4)
    hist(ar,100)
    hold('on')
    grid('on')
    title('Aspect Ratio, 100 bins')
    subplot(4,2,5)
    hist(skew)
    hold('on')
    grid('on')
    title('Skewness, 10 bins')
    subplot(4,2,6)
    hist(skew,100)
    hold('on')
    grid('on')
    title('Skewness, 100 bins')
    subplot(4,2,7)
    hist(stretch)
    hold('on')
    grid('on')
    title('Stretch, 10 bins')
    subplot(4,2,8)
    hist(stretch,100)
    hold('on')
    grid('on')
    title('Stretch, 100 bins')