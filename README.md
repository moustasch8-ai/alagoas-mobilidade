# Alagoas Mobilidade

Aplicação web inicial para conectar passageiros e motoristas nos 102 municípios de Alagoas.

## Tecnologias
- HTML, CSS e JavaScript
- Supabase Auth e PostgreSQL com Row Level Security
- Supabase JS v2 via CDN

## Configuração
1. Abra o projeto Supabase: https://supabase.com/dashboard/project/lmddodyzurpxswvnfsnv
2. O esquema inicial já foi aplicado. O arquivo `supabase/schema.sql` documenta as tabelas e políticas instaladas.
3. Em Authentication → Providers, confira se e-mail/senha está habilitado. Com confirmação de e-mail ativa, o usuário deverá confirmar o endereço.
4. Em Authentication → URL Configuration, adicione a URL publicada do site às Site URL e Redirect URLs.
5. Publique pelo GitHub Pages (Settings → Pages → Deploy from a branch → main → /(root)) ou conecte o repositório a uma hospedagem estática.

A URL e a chave publishable já estão em `supabase-config.js`. A chave é própria para cliente público; nunca coloque uma chave `service_role` ou secret no navegador.

## Funcionalidades iniciais
- Cadastro e login por e-mail e senha
- Solicitação de corrida com origem, destino, município e observações
- Histórico de solicitações do passageiro
- Estrutura de aceitação de corridas por motoristas aprovados

## Aprovação de motoristas
Por segurança, todo novo cadastro recebe papel efetivo de passageiro. Quem solicitar cadastro como motorista fica com `role_requested = 'driver'`, mas não recebe permissão para aceitar corridas automaticamente. Após verificar documentos e habilitação fora do app, um administrador pode aprovar o motorista no SQL Editor:

```sql
update public.profiles
set role = 'driver'
where id = 'UUID_DO_USUARIO' and role_requested = 'driver';
```

## Limitações desta versão
MVP inicial: ainda não inclui GPS em tempo real, mapas/rotas, cálculo automático de preço, pagamentos, chat, avaliação, verificação de documentos ou painel administrativo. Combine valores e detalhes da viagem diretamente até que esses módulos sejam implementados.

## Estrutura
- `index.html` — interface
- `styles.css` — visual responsivo
- `app.js` — autenticação e corridas
- `supabase-config.js` — URL e chave pública
- `supabase/schema.sql` — esquema, gatilho e políticas RLS