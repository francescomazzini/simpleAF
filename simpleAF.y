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
    if(!strcmp(s, "") == 0)
        fprintf(stderr, ">> %s\n", s);
    else
        fprintf(stderr, ">> SYNTAX ERROR\n");
    exit(1);
}

int yylex(void);

 union Value
    {
        float floatValue;
        char stringValue[NAME_MAX];
    };


/**
* An entry of the symbol table.
* -> id - name of the variable
* -> type - name of the type of the variable
* -> value - actual value contained by the variable
* -> scope_level - indicates the int level of the scope (1 is the lowest)
* -> next - pointer of the next node in the linked list
*/
struct symbolTableEntry {
    char id[NAME_MAX];
    char type[NAME_MAX];

    union Value value;

    int scope_level;

    bool is_open;

    struct symbolTableEntry* next;
};

/**
* Symbol table
*/
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

struct symbolTableEntry* createFirstEntryTable(char* id, void* value, char* type, bool is_open);
void createSymbolTable(struct symbolTable *table);
void addEntryTable(struct symbolTableEntry* list,char* id, void* value, char* type, bool is_open);
void addSymbolTable(struct symbolTable* table,char* id, void* value, char* type, bool is_open);
void printSingleSymbolTableEntry(struct symbolTableEntry* symbol);
void printSymbolTableEntry (struct symbolTable* symbol);
struct symbolTableEntry* lookUp(struct symbolTableEntry* symbol, char* id);
struct symbolTableEntry* lookUpTable(struct symbolTable* table, char* id);

void addWithTypeChecking(struct symbolTable SYMBOL_TABLE, char* supposedType, struct symbolTableEntry value,char* id, bool is_open);
void updateValueWithTypeChecking (struct symbolTable SYMBOL_TABLE,char* id,  struct symbolTableEntry value);
void removeBasedOnScopeLevel(struct symbolTable SYMBOL_TABLE, int scopeLevelToRemove);
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

/**
* Starting delcarations of symbol table and global scope level
*/
struct symbolTable SYMBOL_TABLE;
int GLOBAL_SCOPE_LEVEL = 1;
 
%}


%union {
       char* lexeme;			        //name of an identifier
       float value;			            //attribute of a token of type REAL
       bool boolean;                    //attribute of a to boolean
       struct symbolTableEntry id;      //attribute for general expressions
       }

%type <id> exprGeneral
%type <boolean> exprBool

%token END
%token SYMBTB
%token SYM
%token OPEN
%token CLOSE
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
%token ELSE
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

//program is composed of more lines, each of which has to finish with the semicolon, unless they are just new lines
prog  : line  ';' '\n' prog
        | line ';' '\n'
        | '\n' prog
        | '\n'
      ;

//each line is a statement and there are different things that can be executed 
line  :  END  '\n'       {exit(0);}                                                         //end of the program
      | SYMBTB          { printSymbolTableEntry(&SYMBOL_TABLE); }                           //print the symbol table
      | SYM ID          { 
                            struct symbolTableEntry* entry = lookUpTable(&SYMBOL_TABLE, $2);
                            if(entry == NULL) {
                                printf(">> ERROR! ID %s not found\n", $2);
                                exit(1);
                            }
                             printSingleSymbolTableEntry(entry); 
                        }    //print the symbol table entry of a specific ID

    //it represents a general expression of any type
      | exprGeneral         {                                                               
                                if(strcmp($1.type, "STRING") == 0)
                                    printf(">> Value: \"%s\"\n", $1.value.stringValue);
                                else if (strcmp($1.type, "FRACTION") == 0)
                                    printf(">> Value: %s\n", $1.value.stringValue);
                                else if (strcmp($1.type, "REAL") == 0) {
                                    printf(">> Value: %f\n", $1.value.floatValue);
                                }
                            }
    //declaration of an ID as OPEN variable
      | OPEN TYPE ID '=' exprGeneral { 
                                 addWithTypeChecking(SYMBOL_TABLE,$2,$5,$3,true);
                             }
    //declaration of an ID as CLOSE variable
      | CLOSE TYPE ID '=' exprGeneral { 
                                 addWithTypeChecking(SYMBOL_TABLE,$2,$5,$3,false);
                             }
    //declaration of an ID, implicitly OPEN variable
      | TYPE ID '=' exprGeneral { 
                                addWithTypeChecking(SYMBOL_TABLE,$1,$4,$2,false);
                            }
    //reassigning a value to an ID
      | ID '=' exprGeneral  { 
                            updateValueWithTypeChecking(SYMBOL_TABLE, $1, $3);
                        }
    //reassigning a value to an ID based on a bool condition
      | ID '=' '(' exprBool ')' '?' exprGeneral ':' exprGeneral {   
                        if($4 == 1){
                            updateValueWithTypeChecking(SYMBOL_TABLE, $1, $7);
                        } else { 
                            updateValueWithTypeChecking(SYMBOL_TABLE, $1, $9);
                        }
                    }
      | BOOLEAN {printf(">> Boolean recognized\n"); exit(0);}
    //boolean expression
      | exprBool {printf(">> Boolean is: \"%s\"\n", $1 ? "true" : "false");} 
      | IF  '(' exprBool ')' '{' { GLOBAL_SCOPE_LEVEL = GLOBAL_SCOPE_LEVEL + 1; }  '\n' 
        prog  elseStatement              { printf(">> If condition is: \"%s\"\n", $3 ? "true" : "false");} 

      | WHILE '(' exprBool ')' '{'  { GLOBAL_SCOPE_LEVEL = GLOBAL_SCOPE_LEVEL + 1; } '\n' 
        prog '}'                      { removeBasedOnScopeLevel(SYMBOL_TABLE, GLOBAL_SCOPE_LEVEL); GLOBAL_SCOPE_LEVEL = GLOBAL_SCOPE_LEVEL - 1; printf(">> While condition is: \"%s\"\n", $3 ? "true" : "false");}      
      ;

    //it was done with a separate statement because since there was code already at the opening of the first curly bracket,
    // then it was needed to make him know immediately which of the two productions (if then or if else) it has to choose. 
    //Since this was not possible, because even giving priority to the else, than it would have chose that production much before than knowing
    //if there was an else or not, therefore we had to separate the possibility of the else production in a separate one
    elseStatement :  
        '}' { removeBasedOnScopeLevel(SYMBOL_TABLE, GLOBAL_SCOPE_LEVEL); } ELSE '{' '\n' {  }  
        prog '}'  { removeBasedOnScopeLevel(SYMBOL_TABLE, GLOBAL_SCOPE_LEVEL); GLOBAL_SCOPE_LEVEL = GLOBAL_SCOPE_LEVEL - 1;}
        | '}' { removeBasedOnScopeLevel(SYMBOL_TABLE, GLOBAL_SCOPE_LEVEL); GLOBAL_SCOPE_LEVEL = GLOBAL_SCOPE_LEVEL - 1; } 
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


// - - - - - - - - - - - - - - - - BASIC UTILS - - - - - - - - - - - - - - - - 

// Function to compute the Greater Common divisor of two numbers
int gcd(int a, int b) {
    if (b == 0)
        return a;
    else
        return gcd(b, a % b);
}

// Function to compute the Least Common Multiplier between two numbers
int lcm(int a, int b) {
    int gcd_result = gcd(a, b);
    return (a * b) / gcd_result;
}

// Function to find the first int number in a string
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
            printf(">> Invalid character '%c'. Ignoring.\n", str[i]);
        }
    }

    return number;
}

// Function to find the last int number in a string
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
            printf(">> Invalid character '%c'. Ignoring.\n", str[i]);
        }
    }

    return number;
}

// Function to convert the numbers to string
char* numbersToString(int number1, int number2) {
    // Determine the required size
    int size = snprintf(NULL, 0, "%d %d", number1, number2);

    // Allocate memory for the string
    char* str = (char*)malloc((size + 1) * sizeof(char));
    if (str == NULL) {
        printf(">> Memory allocation failed.\n");
        return NULL;
    }

    // Convert the numbers to string
    snprintf(str, size + 1, "%d/%d", number1, number2);

    return str;
}

// Function to simplify a fraction (ex: 2/4 -> 1/2)
char* simplifyFraction(int numerator, int denominator) {
    int commonDivisor = gcd(numerator, denominator);

    // Divide both numerator and denominator by the common divisor
    numerator /= commonDivisor;
    denominator /= commonDivisor;

  
    return numbersToString(numerator,denominator);
}

// Function to convert the string to a float
float convertStringToFloat(char* a){
    int c = stringToNumberStart(a);
    int b = stringToNumberEnd(a);

    return (float)(c/b);
}

// Function for computing the sum of two fractions
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

// Function for computing the subtraction of two fractions
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

// Function for computing the multiplication of two fractions
char* mulFractions(char* a, char* b){
     int numA = stringToNumberStart(a);
     int denA =stringToNumberEnd(a);
     int numB = stringToNumberStart(b);
     int denB = stringToNumberEnd(b);

     int newNum = numA * numB;
     int newDen = denA * denB;

     return simplifyFraction(newNum,newDen);
}

// Function for computing the division of two fractions
char* divFractions(char* a, char* b){
     int numA = stringToNumberStart(a);
     int denA =stringToNumberEnd(a);
     int numB = stringToNumberStart(b);
     int denB = stringToNumberEnd(b);

     int newNum = numA * denB;
     int newDen = denA * numB;

     return simplifyFraction(newNum,newDen);
}

// Function to compute the concatenation of two strings
char* concatenateStrings(const char* str1, const char* str2) {
    size_t len1 = strlen(str1);
    size_t len2 = strlen(str2);
    
    // Allocate memory for the concatenated string
    char* result = (char*)malloc((len1 + len2 + 1) * sizeof(char));
    
    // Check if memory allocation was successful
    if (result == NULL) {
        printf(">> Memory allocation failed.\n");
        return NULL;
    }
    
    // Copy str1 to the result string
    strcpy(result, str1);
    
    // Concatenate str2 to the result string
    strcat(result, str2);
    
    return result;
}

// Function for computing the multiplication of a string with a number, such that it's appended n times
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

// Function for comparing two functions, if the first is greater than the second
bool booleanOfFractionsBigger(char* a, char* b){
    int numA = stringToNumberStart(a);
    int denA = stringToNumberEnd(a);
    int numB = stringToNumberStart(b);
    int denB =stringToNumberEnd(b);

    float numberA = (float)numA/denA;
   
    float numberB = (float)numB / denB;
 
    return numberA>numberB;
}

// Function for comparing two functions, if the first is smaller than the second
bool booleanOfFractionsSmaller(char* a, char* b){
    int numA = stringToNumberStart(a);
    int denA = stringToNumberEnd(a);
    int numB = stringToNumberStart(b);
    int denB =stringToNumberEnd(b);

    float numberA = (float)numA/denA;
   
    float numberB = (float)numB / denB;

    return numberA<numberB;
}



// - - - - - - - - - - - - - - - - SYMBOL TABLE FUNCTIONS - - - - - - - - - - - - - - - - 

// Function for creating the first element of the symbol table although this method is also exploited for 
// creating the next ones
struct symbolTableEntry* createFirstEntryTable(char* id, void* value, char* type, bool is_open) {
  struct symbolTableEntry *first = (struct symbolTableEntry*) malloc(sizeof(struct symbolTableEntry));
	
  first->next=NULL;
  strcpy(first->id, id);
  first->scope_level = GLOBAL_SCOPE_LEVEL;
  first->is_open = is_open;
 

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
    yyerror("TYPE ERROR");
  }

strcpy(first->type, type);
return first;
}

// Function for creating the symbol table
void createSymbolTable(struct symbolTable *table){

  char* charValue = "first";
  table->head = createFirstEntryTable("",(void*)charValue,"STRING", false);
  table->countSymbol = 0;


}

// Function for adding new entry to the symbol table
void addEntryTable(struct symbolTableEntry* list,char* id, void* value, char* type, bool is_open) {

 struct symbolTableEntry *last = list;

  while(last->next != NULL) {
    if (strcmp(last->id, id)==0)
    {
      printf(">> already existing id \n");
      return;

    }
    
    last = last->next;
  }


  last->next = createFirstEntryTable(id,value,type, is_open);  
}

// Function for adding a new enty to the symbol table from the most external level
void addSymbolTable(struct symbolTable* table,char* id, void* value, char* type, bool is_open){
    
  addEntryTable(table->head,id,value,type,is_open);
  table->countSymbol++;

}

// Function for printing a symbol table entry
void printSingleSymbolTableEntry(struct symbolTableEntry* symbol){
    printf(">> Id: %s\n", symbol->id);
  printf("Type: %s\n", symbol->type);
  printf("Scope level: %d\n", symbol->scope_level);
  printf("It is an open variable: %s\n", symbol->is_open ? "true" : "false");
  if(strcmp(symbol->type, "REAL")==0){
      printf("Value: %f\n", symbol->value.floatValue);
  }else if(strcmp(symbol->type, "STRING")==0){
   printf("Value: %s\n", symbol->value.stringValue);
  }else if (strcmp(symbol->type, "FRACTION")==0){
   printf("Value: %s\n", symbol->value.stringValue);

  }else{
    yyerror("TYPE ERROR");
  }  
}

// Function for printing the entire symbol table 
void printSymbolTableEntry (struct symbolTable* symbol) {

struct symbolTableEntry *iterator = symbol->head->next; //the first element is skipped because is empty and set by the language at the beginning
 
  while(iterator != NULL){

  printSingleSymbolTableEntry(iterator);
  iterator = iterator->next;
  
  }

}

// Function for making a look up in the symbol table to get a specific entry
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

// Function for making a look up in the symbol table to get a specific entry from the most external level
struct symbolTableEntry* lookUpTable(struct symbolTable* table, char* id){
  return lookUp(table->head,id);
}

// Function for adding a new entry in the symbol table but with TYPE CHECK
void addWithTypeChecking(struct symbolTable SYMBOL_TABLE, char* supposedType, struct symbolTableEntry value,char* id, bool is_open){

    if(strcmp(value.type, supposedType) != 0) {
        yyerror("ERROR TYPE");
    } else {

        struct symbolTableEntry* entry = lookUpTable(&SYMBOL_TABLE, id);

        if(entry != NULL) {

            printf(">> ERROR! ID %s is already declared\n", id);
            exit(1);
        
        } else {
            if(strcmp(value.type, "STRING") == 0 || strcmp(value.type, "FRACTION") == 0) {
                addSymbolTable(&SYMBOL_TABLE, id, (void*)value.value.stringValue, value.type, is_open);
            } else if (strcmp(value.type, "REAL") == 0 ) {
                addSymbolTable(&SYMBOL_TABLE, id, (void*)&value.value.floatValue, value.type, is_open);
            }
        }

    } 

}

// Function for updating an entry value in the symbol table with TYPE CHECK
void updateValueWithTypeChecking (struct symbolTable SYMBOL_TABLE,char* id,  struct symbolTableEntry value) {

    struct symbolTableEntry* entry = lookUpTable(&SYMBOL_TABLE, id);

    if(entry == NULL) {
        printf(">> ERROR! ID %s not found\n", id);
        exit(1);
    }
    
    if(strcmp(entry->type, value.type) != 0) {
        yyerror("TYPE ERROR");
    }

    if(strcmp(value.type, "REAL")==0){
      entry->value.floatValue = value.value.floatValue;
    }else if(strcmp(value.type, "STRING")==0 || strcmp(value.type, "FRACTION")==0){
        strncpy(entry->value.stringValue, (char*)value.value.stringValue,NAME_MAX-1);
        entry->value.stringValue[NAME_MAX-1]='\0';
    }else{
        yyerror("TYPE ERROR");
    }

}

// Function for removing entries of the symbol table that have a certain scope level but that are not of type OPEN
void removeBasedOnScopeLevel(struct symbolTable SYMBOL_TABLE, int scopeLevelToRemove){

    struct symbolTableEntry *dummy = (struct symbolTableEntry*) malloc(sizeof(struct symbolTableEntry));

    dummy->next=SYMBOL_TABLE.head;

    struct symbolTableEntry *last = dummy;
        

    if (last->next != NULL) {

        while(last->next != NULL) {

            if (last->next->scope_level == scopeLevelToRemove && !last->next->is_open) {
                struct symbolTableEntry *temp = last->next;
                last->next = last->next->next;
                free(temp);
            } else {
                last = last->next;
            }
        }

        SYMBOL_TABLE.head = dummy->next;
        free(dummy);
    }

} 

// Function for getting a value from the symbol table with TYPE CHECK
void* getValueWithTypeChecking (struct symbolTable SYMBOL_TABLE,char* id, char* actualType) {

    struct symbolTableEntry* entry = lookUpTable(&SYMBOL_TABLE, id);

    if(entry == NULL) {
        printf(">> ERROR! ID %s not found\n", id);
        exit(1);
    }
    
    if(strcmp(entry->type, actualType) != 0) {
        yyerror("TYPE ERROR");
    }

    if(strcmp(actualType, "REAL")==0){
        return (void*)&(entry->value.floatValue);
    }else if(strcmp(actualType, "STRING")==0){
        return (void*)&(entry->value.stringValue);
    }else if (strcmp(actualType, "FRACTION")==0){
        return (void*)&(entry->value.stringValue);
    }else{
        yyerror("TYPE ERROR");
    }

    return NULL;

}

// Function for getting a value from the symbol table WITHOUT TYPE CHECK
void* getValueWithoutTypeChecking (struct symbolTable SYMBOL_TABLE,char* id) {

    struct symbolTableEntry* entry = lookUpTable(&SYMBOL_TABLE, id);

    if(entry == NULL) {
        printf(">> ERROR! ID %s not found\n", id);
        exit(1);
    }

    if(strcmp(entry->type, "REAL")==0){
        return (void*)&(entry->value.floatValue);
    }else if(strcmp(entry->type, "STRING")==0){
        return (void*)&(entry->value.stringValue);
    }else if (strcmp(entry->type, "FRACTION")==0){
        return (void*)&(entry->value.stringValue);
    }else{
        yyerror("TYPE ERROR");
    }

    return NULL;

}

// Function for getting the type of an entry in the symbol table
char* getValueType ( struct symbolTable SYMBOL_TABLE,char* id ) {

    struct symbolTableEntry* entry = lookUpTable(&SYMBOL_TABLE, id);

    return entry->type;

}

// - - - - - - - - - - - - - - - - EXPRESSION COMPUTATIONS UTILS - - - - - - - - - - - - - - - - 

// Function for copying info of an entry in the symbol table and pasting them to a similar struct passed as a pointer
void copyIDFromName (struct symbolTable SYMBOL_TABLE, struct symbolTableEntry* id1, char* id2 ) {

    strcpy(id1->type, getValueType(SYMBOL_TABLE, id2));
    if(strcmp(id1->type, "STRING") == 0 || strcmp(id1->type, "FRACTION") == 0)
        strcpy(id1->value.stringValue, getValueWithoutTypeChecking(SYMBOL_TABLE, id2));
    else if (strcmp(id1->type, "REAL") == 0) {
        float* floatValue = getValueWithoutTypeChecking(SYMBOL_TABLE, id2);
        id1->value.floatValue = *floatValue;
    }

}

// Function for converting the info a FRACTION to the struct of a symbol table entry, filling just the value and type
void copyIDFromFraction (struct symbolTable SYMBOL_TABLE, struct symbolTableEntry* id1, char* id2 ) {

    strcpy(id1->type, "FRACTION");

    if(stringToNumberEnd(id2) == 0)
        yyerror("A FRACTION WITH DENUMERATOR EQUAL TO 0 IS NOT POSSIBLE");

    strcpy(id1->value.stringValue, id2);

}

// Function for converting the info a FLOAT to the struct of a symbol table entry, filling just the value and type
void copyIDFromFloat (struct symbolTable SYMBOL_TABLE, struct symbolTableEntry* id1, float id2 ) {

    strcpy(id1->type, "REAL");
    id1->value.floatValue = id2;

}

// Function for converting the info a STRING to the struct of a symbol table entry, filling just the value and type
void copyIDFromString (struct symbolTable SYMBOL_TABLE, struct symbolTableEntry* id1, char* id2 ) {

    strcpy(id1->type, "STRING");
    strcpy(id1->value.stringValue, id2);

}

// Function for copying info of a symboltable entry struct to another symboltable entry struct
void copyID (struct symbolTable SYMBOL_TABLE, struct symbolTableEntry* id1, struct symbolTableEntry id2 ) {

    strcpy(id1->type, id2.type);
    if(strcmp(id1->type, "STRING") == 0 || strcmp(id1->type, "FRACTION") == 0)
        strcpy(id1->value.stringValue, id2.value.stringValue);
    else if (strcmp(id1->type, "REAL") == 0) {
        float floatValue = id2.value.floatValue;
        id1->value.floatValue = floatValue;
    }

}

// Function for doing the sum of two symboltable entry struct regardless of whether they come from the symbol table or not and
// regardless of their type
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
        yyerror("MISMATCH TYPE ERROR");
    }
    
    return result;

}

// Function for doing the subtraction of two symboltable entry struct regardless of whether they come from the symbol table or not and
// regardless of their type
struct symbolTableEntry subID (struct symbolTable SYMBOL_TABLE,  struct symbolTableEntry id1,  struct symbolTableEntry id2) {

    struct symbolTableEntry result;
    strcpy(result.type, "");

    if(strcmp(id1.type, "STRING") == 0 && strcmp(id2.type, "STRING") == 0) {
        yyerror("INCORRECT OPERATION FOR THIS TYPE");
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
        yyerror("MISMATCH TYPE ERROR");
    }
    
    return result;

}

// Function for doing the multiplication of two symboltable entry struct regardless of whether they come from the symbol table or not and
// regardless of their type
struct symbolTableEntry mulID (struct symbolTable SYMBOL_TABLE,  struct symbolTableEntry id1,  struct symbolTableEntry id2) {

    struct symbolTableEntry result;
    strcpy(result.type, "");

    if(strcmp(id1.type, "STRING") == 0 && strcmp(id2.type, "STRING") == 0) {
        yyerror("INCORRECT OPERATION FOR THIS TYPE");
    } else if (strcmp(id1.type, "FRACTION") == 0 && strcmp(id2.type, "FRACTION") == 0) {
        char* val1 = id1.value.stringValue;
        char* val2 = id2.value.stringValue;
        strcpy(result.type, "FRACTION");
        strcpy(result.value.stringValue, mulFractions(val1,val2));
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
        yyerror("MISMATCH TYPE ERROR");
    }
    
    return result;

}

// Function for doing the division of two symboltable entry struct regardless of whether they come from the symbol table or not and
// regardless of their type
struct symbolTableEntry divID (struct symbolTable SYMBOL_TABLE,  struct symbolTableEntry id1,  struct symbolTableEntry id2) {

    struct symbolTableEntry result;
    strcpy(result.type, "");

    if(strcmp(id1.type, "STRING") == 0 && strcmp(id2.type, "STRING") == 0) {
        yyerror("INCORRECT OPERATION FOR THIS TYPE");
    } else if (strcmp(id1.type, "FRACTION") == 0 && strcmp(id2.type, "FRACTION") == 0) {
        char* val1 = id1.value.stringValue;
        char* val2 = id2.value.stringValue;
        strcpy(result.type, "FRACTION");
        strcpy(result.value.stringValue, divFractions(val1, val2));
    } else if (strcmp(id1.type, "REAL") == 0 && strcmp(id2.type, "REAL") == 0) {
        float val1 = id1.value.floatValue;
        float val2 = id2.value.floatValue;

        if(val2 == 0)
            yyerror("DIVISION BY 0 IS NOT POSSIBLE");

        strcpy(result.type, "REAL");
        result.value.floatValue = val1 / val2;
    } else {
        yyerror("MISMATCH TYPE ERROR");
    }
    
    return result;

}

// Function for doing the square root of a symboltable entry struct regardless of whether they come from the symbol table or not and
// regardless of their type
struct symbolTableEntry sqrtID(struct symbolTable SYMBOL_TABLE,  struct symbolTableEntry id1) {

    struct symbolTableEntry result;
    strcpy(result.type, "");

    if(strcmp(id1.type, "STRING") == 0 ) {
        yyerror("INCORRECT OPERATION FOR THIS TYPE");
    } else if (strcmp(id1.type, "FRACTION") == 0) {
        yyerror("INCORRECT OPERATION FOR THIS TYPE");
    } else if (strcmp(id1.type, "REAL") == 0 ) {
        float val1 = id1.value.floatValue;
        strcpy(result.type, "REAL");
        result.value.floatValue = sqrt(val1);
    } else {
        yyerror("MISMATCH TYPE ERROR");
    }
    
    return result;

}

// Function for doing the logarithm of a symboltable entry struct regardless of whether they come from the symbol table or not and
// regardless of their type
struct symbolTableEntry logID(struct symbolTable SYMBOL_TABLE,  struct symbolTableEntry id1) {

    struct symbolTableEntry result;
    strcpy(result.type, "");

    if(strcmp(id1.type, "STRING") == 0 ) {
        yyerror("INCORRECT OPERATION FOR THIS TYPE");
    } else if (strcmp(id1.type, "FRACTION") == 0) {
        yyerror("INCORRECT OPERATION FOR THIS TYPE");
    } else if (strcmp(id1.type, "REAL") == 0 ) {
        float val1 = id1.value.floatValue;
        strcpy(result.type, "REAL");
        result.value.floatValue = log(val1)/log(10);
    } else {
        yyerror("MISMATCH TYPE ERROR");
    }
    
    return result;

}

// Function for doing the modulus of a symboltable entry struct regardless of whether they come from the symbol table or not and
// regardless of their type
struct symbolTableEntry modID(struct symbolTable SYMBOL_TABLE,  struct symbolTableEntry id1,  struct symbolTableEntry id2){

    struct symbolTableEntry result;
    strcpy(result.type, "");

    if(strcmp(id1.type, "STRING") == 0  && strcmp(id2.type, "STRING") == 0) {
        yyerror("INCORRECT OPERATION FOR THIS TYPE");
    } else if (strcmp(id1.type, "FRACTION") == 0  && strcmp(id2.type, "FRACTION") == 0) {
        yyerror("INCORRECT OPERATION FOR THIS TYPE");
    } else if (strcmp(id1.type, "REAL") == 0  && strcmp(id2.type, "REAL") == 0) {
        float val1 = id1.value.floatValue;
        float val2 = id2.value.floatValue;
        strcpy(result.type, "REAL");
        result.value.floatValue = (int)val1 % (int)val2;
    } else {
        yyerror("MISMATCH TYPE ERROR");
    }
    
    return result;

}

// Function for doing the pow of a symboltable entry struct regardless of whether they come from the symbol table or not and
// regardless of their type
struct symbolTableEntry powID (struct symbolTable SYMBOL_TABLE,  struct symbolTableEntry id1,  struct symbolTableEntry id2){

    struct symbolTableEntry result;
    strcpy(result.type, "");

    if(strcmp(id1.type, "STRING") == 0  && strcmp(id2.type, "STRING") == 0) {
        yyerror("INCORRECT OPERATION FOR THIS TYPE");
    } else if (strcmp(id1.type, "FRACTION") == 0  && strcmp(id2.type, "FRACTION") == 0) {
        yyerror("INCORRECT OPERATION FOR THIS TYPE");
    } else if (strcmp(id1.type, "REAL") == 0  && strcmp(id2.type, "REAL") == 0) {
        float val1 = id1.value.floatValue;
        float val2 = id2.value.floatValue;
        strcpy(result.type, "REAL");
        result.value.floatValue = pow(val1,val2);
    } else {
        yyerror("MISMATCH TYPE ERROR");
    }
    
    return result;

}

// Function for evaluating boolean expressions, passing also the type of comparison: >, <, =
bool boolID (struct symbolTable SYMBOL_TABLE,  struct symbolTableEntry id1,  struct symbolTableEntry id2, char operator){

    struct symbolTableEntry result;
    strcpy(result.type, "");

    if(strcmp(id1.type, "STRING") == 0  && strcmp(id2.type, "STRING") == 0) {
        if(operator == '=')
            return strcmp(id1.value.stringValue, id2.value.stringValue) == 0;
        else {
            yyerror("INCORRECT OPERATION FOR THIS TYPE");
        }
    } else if (strcmp(id1.type, "FRACTION") == 0  && strcmp(id2.type, "FRACTION") == 0) {
        switch(operator) {
            case '>' :
                return booleanOfFractionsBigger(id1.value.stringValue, id2.value.stringValue);
            case '<' :
                return booleanOfFractionsSmaller(id1.value.stringValue, id2.value.stringValue);
            case '=':
                return strcmp(simplifyFraction( stringToNumberStart( id1.value.stringValue), stringToNumberEnd(id1.value.stringValue)), simplifyFraction( stringToNumberStart( id2.value.stringValue), stringToNumberEnd(id2.value.stringValue))) == 0;
            default:
                yyerror("INCORRECT OPERATION FOR THIS TYPE");
        }        
    } else if (strcmp(id1.type, "REAL") == 0  && strcmp(id2.type, "REAL") == 0) {
        switch(operator) {
            case '>' :
                return id1.value.floatValue > id2.value.floatValue;
            case '<' :
                return id1.value.floatValue < id2.value.floatValue;
            case '=':
                return (fabs(id1.value.floatValue - id2.value.floatValue)) < 0.0001;
            default:
                yyerror("INCORRECT OPERATION FOR THIS TYPE");
        } 
    } else {
        yyerror("MISMATCH TYPE ERROR");
    }
    
    return 0;

}