%{
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <stdio.h>
#include <math.h>
#include <stdbool.h>

#define NAME_MAX 256


void yyerror(const char *s)
{
    fprintf(stderr, "%s\n", s);
    exit(1);
}

int yylex(void);

 union Value
    {
        float floatValue;
        char stringValue[NAME_MAX];
    };

struct symbolTableEntry {
    char id[NAME_MAX];
    char type[NAME_MAX];

    union Value value;

    int scope_level;

    struct symbolTableEntry* next;
};
struct symbolTable{
  struct symbolTableEntry* head;
  int countSymbol;
};


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
bool booleanOfFractionsBigger(char* a, char* b);
bool booleanOfFractionsSmaller(char* a, char* b);

struct symbolTableEntry* createFirstEntryTable(char* id, void* value, char* type);
void createSymbolTable(struct symbolTable *table);
void addEntryTable(struct symbolTableEntry* list,char* id, void* value, char* type);
void addSymbolTable(struct symbolTable* table,char* id, void* value, char* type);
void printSingleSymbolTableEntry(struct symbolTableEntry* symbol);
void printSymbolTableEntry (struct symbolTable* symbol);
struct symbolTableEntry* lookUp(struct symbolTableEntry* symbol, char* id);
struct symbolTableEntry* lookUpTable(struct symbolTable* table, char* id);

void addWithTypeChecking(struct symbolTable SYMBOL_TABLE, char* supposedType, struct symbolTableEntry value,char* id);
void updateValueWithTypeChecking (struct symbolTable SYMBOL_TABLE,char* id,  struct symbolTableEntry value);
void* getValueWithTypeChecking (struct symbolTable SYMBOL_TABLE,char* id, char* actualType);
void* getValueWithoutTypeChecking (struct symbolTable SYMBOL_TABLE,char* id);
char* getValueType ( struct symbolTable SYMBOL_TABLE,char* id );
void copyIDFromName (struct symbolTable SYMBOL_TABLE, struct symbolTableEntry* id1, char* id2 );
void copyIDFromFloat (struct symbolTable SYMBOL_TABLE, struct symbolTableEntry* id1, float id2 );
void copyIDFromFraction (struct symbolTable SYMBOL_TABLE, struct symbolTableEntry* id1, char* id2 );
void copyIDFromString (struct symbolTable SYMBOL_TABLE, struct symbolTableEntry* id1, char* id2 );
void copyID (struct symbolTable SYMBOL_TABLE, struct symbolTableEntry* id1, struct symbolTableEntry id2 );
struct symbolTableEntry sumID (struct symbolTable SYMBOL_TABLE,  struct symbolTableEntry id1,  struct symbolTableEntry id2);
struct symbolTableEntry subID (struct symbolTable SYMBOL_TABLE,  struct symbolTableEntry id1,  struct symbolTableEntry id2);
struct symbolTableEntry mulID (struct symbolTable SYMBOL_TABLE,  struct symbolTableEntry id1,  struct symbolTableEntry id2);
struct symbolTableEntry divID (struct symbolTable SYMBOL_TABLE,  struct symbolTableEntry id1,  struct symbolTableEntry id2);
struct symbolTableEntry sqrtID(struct symbolTable SYMBOL_TABLE,  struct symbolTableEntry id1);
struct symbolTableEntry logID(struct symbolTable SYMBOL_TABLE,  struct symbolTableEntry id1);
struct symbolTableEntry modID(struct symbolTable SYMBOL_TABLE,  struct symbolTableEntry id1,  struct symbolTableEntry id2);
struct symbolTableEntry powID (struct symbolTable SYMBOL_TABLE,  struct symbolTableEntry id1,  struct symbolTableEntry id2);
bool boolID (struct symbolTable SYMBOL_TABLE,  struct symbolTableEntry id1,  struct symbolTableEntry id2, char operator);


struct symbolTable SYMBOL_TABLE;
int GLOBAL_SCOPE_LEVEL = 1;
 
%}


%union {
       char* lexeme;			//name of an identifier
       float value;			//attribute of a token of type NUM
       bool boolean;      //attribute of a to boolean
       struct symbolTableEntry id;
       }

%type <id> exprGeneral
%type <boolean> exprBool

%token END
%token <lexeme> ID
%token <value>  REAL
%token <lexeme> STRING
%token <lexeme> FRACTION
%token <lexeme> TYPE
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
%token BOOLEAN
%token EQ
%token WHILE


%left '+' '-'
%left '*' ':'
%left '<' '>'

%start scope

%%
scope : prog          
      ;

prog  : line  ';' '\n' prog
        | line ';' '\n'
        | '\n' prog
      ;

line  :  END  '\n'       {exit(0);}
      | exprGeneral         { 
                                if(strcmp($1.type, "STRING") == 0)
                                    printf("Value: \"%s\"", $1.value.stringValue);
                                else if (strcmp($1.type, "FRACTION") == 0)
                                    printf("Value: %s", $1.value.stringValue);
                                else if (strcmp($1.type, "REAL") == 0) {
                                    printf("Value: %f", $1.value.floatValue);
                                }
                            }
      | TYPE ID '=' exprGeneral { 
                                addWithTypeChecking(SYMBOL_TABLE,$1,$4,$2);
                                printSingleSymbolTableEntry(lookUpTable(&SYMBOL_TABLE, $2));
                            }
      | ID '=' exprGeneral  { 
                            updateValueWithTypeChecking(SYMBOL_TABLE, $1, $3);

                            printSingleSymbolTableEntry(lookUpTable(&SYMBOL_TABLE, $1));
                        }
      | BOOLEAN {printf("Boolean recognized\n"); exit(0);}
    //   | expr     {printf("Result: %5.2f\n", $1); exit(0);}
    //   | exprFraction    {printf("Result: %s\n", $1); exit(0);}
    //   | exprStrings  {printf("Result: \"%s\"\n", $1); exit(0);}
    //   | STRING   {printf("String recognized: \"%s\"\n", $1); exit(0);}
    //   | ID             {printf("IDentifier: %s\n", $1); exit(0);}
      | exprBool {printf("Boolean is: \"%s\"\n", $1 ? "true" : "false");} 
      | IF  '(' exprBool ')' '{' { GLOBAL_SCOPE_LEVEL = GLOBAL_SCOPE_LEVEL + 1; }  '\n' 
        prog  elseStatement              { printf("If condition is: \"%s\"\n", $3 ? "true" : "false");} 

      | WHILE '(' exprBool ')' '{'  { GLOBAL_SCOPE_LEVEL = GLOBAL_SCOPE_LEVEL + 1; } '\n' 
        prog '}'                      { GLOBAL_SCOPE_LEVEL = GLOBAL_SCOPE_LEVEL - 1; printf("While condition is: \"%s\"\n", $3 ? "true" : "false");}
    //   | THEN             {printf("Recognized: then\n"); exit(0);}
    //   | FOR             {printf("Recognized: for\n"); exit(0);}
    //   | TIMES             {printf("Recognized: times\n"); exit(0);}
    //   | FROM             {printf("Recognized: from\n"); exit(0);}
    //   | INCREASING             {printf("Recognized: increasing\n"); exit(0);}
    //   | DECREASING             {printf("Recognized: decreasing\n"); exit(0);}
    //   | FRACTION              {printf("fraction: %s\n", $1); exit(0);}
      
      ;

    //it was done with a separate statement because since there ws code already at the opening of the first curly bracket,
    // then it was needed to make him know immediately which of the two productions (if then or if else) it has to choose. 
    //Since this was not possible, because even giving priority to the else, than it would have chose that production much before than knowing
    //if there was an else or not, therefore we had to separate the possibility of the else production in a separate one
    elseStatement :  
        '}' {  } ELSE '{' '\n' {  }  
        prog '}'  { GLOBAL_SCOPE_LEVEL = GLOBAL_SCOPE_LEVEL - 1;}
        | '}' { GLOBAL_SCOPE_LEVEL = GLOBAL_SCOPE_LEVEL - 1; } 
    ;

exprGeneral : 
     exprGeneral '+' exprGeneral { copyID(SYMBOL_TABLE, &$$, sumID(SYMBOL_TABLE, $1, $3)); } 
    | exprGeneral '-' exprGeneral { copyID(SYMBOL_TABLE, &$$, subID(SYMBOL_TABLE, $1, $3)); }
    | exprGeneral '*' exprGeneral { copyID(SYMBOL_TABLE, &$$, mulID(SYMBOL_TABLE, $1, $3)); }
    | exprGeneral ':' exprGeneral { copyID(SYMBOL_TABLE, &$$, divID(SYMBOL_TABLE, $1, $3)); } 
    | RAD '(' exprGeneral ')'              { copyID(SYMBOL_TABLE, &$$, sqrtID(SYMBOL_TABLE, $3)); }
    | LOG '(' exprGeneral ')'               { copyID(SYMBOL_TABLE, &$$, logID(SYMBOL_TABLE, $3)); }
    | MOD '(' exprGeneral ',' exprGeneral ')'             {copyID(SYMBOL_TABLE, &$$, modID(SYMBOL_TABLE, $3, $5));}
    | POW '(' exprGeneral ',' exprGeneral ')'              {  copyID(SYMBOL_TABLE, &$$, powID(SYMBOL_TABLE, $3, $5)); }
    | ID                          { copyIDFromName(SYMBOL_TABLE, &$$, $1); } 
    | REAL                      { copyIDFromFloat(SYMBOL_TABLE, &$$, $1); }
    | FRACTION                   { copyIDFromFraction(SYMBOL_TABLE, &$$, $1); }
    | STRING                    { copyIDFromString(SYMBOL_TABLE, &$$, $1);}
    ;

exprBool: 
        exprGeneral '>' exprGeneral {$$ = boolID(SYMBOL_TABLE,$1,$3, '>');}
    |   exprGeneral '<' exprGeneral {$$ = boolID(SYMBOL_TABLE,$1,$3, '<');}
    |   exprGeneral EQ exprGeneral {$$ = boolID(SYMBOL_TABLE,$1,$3, '=');}
;
    

%%


#include "lex.yy.c"
	
int main(void)
{
  createSymbolTable(&SYMBOL_TABLE);
  return yyparse();
}




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
bool booleanOfFractionsBigger(char* a, char* b){
    int numA = stringToNumberStart(a);
    int denA = stringToNumberEnd(a);
    int numB = stringToNumberStart(b);
    int denB =stringToNumberEnd(b);

    float numberA = (float)numA/denA;
   
    float numberB = (float)numB / denB;
 
    return numberA>numberB;
}
bool booleanOfFractionsSmaller(char* a, char* b){
    int numA = stringToNumberStart(a);
    int denA = stringToNumberEnd(a);
    int numB = stringToNumberStart(b);
    int denB =stringToNumberEnd(b);

    float numberA = (float)numA/denA;
   
    float numberB = (float)numB / denB;

    return numberA<numberB;
}




/// - -  - -- - - - - -- - - -  SYMBOL TABLE - -- - - -- - - - - --

struct symbolTableEntry* createFirstEntryTable(char* id, void* value, char* type) {
  struct symbolTableEntry *first = (struct symbolTableEntry*) malloc(sizeof(struct symbolTableEntry));
	
  first->next=NULL;
  strcpy(first->id, id);
  first->scope_level = GLOBAL_SCOPE_LEVEL;
 

    union Value tempValue;

  
  if(strcmp(type, "REAL")==0){
      tempValue.floatValue = *((float*)value);
      first->value = tempValue;
  }else if(strcmp(type, "STRING")==0){
    strncpy(tempValue.stringValue, (char*)value,NAME_MAX-1);
    tempValue.stringValue[NAME_MAX-1]='\0';
    first->value = tempValue;

  }else if (strcmp(type, "FRACTION")==0){
  strncpy(tempValue.stringValue, (char*)value,NAME_MAX-1);
    tempValue.stringValue[NAME_MAX-1]='\0';
    first->value = tempValue;

  }else{
    printf("error type");
  }

strcpy(first->type, type);
return first;
}
void createSymbolTable(struct symbolTable *table){

  char* charValue = "first";
  table->head = createFirstEntryTable("",(void*)charValue,"STRING");
  table->countSymbol = 0;


}

void addEntryTable(struct symbolTableEntry* list,char* id, void* value, char* type) {

 struct symbolTableEntry *last = list;

  while(last->next != NULL) {
    if (strcmp(last->id, id)==0)
    {
      printf("already existing id \n");
      return;

    }
    
    last = last->next;
  }


  last->next = createFirstEntryTable(id,value,type);
  

  
}
void addSymbolTable(struct symbolTable* table,char* id, void* value, char* type){
    
  addEntryTable(table->head,id,value,type);
  table->countSymbol++;

}
void printSingleSymbolTableEntry(struct symbolTableEntry* symbol){
    printf("Id: %s\n", symbol->id);
  printf("Type: %s\n", symbol->type);
  printf("Scope level: %d\n", symbol->scope_level);
  if(strcmp(symbol->type, "REAL")==0){
      printf("Value: %f\n", symbol->value.floatValue);
  }else if(strcmp(symbol->type, "STRING")==0){
   printf("Value: %s\n", symbol->value.stringValue);
  }else if (strcmp(symbol->type, "FRACTION")==0){
   printf("Value: %s\n", symbol->value.stringValue);

  }else{
    printf("error type");
  }
}
void printSymbolTableEntry (struct symbolTable* symbol) {

struct symbolTableEntry *iterator = symbol->head;
  while(iterator != NULL){

  printSingleSymbolTableEntry(iterator);
  iterator = iterator->next;
  
  }

}

struct symbolTableEntry* lookUp(struct symbolTableEntry* symbol, char* id) {

  struct symbolTableEntry *iter = symbol;
  bool found = false;

  while(!(iter == NULL) && found == false) {

    if(strcmp(iter->id, id) == 0)
      found = true;
    else
      iter = iter->next;

  }

  if(!found)
    iter = NULL;

  return iter;  

}
struct symbolTableEntry* lookUpTable(struct symbolTable* table, char* id){
  return lookUp(table->head,id);
}

//--------- util symbol table ---------

void addWithTypeChecking(struct symbolTable SYMBOL_TABLE, char* supposedType, struct symbolTableEntry value,char* id){

    if(strcmp(value.type, supposedType) != 0) {
        printf("Error type");
        exit(1);
    } else {

        struct symbolTableEntry* entry = lookUpTable(&SYMBOL_TABLE, id);

        if(entry != NULL) {

            printf("ERROR! ID %s is already declared", id);
            exit(1);
        
        } else {
            if(strcmp(value.type, "STRING") == 0 || strcmp(value.type, "FRACTION") == 0) {
                addSymbolTable(&SYMBOL_TABLE, id, (void*)value.value.stringValue, value.type);
            } else if (strcmp(value.type, "REAL") == 0 ) {
                addSymbolTable(&SYMBOL_TABLE, id, (void*)&value.value.floatValue, value.type);
            }
        }

    } 

}

void updateValueWithTypeChecking (struct symbolTable SYMBOL_TABLE,char* id,  struct symbolTableEntry value) {

    struct symbolTableEntry* entry = lookUpTable(&SYMBOL_TABLE, id);

    if(entry == NULL) {
        printf("ERROR! ID %s not found", id);
        exit(1);
    }
    
    if(strcmp(entry->type, value.type) != 0) {
        printf("TYPE ERROR");
        exit(1);
    }

    // union Value tempValue;

    if(strcmp(value.type, "REAL")==0){
    //   tempValue.floatValue = *((float*)value);
      entry->value.floatValue = value.value.floatValue;
    }else if(strcmp(value.type, "STRING")==0 || strcmp(value.type, "FRACTION")==0){
        strncpy(entry->value.stringValue, (char*)value.value.stringValue,NAME_MAX-1);
        entry->value.stringValue[NAME_MAX-1]='\0';
    // }else if (strcmp(actualType, "FRACTION")==0){
    // strncpy(tempValue.stringValue, (char*)value,NAME_MAX-1);
    //     tempValue.stringValue[NAME_MAX-1]='\0';
    //     entry->value = tempValue;

    }else{
        printf("error type");
    }

    // tempValue.floatValue = *((float*)&$3);
    // entry->value = tempValue;

}

void* getValueWithTypeChecking (struct symbolTable SYMBOL_TABLE,char* id, char* actualType) {

    struct symbolTableEntry* entry = lookUpTable(&SYMBOL_TABLE, id);

    if(entry == NULL) {
        printf("ERROR! ID %s not found", id);
        exit(1);
    }
    
    if(strcmp(entry->type, actualType) != 0) {
        printf("TYPE ERROR");
        exit(1);
    }

    if(strcmp(actualType, "REAL")==0){
        return (void*)&(entry->value.floatValue);
    }else if(strcmp(actualType, "STRING")==0){
        return (void*)&(entry->value.stringValue);
    }else if (strcmp(actualType, "FRACTION")==0){
        return (void*)&(entry->value.stringValue);
    }else{
        printf("error type");
    }

    return NULL;

}

void* getValueWithoutTypeChecking (struct symbolTable SYMBOL_TABLE,char* id) {

    struct symbolTableEntry* entry = lookUpTable(&SYMBOL_TABLE, id);

    if(entry == NULL) {
        printf("ERROR! ID %s not found", id);
        exit(1);
    }

    if(strcmp(entry->type, "REAL")==0){
        return (void*)&(entry->value.floatValue);
    }else if(strcmp(entry->type, "STRING")==0){
        return (void*)&(entry->value.stringValue);
    }else if (strcmp(entry->type, "FRACTION")==0){
        return (void*)&(entry->value.stringValue);
    }else{
        printf("error type");
    }

    return NULL;

}

char* getValueType ( struct symbolTable SYMBOL_TABLE,char* id ) {

    struct symbolTableEntry* entry = lookUpTable(&SYMBOL_TABLE, id);

    return entry->type;

}

void copyIDFromName (struct symbolTable SYMBOL_TABLE, struct symbolTableEntry* id1, char* id2 ) {

    strcpy(id1->type, getValueType(SYMBOL_TABLE, id2));
    if(strcmp(id1->type, "STRING") == 0 || strcmp(id1->type, "FRACTION") == 0)
        strcpy(id1->value.stringValue, getValueWithoutTypeChecking(SYMBOL_TABLE, id2));
    else if (strcmp(id1->type, "REAL") == 0) {
        float* floatValue = getValueWithoutTypeChecking(SYMBOL_TABLE, id2);
        id1->value.floatValue = *floatValue;
    }

}

void copyIDFromFraction (struct symbolTable SYMBOL_TABLE, struct symbolTableEntry* id1, char* id2 ) {

    strcpy(id1->type, "FRACTION");
    strcpy(id1->value.stringValue, id2);

}

void copyIDFromFloat (struct symbolTable SYMBOL_TABLE, struct symbolTableEntry* id1, float id2 ) {

    strcpy(id1->type, "REAL");
    id1->value.floatValue = id2;

}

void copyIDFromString (struct symbolTable SYMBOL_TABLE, struct symbolTableEntry* id1, char* id2 ) {

    strcpy(id1->type, "STRING");
    strcpy(id1->value.stringValue, id2);

}

void copyID (struct symbolTable SYMBOL_TABLE, struct symbolTableEntry* id1, struct symbolTableEntry id2 ) {

    strcpy(id1->type, id2.type);
    if(strcmp(id1->type, "STRING") == 0 || strcmp(id1->type, "FRACTION") == 0)
        strcpy(id1->value.stringValue, id2.value.stringValue);
    else if (strcmp(id1->type, "REAL") == 0) {
        float floatValue = id2.value.floatValue;
        id1->value.floatValue = floatValue;
    }

}

struct symbolTableEntry sumID (struct symbolTable SYMBOL_TABLE,  struct symbolTableEntry id1,  struct symbolTableEntry id2) {

    struct symbolTableEntry result;
    strcpy(result.type, "");

    if(strcmp(id1.type, "STRING") == 0 && strcmp(id2.type, "STRING") == 0) {
        char* val1 = id1.value.stringValue;
        char* val2 = id2.value.stringValue;
        strcpy(result.type, "STRING");
        strcpy(result.value.stringValue, concatenateStrings(val1, val2));
    } else if (strcmp(id1.type, "FRACTION") == 0 && strcmp(id2.type, "FRACTION") == 0) {
        char* val1 = id1.value.stringValue;
        char* val2 = id2.value.stringValue;
        strcpy(result.type, "FRACTION");
        strcpy(result.value.stringValue, sumFractions(val1, val2));
    } else if (strcmp(id1.type, "REAL") == 0 && strcmp(id2.type, "REAL") == 0) {
        float val1 = id1.value.floatValue;
        float val2 = id2.value.floatValue;
        strcpy(result.type, "REAL");
        result.value.floatValue = val1 + val2;
    } else {
        printf("MISMATCH TYPE ERROR");
        exit(1);
    }
    
    return result;

}

struct symbolTableEntry subID (struct symbolTable SYMBOL_TABLE,  struct symbolTableEntry id1,  struct symbolTableEntry id2) {

    struct symbolTableEntry result;
    strcpy(result.type, "");

    if(strcmp(id1.type, "STRING") == 0 && strcmp(id2.type, "STRING") == 0) {
        printf("INCORRECT OPERATION FOR THIS TYPE");
        exit(1);
    } else if (strcmp(id1.type, "FRACTION") == 0 && strcmp(id2.type, "FRACTION") == 0) {
        char* val1 = id1.value.stringValue;
        char* val2 = id2.value.stringValue;
        strcpy(result.type, "FRACTION");
        strcpy(result.value.stringValue, subFractions(val1, val2));
    } else if (strcmp(id1.type, "REAL") == 0 && strcmp(id2.type, "REAL") == 0) {
        float val1 = id1.value.floatValue;
        float val2 = id2.value.floatValue;
        strcpy(result.type, "REAL");
        result.value.floatValue = val1 - val2;
    } else {
        printf("MISMATCH TYPE ERROR");
        exit(1);
    }
    
    return result;

}

struct symbolTableEntry mulID (struct symbolTable SYMBOL_TABLE,  struct symbolTableEntry id1,  struct symbolTableEntry id2) {

    struct symbolTableEntry result;
    strcpy(result.type, "");

    if(strcmp(id1.type, "STRING") == 0 && strcmp(id2.type, "STRING") == 0) {
        printf("INCORRECT OPERATION FOR THIS TYPE");
        exit(1);
    } else if (strcmp(id1.type, "FRACTION") == 0 && strcmp(id2.type, "FRACTION") == 0) {
        char* val1 = id1.value.stringValue;
        char* val2 = id2.value.stringValue;
        strcpy(result.type, "FRACTION");
        strcpy(result.value.stringValue, subFractions(val1, val2));
    } else if (strcmp(id1.type, "REAL") == 0 && strcmp(id2.type, "REAL") == 0) {
        float val1 = id1.value.floatValue;
        float val2 = id2.value.floatValue;
        strcpy(result.type, "REAL");
        result.value.floatValue = val1 * val2;
    } else if (strcmp(id1.type, "STRING") == 0 && strcmp(id2.type, "REAL") == 0) {
        char* val1 = id1.value.stringValue;
        float val2 = id2.value.floatValue;
        strcpy(result.type, "STRING");
        strcpy(result.value.stringValue, multiplyStrings(val1, val2));
    } else if (strcmp(id1.type, "REAL") == 0 && strcmp(id2.type, "STRING") == 0) {
        float val1 = id1.value.floatValue;
        char* val2 = id2.value.stringValue;
        strcpy(result.type, "STRING");
        strcpy(result.value.stringValue, multiplyStrings(val2, val1));
    } else {
        printf("MISMATCH TYPE ERROR");
        exit(1);
    }
    
    return result;

}

struct symbolTableEntry divID (struct symbolTable SYMBOL_TABLE,  struct symbolTableEntry id1,  struct symbolTableEntry id2) {

    struct symbolTableEntry result;
    strcpy(result.type, "");

    if(strcmp(id1.type, "STRING") == 0 && strcmp(id2.type, "STRING") == 0) {
        printf("INCORRECT OPERATION FOR THIS TYPE");
        exit(1);
    } else if (strcmp(id1.type, "FRACTION") == 0 && strcmp(id2.type, "FRACTION") == 0) {
        char* val1 = id1.value.stringValue;
        char* val2 = id2.value.stringValue;
        strcpy(result.type, "FRACTION");
        strcpy(result.value.stringValue, divFractions(val1, val2));
    } else if (strcmp(id1.type, "REAL") == 0 && strcmp(id2.type, "REAL") == 0) {
        float val1 = id1.value.floatValue;
        float val2 = id2.value.floatValue;
        strcpy(result.type, "REAL");
        result.value.floatValue = val1 / val2;
    } else {
        printf("MISMATCH TYPE ERROR");
        exit(1);
    }
    
    return result;

}

struct symbolTableEntry sqrtID(struct symbolTable SYMBOL_TABLE,  struct symbolTableEntry id1) {

    struct symbolTableEntry result;
    strcpy(result.type, "");

    if(strcmp(id1.type, "STRING") == 0 ) {
        printf("INCORRECT OPERATION FOR THIS TYPE");
        exit(1);
    } else if (strcmp(id1.type, "FRACTION") == 0) {
        printf("INCORRECT OPERATION FOR THIS TYPE");
        exit(1);
    } else if (strcmp(id1.type, "REAL") == 0 ) {
        float val1 = id1.value.floatValue;
        strcpy(result.type, "REAL");
        result.value.floatValue = sqrt(val1);
    } else {
        printf("MISMATCH TYPE ERROR");
        exit(1);
    }
    
    return result;

}

struct symbolTableEntry logID(struct symbolTable SYMBOL_TABLE,  struct symbolTableEntry id1) {

    struct symbolTableEntry result;
    strcpy(result.type, "");

    if(strcmp(id1.type, "STRING") == 0 ) {
        printf("INCORRECT OPERATION FOR THIS TYPE");
        exit(1);
    } else if (strcmp(id1.type, "FRACTION") == 0) {
        printf("INCORRECT OPERATION FOR THIS TYPE");
        exit(1);
    } else if (strcmp(id1.type, "REAL") == 0 ) {
        float val1 = id1.value.floatValue;
        strcpy(result.type, "REAL");
        result.value.floatValue = log(val1)/log(10);
    } else {
        printf("MISMATCH TYPE ERROR");
        exit(1);
    }
    
    return result;

}

struct symbolTableEntry modID(struct symbolTable SYMBOL_TABLE,  struct symbolTableEntry id1,  struct symbolTableEntry id2){

    struct symbolTableEntry result;
    strcpy(result.type, "");

    if(strcmp(id1.type, "STRING") == 0  && strcmp(id2.type, "STRING") == 0) {
        printf("INCORRECT OPERATION FOR THIS TYPE");
        exit(1);
    } else if (strcmp(id1.type, "FRACTION") == 0  && strcmp(id2.type, "FRACTION") == 0) {
        printf("INCORRECT OPERATION FOR THIS TYPE");
        exit(1);
    } else if (strcmp(id1.type, "REAL") == 0  && strcmp(id2.type, "REAL") == 0) {
        float val1 = id1.value.floatValue;
        float val2 = id2.value.floatValue;
        strcpy(result.type, "REAL");
        result.value.floatValue = (int)val1 % (int)val2;
    } else {
        printf("MISMATCH TYPE ERROR");
        exit(1);
    }
    
    return result;

}

struct symbolTableEntry powID (struct symbolTable SYMBOL_TABLE,  struct symbolTableEntry id1,  struct symbolTableEntry id2){

    struct symbolTableEntry result;
    strcpy(result.type, "");

    if(strcmp(id1.type, "STRING") == 0  && strcmp(id2.type, "STRING") == 0) {
        printf("INCORRECT OPERATION FOR THIS TYPE");
        exit(1);
    } else if (strcmp(id1.type, "FRACTION") == 0  && strcmp(id2.type, "FRACTION") == 0) {
        printf("INCORRECT OPERATION FOR THIS TYPE");
        exit(1);
    } else if (strcmp(id1.type, "REAL") == 0  && strcmp(id2.type, "REAL") == 0) {
        float val1 = id1.value.floatValue;
        float val2 = id2.value.floatValue;
        strcpy(result.type, "REAL");
        result.value.floatValue = pow(val1,val2);
    } else {
        printf("MISMATCH TYPE ERROR");
        exit(1);
    }
    
    return result;

}

bool boolID (struct symbolTable SYMBOL_TABLE,  struct symbolTableEntry id1,  struct symbolTableEntry id2, char operator){

    struct symbolTableEntry result;
    strcpy(result.type, "");

    if(strcmp(id1.type, "STRING") == 0  && strcmp(id2.type, "STRING") == 0) {
        if(operator == '=')
            return strcmp(id1.value.stringValue, id2.value.stringValue) == 0;
        else {
            printf("INCORRECT OPERATION FOR THIS TYPE");
            exit(1);
        }
    } else if (strcmp(id1.type, "FRACTION") == 0  && strcmp(id2.type, "FRACTION") == 0) {
        switch(operator) {
            case '>' :
                return booleanOfFractionsBigger(id1.value.stringValue, id2.value.stringValue);
            case '<' :
                return booleanOfFractionsSmaller(id1.value.stringValue, id2.value.stringValue);
            case '=':
                return strcmp(id1.value.stringValue, id2.value.stringValue) == 0;
            default:
                printf("INCORRECT OPERATION FOR THIS TYPE");
                exit(1);
        }        
    } else if (strcmp(id1.type, "REAL") == 0  && strcmp(id2.type, "REAL") == 0) {
        switch(operator) {
            case '>' :
                return id1.value.floatValue > id2.value.floatValue;
            case '<' :
                return id1.value.floatValue < id2.value.floatValue;
            case '=':
                return id1.value.floatValue == id2.value.floatValue;
            default:
                printf("INCORRECT OPERATION FOR THIS TYPE");
                exit(1);
        } 
    } else {
        printf("MISMATCH TYPE ERROR");
        exit(1);
    }
    
    return 0;

}