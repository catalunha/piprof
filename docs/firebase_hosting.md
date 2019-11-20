
# Build aplicação Flutter Web
visite: https://flutter.dev/docs/get-started/web
Mas o passo a passo é.

1. Mudar o channel para master
flutter channel master
2. Atualize o flutter
flutter upgrade
3. Habilitar o modo web
   * `flutter config --enable-web`
4. Conferir se os devices estao prontos
   * `flutter devices`
   * tem q surgir este device habilitado
     * `Chrome • chrome • web-javascript • Google Chrome 76.0.3809.100`
5. Mandar executar o flutter no device específico
   * `flutter run -d chrome`
6. Trabalhar normalmente dando r pra reload no Terminal do VSCode e no chrome CTRL+ 'Recarregar página' . O aplicativo tb funciona no emulador dando F5 ou reload no VSCode na barra de botoes do debug.
8. Compile o codigo com
   * `flutter build web`
9. A aplicação será gerada em build/web

