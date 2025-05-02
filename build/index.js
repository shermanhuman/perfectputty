#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const yaml = require('js-yaml');
const { buildStarshipThemes } = require('./starship-theme-builder.js');
const { buildPuttySettings } = require('./putty-template-builder.js');

// Bump version in package.json
function bumpVersion() {
  const packagePath = path.join(process.cwd(), 'package.json');
  
  // Create package.json if it doesn't exist
  if (!fs.existsSync(packagePath)) {
    const defaultPackage = {
      name: "perfectputty",
      version: "1.0.0",
      description: "A cross-platform environment configuration system",
      scripts: {
        build: "node build/index.js"
      }
    };
    fs.writeFileSync(packagePath, JSON.stringify(defaultPackage, null, 2));
    console.log(`Created package.json with version 1.0.0`);
    return "1.0.0";
  }
  
  const packageJson = JSON.parse(fs.readFileSync(packagePath, 'utf8'));
  
  // Split version into major.minor.patch
  const versionParts = packageJson.version.split('.');
  
  // Increment patch version
  versionParts[2] = (parseInt(versionParts[2], 10) + 1).toString();
  
  // Update version
  packageJson.version = versionParts.join('.');
  
  // Write updated package.json
  fs.writeFileSync(packagePath, JSON.stringify(packageJson, null, 2));
  
  console.log(`Bumped version to ${packageJson.version}`);
  return packageJson.version;
}

// Generate Windows file manifest
function generateWindowsManifest() {
  console.log('Generating Windows file manifest...');
  
  // Define core files
  const coreFiles = [
    "core/profiles/powershell.ps1",
    "core/terminal/windows.json",
    "core/color-schemes/perfect16.yaml",
    "core/sounds/pop.wav",
    "dist/shell-themes/perfect.toml"
  ];
  
  // Define test files
  const testFiles = [
    "tests/run-tests.ps1",
    "tests/common/colortest.ps1",
    "tests/common/unicode-test.ps1",
    "tests/common/ascii/big.ascii",
    "tests/common/ascii/circle.ascii",
    "tests/common/ascii/future.ascii",
    "tests/common/ascii/mike.ascii",
    "tests/common/ascii/pagga.ascii"
  ];
  
  // Scan addons directory for Windows addon files
  const addonsDir = path.join(process.cwd(), 'addons');
  const addonFiles = [];
  
  if (fs.existsSync(addonsDir)) {
    const addonDirs = fs.readdirSync(addonsDir).filter(dir => 
      fs.statSync(path.join(addonsDir, dir)).isDirectory()
    );
    
    // For each addon, add its Windows files
    for (const addon of addonDirs) {
      const addonDir = path.join(addonsDir, addon);
      const configPath = path.join(addonDir, 'config.yaml');
      
      if (fs.existsSync(configPath)) {
        const config = yaml.load(fs.readFileSync(configPath, 'utf8'));
        const platforms = config.platforms || [];
        
        // Add Windows files if supported
        if (platforms.includes('windows')) {
          addonFiles.push(`addons/${addon}/config.yaml`);
          
          // Check if install-scripts directory exists
          const installScriptsDir = path.join(addonDir, 'install-scripts');
          if (fs.existsSync(installScriptsDir)) {
            addonFiles.push(`addons/${addon}/install-scripts/windows.ps1`);
          } else {
            // Fallback to old structure
            addonFiles.push(`addons/${addon}/windows.ps1`);
          }
          
          // Add any additional files specific to this addon
          if (addon === 'putty') {
            addonFiles.push(`dist/addons/${addon}/putty-settings.reg`);
          }
        }
      }
    }
  }
  
  // Combine all files
  const allFiles = [...coreFiles, ...addonFiles, ...testFiles];
  
  // Format the manifest string
  const manifestString = allFiles.map(file => `    "${file}"`).join(',\n');
  
  return manifestString;
}

// Generate Linux file manifest
function generateLinuxManifest() {
  console.log('Generating Linux file manifest...');
  
  // Define core files
  const coreFiles = [
    "core/profiles/shell_profile.sh",
    "core/terminal/linux.conf",
    "core/color-schemes/perfect16.yaml",
    "core/sounds/pop.wav",
    "dist/shell-themes/perfect.toml"
  ];
  
  // Define test files
  const testFiles = [
    "tests/run-tests.sh",
    "tests/common/colortest.sh",
    "tests/common/unicode-test.sh",
    "tests/common/ascii/big.ascii",
    "tests/common/ascii/circle.ascii",
    "tests/common/ascii/future.ascii",
    "tests/common/ascii/mike.ascii",
    "tests/common/ascii/pagga.ascii"
  ];
  
  // Scan addons directory for Linux addon files
  const addonsDir = path.join(process.cwd(), 'addons');
  const addonFiles = [];
  
  if (fs.existsSync(addonsDir)) {
    const addonDirs = fs.readdirSync(addonsDir).filter(dir => 
      fs.statSync(path.join(addonsDir, dir)).isDirectory()
    );
    
    // For each addon, add its Linux files
    for (const addon of addonDirs) {
      const addonDir = path.join(addonsDir, addon);
      const configPath = path.join(addonDir, 'config.yaml');
      
      if (fs.existsSync(configPath)) {
        const config = yaml.load(fs.readFileSync(configPath, 'utf8'));
        const platforms = config.platforms || [];
        
        // Add Linux files if supported
        if (platforms.includes('linux')) {
          addonFiles.push(`addons/${addon}/config.yaml`);
          
          // Check if install-scripts directory exists
          const installScriptsDir = path.join(addonDir, 'install-scripts');
          if (fs.existsSync(installScriptsDir)) {
            addonFiles.push(`addons/${addon}/install-scripts/linux.sh`);
          } else {
            // Fallback to old structure
            addonFiles.push(`addons/${addon}/linux.sh`);
          }
        }
      }
    }
  }
  
  // Combine all files
  const allFiles = [...coreFiles, ...addonFiles, ...testFiles];
  
  // Format the manifest string
  const manifestString = allFiles.map(file => `    "${file}"`).join('\n');
  
  return manifestString;
}

// Generate macOS file manifest
function generateMacManifest() {
  console.log('Generating macOS file manifest...');
  
  // Define core files
  const coreFiles = [
    "core/profiles/shell_profile.sh",
    "core/terminal/macos.terminal",
    "core/color-schemes/perfect16.yaml",
    "core/sounds/pop.wav",
    "dist/shell-themes/perfect.toml"
  ];
  
  // Define test files
  const testFiles = [
    "tests/run-tests.sh",
    "tests/common/colortest.sh",
    "tests/common/unicode-test.sh",
    "tests/common/ascii/big.ascii",
    "tests/common/ascii/circle.ascii",
    "tests/common/ascii/future.ascii",
    "tests/common/ascii/mike.ascii",
    "tests/common/ascii/pagga.ascii"
  ];
  
  // Scan addons directory for macOS addon files
  const addonsDir = path.join(process.cwd(), 'addons');
  const addonFiles = [];
  
  if (fs.existsSync(addonsDir)) {
    const addonDirs = fs.readdirSync(addonsDir).filter(dir => 
      fs.statSync(path.join(addonsDir, dir)).isDirectory()
    );
    
    // For each addon, add its macOS files
    for (const addon of addonDirs) {
      const addonDir = path.join(addonsDir, addon);
      const configPath = path.join(addonDir, 'config.yaml');
      
      if (fs.existsSync(configPath)) {
        const config = yaml.load(fs.readFileSync(configPath, 'utf8'));
        const platforms = config.platforms || [];
        
        // Add macOS files if supported
        if (platforms.includes('macos')) {
          addonFiles.push(`addons/${addon}/config.yaml`);
          
          // Check if install-scripts directory exists
          const installScriptsDir = path.join(addonDir, 'install-scripts');
          if (fs.existsSync(installScriptsDir)) {
            addonFiles.push(`addons/${addon}/install-scripts/macos.sh`);
          } else {
            // Fallback to old structure
            addonFiles.push(`addons/${addon}/macos.sh`);
          }
        }
      }
    }
  }
  
  // Combine all files
  const allFiles = [...coreFiles, ...addonFiles, ...testFiles];
  
  // Format the manifest string
  const manifestString = allFiles.map(file => `    "${file}"`).join('\n');
  
  return manifestString;
}

// Generate Windows addon registry
function generateWindowsAddonRegistry() {
  console.log('Generating Windows addon registry...');
  
  const addonsDir = path.join(process.cwd(), 'addons');
  let registryString = '';
  
  if (fs.existsSync(addonsDir)) {
    const addonDirs = fs.readdirSync(addonsDir).filter(dir => 
      fs.statSync(path.join(addonsDir, dir)).isDirectory()
    );
    
    for (const addon of addonDirs) {
      const addonDir = path.join(addonsDir, addon);
      const configPath = path.join(addonDir, 'config.yaml');
      
      if (fs.existsSync(configPath)) {
        const config = yaml.load(fs.readFileSync(configPath, 'utf8'));
        const platforms = config.platforms || [];
        
        // Only include Windows-compatible addons
        if (platforms.includes('windows')) {
          // Check if addon has Starship configuration
          let hasStarshipConfig = false;
          let moduleContent = '';
          let configContent = '';
          
          const shellDir = path.join(addonDir, 'shell');
          if (fs.existsSync(shellDir)) {
            const moduleFile = path.join(shellDir, 'starship.module.toml');
            const configFile = path.join(shellDir, 'starship.config.toml');
            
            if (fs.existsSync(moduleFile) && fs.existsSync(configFile)) {
              hasStarshipConfig = true;
              moduleContent = fs.readFileSync(moduleFile, 'utf8');
              configContent = fs.readFileSync(configFile, 'utf8');
            }
          }
          
          // Add to registry
          registryString += `    "${addon}" = @{\n`;
          registryString += `        "Name" = "${config.name}"\n`;
          registryString += `        "Description" = "${config.description}"\n`;
          registryString += `        "Platforms" = @(${platforms.map(p => `"${p}"`).join(', ')})\n`;
          registryString += `        "HasStarshipConfig" = $${hasStarshipConfig}\n`;
          
          if (hasStarshipConfig) {
            registryString += `        "Starship" = @{\n`;
            registryString += `            "Module" = '${moduleContent}'\n`;
            registryString += `            "Config" = @"\n${configContent}\n"@\n`;
            registryString += `        }\n`;
          } else {
            registryString += `        "Starship" = $null\n`;
          }
          
          registryString += `    }\n`;
        }
      }
    }
  }
  
  return registryString;
}

// Generate Unix addon registry
function generateUnixAddonRegistry() {
  console.log('Generating Unix addon registry...');
  
  const addonsDir = path.join(process.cwd(), 'addons');
  let registryString = '';
  
  if (fs.existsSync(addonsDir)) {
    const addonDirs = fs.readdirSync(addonsDir).filter(dir => 
      fs.statSync(path.join(addonsDir, dir)).isDirectory()
    );
    
    for (const addon of addonDirs) {
      const addonDir = path.join(addonsDir, addon);
      const configPath = path.join(addonDir, 'config.yaml');
      
      if (fs.existsSync(configPath)) {
        const config = yaml.load(fs.readFileSync(configPath, 'utf8'));
        const platforms = config.platforms || [];
        
        // Only include Unix-compatible addons (Linux or macOS)
        if (platforms.includes('linux') || platforms.includes('macos')) {
          // Check if addon has Starship configuration
          let hasStarshipConfig = false;
          let moduleContent = '';
          let configContent = '';
          
          const shellDir = path.join(addonDir, 'shell');
          if (fs.existsSync(shellDir)) {
            const moduleFile = path.join(shellDir, 'starship.module.toml');
            const configFile = path.join(shellDir, 'starship.config.toml');
            
            if (fs.existsSync(moduleFile) && fs.existsSync(configFile)) {
              hasStarshipConfig = true;
              moduleContent = fs.readFileSync(moduleFile, 'utf8').replace(/'/g, "'\\''");
              configContent = fs.readFileSync(configFile, 'utf8').replace(/'/g, "'\\''");
            }
          }
          
          // Add to registry
          const addonUpper = addon.toUpperCase();
          
          registryString += `# ${addon}\n`;
          registryString += `ADDON_${addonUpper}_NAME="${config.name}"\n`;
          registryString += `ADDON_${addonUpper}_DESCRIPTION="${config.description}"\n`;
          registryString += `ADDON_${addonUpper}_PLATFORMS=(${platforms.map(p => `"${p}"`).join(' ')})\n`;
          registryString += `ADDON_${addonUpper}_HAS_STARSHIP_CONFIG=${hasStarshipConfig}\n`;
          
          if (hasStarshipConfig) {
            registryString += `ADDON_${addonUpper}_STARSHIP_MODULE='${moduleContent}'\n`;
            registryString += `ADDON_${addonUpper}_STARSHIP_CONFIG='${configContent}'\n`;
          } else {
            registryString += `ADDON_${addonUpper}_STARSHIP_MODULE=""\n`;
            registryString += `ADDON_${addonUpper}_STARSHIP_CONFIG=""\n`;
          }
          
          registryString += `\n`;
        }
      }
    }
  }
  
  return registryString;
}

// Generate installation scripts
async function generateInstallationScripts(version) {
  console.log('Generating installation scripts...');
  
  const distDir = path.join(process.cwd(), 'dist');
  if (!fs.existsSync(distDir)) {
    fs.mkdirSync(distDir, { recursive: true });
  }
  
  const today = new Date().toISOString().split('T')[0];
  
  // Generate Windows installation script
  const winTemplatePath = path.join(process.cwd(), 'install', 'install.ps1.tmpl');
  if (fs.existsSync(winTemplatePath)) {
    let winTemplate = fs.readFileSync(winTemplatePath, 'utf8');
    
    // Replace placeholders
    winTemplate = winTemplate.replace('{{VERSION}}', version);
    winTemplate = winTemplate.replace('{{BUILD_DATE}}', today);
    winTemplate = winTemplate.replace('{{FILE_MANIFEST}}', generateWindowsManifest());
    winTemplate = winTemplate.replace('{{ADDON_REGISTRY}}', generateWindowsAddonRegistry());
    
    // Write to dist directory
    fs.writeFileSync(path.join(distDir, 'perfect-install.ps1'), winTemplate);
    console.log('Generated Windows installation script');
  }
  
  // Generate Linux installation script
  const linuxTemplatePath = path.join(process.cwd(), 'install', 'install-linux.sh.tmpl');
  if (fs.existsSync(linuxTemplatePath)) {
    let linuxTemplate = fs.readFileSync(linuxTemplatePath, 'utf8');
    
    // Replace placeholders
    linuxTemplate = linuxTemplate.replace('{{VERSION}}', version);
    linuxTemplate = linuxTemplate.replace('{{BUILD_DATE}}', today);
    linuxTemplate = linuxTemplate.replace('{{FILE_MANIFEST}}', generateLinuxManifest());
    linuxTemplate = linuxTemplate.replace('{{ADDON_REGISTRY}}', generateUnixAddonRegistry());
    
    // Write to dist directory
    const linuxScriptPath = path.join(distDir, 'perfect-install-linux.sh');
    fs.writeFileSync(linuxScriptPath, linuxTemplate);
    fs.chmodSync(linuxScriptPath, '755'); // Make executable
    console.log('Generated Linux installation script');
  }
  
  // Generate macOS installation script
  const macTemplatePath = path.join(process.cwd(), 'install', 'install-mac.sh.tmpl');
  if (fs.existsSync(macTemplatePath)) {
    let macTemplate = fs.readFileSync(macTemplatePath, 'utf8');
    
    // Replace placeholders
    macTemplate = macTemplate.replace('{{VERSION}}', version);
    macTemplate = macTemplate.replace('{{BUILD_DATE}}', today);
    macTemplate = macTemplate.replace('{{FILE_MANIFEST}}', generateMacManifest());
    macTemplate = macTemplate.replace('{{ADDON_REGISTRY}}', generateUnixAddonRegistry());
    
    // Write to dist directory
    const macScriptPath = path.join(distDir, 'perfect-install-mac.sh');
    fs.writeFileSync(macScriptPath, macTemplate);
    fs.chmodSync(macScriptPath, '755'); // Make executable
    console.log('Generated macOS installation script');
  }
}

// Main build function
async function build() {
  console.log('Starting PerfectPutty build process...');
  
  // Load user config
  const userConfigPath = path.join(process.cwd(), 'user-config.yaml');
  let userConfig;
  
  if (fs.existsSync(userConfigPath)) {
    userConfig = yaml.load(fs.readFileSync(userConfigPath, 'utf8'));
  } else {
    // Create default user config
    userConfig = {
      colorScheme: "Perfect16",
      font: {
        family: "SauceCodePro Nerd Font",
        size: 12
      },
      terminal: {
        scrollback: 10000
      },
      shell: {
        theme: "perfect"
      }
    };
    
    fs.writeFileSync(userConfigPath, yaml.dump(userConfig));
    console.log('Created default user-config.yaml');
  }
  
  // Load the specified color scheme
  const colorSchemeName = userConfig.colorScheme;
  console.log(`Loading color scheme: ${colorSchemeName}`);
  
  const colorSchemePath = path.join(process.cwd(), 'core', 'color-schemes', `${colorSchemeName.toLowerCase()}.yaml`);
  
  if (!fs.existsSync(colorSchemePath)) {
    throw new Error(`Color scheme file not found: ${colorSchemePath}`);
  }
  
  const colorScheme = yaml.load(fs.readFileSync(colorSchemePath, 'utf8'));
  
  // Create dist directory if it doesn't exist
  const distDir = path.join(process.cwd(), 'dist');
  if (!fs.existsSync(distDir)) {
    fs.mkdirSync(distDir, { recursive: true });
  }
  
  // Build Starship themes
  await buildStarshipThemes(userConfig, colorScheme, distDir);
  
  // Build PuTTY settings
  await buildPuttySettings(userConfig, colorScheme, distDir);
  
  // Bump version
  const version = bumpVersion();
  
  // Generate installation scripts
  await generateInstallationScripts(version);
  
  console.log(`Build completed successfully! Version: ${version}`);
}

// Run the build
build().catch(err => {
  console.error('Build failed:', err);
  process.exit(1);
});