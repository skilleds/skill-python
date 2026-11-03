#!/usr/bin/env bash
# ci-template.test.sh (python) — o template de CI e o hook que a skill distribui obedecem à própria skill.
# O quê: reprova template que (a) dispare por commit/PR (piso 27, via check-ci-triggers.sh) ou (b) traga
#   o furo específico achado na revisão de 2026-10-31 (ver asserts abaixo). Gate sem teste é decoração.
# Saída: exit 0 todos passam, 1 algum falhou.
# strict-ok: harness de teste, soma os casos (`schematize-shell` -> `references/piso.md` secao 1)
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CI="$HERE/../assets/ci/github-actions-ci.yml"; rc=0
falha() { echo "  FALHOU $1"; rc=1; }
bash "$HERE/check-ci-triggers.sh" "$CI" >/dev/null 2>&1 || falha "template reprovado pelo check-ci-triggers (piso 27)"
grep -qE '^[[:space:]]*pull_request' "$CI" && falha "template tem pull_request"
grep -q "|| true" "$CI" && falha "CI engole falha com || true"
grep -q "pip install" "$CI" && falha "CI usa pip em vez de uv"
grep -q "uv sync --frozen" "$CI" || falha "CI sem uv sync --frozen"
[ "$rc" -eq 0 ] && echo "ci-template.test(python): OK" || echo "ci-template.test(python): FALHOU"
exit "$rc"
