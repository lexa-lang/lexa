const vscode = require('vscode');
const { exec } = require('child_process');
const os = require('os');
const fs = require('fs');
const path = require('path');

/**
 * @param {vscode.ExtensionContext} context
 */
function activate(context) {
    console.log('Congratulations, your extension "lexi-vscode-extension" is now active!');

    let binaryPath = ''; // Variable to store the binary path

    // Command to set or update the binary path
    const setBinaryPathCommand = vscode.commands.registerCommand('lexi-vscode-extension.setBinaryPath', async function () {
        const newBinaryPath = await vscode.window.showInputBox({
            prompt: 'Enter the path to your binary for the build',
            value: binaryPath || `/u/${os.userInfo().username}/sstal/_build/default/bin/main.exe`
        });

        if (newBinaryPath) {
            binaryPath = newBinaryPath;
            vscode.window.showInformationMessage(`Binary path set to: ${binaryPath}`);
        } else {
            vscode.window.showWarningMessage('Binary path not set');
        }
    });

    context.subscriptions.push(setBinaryPathCommand);

    // Command to check the current binary path
    const checkBinaryPathCommand = vscode.commands.registerCommand('lexi-vscode-extension.checkBinaryPath', function () {
        if (binaryPath) {
            vscode.window.showInformationMessage(`Current binary path: ${binaryPath}`);
        } else {
            vscode.window.showWarningMessage('Binary path not set. Please set it using the appropriate command.');
        }
    });

    context.subscriptions.push(checkBinaryPathCommand);

    // Command to compile a selected file
    const compileFileCommand = vscode.commands.registerCommand('lexi-vscode-extension.compileFile', async function () {
        const fileUri = await vscode.window.showOpenDialog({
            canSelectMany: false,
            openLabel: 'Select a file to compile',
            filters: {
                'Text files': ['txt'],
                'All files': ['*']
            }
        });

        if (fileUri && fileUri[0]) {
            const filePath = fileUri[0].fsPath;

            if (!binaryPath) {
                vscode.window.showWarningMessage('Binary path not set. Please set it using the appropriate command.');
                return;
            }

            // Use a temporary directory for the error log file
            const tempDir = os.tmpdir();
            const errorLogPath = path.join(tempDir, 'compilation_errors.log');

            // Specify the compiler command using the binary path
            const compilerCommand = `${binaryPath} ${filePath} -o /dev/null`;

            // Execute the compilation command
            exec(compilerCommand, (compileError, compileStdout, compileStderr) => {
                if (compileError) {
                    // Log the error to the file
                    fs.appendFile(errorLogPath, `${new Date().toISOString()} - ${compileStderr}\n`, (fsError) => {
                        if (fsError) {
                            vscode.window.showErrorMessage(`Failed to log error: ${fsError.message}`);
                        } else {
                            vscode.window.showErrorMessage(`Compilation error has been logged in: ${errorLogPath}`);
                        }
                    });
                    return;
                }

                vscode.window.showInformationMessage(`Compilation successful: ${compileStdout}`);
            });
        } else {
            vscode.window.showInformationMessage('No file selected');
        }
    });

    context.subscriptions.push(compileFileCommand);
}

function deactivate() {}

module.exports = {
    activate,
    deactivate
};
