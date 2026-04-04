class StockManager < Formula
  desc "Stock portfolio management and automated trading system"
  homepage "https://github.com/shartith/StockManager"
  url "https://github.com/shartith/StockManager/releases/download/v4.1.0/stock-manager-4.1.0.tar.gz"
  sha256 "db2be30c3bcae3ecf66564adcb96094243bd57c651d73e526494bbb265b50a1d"
  license "MIT"
  version "4.1.0"

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
      Stock Manager v4.1.0 has been installed!

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
