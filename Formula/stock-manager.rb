class StockManager < Formula
  desc "Stock portfolio management and automated trading system"
  homepage "https://github.com/shartith/StockManager"
  url "https://github.com/shartith/StockManager/releases/download/v1.1.1/stock-manager-1.1.1.tar.gz"
  sha256 "ae4eada2e3c9e51fe2099244c019e9dab9936bf2678e97f950a46870a43c28f2"
  license "MIT"
  version "1.1.1"

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
