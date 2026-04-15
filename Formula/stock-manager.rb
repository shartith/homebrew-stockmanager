class StockManager < Formula
  desc "Stock portfolio management and automated trading system"
  homepage "https://github.com/shartith/StockManager"
  url "https://github.com/shartith/StockManager/releases/download/v4.13.1/stock-manager-4.13.1.tar.gz"
  sha256 "16d0a18c75bdaaa234433f7741e8ab9f3f6e7bc5b8880134df63d2ccc1a539b7"
  license "MIT"
  version "4.13.1"

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
      Stock Manager v4.13.1 — 외부 LLM(Ollama/OpenAI 원격) 전환

      LLM은 원격 서버(Ollama 또는 OpenAI 호환)에 연결해 사용합니다.
      웹 설정 페이지에서 제공자 선택 + URL / 모델 / (옵션)API 키를 입력하세요.

      기본값: OpenAI 호환 — https://ai.unids.kr/v1
      Ollama: http://<host>:11434/v1

      v4.12.x MLX venv 정리 (선택):
        stock-manager --uninstall-mlx

      시작:  stock-manager
      접속:  http://localhost:3000
    EOS
  end

  test do
    assert_match "stock-manager", shell_output("#{bin}/stock-manager --help 2>&1", 1)
  end
end
