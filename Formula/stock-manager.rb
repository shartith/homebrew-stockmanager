class StockManager < Formula
  desc "Stock portfolio management and automated trading system"
  homepage "https://github.com/shartith/StockManager"
  url "https://github.com/shartith/StockManager/releases/download/v3.0.3/stock-manager-3.0.3.tar.gz"
  sha256 "0283eb7d98c33abbb8891f94366afc26f1953cab3222fa7ae05ebf3b373de79b"
  license "MIT"
  version "3.0.3"

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
