# Alagoas Mobilidade

Aplicação web inicial para conectar passageiros e motoristas nos 102 municípios de Alagoas.

## Tecnologias
- HTML, CSS e JavaScript
- Supabase Auth e PostgreSQL com Row Level Security
- Supabase JS v2 via CDN

## Configuração
1. Abra o projeto Supabase: https://supabase.com/dashboard/project/lmddodyzurpxswvnfsnv
2. No SQL Editor, execute todo o conteúdo de `supabase/schema.sql`.
3. Confira em Authentication → Providers se e-mail/senha está habilitado. Se a confirmação de e-mail estiver ativa, o usuário deverá confirmar o endereço antes de entrar.
4. Em Authentication → URL Configuration, adicione a URL publicada do site às Site URL e Redirect URLs.
5. Publique o repositório pelo GitHub Pages (Settings → Pages → Deploy from a branch → main → /(root)) ou conecte-o a um serviço de hospedagem estática.

A URL e a chave publishable já estão em `supabase-config.js`. Essa chave é própria para cliente público; nunca coloque uma chave `service_role` ou secret no navegador.

## Funcionalidades iniciais
- Cadastro e login por e-mail e senha
- Perfil passageiro/motorista definido no cadastro
- Solicitação de corrida com origem, destino, município e observações
- Motoristas autenticados podem visualizar solicitações abertas e aceitar uma corrida
- Passageiros visualizam suas solicitações; motoristas visualizam corridas abertas e as que aceitaram

## Limitações desta versão
Este é um MVP inicial. Ainda não inclui GPS em tempo real, mapas/rotas, cálculo automático de preço, pagamentos, chat, avaliação, verificação de documentos ou central administrativa. Combine valores e detalhes diretamente até que esses módulos sejam implementados. O cadastro como motorista ainda não representa verificação profissional.

## Estrutura
- `index.html` — interface
- `styles.css` — visual responsivo
- `app.js` — autenticação e corridas
- `supabase-config.js` — URL e chave pública do Supabase
- `supabase/schema.sql` — tabelas, gatilho e políticas RLS