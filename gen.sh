#!/bin/bash
SN="`echo \"$1\" | cut -d'/' -f2`"
IP="`echo \"$1\" | cut -d'/' -f1`"
A="`echo \"$IP\" | cut -d'.' -f1`"
B="`echo \"$IP\" | cut -d'.' -f2`"
C="`echo \"$IP\" | cut -d'.' -f3`"
D="`echo \"$IP\" | cut -d'.' -f4`"
A="`echo \"ibase=10; obase=16; $A\" | bc`"
B="`echo \"ibase=10; obase=16; $B\" | bc`"
C="`echo \"ibase=10; obase=16; $C\" | bc`"
D="`echo \"ibase=10; obase=16; $D\" | bc`"
if [ "`echo \"$A\" | tr -d '\n' | wc -c`" -eq "1" ]
then
        A="0$A"
fi
if [ "`echo \"$B\" | tr -d '\n' | wc -c`" -eq "1" ]
then
        B="0$B"
fi
if [ "`echo \"$C\" | tr -d '\n' | wc -c`" -eq "1" ]
then
        C="0$C"
fi
if [ "`echo \"$D\" | tr -d '\n' | wc -c`" -eq "1" ]
then
        D="0$D"
fi
N="`echo \"ibase=16; obase=2; $A$B$C$D\" | bc`"
NL="`echo \"$N\" | tr -d '\n' | wc -c`"
NL="`echo \"32 - $NL\" | bc`"
N="`echo \"00000000000000000000000000000000\" | cut -c1-$NL`$N"
N="`echo \"$N\" | cut -c1-$SN`"
HB="`echo \"32 - $SN\" | bc`"
UP="`echo \"2^$HB - 1\" | bc`"
for i in `seq 0 $UP`
do
        H="`echo \"ibase=10; obase=2; $i\" | bc`"
        C="`echo \"$H\" | tr -d '\n' | wc -c`"
        Z="`echo \"$HB-$C\" | bc`"
        if [ "$Z" -gt "0" ]
        then
                Z="`echo "00000000000000000000000000000000" | cut -c1-$Z`"
        else
                Z=""
        fi
        H="$N$Z$H"
        H="`echo \"ibase=2; obase=10000; $H\" | bc`"

        HL="`echo \"$H\" | tr -d '\n' | wc -c`"

        if [ "$HL" -lt "8" ]
        then
                HL="`echo \"8 - $HL\" | bc`"
                H="`echo \"00000000\" | cut -c1-$HL`$H"
        fi
        H="`echo \"$H\" | sed -E 's/../\0\./g'`"
        A="`echo \"$H\" | cut -d'.' -f1`"
        B="`echo \"$H\" | cut -d'.' -f2`"
        C="`echo \"$H\" | cut -d'.' -f3`"
        D="`echo \"$H\" | cut -d'.' -f4`"
        A="`echo \"ibase=16; obase=A; $A\" | bc`"
        B="`echo \"ibase=16; obase=A; $B\" | bc`"
        C="`echo \"ibase=16; obase=A; $C\" | bc`"
        D="`echo \"ibase=16; obase=A; $D\" | bc`"
        if [ "$A" -eq "255" ]; then continue; fi
        if [ "$B" -eq "255" ]; then continue; fi
        if [ "$C" -eq "255" ]; then continue; fi
        if [ "$D" -eq "255" ]; then continue; fi

        echo "pdnsutil add-record vp.com.se $A-$B-$C-$D A $A.$B.$C.$D"
        pdnsutil add-record vp.com.se $A-$B-$C-$D A $A.$B.$C.$D
done
