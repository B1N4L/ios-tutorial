# PlayHub

A small iOS app I built while learning SwiftUI. It's a collection of three quick mini-games with high scores, a stats screen, a map of where I played, and a daily reminder. Started as one big pile of views and I slowly refactored it into something cleaner.

## The games

- **Tap Frenzy** – tap the button as fast as you can for 10 seconds. Chaining taps quickly builds a combo multiplier, and the button shrinks and jumps around to make it harder.
- **Light It Up** – a lit tile appears in a grid and you have to tap it before it goes dark. You have 3 lives, and the grid gets bigger / faster as the timer counts down through four levels.
- **Quiz Rush** – trivia questions pulled from the Open Trivia DB API. +1 for a correct answer, -0.5 for a wrong one.

## Architecture

I went with MVVM. The main reason was that my early versions had all the game logic sitting inside the View and it got really hard to follow, so splitting state + logic into a view model made a big difference.

```
tutorial-app/
├── App/            ContentView + tab bar
├── Models/         GameSession, GameMode, Quiz
├── ViewModels/     one VM per game + StatsVM
├── Views/
│   ├── Tabs/       Home, Stats, Map, Settings
│   └── Games/      the three game screens
├── Services/       API, persistence, location, notifications
└── Shared/         reusable bits (ScoreBadge)
```

A few things I tried to stick to:

- **Views stay dumb.** They render state and send taps to the view model. The game logic (timers, scoring, combos) lives in the VM.
- **Services behind protocols.** `APIService`, `HighScoreService`, `LocationService` and `NotificationService` each have a protocol, and the view models take them in through the initializer with a default. That way the model layer doesn't know anything about `UserDefaults` or the network, and I could swap in a fake later for testing.
- **One place for saving scores.** Every game ends by creating a `GameSession` and handing it to `HighScoreService`, which encodes the whole list to JSON in `UserDefaults`. Because they all share the same store, the Stats and Map screens can read across every mode.

The app is a `TabView` with four tabs, and each tab is its own `NavigationStack`.

## Features

- Three mini-games with their own scoring rules
- High scores saved between launches (JSON in UserDefaults)
- Stats tab: total games, total score, personal best per mode, recent games, and a bar chart per mode using Swift Charts
- Map tab: drops a pin for every game I played that recorded a location, tap a pin to see the score
- Location tagging on each session using Core Location
- Daily Challenge: schedule a repeating local notification at a time I pick in Settings
- Settings: notifications toggle, reminder time picker, and a reset-all-stats button with a confirmation dialog
- Share button on the end screen that opens the system share sheet with a one-line score brag

## Known limitations

- Location only gets attached to *new* sessions. Anything I played before adding Core Location has no coordinates, so those don't show on the map.
- If the location permission is still being asked for when a game ends, that session falls back to 0,0 and gets skipped on the map.
- Tapping a map pin shows the score in a plain alert instead of a nicer map callout.
- Quiz Rush needs internet. If the API call fails it shows an error state, but there's no offline/cached question set.
- Scores are kept in `UserDefaults`. That's fine for a small app but it's not really meant for a growing list of data — a proper store like Core Data or SwiftData would be better.
- The notifications toggle doesn't check whether the user actually granted permission in iOS Settings, so it can look "on" while nothing is scheduled.
- No unit tests yet. I set the services up with protocols so they *can* be tested, but I haven't written them.
- There's still one leftover UIKit file (`ResultView.swift`) from an earlier attempt that isn't used anymore.

## Reflection

This project taught me a lot more than I expected, mostly because I let it get messy first and then had to clean it up.

The biggest lesson was the refactor to MVVM. In my first version, Tap Frenzy had timers, scoring, animation state and layout all in one giant view, and every small change felt risky. Moving that into a view model and letting the view just react to `@Published` values made everything easier to reason about. After that the other two games were much quicker to build because I already had the pattern.

Doing dependency injection through protocols was new to me. At first it felt like extra typing for no reason, but the moment I pulled `HighScoreManager` out of the model and into a `HighScoreService`, I got why people do it — the model stopped caring about storage, and every game saved scores the exact same way through one interface.

Some specific things I picked up:

- Using `Timer.publish` with Combine for the countdowns, and remembering to cancel the cancellables or the timer keeps firing after the game ends.
- `async/await` with `URLSession` for the trivia API, and modelling the screen as a small state enum (`idle / loading / playing / finished / error`) instead of a pile of booleans.
- Swift Charts for the stats bar chart, which was surprisingly little code.
- Core Location, MapKit annotations, and local notifications, all of which need permission handling I hadn't dealt with before.
- A concurrency warning around a `@MainActor` view model reading a shared singleton in its default arguments, which I fixed by building the dependencies inside the initializer instead.

If I kept going, the next things on my list would be writing unit tests for the services (now that they're injectable), moving persistence to SwiftData, and making the daily challenge actually respond to whether notifications are authorized. I'd also want to tidy up the last bits of dead code and make the map callouts nicer.

Overall I'm happy with where it ended up. It went from a single messy screen to something with a clear structure that I can actually keep adding to.
