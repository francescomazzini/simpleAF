%option noyywrap
%{
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <stdbool.h>
int TokenCount = 0;
char* removeFirstAndLasChar(const char* str);
%}

digit [0-9]
letter [a-zA-Z]
INT {digit}+
REAL {INT}(\.{INT})?
STRING \"({letter}|{digit})*\"
ID {letter}({letter}|{digit})*  
FRACTION {INT}\/{INT}
TYPE (REAL)|(STRING)|(FRACTION)

%%

[ ] {/*skip blanks*/}

if {return IF;}
else {return ELSE;}
rad {return RAD;}
log {return LOG;}
mod {return MOD;}
pow {return POW;}
while {return WHILE;}
end {return END;}
symbtb {return SYMBTB;}
sym {return SYM;}
CLOSE {return CLOSE;}
OPEN {return OPEN;}

{REAL}   {yylval.value = atof(yytext);
          return REAL;}

{FRACTION}  {yylval.lexeme =strdup(yytext);
             return FRACTION;}

{TYPE} {yylval.lexeme =strdup(yytext);
             return TYPE;}

{STRING}  {yylval.lexeme =removeFirstAndLasChar(strdup(yytext));
             return STRING;}

{ID}    {yylval.lexeme = strdup(yytext);
          return ID;}
        


          
"+"     {return '+';}
"-"     {return '-';}
"*"     {return '*';}
":"     {return ':';}
"("     {return '(';}
")"     {return ')';}
","     {return ',';}
";"     {return ';';}
"=="    {return EQ;}
"="     {return '=';}
">"     {return '>';}
"<"     {return '<';}
"{"     {return '{';}
"}"     {return '}';}
"?"     {return '?';}
\n    {return '\n';}



%%

// Function for removing the apices from the strings so to keep just their actual value
char* removeFirstAndLasChar(const char* str) {
    size_t len = strlen(str);
    
    if (len <= 2) {
        // If the string has 2 or fewer characters, return an empty string
        char* result = (char*)malloc(1 * sizeof(char));
        if (result == NULL) {
            printf("Memory allocation failed.\n");
            return NULL;
        }
        result[0] = '\0';
        return result;
    }
    
    // Calculate the length of the new string without the first and last characters
    size_t newLen = len - 2;
    
    // Allocate memory for the new string
    char* result = (char*)malloc((newLen + 1) * sizeof(char));
    
    // Check if memory allocation was successful
    if (result == NULL) {
        printf("Memory allocation failed.\n");
        return NULL;
    }
    
    // Copy the substring without the first and last characters to the new string
    strncpy(result, str + 1, newLen);
    result[newLen] = '\0';
    
    return result;
}

