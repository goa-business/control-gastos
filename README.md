# Control de Gastos y Bancos · Venezuela

App de GOA Business para llevar gastos, bancos y gastos por pagar en Bs. y $.

- **Página oficial:** https://goa-business.github.io/control-gastos/
- **App web:** https://goa-business.github.io/control-gastos/app/
- **APK Android:** pestaña **Releases** → `Control_de_Gastos.apk`

| Carpeta / archivo | Qué es |
|---|---|
| `index.html` | Página única: cómo funciona, precios y descargas |
| `app/index.html` | La app (código protegido) |
| `manifest.webmanifest`, `sw.js` | Hacen que se pueda instalar en la pantalla principal y que funcione sin internet |
| `privacidad.html` | Política de privacidad (la pide Google Play) |
| `firma.jks.enc` | Llave de firma del APK **cifrada**. Solo se abre con el secreto `KS_PASS` |
| `.github/workflows/apk.yml` | Fabrica el APK y el AAB de Google Play automáticamente |

## Cómo se fabrica el APK
Cada vez que cambia `app/`, GitHub lo fabrica solo (pestaña **Actions**). El APK queda en **Releases** y el archivo para Google Play (`.aab`) en el resultado de la ejecución, sección **Artifacts**.

La versión de Estados Unidos está en el repositorio aparte `goa-business/gastos`.

© 2026 GOA Business. Todos los derechos reservados.
