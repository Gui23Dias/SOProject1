#!/bin/bash
sorting="";

getRules(){

	echo " Invalid Option
	-c	  : regex                     
	-b    : visualize in bytes        
	-k    : visualize in kylobytes    
	-m    : visualize in megabytes    
	-p    : number of interfaces      
	-t    : sort on TX                
	-r	  : sort on RX                
	-T	  : sort on TRATE             
	-R	  : sort on RRATE             
	-v	  : reverse order             
	-l	  : work in loop              
		"	
}

kb=1000 #binary
mb=1000000
um=1
zero=0
cntrl=0
cntrlC=0
numRegex=0
NRRX=2
NRTX=3
jump=9
p="-p"

re='^[0-9]+$';
declare -a arrayTXTOT=( $(for i in {1..100}; do echo 0; done) )
declare -a arrayRXTOT=( $(for i in {1..100}; do echo 0; done) )
declare -a arrayTX
declare -a arrayRX
declare -a arrayTRATE
declare -a arrayRRATE

declare -a arrayTXKB
declare -a arrayRXKB
declare -a arrayTRATEKB
declare -a arrayRRATEKB

declare -a arrayTXMB
declare -a arrayRXMB
declare -a arrayTRATEMB
declare -a arrayRRATEMB

if ! [[ ${@: -1} =~ $re ]] ; then
    echo "error: No time input" >&2; exit 1
elif  [[ ${@: -1} =~ $re ]] && [[ ${@: -2} =~ $p ]] ; then
   echo "error: No time input" >&2; exit 1

else
	time=(${@: -1});
    # echo "time: $time";  print do time
fi




NINTERFACES=$(netstat -i | awk '{print $NF}' | wc -w)-1
NINTERFACES=$(($NINTERFACES - 1)) # numero de interfaces no pc retornadas pelo comando netstat

cntrlArray1=0
while [ $cntrlArray1 -lt $NINTERFACES ]; do
	arrayName=($(netstat -i | awk '{if(NR<='$NINTERFACES+2' && NR>=3) print $1}')) 

	arrayTXB1+=($(netstat -ie | sed '/inet/d' | sed '/ether/d' | sed '/RX error/d' | sed '/TX errors/d' | sed '/device/d' | sed '/loop/d' | sed '1d' | cut -f1 -d":" | sed 's/^ *//g' | awk '{if( NR=='$NRTX' ) print $5}'))
 
	arrayRXB1+=($(netstat -ie | sed '/inet/d' | sed '/ether/d' | sed '/RX error/d' | sed '/TX errors/d' | sed '/device/d' | sed '/loop/d' | sed '1d' | cut -f1 -d":" | sed 's/^ *//g' | awk '{if( NR=='$NRRX' ) print $5}'))  
	
	cntrlArray1=$[$cntrlArray1+1]
	NRRX=$[$NRRX+4]
	NRTX=$[$NRTX+4]
	
done
sleep $time
NRRX=2
NRTX=3
cntrlArray2=0
while [ $cntrlArray2 -lt $NINTERFACES ]; do
	arrayName=($(netstat -i | awk '{if(NR<='$NINTERFACES+2' && NR>=3) print $1}')) 

	arrayTXB2+=($(netstat -ie | sed '/inet/d' | sed '/ether/d' | sed '/RX error/d' | sed '/TX errors/d' | sed '/device/d' | sed '/loop/d' | sed '1d' | cut -f1 -d":" | sed 's/^ *//g' | awk '{if( NR=='$NRTX' ) print $5}'))
 
	arrayRXB2+=($(netstat -ie | sed '/inet/d' | sed '/ether/d' | sed '/RX error/d' | sed '/TX errors/d' | sed '/device/d' | sed '/loop/d' | sed '1d' | cut -f1 -d":" | sed 's/^ *//g' | awk '{if( NR=='$NRRX' ) print $5}'))  
	
	cntrlArray2=$[$cntrlArray2+1]
	NRRX=$[$NRRX+4]
	NRTX=$[$NRTX+4]
	
done


cntrlArrayRate=0
while [ $cntrlArrayRate -lt $NINTERFACES ]; do
    tf=${arrayTXB2[$cntrlArrayRate]}
    rf=${arrayRXB2[$cntrlArrayRate]}

    ti=${arrayTXB1[$cntrlArrayRate]}
    ri=${arrayRXB1[$cntrlArrayRate]}

    var1=`expr $tf - $ti`
    var2=`expr $rf - $ri`
    var11=$(($var1/$time))
    var22=$(($var2/$time))
    arrayTXFB+=($var1)
	arrayRXFB+=($var2)
	arrayTRATEB+=($var11)
    arrayRRATEB+=($var22)

	cntrlArrayRate=$[$cntrlArrayRate+1]
done


if [[ $# -eq 1 ]]; then
	fmt="%-12s%-12s%-12s%-12s%-12s\n"
	printf "$fmt" NETIF TX RX TRATE RRATE
	while [ $cntrl -lt $NINTERFACES ]; do
		printf "$fmt" "${arrayName[$cntrl]}" "${arrayTXFB[$cntrl]}" "${arrayRXFB[$cntrl]}" "${arrayTRATEB[$cntrl]}" "${arrayRRATEB[$cntrl]}"
		cntrl=$[$cntrl+1]
	done
fi 

while getopts ":c:b:k:m:p:t:r:T:R:v:l:" o; do
    case "${o}" in
        c)	
            c=${OPTARG}
			fmt="%-12s%-12s%-12s%-12s%-12s\n"
			printf "$fmt" NETIF TX RX TRATE RRATE
			while [ $cntrlC -lt $NINTERFACES ]; do
				if  [[ ${arrayName[$cntrlC]} =~ $c ]]; then
					printf "$fmt" "${arrayName[$cntrlC]}" "${arrayTXFB[$cntrlC]}" "${arrayRXFB[$cntrlC]}" "${arrayTRATEB[$cntrlC]}" "${arrayRRATEB[$cntrlC]}"
					numRegex=$[$numRegex+1]
				fi
				cntrlC=$[$cntrlC+1]
			done
			if [[ $numRegex == 0 ]]; then
				echo "error: No interface corresponding to that regex pattern" >&2; exit 1
			fi
			
            ;;
        b)
            b=${OPTARG}
			cntrlB=0
            fmt="%-12s%-12s%-12s%-12s%-12s\n"
			printf "$fmt" NETIF TX RX TRATE RRATE
			while [ $cntrlB -lt $NINTERFACES ]; do
				printf "$fmt" "${arrayName[$cntrlB]}" "${arrayTXFB[$cntrlB]}" "${arrayRXFB[$cntrlB]}" "${arrayTRATEB[$cntrlB]}" "${arrayRRATEB[$cntrlB]}"
				cntrlB=$[$cntrlB+1]
			done
			;;
		k)
			cntrlArray1=0
			cntrlK=0
			NRRX=2
			NRTX=3
			while [ $cntrlArray1 -lt $NINTERFACES ]; do
				arrayName=($(netstat -i | awk '{if(NR<='$NINTERFACES+2' && NR>=3) print $1}')) 

				arrayTXKB1+=($(netstat -ie | sed '/inet/d' | sed '/ether/d' | sed '/RX error/d' | sed '/TX errors/d' | sed '/device/d' | sed '/loop/d' | sed '1d' | cut -f1 -d":" | sed 's/^ *//g' | awk '{if( NR=='$NRTX' ) print $5}'))

				arrayRXKB1+=($(netstat -ie | sed '/inet/d' | sed '/ether/d' | sed '/RX error/d' | sed '/TX errors/d' | sed '/device/d' | sed '/loop/d' | sed '1d' | cut -f1 -d":" | sed 's/^ *//g' | awk '{if( NR=='$NRRX' ) print $5}'))  

				cntrlArray1=$[$cntrlArray1+1]
				NRRX=$[$NRRX+4]
				NRTX=$[$NRTX+4]

			done
			sleep $time
			NRRX=2
			NRTX=3
			cntrlArray2=0
			while [ $cntrlArray2 -lt $NINTERFACES ]; do
				arrayName=($(netstat -i | awk '{if(NR<='$NINTERFACES+2' && NR>=3) print $1}')) 

				arrayTXKB2+=($(netstat -ie | sed '/inet/d' | sed '/ether/d' | sed '/RX error/d' | sed '/TX errors/d' | sed '/device/d' | sed '/loop/d' | sed '1d' | cut -f1 -d":" | sed 's/^ *//g' | awk '{if( NR=='$NRTX' ) print $5}'))

				arrayRXKB2+=($(netstat -ie | sed '/inet/d' | sed '/ether/d' | sed '/RX error/d' | sed '/TX errors/d' | sed '/device/d' | sed '/loop/d' | sed '1d' | cut -f1 -d":" | sed 's/^ *//g' | awk '{if( NR=='$NRRX' ) print $5}'))  

				cntrlArray2=$[$cntrlArray2+1]
				NRRX=$[$NRRX+4]
				NRTX=$[$NRTX+4]

			done


			cntrlArrayRate=0
			while [ $cntrlArrayRate -lt $NINTERFACES ]; do
			    tf=${arrayTXKB2[$cntrlArrayRate]}
			    rf=${arrayRXKB2[$cntrlArrayRate]}

			    ti=${arrayTXKB1[$cntrlArrayRate]}
			    ri=${arrayRXKB1[$cntrlArrayRate]}

			    var1=`expr $tf - $ti` #T em bytes
			    var2=`expr $rf - $ri` #R em bytes
				var1f=$(($var1/$kb))  #T em kb
				var2f=$(($var2/$kb))  #R em kb


			    var11f=$(($var1f/$time)) #Trate kb
			    var22f=$(($var2f/$time)) #Rrate kb


			    arrayTXFKB+=($var1f)
				arrayRXFKB+=($var2f)
				arrayTRATEKB+=($var11f)
			    arrayRRATEKB+=($var22f)

				cntrlArrayRate=$[$cntrlArrayRate+1]
			done


			fmt="%-12s%-12s%-12s%-12s%-12s\n"
			printf "$fmt" NETIF TX RX TRATE RRATE

			while [ $cntrlK -lt $NINTERFACES ]; do
				printf "$fmt" "${arrayName[$cntrlK]}" "${arrayTXFKB[$cntrlK]}" "${arrayRXFKB[$cntrlK]}" "${arrayTRATEKB[$cntrlK]}" "${arrayRRATEKB[$cntrlK]}"
				cntrlK=$[$cntrlK+1]
			done
			;;
			
		m)	
			cntrlArray1=0
			cntrlMB=0
			NRRX=2
			NRTX=3
			while [ $cntrlArray1 -lt $NINTERFACES ]; do
				arrayName=($(netstat -i | awk '{if(NR<='$NINTERFACES+2' && NR>=3) print $1}')) 

				arrayTXMB1+=($(netstat -ie | sed '/inet/d' | sed '/ether/d' | sed '/RX error/d' | sed '/TX errors/d' | sed '/device/d' | sed '/loop/d' | sed '1d' | cut -f1 -d":" | sed 's/^ *//g' | awk '{if( NR=='$NRTX' ) print $5}'))

				arrayRXMB1+=($(netstat -ie | sed '/inet/d' | sed '/ether/d' | sed '/RX error/d' | sed '/TX errors/d' | sed '/device/d' | sed '/loop/d' | sed '1d' | cut -f1 -d":" | sed 's/^ *//g' | awk '{if( NR=='$NRRX' ) print $5}'))  

				cntrlArray1=$[$cntrlArray1+1]
				NRRX=$[$NRRX+4]
				NRTX=$[$NRTX+4]

			done
			sleep $time
			NRRX=2
			NRTX=3
			cntrlArray2=0
			while [ $cntrlArray2 -lt $NINTERFACES ]; do
				arrayName=($(netstat -i | awk '{if(NR<='$NINTERFACES+2' && NR>=3) print $1}')) 

				arrayTXMB2+=($(netstat -ie | sed '/inet/d' | sed '/ether/d' | sed '/RX error/d' | sed '/TX errors/d' | sed '/device/d' | sed '/loop/d' | sed '1d' | cut -f1 -d":" | sed 's/^ *//g' | awk '{if( NR=='$NRTX' ) print $5}'))

				arrayRXMB2+=($(netstat -ie | sed '/inet/d' | sed '/ether/d' | sed '/RX error/d' | sed '/TX errors/d' | sed '/device/d' | sed '/loop/d' | sed '1d' | cut -f1 -d":" | sed 's/^ *//g' | awk '{if( NR=='$NRRX' ) print $5}'))  

				cntrlArray2=$[$cntrlArray2+1]
				NRRX=$[$NRRX+4]
				NRTX=$[$NRTX+4]

			done


			cntrlArrayRate=0
			while [ $cntrlArrayRate -lt $NINTERFACES ]; do
			    tf=${arrayTXMB2[$cntrlArrayRate]}
			    rf=${arrayRXMB2[$cntrlArrayRate]}

			    ti=${arrayTXMB1[$cntrlArrayRate]}
			    ri=${arrayRXMB1[$cntrlArrayRate]}

			    var1=`expr $tf - $ti` #T em bytes
			    var2=`expr $rf - $ri` #R em bytes
				var1f=$(($var1/$mb))  #T em mb
				var2f=$(($var2/$mb))  #R em mb


			    var11f=$(($var1f/$time)) #Trate mb
			    var22f=$(($var2f/$time)) #Rrate mb


			    arrayTXFMB+=($var1f)
				arrayRXFMB+=($var2f)
				arrayTRATEMB+=($var11f)
			    arrayRRATEMB+=($var22f)

				cntrlArrayRate=$[$cntrlArrayRate+1]
			done


			fmt="%-12s%-12s%-12s%-12s%-12s\n"
			printf "$fmt" NETIF TX RX TRATE RRATE

			while [ $cntrlMB -lt $NINTERFACES ]; do
				printf "$fmt" "${arrayName[$cntrlMB]}" "${arrayTXFMB[$cntrlMB]}" "${arrayRXFMB[$cntrlMB]}" "${arrayTRATEMB[$cntrlMB]}" "${arrayRRATEMB[$cntrlMB]}"
				cntrlMB=$[$cntrlMB+1]
			done
			;;
		p)
			NINTERFACES=($OPTARG)
			cntrl=0
			fmt="%-12s%-12s%-12s%-12s%-12s\n"

			if [[ $NINTERFACES -gt ${#arrayName[@]} ]];then
				echo "error: Number of interfaces invalid" >&2; exit 1
			fi
			
			printf "$fmt" NETIF TX RX TRATE RRATE

			while [ $cntrl -lt $NINTERFACES ]; do
				printf "$fmt" "${arrayName[$cntrl]}" "${arrayTXFB[$cntrl]}" "${arrayRXFB[$cntrl]}" "${arrayTRATEB[$cntrl]}" "${arrayRRATEB[$cntrl]}"
				cntrl=$[$cntrl+1]
			done
			;;	
		t)

			if [[ $sorting = "s" ]];then
				echo "ERROR : More than 2 sorting options were selected"
				exit 1;
			fi
			fmt="%-12s%-12s%-12s%-12s%-12s\n"
			printf "$fmt" NETIF TX RX TRATE RRATE
			readarray -t arrayTXTemp < <(for a in "${arrayTXFB[@]}"; do echo "$a"; done | sort -r) # sort -r se quiser ordem inversa
			for a in "${!arrayTXTemp[@]}"; do
				for i in "${!arrayTXFB[@]}"; do
   					if [[ "${arrayTXTemp[$a]}" = "${arrayTXFB[$i]}" ]];then
						printf "$fmt" "${arrayName[$i]}" "${arrayTXFB[$i]}" "${arrayRXFB[$i]}" "${arrayTRATEB[$i]}" "${arrayRRATEB[$i]}"
					fi
				done
			done
			
			sorting="s";	
			;;	
		r)
			
			if [[ $sorting = "s" ]];then
				echo "ERROR : More than 2 sorting options were selected"
				exit 1;
			fi
			fmt="%-12s%-12s%-12s%-12s%-12s\n"
			printf "$fmt" NETIF TX RX TRATE RRATE
			readarray -t arrayRXTemp < <(for a in "${arrayRXFB[@]}"; do echo "$a"; done | sort -r)
			for a in "${!arrayRXTemp[@]}"; do
				for i in "${!arrayRXFB[@]}"; do
   					if [[ "${arrayRXTemp[$a]}" = "${arrayRXFB[$i]}" ]];then
						printf "$fmt" "${arrayName[$i]}" "${arrayTXFB[$i]}" "${arrayRXFB[$i]}" "${arrayTRATEB[$i]}" "${arrayRRATEB[$i]}"
					fi
				done
			done
			
			sorting="s";	
			;;	
		T) 	
			if [[ $sorting = "s" ]];then
				echo "ERROR : More than 2 sorting options were selected"
				exit 1;
			fi
			fmt="%-12s%-12s%-12s%-12s%-12s\n"
			printf "$fmt" NETIF TX RX TRATE RRATE
			readarray -t arrayTRATETemp < <(for a in "${arrayTRATEB[@]}"; do echo "$a"; done | sort -r)
			for a in "${!arrayTRATETemp[@]}"; do
				for i in "${!arrayTRATEB[@]}"; do
   					if [[ "${arrayTRATETemp[$a]}" = "${arrayTRATEB[$i]}" ]];then
						printf "$fmt" "${arrayName[$i]}" "${arrayTXFB[$i]}" "${arrayRXFB[$i]}" "${arrayTRATEB[$i]}" "${arrayRRATEB[$i]}"
					fi
				done
			done
			
			sorting="s";	
			;;
		R)
			if [[ $sorting = "s" ]];then
				echo "ERROR : More than 2 sorting options were selected"
				exit 1;
			fi
			fmt="%-12s%-12s%-12s%-12s%-12s\n"
			printf "$fmt" NETIF TX RX TRATE RRATE
			readarray -t arrayRRATETemp < <(for a in "${arrayRRATEB[@]}"; do echo "$a"; done | sort -r)
			for a in "${!arrayRRATETemp[@]}"; do
				for i in "${!arrayRRATEB[@]}"; do
   					if [[ "${arrayRRATETemp[$a]}" = "${arrayRRATEB[$i]}" ]];then
						printf "$fmt" "${arrayName[$i]}" "${arrayTXFB[$i]}" "${arrayRXFB[$i]}" "${arrayTRATEB[$i]}" "${arrayRRATEB[$i]}"
					fi
				done
			done
			
			sorting="s";	
			;;
		v)
			fmt="%-12s%-12s%-12s%-12s%-12s\n"
			printf "$fmt" NETIF TX RX TRATE RRATE
			
			cntrlV="$((NINTERFACES-um))"
			while [ $cntrlV -ge $cntrl ]; do
				printf "$fmt" "${arrayName[$cntrlV]}" "${arrayTXFB[$cntrlV]}" "${arrayRXFB[$cntrlV]}" "${arrayTRATEB[$cntrlV]}" "${arrayRRATEB[$cntrlV]}"
				cntrlV=$[$cntrlV-1]
			done
			;;
		l)
			
			fmt="%-12s%-12s%-12s%-12s%-12s%-12s%-12s\n"
			printf "$fmt" NETIF TX RX TRATE RRATE TXTOT RXTOT

			while true; do
				cntrlL=0
				declare -a arrayTXB1=()
				declare -a arrayRXB1=()
				declare -a arrayTXB2=()
				declare -a arrayRXB2=()
				declare -a arrayTXFB=()
				declare -a arrayRXFB=()
				declare -a arrayTRATEB=()
				declare -a arrayRRATEB=()
				
				cntrlArray1=0
				NRRX=2
				NRTX=3
				while [ $cntrlArray1 -lt $NINTERFACES ]; do
					arrayName=($(netstat -i | awk '{if(NR<='$NINTERFACES+2' && NR>=3) print $1}')) 

					arrayTXB1+=($(netstat -ie | sed '/inet/d' | sed '/ether/d' | sed '/RX error/d' | sed '/TX errors/d' | sed '/device/d' | sed '/loop/d' | sed '1d' | cut -f1 -d":" | sed 's/^ *//g' | awk '{if( NR=='$NRTX' ) print $5}'))

					arrayRXB1+=($(netstat -ie | sed '/inet/d' | sed '/ether/d' | sed '/RX error/d' | sed '/TX errors/d' | sed '/device/d' | sed '/loop/d' | sed '1d' | cut -f1 -d":" | sed 's/^ *//g' | awk '{if( NR=='$NRRX' ) print $5}'))  

					cntrlArray1=$[$cntrlArray1+1]
					NRRX=$[$NRRX+4]
					NRTX=$[$NRTX+4]

				done
				sleep $time
				NRRX=2
				NRTX=3
				cntrlArray2=0
				while [ $cntrlArray2 -lt $NINTERFACES ]; do
					arrayName=($(netstat -i | awk '{if(NR<='$NINTERFACES+2' && NR>=3) print $1}')) 

					arrayTXB2+=($(netstat -ie | sed '/inet/d' | sed '/ether/d' | sed '/RX error/d' | sed '/TX errors/d' | sed '/device/d' | sed '/loop/d' | sed '1d' | cut -f1 -d":" | sed 's/^ *//g' | awk '{if( NR=='$NRTX' ) print $5}'))

					arrayRXB2+=($(netstat -ie | sed '/inet/d' | sed '/ether/d' | sed '/RX error/d' | sed '/TX errors/d' | sed '/device/d' | sed '/loop/d' | sed '1d' | cut -f1 -d":" | sed 's/^ *//g' | awk '{if( NR=='$NRRX' ) print $5}'))  

					cntrlArray2=$[$cntrlArray2+1]
					NRRX=$[$NRRX+4]
					NRTX=$[$NRTX+4]

				done

				cntrlArrayRate=0
				while [ $cntrlArrayRate -lt $NINTERFACES ]; do
				    ti=${arrayTXB1[$cntrlArrayRate]}
					tf=${arrayTXB2[$cntrlArrayRate]}
				    ri=${arrayRXB1[$cntrlArrayRate]}
				    rf=${arrayRXB2[$cntrlArrayRate]}

				    var1=$((tf-ti))
    				var2=$((rf-ri))
    				var11=$(($var1/$time))
    				var22=$(($var2/$time))
    				arrayTXFB+=($var1)
					arrayRXFB+=($var2)
					arrayTRATEB+=($var11)
    				arrayRRATEB+=($var22)

					cntrlArrayRate=$[$cntrlArrayRate+1]
				done

				cntrlL=0
				
				while [ $cntrlL -lt $NINTERFACES ]; do
					arrayTXTOT[$cntrlL]=`expr ${arrayTXTOT[$cntrlL]} + ${arrayTXFB[$cntrlL]}`
					arrayRXTOT[$cntrlL]=`expr ${arrayRXTOT[$cntrlL]} + ${arrayRXFB[$cntrlL]}`
					printf "$fmt" "${arrayName[$cntrlL]}" "${arrayTXFB[$cntrlL]}" "${arrayRXFB[$cntrlL]}" "${arrayTRATEB[$cntrlL]}" "${arrayRRATEB[$cntrlL]}" "${arrayTXTOT[$cntrlL]}" "${arrayRXTOT[$cntrlL]}"
					cntrlL=$[$cntrlL+1]
				done
				sleep 5
				echo -e "\n"
			done	
			;;
        *)
			getRules
			exit 1						
            ;;
    esac
done

# echo "Nº de interfaces: $NINTERFACES"  print numero de interfaces