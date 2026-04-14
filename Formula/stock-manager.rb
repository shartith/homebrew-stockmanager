class StockManager < Formula
  desc "Stock portfolio management and automated trading system"
  homepage "https://github.com/shartith/StockManager"
  url "https://github.com/shartith/StockManager/releases/download/v4.12.0/stock-manager-4.12.0.tar.gz"
  sha256 "aa5d86dd727cf74f12c1238f303ccc0939c0e345222eb5e70234ab03c15a12b8"
  license "MIT"
  version "4.12.0"

  # MLX backend requires Apple Silicon.
  depends_on :macos
  on_intel do
    odie "Stock Manager v4.12.0+ requires Apple Silicon (MLX backend)."
  end

  depends_on "node"
  # Python is required at runtime for the MLX (mlx-lm) server venv,
  # and at build time as a fallback for better-sqlite3 native compilation.
  depends_on "python@3.12"

  def install
    system "npm", "install", "--production=false"
    system "npm", "run", "build"
    system "npm", "prune", "--production"
    libexec.install Dir["*"]

    # Provision an isolated Python venv with mlx-lm inside libexec so brew
    # upgrades regenerate it cleanly. HuggingFace model cache lives under
    # $HOME/.cache/huggingface and persists across upgrades.
    ohai "Installing mlx-lm into libexec venv (may take a moment)..."
    python = Formula["python@3.12"].opt_bin/"python3.12"
    system python, "-m", "venv", "#{libexec}/venv"
    system "#{libexec}/venv/bin/pip", "install", "--quiet", "--upgrade", "pip"
    system "#{libexec}/venv/bin/pip", "install", "--quiet", "mlx-lm"

    (bin/"stock-manager").write <<~EOS
      #!/bin/bash
      export STOCK_MANAGER_DATA="${HOME}/.stock-manager"
      export STOCK_MANAGER_VENV="#{libexec}/venv"
      mkdir -p "$STOCK_MANAGER_DATA"
      exec "#{Formula["node"].bin}/node" "#{libexec}/bin/stock-manager" "$@"
    EOS
  end

  def post_install
    (var/"stock-manager").mkpath
  end

  def caveats
    <<~EOS
      Stock Manager v4.12.0 — Apple MLX 기반 로컬 LLM

      최초 실행 시 MLX 기본 모델(mlx-community/gemma-3-4b-it-4bit, ~2.5GB)이
      HuggingFace에서 자동 다운로드됩니다. 네트워크에 따라 2~5분 소요될 수 있습니다.

      기존 Ollama 사용자: `stock-manager --uninstall-ollama` 실행 시
      바이너리와 ~/.ollama (모델 포함) 전부 제거됩니다.

      시작:  stock-manager
      접속:  http://localhost:3000
      문서:  https://github.com/shartith/StockManager/blob/v4.12.0/docs/MLX_MIGRATION.md
    EOS
  end

  test do
    assert_match "stock-manager", shell_output("#{bin}/stock-manager --help 2>&1", 1)
  end
end
