# Mattiz

Mattiz è una piattaforma di comunicazione anonima progettata per dispositivi iOS e Android. L'applicazione combina trasporto Internet e connessioni Bluetooth long range per garantire continuità della comunicazione anche in assenza di rete dati. Questo repository contiene un prototipo Flutter multipiattaforma con le principali schermate utente, la gestione dell'autenticazione locale e i servizi per orchestrare chat private e instradamento dei messaggi tra differenti canali.

## Funzionalità principali

- **Registrazione e login anonimi**: l'utente sceglie un alias effimero memorizzato localmente senza collegamento a dati personali.
- **Chat private uno-a-uno**: interfaccia Material con elenco conversazioni, anteprima dell'ultimo messaggio e contatore dei non letti.
- **Trasporto multi-canale**: servizi dedicati per WebSocket e Bluetooth Low Energy long range, con fusione degli stream in un unico controller di chat.
- **Persistenza locale**: preferenze condivise per conservare lo stato minimo d'uso e ripristinare la sessione.
- **Architettura modulare**: Riverpod per la gestione dello stato, GoRouter per la navigazione tipizzata e separazione chiara tra modelli, servizi e UI.

## Struttura del progetto

```
lib/
  app.dart                 # Configurazione principale dell'app Material
  main.dart                # Entry point con ProviderScope
  controllers/             # Gestione stato (ChatController)
  models/                  # Modelli dominio (utente, conversazione, messaggio)
  routes/                  # GoRouter e regole di redirect
  screens/                 # Schermate di login, registrazione, chat list e chat
  services/                # Servizi di autenticazione, rete e Bluetooth
  theme/                   # Tema Material personalizzato
  widgets/                 # Componenti riutilizzabili (es. MessageBubble)
```

## Dipendenze chiave

- **Flutter**: motore UI multipiattaforma.
- **flutter_riverpod**: gestione stato reattiva.
- **go_router**: navigazione dichiarativa.
- **flutter_blue_plus**: integrazione con Bluetooth Low Energy long range.
- **web_socket_channel**: trasporto WebSocket per messaggistica in tempo reale.
- **shared_preferences**: persistenza locale di sessione.

## Avvio del progetto

1. Installare l'[SDK di Flutter](https://docs.flutter.dev/get-started/install) e configurare gli strumenti per iOS/Android.
2. Recuperare le dipendenze:
   ```bash
   flutter pub get
   ```
3. Avviare l'app su un emulatore o dispositivo fisico:
   ```bash
   flutter run
   ```
4. Per attivare la messaggistica WebSocket sostituire l'endpoint fittizio `wss://mattiz.example/ws` in `lib/controllers/chat_controller.dart` con il backend reale.

## Considerazioni sulla privacy e sicurezza

- I messaggi dovrebbero essere cifrati end-to-end prima dell'invio; il prototipo espone i punti in cui inserire la crittografia (es. nei servizi di rete/Bluetooth).
- È consigliabile introdurre una fase di *handshake* sicuro via Bluetooth per scambiarsi chiavi temporanee quando non è disponibile Internet.
- Valutare l'uso di identità effimere rinnovate periodicamente per ridurre la correlazione tra conversazioni.

## Passi successivi suggeriti

- Implementare un backend sicuro per l'instradamento Internet, con autenticazione anonima e gestione token.
- Integrare crittografia end-to-end con Double Ratchet o protocollo simile.
- Aggiungere sincronizzazione offline e caching avanzato delle conversazioni.
- Introdurre test widget e unitari per garantire la stabilità delle funzionalità principali.
