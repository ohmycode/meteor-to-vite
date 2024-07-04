# Meteor to Vite Conversion Helper

This script helps you convert your Meteor project to a Vite project, supporting both TypeScript and JavaScript projects, with TypeScript as the default for the converted project.

## Features

- Detects if your Meteor project uses TypeScript or JavaScript.
- Copies the necessary files from your Meteor project to the new Vite project (next to your project folder: your-project_vite)
- Creates `package.json` and `vite.config` files for the new Vite project.
- Comments out Meteor-specific imports.
- Extracts and installs external dependencies.
- Converts `.js` files to `.jsx` and `.ts` files to `.tsx` if they contain JSX.

It doesn't alter your actual project.

## Prerequisites

- Node.js and npm installed
- [pnpm](https://pnpm.io/installation) installed
- A Meteor project to convert

## Usage

1. Clone the repository or download the script.

```bash
git clone https://github.com/yourusername/meteor-to-vite-conversion-helper.git
cd meteor-to-vite-conversion-helper
```

2. Make the script executable.

```bash
chmod +x convert.sh
```

3. Run the script with the path to your Meteor project directory.

```bash
./convert.sh /path/to/your/meteor/project
```

## Script Details

Here's what the script does:

1. **Check for Project Directory**: Ensures you provide the path to your Meteor project directory.
2. **Copy Necessary Files**: Copies client-side code and imports folder to the new Vite project directory.
3. **Detect Project Type**: Checks if the project uses TypeScript or JavaScript.
4. **Create `package.json`**: Generates a `package.json` file with necessary dependencies and devDependencies.
5. **Create Vite Config**: Generates a `vite.config.js` or `vite.config.ts` based on the project type.
6. **Create `index.html`**: Sets up a basic `index.html` file for the Vite project.
7. **Create Main Entry File**: Creates `main.jsx` or `main.tsx` to bootstrap the React application.
8. **Extract and Install Dependencies**: Extracts non-Meteor dependencies and installs them using pnpm to its latest stable version. If you want to keep the dependency versions of your project, the easiest ist to copy the necessary parts from your dependencies in your package.json file to the new package.json and run pnpm install.
9. **Rename Files Containing JSX**: Renames `.js` files to `.jsx` and `.ts` files to `.tsx` if they contain JSX.

## Notes

- There is a very low chance that your new project works out of the box. This script is just ment to ease the pain of converting the project.
- Review the converted files and adjust as necessary.
- You may need to manually update import statements and resolve any Meteor-specific code.
- If you don't use pnpm, just edit the script to use your favourite package manager.
