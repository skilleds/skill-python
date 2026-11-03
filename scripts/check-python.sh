#!/usr/bin/env bash
# schematize-python — o gate. Cobra o piso de `references/piso.md` sobre o Python do repo.
#
# strict-ok: COLETOR — varre tudo e soma os achados; com `set -e` abortaria no primeiro e
# reportaria um problema em vez de todos (`schematize-shell` -> `references/piso.md` secao 1)
set -uo pipefail

raiz="${1:-.}"
AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUFF_CASA="$AQUI/../assets/lint/ruff.toml"
erros=(); avisos=()

# tirar_docstring — imprime o arquivo sem o conteudo dos blocos de docstring (""" e ''').
#
# Existe porque o gate se acusou sozinho no primeiro run: a docstring do exemplo BOM dizia
# "nunca string com shell=True", e a regra casou com o proprio texto. Gate que confunde
# documentacao com codigo produz achado inventado — e achado inventado e o comeco do gate ignorado.
tirar_docstring() {
  local arq="$1" linha dentro=0 marca="" aspas3 apos3
  aspas3=$(printf '%s' '"""')
  apos3=$(printf '%s' "'''")
  while IFS= read -r linha; do
    if [ "$dentro" = 1 ]; then
      case "$linha" in *"$marca"*) dentro=0 ;; esac
      continue
    fi
    case "$linha" in
      # docstring que abre e fecha na MESMA linha: some o conteudo, mantem a linha.
      *"$aspas3"*"$aspas3"*) printf '%s\n' "$(printf '%s' "$linha" | sed 's/""".*"""//')"; continue ;;
      *"$apos3"*"$apos3"*)   printf '%s\n' "$(printf '%s' "$linha" | sed "s/'''.*'''//")"; continue ;;
      *"$aspas3"*) marca="$aspas3"; dentro=1; continue ;;
      *"$apos3"*)  marca="$apos3";  dentro=1; continue ;;
    esac
    printf '%s\n' "$linha"
  done < "$arq"
}


# chamadas_sem <regex-da-chamada> <regex-que-libera> — le o codigo no stdin e imprime o numero da linha de
# cada chamada cujo PARENTESES COMPLETO (ate 20 linhas) nao contem o que libera. Antes o gate liberava o
# ARQUIVO INTEIRO se a palavra `timeout`/`SafeLoader` aparecesse em qualquer outro ponto: uma chamada
# correta escondia todas as erradas (falso verde, P1-11 da revisao de 2026-10-31).
chamadas_sem() {
  CP_RE="$1" CP_OK="$2" awk '
    BEGIN { re = ENVIRON["CP_RE"]; ok = ENVIRON["CP_OK"] }
    { linha[NR] = $0 }
    END {
      for (i = 1; i <= NR; i++) {
        if (match(linha[i], re) == 0) continue
        buf = substr(linha[i], RSTART); depth = 0; j = i
        while (1) {
          n = length(buf); o = gsub(/\(/, "(", buf); c = gsub(/\)/, ")", buf); depth = o - c
          if (depth <= 0 || j >= NR || j - i >= 20) break
          j++; buf = buf "\n" linha[j]
        }
        if (buf !~ ok) print i
      }
    }'
}

arquivos=()
while IFS= read -r -d '' f; do arquivos+=("$f"); done < <(
  find "$raiz" -type f -name '*.py' \
    -not -path '*/.git/*' -not -path '*/.venv/*' -not -path '*/venv/*' \
    -not -path '*/node_modules/*' -not -path '*/versions/*' -not -path '*/__pycache__/*' -print0 2>/dev/null
)
notebooks=()
while IFS= read -r -d '' f; do notebooks+=("$f"); done < <(
  find "$raiz" -type f -name '*.ipynb' -not -path '*/.git/*' -not -path '*/.venv/*' -print0 2>/dev/null
)

if [ "${#arquivos[@]}" -eq 0 ] && [ "${#notebooks[@]}" -eq 0 ]; then
  echo "✖ nenhum .py nem .ipynb em $raiz — nada para verificar (ausência de material não é aprovação)." >&2
  exit 2
fi

# ------------------------------------------------------------------ 1. ruff (o gate)
# Sem ruff NÃO há gate: sai 2 ("ausência de material não é aprovação"). Antes avisava e saía 0.
if ! command -v ruff >/dev/null 2>&1; then
  echo "✖ ruff NÃO instalado — o gate não consegue verificar nada. Instale: uv tool install ruff (references/stack-versoes.md)" >&2
  exit 2
fi
# Config: a do projeto, se existir; senão a DA CASA (S/B/ASYNC/PGH/RUF100). Sem isso o ruff roda só E/F
# e o gate declarava "ruff limpo" sem ter aplicado o piso (P1-12).
cfg=()
if [ -f "$raiz/ruff.toml" ] || [ -f "$raiz/.ruff.toml" ] || { [ -f "$raiz/pyproject.toml" ] && grep -q '^\[tool\.ruff' "$raiz/pyproject.toml"; }; then
  :
else
  cfg=(--config "$RUFF_CASA")
  avisos+=("projeto sem config de ruff: usando a da casa (assets/lint/ruff.toml). Estenda-a no pyproject.toml")
fi
saida="$(ruff check "${cfg[@]}" --output-format=concise "${arquivos[@]}" 2>&1)"
rc=$?
if [ "$rc" != 0 ] && [ -n "$saida" ]; then
  while IFS= read -r l; do [ -n "$l" ] && [[ "$l" != Found\ * ]] && erros+=("ruff: $l"); done <<< "$(head -30 <<< "$saida")"
fi
fmt="$(ruff format "${cfg[@]}" --check "${arquivos[@]}" 2>&1)"
[ $? != 0 ] && [ -n "$fmt" ] && avisos+=("ruff format: $(head -3 <<< "$fmt" | tr '\n' ' ')")

# ------------------------------------------------------------------ 2. dependência e lock
if [ -f "$raiz/pyproject.toml" ]; then
  [ -f "$raiz/uv.lock" ] || [ -f "$raiz/poetry.lock" ] \
    || erros+=("pyproject.toml sem lockfile commitado — sem lock, 'funciona na minha máquina' é literal: o transitivo sobe sozinho no runner (piso.md secao 1)")
  grep -q 'requires-python' "$raiz/pyproject.toml" \
    || erros+=("pyproject.toml sem \`requires-python\` — a versão de Python é declarada, não herdada do PATH")
else
  [ "${#arquivos[@]}" -gt 3 ] && avisos+=("sem pyproject.toml — projeto Python de verdade declara dependência e versão")
fi
[ -f "$raiz/requirements.txt" ] && [ ! -f "$raiz/uv.lock" ] \
  && avisos+=("requirements.txt sem lock: faixa de versão não é lockfile (piso.md secao 1)")

# ------------------------------------------------------------------ 3. piso próprio
for f in "${arquivos[@]}"; do
  nome="${f#"$raiz"/}"
  # `codigo` = o arquivo SEM comentário e SEM docstring. A segunda remoção existe porque o gate se
  # acusou sozinho no primeiro run: a docstring do exemplo BOM dizia "nunca string com shell=True",
  # e a regra casou com o próprio texto. Gate que confunde documentação com código produz achado
  # inventado — e achado inventado é o começo do gate ignorado.
  codigo="$(tirar_docstring "$f" | sed -e 's/#.*$//')"

  grep -qE '(^|[^_a-zA-Z])(eval|exec)\s*\(' <<< "$codigo" \
    && ! grep -qE '(eval|exec)\s*\(.*#\s*python-ok:\s*\S+' "$f" \
    && erros+=("$nome: usa \`eval\`/\`exec\` — VETADO sobre dado externo (piso.md secao 5)")
  grep -qE 'shell\s*=\s*True' <<< "$codigo" \
    && erros+=("$nome: \`subprocess(..., shell=True)\` — passe LISTA de argumentos; com shell=True, um espaço no dado vira comando")
  while IFS= read -r n; do [ -n "$n" ] && erros+=("$nome:$n: \`yaml.load\` sem SafeLoader — é execução de código, não parsing"); done \
    < <(chamadas_sem 'yaml\.load[[:space:]]*\(' 'SafeLoader' <<< "$codigo")
  grep -qE '(^|[^_a-zA-Z])pickle\.(load|loads)\s*\(' <<< "$codigo" \
    && avisos+=("$nome: \`pickle.load\` — pickle é EXECUÇÃO de código: nunca sobre dado que veio de fora")
  grep -qE 'except\s+(Exception|BaseException)?\s*:\s*$' <<< "$codigo" && grep -qE '^\s*pass\s*$' <<< "$codigo" \
    && avisos+=("$nome: possível \`except: pass\` — erro engolido (piso.md secao 7)")
  while IFS= read -r n; do [ -n "$n" ] && erros+=("$nome:$n: chamada HTTP sem \`timeout\` — requests/httpx NÃO têm timeout por default: a chamada pendura para sempre e o worker morre segurando a conexão"); done \
    < <(chamadas_sem '(requests|httpx)\.(get|post|put|patch|delete)[[:space:]]*\(' 'timeout' <<< "$codigo")
  grep -qE '(^|[^_a-zA-Z])random\.(random|randint|choice|sample|shuffle)\s*\(' <<< "$codigo" \
    && grep -qiE 'token|senha|password|secret|otp|nonce|salt' "$f" \
    && erros+=("$nome: \`random\` em contexto de segurança — use \`secrets\` (o Mersenne Twister é previsível a partir da saída)")
  grep -qE 'def \w+\([^)]*=\s*(\[\]|\{\})' <<< "$codigo" \
    && erros+=("$nome: argumento default MUTÁVEL (\`=[]\`/\`={}\`) — ele é criado UMA vez e sobrevive entre chamadas")
  # Supressão NUA: `# noqa` sem código e `# type: ignore` sem [código] — VETADOS (piso.md secoes 2 e 3).
  # Lê o arquivo CRU (o `codigo` acima já perdeu os comentários).
  grep -qP '#\s*noqa(?!\s*:)' "$f" 2>/dev/null \
    && erros+=("$nome: \`# noqa\` sem código — suprima a regra específica (\`# noqa: S101\`) com o porquê (piso.md secao 2)")
  grep -qP '#\s*type:\s*ignore(?!\[)' "$f" 2>/dev/null \
    && erros+=("$nome: \`# type: ignore\` sem [código] — diga qual erro e por quê (piso.md secao 3)")
  # Deploy/ops por script (pisos 23 e 24 da engineering): script Python NÃO manda código à VPS, NÃO muda
  # servidor por ssh, NÃO aplica SQL ad-hoc: pede OPERAÇÃO NOMEADA ao `<projeto>_ops`. Exceção ESCOPADA:
  # ponte direta à máquina de build/teste dev/hml (piso 29), marcada na linha com `# ponte-build-ok: <host de maquinas.yml>`.
  semdoc="$(tirar_docstring "$f" | grep -vE '^[[:space:]]*#' )"
  while IFS= read -r l; do
    [ -n "$l" ] || continue
    grep -q 'ponte-build-ok:' <<< "$l" && continue
    erros+=("$nome: ${l:0:80} — deploy/ops por script é VETADO (pisos 23/24): peça uma operação nomeada ao <projeto>_ops; só a máquina de build dev/hml aceita ponte direta, com \`# ponte-build-ok: <host>\`")
  done < <(grep -nE "(^|[^_a-zA-Z])(import|from)[[:space:]]+(paramiko|fabric|invoke)\b|[\"'](ssh|scp|sftp|rsync|kubectl)[\"']|os\.(system|popen)[[:space:]]*\([^)]*(ssh|scp|rsync|kubectl)|docker[[:space:]]+(save|load)" <<< "$semdoc" | sed 's/^\([0-9]*\):/L\1 /')
  grep -qE '/tmp/[A-Za-z0-9_.-]+' <<< "$codigo" && ! grep -q 'tempfile' "$f" \
    && avisos+=("$nome: caminho fixo em /tmp sem \`tempfile\` — /tmp é mundialmente gravável")
done

# ------------------------------------------------------------------ 4. notebook
for nb in "${notebooks[@]:-}"; do
  [ -n "$nb" ] || continue
  nome="${nb#"$raiz"/}"
  if grep -q '"output_type"' "$nb" 2>/dev/null; then
    erros+=("$nome: notebook commitado COM saída — amostra de dado real e token colado vazam por aí; use nbstripout (dados-notebook.md secao 1)")
  fi
  grep -qE '"(sk-|ghp_|AKIA)[A-Za-z0-9]{10,}' "$nb" 2>/dev/null \
    && erros+=("$nome: possível credencial dentro do notebook")
done

for a in "${avisos[@]:-}"; do [ -n "$a" ] && echo "  ! $a" >&2; done
if [ "${#erros[@]}" -gt 0 ]; then
  echo "" >&2
  echo "✖ PYTHON REPROVADO — ${#erros[@]} problema(s):" >&2
  for e in "${erros[@]}"; do echo "  · $e" >&2; done
  exit 1
fi
echo "✔ python: ${#arquivos[@]} arquivo(s) e ${#notebooks[@]} notebook(s) no piso$(command -v ruff >/dev/null 2>&1 && echo ' (ruff limpo)' || echo ' — SEM ruff, cobertura reduzida')."
