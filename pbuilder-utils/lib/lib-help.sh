#!/bin/sh

HELP=
VERSION=${VERSION:-"3.3"}
MANDATE=${MANDATE:-"April 2010"}
MANSECTION=${MANSECTION:-"1"}
AUTHORS=${AUTHORS:-"Jean-Christophe Dubacq"}
COPYRIGHT=${COPYRIGHT:-"© 2010 $AUTHORS."}
ADDITIONALCOPYRIGHT=${ADDITIONALCOPYRIGHT:-"BSD License.
.br
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law."}

help_options() {
    case "$1" in
        --help-nroff|--help)
            HELP="${1#--}"
            HELP="${HELP#help-}"
            return 0
            ;;
        *)
            HELP="fail"
            return 1
            ;;
    esac
}

do_help() {
    if [ -z "$HELP" ]; then
        return
    fi
    PARAG=
    ITALIC=p
    ITEM=' \1 \2'
    if [ "$HELP" = "nroff" ]; then
        case $MANSECTION in
            1)
                SECTIONTEXT="User Commands"
                ;;
            8)
                SECTIONTEXT="Maintenance Commands"
                ;;

            *)
                SECTIONTEXT="Unknown"
                ;;
        esac
        PARAG=".PP"
        ITALIC='s/<<([-A-Za-z ]*)>>/\\fB\1\\fR/g;s/<([-a-z ]*)>/\\fI\1\\fR/g;s/-/\\-/g;p'
        ITEM='.IP \1 2\n\2'
        echo ".TH $(echo $NAME|tr 'a-z' 'A-Z') \"$MANSECTION\" \"$MANDATE\" \"$(echo $VERSION|sed -e 's/[.]/\\./g')\" \"$SECTIONTEXT\""
        echo ".SH NAME";echo "$NAME \- $(echo $SHORTUSAGE|sed -e 's/-/\\-/g')"
        echo ".SH SYNOPSIS";echo ".B $USAGE"|sed -Ee 's/<([^>]*)>/\\fI\1\\fB/g'
    else
        echo "$USAGE"
    fi
    for sect in $(sed -E -ne '/^#BEGINARGS / {s/^#BEGINARGS (.*)/\1/g;p}'< $0); do
        if [ "$HELP" = "nroff" ]; then
            echo ".SH ${sect}"|sed -e 's/_/ /g'|tr 'a-z' 'A-Z'
            sed -E -ne "1,/^#BEGINARGS ${sect}/ d;/^#ENDARGS ${sect}/,\$ d" -e 's/^[         ]*([^         ]+)\). *#([^#]*)# *(.*)$/.TP\n\\fB\1\\fR \\fI\2\\fR\n\3/g;t ok' -e 'd' -e ':ok' -e 's/ \\fI\\fR//g;s/<([a-z]*)>/\\fI\1\\fR/g;s/-/\\-/g;p' < $0
        else
            echo
            echo "${sect}:"|sed -e 's/_/ /g'
            sed -E -ne "1,/^#BEGINARGS ${sect}/ d;/^#ENDARGS ${sect}/,\$ d" -e 's/^[         ]*([^         ]+)\). *#([^#]*)# *(.*)$/  \1 \2\n      \3/g;t ok' -e 'd' -e ':ok' -e 'p' < $0
        fi
        sed -E -ne "1,/^#BEGINARGS ${sect}/ d;/^#ENDARGS ${sect}/,\$ d" -e "s/^###\$/${PARAG}/g" -e "s/^####([^# ]*)  *(.*)\$/${ITEM}/g" -e 's/^###(.*)$/\1/g;t ok' -e 'd' -e ':ok' -e "$ITALIC"  < $0 |grep -v ^$ || true
    done
    if [ "$HELP" = "help" ]; then 
        exit 0
    elif [ "$HELP" = "fail" ]; then
        exit 1
    elif [ "$HELP" = "nroff" ]; then
        echo ".SH AUTHORS"
        echo "Written by $AUTHORS"
        if [ -n "$ADDITIONALAUTHORS" ]; then
            echo "$ADDITIONALAUTHORS"
        fi
        SEEN=0
        for i in $SEEALSO; do
            if [ "$i" != "$NAME/$MANSECTION" ]; then
                if [ "$SEEN" = 0 ]; then
                    echo ".SH SEE ALSO"
                    SEEN=1
                elif [ "$SEEN" = 1 ]; then
                    echo ", \""
                fi
                echo -n ".BR \"${i%/*}\" \"(${i##*/})"
            fi
        done
        if [ "$SEEN" != 0 ]; then
            echo "\""
        fi
        echo ".SH COPYRIGHT"
        echo $COPYRIGHT|sed -e 's/©/Copyright \\(co/g;s/-/\-/g;s/^$/.PP/g'
        if [ -n "$ADDITIONALCOPYRIGHT" ]; then
            echo ".PP"
            echo "$ADDITIONALCOPYRIGHT"
        fi
        exit 0
    fi
}
