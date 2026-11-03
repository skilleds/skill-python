# Onde Python entra, e onde é VETADO

> Parte da skill **schematize-python**. Esta é a metade da skill que **não** é técnica: é a
> fronteira. O canônico do rol está em `schematize-engineering` → `references/linguagens.md` §2.1;
> aqui é o detalhe operacional.

---

## 1. A posição, em uma linha

**Python é sancionado como FERRAMENTA e VETADO como backend de produto novo — exatamente como Node.**

## 2. Onde ele entra (e onde não há substituto razoável)

- **Dados e ML:** pipeline, treino, avaliação, análise. O ecossistema não tem par, e trocá-lo por
  linguagem do rol seria perder biblioteca sem ganhar disciplina.
- **Automação e scripts de apoio:** o que passa do que shell aguenta bem (parsing sério, chamada de
  API com retry, manipulação de dado estruturado) e não justifica um serviço.
- **Ferramental interno:** gerador, verificador, motor de teste — o `simulated/run.py` que a
  `schematize-qa` distribui é o exemplo vivo, e é **código de produção do catálogo**.
- **Notebook para explorar** — e só para explorar (`dados-notebook.md`).

## 3. Onde é VETADO

- **API/serviço de produto novo.** Nasce no rol (Go, Rust, Elixir, C#, Zig, Ruby), com ADR de fit.
  Não é sobre desempenho nem sobre gosto: é que a casa **não quer** manter piso de produção
  (empacotamento, tipos que travam o CI, concorrência, deploy, observabilidade) em mais um
  ecossistema — e um serviço de produto vive dez anos.
- **Serviço que "só começou como script".** É assim que acontece de verdade: um `cron` vira endpoint,
  o endpoint vira dois, e um ano depois existe um backend que ninguém decidiu criar.

## 4. A exceção que existe, e a forma dela

**Servir modelo de ML é a exceção esperada** — e ela tem forma, para não virar cavalo de Troia:

- O serviço Python é **fino**: carrega o modelo, expõe inferência, e **não tem regra de negócio**.
- Ele fica **atrás** de um serviço do rol, que faz **authz, validação de entrada, orquestração,
  rate-limit e resposta ao cliente**. O Python não é a borda pública.
- **Contrato explícito** entre os dois (OpenAPI/protobuf), versionado — não "os dois times se
  falam".
- **ADR** registrando por que a inferência não roda embutida (tamanho do modelo, GPU, dependência
  nativa) — porque às vezes ela roda, e aí não há serviço nenhum a criar.

## 5. Legado em Python que já é backend

Não se reescreve por decreto. Vale a mesma regra do Node (`schematize-node`): **fica como está até
ser tocado**, e migra **por funcionalidade** — ~30% do módulo afetado → extrai aquela parte para um
serviço do rol; ~50% extraído → migra o resto. Ajuste pontual **não** porta. E, enquanto vive, ele
**cumpre o piso** de `piso.md`: lock, ruff, tipos que travam, teste. Legado sem piso é o que produz
a próxima reescrita de emergência.

## 6. O que não muda por ser "só um script"

Piso comum da casa vale igual: segredo fora do código, **efeito externo nunca sai de não-produção**
(`schematize-engineering` → `references/efeitos-externos.md`), teste, log sem PII, archive da
decisão. *"É só um script"* é a frase que antecede o incidente — o script roda em produção, com
credencial de produção, no cron das 3h.
