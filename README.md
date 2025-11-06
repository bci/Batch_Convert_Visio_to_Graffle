# Visio to OmniGraffle Batch Converter

AppleScript tool for batch converting Visio stencils (.vss, .vssx) to OmniGraffle stencils (.gstencil).

## Features

- Recursively processes Visio stencil files
- Automated GUI interaction with OmniGraffle
- Customizable stencil naming: `<folder-name>-<filename>`
- Memory management with periodic app quit
- Configurable logging levels
- Input validation and error handling

## Requirements

- macOS
- OmniGraffle with iCloud Drive enabled
- Visio stencil files (.vss or .vssx)

## Getting Started

### Clone

```bash
git clone https://github.com/bci/Batch_Convert_Visio_to_Graffle.git
cd Batch_Convert_Visio_to_Graffle
```

### Compile

AppleScript files (`.applescript`) do not require compilation to run. However, if you want to create a compiled `.scpt` file for faster execution:

```bash
# Optional: Compile to .scpt format
osacompile -o batch_convert_visio_to_graffle.scpt batch_convert_visio_to_graffle.applescript
```

### Run

Execute the script directly using `osascript`:

```bash
# Basic usage (skip existing files)
osascript batch_convert_visio_to_graffle.applescript --skip

# Or if you compiled it:
osascript batch_convert_visio_to_graffle.scpt --skip
```

## Usage

```bash
osascript batch_convert_visio_to_graffle.applescript [OPTIONS]
```

### Required Options

- `--overwrite` - Overwrite existing stencils
- `--skip` - Skip files that already exist

### Optional Options

- `--visio-stencil-folder DIR` - Input folder containing Visio stencils (default: ./VisioStencils)
- `--debuglevel LEVEL` - Set logging level: debug, info, warning, error (default: info)
- `--quit-interval NUM` - Quit OmniGraffle every NUM files to free memory (default: 50)
- `--count NUM` - Limit number of files to convert (useful for testing)
- `--batch` - Suppress all dialog boxes for unattended execution
- `--help, -h` - Display help message

### Examples

```bash
# Basic usage (skip existing files)
osascript batch_convert_visio_to_graffle.applescript --skip

# Overwrite existing files with debug logging
osascript batch_convert_visio_to_graffle.applescript --overwrite --debuglevel debug

# Test with first 5 files only
osascript batch_convert_visio_to_graffle.applescript --skip --count 5

# Custom input folder
osascript batch_convert_visio_to_graffle.applescript --skip --visio-stencil-folder ~/MyStencils

# Adjust memory management interval
osascript batch_convert_visio_to_graffle.applescript --skip --quit-interval 25

# Unattended batch mode (no dialogs)
osascript batch_convert_visio_to_graffle.applescript --skip --batch
```

## How It Works

1. Recursively finds all .vss and .vssx files in the input folder
2. For each file:
   - Opens it in OmniGraffle
   - Sets the stencil name using the folder-filename pattern
   - Saves to OmniGraffle's iCloud stencils folder
   - Closes the document
3. Periodically quits OmniGraffle to free memory during large batch operations
4. Provides summary of successful, skipped, and failed conversions

## Output Location

Stencils are saved to OmniGraffle's iCloud folder:
```
~/Library/Mobile Documents/iCloud~com~omnigroup~OmniGraffle/Documents/Stencils
```

This corresponds to `iCloud Drive/OmniGraffle/Stencils` in Finder.

## Filename Sanitization

The script automatically sanitizes filenames by:
- Replacing special characters (`/`, `\`, `()`, spaces) with underscores
- Collapsing multiple consecutive underscores
- Preserving alphanumeric characters, dots, and hyphens

## Notes

- Large batch conversions may take considerable time
- The script requires GUI accessibility permissions for System Events
- OmniGraffle must be configured to use iCloud Drive for stencils
- Memory management via periodic quit helps prevent crashes during large batches

## Troubleshooting

### Common Issues

**Script fails with "OmniGraffle iCloud stencils folder not found"**
- Ensure OmniGraffle is installed and configured to use iCloud Drive
- Check that the iCloud Drive path exists: `~/Library/Mobile Documents/iCloud~com~omnigroup~OmniGraffle/Documents/Stencils`

**"Operation not permitted" errors**
- Grant Accessibility permissions to Terminal (or your terminal app) in System Preferences > Privacy & Security > Accessibility

**Stencils not appearing in OmniGraffle**
- Allow time for iCloud sync to complete
- Restart OmniGraffle to refresh the stencils list

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Authors

- **Kent** - *Initial work and primary development*
- **GitHub Copilot (Claude Sonnet 4.5)** - *Co-author and development assistance*

## License

MIT License

Copyright (c) 2025 Kent

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
