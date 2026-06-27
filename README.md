# my-hyprland-os

<img width="1920" height="1080" alt="Screenshot_19-Jan_11-34-31_18840" src="https://github.com/user-attachments/assets/d1ba7d7d-733f-4aea-a380-24971e6e17f9" />

<img width="1920" height="1080" alt="Screenshot_21-Jan_21-48-02_3634" src="https://github.com/user-attachments/assets/ca4c2235-7923-4c6a-97ec-b52b8f36ea16" />

A custom, immutable uBlue base image built with BlueBuild. This image is pre-configured with a modern Hyprland desktop environment infrastructure, essential CLI tools, and a suite of GUI applications.

It is designed to be a "batteries-included" base system that decouples the immutable OS layer from your high-frequency desktop customizations (dotfiles).

## 📦 What's Inside?

### Base System
* **Base Image:** `ghcr.io/ublue-os/base-main` (uBlue base image)
* **Shell:** Zsh (pre-installed)
* **Editor:** Vim (vim-enhanced)

### Desktop Environment Infrastructure
* **Window Manager:** Hyprland (Bleeding edge via Solopasha COPR)
* **Terminal:** Kitty
* **Launcher:** Rofi
* **Wallpaper:** Hyprpaper
* **Idle Daemon:** Hypridle
* **Status Bar:** Waybar
* **System Tray:** Network Manager Applet

### Core Utilities & Custom Additions
* **Wallust:** Pre-installed via COPR for dynamic color scheme generation.
* **Messaging & IPC:** `libnotify` (desktop notifications) and `dbus-tools` (session bus polling).
* **Included GUI Applications:** Waterfox (Flatpak), Nautilus, Xarchiver, MPV, Eye of GNOME, GNOME Calculator, Pavucontrol, GNOME Text Editor.
* **System Management:** Htop, Distrobox, Flatseal.
* **Screen Capture:** Wf-recorder, slurp, grim, swappy.

---

## 🏗️ Architecture: Decoupled Dotfiles

To prevent rebuilding the entire operating system image for minor visual adjustments, this OS uses a **Decoupled Bootstrap Architecture**:
1. **The OS Image (`my-hyprland-os`):** Ships only system-level dependencies, binaries, and a clean `/etc/skel` folder containing a single first-login systemd service.
2. **The User Rice (`Dotfiles`):** Cloned manually after installation to allow instant, real-time configuration edits via symlinks.

---

## 🚀 Installation (Rebase)

To switch to this image, run the following command:

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

---

## ⚙️ Post-Install Configuration

Because desktop configs are managed externally, your initial boot will load a vanilla Hyprland fallback desktop. 

To apply the full environment, clone your dotfiles manually into your home folder and link them:

```bash
git clone https://github.com/hillz2/Dotfiles.git ~/Dotfiles
```

Refer to the `Dotfiles` repository documentation for the exact routing commands to activate your environment.

---

## 🐳 Using bootc (Experimental)

To switch to this image using `bootc`:

```bash
sudo bootc switch ghcr.io/hillz2/my-hyprland-os:latest
```

To update your system using `bootc`:

```bash
sudo bootc upgrade
```
