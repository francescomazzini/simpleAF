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
