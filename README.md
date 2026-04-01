# Homebrew Tap for Stock Manager

Stock portfolio management and automated trading system.

## Installation

```bash
brew tap shartith/stockmanager
brew install stock-manager
```

## Usage

```bash
# Start the server
stock-manager

# Open in browser
open http://localhost:3000
```

## Optional Dependencies

```bash
# Install Ollama for AI-powered trading decisions
brew install ollama
ollama serve
ollama pull qwen3:4b
```

## Uninstall

```bash
brew uninstall stock-manager
brew untap shartith/stockmanager
```
