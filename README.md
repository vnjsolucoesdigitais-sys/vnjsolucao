# VNJ · Painel de Licitações

Painel privado para duas contas da equipe VNJ. Interface em português, responsiva, com licitações, clientes VNJ, órgãos compradores, fornecedores, contatos, alertas internos e exportação CSV compatível com Excel.

## Antes de começar

- Uma conta Cloudflare no plano Free.
- Node.js e npm instalados no computador.
- Wrangler conectado à sua conta Cloudflare (`npx wrangler login`).
- Não habilite planos pagos nem cobrança por uso. O aplicativo bloqueia anexos acima de 20 MB e limita o total de PDFs guardados a 8 GB. Os limites da conta Cloudflare também se aplicam.

## Criar os serviços gratuitos

Abra um terminal nesta pasta e rode:

```bash
npm install
npx wrangler login
npx wrangler d1 create vnj-painel-db
npx wrangler r2 bucket create vnj-painel-arquivos
```

O comando do D1 mostrará um `database_id`. Copie esse ID no lugar de `SUBSTITUA_PELO_ID_D1` nos dois arquivos:

- `wrangler.toml`
- `worker/wrangler.toml`

O nome do banco deve continuar `vnj-painel-db`; o bucket deve continuar `vnj-painel-arquivos`.

Depois, crie as tabelas no banco remoto:

```bash
npm run db:init
```

## Testar no computador

```bash
npm run dev
```

Abra o endereço local mostrado pelo Wrangler. Configure a primeira conta de administrador. Depois de entrar, use **Configurações → Adicionar conta do sócio** para criar a segunda conta. Ambas têm permissões iguais.

## Publicar em `pages.dev`

Publique primeiro o sincronizador automático e depois a aplicação:

```bash
npm run deploy:cron
npm run deploy
```

O endereço público será exibido pelo Wrangler, no formato `https://vnj-painel-licitacoes.pages.dev`. Nas configurações do projeto Pages, confirme que os bindings `DB` (D1) e `FILES` (R2) estão conectados ao banco e bucket criados acima. No Worker `vnj-painel-sync`, confirme o binding `DB` e o agendamento a cada três horas. Os arquivos de configuração já declaram esses bindings.

Faça o primeiro acesso nesse endereço e crie a primeira conta. O cadastro inicial só fica aberto até a primeira conta ser criada; depois, apenas usuários autenticados podem usar o painel.

## O que funciona

- Cadastro e login individuais com senha protegida, sessão segura e até duas contas.
- Cadastro de licitação, etapa de trabalho, prazo, notas e PDF; leitura de texto do PDF no navegador quando o arquivo tem texto selecionável. PDF escaneado fica anexado para preenchimento manual.
- Alertas dentro do painel e lembretes de prazo em 7 dias, 4 dias, 2 dias e 8 horas.
- Consulta de editais de propostas abertas no PNCP, com atualização manual e Worker agendado a cada três horas.
- Importação manual de empresas fornecedoras a partir de contratos publicados no PNCP e sugestões por termos coincidentes entre o edital e os objetos desses contratos.
- Cadastro separado de clientes/leads VNJ e órgãos compradores encontrados nos editais.
- Histórico de atividades, filtros locais, preferências de alertas, exportação CSV e atalhos para contato.

## Limites e conferência humana

- A consulta automática de editais percorre até cinco páginas de 50 registros por rodada. Em períodos de publicação intensa, pode haver mais resultados que esse limite; o PNCP continua disponível para conferência direta.
- A consulta de fornecedores percorre até quatro páginas de 100 contratos recentes. Ela não é um diretório exaustivo de todas as empresas brasileiras.
- A nota de aderência usa termos do objeto e contratos públicos anteriores; não comprova estoque, capacidade atual, frete, prazo, habilitação nem disponibilidade. Confirme esses dados com cada empresa e leia o edital oficial antes de decidir.
- PDF com texto selecionável tem campos sugeridos por regras simples; todos os campos precisam ser revisados. Arquivo escaneado não passa por OCR e deve ser preenchido manualmente.
- WhatsApp, telefone e e-mail abrem o aplicativo de contato para envio manual. O painel não envia mensagens nem e-mails automaticamente.
- Os limites de D1 e R2 dependem das condições vigentes da conta Cloudflare. Ao atingir o limite interno de PDFs, novos anexos são recusados.

## Arquivos principais

- `public/` — painel web.
- `functions/api/[[path]].js` — API de autenticação, dados, PNCP e anexos.
- `worker/sync.js` — atualização agendada do PNCP e lembretes.
- `schema.sql` — estrutura do banco D1.
- `wrangler.toml` — configuração do Cloudflare Pages.
- `worker/wrangler.toml` — configuração do Worker de sincronização.
