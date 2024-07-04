#!/bin/bash

# Check if the Meteor project directory is provided
if [ $# -eq 0 ]; then
    echo "Please provide the path to your Meteor project directory."
    exit 1
fi

METEOR_PROJECT_DIR=$1
VITE_PROJECT_DIR="${METEOR_PROJECT_DIR}_vite"

# Create new Vite project directory
mkdir -p "$VITE_PROJECT_DIR"

# Copy client-side code and imports folder
cp -r "$METEOR_PROJECT_DIR/client" "$VITE_PROJECT_DIR/src"
cp -r "$METEOR_PROJECT_DIR/public" "$VITE_PROJECT_DIR/public"
cp -r "$METEOR_PROJECT_DIR/imports" "$VITE_PROJECT_DIR/src/imports"

# Create package.json for Vite project
cat > "$VITE_PROJECT_DIR/package.json" <<EOL
{
  "name": "vite-converted-meteor-project",
  "private": true,
  "version": "0.0.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview"
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0"
  },
  "devDependencies": {
    "@vitejs/plugin-react": "^4.0.0",
    "vite": "^4.3.9"
  }
}
EOL

# Create vite.config.js
cat > "$VITE_PROJECT_DIR/vite.config.js" <<EOL
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  esbuild: {
    loader: "jsx",
    include: /src\/.*\.jsx?$/,
    exclude: [],
  },
  optimizeDeps: {
    esbuildOptions: {
      loader: {
        '.js': 'jsx',
      },
    },
  },
})
EOL

# Create index.html
cat > "$VITE_PROJECT_DIR/index.html" <<EOL
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Vite Converted Meteor Project</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.jsx"></script>
  </body>
</html>
EOL

# Create main.jsx
cat > "$VITE_PROJECT_DIR/src/main.jsx" <<EOL
import React from "react";
import { createRoot } from "react-dom/client";
import App from "./imports/ui/App";
import "./main.css";

const container = document.getElementById("root");
const root = createRoot(container);

root.render(
    <React.StrictMode>
        <App />
    </React.StrictMode>
);
EOL

# Function to extract unique package names from import statements
extract_packages() {
    grep -hoE "(from|import) ['\"](@[a-zA-Z0-9_-]+/[a-zA-Z0-9._-]+|[a-zA-Z0-9._-]+)['\"]" "$1" | 
    sed "s/from ['\"]//; s/import ['\"]//; s/['\"]$//" | 
    grep -v "^meteor/" |
    sort -u
}

# Comment out Meteor imports and collect all external packages
PACKAGES=()
while IFS= read -r -d '' file; do
    # Comment out Meteor imports
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' "s/^import.*from 'meteor\/.*$/\/\/ &/" "$file"
    else
        # Linux and others
        sed -i "s/^import.*from 'meteor\/.*$/\/\/ &/" "$file"
    fi
    
    # Extract non-Meteor packages
    PACKAGES+=($(extract_packages "$file"))
    
    # Rename .js to .jsx if file contains JSX and is not already .jsx
    if [[ "$file" == *.js ]] && grep -q "React.createElement\|jsx\|<[A-Z]" "$file"; then
        mv "$file" "${file%.js}.jsx"
    fi
done < <(find "$VITE_PROJECT_DIR/src" -type f \( -name "*.js" -o -name "*.jsx" \) -print0)

# Remove duplicates
UNIQUE_PACKAGES=($(echo "${PACKAGES[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))

# Remove React and React DOM as they're already in package.json
UNIQUE_PACKAGES=(${UNIQUE_PACKAGES[@]/react /})
UNIQUE_PACKAGES=(${UNIQUE_PACKAGES[@]/react-dom /})

# Install dependencies
cd "$VITE_PROJECT_DIR"
pnpm install

# Install extracted packages
if [ ${#UNIQUE_PACKAGES[@]} -ne 0 ]; then
    echo "Installing extracted packages: ${UNIQUE_PACKAGES[*]}"
    pnpm add ${UNIQUE_PACKAGES[@]}
else
    echo "No additional packages to install."
fi

echo "Conversion complete. Your Vite project is now in $VITE_PROJECT_DIR"
echo "Please review the converted files and adjust as necessary."
echo "You may need to manually update import statements and resolve any Meteor-specific code."
