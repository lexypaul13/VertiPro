# VertiPro

**Augmented-reality guidance for vestibular rehabilitation exercises.**

VertiPro is an experimental iPhone app that helps people perform guided head-movement exercises and track their progress over time. Using ARKit face tracking, the app detects head movement, presents directional targets, gives real-time visual and spoken feedback, and records exercise results.

> **Project status:** VertiPro is a prototype. It is not a medical device and is not intended to diagnose, treat, cure, or prevent any condition.

## Why VertiPro

Vestibular disorders can affect balance and spatial orientation, producing symptoms such as recurring dizziness. Rehabilitation exercises can help some patients, but it can be difficult to perform movements consistently and understand whether technique is improving.

VertiPro explores a more interactive approach: use the iPhone's front-facing camera and augmented reality to guide each movement, measure the response, and turn exercise sessions into understandable progress data.

## Features

- **AR-guided exercises** with targets for up, down, left, and right head movements
- **Real-time face tracking** and movement validation powered by ARKit
- **Immediate feedback** through adaptive visuals, accuracy indicators, and voice prompts
- **Configurable sessions** with adjustable speed, arrow size, movement pattern, and duration
- **Dizziness check-in** on a 1–10 scale before each session
- **Session results** including accuracy, completed targets, and head turns per minute
- **Progress dashboard** with exercise frequency and performance summaries
- **Daily, weekly, monthly, and yearly views** for reviewing trends
- **Exercise history** sortable by date, accuracy, duration, or dizziness level
- **Local persistence** for session data using `UserDefaults` and `Codable`
- **Onboarding, safety guidance, and accessibility settings**

## How it works

1. The user records their current dizziness level.
2. They select a movement pattern, pace, target size, and session duration.
3. VertiPro displays directional targets over the live camera view.
4. ARKit face tracking evaluates pitch and yaw as the user moves their head.
5. The app supplies visual and spoken feedback and records each response.
6. Completed sessions feed the dashboard, history, and trend views.

## Technology

- Swift and SwiftUI
- ARKit and SceneKit
- Apple Charts
- AVFoundation speech synthesis
- Combine
- `Codable` and `UserDefaults` for on-device storage

The current implementation has no third-party package dependencies or remote backend.

## Requirements

- macOS with Xcode
- iOS 17.6 or later
- A physical iPhone that supports ARKit face tracking

Face tracking depends on device hardware and is not available in the iOS Simulator.

## Run locally

```bash
git clone https://github.com/lexypaul13/VertiPro.git
cd VertiPro
open VertiPro.xcodeproj
```

In Xcode:

1. Select the **VertiPro** scheme.
2. Choose a compatible physical iPhone as the run destination.
3. Select your development team under **Signing & Capabilities** if required.
4. Build and run the app.
5. Grant camera access when prompted.

## Project structure

```text
VertiPro/
├── VertiProApp.swift            # Application entry point
├── SplashScreenView.swift       # Launch, disclaimer, and onboarding flow
├── MainTabView.swift            # Dashboard, log, history, and settings
├── ExerciseSetupView.swift      # Session configuration
├── ExerciseView.swift           # Active guided exercise
├── ARViewContainer.swift        # AR scene and visual feedback
├── HeadTrackingManager.swift    # Face tracking and movement analysis
├── ExerciseDataStore.swift      # Local session persistence
├── ExerciseSession.swift        # Session and movement models
├── DashBoardView.swift          # Progress overview
├── DailyLogView.swift           # Time-based progress analysis
├── ExerciseSummaryView.swift    # Session history
└── Components/                  # Reusable dashboard and chart views
```

## Recognition

The original VertiPro concept earned **second place at the 2018 University of Texas at San Antonio CITE $100,000 Student Technology Venture Competition**. The team received a **$1,500 cash award**.

The competition team included:

- Alexander Paul
- Delano Covarrubias
- Cynthia Perez

Read the coverage from *Startups San Antonio*: [An Innovative Winch, AR App, and Medical Device Win UTSA CITE Competition](https://www.startupssanantonio.com/an-innovative-winch-ar-app-and-medical-device-win-utsa-cite-competition/).

## Safety and medical disclaimer

VertiPro is an educational prototype and a supplementary exercise tool. It does not replace professional medical advice, diagnosis, or treatment. Consult a qualified healthcare professional before beginning vestibular exercises. Stop immediately and seek appropriate care if an exercise causes severe dizziness, nausea, pain, or other concerning symptoms.

