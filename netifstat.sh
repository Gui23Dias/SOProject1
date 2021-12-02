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

kb=0.001 #binary
mb=0.000001
um=1
cntrl=0
cntrlC=0
cntrlArray=0
numRegex=0
NRRX=6 
NRTX=8 
jump=9
p="-p"

re='^[0-9]+$';
declare -a arrayTXTOT=( $(for i in {1..100}; do echo 0; done) )
declare -a arrayRXTOT=( $(for i in {1..100}; do echo 0; done) ./)
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

arrayName=($(netstat -i | awk '{if(NR<='$NINTERFACES+2' && NR>=3) print $1}')) 

arrayTX=($(netstat -i | awk '{if(NR<='$NINTERFACES+2' && NR>=3) print $7}'))
 
arrayRX=($(netstat -i | awk '{if(NR<='$NINTERFACES+2' && NR>=3) print $3}'))
 
arrayTRATE=($(netstat -i | awk '{if(NR<='$NINTERFACES+2' && NR>=3) print $7/'$time'}'))
 
arrayRRATE=($(netstat -i | awk '{if(NR<='$NINTERFACES+2' && NR>=3) print $3/'$time'}'))

while [ $cntrlArray -lt $NINTERFACES ]; do
	arrayName=($(netstat -i | awk '{if(NR<='$NINTERFACES+2' && NR>=3) print $1}')) 

	arrayTXB+=($(netstat -ie | awk '{if( NR=='$NRTX' ) print $5}'))
 
	arrayRXB+=($(netstat -ie | awk '{if( NR=='$NRRX' ) print $5}'))
 
	arrayTRATEB+=($(netstat -ie | awk '{if( NR=='$NRTX' ) print $5/'$time'}'))
 
	arrayRRATEB+=($(netstat -ie | awk '{if( NR=='$NRRX' ) print $5/'$time'}'))  
	
	cntrlArray=$[$cntrlArray+1]
	NRRX=$[$NRRX+9]
	NRTX=$[$NRTX+9]
	
done


if [[ $# -eq 1 ]]; then
	fmt="%-12s%-12s%-12s%-12s%-12s\n"
	printf "$fmt" NETIF TX RX TRATE RRATE
	while [ $cntrl -lt $NINTERFACES ]; do
		printf "$fmt" "${arrayName[$cntrl]}" "${arrayTX[$cntrl]}" "${arrayRX[$cntrl]}" "${arrayTRATE[$cntrl]}" "${arrayRRATE[$cntrl]}"
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
					printf "$fmt" "${arrayName[$cntrlC]}" "${arrayTX[$cntrlC]}" "${arrayRX[$cntrlC]}" "${arrayTRATE[$cntrlC]}" "${arrayRRATE[$cntrlC]}"
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
            fmt="%-12s%-12s%-12s%-12s%-12s\n"
			printf "$fmt" NETIF TX RX TRATE RRATE
			while [ $cntrl -lt $NINTERFACES ]; do
				printf "$fmt" "${arrayName[$cntrl]}" "${arrayTXB[$cntrl]}" "${arrayRXB[$cntrl]}" "${arrayTRATEB[$cntrl]}" "${arrayRRATEB[$cntrl]}"
				# echo -e "${arrayName[$cntrl]} \t${arrayTX[$cntrl]} \t${arrayRX[$cntrl]} \t${arrayTRATE[$cntrl]} \t${arrayRRATE[$cntrl]} "
				cntrl=$[$cntrl+1]
			done
			;;
		k)
			NRRXKB=6
			NRTXKB=8
			cntrlArrayKB=0
			while [ $cntrlArrayKB -lt $NINTERFACES ]; do
				arrayName=($(netstat -i | awk '{if(NR<='$NINTERFACES+2' && NR>=3) print $1}')) 

				arrayTXKB+=($(netstat -ie | awk '{if( NR=='$NRTXKB' ) print $5*'$kb'}'))

				arrayRXKB+=($(netstat -ie | awk '{if( NR=='$NRRXKB' ) print $5*'$kb'}'))

				arrayTRATEKB+=($(netstat -ie | awk '{if( NR=='$NRTXKB' ) print ($5*'$kb')/'$time'}'))

				arrayRRATEKB+=($(netstat -ie | awk '{if( NR=='$NRRXKB' ) print ($5*'$kb')/'$time'}'))  
			
			cntrlArrayKB=$[$cntrlArrayKB+1]
			NRRXKB=$[$NRRXKB+9]
			NRTXKB=$[$NRTXKB+9]
	
			done

			fmt="%-12s%-12s%-12s%-12s%-12s\n"
			printf "$fmt" NETIF TX RX TRATE RRATE

			while [ $cntrl -lt $NINTERFACES ]; do
				printf "$fmt" "${arrayName[$cntrl]}" "${arrayTXKB[$cntrl]}" "${arrayRXKB[$cntrl]}" "${arrayTRATEKB[$cntrl]}" "${arrayRRATEKB[$cntrl]}"
				cntrl=$[$cntrl+1]
			done
			;;
			
		m)	
			NRRXMB=6
			NRTXMB=8
			cntrlArrayMB=0
			while [ $cntrlArrayMB -lt $NINTERFACES ]; do
				arrayName=($(netstat -i | awk '{if(NR<='$NINTERFACES+2' && NR>=3) print $1}')) 

				arrayTXMB+=($(netstat -ie | awk '{if( NR=='$NRTXMB' ) print $5*'$mb'}'))

				arrayRXMB+=($(netstat -ie | awk '{if( NR=='$NRRXMB' ) print $5*'$mb'}'))

				arrayTRATEMB+=($(netstat -ie | awk '{if( NR=='$NRTXMB' ) print ($5*'$mb')/'$time'}'))

				arrayRRATEMB+=($(netstat -ie | awk '{if( NR=='$NRRXMB' ) print ($5*'$mb')/'$time'}'))  
			
			cntrlArrayMB=$[$cntrlArrayMB+1]
			NRRXMB=$[$NRRXMB+9]
			NRTXMB=$[$NRTXMB+9]
	
			done 	
			
			fmt="%-12s%-12s%-12s%-12s%-12s\n"
			printf "$fmt" NETIF TX RX TRATE RRATE

			while [ $cntrl -lt $NINTERFACES ]; do
				printf "$fmt" "${arrayName[$cntrl]}" "${arrayTXMB[$cntrl]}" "${arrayRXMB[$cntrl]}" "${arrayTRATEMB[$cntrl]}" "${arrayRRATEMB[$cntrl]}"
				cntrl=$[$cntrl+1]
			done
			;;
		p)
			NINTERFACES=($OPTARG)
			fmt="%-12s%-12s%-12s%-12s%-12s\n"

			if [[ $NINTERFACES -gt ${#arrayName[@]} ]];then
				echo "error: Number of interfaces invalid" >&2; exit 1
			fi
			
			printf "$fmt" NETIF TX RX TRATE RRATE

			while [ $cntrl -lt $NINTERFACES ]; do
				printf "$fmt" "${arrayName[$cntrl]}" "${arrayTX[$cntrl]}" "${arrayRX[$cntrl]}" "${arrayTRATE[$cntrl]}" "${arrayRRATE[$cntrl]}"
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
			readarray -t arrayTXTemp < <(for a in "${arrayTX[@]}"; do echo "$a"; done | sort -r) # sort -r se quiser ordem inversa
			for a in "${!arrayTXTemp[@]}"; do
				for i in "${!arrayTX[@]}"; do
   					if [[ "${arrayTXTemp[$a]}" = "${arrayTX[$i]}" ]];then
						printf "$fmt" "${arrayName[$i]}" "${arrayTX[$i]}" "${arrayRX[$i]}" "${arrayTRATE[$i]}" "${arrayRRATE[$i]}"
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
			readarray -t arrayRXTemp < <(for a in "${arrayRX[@]}"; do echo "$a"; done | sort -r)
			for a in "${!arrayRXTemp[@]}"; do
				for i in "${!arrayRX[@]}"; do
   					if [[ "${arrayRXTemp[$a]}" = "${arrayRX[$i]}" ]];then
						printf "$fmt" "${arrayName[$i]}" "${arrayTX[$i]}" "${arrayRX[$i]}" "${arrayTRATE[$i]}" "${arrayRRATE[$i]}"
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
			readarray -t arrayTRATETemp < <(for a in "${arrayTRATE[@]}"; do echo "$a"; done | sort -r)
			for a in "${!arrayTRATETemp[@]}"; do
				for i in "${!arrayTRATE[@]}"; do
   					if [[ "${arrayTRATETemp[$a]}" = "${arrayTRATE[$i]}" ]];then
						printf "$fmt" "${arrayName[$i]}" "${arrayTX[$i]}" "${arrayRX[$i]}" "${arrayTRATE[$i]}" "${arrayRRATE[$i]}"
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
			readarray -t arrayRRATETemp < <(for a in "${arrayRRATE[@]}"; do echo "$a"; done | sort -r)
			for a in "${!arrayRRATETemp[@]}"; do
				for i in "${!arrayRRATE[@]}"; do
   					if [[ "${arrayRRATETemp[$a]}" = "${arrayRRATE[$i]}" ]];then
						printf "$fmt" "${arrayName[$i]}" "${arrayTX[$i]}" "${arrayRX[$i]}" "${arrayTRATE[$i]}" "${arrayRRATE[$i]}"
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
				printf "$fmt" "${arrayName[$cntrlV]}" "${arrayTX[$cntrlV]}" "${arrayRX[$cntrlV]}" "${arrayTRATE[$cntrlV]}" "${arrayRRATE[$cntrlV]}"
				cntrlV=$[$cntrlV-1]
			done
			;;
		l)
			
			fmt="%-12s%-12s%-12s%-12s%-12s%-12s%-12s\n"
			printf "$fmt" NETIF TX RX TRATE RRATE TXTOT RXTOT
			while true; do
				cntrlL=0
				arrayName=($(netstat -i | awk '{if(NR<='$NINTERFACES+2' && NR>=3) print $1}')) 

 				arrayTX=($(netstat -i | awk '{if(NR<='$NINTERFACES+2' && NR>=3) print $7}'))
 
 				arrayRX=($(netstat -i | awk '{if(NR<='$NINTERFACES+2' && NR>=3) print $3}'))
 
 				arrayTRATE=($(netstat -i | awk '{if(NR<='$NINTERFACES+2' && NR>=3) print $7/'$time'}'))
 
 				arrayRRATE=($(netstat -i | awk '{if(NR<='$NINTERFACES+2' && NR>=3) print $3/'$time'}'))
				while [ $cntrlL -lt $NINTERFACES ]; do
					arrayTXTOT[$cntrlL]=`expr ${arrayTXTOT[$cntrlL]} + ${arrayTX[$cntrlL]}`
					arrayRXTOT[$cntrlL]=`expr ${arrayRXTOT[$cntrlL]} + ${arrayRX[$cntrlL]}`
					printf "$fmt" "${arrayName[$cntrlL]}" "${arrayTX[$cntrlL]}" "${arrayRX[$cntrlL]}" "${arrayTRATE[$cntrlL]}" "${arrayRRATE[$cntrlL]}" "${arrayTXTOT[$cntrl]}" "${arrayRXTOT[$cntrl]}"
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

