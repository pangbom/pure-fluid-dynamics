# Pure Fluid Dynamics

A free, open-source wind tunnel and fluid dynamics simulator that runs in any modern browser on Mac, Windows, Linux, iPhone, iPad and Android. Draw a shape, turn on the wind, and watch the air flow around it. Inspired by Wind Tunnel by Algorizk, which is no longer available for Mac and iPhone. Not affiliated with Algorizk.

## Features

- Real-time incompressible Navier–Stokes solver on the GPU (WebGL 2): MacCormack advection, implicit viscosity, red-black SOR pressure projection, optional vorticity confinement.
- Wind tunnel mode (adjustable wind, blowing left to right or top to bottom) and free mode (no wind, edges wrap around like a torus).
- Tools: interact (stir the fluid), draw obstacles (brush, line, circle, box), place smoke sources, erase, move and rotate.
- Views: smoke, particles (random or streaklines), speed, pressure coefficient with isobars, vorticity, plus velocity arrows.
- Lift and drag coefficients, L/D and Reynolds number, with a live trace.
- Lift-curve sweep: steps the angle of attack and plots Cl and Cd to show stall.
- Scenes: NACA airfoils, stalled wing, Kármán vortex street, ridge rotor, ram-air canopy, car, flat plate, rocks, free swirl, pillars.
- Save scenes in the browser, download/open scene files, share a scene as a link, screenshots and video recording.
- Installs as an app (Add to Home Screen on iPhone/iPad, Add to Dock in Safari on Mac, Install in Chrome/Edge) and works offline.

## Publish it free on GitHub Pages

1. Create a free account at github.com.
2. Click New repository. Name it `pure-fluid-dynamics`, set it to Public, and create it.
3. Click "uploading an existing file", drag in every file from this folder (including `.nojekyll`), and click Commit changes.
4. Go to Settings → Pages. Under Source choose "Deploy from a branch", branch `main`, folder `/ (root)`, and Save.
5. After a minute the app is live at `https://<your-username>.github.io/pure-fluid-dynamics/`.

To update later, upload the changed `index.html` the same way.

Alternative: drag this folder onto https://app.netlify.com/drop for an instant free link.

## Run locally

Open `index.html` in a browser. Offline install and share links need it to be served over https (GitHub Pages does this).

## Limits

The simulation is 2D, runs at Reynolds numbers in the thousands, and uses a staircase grid for shapes, so lift and drag are qualitative. Stall is gentler than on full-size wings at high Reynolds numbers.

## License

MIT
