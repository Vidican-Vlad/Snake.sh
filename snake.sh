#!/bin/bash

HEIGHT=15
WIDTH=30
DIRECTIOn="NULL"

if [[ $# != 0 && $# != 2 ]]; then
	echo "wrong number of params"
	exit 1
fi

if [[ $# == 2 ]]; then
	tempHeight=$(( $1 ))
	tempWidth=$(( $2 ))

	if [[ $(( $1 )) == 0 || $(( $2 )) == 0 ]]; then
		echo "one of the inputs for map size wass not a valid number, use default values instead"
	else
		HEIGHT=$(( $1 ))
		WIDTH=$(( $2 ))
	fi
fi

echo -e "map size:\n ---- HEIGHT $HEIGHT ROWS ----\n ---- WIDTH $WIDTH COLLUMNS ----"

pX=$(( $WIDTH/2 ))
pY=$(( $HEIGHT/2 ))
appleX=0 #just initializing it as a global variable so that I can use it later
appleY=0
TAIL_LENGTH=0
TAIL=()
#no boolean available
EXTEND_TAIL=0
GAME_OVER=0

determineInput () {

	if [[ $# != 1 ]]; then 
		echo "wrong numbers of arguments"
		exit 1
	fi

	if [[ $1 == "w" && $DIRECTION != "DOWN" ]]; then
		DIRECTION="UP"
	elif [[ $1 == "s" && $DIRECTION != "UP" ]]; then
		DIRECTION="DOWN"
	elif [[ $1 == "a" && $DIRECTION != "RIGHT" ]]; then
		DIRECTION="LEFT"
	elif [[ $1 == "d" && $DIRECTION != "LEFT" ]]; then
		DIRECTION="RIGHT"
	elif [[ $1 == "e" ]]; then
		GAME_OVER=1
	fi
}

generateApple (){
	
	limit_x=$((WIDTH -2))
	limit_y=$((HEIGHT -2))
	
	while true; do
		appleX=$(((RANDOM % limit_x) + 2))
		appleY=$(((RANDOM % limit_y) + 2))
		
		if ! checkIfPointIsInTail $appleX $appleY; then
			return 1;
		fi
		echo "generated values: x=  $appleX and y= $appleY, but were invalid" >> tmp.log
	done
	

}

moveSnake () {

	if [[ $GAME_OVER == 1 ]]; then
		return 1
	fi
	
	TAIL+=($pX $pY)

	if [[ $DIRECTION == "UP" && $pY -gt 1 ]]; then
		((--pY))
	elif [[ $DIRECTION == "DOWN" && $pY -lt $HEIGHT ]]; then
		((++pY))
	elif [[ $DIRECTION == "LEFT" && $pX -gt 1 ]]; then
		((--pX))
	elif [[ $DIRECTION == "RIGHT" && $pX -lt $WIDTH ]]; then
		((++pX))
	fi

	if [[ $EXTEND_TAIL == 0 ]]; then
		TAIL=("${TAIL[@]:2}")
	else
		EXTEND_TAIL=0
	fi

}

debugPrintTail () {

	for element in "${TAIL[@]}"; do
		echo -n "$element "
	done
}

checkIfPointIsInTail() {

	#$1 point.x 
	#$2 point.y
	
	for (( k=0; k<TAIL_LENGTH; k++)); do
		elemX=$((2 * k))
		elemY=$((2 * k +1))
		
		if [[ "${TAIL[elemX]}" == $1 && "${TAIL[elemY]}" == $2 ]]; then
			return 0;#as in return true
		fi

	done
	return 1;#as in return false
}

drawMap (){
	
	if [[ $GAME_OVER == 1 ]]; then
		return 1;
	fi

	clear
	for (( row=1; row<=HEIGHT; row++ )); do
		for (( col=1; col<=WIDTH; col++ )); do
			if [[ $row == 1 || $col == 1 || $row == $HEIGHT || $col == $WIDTH ]]; then
				echo -n "#"
		       	elif [[ $row == $pY && $col == $pX ]]; then
		 		echo -n "O"
			elif [[ $row == $appleY && $col == $appleX ]]; then
				echo -n "X"
			elif checkIfPointIsInTail $col $row; then
				echo -n "o"
			else
				echo -n " "
			fi
		done
		echo ""
	done
	echo "score is: $((TAIL_LENGTH * 100))"
       	echo -n "the positions of the tail elements are: "
	debugPrintTail	
}

processCollision () {

	if [[ $pX == $appleX && $pY == $appleY ]]; then
		((++TAIL_LENGTH))
		EXTEND_TAIL=1
		generateApple
	elif checkIfPointIsInTail $pX $pY; then
		GAME_OVER=1
	elif [[ $pX == 1 || $pY == 1 || $pX == $WIDTH || $pY == $HEIGHT ]]; then
		GAME_OVER=1
	fi
}

gameLogic (){
	
	if [[ $GAME_OVER == 1 ]]; then
		
		echo -e  "\n\n!!!!!!!!!!!!!!!! GAME OVER !!!!!!!!!!!!!!!!!!\n\n"
		exit 1

	fi

	( sleep 0.12; kill -ALRM $$ ) &

		
	moveSnake
	processCollision
	drawMap
}

#set gameLogic to trigger at regular intervals
trap gameLogic ALRM
gameLogic

#init stuff
generateApple

while true; do
	if [[ $GAME_OVER == 0 ]]; then
		read -rsn1 input
		determineInput $input
	fi
done
