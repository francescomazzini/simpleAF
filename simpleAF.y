%{
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <stdio.h>
#include <math.h>


void yyerror(const char *s)
{
    fprintf(stderr, "%s\n", s);
    exit(1);
}

int yylex(void);

// Funzione per calcolare il massimo comune divisore (GCD) di due numeri
int gcd(int a, int b) {
    if (b == 0)
        return a;
    else
        return gcd(b, a % b);
}

// Funzione per calcolare il minimo comune multiplo (LCM) di due numeri
int lcm(int a, int b) {
    int gcd_result = gcd(a, b);
    return (a * b) / gcd_result;
}

int stringToNumberStart(const char* str) {
    int number = 0;
    int length = strlen(str);

    for (int i = 0; i < length; i++) {
        if (str[i] == '/') {
            break;  // Stop converting when '/' is encountered
        }

        if (str[i] >= '0' && str[i] <= '9') {
            number = number * 10 + (str[i] - '0');
        } else {
            printf("Invalid character '%c'. Ignoring.\n", str[i]);
        }
    }

    return number;
}
int stringToNumberEnd(const char* str) {
    int number = 0;
    int length = strlen(str);

    for (int i = length - 1; i >= 0; i--) {
        if (str[i] == '/') {
            break;  // Stop converting when '/' is encountered
        }

        if (str[i] >= '0' && str[i] <= '9') {
            number = (str[i] - '0') * (int)pow(10, length - 1 - i) + number;
        } else {
            printf("Invalid character '%c'. Ignoring.\n", str[i]);
        }
    }

    return number;
}
char* numbersToString(int number1, int number2) {
    // Determine the required size
    int size = snprintf(NULL, 0, "%d %d", number1, number2);

    // Allocate memory for the string
    char* str = (char*)malloc((size + 1) * sizeof(char));
    if (str == NULL) {
        printf("Memory allocation failed.\n");
        return NULL;
    }

    // Convert the numbers to string
    snprintf(str, size + 1, "%d/%d", number1, number2);

    return str;
}
char* sumFractions(char* a, char* b){
     int numA = stringToNumberStart(a);
     int denA =stringToNumberEnd(a);
     int numB = stringToNumberStart(b);
     int denB = stringToNumberEnd(b);

     int mcm = lcm(denA,denB);
     int newNumA = mcm/denA* numA;
     int newNumB = mcm/denB*numB;

     int numAdded = newNumA+newNumB;

     return numbersToString(numAdded,mcm);

}


 
%}


%union {
       char* lexeme;			//name of an identifier
       float value;			//attribute of a token of type NUM
       }

%token <value>  REAL
%token <lexeme> ID
%token <lexeme> FRACTION
%token IF
%token THEN
%token ELSE
%token FOR
%token TIMES
%token FROM
%token INCREASING
%token DECREASING

%type <value> expr
%type <lexeme> exprFraction

%left '+' '-'
%left '*' ':'

%start line

%%
line  : expr '\n'      {printf("Result: %5.2f\n", $1); exit(0);}
      | exprFraction '\n'   {printf("Result: %s\n", $1); exit(0);}
      | ID             {printf("IDentifier: %s\n", $1); exit(0);}
      | IF             {printf("Recognized: if\n"); exit(0);}
      | THEN             {printf("Recognized: then\n"); exit(0);}
      | ELSE             {printf("Recognized: else\n"); exit(0);}
      | FOR             {printf("Recognized: for\n"); exit(0);}
      | TIMES             {printf("Recognized: times\n"); exit(0);}
      | FROM             {printf("Recognized: from\n"); exit(0);}
      | INCREASING             {printf("Recognized: increasing\n"); exit(0);}
      | DECREASING             {printf("Recognized: decreasing\n"); exit(0);}
      | FRACTION              {printf("fraction: %s\n", $1); exit(0);}
      
      ;
expr  : expr '+' expr  {$$ = $1 + $3;}
      | expr '-' expr  {$$ = $1 - $3;}
      | expr '*' expr  {$$ = $1 * $3;}
      | expr ':' expr  {$$ = $1 / $3;}
      | REAL            {$$ = $1;}

      ;
exprFraction: exprFraction '+' exprFraction  {$$ = sumFractions($1,$3);}
      | FRACTION            {$$ = $1;}
      ;

%%


#include "lex.yy.c"
	
int main(void)
{
  return yyparse();}
