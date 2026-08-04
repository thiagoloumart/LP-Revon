# LP Revon — HOF

Landing page da Revon para clínicas de Harmonização Orofacial (HOF).
Está no ar em <https://www.revon.com.br>.

Este repositório existe para **revisão técnica por terceiros** — o objetivo é ter uma opinião
externa sobre o que está certo, o que está errado e o que precisa ser feito antes de colocar
tráfego pago em cima da página.

---

## O que tem aqui

| Arquivo | O que é |
|---|---|
| `index.html` | A landing page inteira, em arquivo único (1,4 MB). Imagens (WebP) e fontes vêm embutidas em base64 — abre no navegador sem internet, é só dar duplo clique. |

O `index.html` é um **build gerado**, não é o arquivo de edição. O cabeçalho dele diz:

```
Fonte: revon_lp_hof.html · gerado por design/lp-standalone.mjs
```

O gerador e o HTML-fonte não fazem parte deste repositório.

## Stack

Nada. É HTML, CSS e um bloco de JavaScript vanilla, sem dependências, sem build no cliente,
sem framework. A página é estática e autocontida.

---

## Ponto principal pra revisão: o formulário não tem destino

A LP tem um formulário de diagnóstico que coleta **nome, clínica, e-mail, telefone,
faturamento e cargo**. Hoje ele **não tem endpoint configurado** — o `<form>` está sem o
atributo `data-endpoint`, e o script trata esse caso assim:

```js
var endpoint = form.getAttribute('data-endpoint');
...
if (!endpoint) { document.dispatchEvent(new CustomEvent('revon:lead', { detail: dados })); done(true); return; }
fetch(endpoint, { method:'POST', headers:{'Content-Type':'application/json'}, body: JSON.stringify(dados) })
```

Sem endpoint, ele emite um `CustomEvent` e segue pelo caminho de sucesso, sem nenhuma
requisição de rede. **Definir para onde os leads vão (CRM, webhook, e-mail) é a decisão
pendente** — e é o item mais urgente da lista.

Vale a revisão opinar também sobre o tratamento de erro, o anti-duplo-envio e a validação
dos campos, que já estão implementados no mesmo bloco.

---

## Outros pontos em aberto

1. **Sem analytics.** Não há Meta Pixel, Google Analytics nem qualquer outro rastreador —
   isso foi verificado, não é suposição. Para uma landing page de captação, provavelmente é
   uma lacuna e não uma escolha.
2. **Sem CSP** (`Content-Security-Policy`). A página é estática e autocontida, então o risco
   é baixo, mas uma CSP restritiva seria barata de adicionar.
3. **HSTS ainda não ativo.** É semi-irreversível (o navegador cacheia por meses), então a
   decisão foi deixar consciente para depois.
4. **Acessibilidade e performance** não foram auditadas. O arquivo tem 1,4 MB em requisição
   única por causa do base64 embutido — vale opinião sobre esse trade-off (zero requisições
   extras versus um first-load pesado).

## Verificação de segurança já feita no arquivo

| Item | Resultado |
|---|---|
| Chaves / segredos embutidos | Nenhum |
| Rastreadores (Meta Pixel, GA) | Nenhum |
| Chamadas de rede externas | Nenhuma — só o namespace `w3.org/2000/svg`, que é inerte |
| `eval`, `innerHTML`, cookies, `localStorage` | Nenhum |
| JavaScript | Um bloco só, vanilla, sem dependências |

---

## Infraestrutura

A página é servida por Nginx atrás de Cloudflare, com TLS via Let's Encrypt e renovação
automática. Os detalhes de configuração do servidor não estão neste repositório — quem
precisar deles para a revisão, peça diretamente ao mantenedor.
