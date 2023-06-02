%option noyywrap
%{
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
int TokenCount = 0;
%}



digit [0-9]
letter [a-zA-Z]
int {digit}+
real {int}\.{int}
fraction {int}\/{int}
string \"{letter|digit}*\"
date {digit}{digit}\/{digit}{digit}\/{digit}{digit}{digit}{digit}{{ }{[bC]|[aC]}}?

id {letter}({letter}|{digit})*  

%%

[ ] {/*skip blanks*/}

if {return IF;}
then {return THEN;}
else {return ELSE;}

for {return FOR;}
times {return TIMES;}
from {return FROM;}
increasing {return INCREASING;}
decreasing {return DECREASING;}

"+"     {return '+';}
"-"     {return '-';}
"*"     {return '*';}
"/"     {return '/';}
\n     {return '\n';}

%%
