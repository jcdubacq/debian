#!/usr/bin/perl
package libhelp;
use strict;
use warnings;
use feature qw{ switch };
$libhelp::HELP='';
$libhelp::VERSION='1.5' unless ($libhelp::VERSION);
$libhelp::MANDATE="April 2010" unless ($libhelp::MANDATE);
$libhelp::MANSECTION='1' unless ($libhelp::MANSECTION);
$libhelp::AUTHORS='Jean-Christophe Dubacq' unless ($libhelp::AUTHORS);
$libhelp::COPYRIGHT="© 2010 ${libhelp::AUTHORS}." unless ($libhelp::COPYRIGHT);
$libhelp::ADDITIONALCOPYRIGHT="BSD License.
.br
    This is free software: you are free to change and redistribute it.
    There is NO WARRANTY, to the extent permitted by law." unless ($libhelp::ADDITIONALCOPYRIGHT);
$libhelp::mode='';

sub help_options {
    my $return=0;
    given ($ARGV[0]) {
        when (/--help-nroff/) { $libhelp::HELP='help-nroff'; }
        when (/--help/) { $libhelp::HELP='help'; }
        default { $return=1; $libhelp::HELP='fail';}
    }
    return $return;
}

sub escapism {
    $_=$_[0];
    return $_ unless $libhelp::mode eq 'nroff';
    my $no=$_[1]?$_[1]:'\fR';
    my $bo=$_[2]?$_[2]:'\fB';
    s/[.]/\\./g;
    s/-/\\-/g;
    s/<<([^>]*)>>/${bo}${1}${no}/g;
    s/<([^>]*)>/\\fI${1}${no}/g;
    return $_;
}
sub do_help {
    return unless ($libhelp::HELP);
    my $sectiontext="Unknown";
    given ($libhelp::MANSECTION) {
        when(1) { $sectiontext="User Commands"; }
        when(8) { $sectiontext="Maintenance Commands"; }
    }
    given ($libhelp::HELP) {
        when(/^help-nroff$/) { 
            $libhelp::mode="nroff";
            print ".TH ".(uc $libhelp::NAME).' "'.$libhelp::MANSECTION.'" "'.$libhelp::MANDATE.'" "'.escapism($libhelp::VERSION)."\" \"${sectiontext}\"\n";
            print ".SH NAME\n${libhelp::NAME} \- ".escapism(${libhelp::SHORTUSAGE})."\n";
            print ".SH SYNOPSIS\n.B ".escapism(${libhelp::USAGE},'\fB','\fR')."\n";
        }
        default { print ${libhelp::USAGE},"\n";}
    }
    
    my @lines;
    open ORIG,"$0";
    @lines=<ORIG>;
    close ORIG;
    my @sect=();
    foreach (@lines) {
        if (/^#BEGINARGS (.*)$/) {
            push @sect,$1;
        }
    }
    my $in;
    my $sect;
    my $a;
    foreach $sect (@sect) {
        $in=2;
        foreach (@lines) {
            if (/^#BEGINARGS ${sect}/) {
                if($in==2) {
                    given($libhelp::HELP) {
                        when(/^help-nroff/) {$a=$sect;$a=~s/_/ /g; print uc ".SH $a\n";}
                        default {$a=$sect;$a=~s/_/ /g; print uc "$a\n";}
                    };
                    $in=1;next;
                }
            }
            if (/^#ENDARGS ${sect}/) {$in=0;next;}
            if ($in==1) {
                if (/^[[:space:]]+when[[:space:]]+\(\/([^)]+)\/\)[^#]*#([^#]*)#(.*)$/) {
                    my ($case,$arg,$expl)=($1,$2,$3);
                    $case=escapism($case);
                    $arg=escapism($arg,'\fB','\fI');
                    $expl=escapism($expl);
                    if ($libhelp::mode eq 'nroff') {
                        print ".TP\n\\fB${case}\\fR";
                        print "\\fI${arg}\\fR" if ($arg);
                        print "\n${expl}\n";
                    } else {
                        print "  $case";
                        print "<$arg>" if ($arg);
                        print "\n    $expl\n"
                    }
                } elsif (/^###$/) {
                    if ($libhelp::mode eq 'nroff') {
                        print ".P\n";
                    } else {
                        print "\n";
                    }
                } elsif (/^####([^# ]*) (.*)/) {
                    if ($libhelp::mode eq 'nroff') {
                        print ".IP $1 2\n";
                        print escapism($2),"\n";
                    } else {
                        print "  $1 $2\n";
                    }
                } elsif (/^###(.*)$/) {
                    if ($libhelp::mode eq 'nroff') {
                        print escapism($1),"\n";
                    } else {
                        print $1,"\n";
                    }
                }
            }
        }
    }
}
#     PARAG=
#     ITALIC=p
#     ITEM=' \1 \2'
#         PARAG=".PP"
#         ITALIC='s/<<([-A-Za-z ]*)>>/\\fB\1\\fR/g;s/<([-a-z ]*)>/\\fI\1\\fR/g;s/-/\\-/g;p'
#         ITEM='.IP \1 2\n\2'

#     for sect in $(sed -E -ne '/^#BEGINARGS / {s/^#BEGINARGS (.*)/\1/g;p}'< $0); do
#         if [ "$HELP" = "nroff" ]; then
#             echo ".SH ${sect}"|sed -e 's/_/ /g'|tr 'a-z' 'A-Z'
#             sed -E -ne "1,/^#BEGINARGS ${sect}/ d;/^#ENDARGS ${sect}/,\$ d" -e 's/^[         ]*([^         ]+)\). *#([^#]*)# *(.*)$/.TP\n\\fB\1\\fR \\fI\2\\fR\n\3/g;t ok' -e 'd' -e ':ok' -e 's/ \\fI\\fR//g;s/<([a-z]*)>/\\fI\1\\fR/g;p' < $0
#         else
#             echo
#             echo "${sect}:"|sed -e 's/_/ /g'
#             sed -E -ne "1,/^#BEGINARGS ${sect}/ d;/^#ENDARGS ${sect}/,\$ d" -e 's/^[         ]*([^         ]+)\). *#([^#]*)# *(.*)$/  \1 \2\n      \3/g;t ok' -e 'd' -e ':ok' -e 'p' < $0
#         fi
#         sed -E -ne "1,/^#BEGINARGS ${sect}/ d;/^#ENDARGS ${sect}/,\$ d" -e "s/^###\$/${PARAG}/g" -e "s/^####([^# ]*)  *(.*)\$/${ITEM}/g" -e 's/^###(.*)$/\1/g;t ok' -e 'd' -e ':ok' -e "$ITALIC"  < $0 |grep -v ^$ || true
#     done
#     if [ "$HELP" = "help" ]; then 
#         exit 0
#     elif [ "$HELP" = "fail" ]; then
#         exit 1
#     elif [ "$HELP" = "nroff" ]; then
#         echo ".SH AUTHORS"
#         echo "Written by $AUTHORS"
#         if [ -n "$ADDITIONALAUTHORS" ]; then
#             echo "$ADDITIONALAUTHORS"
#         fi
#         SEEN=0
#         for i in $SEEALSO; do
#             if [ "$i" != "$NAME/$MANSECTION" ]; then
#                 if [ "$SEEN" = 0 ]; then
#                     echo ".SH SEE ALSO"
#                     SEEN=1
#                 elif [ "$SEEN" = 1 ]; then
#                     echo ", \""
#                 fi
#                 echo -n ".BR \"${i%/*}\" \"(${i##*/})"
#             fi
#         done
#         if [ "$SEEN" != 0 ]; then
#             echo "\""
#         fi
#         echo ".SH COPYRIGHT"
#         echo $COPYRIGHT|sed -e 's/©/Copyright \\(co/g;s/-/\-/g;s/^$/.PP/g'
#         if [ -n "$ADDITIONALCOPYRIGHT" ]; then
#             echo ".PP"
#             echo "$ADDITIONALCOPYRIGHT"
#         fi
#         exit 0
#     fi
1;
