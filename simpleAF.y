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

char* concatenateStrings(const char* str1, const char* str2);
char* divFractions(char* a, char* b);
char* mulFractions(char* a, char* b);
char* subFractions(char* a, char* b);
char* sumFractions(char* a, char* b);
float convertStringToFloat(char* a);
char* simplifyFraction(int numerator, int denominator);
char* numbersToString(int number1, int number2);
int stringToNumberEnd(const char* str);
int stringToNumberStart(const char* str);
int lcm(int a, int b);
int gcd(int a, int b);
char* multiplyStrings (const char* str1, float mulNum);


 
%}


%union {
       char* lexeme;			//name of an identifier
       float value;			//attribute of a token of type NUM
       }

%type <value> expr
%type <lexeme> exprStrings
%type <lexeme> exprFraction

%token <lexeme> ID
%token <value>  REAL
%token <lexeme> STRING
%token <lexeme> FRACTION
%token LOG
%token RAD
%token MOD
%token POW
%token IF
%token THEN
%token ELSE
%token FOR
%token TIMES
%token FROM
%token INCREASING
%token DECREASING

%left '+' '-'
%left '*' ':'

%start line

%%
line  : expr '\n'      {printf("Result: %5.2f\n", $1); exit(0);}
      | exprFraction '\n'   {printf("Result: %s\n", $1); exit(0);}
      | exprStrings '\n' {printf("Result: \"%s\"\n", $1); exit(0);}
      | STRING   {printf("String recognized: \"%s\"\n", $1); exit(0);}
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
      | RAD '(' expr ')' {$$ = sqrt($3);}
      | LOG '(' expr ')' {$$ = log($3)/log(10);}
      | MOD '(' expr ',' expr ')' {$$ = (int)$3 % (int)$5;}
      | POW '(' expr ',' expr ')' {$$ =pow($3,$5);}
      | REAL            {$$ = $1;}

      ;
exprFraction: exprFraction '+' exprFraction  {$$ = sumFractions($1,$3);}
      | exprFraction '-' exprFraction  {$$ = subFractions($1,$3);}
      | exprFraction '*' exprFraction  {$$ = mulFractions($1,$3);}
      | exprFraction ':' exprFraction  {$$ = divFractions($1,$3);}
      | FRACTION            {$$ = $1;}
      ;

exprStrings: exprStrings '+' exprStrings {$$ = concatenateStrings($1,$3);}
        | exprStrings '*' REAL {$$ = multiplyStrings($1,$3);}
        | STRING {$$ = $1;}
        ;

        

%%


#include "lex.yy.c"
	
int main(void)
{
  return yyparse();}

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

char* simplifyFraction(int numerator, int denominator) {
    int commonDivisor = gcd(numerator, denominator);

    // Divide both numerator and denominator by the common divisor
    numerator /= commonDivisor;
    denominator /= commonDivisor;

  
    return numbersToString(numerator,denominator);
}

float convertStringToFloat(char* a){
    int c = stringToNumberStart(a);
    int b = stringToNumberEnd(a);

    return (float)(c/b);
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

     return simplifyFraction(numAdded,mcm);

}

char* subFractions(char* a, char* b){
     int numA = stringToNumberStart(a);
     int denA =stringToNumberEnd(a);
     int numB = stringToNumberStart(b);
     int denB = stringToNumberEnd(b);

     int mcm = lcm(denA,denB);
     int newNumA = mcm/denA* numA;
     int newNumB = mcm/denB*numB;

     int numAdded = newNumA-newNumB;

     return simplifyFraction(numAdded,mcm);

}


char* mulFractions(char* a, char* b){
     int numA = stringToNumberStart(a);
     int denA =stringToNumberEnd(a);
     int numB = stringToNumberStart(b);
     int denB = stringToNumberEnd(b);

     int newNum = numA * numB;
     int newDen = denA * denB;

     return simplifyFraction(newNum,newDen);
}

char* divFractions(char* a, char* b){
     int numA = stringToNumberStart(a);
     int denA =stringToNumberEnd(a);
     int numB = stringToNumberStart(b);
     int denB = stringToNumberEnd(b);

     int newNum = numA * denB;
     int newDen = denA * numB;

     return simplifyFraction(newNum,newDen);
}

char* concatenateStrings(const char* str1, const char* str2) {
    size_t len1 = strlen(str1);
    size_t len2 = strlen(str2);
    
    // Allocate memory for the concatenated string
    char* result = (char*)malloc((len1 + len2 + 1) * sizeof(char));
    
    // Check if memory allocation was successful
    if (result == NULL) {
        printf("Memory allocation failed.\n");
        return NULL;
    }
    
    // Copy str1 to the result string
    strcpy(result, str1);
    
    // Concatenate str2 to the result string
    strcat(result, str2);
    
    return result;
}

char* multiplyStrings(const char* str, float numTimes) {

    int times = (int) numTimes;
    size_t strLength = strlen(str);
    size_t resultLength = strLength * times;

    char* result = (char*)malloc((resultLength + 1) * sizeof(char));
    strcpy(result, "");

    for (int i = 0; i < times; i++) {
        strcat(result, str);
    }

    return result;
}