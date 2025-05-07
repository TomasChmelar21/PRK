"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.activate = activate;
exports.deactivate = deactivate;
const cp = __importStar(require("child_process"));
const vscode = __importStar(require("vscode"));
const fs = __importStar(require("fs"));
const path = __importStar(require("path"));
function activate(context) {
    function toWslPath(winPath) {
        return '/mnt/' + winPath
            .replace(/\\/g, '/')
            .replace(/^([a-zA-Z]):/, (match, drive) => drive.toLowerCase());
    }
    const runParser = vscode.commands.registerCommand('songton.runParser', () => {
        const editor = vscode.window.activeTextEditor;
        if (!editor)
            return;
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
function deactivate() { }
//# sourceMappingURL=extension.js.map