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
STRING \"({letter}|{digit})*\"
ID {letter}({letter}|{digit})*  
FRACTION {int}\/{int}

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


{FRACTION}  {yylval.lexeme =strdup(yytext);
             return FRACTION;}

{STRING}  {yylval.lexeme =strdup(yytext);
             return STRING;}

{ID}    {yylval.lexeme = strdup(yytext);
          return ID;}
          
"+"     {return '+';}
"-"     {return '-';}
"*"     {return '*';}
":"     {return ':';}
\n    {return '\n';}

%%
