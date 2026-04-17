class StockManager < Formula
  desc "Stock portfolio management and automated trading system"
  homepage "https://github.com/shartith/StockManager"
  url "https://github.com/shartith/StockManager/releases/download/v4.17.1/stock-manager-4.17.1.tar.gz"
  sha256 "0340cb006c5dcce8ac0b161273ca29dd65aec22a7cdc19b2447e89b0557f66fe"
  license "MIT"
  version "4.17.1"

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
      Stock Manager v4.17.1 — USE_CASES gap 보강 (테스트 +51) + cleanup 버그 fix

      v4.17.0 백테스트 파이프라인 유지.
      UC-07/11/12 테스트 gap 보강 (631 tests pass).
      watchlistCleanup: 추천 없는 종목이 3일 후 삭제되던 버그 수정.

      시작:  stock-manager
      접속:  http://localhost:3000
    EOS
  end

  test do
    assert_match "stock-manager", shell_output("#{bin}/stock-manager --help 2>&1", 1)
  end
end
