# NoteGround

Installable Obsidian plugin bundle for NoteGround.

This repository contains the published plugin artifacts in `bundle/`:

- `bundle/main.js`
- `bundle/manifest.json`
- `bundle/styles.css`

## Install

### Option A: Install Script

```bash
chmod +x install.sh
./install.sh /path/to/your/vault
```

Or install directly into the currently open Obsidian vault:

```bash
chmod +x install.sh
./install.sh --active-vault
```

This copies the bundle files into:

```bash
<vault>/.obsidian/plugins/note-ground/
```

### Option B: npx

```bash
npx note-ground --active-vault
```

Or target a specific vault:

```bash
npx note-ground /path/to/your/vault
```

### Option C: Manual

1. Download `bundle/main.js`, `bundle/manifest.json`, and `bundle/styles.css` from this repository or its releases.
2. Create the folder `<your-vault>/.obsidian/plugins/note-ground/`.
3. Copy the three files into that folder.
4. Open Obsidian and enable **NoteGround** in **Settings > Community plugins**.

## Requirements

Install at least one supported AI CLI locally:

- Claude Code
- OpenAI Codex
- Gemini CLI

## Version

This bundle release is `0.3.1`.
