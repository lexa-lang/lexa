const vscode = require('vscode');
const { exec } = require('child_process');
const os = require('os'); // Import the os module
const fs = require('fs'); // Import the fs module
const path = require('path'); // Import the path module

/**
 * @param {vscode.ExtensionContext} context
 */
function activate(context) {
    console.log('Congratulations, your extension "lexi-vscode-extension" is now active!');

    const helloWorldCommand = vscode.commands.registerCommand('lexi-vscode-extension.helloWorld', function () {
        vscode.window.showInformationMessage('Hello World from lexi-vscode-extension!');
    });

    context.subscriptions.push(helloWorldCommand);

    const compileFileCommand = vscode.commands.registerCommand('lexi-vscode-extension.compileFile', async function () {
        // Prompt user to select a file
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

            // Get the current user's username
            const username = os.userInfo().username;

            // Specify the compiler command
            const compilerCommand = `/u/${username}/sstal/_build/default/bin/main.exe ${filePath} -o /dev/null`;

            // Define the path to the error log file
            const errorLogPath = `/u/${username}/sstal/compilation_errors.log`;

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
