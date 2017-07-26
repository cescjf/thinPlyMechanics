#!/bin/bash

clear

WD="/home/luca/WD/thinPlyMechanics/tex/Slides_11_Update-2017-07-17"
BASE="2017-07-25_AbqRunSummary_SmallStrain_D"
F1="_F-SoF-VCCT_"
F2="_F-SoM-VCCT_"
V1="Summary"
V2="GI"
V3="GII"
V4="GTOT"
EXT=".tex"

GLOBALTEX="$WD"
GLOBALTEX+="/Update-2017-07-17"
GLOBALTEX+=".tex"

NEWGLOBALTEX="$WD"
NEWGLOBALTEX+="/Update-2017-07-27"
NEWGLOBALTEX+=".tex"

for j in `seq 1 2`;

do
    for i in `seq 3 10`;

    do
        F=$BASE
        FOLDER=$WD
        FOLDER+="/2017-07-25_AbqRunSummary_SmallStrain_D"
        SUBFOLDER="2017-07-25_AbqRunSummary_SmallStrain_D"
        if [ "$i" -lt 10 ]; then
            FOLDER+="0"
            SUBFOLDER+="0"
            F+="0"
        fi
        FOLDER+="$i"
        SUBFOLDER+="$i"
        F+="$i"
        if [ "$j" -lt 2 ]; then
            F+="$F1"
        else
            F+="$F2"
        fi
        BEAMERINPUTFILE=$FOLDER
        BEAMERINPUTFILE+="_VCCI.tex"
        TARGETFOLDER=$FOLDER
        FOLDER+="/tex"
        TARGETFOLDER+="/pdf"
        SUMMARY=$F
        GI=$F
        GII=$F
        GTOT=$F
        SUMMARY+="$V1"
        GI+="$V2"
        GII+="$V3"
        GTOT+="$V4"
        PDFSUMMARY="$SUMMARY"
        PDFGI="$GI"
        PDFGII="$GII"
        PDFGTOT="$GTOT"
        PDFSUMMARY+=".pdf"
        PDFGI+=".pdf"
        PDFGII+=".pdf"
        PDFGTOT+=".pdf"
        JOB1="$GI"
        JOB2="$GII"
        JOB3="$GTOT"
        SUMMARY+="$EXT"
        GI+="$EXT"
        GII+="$EXT"
        GTOT+="$EXT"
        SOURCE=$FOLDER
        DEST=$FOLDER
        SOURCE+="/"
        DEST+="/"
        SOURCE+=$SUMMARY
        DEST1=$DEST
        DEST1+=$GI
        DEST2=$DEST
        DEST2+=$GII
        DEST3=$DEST
        DEST3+=$GTOT
        echo "Copying file"
        echo $SUMMARY
        echo "from folder"
        echo $FOLDER
        echo "to files"
        echo $GI 
        echo $GII
        echo $GTOT
        FIRSTLINE="%"
        FIRSTLINE+=$(date +%c)
        echo $FIRSTLINE > $DEST1 
        echo $FIRSTLINE > $DEST2
        echo $FIRSTLINE > $DEST3
        ADDALL=true
        ADD1=false
        ADD2=false
        ADD3=false
        while IFS= read -r line; do
            if [[ $line == *"addplot"* ]] ; then
               ADDALL=false
               if [[ $line == *"mark=square"* ]] ; then
                   ADD1=true
                   echo $line >> $DEST1
               elif [[ $line == *"mark=triangle"* ]] ; then
                   ADD2=true
                   echo $line >> $DEST2
               else
                   ADD3=true
                   echo $line >> $DEST3
               fi
            elif [[ "$ADDALL" = false && $line == *"};"* ]] ; then
               if [ "$ADD1" = true  ] ; then
                   echo $line >> $DEST1
               elif [ "$ADD2" = true ] ; then
                   echo $line >> $DEST2
               elif [ "$ADD3" = true ] ; then
                   echo $line >> $DEST3
               fi
               ADDALL=true
               ADD1=false
               ADD2=false
               ADD3=false
            else
                if [ "$ADDALL" = true ] ; then
                    echo $line >> $DEST1
                    echo $line >> $DEST2
                    echo $line >> $DEST3
                else
                    if [ "$ADD1" = true  ] ; then
                        echo $line >> $DEST1
                    elif [ "$ADD2" = true ] ; then
                        echo $line >> $DEST2
                    elif [ "$ADD3" = true ] ; then
                        echo $line >> $DEST3
                    fi
                fi
            fi
        done < $SOURCE
        cd $TARGETFOLDER
        sudo pdflatex $DEST1 -jobname=$JOB1
        sudo pdflatex $DEST2 -jobname=$JOB2
        sudo pdflatex $DEST3 -jobname=$JOB3
        cd $WD
        LINE="\\frametitle{\\small \$G_{I}\$ from VCCI, stresses extracted on "
        if [ "$j" -lt 2 ]; then
            echo "\\begin{frame}" > $BEAMERINPUTFILE
            LINE+="fiber surface, \$\\delta="
        else
            echo "\\begin{frame}" >> $BEAMERINPUTFILE
            LINE+="matrix surface, \$\\delta="
        fi
        
        if [ "$i" -lt 10 ]; then
            LINE+="$i"
            LINE+=".0^{\\circ}\$}"
        else
            LINE+="1.0^{\\circ}\$}"
        fi
        echo "$LINE" >> $BEAMERINPUTFILE
        echo "\\vspace{-0.5cm}" >> $BEAMERINPUTFILE
        echo "\\centering" >> $BEAMERINPUTFILE
        echo "\\captionsetup[figure]{font=scriptsize,labelfont=scriptsize}" >> $BEAMERINPUTFILE
        echo "\\begin{figure}[!h]" >> $BEAMERINPUTFILE
        echo "\\centering" >> $BEAMERINPUTFILE
        LINE="\\includegraphics[height=0.7\\textheight]{"
        LINE+="$SUBFOLDER"
        LINE+="/pdf/"
        LINE+="$PDFGI"
        LINE+="}"
        echo "$LINE" >> $BEAMERINPUTFILE
        echo "  \\caption{\\scriptsize Fading from blue to red for increasing number of integration elements, Virtual Crack Closure Integral (VCCI) from FEM results; in green VCCT from FEM results; in black BEM results.}" >> $BEAMERINPUTFILE
        echo "  \\label{fig:res1}" >> $BEAMERINPUTFILE
        echo "\\end{figure}" >> $BEAMERINPUTFILE
        echo "\\end{frame}" >> $BEAMERINPUTFILE
        echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%" >> $BEAMERINPUTFILE
        echo "\\begin{frame}" >> $BEAMERINPUTFILE
        LINE="\\frametitle{\\small \$G_{II}\$ from VCCI, stresses extracted on "
        if [ "$j" -lt 2 ]; then
            LINE+="fiber surface, \$\\delta="
        else
            LINE+="matrix surface, \$\\delta="
        fi
        
        if [ "$i" -lt 10 ]; then
            LINE+="$i"
            LINE+=".0^{\\circ}\$}"
        else
            LINE+="1.0^{\\circ}\$}"
        fi
        echo "$LINE" >> $BEAMERINPUTFILE
        echo "\\vspace{-0.5cm}" >> $BEAMERINPUTFILE
        echo "\\centering" >> $BEAMERINPUTFILE
        echo "\\captionsetup[figure]{font=scriptsize,labelfont=scriptsize}" >> $BEAMERINPUTFILE
        echo "\\begin{figure}[!h]" >> $BEAMERINPUTFILE
        echo "\\centering" >> $BEAMERINPUTFILE
        LINE="\\includegraphics[height=0.7\\textheight]{"
        LINE+="$SUBFOLDER"
        LINE+="/pdf/"
        LINE+="$PDFGII"
        LINE+="}"
        echo "$LINE" >> $BEAMERINPUTFILE
        echo "  \\caption{\\scriptsize Fading from blue to red for increasing number of integration elements, Virtual Crack Closure Integral (VCCI) from FEM results; in green VCCT from FEM results; in black BEM results.}" >> $BEAMERINPUTFILE
        echo "  \\label{fig:res1}" >> $BEAMERINPUTFILE
        echo "\\end{figure}" >> $BEAMERINPUTFILE
        echo "\\end{frame}" >> $BEAMERINPUTFILE
        echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%" >> $BEAMERINPUTFILE
        echo "\\begin{frame}" >> $BEAMERINPUTFILE
        LINE="\\frametitle{\\small \$G_{TOT}\$ from VCCI, stresses extracted on "
        if [ "$j" -lt 2 ]; then
            LINE+="fiber surface, \$\\delta="
        else
            LINE+="matrix surface, \$\\delta="
        fi
        
        if [ "$i" -lt 10 ]; then
            LINE+="$i"
            LINE+=".0^{\\circ}\$}"
        else
            LINE+="1.0^{\\circ}\$}"
        fi
        echo "$LINE" >> $BEAMERINPUTFILE
        echo "\\vspace{-0.5cm}" >> $BEAMERINPUTFILE
        echo "\\centering" >> $BEAMERINPUTFILE
        echo "\\captionsetup[figure]{font=scriptsize,labelfont=scriptsize}" >> $BEAMERINPUTFILE
        echo "\\begin{figure}[!h]" >> $BEAMERINPUTFILE
        echo "\\centering" >> $BEAMERINPUTFILE
        LINE="\\includegraphics[height=0.7\\textheight]{"
        LINE+="$SUBFOLDER"
        LINE+="/pdf/"
        LINE+="$PDFGTOT"
        LINE+="}"
        echo "$LINE" >> $BEAMERINPUTFILE
        echo "  \\caption{\\scriptsize Fading from blue to red for increasing number of integration elements, Virtual Crack Closure Integral (VCCI) from FEM results; in green VCCT from FEM results; in black BEM results.}" >> $BEAMERINPUTFILE
        echo "  \\label{fig:res1}" >> $BEAMERINPUTFILE
        echo "\\end{figure}" >> $BEAMERINPUTFILE
        echo "\\end{frame}" >> $BEAMERINPUTFILE
        echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%" >> $BEAMERINPUTFILE
        echo "\\begin{frame}" >> $BEAMERINPUTFILE
        LINE="\\frametitle{\\small Summary of \$G_{\\left(\\cdot\\cdot\\right)}\$ from VCCI, stresses extracted on "
        if [ "$j" -lt 2 ]; then
            LINE+="fiber surface, \$\\delta="
        else
            LINE+="matrix surface, \$\\delta="
        fi
        
        if [ "$i" -lt 10 ]; then
            LINE+="$i"
            LINE+=".0^{\\circ}\$}"
        else
            LINE+="1.0^{\\circ}\$}"
        fi
        echo "$LINE" >> $BEAMERINPUTFILE
        echo "\\vspace{-0.5cm}" >> $BEAMERINPUTFILE
        echo "\\centering" >> $BEAMERINPUTFILE
        echo "\\captionsetup[figure]{font=scriptsize,labelfont=scriptsize}" >> $BEAMERINPUTFILE
        echo "\\begin{figure}[!h]" >> $BEAMERINPUTFILE
        echo "\\centering" >> $BEAMERINPUTFILE
        LINE="\\includegraphics[height=0.7\\textheight]{"
        LINE+="$SUBFOLDER"
        LINE+="/pdf/"
        LINE+="$PDFSUMMARY"
        LINE+="}"
        echo "$LINE" >> $BEAMERINPUTFILE
        echo "  \\caption{\\scriptsize Fading from blue to red for increasing number of integration elements, Virtual Crack Closure Integral (VCCI) from FEM results; in green VCCT from FEM results; in black BEM results.}" >> $BEAMERINPUTFILE
        echo "  \\label{fig:res1}" >> $BEAMERINPUTFILE
        echo "\\end{figure}" >> $BEAMERINPUTFILE
        echo "\\end{frame}" >> $BEAMERINPUTFILE
        echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%" >> $BEAMERINPUTFILE
    done
done
FIRSTLINE="% Created on "
FIRSTLINE+=$(date +%c)
echo $FIRSTLINE > $NEWGLOBALTEX
for i in `seq 3 10`;
       
do
    BEAMERINPUTFILE="2017-07-25_AbqRunSummary_SmallStrain_D"
    if [ "$i" -lt 10 ]; then
        BEAMERINPUTFILE+="0"
    fi
    BEAMERINPUTFILE+="$i"
    BEAMERINPUTFILE+="_VCCI.tex"
    STRING="% ====== > 0."
    STRING+=$(($i-1))
    while IFS= read -r line; do
        if [[ $line == *"$STRING"* ]] ; then
            LINE="\\input{"
            LINE+="$BEAMERINPUTFILE"
            LINE+="}"
            echo "$LINE" >> $NEWGLOBALTEX
            echo "%%%" >> $NEWGLOBALTEX
            echo "$line" >> $NEWGLOBALTEX
        else
            echo "$line" >> $NEWGLOBALTEX
        fi
    done < $GLOBALTEX
done

sudo pdflatex $NEWGLOBALTEX