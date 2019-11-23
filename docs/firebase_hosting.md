
# Build aplicação in Flutter Web
visite: https://flutter.dev/docs/get-started/web
Mas o passo a passo é.

1. Mudar o channel para master
~~~
flutter channel master
~~~
2. Atualize o flutter
flutter upgrade
3. Habilitar o modo web
~~~
flutter config --enable-web
~~~
4. Conferir se os devices estao prontos
~~~
flutter devices
~~~
   tem q surgir este device habilitado
~~~
Chrome • chrome • web-javascript • Google Chrome 76.0.3809.100
~~~
5. Mandar executar o flutter no device específico
~~~
flutter run -d chrome
~~~
6. Trabalhar normalmente dando r pra reload no Terminal do VSCode e no chrome CTRL+ 'Recarregar página' . O aplicativo tb funciona no emulador dando F5 ou reload no VSCode na barra de botoes do debug.
8. Compile o codigo com este comando. A aplicação será gerada em build/web pronta para deploy
~~~
flutter build web
~~~



# Deploy in Firebase Hosting

1. Acesse esse link: https://firebase.google.com/docs/hosting/quickstart?hl=pt-BR
2. Execute a etapa 01 - somente a primeira vez
3. Não executar a etapa 02 - já foi configurado no projeto
4. Para gerar o build web veja detalhes em: https://flutter.dev/docs/get-started/web
5. Antes confira o firebase.json em ./piprof/firebase.json q deve ficar desta forma:
~~~
Para o PI-Prof
{
  "hosting": {
    "site": "piprof-brintec",
    "public": "build/web",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ]
  }
}
Para o PI-Aluno
{
  "hosting": {
    "site": "pialuno-brintec",
    "public": "build/web",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ]
  }
}
~~~
6. Se nao estive compilado para web aplique:
~~~
flutter build web
~~~
8. Executar a etapa 03 - deploy para o hosting
~~~
firebase deploy
~~~

Todos os assets são movidos automaticamente para o endereço /web/assets
