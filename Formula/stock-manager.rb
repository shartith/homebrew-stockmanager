class StockManager < Formula
  desc "Stock portfolio management and automated trading system"
  homepage "https://github.com/shartith/StockManager"
  url "https://github.com/shartith/StockManager/releases/download/v3.0.4/stock-manager-3.0.4.tar.gz"
  sha256 "36a749de65854b587d5cb2591c5657e52d4f12203cb5665ac0a042d2ce2479f0"
  license "MIT"
  version "3.0.4"

  depends_on "node"

  def install
    # Install npm dependencies and build
    system "npm", "install", "--production=false"
    system "npm", "run", "build"

    # Remove devDependencies after build
    system "npm", "prune", "--production"

    # Install to libexec (keeps node_modules isolated)
    libexec.install Dir["*"]

    # Create wrapper script
    (bin/"stock-manager").write <<~EOS
      #!/bin/bash
      export STOCK_MANAGER_DATA="${HOME}/.stock-manager"
      mkdir -p "$STOCK_MANAGER_DATA"
      exec "#{Formula["node"].bin}/node" "#{libexec}/bin/stock-manager" "$@"
    EOS
  end

  def post_install
    # Create data directory
    (var/"stock-manager").mkpath
  end

  def caveats
    <<~EOS
      Stock Manager has been installed!

      Start the server:
        stock-manager

      Then open http://localhost:3000 in your browser.

      Data is stored in: ~/.stock-manager/

      Optional: Install Ollama for AI-powered trading decisions:
        brew install ollama
        ollama serve
        ollama pull qwen3:4b
    EOS
  end

  test do
    assert_match "stock-manager", shell_output("#{bin}/stock-manager --help 2>&1", 1)
  end
end
