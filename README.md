# ShopNest CTF Base

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

## Development & Deployment

### Quick Start (Recommended for Linux / Kali / CTF Hosts)

On any fresh Linux or Kali machine, run the one-line deployment command:

```bash
git clone https://github.com/projectscyber2024-oss/ctf-meachinne-.git && cd ctf-meachinne- && PORT=9000 bash setup.sh
```

If the repository is already cloned locally:

```bash
PORT=9000 bash setup.sh
```

- **Application URL:** `http://localhost:9000` (or `http://<LAN-IP>:9000`)
- **Docker Base:** `node:22-bookworm-slim`
- **Native Addon:** `better-sqlite3` compiles/runs reliably inside Docker.
- **Database Persistence:** SQLite database is persisted inside the Docker named volume `shopnest-data` (`/app/data/ctf.sqlite`).

### Container Management

- **View container logs:**
  ```bash
  docker compose logs -f
  ```
- **Check container status:**
  ```bash
  docker compose ps
  ```
- **Restart services:**
  ```bash
  docker compose restart
  ```
- **Stop services (preserving database and CTF state):**
  ```bash
  docker compose down
  ```
- **Resume services:**
  ```bash
  docker compose up -d
  ```

### Windows Hosts (Docker Desktop)

**PowerShell:**
```powershell
git clone https://github.com/projectscyber2024-oss/ctf-meachinne-.git; cd ctf-meachinne-; ./start.ps1
```

**Command Prompt:**
```cmd
git clone https://github.com/projectscyber2024-oss/ctf-meachinne-.git && cd ctf-meachinne- && start.bat
```

