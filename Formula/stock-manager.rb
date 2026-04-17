class StockManager < Formula
  desc "Stock portfolio management and automated trading system"
  homepage "https://github.com/shartith/StockManager"
  url "https://github.com/shartith/StockManager/releases/download/v4.17.0/stock-manager-4.17.0.tar.gz"
  sha256 "2863e7337cdf7fbedc63a46ba17eca7c4142ef814bd2a5b59313c5e8fb37b6e0"
  license "MIT"
  version "4.17.0"

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
      Stock Manager v4.17.0 — 백테스트 파이프라인 통합 (종목 필터)

      주말 자동 백테스트(관심/추천 최대 30종목) → DB 저장.
      Protection BacktestReject: PF<0.8 종목 매수 차단.
      스코어링에 PF 가점/감점 반영 (PF>=1.5 +15, PF<1.0 -20).
      실시간 결정 근거가 아닌 구조적 필터로 활용.

      시작:  stock-manager
      접속:  http://localhost:3000
    EOS
  end

  test do
    assert_match "stock-manager", shell_output("#{bin}/stock-manager --help 2>&1", 1)
  end
end
