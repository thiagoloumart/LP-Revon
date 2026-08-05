-- Tabela de leads da landing page da Revon.
-- Rodar no Supabase: projeto revon-lp-leads → SQL Editor → colar → Run.
--
-- As colunas têm exatamente os mesmos nomes dos campos do formulário em
-- index.html (name="nome", name="clinica", ...). Se mudar um nome lá, mude aqui.

create table if not exists public.leads (
  id           uuid        primary key default gen_random_uuid(),
  criado_em    timestamptz not null default now(),
  nome         text        not null,
  clinica      text        not null,
  email        text        not null,
  telefone     text        not null,
  faturamento  text,
  cargo        text
);

-- ---------------------------------------------------------------------------
-- SEGURANÇA — a parte que não pode sair errada.
--
-- A chave anon fica exposta dentro do index.html, que é público (a página está
-- no ar e o repositório é aberto). Isso é o funcionamento normal do Supabase,
-- MAS só é seguro por causa do RLS abaixo.
--
-- Existe uma política de INSERT e nenhuma de SELECT. Com o RLS ligado, o que
-- não tem política é negado — então o visitante anônimo consegue gravar um
-- lead e não consegue ler nenhum. Se alguém criar uma política de SELECT para
-- o papel anon, a base inteira de leads passa a ser baixável por qualquer
-- pessoa usando a chave que está na própria página. Não faça isso.
--
-- Para ler os leads: use o painel do Supabase, ou a service_role no servidor.
-- ---------------------------------------------------------------------------

alter table public.leads enable row level security;

drop policy if exists "anon pode inserir lead" on public.leads;

create policy "anon pode inserir lead"
  on public.leads
  for insert
  to anon
  with check (true);

-- Conferência rápida depois de rodar:
--   select relrowsecurity from pg_class where oid = 'public.leads'::regclass;  -- deve dar true
--   select cmd, roles from pg_policies where tablename = 'leads';             -- só INSERT / {anon}
