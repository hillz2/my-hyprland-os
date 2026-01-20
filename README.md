# my-hyprland-os

<img width="1920" height="1080" alt="Screenshot_19-Jan_11-34-31_18840" src="https://github.com/user-attachments/assets/d1ba7d7d-733f-4aea-a380-24971e6e17f9" />

<img width="1920" height="1080" alt="Screenshot_20-Jan_14-07-19_24669" src="https://github.com/user-attachments/assets/38892d27-cd83-4993-905b-fd8d03f3df08" />



A custom, immutable Fedora Silverblue image built with BlueBuild. This image is pre-configured with a modern Hyprland desktop environment, essential CLI tools, and a suite of GUI applications.

It is designed to be a "batteries-included" starting point for a Hyprland setup on an atomic Fedora base.

## 📦 What's Inside?

### Base System
* **Base Image:** `ghcr.io/wayblueorg/hyprland` (Fedora Atomic)
* **Shell:** Zsh (pre-installed)
* **Editor:** Vim (vim-enhanced)

### Desktop Environment (Hyprland Ecosystem)
* **Window Manager:** Hyprland (Bleeding edge via Solopasha COPR)
* **Terminal:** Kitty
* **Launcher:** Rofi
* **Wallpaper:** Hyprpaper
* **Idle Daemon:** Hypridle
* **Status Bar:** Waybar (Configuration files included in skeleton)
* **System Tray:** Network Manager Applet

### Included Applications
* **Browser:** Waterfox (via Flatpak)
* **File Manager:** Thunar
* **Archive Manager:** Xarchiver
* **Media Player:** MPV
* **Image Viewer:** Eye of GNOME (eog)
* **Office/Calc:** Gnumeric, Gnome Calculator
* **Audio Control:** Pavucontrol
* **Text Editor:** Gnome Text Editor
* **System Management:** Htop, Distrobox, Flatseal

### Custom Binaries
* **Wallust:** Included directly in `/usr/bin/wallust` for generating color schemes from wallpapers.

---

## 🚀 Installation (Rebase)

To switch to this image, run the following command. This downloads the image and prepares it for the next boot.

Note that we use `ostree-unverified-registry` for the initial switch. This is necessary because your system doesn't have the custom signing key for this image yet. **The key is embedded inside the image**, so once you reboot, future updates will be verified automatically.

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/hillz2/my-hyprland-os:latest
```

Once the process completes, restart your system:

```bash
systemctl reboot
```

Now switch to the signed image:

```bash
rpm-ostree rebase ostree-image-signed:docker://ghcr.io/hillz2/my-hyprland-os:latest
```

What happens next?

After rebooting, if you run `rpm-ostree status`, you will see:

```plaintext
● ostree-image-signed:docker://ghcr.io/hillz2/my-hyprland-os:latest
```

---

## ⚙️ Configuration Setup (Post-Install)

This image places default configuration files (dotfiles) into `/etc/skel/.config/`.
**Linux only copies files from `/etc/skel` to your home directory when a NEW user is created.**

If you are rebasing an **existing user**, you must manually copy these configurations to your home directory to apply them.

### Step 1: Backup Existing Configs (Recommended)
Before copying, it is good practice to back up your current settings to avoid data loss.

```bash
mkdir -p ~/config-backup
[ -d ~/.config/hypr ] && mv ~/.config/hypr ~/config-backup/
[ -d ~/.config/waybar ] && mv ~/.config/waybar ~/config-backup/
[ -d ~/.config/kitty ] && mv ~/.config/kitty ~/config-backup/
[ -d ~/.config/rofi ] && mv ~/.config/rofi ~/config-backup/
```

### Step 2: Copy New Configs
Run this command to copy the included configurations to your active user folder:
1. Move hyprland config files
```bash
cp -r /etc/skel/.config/* ~/.config/
```
2. Move `.zshrc` and `.vimrc` to home directory
```bash
cp /etc/skel/.zshrc /etc/skel/.vimrc ~/
```
3. Move zsh plugins to home directory
```bash
mkdir -p ~/.local/share/zsh/plugins/
cp /etc/skel/.local/share/zsh/plugins/zsh-autosuggestions.zsh ~/.local/share/zsh/plugins/
cp /etc/skel/.local/share/zsh/plugins/zsh-syntax-highlighting.zsh ~/.local/share/zsh/plugins/
```

### Step 3: Switch Shell to Zsh (Optional)
If you want to use Zsh as your default shell:

```bash
lchsh $USER
# Enter /usr/bin/zsh when prompted
```

---

## 🔄 Updating

To update your system in the future, simply run the standard upgrade command. This will pull the latest version of your custom image from GitHub Container Registry.

```bash
rpm-ostree upgrade
```
