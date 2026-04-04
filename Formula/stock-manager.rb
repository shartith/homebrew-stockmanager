class StockManager < Formula
  desc "Stock portfolio management and automated trading system"
  homepage "https://github.com/shartith/StockManager"
  url "https://github.com/shartith/StockManager/releases/download/v4.0.2/stock-manager-4.0.2.tar.gz"
  sha256 "f9841f92a75003c4affb0f7ef1b22e831e77d6bda1007cbcca07b4e928b677b4"
  license "MIT"
  version "4.0.2"

  depends_on "node"

  def install
    system "npm", "install", "--production=false"
    system "npm", "run", "build"
    system "npm", "prune", "--production"
    libexec.install Dir["*"]
    (bin/"stock-manager").write <<~EOS
      #!/bin/bash
      export STOCK_MANAGER_DATA="${HOME}/.stock-manager"
      mkdir -p "$STOCK_MANAGER_DATA"
      exec "#{Formula["node"].bin}/node" "#{libexec}/bin/stock-manager" "$@"
    EOS
  end

  def post_install
    (var/"stock-manager").mkpath
  end

  def caveats
    <<~EOS
      Stock Manager v4.0.2 has been installed!

      Start the server:
        stock-manager

      Ollama will be automatically installed and started if needed.
      Then open http://localhost:3000 in your browser.

      Data is stored in: ~/.stock-manager/
    EOS
  end

  test do
    assert_match "stock-manager", shell_output("#{bin}/stock-manager --help 2>&1", 1)
  end
end
