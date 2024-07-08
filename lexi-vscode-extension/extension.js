const vscode = require('vscode');
const { exec } = require('child_process');

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

            // Specify the compiler and compilation command
            const compilerCommand = `dune exec -- sstal ${filePath} -o /dev/null`;

            // Execute the compilation command
            exec(compilerCommand, (error, stdout, stderr) => {
                if (error) {
                    vscode.window.showErrorMessage(`Compilation error: ${stderr}`);
                    return;
                }

                vscode.window.showInformationMessage(`Compilation successful: ${stdout}`);
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
