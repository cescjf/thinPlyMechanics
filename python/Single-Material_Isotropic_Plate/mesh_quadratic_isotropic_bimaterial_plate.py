# Autogenerated with SMOP 
from smop.core import *
# 

    
@function
def mesh_quadratic_isotropic_bimaterial_plate(isCohesive=None,x0=None,y0low=None,y0up=None,lx=None,ly=None,Nxo1=None,Nyo1=None,xA=None,deltaA=None,*args,**kwargs):
    varargin = mesh_quadratic_isotropic_bimaterial_plate.varargin
    nargin = mesh_quadratic_isotropic_bimaterial_plate.nargin

    ##
#==============================================================================
# Copyright (c) 2016-2017 Universit de Lorraine & Lule tekniska universitet
# Author: Luca Di Stasio <luca.distasio@gmail.com>
#                        <luca.distasio@ingpec.eu>
    
    # Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
    
    
    # Redistributions of source code must retain the above copyright
# notice, this list of conditions and the following disclaimer.
# Redistributions in binary form must reproduce the above copyright
# notice, this list of conditions and the following disclaimer in
# the documentation and/or other materials provided with the distribution
# Neither the name of the Universit de Lorraine or Lule tekniska universitet
# nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.
    
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
    
    #-------------------------------------------------------------------------#
#-------------------------------------------------------------------------#
#-                          Input Data                                   -#
#-------------------------------------------------------------------------#
#-------------------------------------------------------------------------#
    
    Nx=zeros(length(Nxo1))
    for i in arange(1,length(Nxo1)).reshape(-1):
        Nx[i]=dot(2,Nxo1[i])
    
    Ny=zeros(length(Nyo1))
    for i in arange(1,length(Nyo1)).reshape(-1):
        Ny[i]=dot(2,Nyo1[i])
    
    #-------------------------------------------------------------------------#
#-------------------------------------------------------------------------#
#-                        Lower Half Nodes                               -#
#-------------------------------------------------------------------------#
#-------------------------------------------------------------------------#
    
    lowerHalfNodesTemp=gradedRectangle(x0,y0low,lx,cat([ly[2]],[ly[1]]),Nx,cat([Ny[2]],[Ny[1]]))
    lowerHalfNodes=matlabarray([])
    for j in arange(1,sum(Nyo1)).reshape(-1):
        lowerHalfNodes=matlabarray(cat([lowerHalfNodes],[lowerHalfNodesTemp[dot(dot((j - 1),2),(sum(Nx) + 1)) + 1:dot(dot((j - 1),2),(sum(Nx) + 1)) + (sum(Nx) + 1),:]],[lowerHalfNodesTemp[dot(dot((j - 1),2),(sum(Nx) + 1)) + (sum(Nx) + 1) + 1:2:dot(dot((j - 1),2),(sum(Nx) + 1)) + dot(2,(sum(Nx) + 1)),:]]))
    
    lowerHalfNodes=matlabarray(cat([lowerHalfNodes],[lowerHalfNodesTemp[dot(sum(Ny),(sum(Nx) + 1)) + 1:dot((sum(Ny) + 1),(sum(Nx) + 1)),:]]))
    clear('lowerHalfNodesTemp')
    # get corners' nodes
    
    lowerSWnode=1
    lowerSEnode=sum(Nx) + 1
    lowerNEnode=length(lowerHalfNodes)
    lowerNWnode=dot((sum(Nx) + 1),sum(Ny)) + 1
    # get sides' nodes except corners' nodes
    
    lowerSOUTHsideNodes=(arange(lowerSWnode,lowerSEnode)).T
    lowerEASTsideNodes=(arange(lowerSEnode,lowerNEnode,sum(Nx) + 1)).T
    lowerNORTHsideNodes=(arange(lowerNEnode,lowerNWnode,- 1)).T
    lowerWESTsideNodes=(arange(lowerNWnode,lowerSWnode,- (sum(Nx) + 1))).T
    #-------------------------------------------------------------------------#
#-------------------------------------------------------------------------#
#-                         Upper Half Nodes                              -#
#-------------------------------------------------------------------------#
#-------------------------------------------------------------------------#
    
    upperHalfNodesTemp=gradedRectangle(x0,y0up,lx,ly,Nx,Ny)
    upperHalfNodes=matlabarray([])
    for j in arange(1,sum(Nyo1)).reshape(-1):
        upperHalfNodes=matlabarray(cat([upperHalfNodes],[upperHalfNodesTemp[dot(dot((j - 1),2),(sum(Nx) + 1)) + 1:dot(dot((j - 1),2),(sum(Nx) + 1)) + (sum(Nx) + 1),:]],[upperHalfNodesTemp[dot(dot((j - 1),2),(sum(Nx) + 1)) + (sum(Nx) + 1) + 1:2:dot(dot((j - 1),2),(sum(Nx) + 1)) + dot(2,(sum(Nx) + 1)),:]]))
    
    upperHalfNodes=matlabarray(cat([upperHalfNodes],[upperHalfNodesTemp[dot(sum(Ny),(sum(Nx) + 1)) + 1:dot((sum(Ny) + 1),(sum(Nx) + 1)),:]]))
    clear('upperHalfNodesTemp')
    offset=length(lowerHalfNodes)
    # get corners' nodes
    
    upperSWnode=offset + 1
    upperSEnode=offset + sum(Nx) + 1
    upperNEnode=offset + length(upperHalfNodes)
    upperNWnode=offset + dot((sum(Nx) + 1),sum(Ny)) + 1
    # get sides' nodes except corners' nodes
    
    upperSOUTHsideNodes=(arange(upperSWnode,upperSEnode)).T
    upperEASTsideNodes=(arange(upperSEnode,upperNEnode,sum(Nx) + 1)).T
    upperNORTHsideNodes=(arange(upperNEnode,upperNWnode,- 1)).T
    upperWESTsideNodes=(arange(upperNWnode,upperSWnode,- (sum(Nx) + 1))).T
    #-------------------------------------------------------------------------#
#-------------------------------------------------------------------------#
#-                            All Nodes                                  -#
#-------------------------------------------------------------------------#
#-------------------------------------------------------------------------#
    
    allNodes=matlabarray(cat([lowerHalfNodes],[upperHalfNodes]))
    #-------------------------------------------------------------------------#
#-------------------------------------------------------------------------#
#-                         Interface Nodes                               -#
#-------------------------------------------------------------------------#
#-------------------------------------------------------------------------#
    
    # get lower interface
    
    lowerInterfaceNodes=copy(lowerNORTHsideNodes)
    lowerEASTboundedInterfaceNodes=matlabarray([])
    lowerWESTboundedInterfaceNodes=matlabarray([])
    lowerDEBONDinterfaceNodes=matlabarray([])
    for i in arange(1,length(lowerInterfaceNodes)).reshape(-1):
        if allNodes[lowerInterfaceNodes[i],1] < (xA + dot(0.5,deltaA)) and allNodes[lowerInterfaceNodes[i],1] > (xA - dot(0.5,deltaA)):
            lowerDEBONDinterfaceNodes=matlabarray(cat([lowerDEBONDinterfaceNodes],[lowerInterfaceNodes[i]]))
        else:
            if allNodes[lowerInterfaceNodes[i],1] >= (xA + dot(0.5,deltaA)):
                lowerEASTboundedInterfaceNodes=matlabarray(cat([lowerEASTboundedInterfaceNodes],[lowerInterfaceNodes[i]]))
            else:
                lowerWESTboundedInterfaceNodes=matlabarray(cat([lowerWESTboundedInterfaceNodes],[lowerInterfaceNodes[i]]))
    
    if logical_not(isempty(lowerEASTboundedInterfaceNodes)):
        lowerEASTcrackTipNode=lowerEASTboundedInterfaceNodes[end()]
    else:
        lowerEASTcrackTipNode=0
    
    if logical_not(isempty(lowerWESTboundedInterfaceNodes)):
        lowerWESTcrackTipNode=lowerWESTboundedInterfaceNodes[1]
    else:
        lowerWESTcrackTipNode=0
    
    # get upper interface
    
    upperInterfaceNodes=copy(upperSOUTHsideNodes)
    upperEASTboundedInterfaceNodes=matlabarray([])
    upperWESTboundedInterfaceNodes=matlabarray([])
    upperDEBONDinterfaceNodes=matlabarray([])
    for i in arange(length(upperInterfaceNodes),1,- 1).reshape(-1):
        if allNodes[upperInterfaceNodes[i],1] < (xA + dot(0.5,deltaA)) and allNodes[upperInterfaceNodes[i],1] > (xA - dot(0.5,deltaA)):
            upperDEBONDinterfaceNodes=matlabarray(cat([upperDEBONDinterfaceNodes],[upperInterfaceNodes[i]]))
        else:
            if allNodes[upperInterfaceNodes[i],1] >= (xA + dot(0.5,deltaA)):
                upperEASTboundedInterfaceNodes=matlabarray(cat([upperEASTboundedInterfaceNodes],[upperInterfaceNodes[i]]))
            else:
                upperWESTboundedInterfaceNodes=matlabarray(cat([upperWESTboundedInterfaceNodes],[upperInterfaceNodes[i]]))
    
    if logical_not(isempty(upperEASTboundedInterfaceNodes)):
        upperEASTcrackTipNode=upperEASTboundedInterfaceNodes[end()]
    else:
        upperEASTcrackTipNode=0
    
    if logical_not(isempty(upperWESTboundedInterfaceNodes)):
        upperWESTcrackTipNode=upperWESTboundedInterfaceNodes[1]
    else:
        upperWESTcrackTipNode=0
    
    #-------------------------------------------------------------------------#
#-------------------------------------------------------------------------#
#-                       Lower Half Elements                             -#
#-------------------------------------------------------------------------#
#-------------------------------------------------------------------------#
    
    lowerHalfElements=zeros(dot(sum(Nx),sum(Ny)),4)
    for j in arange(1,sum(Ny)).reshape(-1):
        lowerHalfElements[dot((j - 1),sum(Nx)) + 1:dot(j,sum(Nx)),1]=dot((j - 1),(sum(Nx) + 1)) + (arange(1,sum(Nx))).T
        lowerHalfElements[dot((j - 1),sum(Nx)) + 1:dot(j,sum(Nx)),2]=dot((j - 1),(sum(Nx) + 1)) + (arange(2,sum(Nx) + 1)).T
        lowerHalfElements[dot((j - 1),sum(Nx)) + 1:dot(j,sum(Nx)),3]=dot(j,(sum(Nx) + 1)) + (arange(2,sum(Nx) + 1)).T
        lowerHalfElements[dot((j - 1),sum(Nx)) + 1:dot(j,sum(Nx)),4]=dot(j,(sum(Nx) + 1)) + (arange(1,sum(Nx))).T
    
    # get interface elements
    
    lowerInterfaceElements=(arange(length(lowerHalfElements),dot((sum(Ny) - 1),sum(Nx)) + 1,- 1)).T
    # get distributed load elements
    
    lowerSOUTHsideElements=(arange(1,sum(Nx))).T
    #-------------------------------------------------------------------------#
#-------------------------------------------------------------------------#
#-                       Upper Half Elements                             -#
#-------------------------------------------------------------------------#
#-------------------------------------------------------------------------#
    
    offset=length(lowerHalfNodes)
    upperHalfElements=zeros(dot(sum(Nx),sum(Ny)),4)
    for j in arange(1,sum(Ny)).reshape(-1):
        upperHalfElements[dot((j - 1),sum(Nx)) + 1:dot(j,sum(Nx)),1]=offset + dot((j - 1),(sum(Nx) + 1)) + (arange(1,sum(Nx))).T
        upperHalfElements[dot((j - 1),sum(Nx)) + 1:dot(j,sum(Nx)),2]=offset + dot((j - 1),(sum(Nx) + 1)) + (arange(2,sum(Nx) + 1)).T
        upperHalfElements[dot((j - 1),sum(Nx)) + 1:dot(j,sum(Nx)),3]=offset + dot(j,(sum(Nx) + 1)) + (arange(2,sum(Nx) + 1)).T
        upperHalfElements[dot((j - 1),sum(Nx)) + 1:dot(j,sum(Nx)),4]=offset + dot(j,(sum(Nx) + 1)) + (arange(1,sum(Nx))).T
    
    offset=length(lowerHalfElements)
    # get interface elements
    
    upperInterfaceElements=offset + (arange(1,sum(Nx))).T
    # get distributed load elements
    
    upperNORTHsideElements=offset + (arange(dot((sum(Ny) - 1),sum(Nx)) + 1,length(upperHalfElements))).T
    #-------------------------------------------------------------------------#
#-------------------------------------------------------------------------#
#-                          All Elements                                 -#
#-------------------------------------------------------------------------#
#-------------------------------------------------------------------------#
    
    allElements=matlabarray(cat([lowerHalfElements],[upperHalfElements]))
    #-------------------------------------------------------------------------#
#-------------------------------------------------------------------------#
#-                      Interface Elements                               -#
#-------------------------------------------------------------------------#
#-------------------------------------------------------------------------#
    
    # get lower interface elements
    
    lowerEASTboundedInterfaceElements=matlabarray([])
    lowerWESTboundedInterfaceElements=matlabarray([])
    lowerDEBONDInterfaceElements=matlabarray([])
    for i in arange(1,length(lowerInterfaceElements)).reshape(-1):
        if isempty(find(lowerDEBONDinterfaceNodes == allElements[lowerInterfaceElements[i],3])) and isempty(find(lowerDEBONDinterfaceNodes == allElements[lowerInterfaceElements[i],4])):
            if logical_not(isempty(find(lowerEASTboundedInterfaceNodes == allElements[lowerInterfaceElements[i],3]))):
                lowerEASTboundedInterfaceElements=matlabarray(cat([lowerEASTboundedInterfaceElements],[lowerInterfaceElements[i]]))
            else:
                lowerWESTboundedInterfaceElements=matlabarray(cat([lowerWESTboundedInterfaceElements],[lowerInterfaceElements[i]]))
        else:
            lowerDEBONDInterfaceElements=matlabarray(cat([lowerDEBONDInterfaceElements],[lowerInterfaceElements[i]]))
    
    if logical_not(isempty(lowerEASTboundedInterfaceElements)):
        lowerEASTcrackTipElement=lowerEASTboundedInterfaceElements[end()]
    else:
        lowerEASTcrackTipElement=0
    
    if logical_not(isempty(lowerWESTboundedInterfaceElements)):
        lowerWESTcrackTipElement=lowerWESTboundedInterfaceElements[1]
    else:
        lowerWESTcrackTipElement=0
    
    # get upper interface elements
    
    upperEASTboundedInterfaceElements=matlabarray([])
    upperWESTboundedInterfaceElements=matlabarray([])
    upperDEBONDInterfaceElements=matlabarray([])
    for i in arange(1,length(upperInterfaceElements)).reshape(-1):
        if isempty(find(upperDEBONDinterfaceNodes == allElements[upperInterfaceElements[i],2])) and isempty(find(upperDEBONDinterfaceNodes == allElements[upperInterfaceElements[i],1])):
            if logical_not(isempty(find(upperEASTboundedInterfaceNodes == allElements[upperInterfaceElements[i],2]))):
                upperEASTboundedInterfaceElements=matlabarray(cat([upperEASTboundedInterfaceElements],[upperInterfaceElements[i]]))
            else:
                upperWESTboundedInterfaceElements=matlabarray(cat([upperWESTboundedInterfaceElements],[upperInterfaceElements[i]]))
        else:
            upperDEBONDInterfaceElements=matlabarray(cat([upperDEBONDInterfaceElements],[upperInterfaceElements[i]]))
    
    if logical_not(isempty(upperEASTboundedInterfaceElements)):
        upperEASTcrackTipElement=upperEASTboundedInterfaceElements[end()]
    else:
        upperEASTcrackTipElement=0
    
    if logical_not(isempty(upperWESTboundedInterfaceElements)):
        upperWESTcrackTipElement=upperWESTboundedInterfaceElements[1]
    else:
        upperWESTcrackTipElement=0
    
    #-------------------------------------------------------------------------#
#-------------------------------------------------------------------------#
#-                         Cohesive Layer                                -#
#-------------------------------------------------------------------------#
#-------------------------------------------------------------------------#
    
    if isCohesive:
        pass
    
    return allNodes,lowerHalfNodes,upperHalfNodes,lowerSWnode,lowerSEnode,lowerNEnode,lowerNWnode,lowerSOUTHsideNodes,lowerEASTsideNodes,lowerNORTHsideNodes,lowerWESTsideNodes,upperSWnode,upperSEnode,upperNEnode,upperNWnode,upperSOUTHsideNodes,upperEASTsideNodes,upperNORTHsideNodes,upperWESTsideNodes,lowerInterfaceNodes,lowerEASTboundedInterfaceNodes,lowerWESTboundedInterfaceNodes,lowerDEBONDinterfaceNodes,lowerEASTcrackTipNode,lowerWESTcrackTipNode,upperInterfaceNodes,upperEASTboundedInterfaceNodes,upperWESTboundedInterfaceNodes,upperDEBONDinterfaceNodes,upperEASTcrackTipNode,upperWESTcrackTipNode,allElements,lowerHalfElements,upperHalfElements,lowerInterfaceElements,upperInterfaceElements,lowerEASTboundedInterfaceElements,lowerWESTboundedInterfaceElements,lowerDEBONDInterfaceElements,lowerEASTcrackTipElement,lowerWESTcrackTipElement,upperEASTboundedInterfaceElements,upperWESTboundedInterfaceElements,upperDEBONDInterfaceElements,upperEASTcrackTipElement,upperWESTcrackTipElement,lowerSOUTHsideElements,upperNORTHsideElements