#ifndef AST_H
#define AST_H

// Přepiš definice z parser.y
typedef enum {
    N_PROGRAM,
    N_STATEMENTS,
    N_VAR_DECL,
    N_ASSIGN,
    N_PRINT_STRING,
    N_PRINT_ID,
    N_IF,
    N_WHILE,
    N_BINARY_OP,
    N_UNARY_OP,
    N_IDENTIFIER,
    N_INTEGER_LITERAL,
    N_BOOLEAN_LITERAL,
    N_STRING_LITERAL,
    N_CHAR_LITERAL,
    N_HEX_LITERAL
} NodeType;

typedef struct Node {
    NodeType type;
    union {
        struct { struct Node* left; struct Node* right; int operator; } binaryOp;
        struct { struct Node* operand; int operator; } unaryOp;
        struct { char* name; } identifier;
        int intValue;
        int boolValue;
        char* stringValue;
        char charValue;
        struct { char* name; struct Node* expression; } varDecl;
        struct { char* name; struct Node* expression; } assign;
        struct { struct Node* condition; struct Node* body; } ifStmt;
        struct { struct Node* condition; struct Node* body; } whileStmt;
        struct { struct Node* expression; } printString;
        struct { struct Node* identifier; } printId;
        struct { struct Node* statement; struct Node* next; } statementsList;
    } data;
} Node;

typedef struct {
    char* name;
    int value;
} Variable;

// Deklarace globální proměnné pro kořen AST
extern Node* rootAST;

// Deklarace funkcí pro AST (prototypy)
Node* createNode(NodeType type);
Node* createBinaryOpNode(int op, Node* left, Node* right);
Node* createUnaryOpNode(int op, Node* operand);
Node* createIdentifierNode(char* name);
Node* createIntLiteralNode(int value);
Node* createBoolLiteralNode(int value);
Node* createStringLiteralNode(char* value);
Node* createCharLiteralNode(char value);
Node* createVarDeclNode(char* name, Node* expression);
Node* createAssignNode(char* name, Node* expression);
Node* createIfNode(Node* condition, Node* body);
Node* createWhileNode(Node* condition, Node* body);
Node* createPrintStringNode(Node* expression);
Node* createPrintIdNode(Node* identifier);
Node* createStatementsListNode(Node* statement, Node* next);
void freeAST(Node* node);
void interpretAST(Node* node);
int evaluateExpression(Node* node);
void interpretStatements(Node* statements);

#endif // AST_H