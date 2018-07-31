



```
grammar TruthSerum;

OPERATION ::= "and" | "or"
TERM ::= PREFIX "term" | "term" "colon" "term" | "term"
PREFIX ::= "-" | "+"

S := TERM | TERM OPERATION S
``` 
