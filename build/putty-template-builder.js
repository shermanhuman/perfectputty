const fs = require('fs');
const path = require('path');

// Convert hex color to RGB format for PuTTY
function hexToRgb(hex) {
  // Remove # if present
  hex = hex.replace('#', '');
  
  // Parse the hex values
  const r = parseInt(hex.substring(0, 2), 16);
  const g = parseInt(hex.substring(2, 4), 16);
  const b = parseInt(hex.substring(4, 6), 16);
  
  // Return as comma-separated string
  return `${r},${g},${b}`;
}

// Convert decimal to hexadecimal dword format for PuTTY
function decimalToHexDword(decimal) {
  // Convert to hex and pad with zeros to 8 digits
  return decimal.toString(16).padStart(8, '0');
}

// Process PuTTY template
function processPuttyTemplate(templateContent, userConfig, colorScheme) {
  let processedContent = templateContent;
  
  // Replace font and scrollback placeholders
  const fontFamily = userConfig.font?.family || 'DejaVu Sans Mono';
  const scrollbackLines = userConfig.terminal?.scrollback || 10000;
  const scrollbackLinesHex = decimalToHexDword(scrollbackLines);
  
  processedContent = processedContent.replace('{{FONT_FAMILY}}', fontFamily);
  processedContent = processedContent.replace('{{SCROLLBACK_LINES_HEX}}', scrollbackLinesHex);
  
  // Replace color placeholders
  processedContent = processedContent.replace(/{{FOREGROUND_RGB}}/g, hexToRgb(colorScheme.colors.foreground));
  processedContent = processedContent.replace(/{{BACKGROUND_RGB}}/g, hexToRgb(colorScheme.colors.background));
  processedContent = processedContent.replace(/{{BLACK_RGB}}/g, hexToRgb(colorScheme.colors.black));
  processedContent = processedContent.replace(/{{BRIGHT_BLACK_RGB}}/g, hexToRgb(colorScheme.colors.brightBlack));
  processedContent = processedContent.replace(/{{RED_RGB}}/g, hexToRgb(colorScheme.colors.red));
  processedContent = processedContent.replace(/{{BRIGHT_RED_RGB}}/g, hexToRgb(colorScheme.colors.brightRed));
  processedContent = processedContent.replace(/{{GREEN_RGB}}/g, hexToRgb(colorScheme.colors.green));
  processedContent = processedContent.replace(/{{BRIGHT_GREEN_RGB}}/g, hexToRgb(colorScheme.colors.brightGreen));
  processedContent = processedContent.replace(/{{YELLOW_RGB}}/g, hexToRgb(colorScheme.colors.yellow));
  processedContent = processedContent.replace(/{{BRIGHT_YELLOW_RGB}}/g, hexToRgb(colorScheme.colors.brightYellow));
  processedContent = processedContent.replace(/{{BLUE_RGB}}/g, hexToRgb(colorScheme.colors.blue));
  processedContent = processedContent.replace(/{{BRIGHT_BLUE_RGB}}/g, hexToRgb(colorScheme.colors.brightBlue));
  processedContent = processedContent.replace(/{{PURPLE_RGB}}/g, hexToRgb(colorScheme.colors.purple));
  processedContent = processedContent.replace(/{{BRIGHT_PURPLE_RGB}}/g, hexToRgb(colorScheme.colors.brightPurple));
  processedContent = processedContent.replace(/{{CYAN_RGB}}/g, hexToRgb(colorScheme.colors.cyan));
  processedContent = processedContent.replace(/{{BRIGHT_CYAN_RGB}}/g, hexToRgb(colorScheme.colors.brightCyan));
  processedContent = processedContent.replace(/{{WHITE_RGB}}/g, hexToRgb(colorScheme.colors.white));
  processedContent = processedContent.replace(/{{BRIGHT_WHITE_RGB}}/g, hexToRgb(colorScheme.colors.brightWhite));
  
  return processedContent;
}

// Build PuTTY settings
async function buildPuttySettings(userConfig, colorScheme, distDir) {
  console.log('Building PuTTY settings...');
  
  console.log(`Using color scheme: ${colorScheme.name}`);
  console.log(`Using font: ${userConfig.font?.family || 'DejaVu Sans Mono'}`);
  console.log(`Using scrollback lines: ${userConfig.terminal?.scrollback || 10000}`);
  
  // Get template file
  const templatePath = path.join(process.cwd(), 'addons', 'putty', 'templates', 'putty-settings.reg.tmpl');
  
  if (!fs.existsSync(templatePath)) {
    console.log('PuTTY template not found, skipping');
    return;
  }
  
  const templateContent = fs.readFileSync(templatePath, 'utf8');
  
  // Process template with user config and color scheme
  const processedContent = processPuttyTemplate(templateContent, userConfig, colorScheme);
  
  // Create output directory
  const outputDir = path.join(distDir, 'addons', 'putty');
  if (!fs.existsSync(outputDir)) {
    fs.mkdirSync(outputDir, { recursive: true });
  }
  
  // Write processed template to output file
  const outputPath = path.join(outputDir, 'putty-settings.reg');
  fs.writeFileSync(outputPath, processedContent);
  
  console.log(`Generated: ${outputPath}`);
}

module.exports = { buildPuttySettings };