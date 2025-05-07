# Název cílového programu (vnořený do složky songton)
TARGET_DIR = songton
TARGET = $(TARGET_DIR)/mujprogram.exe  # Přípona .exe pro Windows
TARGET_ROOT = mujprogram.exe  # Cíl v základní složce

# Soubor pro bison (parser)
PARSER = parser.y

# Soubor pro flex (lexer)
LEXER = lexer.l

# Cíl pro kompilaci
all: $(TARGET) $(TARGET_ROOT)  # Generuje oba soubory

# Pravidlo pro spuštění Bison a Flex, následně kompilace
$(TARGET): $(LEXER) $(PARSER)
	@echo "Generuji parser a lexer..."
	bison -d -t $(PARSER)
	flex $(LEXER)
	@mkdir -p $(TARGET_DIR)
	gcc -o $(TARGET) lex.yy.c parser.tab.c -lfl -lm  # Vytváří mujprogram.exe ve složce songton
	@echo "Kompilace dokončena. Binárka: $(TARGET)"

$(TARGET_ROOT): $(LEXER) $(PARSER)
	@echo "Generuji parser a lexer..."
	bison -d -t $(PARSER)
	flex $(LEXER)
	gcc -o $(TARGET_ROOT) lex.yy.c parser.tab.c -lfl -lm  # Vytváří mujprogram.exe v základní složce
	@echo "Kompilace dokončena. Binárka: $(TARGET_ROOT)"

# Čistící cíl
clean:
	rm -f $(TARGET_DIR)/mujprogram.exe $(TARGET_ROOT) lex.yy.c parser.tab.c parser.tab.h

# Cíl pro zobrazení stromu souborů
tree:
	@echo "Zobrazuji strukturu složek a souborů:"
	find . -type f

.PHONY: all clean tree
