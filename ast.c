#include "parser.tab.h"
#include "ast.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

// Symbolická tabulka (implementace)
#define MAX_VARS 100
Variable varTable[MAX_VARS];
int varCount = 0;

void setVariable(const char* name, int value) {
    for (int i = 0; i < varCount; i++) {
        if (strcmp(varTable[i].name, name) == 0) {
            varTable[i].value = value;
            return;
        }
    }
    varTable[varCount].name = strdup(name);
    varTable[varCount].value = value;
    varCount++;
}

int getVariable(const char* name) {
    for (int i = 0; i < varCount; i++) {
        if (strcmp(varTable[i].name, name) == 0)
            return varTable[i].value;
    }
    fprintf(stderr, "Neznámá proměnná: %s\n", name);
    return 0;
}

// Globální proměnná pro kořen AST (definice)
Node* rootAST = NULL;

// Implementace funkcí pro vytváření uzlů AST
Node* createNode(NodeType type) {
    Node* node = (Node*)malloc(sizeof(Node));
    if (!node) {
        perror("Nedostatek paměti");
        exit(EXIT_FAILURE);
    }
    node->type = type;
    return node;
}

Node* createBinaryOpNode(int op, Node* left, Node* right) {
    Node* node = createNode(N_BINARY_OP);
    node->data.binaryOp.operator = op;
    node->data.binaryOp.left = left;
    node->data.binaryOp.right = right;
    return node;
}

Node* createUnaryOpNode(int op, Node* operand) {
    Node* node = createNode(N_UNARY_OP);
    node->data.unaryOp.operator = op;
    node->data.unaryOp.operand = operand;
    return node;
}

Node* createIdentifierNode(char* name) {
    Node* node = createNode(N_IDENTIFIER);
    node->data.identifier.name = strdup(name);
    return node;
}

Node* createIntLiteralNode(int value) {
    Node* node = createNode(N_INTEGER_LITERAL);
    node->data.intValue = value;
    return node;
}

Node* createBoolLiteralNode(int value) {
    Node* node = createNode(N_BOOLEAN_LITERAL);
    node->data.boolValue = value;
    return node;
}

Node* createStringLiteralNode(char* value) {
    Node* node = createNode(N_STRING_LITERAL);
    node->data.stringValue = strdup(value);
    return node;
}

Node* createCharLiteralNode(char value) {
    Node* node = createNode(N_CHAR_LITERAL);
    node->data.charValue = value;
    return node;
}

Node* createVarDeclNode(char* name, Node* expression) {
    Node* node = createNode(N_VAR_DECL);
    node->data.varDecl.name = strdup(name);
    node->data.varDecl.expression = expression;
    return node;
}

Node* createAssignNode(char* name, Node* expression) {
    Node* node = createNode(N_ASSIGN);
    node->data.assign.name = strdup(name);
    node->data.assign.expression = expression;
    return node;
}

Node* createIfNode(Node* condition, Node* body) {
    Node* node = createNode(N_IF);
    node->data.ifStmt.condition = condition;
    node->data.ifStmt.body = body;
    return node;
}

Node* createWhileNode(Node* condition, Node* body) {
    Node* node = createNode(N_WHILE);
    node->data.whileStmt.condition = condition;
    node->data.whileStmt.body = body;
    return node;
}

Node* createPrintStringNode(Node* expression) {
    Node* node = createNode(N_PRINT_STRING);
    node->data.printString.expression = expression;
    return node;
}

Node* createPrintIdNode(Node* identifier) {
    Node* node = createNode(N_PRINT_ID);
    node->data.printId.identifier = identifier;
    return node;
}

Node* createStatementsListNode(Node* statement, Node* next) {
    Node* node = createNode(N_STATEMENTS);
    node->data.statementsList.statement = statement;
    node->data.statementsList.next = next;
    return node;
}

void freeASTNode(Node* node) {
    if (node == NULL) return;
    switch (node->type) {
        case N_IDENTIFIER:
            free(node->data.identifier.name);
            break;
        case N_STRING_LITERAL:
            free(node->data.stringValue);
            break;
        case N_VAR_DECL:
            free(node->data.varDecl.name);
            freeASTNode(node->data.varDecl.expression);
            break;
        case N_ASSIGN:
            free(node->data.assign.name);
            freeASTNode(node->data.assign.expression);
            break;
        case N_BINARY_OP:
            freeASTNode(node->data.binaryOp.left);
            freeASTNode(node->data.binaryOp.right);
            break;
        case N_UNARY_OP:
            freeASTNode(node->data.unaryOp.operand);
            break;
        case N_IF:
            freeASTNode(node->data.ifStmt.condition);
            freeASTNode(node->data.ifStmt.body);
            break;
        case N_WHILE:
            freeASTNode(node->data.whileStmt.condition);