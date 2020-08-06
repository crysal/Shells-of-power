#!/bin/bash
#This script take $1 as input and outputs as morsecode using the Caps/Scroll/Num leds on your keyboard
#
#
morse_dot(){ #function to make the leds blink in a dot veriant
setleds -caps
setleds -scroll
setleds +num
sleep 2
setleds -num
sleep 1
}

morse_dash(){ #function to make the leds blink in a dash veriant
setleds +caps
setleds -scroll
setleds +num
sleep 2
setleds -num
setleds -caps
sleep 1
}

#below is entire alphabet in functions to make leds blink in right oder

morse_a(){
morse_dot
morse_dash
sleep 2
}

morse_b(){
morse_dash
morse_dot
morse_dot
morse_dot
sleep 2
}

morse_c(){
morse_dash
morse_dot
morse_dash
morse_dot
sleep 2

}

morse_d(){
morse_dash
morse_dot
morse_dot
sleep 2

}
morse_e(){
morse_dot
sleep 2

}
morse_f(){
morse_dot
morse_dot
morse_dash
morse_dot
sleep 2
}

morse_g(){
morse_dash
morse_dash
morse_dot
sleep 2
}

morse_h(){
morse_dot
morse_dot
morse_dot
morse_dot
sleep 2
}

morse_i(){
morse_dot
morse_dot
sleep 2
}

morse_j(){
morse_dot
morse_dash
morse_dash
morse_dash
sleep 2
}

morse_k(){
morse_dash
morse_dot
morse_dash
sleep 2
}

morse_l(){
morse_dot
morse_dash
morse_dot
morse_dot
sleep 2
}

morse_m(){
morse_dash
morse_dash
sleep 2
}

morse_n(){
morse_dash
morse_dot
sleep 2
}

morse_o(){
morse_dash
morse_dash
morse_dash
sleep 2
}

morse_p(){
morse_dot
morse_dash
morse_dash
morse_dot
sleep 2
}

morse_q(){
morse_dash
morse_dash
morse_dot
morse_dash
sleep 2
}

morse_r(){
morse_dot
morse_dash
morse_dot
sleep 2
}

morse_s(){
morse_dot
morse_dot
morse_dot
sleep 2
}

morse_t(){
morse_dash
sleep 2
}

morse_u(){
morse_dot
morse_dot
morse_dash
sleep 2
}

morse_v(){
morse_dot
morse_dot
morse_dot
morse_dash
sleep 2
}

morse_w(){
morse_dot
morse_dash
morse_dash
sleep 2
}

morse_x(){
morse_dash
morse_dot
morse_dot
morse_dash
sleep 2
}

morse_y(){
morse_dash
morse_dot
morse_dash
morse_dash
sleep 2
}

morse_z(){
morse_dash
morse_dash
morse_dot
morse_dot
sleep 2
}

morse_1(){
morse_dot
morse_dash
morse_dash
morse_dash
morse_dash
sleep 2
}

morse_2(){
morse_dot
morse_dot
morse_dash
morse_dash
morse_dash
sleep 2
}

morse_3(){
morse_dot
morse_dot
morse_dot
morse_dash
morse_dash
sleep 2
}

morse_4(){
morse_dot
morse_dot
morse_dot
morse_dot
morse_dash
sleep 2
}

morse_5(){
morse_dot
morse_dot
morse_dot
morse_dot
morse_dot
sleep 2
}

morse_6(){
morse_dash
morse_dot
morse_dot
morse_dot
morse_dot
sleep 2
}

morse_7(){
morse_dash
morse_dash
morse_dot
morse_dot
morse_dot
sleep 2
}

morse_8(){
morse_dash
morse_dash
morse_dash
morse_dot
morse_dot
sleep 2
}

morse_9(){
morse_dash
morse_dash
morse_dash
morse_dash
morse_dot
sleep 2
}

morse_0(){
morse_dash
morse_dash
morse_dash
morse_dash
morse_dash
sleep 2
}

#Loop incase you have more than 1 charcter in $1
length=$(echo ${#1})
x=0
while [ $x -ne $length ]
do
x=$(($x+1))
currentletter=$(echo $1 | head -c $x | tail -c 1)
morse_$currentletter
done
