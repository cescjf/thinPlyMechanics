# Autogenerated with SMOP 
from smop.core import *
# 

    
@function
def RoM(Vf=None,rhof=None,ELf=None,ETf=None,nuf=None,alphaf=None,rhom=None,ELm=None,ETm=None,num=None,alpham=None,*args,**kwargs):
    varargin = RoM.varargin
    nargin = RoM.nargin

    ##
#==============================================================================
# Copyright (c) 2017 Universit de Lorraine & Lule tekniska universitet
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
#  A function implementing the Rule of Mixtures for fiber reinforced
#  composite plies
    
    ##
    
    Vm=1 - Vf
    Gf=dot(0.5,ELf) / (1 + nuf)
    Gm=dot(0.5,ELm) / (1 + num)
    rhoc=dot(rhof,Vf) + dot(rhom,Vm)
    E1=dot(ELf,Vf) + dot(ELm,Vm)
    E2=(Vf / ETf + Vm / ETm) ** (- 1)
    nu12=dot(nuf,Vf) + dot(num,Vm)
    G12=(Vf / Gf + Vm / Gm) ** (- 1)
    nu21=dot(nu12,(E2 / E1))
    nu23=dot(nu12,(1 - nu21)) / (1 - nu12)
    G23=dot(0.5,E2) / (1 + nu23)
    alpha1=(dot(dot(ELf,alphaf),Vf) + dot(dot(ELm,alpham),Vm)) / (dot(ELf,Vf) + dot(ELm,Vm))
    alpha2=dot(dot((1 + nuf),alphaf),Vf) + dot(dot((1 + num),alpham),Vm) - dot(alpha1,nu12)
    return rhoc,E1,E2,nu12,nu21,G12,nu23,G23,alpha1,alpha2