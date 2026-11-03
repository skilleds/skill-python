# Notebook não é entregável — e o recorte de dados/ML

> Parte da skill **schematize-python**. A disciplina de dados (contratos, qualidade, lineage) é da
> **`schematize-data`**; a de modelo/eval, da **`schematize-ai`**. Aqui fica o que é **do Python**:
> o estatuto do notebook e as armadilhas de reprodutibilidade.

---

## 1. O estatuto do notebook

**Notebook é ferramenta de exploração. Não é entregável, não vai para produção, não é a fonte da
verdade de nada.**

O que ele é bom: olhar dado, testar hipótese, gerar gráfico, contar uma história para gente.
O que ele **não** é, e o motivo de cada um:

- **Não é código versionável de verdade.** O `.ipynb` é JSON com saída embutida: o diff é ilegível,
  o merge conflita por metadado, e o review vira "confia em mim".
- **Não é reprodutível por construção.** A ordem de execução **não é a ordem das células** — dá para
  rodar 3, depois 1, depois 2 e obter um estado que ninguém reconstrói. Célula apagada deixa a
  variável viva. *"Roda tudo de novo do zero" é uma sugestão, não uma garantia.*
- **Não é seguro.** A saída fica salva no arquivo: amostra de dado real de cliente, token colado
  numa célula, connection string. Notebook commitado é o vazamento mais silencioso da casa.

**MUST**
- Notebook no repo vai **sem saída** (`nbstripout` ou equivalente no pre-commit), e **nunca** com
  dado real de cliente.
- **Nada de credencial na célula:** o notebook lê do ambiente, como qualquer código.
- **Quando o notebook vira produto, ele vira MÓDULO:** o código sai para `src/`, ganha função,
  teste e tipo — e o notebook, se sobreviver, passa a **importar** o módulo. O caminho contrário
  (executar notebook em produção com `papermill` e afins) é solução de emergência, não arquitetura,
  e exige ADR com data de virada.

## 2. Reprodutibilidade de pipeline

- **Semente fixa e logada** onde há aleatoriedade (split, inicialização, amostragem) — sem ela o
  resultado não é comparável com o de ontem, e a "melhora" pode ser variância.
- **Dado versionado** ou, no mínimo, **identificado**: hash/data/consulta que o gerou. Métrica sem
  a versão do dado é número solto.
- **Ambiente travado** (`uv.lock`): mudança de versão de biblioteca numérica **muda resultado**, e
  em silêncio.
- **O pipeline roda de ponta a ponta por comando** (`make`/`uv run`), não por sequência de células
  que alguém lembra.

## 3. Pandas e afins — as três que mais mordem

- **`SettingWithCopyWarning` é bug, não ruído:** significa que você pode estar escrevendo numa cópia,
  e a escrita **some**. Trate warning como erro no CI de dados.
- **`dtype` inferido muda com o dado.** Uma coluna de código que vem só com números vira `int64`, e o
  `00123` perde o zero à esquerda; um `NaN` transforma `int` em `float`. **Declare o `dtype`** na
  leitura.
- **Comparação de ponto flutuante** e agregação em `float32` acumulam erro — para dinheiro, `Decimal`
  ou inteiro de centavos, nunca `float` (piso da `schematize-database`).

## 4. A fronteira com as irmãs

| Assunto | Dono |
|---|---|
| Contrato de dado, qualidade, lineage, backfill | `schematize-data` |
| Eval de modelo, guardrail, prompt, custo de LLM | `schematize-ai` |
| Piso de Python (lock, ruff, tipos, segurança) | **esta skill** |
| Onde o serviço de inferência mora e o que ele **não** faz | esta skill, `escopo.md` §4 |
