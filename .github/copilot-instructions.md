# vim-open - Vim Plugin Development Instructions

vim-open is a Vim plugin designed to enhance the built-in `gf` command to intelligently open different types of resources (HTTP links, file paths, custom identifiers, etc.).

**Always reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.**

## Repository Current State

**CRITICAL**: This repository currently contains only documentation (README.md). The actual plugin implementation has not been created yet. These instructions cover both the current state and the development workflow for when plugin code is added.

## Working Effectively

### Repository Structure (When Implemented)
Standard Vim plugin structure will include:
- `plugin/vim-open.vim` - Main plugin file with commands and mappings
- `autoload/gopher.vim` - Autoload functions (`gopher#add_finder()`, `gopher#add_opener()`)
- `doc/vim-open.txt` - Plugin documentation
- Optional: `after/`, `ftplugin/`, `syntax/` directories for specific functionality

### Development Workflow

#### Initial Setup and Validation
- Install vim script linter: `python3 -m pip install vim-vint`
- Verify Vim is available: `vim --version` (requires Vim 7.4+ or Neovim)
- Test basic Vim functionality: `echo "test" > /tmp/test_vim.txt && vim -c "echo 'vim works'" -c "q!" /tmp/test_vim.txt`

#### Development Commands
- **Lint vim scripts**: `vint plugin/*.vim autoload/*.vim` -- takes <5 seconds. NEVER CANCEL.
- **Test plugin loading**: `vim -c "VimOpenTest" -c "q" --cmd "set runtimepath+=$(pwd)"` -- takes <1 second.
- **Manual testing**: `vim -c "call gopher#test()" -c "q" --cmd "set runtimepath+=$(pwd)"` -- takes <1 second.

#### Plugin Installation Testing Methods

**Method 1: Runtime Path (Development)**
```bash
vim --cmd "set runtimepath+=/home/runner/work/vim-open/vim-open" -c "VimOpenTest" -c "q"
```

**Method 2: Native Vim 8+ Packages**
```bash
mkdir -p ~/.vim/pack/plugins/start
cp -r /home/runner/work/vim-open/vim-open ~/.vim/pack/plugins/start/vim-open
vim -c "VimOpenTest" -c "q"
```

**Method 3: Vundle (if needed for testing)**
```bash
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
# Add to ~/.vimrc: Plugin 'sophiehicks1/vim-open'
```

### Build and Test Process

**CRITICAL**: Currently no build process exists. When plugin code is implemented:

- **Linting**: `vint plugin/*.vim autoload/*.vim` -- takes <5 seconds. NEVER CANCEL.
- **Syntax validation**: Load plugin in Vim and test functions -- takes <1 second.
- **Integration testing**: Test `gf` mappings with different content types -- manual validation required.

**All validation commands complete in under 10 seconds. No long-running builds exist for this plugin.**

## Validation Scenarios

**CRITICAL**: When plugin code exists, always test these scenarios after making changes:

### Core Function Testing
1. **Basic plugin loading**: `vim -c "VimOpenTest" -c "q" --cmd "set runtimepath+=$(pwd)"`
2. **Autoload functions**: `vim -c "call gopher#add_finder('test', 'test')" -c "q" --cmd "set runtimepath+=$(pwd)"`
3. **HTTP link detection**: Create test file with `https://github.com`, place cursor on it, test `gf` command
4. **File path fallback**: Create test file with local path, test that `gf` works normally
5. **Custom finder/opener**: Add test finder and opener, validate they're called correctly

### Manual Validation Steps
1. Create test file: `echo -e "https://github.com\n/tmp/test.txt\nCC-1234" > test_content.txt`
2. Open in Vim: `vim test_content.txt --cmd "set runtimepath+=$(pwd)"`
3. Test each line with `gf` command:
   - Line 1: Should open browser (when implemented)
   - Line 2: Should open file in Vim (default behavior)
   - Line 3: Should trigger custom handler (when implemented)

### Expected Behavior
- HTTP/HTTPS links: Open in system browser
- File paths: Use default Vim `gf` behavior
- Custom patterns: Route through appropriate finder/opener functions
- Fallback: Always preserve original `gf` functionality

## Development Standards

### Code Quality
- **ALWAYS run**: `vint plugin/*.vim autoload/*.vim` before committing changes
- Follow Google VimScript Style Guide (enforced by vint)
- Use `abort` attribute for autoload functions
- Prefer single-quoted strings
- Document all public functions

### Plugin Functions (From README.md)
- `gopher#add_finder(match_fn, extract_fn)` - Add pattern recognition
- `gopher#add_opener(can_handle_fn, handler)` - Add resource opening method
- Main `gf` mapping override in `plugin/vim-open.vim`

## Common Issues and Solutions

### Plugin Not Loading
- Verify `runtimepath` includes plugin directory: `:echo &runtimepath`
- Check for syntax errors: `:messages` after loading
- Ensure proper file locations: `plugin/*.vim` and `autoload/*.vim`

### Testing Environment
- Use clean Vim instance: `vim -u NONE --cmd "set rtp+=$(pwd)"`
- Test with minimal vimrc to avoid conflicts
- Verify in both Vim and Neovim if available

### Browser Integration
- Browser opening depends on system `xdg-open` (Linux), `open` (macOS), or `start` (Windows)
- Test browser opening with: `xdg-open https://github.com` (Linux)

## Repository File Structure

Current repository contents:
```
/home/runner/work/vim-open/vim-open/
├── .git/
├── .github/
│   └── copilot-instructions.md  (this file)
└── README.md
```

Expected structure when implemented:
```
├── plugin/vim-open.vim
├── autoload/gopher.vim  
├── doc/vim-open.txt
├── README.md
└── .github/
    └── copilot-instructions.md
```

## Timing Expectations

**All operations are fast (under 10 seconds):**
- Linting with vint: <5 seconds
- Plugin loading test: <1 second  
- Manual validation: <30 seconds
- Complete development workflow: <1 minute

**No long-running builds or tests exist for this plugin type.**

## Key Development Notes

- This is a pure VimScript plugin with no external dependencies
- No compilation, building, or complex test suites required
- Focus on manual testing with real Vim usage scenarios
- Plugin architecture based on extensible finder/opener pattern
- Preserve default `gf` behavior as fallback
- Browser integration relies on system commands

## Quick Reference Commands

**Development workflow validation (run these to verify environment):**
```bash
# Verify environment (takes ~1 second)
python3 -m pip install vim-vint >/dev/null 2>&1 && echo "✓ vint ready"
vim --version >/dev/null && echo "✓ Vim available"
echo "test" > /tmp/test_vim.txt && vim -c "echo 'Environment OK'" -c "q!" /tmp/test_vim.txt

# When plugin code exists - validate everything (takes <10 seconds total)
vint plugin/*.vim autoload/*.vim  # Lint check
vim -c "VimOpenTest" -c "q" --cmd "set runtimepath+=$(pwd)"  # Plugin loading test
```

**Manual testing template:**
```bash
# Create test content
echo -e "https://github.com\n/tmp/test.txt\nCC-1234" > test_content.txt

# Test in Vim (when plugin implemented)
vim test_content.txt --cmd "set runtimepath+=$(pwd)"
# Then manually test gf on each line
```