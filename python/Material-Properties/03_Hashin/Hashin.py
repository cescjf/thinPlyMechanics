# Autogenerated with SMOP 
from smop.core import *
# 

    
@function
def Hashin(Vf=None,rhof=None,ELf=None,ETf=None,nu12f=None,nu23f=None,alphaLf=None,alphaTf=None,rhom=None,ELm=None,ETm=None,num=None,alpham=None,*args,**kwargs):
    varargin = Hashin.varargin
    nargin = Hashin.nargin

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
#  A function implementing the Hashin (CCA) method for fiber reinforced
#  composite plies
    
    ##
    
    Vm=1 - Vf
    G12f=dot(0.5,ELf) / (1 + nu12f)
    Gm=dot(0.5,ELm) / (1 + num)
    rhoc=dot(rhof,Vf) + dot(rhom,Vm)
    kmT=dot(0.5,ELm) / (1 - num - dot(2,num ** 2))
    kfT=dot(ELf,ETf) / (dot(dot(2,ELf),(1 - nu23f)) - dot(dot(4,ETf),nu12f ** 2))
    lambda1=dot(2,(1 / Gm + Vf / kmT + Vm / kfT) ** (- 1))
    E1=dot(Vf,ELf) + dot(Vm,ELm) + dot(dot(dot(dot(2,lambda1),Vf),Vm),(num - nu12f) ** 2)
    nu12=dot(Vf,nu12f) + dot(Vm,num) + dot(dot(dot(dot(dot(0.5,lambda1),(num - nu12f)),(1 / kfT - 1 / kmT)),Vf),Vm)
    G12=Gm + Vf / (1 / (G12f - Gm) + dot(0.5,Vm) / Gm)
    K23=(dot(dot(kmT,(kfT + Gm)),Vm) + dot(dot(kfT,(kmT + Gm)),Vf)) / (dot((kfT + Gm),Vm) + dot((kmT + Gm),Vf))
    lambda3=1 + dot(4,(dot(K23,nu12 ** 2))) / E1
    G23=Gm + Vf / (1 / (dot(0.5,ETf) / (1 + nu23f) - Gm) + dot(Vm,(kmT + dot(2,Gm))) / (dot(dot(2,Gm),(kmT + Gm))))
    E2=dot(4,G23) / (1 + dot(lambda3,G23) / K23)
    nu21=dot(nu12,(E2 / E1))
    nu23=dot(nu12,(1 - nu21)) / (1 - nu12)
    km=Gm / (1 - dot(2,num))
    lambda_=(dot(0.5,(1 / Gm + Vf / km + Vm / kfT))) ** (- 1)
    alpha1=(dot(dot(ELf,alphaf),Vf) + dot(dot(ELm,alpham),Vm)) / (dot(ELf,Vf) + dot(ELm,Vm))
    alpha2=dot(- nu12,alpha1) + dot((alphaTf + dot(nu12f,alphaLf)),Vf) + dot((alpham + dot(num,alpham)),Vm) + dot(dot(dot(dot(dot(0.5,lambda_),(1 / kfT - 1 / km)),Vf),Vm),((alpham + dot(num,alpham)) - (alphaTf + dot(nu23f,alphaLf))))
    return rhoc,E1,E2,nu12,nu21,G12,nu23,G23,alpha1,alpha2