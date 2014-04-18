#!/bin/sh

echo "2" > /sys/class/gpio/export
echo "3" > /sys/class/gpio/export
echo "4" > /sys/class/gpio/export

echo "out" > /sys/class/gpio/gpio2/direction
echo "out" > /sys/class/gpio/gpio3/direction
echo "in" > /sys/class/gpio/gpio4/direction

echo "1" > /sys/class/gpio/gpio2/value
echo "1" > /sys/class/gpio/gpio3/value

USER=""
PASSWORD=""

while true; do
    if [ $(cat /sys/class/gpio/gpio4/value) -eq 0 ]; then
        # Se connecter et enregistrer la page
        curl -c /tmp/cookies -d "name=$USER&pass=$PASSWORD&form_id=user_login&op=Se+connecter" http://lebib.org/user -s
        curl -b /tmp/cookies http://lebib.org --output /tmp/bib.html -s
        # recuperation du token et etat 
        token=$(cat /tmp/bib.html | grep -m 1 form_token | awk '{print $4}' | awk -F '\"' '{print $2}')
        id=$(cat /tmp/bib.html | grep -m 1 form_build_id | awk '{print $29}' | awk -F '\"' '{print $2}')
        state=$(cat /tmp/bib.html | grep -m 1 bibopen | awk '{print $9}' | awk -F '\"' '{print $2}')
        # Si le bib est fermé allumer led orange, si ouvert allumer led blanche
            if [ -z $state ]; then
                echo "0" > /sys/class/gpio/gpio2/value
                echo "1" > /sys/class/gpio/gpio3/value
            else
                echo "0" > /sys/class/gpio/gpio3/value
                echo "1" > /sys/class/gpio/gpio2/value
            fi
        # changer l'etat
        curl -b /tmp/cookies -d "op=Changer&form_build_id=$id&form_token=$token&form_id=bibstate_toggle_form" http://lebib.org -s
        if [ $(cat /sys/class/gpio/gpio3/value) -eq 1 ]; then
            echo "1" > /sys/class/gpio/gpio3/value
            echo "0" > /sys/class/gpio/gpio2/value
        else
            echo "1" > /sys/class/gpio/gpio2/value
            echo "0" > /sys/class/gpio/gpio3/value
        fi
    else
        continue
    fi
done
