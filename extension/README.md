# Ecommerce KPI - Browser Extension Agent

This is the Browser Extension sub-project of the **Enterprise Multi-Channel Ecommerce KPI Management System**.

## Tech Stack
- **Framework:** React 18 (TypeScript)
- **Build Tool:** Vite + CRXJS (Manifest V3 support)
- **State Management:** Zustand
- **HTTP Client:** Axios
- **Testing:** Vitest

## Getting Started

### Prerequisites
- Node.js >= v20.x
- npm >= v10.x

### Installation
From the current directory:
```bash
npm install
```

### Development
To run in hot-reload development mode:
```bash
npm run dev
```
Then load the `dist` directory in Chrome Developer Mode (`chrome://extensions/` -> "Load unpacked").

### Production Build
To bundle the extension for production deployment:
```bash
npm run build
```
The compiled assets will be generated in the `dist/` directory.

### Running Lint Checks
```bash
npm run lint
```

### Running Tests
```bash
npm run test
```
