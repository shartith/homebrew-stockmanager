class StockManager < Formula
  desc "Stock portfolio management and automated trading system"
  homepage "https://github.com/shartith/StockManager"
  url "https://github.com/shartith/StockManager/releases/download/v4.18.0/stock-manager-4.18.0.tar.gz"
  sha256 "66cdf1ca95f80fa62b59cbb22a9a0b889c8dd42f0e0024e70ef3c8f7ff5be9bd"
  license "MIT"
  version "4.18.0"

  depends_on "node"
  # Python is still used at build time as a fallback for better-sqlite3 native compilation.
  depends_on "python@3.12"

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
      Stock Manager v4.18.0 — USE_CASES 구조 보완 3건

      auto_trades.failure_reason 구조화 (enum 10종).
      LLM provider 자동 스위치: primary → fallback → 기술적 fallback.
      llmFallbackUrl/Model/ApiKey 설정 시 외부 LLM 장애 대비 가능.
      weekendLearning smoke 테스트. 663 tests pass.

      시작:  stock-manager
      접속:  http://localhost:3000
    EOS
  end

  test do
    assert_match "stock-manager", shell_output("#{bin}/stock-manager --help 2>&1", 1)
  end
end
