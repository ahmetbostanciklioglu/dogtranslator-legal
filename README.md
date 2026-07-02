<div align="center">

# 🐾 DogTranslator — Legal

**Public hosting for the DogTranslator AI privacy policy.**

<p>
  <img src="https://img.shields.io/badge/HTML5-E34F26?style=flat-square&logo=html5&logoColor=white" alt="HTML5">
  <img src="https://img.shields.io/badge/GitHub%20Pages-222?style=flat-square&logo=githubpages&logoColor=white" alt="GitHub Pages">
  <img src="https://img.shields.io/badge/license-privacy-6E48AA?style=flat-square" alt="Privacy Policy">
  <img src="https://img.shields.io/github/stars/ahmetbostanciklioglu/dogtranslator-legal?style=flat-square&color=6E48AA" alt="Stars">
  <img src="https://img.shields.io/github/last-commit/ahmetbostanciklioglu/dogtranslator-legal?style=flat-square&color=4776E6" alt="Last commit">
</p>

</div>

## 📖 Overview

This repository hosts the public privacy policy page for **DogTranslator AI**, an iOS app. It is a single self-contained static HTML page (no build step, no dependencies) served via GitHub Pages, with all styling inlined. The policy explains that the app is privacy-first: microphone audio is analyzed on-device and never recorded or transmitted, and most data stays on the user's device.

## ✨ Features

- Single, self-contained `index.html` with inline CSS — no build tooling or external assets required.
- Served as a GitHub Pages static site (`.nojekyll` disables Jekyll processing).
- Reachable at both the site root (`/`) and `/privacy/`, which mirror the same policy.
- Responsive, mobile-friendly layout with a gradient header and card sections.
- Covers microphone/audio, photos, dog profile, purchases, analytics, third-party services (Apple/StoreKit, Dog CEO API), data retention, and children.

## 🚀 Getting Started

```bash
# Clone the repository
git clone https://github.com/ahmetbostanciklioglu/dogtranslator-legal.git
cd dogtranslator-legal

# Open the page locally in your default browser
open index.html            # macOS
# or serve it over HTTP
python3 -m http.server 8080 # then visit http://localhost:8080
```

## 📋 Requirements

- Any modern web browser to view the page.
- For hosting: GitHub Pages (or any static file host). No server-side runtime, package manager, or build step is needed.

## 🧑‍💻 Author

**Ahmet Bostancıklıoğlu** — [@ahmetbostanciklioglu](https://github.com/ahmetbostanciklioglu) · ahmetbostancikli@gmail.com

> ⭐ If this helped you, consider giving the repo a star!
