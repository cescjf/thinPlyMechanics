function[projectName]=bmip_mesh_create_project(folder,matDBfolder,index,...
                                               isCohesive,isSymm,x0,y0low,y0up,lx1,lx2,ly1,ly2,Nx1,Nx2,Ny1,Ny2,xA,deltaA,...
                                               lowerMaterial,upperMaterial,interfaceDef,epsyy,dT,unitConvFactor,...
                                               element,order,generalized,...
                                               requestDAT,requestFIL,requestODB)
%%
%==============================================================================
% Copyright (c) 2016-2017 Universit� de Lorraine & Lule� tekniska universitet
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
%  A script to generate the project files for RVE Finite Elements
%  Simulations:
%
%   .json
%   .csv
%   .tex
%   .inp
%
%  unitConvFactor(1)  => length
%  unitConvFactor(2)  => mass
%  unitConvFactor(3)  => time
%  unitConvFactor(4)  => electric current
%  unitConvFactor(5)  => thermodynamic temperature
%  unitConvFactor(6)  => amount of substance
%  unitConvFactor(7)  => luminous intensity
%  unitConvFactor(8)  => density
%  unitConvFactor(9)  => pressure/stress
%  unitConvFactor(10) => thermal expansion
%  unitConvFactor(11) => thermal conductivity
%  unitConvFactor(12) => specific heat capacity
%  unitConvFactor(13) => fracture toughness
%  unitConvFactor(14) => interface stiffness
%  unitConvFactor(15) => force
%
%%

%-------------------------------------------------------------------------%
%-------------------------------------------------------------------------%
%-                     Preliminary Calculations                          -%
%-------------------------------------------------------------------------%
%-------------------------------------------------------------------------%
%%
nodesTOT = 0;

elTOT = 0;

if isSymm
    nodesTOT = 2*((Nx1+Nx2+1)*(Ny1+Ny2+1));
    elTOT = 2*((Nx1+Nx2)*(Ny1+Ny2));
else
    nodesTOT = 2*((Nx1+2*Nx2+1)*(Ny1+Ny2+1));
    elTOT = 2*((Nx1+2*Nx2)*(Ny1+Ny2));
end

modelcode = strcat('VL4FC-2DbmipCC-',num2str(isCohesive), '-',num2str(isSymm), '-',num2str(x0), '-', num2str(y0low), '-',...
		num2str(y0up), '-', num2str(lx1), '-', num2str(lx2), '-',num2str(ly1), '-',num2str(ly2), '-', num2str(xA), '-', num2str(deltaA),'-', num2str(Nx1), '-',...
        num2str(Nx2), '-', num2str(Ny1), '-',num2str(Ny2), '-',...
        num2str(lowerMaterial), '-', num2str(upperMaterial), '-', num2str(interfaceDef), '-', num2str(epsyy), '-', num2str(dT),'-', ...
        num2str(element), '-', num2str(order), '-', num2str(generalized), '-', ...
		num2str(nodesTOT), '-',num2str(elTOT));
        
%-------------------------------------------------------------------------%
%-------------------------------------------------------------------------%
%-                          I/O settings                                 -%
%-------------------------------------------------------------------------%
%-------------------------------------------------------------------------%
%%

projectName = '';

if ~checkIndex(folder,strcat(index,'.csv'),modelcode)
    projectName = incrementName(folder,strcat(index,'.csv'));
    createWD(folder,projectName);
    fileId = fopen(fullfile(folder,strcat(index,'.csv')),'a');
    fprintf(fileId,'%s',strcat(projectName,',',modelcode));
    fprintf(fileId,'\n');
    fclose(fileId);
else
    projectName = strcat('A model with this set of parameters already exists. See: ',getModelFolder(folder,strcat(index,'.csv'),modelcode));
    return
end

%%
%-------------------------------------------------------------------------%
%-------------------------------------------------------------------------%
%-                        Mesh Generation                                -%
%-------------------------------------------------------------------------%
%-------------------------------------------------------------------------%
%%

if isSymm
    Nx = [Nx1;Nx2];
    lx = [lx1;lx2];
    w = lx1 + lx2;
else
    Nx = [Nx2;Nx1;Nx2];
    lx = [lx2;lx1;lx2];
    w = lx1 + 2*lx2;
end

Ny = [Ny1;Ny2];
ly = [ly1;ly2];
h = ly1 + ly2;

[allNodes,lowerHalfNodes,upperHalfNodes,lowerSWnode,lowerSEnode,lowerNEnode,lowerNWnode,...
         lowerSOUTHsideNodes,lowerEASTsideNodes,lowerNORTHsideNodes,lowerWESTsideNodes,...
         upperSWnode,upperSEnode,upperNEnode,upperNWnode,...
         upperSOUTHsideNodes,upperEASTsideNodes,upperNORTHsideNodes,upperWESTsideNodes,...
         lowerInterfaceNodes,lowerEASTboundedInterfaceNodes,lowerWESTboundedInterfaceNodes,...
         lowerDEBONDInterfaceNodes,lowerEASTcrackTipNode,lowerWESTcrackTipNode,...
         upperInterfaceNodes,upperEASTboundedInterfaceNodes,upperWESTboundedInterfaceNodes,...
         upperDEBONDInterfaceNodes,upperEASTcrackTipNode,upperWESTcrackTipNode,...
         allElements,lowerHalfElements,upperHalfElements,lowerInterfaceElements,upperInterfaceElements,...
         lowerEASTboundedInterfaceElements,lowerWESTboundedInterfaceElements,...
         lowerDEBONDInterfaceElements,lowerEASTcrackTipElement,lowerWESTcrackTipElement,...
         upperEASTboundedInterfaceElements,upperWESTboundedInterfaceElements,...
         upperDEBONDInterfaceElements,upperEASTcrackTipElement,upperWESTcrackTipElement,...
         lowerSOUTHsideElements,upperNORTHsideElements]=mesh_isotropic_bimaterial_plate(isCohesive,x0,y0low,y0up,lx,ly,Nx,Ny,xA,deltaA);
                                                                                                                     
%%
%-------------------------------------------------------------------------%
%-------------------------------------------------------------------------%
%-                        Write .inp file                                -%
%-------------------------------------------------------------------------%
%-------------------------------------------------------------------------%
%%
% create the filepath
abqpath = fullfile(folder,projectName,'abqinp',strcat(projectName,'.inp'));

% create the file
abqinpID = fopen(abqpath,'w');
fclose(abqinpID);

%% HEADER SECTION

switch lowerMaterial
    case 1
        lowMat = 'CarbonFiber';
    case 2
        lowMat = 'GlassFiber';
    otherwise
        lowMat = 'CarbonFiber';
end
switch upperMaterial
    case 1
        upMat = 'Epoxy';
    case 2
        upMat = 'HDPE';
    otherwise
        upMat = 'Epoxy';
end
switch interfaceDef
    case 1
        interfaceFormulation = 'Contact with fracture interaction and debond growth';
    case 2
        interfaceFormulation = 'Tied surfaces and Contact with debond fracture interaction at crack tips';
    case 3
        interfaceFormulation = 'Equation-based continuity at surfaces and Contact with debond fracture interaction at crack tips';
    case 4
        interfaceFormulation = 'Tied surfaces';
    case 5
        interfaceFormulation = 'Equation-based continuity at surfaces';
    case 6
        interfaceFormulation = 'Connector elements';
end
if element==1
    eltype = 'Quadrilateral';
elseif element==2
    eltype = 'Triangular';
else
    eltype = 'NA';
end
if order==1
    elorder = '1st';
elseif order==2
    elorder = '2nd';
else
    elorder = 'NA';
end
if dT~=0
    if generalized
        if isCohesive
           if element==1 && order==1
              elId = 'CPEG4T & COH2D4';
           elseif element==1 && order==2
              elId = 'CPEG8T & COH2D4';
           elseif element==2 && order==1
              elId = 'CPEG3T & COH2D4';
           elseif element==1 && order==1
              elId = 'CPEG6MT & COH2D4';
           else
              elId = 'NA';
           end
        else
           if element==1 && order==1
              elId = 'CPEG4T';
           elseif element==1 && order==2
              elId = 'CPEG8T';
           elseif element==2 && order==1
              elId = 'CPEG3T';
           elseif element==1 && order==1
              elId = 'CPEG6MT';
           else
              elId = 'NA';
           end
        end
    else
        if isCohesive
           if element==1 && order==1
              elId = 'CPE4T & COH2D4';
           elseif element==1 && order==2
              elId = 'CPE8T & COH2D4';
           elseif element==2 && order==1
              elId = 'CPE3T & COH2D4';
           elseif element==1 && order==1
              elId = 'CPE6MT & COH2D4';
           else
              elId = 'NA';
           end
        else
           if element==1 && order==1
              elId = 'CPE4T';
           elseif element==1 && order==2
              elId = 'CPE8T';
           elseif element==2 && order==1
              elId = 'CPE3T';
           elseif element==1 && order==1
              elId = 'CPE6MT';
           else
              elId = 'NA';
           end
        end
    end
else
    if generalized
        if isCohesive
           if element==1 && order==1
              elId = 'CPEG4 & COH2D4';
           elseif element==1 && order==2
              elId = 'CPEG8 & COH2D4';
           elseif element==2 && order==1
              elId = 'CPEG3 & COH2D4';
           elseif element==2 && order==2
              elId = 'CPEG6 & COH2D4';
           else
              elId = 'NA';
           end
        else
           if element==1 && order==1
              elId = 'CPEG4';
           elseif element==1 && order==2
              elId = 'CPEG8';
           elseif element==2 && order==1
              elId = 'CPEG3';
           elseif element==2 && order==2
              elId = 'CPEG6';
           else
              elId = 'NA';
           end
        end
    else
        if isCohesive
           if element==1 && order==1
              elId = 'CPE4 & COH2D4';
           elseif element==1 && order==2
              elId = 'CPE8 & COH2D4';
           elseif element==2 && order==1
              elId = 'CPE3 & COH2D4';
           elseif element==2 && order==2
              elId = 'CPE6 & COH2D4';
           else
              elId = 'NA';
           end
        else
           if element==1 && order==1
              elId = 'CPE4';
           elseif element==1 && order==2
              elId = 'CPE8';
           elseif element==2 && order==1
              elId = 'CPE3';
           elseif element==2 && order==2
              elId = 'CPE6';
           else
              elId = 'NA';
           end
        end
    end
end


% write header
header ={'--                                                                                                                                                                --'; ...
         '--                                         MECHANICS OF EXTREME THIN PLIES IN FIBER REINFORCED COMPOSITE LAMINATES                                                --'; ...
         '--                                                                                                                                                                --'; ...
         '--                                        2D PARAMETRIC SIMULATION OF BI-MATERIAL ISOTROPIC PLATE WITH CENTRAL CRACK                                                        --'; ...
         '--                                                                                                                                                                --'; ...
         '--                                                                                                                                                                --'; ...
         '--------------------------------------------------------------------------------------------------------------------------------------------------------------------'; ...
         '--                                                                                                                             --'; ...
         ['--                       Model Code: ',modelcode,'  --']; ...
         ['--                  Space Dimension: 2D','  --']; ...
         '--                                                                                                                             --'; ...
         ['--                            Width: ',num2str(w),'  --']; ...
         ['--                           Height: ',num2str(h),'  --']; ...
         ['--                  Crack''s Length: ',num2str(deltaA),'  --']; ...
         ['--            Plate''s Aspect Ratio: ',num2str(0.5*w/h),'  --']; ...
         ['-- Crack''s Horizontal Aspect Ratio: ',num2str(deltaA/w),'  --']; ...
         ['--   Crack''s Vertical Aspect Ratio: ',num2str(0.5*deltaA/h),'  --']; ...
         '--                                                                                                                             --'; ...
         ['--             Applied Axial Strain: ',num2str(epsyy),'  --']; ...
         '--                                                                                                                             --'; ...
         ['--         Applied Temperature Jump: ',num2str(dT),'  --']; ...
         '--                                                                                                                             --'; ...
         ['--                   Lower Material: ',lowMat,'  --']; ...
         ['--                   Upper Material: ',upMat,'  --']; ...    
         '--                                                                                                                             --'; ...
         ['--            Interface Formulation: ',interfaceFormulation,'  --']; ...
         '--                                                                                                                             --'; ...                                                                                                                            --'; ...
         ['--                  Elements'' Type: ',eltype,'  --']; ...
         ['--                 Elements'' Order: ',elorder,'  --']; ...
         ['--                    Elements'' ID: ',elId,'  --']; ...
         '--                                                                                                                             --'; ...
         ['--                              Nx fine: ',num2str(Nx1),'  --']; ...
         ['--                            Nx coarse: ',num2str(Nx2),'  --']; ...
         ['--                              Ny fine: ',num2str(Ny1),'  --']; ...
         ['--                            Ny coarse: ',num2str(Ny2),'  --']; ...
         ['--                Total Number of Nodes: ',num2str(nodesTOT),'  --']; ...
         ['--             Total Number of Elements: ',num2str(elTOT),'  --']; ...
         '--                                                                                                                             --'; ...
         '--       Conversion factor of units of measurement with respect to SI   --'; ...
         ['--                              length, SI [m]: ',num2str(unitConvFactor(1), '%10.5e'),'  --']; ...
         ['--                               mass, SI [kg]: ',num2str(unitConvFactor(2), '%10.5e'),'  --']; ...
         ['--                                time, SI [s]: ',num2str(unitConvFactor(3), '%10.5e'),'  --']; ...
         ['--                               force, SI [N]: ',num2str(unitConvFactor(15), '%10.5e'),'  --']; ...
         ['--                    electric current, SI [A]: ',num2str(unitConvFactor(4), '%10.5e'),'  --']; ...
         ['--           thermodynamic temperature, SI [K]: ',num2str(unitConvFactor(5), '%10.5e'),'  --']; ...
         ['--               amount of substance, SI [mol]: ',num2str(unitConvFactor(6), '%10.5e'),'  --']; ...
         ['--                 luminous intensity, SI [cd]: ',num2str(unitConvFactor(7), '%10.5e'),'  --']; ...
         ['--                        density, SI [kg/m^3]: ',num2str(unitConvFactor(8), '%10.5e'),'  --']; ...
         ['--                    pressure/stress, SI [Pa]: ',num2str(unitConvFactor(9), '%10.5e'),'  --']; ...
         ['--             thermal expansion, SI [m/(m*K)]: ',num2str(unitConvFactor(10), '%10.5e'),'  --']; ...
         ['--          thermal conductivity, SI [W/(m*K)]: ',num2str(unitConvFactor(11), '%10.5e'),'  --']; ...
         ['--       specific heat capacity, SI [J/(kg*K)]: ',num2str(unitConvFactor(12), '%10.5e'),'  --']; ...
         ['--             energy release rate, SI [J/m^2]: ',num2str(unitConvFactor(13), '%10.5e'),'  --']; ...
         ['--             interface stiffness, SI [N/m^3]: ',num2str(unitConvFactor(14), '%10.5e'),'  --']; ...
         '--                                                                                                                             --'; ...
         '--                                                                                                                             --'};

writeABQheader(abqpath,header);

%write license
holder = 'Universit� de Lorraine or Lule� tekniska universitet';
author = 'Luca Di Stasio';

writeABQlicense(abqpath,holder,author);

%write heading

writeABQheading(abqpath,{['2D Bi-Mat Iso Plate CC, Plate''s AR ',num2str(0.5*w/h),' Crack''s HAR',num2str(deltaA/w),' Crack''s VAR ',num2str(0.5*deltaA/h)]},'none');

% write preprint
contact = 'YES';
echo = 'NO';
history = 'YES';
model = 'YES';
parsubstitution =  'YES';
parvalues = 'YES';
massprop = 'NO';

writeABQpreprint(abqpath,contact,echo,history,model,parsubstitution,parvalues,massprop,{},'none');

% start mesh section
writeABQmeshsec(abqpath);

%% NODES SECTION

% start nodes section
writeABQnodesec(abqpath);

% generates all nodes

writeABQnodegen(abqpath,1,1,allNodes,'All-Nodes');

% assign nodes to node sets

writeABQnodeset(abqpath,1,(1:length(lowerHalfNodes))','lowerHalf-Nodes');
writeABQnodeset(abqpath,1,length(lowerHalfNodes)+(1:length(upperHalfNodes))','upperHalf-Nodes');

writeABQnodeset(abqpath,1,lowerSWnode,'lowerSW-Node');
writeABQnodeset(abqpath,1,lowerSEnode,'lowerSE-Node');
writeABQnodeset(abqpath,1,lowerNEnode,'lowerNE-Node');
writeABQnodeset(abqpath,1,lowerNWnode,'lowerNW-Node');

writeABQnodeset(abqpath,1,lowerSOUTHsideNodes,'lowerSOUTHside-Nodes');
writeABQnodeset(abqpath,1,lowerEASTsideNodes,'lowerEASTside-Nodes');
writeABQnodeset(abqpath,1,lowerNORTHsideNodes,'lowerNORTHside-Nodes');
writeABQnodeset(abqpath,1,lowerWESTsideNodes,'lowerWESTside-Nodes');

writeABQnodeset(abqpath,1,upperSWnode,'upperSW-Node');
writeABQnodeset(abqpath,1,upperSEnode,'upperSE-Node');
writeABQnodeset(abqpath,1,upperNEnode,'upperNE-Node');
writeABQnodeset(abqpath,1,upperNWnode,'upperNW-Node');

writeABQnodeset(abqpath,1,upperSOUTHsideNodes,'upperSOUTHside-Nodes');
writeABQnodeset(abqpath,1,upperEASTsideNodes,'upperEASTside-Nodes');
writeABQnodeset(abqpath,1,upperNORTHsideNodes,'upperNORTHside-Nodes');
writeABQnodeset(abqpath,1,upperWESTsideNodes,'upperWESTside-Nodes');
        
writeABQnodeset(abqpath,1,lowerInterfaceNodes,'lowerInterface-Nodes');
writeABQnodeset(abqpath,1,upperInterfaceNodes,'upperInterface-Nodes');

writeABQnodeset(abqpath,1,lowerDEBONDInterfaceNodes,'lowerDEBONDInterface-Nodes');
writeABQnodeset(abqpath,1,lowerEASTcrackTipNode,'lowerEASTcrackTip-Node');

writeABQnodeset(abqpath,1,upperDEBONDInterfaceNodes,'upperDEBONDInterface-Nodes');
writeABQnodeset(abqpath,1,upperEASTcrackTipNode,'upperEASTcrackTip-Node');

writeABQnodeset(abqpath,1,lowerEASTboundedInterfaceNodes,'lowerEASTboundedInterface-Nodes');
writeABQnodeset(abqpath,1,upperEASTboundedInterfaceNodes,'upperEASTboundedInterface-Nodes');
writeABQnodeset(abqpath,1,lowerEASTboundedInterfaceNodes(1:end-1),'lowerEASTboundedInterfaceWithoutTip-Nodes');
writeABQnodeset(abqpath,1,upperEASTboundedInterfaceNodes(1:end-1),'upperEASTboundedInterfaceWithoutTip-Nodes');
writeABQnodeset(abqpath,1,lowerEASTboundedInterfaceNodes,'lowerEASTboundedInterface-Nodes');
writeABQnodeset(abqpath,1,lowerEASTboundedInterfaceNodes(1:end-1),'lowerEASTboundedInterfaceWithoutTip-Nodes');
writeABQnodeset(abqpath,1,upperEASTboundedInterfaceNodes(1:end-1),'upperEASTboundedInterfaceWithoutTip-Nodes');
writeABQnodeset(abqpath,1,upperEASTboundedInterfaceNodes,'upperEASTboundedInterface-Nodes');
writeABQnodeset(abqpath,1,upperEASTboundedInterfaceNodes(2:end),'upperEASTboundedInterfaceWithoutTip-Nodes');
    
if ~isSymm
    writeABQnodeset(abqpath,1,lowerWESTcrackTipNode,'lowerWESTcrackTip-Node');
    writeABQnodeset(abqpath,1,upperWESTcrackTipNode,'upperWESTcrackTip-Node');
    writeABQnodeset(abqpath,2,{'lowerWESTcrackTip-Node';'lowerEASTcrackTip-Node'},'lowerCrackTips-Nodes');
    writeABQnodeset(abqpath,2,{'upperWESTcrackTip-Node';'upperEASTcrackTip-Node'},'upperCrackTips-Nodes');
    writeABQnodeset(abqpath,1,lowerWESTboundedInterfaceNodes,'lowerWESTboundedInterface-Nodes');
    writeABQnodeset(abqpath,1,upperWESTboundedInterfaceNodes,'upperWESTboundedInterface-Nodes');
    writeABQnodeset(abqpath,1,upperWESTboundedInterfaceNodes(2:end),'upperWESTboundedInterfaceWithoutTip-Nodes');
    writeABQnodeset(abqpath,2,{'lowerEASTboundedInterface-Nodes';'lowerWESTboundedInterface-Nodes'},'lowerBoundedInterface-Nodes');
    writeABQnodeset(abqpath,2,{'upperEASTboundedInterface-Nodes';'upperWESTboundedInterface-Nodes'},'upperBoundedInterface-Nodes');
end

if interfaceDef==5
   if isSymm
       writeABQnodegen(abqpath,2*length(allNodes)+1,1,[0 2*h],'Dummy1-Node');
   else
       writeABQnodegen(abqpath,2*length(allNodes)+1,1,[0 -2*h;0 2*h],'Dummy-Nodes');
       writeABQnodeset(abqpath,1,[2*length(allNodes)+1],'Dummy1-Node');
       writeABQnodeset(abqpath,1,[2*length(allNodes)+2],'Dummy2-Node');
   end
end

%% ELEMENTS SECTION

% start elements part
writeABQelsec(abqpath);

if dT~=0
    if generalized
        if element==1 && order==1
          elTypeId = 'CPEG4T';
        elseif element==1 && order==2
          elTypeId = 'CPEG8T';
        elseif element==2 && order==1
          elTypeId = 'CPEG3T';
        elseif element==2 && order==2
          elTypeId = 'CPEG6MT';
        else
          elTypeId = 'CPEG4T';
        end
    else
        if element==1 && order==1
          elTypeId = 'CPE4T';
        elseif element==1 && order==2
          elTypeId = 'CPE8T';
        elseif element==2 && order==1
          elTypeId = 'CPE3T';
        elseif element==2 && order==2
          elTypeId = 'CPE6MT';
        else
          elTypeId = 'CPE4T';
        end
    end
else
    if generalized
        if element==1 && order==1
            elTypeId = 'CPEG4';
        elseif element==1 && order==2
            elTypeId = 'CPEG8';
        elseif element==2 && order==1
            elTypeId = 'CPEG3';
        elseif element==2 && order==2
            elTypeId = 'CPEG6';
        else
            elTypeId = 'CPEG4';
        end
    else
        if element==1 && order==1
            elTypeId = 'CPE4';
        elseif element==1 && order==2
            elTypeId = 'CPE8';
        elseif element==2 && order==1
            elTypeId = 'CPE3';
        elseif element==2 && order==2
            elTypeId = 'CPE6';
        else
            elTypeId = 'CPE4';
        end
    end

end

writeABQelgen(abqpath,1,1,lowerHalfElements,elTypeId,'lowerHalf-Elements');
writeABQelgen(abqpath,length(lowerHalfElements)+1,1,upperHalfElements,elTypeId,'upperHalf-Elements');

% if isCohesive
%     
% end
            
% assign elements to element sets
         
writeABQelementset(abqpath,1,lowerInterfaceElements,'lowerInterface-Elements');
writeABQelementset(abqpath,1,upperInterfaceElements,'upperInterface-Elements');

writeABQelementset(abqpath,1,lowerDEBONDInterfaceElements,'lowerDEBONDInterface-Elements');
writeABQelementset(abqpath,1,upperDEBONDInterfaceElements,'upperDEBONDInterface-Elements');

%writeABQelementset(abqpath,1,lowerEASTcrackTipElement,'lowerDEBONDInterface-Element');
%writeABQelementset(abqpath,1,lowerWESTcrackTipElement,'lowerDEBONDInterface-Element');
%writeABQelementset(abqpath,1,upperEASTcrackTipElement,'upperDEBONDInterface-Element');
%writeABQelementset(abqpath,1,upperWESTcrackTipElement,'upperDEBONDInterface-Element');

writeABQelementset(abqpath,1,lowerSOUTHsideElements,'lowerSOUTHside-Elements');
writeABQelementset(abqpath,1,upperNORTHsideElements,'upperNORTHside-Elements');

writeABQelementset(abqpath,1,lowerEASTboundedInterfaceElements,'lowerEASTboundedInterface-Elements');
writeABQelementset(abqpath,1,upperEASTboundedInterfaceElements,'upperEASTboundedInterface-Elements');
writeABQelementset(abqpath,1,lowerEASTcrackTipElement,'lowerEASTcrackTip-Element');
writeABQelementset(abqpath,1,upperEASTcrackTipElement,'upperEASTcrackTip-Element');
writeABQelementset(abqpath,1,lowerEASTboundedInterfaceElements(find(lowerEASTboundedInterfaceElements~=lowerEASTcrackTipElement)),'lowerEASTboundedInterfaceWithoutTip-Elements');
writeABQelementset(abqpath,1,upperEASTboundedInterfaceElements(find(upperEASTboundedInterfaceElements~=upperEASTcrackTipElement)),'upperEASTboundedInterfaceWithoutTip-Elements');
    
if ~isSymm
    writeABQelementset(abqpath,1,lowerWESTboundedInterfaceElements,'lowerWESTboundedInterface-Elements');
    writeABQelementset(abqpath,1,upperWESTboundedInterfaceElements,'upperWESTboundedInterface-Elements');
    writeABQelementset(abqpath,1,lowerWESTcrackTipElement,'lowerWESTcrackTip-Element');
    writeABQelementset(abqpath,1,upperWESTcrackTipElement,'upperWESTcrackTip-Element');
    writeABQelementset(abqpath,1,lowerWESTboundedInterfaceElements(find(lowerWESTboundedInterfaceElements~=lowerWESTcrackTipElement)),'lowerWESTboundedInterfaceWithoutTip-Elements');
    writeABQelementset(abqpath,1,upperWESTboundedInterfaceElements(find(upperWESTboundedInterfaceElements~=upperWESTcrackTipElement)),'upperWESTboundedInterfaceWithoutTip-Elements');
end

if interfaceDef==6
    offset = length(lowerHalfElements)+length(upperHalfElements);
    if isSymm
        writeABQelgen(abqpath,offset+1,1,[lowerEASTboundedInterfaceNodes+sum(Nx)+1 lowerEASTboundedInterfaceNodes],'CONN2D2','ConnectorEASTNoTips-Elements');
        writeABQconnectorsection(abqpath,'Connector-Elements','none','none','none',{'JOIN'},'none');
        offset = offset + length(lowerEASTboundedInterfaceNodes);
        writeABQelgen(abqpath,offset+1,1,[lowerEASTcrackTipNode+sum(Nx)+1 lowerEASTcrackTipNode],'CONN2D2','ConnectorEASTCrackTip-Element');
        writeABQconnectorsection(abqpath,'Connector-Elements','none','none','none',{'JOIN'},'none');
        writeABQelementset(abqpath,2,{'ConnectorEASTNoTips-Elements';'ConnectorEASTCrackTip-Element'},'Connector-Elements');
    else
        writeABQelgen(abqpath,offset+1,1,[lowerEASTboundedInterfaceNodes+sum(Nx)+1 lowerEASTboundedInterfaceNodes],'CONN2D2','ConnectorEASTNoTips-Elements');
        writeABQconnectorsection(abqpath,'Connector-Elements','none','none','none',{'JOIN'},'none');
        offset = offset + length(lowerEASTboundedInterfaceNodes);
        writeABQelgen(abqpath,offset+1,1,[lowerEASTcrackTipNode+sum(Nx)+1 lowerEASTcrackTipNode],'CONN2D2','ConnectorEASTCrackTip-Element');
        writeABQconnectorsection(abqpath,'Connector-Elements','none','none','none',{'JOIN'},'none');
        offset = offset + 1;
        writeABQelgen(abqpath,offset+1,1,[lowerWESTboundedInterfaceNodes+sum(Nx)+1 lowerWESTboundedInterfaceNodes],'CONN2D2','ConnectorWESTNoTips-Elements');
        writeABQconnectorsection(abqpath,'Connector-Elements','none','none','none',{'JOIN'},'none');
        offset = offset + length(lowerWESTboundedInterfaceNodes);
        writeABQelgen(abqpath,offset+1,1,[lowerWESTcrackTipNode+sum(Nx)+1 lowerWESTcrackTipNode],'CONN2D2','ConnectorWESTCrackTip-Element');
        writeABQconnectorsection(abqpath,'Connector-Elements','none','none','none',{'JOIN'},'none');
        writeABQelementset(abqpath,2,{'ConnectorEASTNoTips-Elements';'ConnectorEASTCrackTip-Element'},'ConnectorEAST-Elements');
        writeABQelementset(abqpath,2,{'ConnectorWESTNoTips-Elements';'ConnectorWESTCrackTip-Element'},'ConnectorWEST-Elements');
        writeABQelementset(abqpath,2,{'ConnectorEAST-Elements';'ConnectorWEST-Elements'},'Connector-Elements');
    end
end
%% MATERIAL SECTION

%  unitConvFactor(1)  => length
%  unitConvFactor(2)  => mass
%  unitConvFactor(3)  => time
%  unitConvFactor(4)  => electric current
%  unitConvFactor(5)  => thermodynamic temperature
%  unitConvFactor(6)  => amount of substance
%  unitConvFactor(7)  => luminous intensity
%  unitConvFactor(8)  => density
%  unitConvFactor(9)  => pressure/stress
%  unitConvFactor(10) => thermal expansion
%  unitConvFactor(11) => thermal conductivity
%  unitConvFactor(12) => specific heat capacity
%  unitConvFactor(13) => fracture toughness
%  unitConvFactor(14) => interface stiffness
%  unitConvFactor(15) => force

writeABQmatsec(abqpath);

switch lowerMaterial
    case 1
        lowerProps = getValuesFromCSV(matDBfolder,strcat('CF','.csv'),2,0,9);
        lowerUnitConv = getValuesFromCSV(matDBfolder,strcat('CF','.csv'),1,0,9);
    case 2
        lowerProps = getValuesFromCSV(matDBfolder,strcat('GF','.csv'),2,0,9);
        lowerUnitConv = getValuesFromCSV(matDBfolder,strcat('GF','.csv'),1,0,9);
    otherwise
        lowerProps = getValuesFromCSV(matDBfolder,strcat('CF','.csv'),2,0,9);
        lowerUnitConv = getValuesFromCSV(matDBfolder,strcat('CF','.csv'),1,0,9);
end
switch upperMaterial
    case 1
        upperProps = getValuesFromCSV(matDBfolder,strcat('EP','.csv'),2,0,9);
        upperUnitConv = getValuesFromCSV(matDBfolder,strcat('EP','.csv'),1,0,9);
    case 2
        upperProps = getValuesFromCSV(matDBfolder,strcat('HDPE','.csv'),2,0,9);
        upperUnitConv = getValuesFromCSV(matDBfolder,strcat('HDPE','.csv'),1,0,9);
    otherwise
        upperProps = getValuesFromCSV(matDBfolder,strcat('EP','.csv'),2,0,9);
        upperUnitConv = getValuesFromCSV(matDBfolder,strcat('EP','.csv'),1,0,9);
end

rhoLow    = lowerProps(1)*lowerUnitConv(1);
E1Low     = lowerProps(2)*lowerUnitConv(2);
E2Low     = lowerProps(3)*lowerUnitConv(3);
G12Low    = lowerProps(4)*lowerUnitConv(4);
nu12Low   = lowerProps(5)*lowerUnitConv(5);
nu23Low   = lowerProps(6)*lowerUnitConv(6);
alpha1Low = lowerProps(7)*lowerUnitConv(7);
alpha2Low = lowerProps(8)*lowerUnitConv(8);

rhoUp    = upperProps(1)*upperUnitConv(1);
E1Up     = upperProps(2)*upperUnitConv(2);
E2Up     = upperProps(3)*upperUnitConv(3);
G12Up    = upperProps(4)*upperUnitConv(4);
nu12Up   = upperProps(5)*upperUnitConv(5);
nu23Up   = upperProps(6)*upperUnitConv(6);
alpha1Up = upperProps(7)*upperUnitConv(7);
alpha2Up = upperProps(8)*upperUnitConv(8);

% lower

writeABQsolidsection(abqpath,'none','LowerHalf-Elements',lowMat,'none','none','LowerHalf-SectionControls','none','none','none','none',{'1.0'},'none');

writeABQsectioncontrols(abqpath,'LowerHalf-SectionControls','none','none','none','none','none','ENHANCED','none','none','none','none','none','none','none','none',...
                                'none','none',{},'none');

writeABQmaterial(abqpath,lowMat,'none','none','none',{},'none');

writeABQelastic(abqpath,'none','none','none','ISOTROPIC',{strcat(num2str(E1Low*unitConvFactor(9), '%10.5e'),', ',num2str(nu12Low, '%10.5e'))},'E nu');

writeABQdensity(abqpath,'none','none',{num2str(rhoLow*unitConvFactor(8), '%10.5e')},'rho');

writeABQexpansion(abqpath,'none','none','none','ISO','none','none',{strcat(num2str(alpha1Low*unitConvFactor(10), '%10.5e'))},'alpha');

% upper

writeABQsolidsection(abqpath,'none','UpperHalf-Elements',upMat,'none','none','UpperHalf-SectionControls','none','none','none','none',{'1.0'},'none');

writeABQsectioncontrols(abqpath,'UpperHalf-SectionControls','none','none','none','none','none','ENHANCED','none','none','none','none','none','none','none','none',...
                                'none','none',{},'none');

writeABQmaterial(abqpath,upMat,'none','none','none',{},'none');

writeABQelastic(abqpath,'none','none','none','ISOTROPIC',{strcat(num2str(E1Up*unitConvFactor(9), '%10.5e'),', ',num2str(nu12Up, '%10.5e'))},'E nu');

writeABQdensity(abqpath,'none','none',{num2str(rhoUp*unitConvFactor(8), '%10.5e')},'rho');

writeABQexpansion(abqpath,'none','none','none','ISO','none','none',{strcat(num2str(alpha1Up*unitConvFactor(10), '%10.5e'))},'alpha');

if upperMaterial==1 && lowerMaterial==1
    cohesiveDamageProps = getValuesFromCSV(matDBfolder,strcat('EP-CF-interface','.csv'),2,0,9);
    cohesiveDamageUnitConv = getValuesFromCSV(matDBfolder,strcat('EP-CF-interface','.csv'),1,0,9);
elseif upperMaterial==1 && lowerMaterial==2
    cohesiveDamageProps = getValuesFromCSV(matDBfolder,strcat('EP-GF-interface','.csv'),2,0,9);
    cohesiveDamageUnitConv = getValuesFromCSV(matDBfolder,strcat('EP-GF-interface','.csv'),1,0,9);
elseif upperMaterial==2 && lowerMaterial==1
    cohesiveDamageProps = getValuesFromCSV(matDBfolder,strcat('HDPE-CF-interface','.csv'),2,0,9);
    cohesiveDamageUnitConv = getValuesFromCSV(matDBfolder,strcat('HDPE-CF-interface','.csv'),1,0,9);
elseif upperMaterial==2 && lowerMaterial==2
    cohesiveDamageProps = getValuesFromCSV(matDBfolder,strcat('HDPE-GF-interface','.csv'),2,0,9);
    cohesiveDamageUnitConv = getValuesFromCSV(matDBfolder,strcat('HDPE-GF-interface','.csv'),1,0,9);
else
    cohesiveDamageProps = getValuesFromCSV(matDBfolder,strcat('EP-CF-interface','.csv'),2,0,9);
    cohesiveDamageUnitConv = getValuesFromCSV(matDBfolder,strcat('EP-CF-interface','.csv'),1,0,9);
end

% Load Fiber/Matrix Interface Properties

Eint1 = cohesiveDamageProps(1)*cohesiveDamageUnitConv(1);
Eint2 = cohesiveDamageProps(2)*cohesiveDamageUnitConv(2);
Eint3 = cohesiveDamageProps(3)*cohesiveDamageUnitConv(3);
maxT1 = cohesiveDamageProps(4)*cohesiveDamageUnitConv(4);
maxT2 = cohesiveDamageProps(5)*cohesiveDamageUnitConv(5);
maxT3 = cohesiveDamageProps(6)*cohesiveDamageUnitConv(6);
GIc   = cohesiveDamageProps(7)*cohesiveDamageUnitConv(7);
GIIc  = cohesiveDamageProps(8)*cohesiveDamageUnitConv(8);
GIIIc = cohesiveDamageProps(9)*cohesiveDamageUnitConv(9);
eta   = cohesiveDamageProps(10)*cohesiveDamageUnitConv(10);

%% SURFACE AND FRACTURE SECTION

writeABQsurfacesec(abqpath);

switch interfaceDef
    case 1
        % lower surface
        writeABQsurface(abqpath,'Lower-Surface','none','none','none','none','none','none','none','none','ELEMENT','none','none','none','none',...
                        {'lowerInterface-Elements, S3'},'lower surface');
        % upper surface
        writeABQsurface(abqpath,'Upper-Surface','none','none','none','none','none','none','none','none','ELEMENT','none','none','none','none',...
                        {'upperInterface-Elements, S1'},'upper surface');
        % surface interaction
        writeABQcontactpair(abqpath,'LowerUpperFractInterface','none','none','none','none','none','none','none','SMALL SLIDING','none','none','none','none','none','SURFACE TO SURFACE',...
                                 {'Upper-Surface, Lower-Surface'},'slave, master');
        writeABQsurfaceinteraction(abqpath,'LowerUpperFractInterface','none','none','none','none','none','none',{'1.0'},'Out-of-plane thickness of the surface');            
    case 2
        if isSymm
            % lower surfaces
            writeABQsurface(abqpath,'LowerDebond-Surface','none','none','none','none','none','none','none','none','ELEMENT','none','none','none','none',...
                            {'lowerDEBONDInterface-Elements, S3';'lowerEASTcrackTip-Element, S3'},'lower debond surface');
            writeABQsurface(abqpath,'LowerEast-Surface','none','none','none','none','none','none','none','none','ELEMENT','none','none','none','none',...
                            {'lowerEASTboundedInterfaceWithoutTip-Elements, S3'},'lower east surface');
            % upper surfaces
            writeABQsurface(abqpath,'UpperDebond-Surface','none','none','none','none','none','none','none','none','ELEMENT','none','none','none','none',...
                            {'upperDEBONDInterface-Elements, S1';'upperEASTcrackTip-Element, S1'},'lower debond surface');
            writeABQsurface(abqpath,'UpperEast-Surface','none','none','none','none','none','none','none','none','ELEMENT','none','none','none','none',...
                            {'upperEASTboundedInterfaceWithoutTip-Elements, S1'},'upper east surface');
        else
            % lower surfaces
            writeABQsurface(abqpath,'LowerDebond-Surface','none','none','none','none','none','none','none','none','ELEMENT','none','none','none','none',...
                            {'lowerDEBONDInterface-Elements, S3';'lowerEASTcrackTip-Element, S3';'lowerWESTcrackTip-Element, S3'},'lower debond surface');
            writeABQsurface(abqpath,'LowerEast-Surface','none','none','none','none','none','none','none','none','ELEMENT','none','none','none','none',...
                            {'lowerEASTboundedInterfaceWithoutTip-Elements, S3'},'lower east surface');
            writeABQsurface(abqpath,'LowerWest-Surface','none','none','none','none','none','none','none','none','ELEMENT','none','none','none','none',...
                            {'lowerWESTboundedInterfaceWithoutTip-Elements, S3'},'lower west surface');
            % upper surfaces
            writeABQsurface(abqpath,'UpperDebond-Surface','none','none','none','none','none','none','none','none','ELEMENT','none','none','none','none',...
                            {'upperDEBONDInterface-Elements, S1';'upperEASTcrackTip-Element, S1';'upperWESTcrackTip-Element, S1'},'lower debond surface');
            writeABQsurface(abqpath,'UpperEast-Surface','none','none','none','none','none','none','none','none','ELEMENT','none','none','none','none',...
                            {'upperEASTboundedInterfaceWithoutTip-Elements, S1'},'upper east surface');
            writeABQsurface(abqpath,'UpperWest-Surface','none','none','none','none','none','none','none','none','ELEMENT','none','none','none','none',...
                            {'upperWESTboundedInterfaceWithoutTip-Elements, S1'},'upper west surface');
        end
        % surface interaction
        writeABQcontactpair(abqpath,'LowerUpperFractInterface','none','none','none','none','none','none','none','SMALL SLIDING','none','none','none','none','none','SURFACE TO SURFACE',...
                                 {'UpperDebond-Surface, LowerDebond-Surface'},'slave, master');
        writeABQsurfaceinteraction(abqpath,'LowerUpperFractInterface','none','none','none','none','none','none',{'1.0'},'Out-of-plane thickness of the surface');
        % tied surfaces
        writeABQtie(abqpath,'LowerUpperEastTieConstraint','none','none','YES','none','none','none','none','SURFACE TO SURFACE',...
                    {'LowerEast-Surface, UpperEast-Surface'},'tie constraint between slave and master');
        if ~isSymm
            writeABQtie(abqpath,'LowerUpperWestTieConstraint','none','none','YES','none','none','none','none','SURFACE TO SURFACE',...
                    {'LowerWest-Surface, UpperWest-Surface'},'tie constraint between slave and master');
        end
    case 3
        if isSymm
            % lower surfaces
            writeABQsurface(abqpath,'LowerDebond-Surface','none','none','none','none','none','none','none','none','ELEMENT','none','none','none','none',...
                            {'lowerDEBONDInterface-Elements, S3';'lowerEASTcrackTip-Element, S3'},'lower debond surface');
            % upper surfaces
            writeABQsurface(abqpath,'UpperDebond-Surface','none','none','none','none','none','none','none','none','ELEMENT','none','none','none','none',...
                            {'upperDEBONDInterface-Elements, S1';'upperEASTcrackTip-Element, S1'},'lower debond surface');
        else
            % lower surfaces
            writeABQsurface(abqpath,'LowerDebond-Surface','none','none','none','none','none','none','none','none','ELEMENT','none','none','none','none',...
                            {'lowerDEBONDInterface-Elements, S3';'lowerEASTcrackTip-Element, S3';'lowerWESTcrackTip-Element, S3'},'lower debond surface');
            % upper surfaces
            writeABQsurface(abqpath,'UpperDebond-Surface','none','none','none','none','none','none','none','none','ELEMENT','none','none','none','none',...
                            {'upperDEBONDInterface-Elements, S1';'upperEASTcrackTip-Element, S1';'upperWESTcrackTip-Element, S1'},'lower debond surface');
        end
        % surface interaction
        writeABQcontactpair(abqpath,'LowerUpperFractInterface','none','none','none','none','none','none','none','SMALL SLIDING','none','none','none','none','none','SURFACE TO SURFACE',...
                                 {'UpperDebond-Surface, LowerDebond-Surface'},'slave, master');
        writeABQsurfaceinteraction(abqpath,'LowerUpperFractInterface','none','none','none','none','none','none',{'1.0'},'Out-of-plane thickness of the surface');
        % tied nodes
        for i=1:length(lowerEASTboundedInterfaceNodes(1:end-1))
            writeABQmpc(abqpath,'none','none','none',...
                        {strcat('TIE, ', num2str(lowerEASTboundedInterfaceNodes(i)), ', ', num2str(lowerEASTboundedInterfaceNodes(i)+sum(Nx)+1))},...
                        'MPC type, node numbers or node sets');
        end
        if ~isSymm
            for i=1:length(lowerWESTboundedInterfaceNodes(2:end))
                writeABQmpc(abqpath,'none','none','none',...
                            {strcat('TIE, ', num2str(lowerWESTboundedInterfaceNodes(i)), ', ', num2str(lowerWESTboundedInterfaceNodes(i)+sum(Nx)+1))},...
                            'MPC type, node numbers or node sets');
            end
        end
    case 4
        if isSymm
            % lower surfaces
            writeABQsurface(abqpath,'LowerDebond-Surface','none','none','none','none','none','none','none','none','ELEMENT','none','none','none','none',...
                            {'lowerDEBONDInterface-Elements, S3'},'lower debond surface');
            writeABQsurface(abqpath,'LowerEast-Surface','none','none','none','none','none','none','none','none','ELEMENT','none','none','none','none',...
                            {'lowerEASTboundedInterface-Elements, S3'},'lower east surface');
            % upper surfaces
            writeABQsurface(abqpath,'UpperDebond-Surface','none','none','none','none','none','none','none','none','ELEMENT','none','none','none','none',...
                            {'upperDEBONDInterface-Elements, S1'},'upper debond surface');
            writeABQsurface(abqpath,'UpperEast-Surface','none','none','none','none','none','none','none','none','ELEMENT','none','none','none','none',...
                            {'upperEASTboundedInterface-Elements, S1'},'upper east surface');
        else
            % lower surfaces
            writeABQsurface(abqpath,'LowerDebond-Surface','none','none','none','none','none','none','none','none','ELEMENT','none','none','none','none',...
                            {'lowerDEBONDInterface-Elements, S3'},'lower debond surface');
            writeABQsurface(abqpath,'LowerEast-Surface','none','none','none','none','none','none','none','none','ELEMENT','none','none','none','none',...
                            {'lowerEASTboundedInterface-Elements, S3'},'lower east surface');
            writeABQsurface(abqpath,'LowerWest-Surface','none','none','none','none','none','none','none','none','ELEMENT','none','none','none','none',...
                            {'lowerWESTboundedInterface-Elements, S3'},'lower west surface');
            % upper surfaces
            writeABQsurface(abqpath,'UpperDebond-Surface','none','none','none','none','none','none','none','none','ELEMENT','none','none','none','none',...
                            {'upperDEBONDInterface-Elements, S1'},'upper debond surface');
            writeABQsurface(abqpath,'UpperEast-Surface','none','none','none','none','none','none','none','none','ELEMENT','none','none','none','none',...
                            {'upperEASTboundedInterface-Elements, S1'},'upper east surface');
            writeABQsurface(abqpath,'UpperWest-Surface','none','none','none','none','none','none','none','none','ELEMENT','none','none','none','none',...
                            {'upperWESTboundedInterface-Elements, S1'},'upper west surface');
        end
        % surface interaction
        writeABQcontactpair(abqpath,'LowerUpperFractInterface','none','none','none','none','none','none','none','SMALL SLIDING','none','none','none','none','none','SURFACE TO SURFACE',...
                                 {'UpperDebond-Surface, LowerDebond-Surface'},'slave, master');
        writeABQsurfaceinteraction(abqpath,'LowerUpperFractInterface','none','none','none','none','none','none',{'1.0'},'Out-of-plane thickness of the surface');
        % tied surfaces
        writeABQtie(abqpath,'LowerUpperEastTieConstraint','none','none','YES','none','none','none','none','SURFACE TO SURFACE',...
                    {'LowerEast-Surface, UpperEast-Surface'},'tie constraint between slave and master');
        if ~isSymm
            writeABQtie(abqpath,'LowerUpperWestTieConstraint','none','none','YES','none','none','none','none','SURFACE TO SURFACE',...
                    {'LowerWest-Surface, UpperWest-Surface'},'tie constraint between slave and master');
        end
    case 5
        % lower debond
        writeABQsurface(abqpath,'LowerDebond-Surface','none','none','none','none','none','none','none','none','ELEMENT','none','none','none','none',...
                        {'lowerDEBONDInterface-Elements, S3'},'lower debond surface');
        % upper debond
        writeABQsurface(abqpath,'UpperDebond-Surface','none','none','none','none','none','none','none','none','ELEMENT','none','none','none','none',...
                        {'upperDEBONDInterface-Elements, S1'},'upper debond surface');
        % surface interaction
        writeABQcontactpair(abqpath,'LowerUpperFractInterface','none','none','none','none','none','none','none','SMALL SLIDING','none','none','none','none','none','SURFACE TO SURFACE',...
                                 {'UpperDebond-Surface, LowerDebond-Surface'},'slave, master');
        writeABQsurfaceinteraction(abqpath,'LowerUpperFractInterface','none','none','none','none','none','none',{'1.0'},'Out-of-plane thickness of the surface');
        % tied nodes
%         for i=1:length(lowerEASTboundedInterfaceNodes)
%             writeABQmpc(abqpath,'none','none','none',...
%                         {strcat('TIE, ', num2str(lowerEASTboundedInterfaceNodes(i)), ', ', num2str(lowerEASTboundedInterfaceNodes(i)+sum(Nx)+1))},...
%                         'MPC type, node numbers or node sets');
%         end
%         if ~isSymm
%             for i=1:length(lowerWESTboundedInterfaceNodes)
%                 writeABQmpc(abqpath,'none','none','none',...
%                             {strcat('TIE, ', num2str(lowerWESTboundedInterfaceNodes(i)), ', ', num2str(lowerWESTboundedInterfaceNodes(i)+sum(Nx)+1))},...
%                             'MPC type, node numbers or node sets');
%             end
%         end
        writeABQequation(abqpath,'none',{'3';'lowerEASTcrackTip-Node,1,1,upperEASTcrackTip-Node,1,-1,Dummy1-Node,1,-1'},'none');
        writeABQequation(abqpath,'none',{'3';'lowerEASTcrackTip-Node,2,1,upperEASTcrackTip-Node,2,-1,Dummy1-Node,2,-1'},'none');
        for i=1:length(lowerEASTboundedInterfaceNodes)
            if lowerEASTboundedInterfaceNodes(i)~=lowerEASTcrackTipNode
                writeABQequation(abqpath,'none',{'2';strcat(num2str(lowerEASTboundedInterfaceNodes(i)+sum(Nx)+1),',1,1,',num2str(lowerEASTboundedInterfaceNodes(i)),',1,-1')},'none');
                writeABQequation(abqpath,'none',{'2';strcat(num2str(lowerEASTboundedInterfaceNodes(i)+sum(Nx)+1),',2,1,',num2str(lowerEASTboundedInterfaceNodes(i)),',2,-1')},'none');
            end
        end
        if isSymm
            writeABQboundary(abqpath,'none','none','none','none','none','none','none','none','none','none','none','none',...
                         {'Dummy1-Node,ENCASTRE'},'none');
        else
            writeABQequation(abqpath,'none',{'3';'lowerWESTcrackTip-Node,1,1,upperWESTcrackTip-Node,1,-1,Dummy2-Node,1,-1'},'none');
            writeABQequation(abqpath,'none',{'3';'lowerWESTcrackTip-Node,2,1,upperWESTcrackTip-Node,2,-1,Dummy2-Node,2,-1'},'none');
            for i=1:length(lowerWESTboundedInterfaceNodes)
                if lowerWESTboundedInterfaceNodes(i)~=lowerWESTcrackTipNode
                    writeABQequation(abqpath,'none',{'2';strcat(num2str(lowerWESTboundedInterfaceNodes(i)+sum(Nx)+1),',1,1,',num2str(lowerWESTboundedInterfaceNodes(i)),',1,-1')},'none');
                    writeABQequation(abqpath,'none',{'2';strcat(num2str(lowerWESTboundedInterfaceNodes(i)+sum(Nx)+1),',2,1,',num2str(lowerWESTboundedInterfaceNodes(i)),',2,-1')},'none');
                end
            end
            writeABQboundary(abqpath,'none','none','none','none','none','none','none','none','none','none','none','none',...
                         {'Dummy-Nodes,ENCASTRE'},'none');
        end
          
    case 6
        % lower debond
        writeABQsurface(abqpath,'LowerDebond-Surface','none','none','none','none','none','none','none','none','ELEMENT','none','none','none','none',...
                        {'lowerDEBONDInterface-Elements, S3'},'lower debond surface');
        % upper debond
        writeABQsurface(abqpath,'UpperDebond-Surface','none','none','none','none','none','none','none','none','ELEMENT','none','none','none','none',...
                        {'upperDEBONDInterface-Elements, S1'},'upper debond surface');
        % surface interaction
        writeABQcontactpair(abqpath,'LowerUpperFractInterface','none','none','none','none','none','none','none','SMALL SLIDING','none','none','none','none','none','SURFACE TO SURFACE',...
                                 {'UpperDebond-Surface, LowerDebond-Surface'},'slave, master');
        writeABQsurfaceinteraction(abqpath,'LowerUpperFractInterface','none','none','none','none','none','none',{'1.0'},'Out-of-plane thickness of the surface');
end

%% BOUNDARY CONDITIONS SECTION

writeABQbcsec(abqpath);

if isSymm
    writeABQboundary(abqpath,'none','none','none','none','none','none','none','none','none','none','none','none',...
                     {'lowerSW-Node,XSYMM';...
                      'lowerWESTside-Nodes,XSYMM';...
                      'lowerNW-Node,XSYMM';
                      'upperSW-Node,XSYMM';...
                      'upperWESTside-Nodes,XSYMM';...
                      'upperNW-Node,XSYMM'},'none');    
end

%% INITIAL CONDITIONS SECTION

writeABQicsec(abqpath);

switch interfaceDef
    case 1
        if isSymm
            writeABQinitialconditions(abqpath,'CONTACT','none','none','none','none','none','none','none','none','none','none','none','none','none','none','none','none','none','none','none','none',...
                          {'Upper-Surface,Lower-Surface,upperEASTboundedInterface-Nodes'},'none');
        else
            writeABQinitialconditions(abqpath,'CONTACT','none','none','none','none','none','none','none','none','none','none','none','none','none','none','none','none','none','none','none','none',...
                          {'Upper-Surface,Lower-Surface,upperBoundedInterface-Nodes'},'none');
        end
    case 2
        if isSymm
            writeABQinitialconditions(abqpath,'CONTACT','none','none','none','none','none','none','none','none','none','none','none','none','none','none','none','none','none','none','none','none',...
                          {'UpperDebond-Surface,LowerDebond-Surface,upperEASTcrackTip-Node'},'none');
        else
            writeABQinitialconditions(abqpath,'CONTACT','none','none','none','none','none','none','none','none','none','none','none','none','none','none','none','none','none','none','none','none',...
                          {'UpperDebond-Surface,LowerDebond-Surface,upperCrackTips-Nodes'},'none');
        end
    case 3
        if isSymm
            writeABQinitialconditions(abqpath,'CONTACT','none','none','none','none','none','none','none','none','none','none','none','none','none','none','none','none','none','none','none','none',...
                          {'UpperDebond-Surface,LowerDebond-Surface,upperEASTcrackTip-Node'},'none');
        else
            writeABQinitialconditions(abqpath,'CONTACT','none','none','none','none','none','none','none','none','none','none','none','none','none','none','none','none','none','none','none','none',...
                          {'UpperDebond-Surface,LowerDebond-Surface,upperCrackTips-Nodes'},'none');
        end
end

%% LOAD SECTION

writeABQloadsec(abqpath);

writeABQstep(abqpath,'STEP','YES','none','none','10000','LoadStep','YES','none','none','none',{},'none');

writeABQstatic(abqpath,'none','none','none','none','none','none','none','none','none',...
               {'1e-4,1.0,1e-8,1e-2'},...
               'Initial time increment, Time period of the step, Minimum time increment allowed, Maximum time increment allowed');
           
%writeABQdload(abqpath,'none','none','none','none','none','none','none','none','none','none',...
%              {strcat('lowerSOUTHside-Elements,TRVEC1,',num2str(-sigmayy),'0.0,-1.0');strcat('upperNORTHside-Elements,TRVEC3,',num2str(sigmayy),'0.0,1.0')},'none')

boundaryData ={strcat('lowerSOUTHside-Nodes,2,,',num2str(-epsyy*abs(allNodes(lowerSWnode,2))));...
   strcat('upperNORTHside-Nodes,2,,',num2str(epsyy*abs(allNodes(upperNWnode,2))))};

writeABQboundary(abqpath,'none','none','none','none','none','MOD','none','none','DISPLACEMENT','none','none','none',boundaryData,'');

switch interfaceDef
    case 1
        writeABQdebond(abqpath,'Lower-Surface','Upper-Surface','none','none','BOTH','none',{},'');

        writeABQfracturecriterion(abqpath,'none','none','VCCT','none','BK','none','none','none','none','0.5','none',...
                                      {strcat(num2str(GIc*unitConvFactor(13), '%10.5e'),', ',num2str(GIIc*unitConvFactor(13), '%10.5e'),', ',num2str(GIIIc*unitConvFactor(13), '%10.5e'),',',num2str(eta, '%10.5e'))},...
                                      'GIc GIIc GIIIc eta');
    case 2
        writeABQdebond(abqpath,'LowerDebond-Surface','UpperDebond-Surface','none','none','BOTH','none',{},'');

        writeABQfracturecriterion(abqpath,'none','none','VCCT','none','BK','none','none','none','none','0.5','none',...
                                      {strcat(num2str(GIc*unitConvFactor(13), '%10.5e'),', ',num2str(GIIc*unitConvFactor(13), '%10.5e'),', ',num2str(GIIIc*unitConvFactor(13), '%10.5e'),',',num2str(eta, '%10.5e'))},...
                                      'GIc GIIc GIIIc eta');
    case 3
        writeABQdebond(abqpath,'LowerDebond-Surface','UpperDebond-Surface','none','none','BOTH','none',{},'');

        writeABQfracturecriterion(abqpath,'none','none','VCCT','none','BK','none','none','none','none','0.5','none',...
                                      {strcat(num2str(GIc*unitConvFactor(13), '%10.5e'),', ',num2str(GIIc*unitConvFactor(13), '%10.5e'),', ',num2str(GIIIc*unitConvFactor(13), '%10.5e'),',',num2str(eta, '%10.5e'))},...
                                      'GIc GIIc GIIIc eta');
end

%% OUTPUT SECTION

writeABQoutsec(abqpath);

% output to .fil

if requestFIL
    writeABQfileformat(abqpath,'ASCII','none',{},'');
    
    writeABQelfile(abqpath,'YES','All-Elements','none','none','none','none','none',{'COORD,S,SP,SINV,E,EP,NE,NEP';'LE,LEP,EE,EEP,IE,IEP,THE,THEP';'ENER,TEMP'},'none');
    
    writeABQenergyfile(abqpath,'All-Elements','none',{},'none');
    
    writeABQnodefile(abqpath,'none','YES','none','none','All-Nodes',{'COORD,U,RF,CF,TF,VF'},'none');
    
    if interfaceDef==6
        writeABQelfile(abqpath,'YES','Connector-Elements','none','none','none','none','none',{'CRF1'},'none');
        writeABQelfile(abqpath,'YES','Connector-Elements','none','none','none','none','none',{'CRF2'},'none');
        writeABQelfile(abqpath,'YES','Connector-Elements','none','none','none','none','none',{'CRF3'},'none');
    end
    
    if interfaceDef==5
        if isSymm
            writeABQnodefile(abqpath,'none','YES','none','none','Dummy1-Node',{'COORD,U,RF,CF,TF,VF'},'none');
        else
            writeABQnodefile(abqpath,'none','YES','none','none','Dummy-Nodes',{'COORD,U,RF,CF,TF,VF'},'none');
        end
    end
end

% output to .dat

if requestDAT
    writeABQelprint(abqpath,'All-Elements','none','none','none','none','none','none','none',{'COORD'},'none');
    writeABQelprint(abqpath,'All-Elements','none','none','none','none','none','none','none',{'S'},'none');
    writeABQelprint(abqpath,'All-Elements','none','none','none','none','none','none','none',{'SP'},'none');
    writeABQelprint(abqpath,'All-Elements','none','none','none','none','none','none','none',{'SINV'},'none');
    writeABQelprint(abqpath,'All-Elements','none','none','none','none','none','none','none',{'E'},'none');
    writeABQelprint(abqpath,'All-Elements','none','none','none','none','none','none','none',{'EP'},'none');
    writeABQelprint(abqpath,'All-Elements','none','none','none','none','none','none','none',{'NE'},'none');
    writeABQelprint(abqpath,'All-Elements','none','none','none','none','none','none','none',{'NEP'},'none');
    writeABQelprint(abqpath,'All-Elements','none','none','none','none','none','none','none',{'LE'},'none');
    writeABQelprint(abqpath,'All-Elements','none','none','none','none','none','none','none',{'LEP'},'none');
    writeABQelprint(abqpath,'All-Elements','none','none','none','none','none','none','none',{'EE'},'none');
    writeABQelprint(abqpath,'All-Elements','none','none','none','none','none','none','none',{'EEP'},'none');
    writeABQelprint(abqpath,'All-Elements','none','none','none','none','none','none','none',{'IE'},'none');
    writeABQelprint(abqpath,'All-Elements','none','none','none','none','none','none','none',{'IEP'},'none');
    writeABQelprint(abqpath,'All-Elements','none','none','none','none','none','none','none',{'THE'},'none');
    writeABQelprint(abqpath,'All-Elements','none','none','none','none','none','none','none',{'THEP'},'none');
    writeABQelprint(abqpath,'All-Elements','none','none','none','none','none','none','none',{'ENER'},'none');
    writeABQelprint(abqpath,'All-Elements','none','none','none','none','none','none','none',{'TEMP'},'none');

    writeABQenergyprint(abqpath,'All-Elements','none',{},'none');
    
    writeABQnodeprint(abqpath,'none','YES','none','none','All-Nodes','NO','NO',{'COORD'},'none');
    writeABQnodeprint(abqpath,'none','YES','none','none','All-Nodes','NO','NO',{'U,RF'},'none');
    writeABQnodeprint(abqpath,'none','YES','none','none','All-Nodes','NO','NO',{'CF,TF'},'none');
    
    if interfaceDef==6
        writeABQelprint(abqpath,'Connector-Elements','none','none','none','none','none','none','none',{'CRF1'},'none');
        writeABQelprint(abqpath,'Connector-Elements','none','none','none','none','none','none','none',{'CRF2'},'none');
        writeABQelprint(abqpath,'Connector-Elements','none','none','none','none','none','none','none',{'CRF3'},'none');
    end
    
    if interfaceDef==5
        if isSymm
            writeABQnodeprint(abqpath,'none','YES','none','none','Dummy1-Node','NO','NO',{'COORD'},'none');
            writeABQnodeprint(abqpath,'none','YES','none','none','Dummy1-Node','NO','NO',{'U,RF'},'none');
        else
            writeABQnodeprint(abqpath,'none','YES','none','none','Dummy-Nodes','NO','NO',{'COORD'},'none');
            writeABQnodeprint(abqpath,'none','YES','none','none','Dummy-Nodes','NO','NO',{'U,RF'},'none');
        end
    end
end

% output to .odb

if requestODB
    writeABQoutput(abqpath,'YES','none','none','none','none','none','none','none','none','none','none','none','none',{},'none');

    writeABQoutput(abqpath,'none','FIELD','none','none','none','FieldData','10','none','none','none','none','ALL','none',{},'none');

    writeABQoutput(abqpath,'none','none','HISTORY','none','none','HistoryData','none','none','none','none','none','none','none',{},'none');
    
    writeABQnodeoutput(abqpath,'upperNORTHside-Nodes','none','none','none','none',{'U'},'none');
    writeABQnodeoutput(abqpath,'lowerSOUTHside-Nodes','none','none','none','none',{'U'},'none');
    %writeABQnodeoutput(abqpath,'All-Nodes','none','none','none','none',{'RF'},'none');
    %writeABQnodeoutput(abqpath,'All-Nodes','none','none','none','none',{'TF'},'none');
    
    switch interfaceDef
        case 1
            writeABQcontactoutput(abqpath,'none','none','none','none','none','ALL','Lower-Surface','Upper-Surface',{},'none');
            writeABQcontactoutput(abqpath,'none','none','none','none','none','none','Lower-Surface','Upper-Surface',{'DBT,DBS,DBSF,BDSTAT,CSDMG,OPENBC,CRSTS,ENRRT,EFENRRTR'},'none');
        case 2
            writeABQcontactoutput(abqpath,'none','none','none','none','none','ALL','LowerDebond-Surface','UpperDebond-Surface',{},'none');
            writeABQcontactoutput(abqpath,'none','none','none','none','none','none','LowerDebond-Surface','UpperDebond-Surface',{'DBT,DBS,DBSF,BDSTAT,CSDMG,OPENBC,CRSTS,ENRRT,EFENRRTR'},'none');
            writeABQcontactoutput(abqpath,'none','none','none','none','none','ALL','LowerEast-Surface','UpperEast-Surface',{},'none');
            if ~isSymm
                writeABQcontactoutput(abqpath,'none','none','none','none','none','ALL','LowerWest-Surface','UpperWest-Surface',{},'none');
            end
        case 3
            writeABQcontactoutput(abqpath,'none','none','none','none','none','ALL','LowerDebond-Surface','UpperDebond-Surface',{},'none');
            writeABQcontactoutput(abqpath,'none','none','none','none','none','none','LowerDebond-Surface','UpperDebond-Surface',{'DBT,DBS,DBSF,BDSTAT,CSDMG,OPENBC,CRSTS,ENRRT,EFENRRTR'},'none');
        case 4
            writeABQcontactoutput(abqpath,'none','none','none','none','none','ALL','LowerDebond-Surface','UpperDebond-Surface',{},'none');
            writeABQcontactoutput(abqpath,'none','none','none','none','none','ALL','LowerEast-Surface','UpperEast-Surface',{},'none');
            if ~isSymm
                writeABQcontactoutput(abqpath,'none','none','none','none','none','ALL','LowerWest-Surface','UpperWest-Surface',{},'none');
            end
        case 5
            writeABQcontactoutput(abqpath,'none','none','none','none','none','ALL','LowerDebond-Surface','UpperDebond-Surface',{},'none');
    end
    
    if interfaceDef==6
        writeABQelementoutput(abqpath,'Connector-Elements','none','YES','none','none','none','none',{'CRF1'},'none');
        writeABQelementoutput(abqpath,'Connector-Elements','none','YES','none','none','none','none',{'CRF2'},'none');
        writeABQelementoutput(abqpath,'Connector-Elements','none','YES','none','none','none','none',{'CRF3'},'none');
    end
    
    if interfaceDef==5
        if isSymm
            writeABQnodeoutput(abqpath,'Dummy1-Node','none','none','none','none',{'COORD'},'none');
            writeABQnodeoutput(abqpath,'Dummy1-Node','none','none','none','none',{'U,RF'},'none');
        else
            writeABQnodeoutput(abqpath,'Dummy-Nodes','none','none','none','none',{'COORD'},'none');
            writeABQnodeoutput(abqpath,'Dummy-Nodes','none','none','none','none',{'U,RF'},'none');
        end
    end
    
end

writeABQendstep(abqpath);

return