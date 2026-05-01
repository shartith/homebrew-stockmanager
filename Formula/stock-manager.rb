class StockManager < Formula
  desc "Stock portfolio management and automated trading system"
  homepage "https://github.com/shartith/StockManager"
  url "https://github.com/shartith/StockManager/releases/download/v4.19.2/stock-manager-4.19.2.tar.gz"
  sha256 "684af7613fd4d2b3b004cb3d93c278ea064682b87243d09395c88e8de99664d6"
  license "MIT"
  version "4.19.2"

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
      Stock Manager v4.19.2 — 추천 갱신 watchlist 가드 누락 fix

      13일간 추천종목 INSERT 0건 회귀 해결. watchlistTickers SELECT 에
      `deleted_at IS NULL` 가드 추가, /:id/watch 부활 전략 적용.
      757 tests pass (+5). v4.19.0 양방향 NAS sync 유지.

      시작:  stock-manager
      접속:  http://localhost:3000
    EOS
  end

  test do
    assert_match "stock-manager", shell_output("#{bin}/stock-manager --help 2>&1", 1)
  end
end
