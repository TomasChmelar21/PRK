import * as cp from 'child_process';
import * as vscode from 'vscode';
import * as fs from 'fs';
import * as path from 'path';

export function activate(context: vscode.ExtensionContext) {
    function toWslPath(winPath: string): string {
        return '/mnt/' + winPath
            .replace(/\\/g, '/')
            .replace(/^([a-zA-Z]):/, (match, drive) => drive.toLowerCase());
    }

    const runParser = vscode.commands.registerCommand('songton.runParser', () => {
        const editor = vscode.window.activeTextEditor;
        if (!editor) return;
    
        const document = editor.document;
        const programPath = path.join(context.extensionPath, '../songton', 'mujprogram.exe');
        const tempFile = path.join(context.extensionPath, '../songton', 'temp_input.txt');
    
        fs.writeFileSync(tempFile, document.getText());
    
        const wslProgramPath = toWslPath(programPath);
        const wslTempPath = toWslPath(tempFile);
    
        const outputChannel = vscode.window.createOutputChannel('Songton AST');
        outputChannel.clear();
    
        // === 1. Spuštění v terminálu (uživatelský výstup) ===
        const terminal = vscode.window.createTerminal('Songton Parser');
        terminal.show();
        terminal.sendText(`wsl bash -c "${wslProgramPath} < ${wslTempPath}"`);

    
        // === 2. Spuštění na pozadí pro OutputChannel ===
        const child = cp.spawn('wsl', [wslProgramPath], {
            stdio: ['pipe', 'pipe', 'pipe']
        });
    
        const inputData = fs.readFileSync(tempFile, 'utf-8');
        child.stdin.write(inputData);
        child.stdin.end();
    
        child.stdout.on('data', (data) => {
            const output = data.toString();
            console.log("STDOUT:", output);
            outputChannel.append(output);
        });
    
        child.stderr.on('data', (data) => {
            const error = data.toString();
            console.log("STDERR:", error);
            outputChannel.append(error);
        });
    
        child.on('close', (code) => {
            console.log(`Proces ukončen s kódem ${code}`);
            if (code !== 0) {
                vscode.window.showErrorMessage(`Program skončil s chybovým kódem: ${code}`);
            }
        });
    
        child.on('error', (err) => {
            console.error("Chyba při spouštění programu:", err);
            vscode.window.showErrorMessage('Chyba při spouštění programu');
        });
    });
    

    const helloWorld = vscode.commands.registerCommand('songton.helloWorld', () => {
        vscode.window.showInformationMessage('Hello World from songton!');
    });

    context.subscriptions.push(runParser, helloWorld);

    console.log('Rozšíření songton bylo aktivováno.');
}

export function deactivate() {}
