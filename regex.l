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
REAL {int}(\.{int})?
ID {letter}({letter}|{digit})*  

FRACTION {int}\/{int}
string \"{letter|digit}*\"
date {digit}{digit}\/{digit}{digit}\/{digit}{digit}{digit}{digit}{{ }{[bC]|[aC]}}?


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

{REAL}   {yylval.value = atof(yytext);
          return REAL;}

{ID}    {yylval.lexeme = strdup(yytext);
          return ID;}

{FRACTION}  {yylval.lexeme =strdup(yytext);
             return FRACTION;}

"+"     {return '+';}
"-"     {return '-';}
"*"     {return '*';}
":"     {return ':';}
\n    {return '\n';}

%%
