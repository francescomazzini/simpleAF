# SimpleAF
  
## Introduzione  
SimpleAF wants to be an easy, intuitive, high level programming language, perfect to start your coding experience with. It has simple and clear features, overall for people coming from a scientific field, having for example the FUNCTION types, or scientific operations like  rad(), log(), pow(), mod(), ..., and possibility to declare variables to work multiscope and intrascope, and much more.    

## Execution
To execute the interpreter : 
   
ON LINUX 
create a Makefile and insert   
```bash
all:
    flex -l regex.l;
    yacc -vd simpleAF.y;
    gcc y.tab.c -ly -lm
```
and then execute it using `make`
  
ON WINDOWS  
open CLI and use the following commands   
```bash
bison -d simpleAF.y
flex regex.l
gcc simpleAF.tab.c -o output
output
```

### Grammar & Features
SimpleAF allows to:

- perform computations inline with real numbers
- perform computations inline with strings
- perform computations inline with fractions
- declare a variable with a name and type (REAL/STRING/FRACTION) and assigning it a value or an expression of equivalent type
- for real numbers the following operations are possible: sum, subtraction, multiplication, division, square root, logarithm (base 10), modulus, pow
- for fractions the following operations are possible: sum, subtraction, multiplication and division
- for strings the following operations are possible: sum (concatenation), multiplication string times a number (n times concatenation)
- it is possible to compare these, using "==", ">", "<"
- it is possible to reassign variables values
- it is possible to assign values to variables with a condition (ternary operator)
- it is possible to declare variables of type OPEN (visible in any part of the code after their declaration) and CLOSE (as default variable, visible just in the scope, they have been declared in)
- if / if - else / while are possible
- print symbol table variables
- print a specific variable of the symbol table

## Input Examples and Outcomes
Some exmaples of some possible code, recognized by the grammar

### Example 1
```C
5 + 7  *9 - 10 : 5;
>> Value: 66.000000
```
### Example 2
```C
"aaaaa" + "bbb"*2;
>> Value: "aaaaabbbbbb"
```
### Example 3
```C
1/4 + 1/4 * 4/1 : 4/1 - 1/4;
>> Value: 1/4
```
### Example 4
```C
REAL x = 5;
FRACTION y = 1/4;
STRING z = "NormalString";
```
### Example 5
```C
rad(4) + pow(5,2) - mod(6,2) + log(100);
>> Value: 29.000000
```
### Example 6
```C
REAL num = 4 + rad(4) - 1;
STRING str = "a" + "b";
FRACTION frac = 1/4 * 8/1;
```
### Example 7
```C
REAL a = 1;
STRING b = "b";
FRACTION c = 1/2;
a = 19;
b = b * 4;
c = c - c + 1/7;
```
### Example 8
```C
REAL x = 1;
STRING y = "aaaa";
FRACTION z = 1/4;

x > 0;
>> Boolean is: "true"
y == "aaaa";
>> Boolean is: "true"
z < 1/5;
>> Boolean is: "false"
```
### Example 9
```C
REAL x = 5;
REAL y = 3;
x = (x - 7 > y - 1) ? x : y;
```
### Example 10
```C
if (3 > 2) {

if (x > y) {

y = 1 - x;

};
>> If condition is: "false"

} else {

while (x > 2) {

x = x -1;

};
>> While condition is: "true"
};
>> If condition is: "true"
```
### Example 11
```C

REAL z = 1;

if ("aa" == "bb") {

z =  3;
REAL zzzz = 10;

};
>> If condition is: "false"

z = 9;
zzzz = 11;
>> ERROR! ID zzzz not found
```
Variables follow by default the scope, which they have been declared in
### Example 12
```C
REAL z = 1;

if ("aa" == "bb") {

z =  3;
OPEN REAL zzzz = 10;

};
>> If condition is: "false"

z = 9;
zzzz = 11;
```
Variables declared of type OPEN don't follow the regular scope rule, but they are visible at any point of the program after their declaration
### Example 13
```C
REAL z = 1;
if ("aa" == "bb") {
z = ("aa" == "aa") ? 3 : 100;
CLOSE REAL zzzz = 11;
};
>> If condition is: "false"

z = (1/4 == 1/3) ? 1 : 3;
zzzz = (1 == 2) ? 1 : 2;
>> ERROR! ID zzzz not found
```
Variables declared as CLOSE follow normal scope rules
### Example 14
```C
REAL x = 34;

STRING y = "ciao";

if (x > 2) {

FRACTION z = 1/3;

OPEN REAL xy = 1;

symbtb;
>> Id: x
Type: REAL
Scope level: 1
It is an open variable: false
Value: 34.000000
>> Id: y
Type: STRING
Scope level: 1
It is an open variable: false
Value: ciao
>> Id: z
Type: FRACTION
Scope level: 2
It is an open variable: false
Value: 1/3
>> Id: xy
Type: REAL
Scope level: 2
It is an open variable: true
Value: 1.000000
```
With `symbtb` it is possible to print the entire symbol table
### Example 15
```C
STRING var = "example";

sym var;
>> Id: var
Type: STRING
Scope level: 1
It is an open variable: false
Value: example

Con sym ID si possono stampare le informazioni prese dalla symbol table di quel determinato simbolo

Esempio 16

REAL x = 15;
REAL y = 16;

if( x + y > 30) {

x = (x  == y) ? 1 : 0;

OPEN FRACTION frac = 1/4;
STRING z = "bad";

} else {

x = 1 : 5;

STRING z = "ok";
frac = 1/6;

if( frac == 1/6) {

z = "yes";

};
>> If condition is: "true"

};
>> If condition is: "true"

STRING str = "end";

symbtb;
>> Id: x
Type: REAL
Scope level: 1
It is an open variable: false
Value: 0.200000
>> Id: y
Type: REAL
Scope level: 1
It is an open variable: false
Value: 16.000000
>> Id: frac
Type: FRACTION
Scope level: 2
It is an open variable: true
Value: 1/6
>> Id: str
Type: STRING
Scope level: 1
It is an open variable: false
Value: end

end
```
