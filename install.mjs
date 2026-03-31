#!/usr/bin/env node

import fs from "node:fs";
import os from "node:os";
import path from "node:path";

const rawBaseUrl =
  process.env.NOTE_GROUND_RAW_BASE_URL ?? "https://raw.githubusercontent.com/dangquan1402/note-ground/main/bundle";

function usage() {
  console.log(`Usage:
  note-ground /path/to/vault
  note-ground --active-vault

Options:
  --active-vault   Detect the currently open Obsidian vault from app config`);
}

function getObsidianConfigPath() {
  switch (process.platform) {
    case "darwin":
      return path.join(os.homedir(), "Library", "Application Support", "obsidian", "obsidian.json");
    case "linux":
      return path.join(os.homedir(), ".config", "obsidian", "obsidian.json");
    case "win32":
      return path.join(process.env.APPDATA || path.join(os.homedir(), "AppData", "Roaming"), "obsidian", "obsidian.json");
    default:
      throw new Error(`Unsupported platform: ${process.platform}`);
  }
}

function detectActiveVault() {
  const configPath = getObsidianConfigPath();
  if (!fs.existsSync(configPath)) {
    throw new Error(`Obsidian config not found: ${configPath}`);
  }

  const parsed = JSON.parse(fs.readFileSync(configPath, "utf8"));
  const vaults = parsed.vaults && typeof parsed.vaults === "object" ? Object.values(parsed.vaults) : [];
  const active = vaults
    .filter((entry) => entry && typeof entry.path === "string")
    .sort((a, b) => Number(Boolean(b.open)) - Number(Boolean(a.open)) || Number(b.ts ?? 0) - Number(a.ts ?? 0))[0];

  if (!active || typeof active.path !== "string") {
    throw new Error("Could not detect the active Obsidian vault.");
  }

  return active.path;
}

async function fetchText(url) {
  const response = await fetch(url);
  if (!response.ok) {
    throw new Error(`Download failed: ${url} (${response.status})`);
  }
  return await response.text();
}

async function installFile(fileName, pluginDir) {
  const localPath = path.join(process.cwd(), "bundle", fileName);
  const targetPath = path.join(pluginDir, fileName);

  if (fs.existsSync(localPath)) {
    fs.copyFileSync(localPath, targetPath);
    return;
  }

  const content = await fetchText(`${rawBaseUrl}/${fileName}`);
  fs.writeFileSync(targetPath, content, "utf8");
}

async function main() {
  const arg = process.argv[2];
  if (!arg || arg === "-h" || arg === "--help") {
    usage();
    process.exit(arg ? 0 : 1);
  }

  const vaultPath = arg === "--active-vault" ? detectActiveVault() : arg;
  if (!fs.existsSync(vaultPath) || !fs.statSync(vaultPath).isDirectory()) {
    throw new Error(`Vault not found: ${vaultPath}`);
  }

  const pluginDir = path.join(vaultPath, ".obsidian", "plugins", "note-ground");
  fs.mkdirSync(pluginDir, { recursive: true });

  await installFile("main.js", pluginDir);
  await installFile("manifest.json", pluginDir);
  await installFile("styles.css", pluginDir);

  console.log(`Installed NoteGround into: ${pluginDir}`);
}

main().catch((error) => {
  console.error(error instanceof Error ? error.message : String(error));
  process.exit(1);
});
