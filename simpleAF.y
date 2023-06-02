%{
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <stdio.h>

void yyerror(const char *s)
{
    fprintf(stderr, "%s\n", s);
    exit(1);
}

int yylex(void);
 
%}


%union {
       char* lexeme;			//name of an identifier
       float value;			//attribute of a token of type NUM
       }

%token <value>  REAL
%token <lexeme> ID
%token IF
%token THEN
%token ELSE
%token FOR
%token TIMES
%token FROM
%token INCREASING
%token DECREASING

%type <value> expr

%left '+' '-'
%left '*' '/'

%start line

%%
line  : expr '\n'      {printf("Result: %5.2f\n", $1); exit(0);}
      | ID             {printf("IDentifier: %s\n", $1); exit(0);}
      | IF             {printf("Recognized: if\n"); exit(0);}
      | THEN             {printf("Recognized: then\n"); exit(0);}
      | ELSE             {printf("Recognized: else\n"); exit(0);}
      | FOR             {printf("Recognized: for\n"); exit(0);}
      | TIMES             {printf("Recognized: times\n"); exit(0);}
      | FROM             {printf("Recognized: from\n"); exit(0);}
      | INCREASING             {printf("Recognized: increasing\n"); exit(0);}
      | DECREASING             {printf("Recognized: decreasing\n"); exit(0);}
      ;
expr  : expr '+' expr  {$$ = $1 + $3;}
      | expr '-' expr  {$$ = $1 - $3;}
      | expr '*' expr  {$$ = $1 * $3;}
      | expr '/' expr  {$$ = $1 / $3;}
      | REAL            {$$ = $1;}
      ;


%%

#include "lex.yy.c"
	
int main(void)
{
  return yyparse();}
