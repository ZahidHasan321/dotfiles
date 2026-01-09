# Dotfiles Reference

This is an ML4W-based Hyprland dotfiles setup for Arch Linux with distrobox development workflow.

## Root Files

| File | Description |
|------|-------------|
| `.zshrc` | Modular zsh config - sources files from `~/.config/zshrc/` in numeric order |
| `.bashrc` | Minimal bash config for fallback shell |
| `.distroboxrc` | Distrobox container init script - symlinks dotfiles, sets env vars (no installs) |
| `.gitconfig` | Git user configuration |
| `.gtkrc-2.0` | GTK2 theme settings |
| `.Xresources` | X11 resource settings (cursor size) |

## scripts/

| File | Description |
|------|-------------|
| `create-devbox.sh` | Creates distrobox container with dev tools (zsh, oh-my-zsh, eza, uv, pnpm) installed to container-only paths (/usr/local). Use `distrobox-export` to share tools with host. |

## .config/hypr/ - Hyprland Configuration

### Main Files
| File | Description |
|------|-------------|
| `hyprland.conf` | Main config - sources all other conf files in order |
| `colors.conf` | Matugen-generated color variables (primary, on_primary, etc.) |
| `hyprlock.conf` | Lock screen configuration |
| `hypridle.conf` | Idle timeout and lock behavior |
| `hyprpaper.conf` | Wallpaper configuration |

### conf/ - Modular Configuration
| File | Description |
|------|-------------|
| `monitor.conf` | Sources monitor preset from `monitors/` |
| `environment.conf` | Sources environment preset from `environments/` |
| `keyboard.conf` | Keyboard layout and input settings |
| `autostart.conf` | Apps and services to start with Hyprland |
| `window.conf` | Sources window preset from `windows/` |
| `decoration.conf` | Sources decoration preset from `decorations/` |
| `layout.conf` | Sources layout preset from `layouts/` |
| `workspace.conf` | Sources workspace config from `workspaces/` |
| `animation.conf` | Sources animation preset from `animations/` |
| `misc.conf` | Misc settings (disable logo, splash) |
| `keybinding.conf` | Sources keybinding preset from `keybindings/` |
| `windowrule.conf` | Sources window rules from `windowrules/` |
| `cursor.conf` | Cursor theme settings |
| `custom.conf` | User custom overrides (loaded last) |
| `ml4w.conf` | ML4W-specific integrations |

### conf/keybindings/default.conf - Key Bindings (SUPER = mainMod)
| Binding | Action |
|---------|--------|
| `SUPER+Return` | Terminal |
| `SUPER+B` | Browser |
| `SUPER+E` | File manager |
| `SUPER+Space` | App launcher (rofi/walker) |
| `SUPER+Q` | Kill window |
| `SUPER+F` | Fullscreen |
| `SUPER+M` | Maximize (fake fullscreen) |
| `SUPER+T` | Toggle floating |
| `SUPER+V` | Clipboard manager |
| `SUPER+1-0` | Switch workspace |
| `SUPER+SHIFT+1-0` | Move window to workspace |
| `SUPER+CTRL+Q` | Logout menu (wlogout) |
| `SUPER+CTRL+L` | Lock screen |
| `SUPER+SHIFT+W` | Random wallpaper |
| `SUPER+CTRL+W` | Wallpaper selector (waypaper) |
| `SUPER+Print` | Screenshot |

### conf/decorations/ - Window Decoration Presets
| File | Description |
|------|-------------|
| `default.conf` | **ACTIVE** - rounding=4, blur, shadows enabled |
| `blur.conf` | More pronounced blur, rounding=10 |
| `no-blur.conf` | Blur disabled |
| `no-rounding.conf` | Square corners |
| `rounding.conf` | Rounded corners only |
| `gamemode.conf` | Minimal decorations for gaming performance |

### conf/windows/ - Window Layout Presets
| File | Description |
|------|-------------|
| `default.conf` | **ACTIVE** - gaps_in=2, gaps_out=0, border_size=1, dwindle layout |
| `no-border.conf` | No window borders |
| `glass.conf` | Glass effect styling |
| `transparent.conf` | Transparent window backgrounds |
| `gamemode.conf` | Minimal gaps for gaming |
| `border-*.conf` | Various border size presets |

### conf/animations/ - Animation Presets
| File | Description |
|------|-------------|
| `default.conf` | Standard animations |
| `disabled.conf` | All animations off |
| `animations-fast.conf` | Quick transitions |
| `animations-smooth.conf` | Smooth, slower animations |

### scripts/ - Hyprland Scripts
| File | Description |
|------|-------------|
| `launcher.sh` | Opens app launcher (rofi/walker based on settings) |
| `wallpaper.sh` | Wallpaper management |
| `waypaper.sh` | Wallpaper selector GUI |
| `screenshot.sh` | Screenshot with various modes |
| `power.sh` | Power menu actions (lock, suspend, etc.) |
| `gamemode.sh` | Toggle gaming optimizations |
| `toggle-animations.sh` | Enable/disable animations |
| `gtk.sh` | Apply GTK theme settings |
| `keybindings.sh` | Show keybindings in rofi |
| `hyprshade.sh` | Screen shader toggle (blue light filter) |

## .config/kitty/ - Terminal

| File | Description |
|------|-------------|
| `kitty.conf` | Main config - JetBrainsMono font, 70% opacity, **hide_window_decorations=yes** |
| `colors-matugen.conf` | Matugen-generated terminal colors |

## .config/zshrc/ - Modular ZSH Config

Files loaded in numeric order:
| File | Description |
|------|-------------|
| `00-init` | Oh-my-zsh setup, plugins (git, zsh-autosuggestions, zsh-syntax-highlighting) |
| `15-dev-tools` | Development tool paths (uv, pnpm) - only in distrobox |
| `20-customization` | Oh-my-posh prompt, fastfetch greeting |
| `25-aliases` | Shell aliases (eza for ls, quick commands) |
| `30-autostart` | Shell startup commands |

## .config/waybar/ - Status Bar

| File | Description |
|------|-------------|
| `launch.sh` | Launch waybar with theme |
| `toggle.sh` | Show/hide waybar |
| `modules.json` | Module definitions |
| `themes/` | Multiple theme presets (ml4w, etc.) |

## .config/rofi/ - App Launcher

| File | Description |
|------|-------------|
| `config.rasi` | Main rofi config |
| `config-compact.rasi` | Compact layout variant |
| `config-cliphist.rasi` | Clipboard manager layout |
| `colors.rasi` | Matugen-generated colors |

## .config/gtk-3.0/ and gtk-4.0/ - GTK Themes

| File | Description |
|------|-------------|
| `settings.ini` | GTK theme (Adwaita), icon theme (Colloid), cursor (ArcStarry), dark mode |
| `gtk.css` | Custom GTK styling |
| `colors.css` | Matugen-generated GTK colors |

## .config/ml4w/ - ML4W Dotfiles Framework

### settings/ - Application Settings
Shell scripts that return the configured application:
| File | Description |
|------|-------------|
| `terminal.sh` | Default terminal (kitty) |
| `browser.sh` | Default browser |
| `filemanager.sh` | Default file manager |
| `editor.sh` | Default editor |

### scripts/ - ML4W Scripts
| File | Description |
|------|-------------|
| `cliphist.sh` | Clipboard history with rofi |
| `wlogout.sh` | Logout menu |
| `toggle-theme.sh` | Light/dark theme toggle |
| `focus.sh` | Window switcher |

### themes/ - ML4W Themes
| Directory | Description |
|-----------|-------------|
| `modern/` | Modern theme |
| `glass/` | Glass effect theme |
| `transparent/` | Transparent theme |

## .config/distrobox/

| File | Description |
|------|-------------|
| `distrobox.ini` | Distrobox container definitions |

## .config/nvim/ - Neovim (LazyVim)

| File | Description |
|------|-------------|
| `init.lua` | LazyVim bootstrap |
| `lazy-lock.json` | Plugin version lock |
| `lua/` | Lua configuration modules |

## .config/ohmyposh/ - Shell Prompt

Custom Oh-My-Posh prompt configuration.

## Other Configs

| Directory | Description |
|-----------|-------------|
| `.config/btop/` | System monitor config |
| `.config/swaync/` | Notification center config |
| `.config/wlogout/` | Logout menu styling |
| `.config/walker/` | Walker launcher config |
| `.config/waypaper/` | Wallpaper selector config |
| `.config/fastfetch/` | System info display config |
| `.config/qt6ct/` | Qt6 theme settings (Breeze) |
| `.config/xsettingsd/` | X settings daemon config |
| `.config/sidepad/` | Sidepad scratchpad config |
| `.config/nwg-dock-hyprland/` | Dock configuration |
| `.config/matugen/` | Matugen color generation config |

## Color System

Uses **Matugen** for automatic color generation from wallpaper:
- Generates `colors.conf` for Hyprland
- Generates `colors.rasi` for Rofi
- Generates `colors-matugen.conf` for Kitty
- Generates `colors.css` for GTK

## Important Notes

1. **No window title bar buttons** - Hyprland is a tiling WM, uses keyboard shortcuts instead:
   - `SUPER+M` = Maximize
   - `SUPER+Q` = Close
   - `SUPER+T` = Toggle float

2. **Kitty hides decorations** - `hide_window_decorations=yes` in kitty.conf

3. **Development happens in distrobox** - Host stays clean, dev tools installed to container-only paths (/usr/local). Export with `distrobox-export --bin /usr/local/bin/<tool>` when needed on host.

4. **ML4W framework** - Many settings controlled via ML4W Settings app (`SUPER+CTRL+S`)
