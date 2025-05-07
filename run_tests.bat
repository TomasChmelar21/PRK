@echo off
REM Kompilace lexeru a parseru
flex lexer.l
bison -d parser.y
gcc lex.yy.c parser.tab.c -o parser.exe

REM Spuštění parseru s testovacím souborem
echo Spouštím test...
parser.exe < test_input.txt
