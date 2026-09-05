# ShopNest CTF Base

## Run With Docker

Prerequisite: a Linux/Kali machine with Git, Docker Engine, and the Docker Compose plugin installed. No host Node.js, npm, SQLite, Python, or compiler setup is required.

Run the current CTF with one command:

```bash
git clone https://github.com/projectscyber2024-oss/ctf-meachinne-.git && cd ctf-meachinne- && docker compose up --build -d
```

Open `http://localhost:9000`. To access it from another device on the same network, use `http://<machine-ip>:9000`.

The image uses Node.js 22, installs dependencies and compiles `better-sqlite3` inside the image, then starts the application. The committed current database is copied into a named Docker volume only on first start; existing volume data is preserved on rebuilds and restarts.

Create a lightweight fictional e-commerce website for a cybersecurity CTF lab.

Overall Design

Make the UI inspired by the clean, simple layout of major Indian e-commerce websites such as Flipkart.

Do NOT copy Flipkart's logo, branding, proprietary assets, or exact design.

Use a fictional brand name: "ShopNest".

Keep the interface simple, modern, clean, and lightweight.

Do not create a huge marketplace.

Use only around 12–16 fictional products.

Prioritize fast loading and simple navigation.

Header

Create a simple e-commerce header containing:

ShopNest logo/text

Search bar

Login button

Cart icon/button

Simple navigation/categories

Homepage

Create:

Small promotional banner

4–5 product categories

Product grid

Around 12–16 products total

Product image

Product name

Price

Rating

"Add to Cart" button

"View Details" button

Use fictional products such as:

Wireless Headphones

Smart Watch

Mechanical Keyboard

Gaming Mouse

Backpack

Power Bank

Bluetooth Speaker

USB-C Hub

Laptop Stand

Smartphone Case

LED Desk Lamp

Fitness Band

Product Details

Each product should have:

Product image

Product name

Price

Rating

Short description

Stock status

Quantity selector

Add to Cart button

Buy Now button

Authentication

Create:

Register page

Login page

Logout functionality

User profile page

Users should be able to create a normal account and log in.

Cart

Create a simple cart:

Product

Quantity

Price

Remove button

Total price

Checkout button

Orders

Create a simple fictional order flow:

Checkout

Order confirmation

Orders page

Order details

No real payment gateway is required.

Admin UI Placeholder

Create a basic placeholder route for an admin area, but DO NOT implement any vulnerabilities or challenge logic yet.

The project will later be converted into a controlled cybersecurity CTF lab.

Technical Requirements

Keep the codebase lightweight.

Use reusable components.

Use responsive design for desktop and laptop screens.

Use fictional data only.

No external APIs.

No real payment processing.

No unnecessary animations.

No excessive product listings.

No unnecessary dependencies.

IMPORTANT:
This is only the clean base application.

Do NOT add:

vulnerabilities

exploits

brute-force logic

IDOR logic

authentication bypasses

hidden parameters

privilege escalation

flags

steganography

challenge solutions

Those will be added separately after the base website is working correctly.

This project was built with [Lovable](https://lovable.dev).

## Build with Lovable

Continue developing this project in the [Lovable editor](https://lovable.dev/projects/f9bfc71b-95de-436e-9993-08f6205bb5f9).

- **Ship faster**: describe what you want to build and Lovable handles the code.
- **Stay in sync**: every change made in Lovable is committed straight to this repository.
- **Full ownership**: this code is yours. Push to `main` on GitHub and your changes sync back into Lovable, ready for your next prompt.

## Development

### One-Command Setup

Copy and run ONE Docker command on your computer. Node.js, npm, native SQLite tooling, and project dependencies are provided inside the container.

**Linux / macOS:**

```bash
git clone https://github.com/noyall-gf/final-ctf-meachine-.git && cd final-ctf-meachine- && docker compose up --build -d
```

**Windows (PowerShell):**

```powershell
git clone https://github.com/noyall-gf/final-ctf-meachine-.git; cd final-ctf-meachine-; docker compose up --build -d
```

**Windows (Command Prompt):**

```cmd
git clone https://github.com/noyall-gf/final-ctf-meachine-.git && cd final-ctf-meachine- && docker compose up --build -d
```

Open browser: `http://localhost:3000`

### Quick Start

Clone and run the setup script on your computer. Node.js 22 will be downloaded automatically.

**Linux / macOS:**

```sh
git clone https://github.com/noyall-gf/final-ctf-meachine-.git
cd final-ctf-meachine-
docker compose up --build -d
```

**Windows (PowerShell):**

```powershell
git clone https://github.com/noyall-gf/final-ctf-meachine-.git
cd final-ctf-meachine-
docker compose up --build -d
```

**Windows (Command Prompt):**

```cmd
git clone https://github.com/noyall-gf/final-ctf-meachine-.git
cd final-ctf-meachine-
docker compose up --build -d
```

Docker is the recommended reproducible setup. The older `setup.sh`, `setup.ps1`, and `setup.bat` scripts remain available for non-Docker development, but they require a host runtime and are not needed for the portable deployment.

### Alternative: Manual Setup

If you prefer to install dependencies yourself, install Node.js 22 LTS — [install with nvm](https://github.com/nvm-sh/nvm#installing-and-updating). SQLite is included through the `better-sqlite3` dependency; a separate SQLite installation is not required.

```sh
git clone <this-repository-url>
cd <repository-name>
npm ci --legacy-peer-deps
npm run dev
```

### Docker: Portable One-Line Setup

This is the recommended setup for running the CTF independently on many computers. Install Docker Desktop on each computer, then run one command from PowerShell, Command Prompt, or a terminal.

**Windows PowerShell:**

```powershell
git clone https://github.com/noyall-gf/final-ctf-meachine-.git; cd final-ctf-meachine-; docker compose up --build -d
```

**Windows Command Prompt:**

```cmd
git clone https://github.com/noyall-gf/final-ctf-meachine-.git && cd final-ctf-meachine- && docker compose up --build -d
```

**Linux/macOS:**

```sh
git clone https://github.com/noyall-gf/final-ctf-meachine-.git && cd final-ctf-meachine- && docker compose up --build -d
```

Docker automatically provides the pinned Node.js 22 runtime, installs the locked dependency versions, and builds the native SQLite dependency inside the container. No Node.js, npm, Python, or compiler installation is needed on the host computer.

Open `http://localhost:3000`. To access it from another device on the same network, use `http://<computer-ip>:3000`.

On first startup, the committed seed database is copied into the persistent `shopnest-data` Docker volume. This preserves the existing users, admin, cart data, and flags. Later changes remain independent on each computer and survive container restarts.

To use another host port, copy `.env.example` to `.env` and change `HOST_PORT`:

```sh
cp .env.example .env
# Edit .env: HOST_PORT=3001
docker compose up --build -d
```

The application still listens on port `3000` inside the container; `HOST_PORT` only changes the port exposed on the host.

Stop the local instance with:

```sh
docker compose down
```

Rebuild and restart after code changes with:

```sh
docker compose up --build -d
```

To remove the local database volume too, use `docker compose down -v`.
