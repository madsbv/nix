{ pkgs }:

with pkgs; [
  dockutil
  pinentry_mac
  pngpaste
  # LLM testing
  # llm.withPlugins
  # ([ "llm-gpt4all" ])
  ollama
  cargo-instruments
]
